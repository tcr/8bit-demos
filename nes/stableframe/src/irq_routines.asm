; (IRQ can be called up to 22 CPU cycles late according to Mesen.)

    ; Simplify how we look up additional bytes from the lookup table with a compiler variable.
    ; We should advance by at least two bytes (the length of an IRQ routine address) each routine,
    ; but we can read additional bytes from the table as well.
IRQ_ADVANCE_COUNT set 0

    ; Standard entry macro, preserves A and Y registers. Y register is used for additional lookup
    ; table values, and A is used for everything. You could also preserve X but simple routines
    ; don't need it.
IRQ_ENTER macro
        ; [+ 6] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y
        ; [= 6]

IRQ_ADVANCE_COUNT set 2
    endm

    ; Load the next byte from the table.
IRQ_LDA_NEXT_BYTE macro
        ldy #IRQ_ADVANCE_COUNT
        lda (zp_irq_lo),y

IRQ_ADVANCE_COUNT set IRQ_ADVANCE_COUNT + 1
    endm

    ; Increment the IRQ trampoline lookup by IRQ_ADVANCE_COUNT bytes.
IRQ_ADVANCE_LOOKUP macro
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE_COUNT
        sta zp_irq_lo
    endm

IRQ_EXIT macro
        ; Acknowledge and reset IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Restore registers.
        ldy zp_temp_y
        lda zp_temp_a

        ; Return from interrupt.
        rti
    endm

    ; "Quick coarse" scroll logic. Trashes A and Y.
    ; https://www.nesdev.org/wiki/PPU_scrolling#Quick_coarse_X/Y_split
COARSE_SCROLL macro ARGCOARSEX, ARGCOARSEY, ARGFINEY, ARGNAMETABLE
        lda #ARGNAMETABLE << 2 | (ARGCOARSEY >> 3) | (ARGFINEY << 4)
        ldy #ARGCOARSEX | (cutout(ARGCOARSEY, 0, 3) << 5)
        sta PPUADDR
        sty PPUADDR
    endm



; -------irq routine empty---------

    ; If you aren't updating DMC rate at all, simply advance the counter.
irq_routine_empty:
        IRQ_ADVANCE_LOOKUP
        rti


; -------irq routine one step and two step---------

    ; Set the DMC frequency once from the lookup table. P0 will be what DMCFREQ is equal to
    ; when this IRQ fires, but then next eight periods will be the retrieved frequency.
irq_routine_one_step:
        IRQ_ENTER

        ; Update DMC with P1 and P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        IRQ_ADVANCE_LOOKUP
        IRQ_EXIT


    ; Set the DMC frequency twice from the lookup table. P0 will be what DMCFREQ is equal to
    ; when this IRQ fires, P1 will be equal to the first provided frequency, and the next 7
    ; periods will be the second provided frequency.
    ;
    ; NOTE: This function expects DMCFREQ to be 54 or 72 cycles when called. You'll need to adjust
    ; the timing if DMCFREQ was higher when this routine is used.
irq_routine_two_step:
        ; [+ 6]
        IRQ_ENTER
        ; [= 6]

        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; [+30] Sleep.
        SLEEP 30
        ; [=51]

        ; [+ 5] After P1 starts, update DMC with P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=56]

        IRQ_ADVANCE_LOOKUP
        IRQ_EXIT


; ------irq routine vblank start------

irq_routine_vblank_start:
        IRQ_ENTER

        ; Update DMC with P1 and P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; Perform some PPU changes.
        ; Set PPUMASK emphasis to grey.
        lda #DEFAULT_PPUMASK | PPUMASK_GREYSCALE
        sta PPUMASK
        ; Reset scroll for the frame.
        lda #0
        sta PPUSCROLL
        sta PPUSCROLL

        ; Evaluate any VBLANK logic in the main program.
        jsr vblank_from_irq

        IRQ_ADVANCE_LOOKUP
        IRQ_EXIT


; ------irq routines for end-of-frame alignment------

irq_routine_align_start:
        IRQ_ENTER

        ; Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; Reset PPU scroll to the bottom section following the middle rows.
        COARSE_SCROLL 0, 23, 0, %00
        ; Set PPUMASK emphasis to grey.
        lda #DEFAULT_PPUMASK | PPUMASK_GREYSCALE
        sta PPUMASK

        ; Manually set IRQ trampoline to point to "current frame" section.
        lda zp_irq_align_sequence
        sta zp_irq_lo

        IRQ_EXIT


irq_routine_one_step_align:
        IRQ_ENTER

        ; Update DMC P1 with lookup3.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; Update the alignment sequence from the lookup table.
        IRQ_LDA_NEXT_BYTE
        sta zp_irq_align_sequence
        ; Set the IRQ trampoline to point to the start of the table again.
        lda #lo(irq_routines_table)
        sta zp_irq_lo

        IRQ_EXIT


irq_routine_two_step_align:
        ; [+ 6]
        IRQ_ENTER
        ; [+11] Update DMC P1 with lookup3.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [+50] Sleep.
        SLEEP 50
        ; [=67]

        ; [+ 8] Update DMC P2 with lookup4.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=75]
        
        ; Update the alignment sequence from the lookup table.
        IRQ_LDA_NEXT_BYTE
        sta zp_irq_align_sequence
        ; Set the IRQ trampoline to point to the start of the table again.
        lda #lo(irq_routines_table)
        sta zp_irq_lo

        IRQ_EXIT


; ------irq routines for light/dark rows------

        ; Expect to be called with DMC P0 = 54.
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_routine_row_light:
        ; [+ 6] 
        IRQ_ENTER
        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; Set PPUSCROLL register.
        COARSE_SCROLL 0, 7, 0, %00
        ; [+10] Clear PPUMASK.
        lda #DEFAULT_PPUMASK
        sta PPUMASK

        ; [+ 8] Sleep.
        sleep 12
        ; [=34]

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=39]

        IRQ_ADVANCE_LOOKUP
        IRQ_EXIT


        ; Expect to be called with DMC P0 = 54.
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_routine_row_dark:
        ; [+ 6] Preserve registers.
        IRQ_ENTER
        ; [= 6]

        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; Set PPUSCROLL register.
        COARSE_SCROLL 2, 7, 0, %00

        ; [+10] Change PPUMASK to darken row.
        lda #DEFAULT_PPUMASK | PPUMASK_EMPHRED | PPUMASK_EMPHGREEN | PPUMASK_EMPHBLUE
        sta PPUMASK

        ; [+ 8] Sleep.
        sleep 12
        ; [=34]

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=39]

        IRQ_ADVANCE_LOOKUP
        IRQ_EXIT

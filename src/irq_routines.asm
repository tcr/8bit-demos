IRQ_ADVANCE_COUNT set 0


IRQ_ENTER macro
        ; [+ 6] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y


IRQ_ADVANCE_COUNT set 2
    endm
    ; [= 6]


IRQ_LDA_NEXT_BYTE macro
        if IRQ_ADVANCE_COUNT == 2
            ldy #2
        else
            iny
        endif
        lda (zp_irq_lo),y

IRQ_ADVANCE_COUNT set IRQ_ADVANCE_COUNT + 1
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


IRQ_ADVANCE_LOOKUP macro
        if IRQ_ADVANCE_COUNT < 3
            rept IRQ_ADVANCE_COUNT
                inc zp_irq_lo
            endm
        else
            lda zp_irq_lo
            clc
            adc #IRQ_ADVANCE_COUNT
            sta zp_irq_lo
        endif
    endm


; -------irq generic routines---------

        ; OPTIMIZED
        ; TODO remove this by using actual DMA len value?
irq_keep_rate:
        IRQ_ADVANCE_LOOKUP
        rti


irq_set_rate:
        IRQ_ENTER

        ; Update DMC with P1 and P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE
        sta PPUMASK

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT


irq_set_two_rates:
        ; [+ 6]
        IRQ_ENTER
        ; [= 6]

        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [+30] Sleep.
        SLEEP 30
        ; [=51]

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=56]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT


irq_reset_to_frame:
        IRQ_ENTER

        ; Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; Change PPUMASK twice in quick succession to see a visible artifact.
        ; lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        ; sta PPUMASK
        ; lda #PPUMASK_COMMON | PPUMASK_EMPHRED
        ; sta PPUMASK

        ; Manually set IRQ trampoline to point to "current frame" section.
        lda zp_frame_index
        asl
        asl
        asl
        asl
        sta zp_irq_lo

        IRQ_EXIT


irq_set_rate_and_advance:
        IRQ_ENTER

        ; Update DMC P1 with lookup3.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; Restore PPUMASK to start showing colors after the blanking period.
        ; lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN
        ; sta PPUMASK

        ; Read the joypad, then update frame index based on it.
        jsr routine_read_joypad
        ldy zp_frame_index
        jsr routine_update_frame_from_joypad

        ; Manually set IRQ trampoline to point to "rows" section.
        lda #lo(table_irq_rows)
        sta zp_irq_lo

        IRQ_EXIT


irq_set_two_rates_and_advance:
        ; DMC P0=lookup2

        ; [+ 6]
        IRQ_ENTER
        ; [= 6]

        ; [+11] Update DMC P1 with lookup3.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=17]

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        ; lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN
        ; sta PPUMASK
        ; [+82] Sleep.
        SLEEP 82
        ; [=104]

        ; [+ 8] Update DMC P2 with lookup4.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=112]

        ; Read the joypad, then update frame index based on it.
        jsr routine_read_joypad
        ldy zp_frame_index
        jsr routine_update_frame_from_joypad

        ; Manually set IRQ trampoline to point to "rows" section.
        lda #lo(table_irq_rows)
        sta zp_irq_lo

        IRQ_EXIT


; ------irq colored row routines------

        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_light_row:
        ; [+ 6] 
        IRQ_ENTER
        ; [= 6]

        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [+ 8] Sleep.
        sleep 8
        ; [=34]

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=39]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT


        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_dark_row:
        ; [+ 6] Preserve registers.
        IRQ_ENTER
        ; [= 6]

        ; [+10] Update DMC with P1 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=16]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHRED | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [+ 8] Sleep.
        sleep 8
        ; [=34]

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=39]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT


irq_blank_set_rate:
        IRQ_ENTER

        ; Update DMC with P1 and P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT

irq_map_set_two_rates:
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

        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        IRQ_LDA_NEXT_BYTE
        sta DMCFREQ
        ; [=56]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP

        IRQ_EXIT

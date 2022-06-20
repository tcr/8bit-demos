
        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_light_row:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y
        ; [= 3]

        ; [+10] Update DMC with P1 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ
        ; [= 9]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [=19]

        ; [+ 5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=24]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ

        lda zp_irq_lo
        clc
        adc #3
        sta zp_irq_lo
        ; [=63]

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_dark_row:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y
        ; [= 3]

        ; [+10] Update DMC with P1 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ
        ; [= 9]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHRED | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [=19]

        ; [+ 5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=24]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ

        lda zp_irq_lo
        clc
        adc #3
        sta zp_irq_lo
        ; [=63]

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_last_row:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y
        ; [= 3]

        ; [+10] Update DMC with P1 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ
        ; [= 9]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHRED
        sta PPUMASK
        ; [=19]

        ; [+ 5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=24]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ

        lda zp_frame_index
        asl
        asl
        asl
        asl
        sta zp_irq_lo
        ; [=63]

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


; -------end of frame irq routines---------

irq_blank_0:
        ; Preserve registers.
        sta zp_temp_a
        sty zp_temp_y

        ; Update DMC with P1 and P2 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ

        ; Change PPUMASK to greyscale during the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        
        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        
        ; Advance IRQ trampoline
        inc zp_irq_lo
        inc zp_irq_lo
        inc zp_irq_lo
        
        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


irq_blank_1:
        ; Preserve registers.
        sta zp_temp_a
        sty zp_temp_y

        ; Update DMC with P1 and P2 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ

        ; Do any color updates if needed.

        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        inc zp_irq_lo
        inc zp_irq_lo
        inc zp_irq_lo

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


irq_blank_2:
        ; Preserve registers.
        sta zp_temp_a
        sty zp_temp_y

        ; Update DMC with P1 and P2 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ

        ; Do any color updates if needed.

        ; Read joypads (CPU cycles in this subroutine are not bounded).
        jsr routine_read_joypad

        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        inc zp_irq_lo
        inc zp_irq_lo
        inc zp_irq_lo

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti


irq_blank_3:
        ; DMC P0=lookup2

        ; [+ 6] Preserve registers.
        sta zp_temp_a
        sty zp_temp_y
        ; [= 6]

        ; [+11] Update DMC P1 with lookup3.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ
        ; [=17]

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [=22]

        ; [+42]
        SLEEP 82
        ; [=76]

        ; [+ 8] Update DMC P2 with lookup4.
        iny
        lda (zp_irq_lo),y
        sta DMCFREQ
        ; [=84]

        ldy zp_frame_index
        jsr routine_update_frame_from_joypad

        ; [+ 5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=34]

        ; [+ 5] Reset IRQ trampoline
        lda #lo(table_irq_rows)
        sta zp_irq_lo
        ; [=29]

        ; Restore registers and return.
        ldy zp_temp_y
        lda zp_temp_a
        rti

        ; [+ 3] Preserve registers.
IRQ_SAVE_REGISTERS macro
        sta zp_temp_a
        sty zp_temp_y
    endm

IRQ_RESTORE_REGISTERS macro
        ldy zp_temp_y
        lda zp_temp_a
    endm

IRQ_ADVANCE_LOOKUP macro BYCOUNT
        if BYCOUNT < 3
            rept BYCOUNT
                inc zp_irq_lo
            endm
        else
            lda zp_irq_lo
            clc
            adc #BYCOUNT
            sta zp_irq_lo
        endif
    endm


; -------irq frame routines---------

irq_blank_0:
        ; Preserve registers.
        IRQ_SAVE_REGISTERS

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
        IRQ_ADVANCE_LOOKUP 3
        
        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


irq_set_rate:
        ; Preserve registers.
        IRQ_SAVE_REGISTERS

        ; Update DMC with P1 and P2 rate.
        ldy #2
        lda (zp_irq_lo),y
        sta DMCFREQ

        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP 3

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


irq_blank_2:
        ; Preserve registers.
        IRQ_SAVE_REGISTERS

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
        IRQ_ADVANCE_LOOKUP 3

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


irq_blank_3:
        ; DMC P0=lookup2

        ; [+ 6] Preserve registers.
        IRQ_SAVE_REGISTERS
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

        ; Move IRQ trampoline to point to "rows" section.
        lda #lo(table_irq_rows)
        sta zp_irq_lo

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


; ------irq colored row routines------

        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_light_row:
        ; [+ 3] Preserve registers.
        IRQ_SAVE_REGISTERS
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
        ; [=63]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP 3

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_dark_row:
        ; [+ 3] Preserve registers.
        IRQ_SAVE_REGISTERS
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
        ; [=63]

        ; Advance IRQ trampoline
        IRQ_ADVANCE_LOOKUP 3

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti


        ; Expect to be called with DMC P0 = 54.
        ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
        ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_last_row:
        ; [+ 3] Preserve registers.
        IRQ_SAVE_REGISTERS
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
        ; [=63]

        ; Reset IRQ trampoline to point to current frame section.
        lda zp_frame_index
        asl
        asl
        asl
        asl
        sta zp_irq_lo

        ; Restore registers and return.
        IRQ_RESTORE_REGISTERS
        rti

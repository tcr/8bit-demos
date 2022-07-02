; --------dmc sync lookup--------

    ; Lookup table for DMC initial sync.
    include "dmc_sync.asm"

    ; This fits in the end of the DMC lookup table.
    include "vdelay_short.asm"

; --------nmi--------

    align 256
irq_initial_sync:
        ; pop return address
        pla
        pla
        tax
        pla

        lda dmc_sync_3_4,x
        and #%1111
        pha

        lda dmc_sync_3_4,x
        ror
        ror
        ror
        ror
        and #%1111
        pha

        lda dmc_sync_1_2,x
        and #%1111
        pha

        lda dmc_sync_1_2,x
        ror
        ror
        ror
        ror
        and #%1111
        pha

        nop
        nop
        nop
        nop
        nop
        
        pla
        tay
        ora #%10000000
        sta DMCFREQ
        lda dma_sync_delay_1,y
        beq +
        jsr vdelay
    +:
        lda dma_sync_delay_2,y
        beq +
        jsr vdelay
    +:

        pla
        tay
        ora #%10000000
        sta DMCFREQ
        lda dma_sync_delay_1,y
        beq +
        jsr vdelay
    +:
        lda dma_sync_delay_2,y
        beq +
        jsr vdelay
    +:

        pla
        tay
        ora #%10000000
        sta DMCFREQ
        lda dma_sync_delay_1,y
        beq +
        jsr vdelay
    +:
        lda dma_sync_delay_2,y
        beq +
        jsr vdelay
    +:

        pla
        tay
        ora #%10000000
        sta DMCFREQ
        lda dma_sync_delay_1,y
        beq +
        jsr vdelay
    +:
        lda dma_sync_delay_2,y
        beq +
        jsr vdelay
    +:

        ; Update IRQ rate to 52.
        nop
        nop

        ; Acknowledge and reset IRQ.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        lda #0
        sta PPUADDR
        sta PPUADDR

        ; Update IRQ trampoline to "jmp ($xxxx)" indirect lookup to IRQ table.
        lda #$6c
        sta zp_irq_jmp
        lda #lo(irq_routines_table)
        sta zp_irq_lo
        lda #hi(irq_routines_table)
        sta zp_irq_hi

        ; Set up the IRQ align sequence.
        lda #lo(irq_routines_table_align_0)
        sta zp_irq_align_sequence

        rti


; Each decode of the dmc_sync table requires some setup (splitting upper and lower nybbles) so
; we burn some CPU cycles. Subtract that from the actual delay number.
DMC_ADJUST = 25

; The sleep method only goes up to 256 cycles, so we split larger numbers into two steps. For lower
; numbers, if we read a 0, we just don't call the sleep method.

    align 16
dma_sync_delay_1:
        byt (428/2)-DMC_ADJUST, (380/2)-DMC_ADJUST, (340/2)-DMC_ADJUST, (320/2)-DMC_ADJUST, (286/2)-DMC_ADJUST, (254/2)-DMC_ADJUST, (226)-DMC_ADJUST, (214)-DMC_ADJUST, (190)-DMC_ADJUST, (160)-DMC_ADJUST, (142)-DMC_ADJUST, (128)-DMC_ADJUST, (106)-DMC_ADJUST, (84)-DMC_ADJUST, (72)-DMC_ADJUST, (54)-DMC_ADJUST

    align 16
dma_sync_delay_2:
        byt (428/2)+1, (380/2)+1, (340/2)+1, (320/2)+1, (286/2)+1, (254/2)+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


;--------NOP counter--------

    ; This method is called after the initial DMC starts to see how many clock cycles we need to
    ; adjust it by. This must be aligned so we can use the bottom byte of PC as our cycle count
    align 256
nop_chain:
        rept 432/2
            nop
        endm
        jmp nop_chain


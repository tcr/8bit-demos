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

        lda #$6c
        sta zp_irq_jmp
        lda #lo(table_irq_rows)
        sta zp_irq_lo
        lda #hi(table_irq_rows)
        sta zp_irq_hi

        rti

DMC_ADJUST = 25

    align 16
dma_sync_delay_1:
        byt (428/2)-DMC_ADJUST, (380/2)-DMC_ADJUST, (340/2)-DMC_ADJUST, (320/2)-DMC_ADJUST, (286/2)-DMC_ADJUST, (254/2)-DMC_ADJUST, (226)-DMC_ADJUST, (214)-DMC_ADJUST, (190)-DMC_ADJUST, (160)-DMC_ADJUST, (142)-DMC_ADJUST, (128)-DMC_ADJUST, (106)-DMC_ADJUST, (84)-DMC_ADJUST, (72)-DMC_ADJUST, (54)-DMC_ADJUST

    align 16
dma_sync_delay_2:
        byt (428/2)+1, (380/2)+1, (340/2)+1, (320/2)+1, (286/2)+1, (254/2)+1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    align 256
nmi_nop_count:
        rept 432/2
            nop
        endm
        jmp nmi_nop_count


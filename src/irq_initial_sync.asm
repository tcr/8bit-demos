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

irq_initial_sync_setup:
        ; Store IRQ trampoline "jmp irq_initial_sync" into ZP.
        lda #$4C
        sta zp_irq_jmp
        lda #lo(irq_initial_sync)
        sta zp_irq_lo
        lda #hi(irq_initial_sync)
        sta zp_irq_hi

        ; Setup initial DMC rate to the lowest rate before VBLANK.
        ; This ensures later we will wait the smallest length (<=54*8 cycles) to synchronize.
        SETMEM_DMCADDRESS DMC_SAMPLE_ADDR
        lda #0
        sta DMCLEN
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ

        ; Synchronize VBLANK to a consistent PPU frame, so we can time the DMC sync consistently.
        lda #0
	    sta zp_even_frame
        jsr sync_vbl_long

        ; Setup the stack such that an `rti` instruction from IRQ points to the main thread loop
        cli
        php
        sei

        ; Now enable the DMC.
        ; Due to a hardware quirk, we need to write the sample length three times in a row
        ; so as not to trigger an immediate IRQ. See https://www.nesdev.org/wiki/APU_DMC
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        sta APUSTATUS
        sta APUSTATUS

        ; Re-enable interrupts.
        cli
        ; Jump to the NMI waiting code to count NOPs. IRQ will interrupt this command, after which
        ; it will read the number of "nop" commands elapsed and calibrate DMC times off of it.
        jmp nmi_nop_count

    align 256
nmi_nop_count:
        rept 432/2
            nop
        endm
        jmp nmi_nop_count


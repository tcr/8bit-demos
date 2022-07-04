
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


; --------nmi--------

    align 256

    ; Subroutine to perform DMC sync. This will setup DMC to a short interval, wait a few frames to
    ; synchronize with PPU, then measure DMC delay.
initial_dmc_sync:
        ; Adjust the lo return byte + 1 since we'll return to it via `rti` (different than `rts`)
        pla
        clc
        adc #1
        pha
        ; Clear the our processor state for `rti`.
        lda #$00
        pha

        ; Store IRQ trampoline "jmp irq_initial_sync" into ZP.
        lda #$4C
        sta zp_irq_jmp
        lda #lo(irq_initial_sync)
        sta zp_irq_lo
        lda #hi(irq_initial_sync)
        sta zp_irq_hi

initial_dmc_sync_midway:
        ; Setup initial DMC rate to the lowest rate before VBLANK.
        ; This ensures later we will wait the smallest length (<=54*8 cycles) to synchronize.
        SETMEM_DMCADDRESS DMC_SAMPLE_ADDR
        lda #0
        sta DMCLEN
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ

        ; Synchronize VBLANK to a consistent PPU frame, so we can time the DMC sync consistently.
        jsr sync_vbl_long
        ; Position to late in the frame where DMC calibration should happen. This allows the
        ; calibration to be performed so that the first IRQ will fire at the start of scanline 240.
        ; This can be manually adjusted as needed, as well as the delay length gen_dmc_sync.asm.
        ldy #34
        ldx #23
    -:	
        dey
        bne -
        nop
        dex
        bne -
        nop
        nop
        jmp * + 3

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
        jmp nop_chain

    ; Certain values are more prone to mismeasurement due to DMC fetch stalling the CPU right
    ; after the initial three writes to APU_STATUS (at least in mesen). If the measurement
    ; is one of these values, just retry sync.
irq_initial_sync_bail:
        ; Drop hi byte
        pla

        ; Disable current IRQ and future interrupts
        lda #0
        sta APUSTATUS
        sei

        ; Restart the DMC sync process and hope we get a different sync delay.
        lda #hi(initial_dmc_sync_midway)
        pha
        lda #lo(initial_dmc_sync_midway)
        pha
        php

        rti

    ; Initial IRQ for synchronizing DMC with a known cycle, using the dmc_sync lookup table
    ; and the lower byte of PC as our delay measurement.
irq_initial_sync:
        ; Pop stack state.
        pla
        ; Pop lower byte of return address. This is our delay measurement. Bail if needed.
        pla
        beq irq_initial_sync_bail ; mesen_sync_stress_test.lua showed errors with #$00
        cmp #$d3
        bcs irq_initial_sync_bail ; mesen_sync_stress_test.lua showed errors with #$d3, #$d4
        ; Move lookup offset to X.
        tax
        ; Ignore the hi byte.
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

        ; Alignment.
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

        ; Alignment.
        nop
        nop
        ; Update IRQ rate to 54.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
    
        ; End of timed code.
        ; Acknowledge and reset IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

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


;--------NOP counter--------

    ; This method is called after the initial DMC starts to see how many clock cycles we need to
    ; adjust it by. This must be aligned so we can use the bottom byte of PC as our cycle count.
    ; We don't expect measurmeent to ever exceed nop $d8 (e.g. 54 * 8 bits / 2 cycles)
    align 256
nop_chain:
        rept 255
            nop
        endm
        ; Fall through.
    
    ; Your game can also reuse nop_chain as a fixed sleep routine, such as via the SLEEP macro.
sleep_routine:
        rts


; --------dmc sync lookup--------

    ; Lookup table for DMC initial sync.
    include "dmc_sync_table.asm"

    ; Dynamic sleep routine for 27-255 cycles, given a cycle count in A.
    ; Your game can reuse this as a generic sleep routine as well.
    ; (Conveniently, this code fits in the end of the page-aligned DMC lookup table.)
    include "vdelay_short.asm"

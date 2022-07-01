    include "bitfuncs.inc"

; NES registers

PPUCTRL equ $2000
PPUCTRL_NAMETABLE2000 equ %0
PPUCTRL_NAMETABLE2400 equ %1
PPUCTRL_NAMETABLE2800 equ %10
PPUCTRL_NAMETABLE2C00 equ %11
PPUCTRL_INCREMENTMODE equ %100
PPUCTRL_SPRITEPATTERN equ %1000
PPUCTRL_BACKGROUNDPATTERN equ %10000
PPUCTRL_SPRITE16PXMODE equ %100000
PPUCTRL_WRITEEXT equ %1000000
PPUCTRL_VBLANKNMI equ %10000000

PPUMASK equ $2001
PPUMASK_GREYSCALE equ %1
PPUMASK_BACKGROUNDLEFT8PX equ %10
PPUMASK_SPRITELEFT8PX equ %100
PPUMASK_BACKGROUNDENABLE equ %1000
PPUMASK_SPRITEENABLE equ %10000
PPUMASK_EMPHRED equ %100000
PPUMASK_EMPHGREEN equ %1000000
PPUMASK_EMPHBLUE equ %10000000

PPUSTATUS equ $2002
PPUSCROLL equ $2005
PPUADDR equ $2006
PPUDATA equ $2007
OAMDMA equ $4014

APUSTATUS equ $4015
APUSTATUS_ENABLE_DMC = %10000

DMCFREQ equ $4010
DMCFREQ_IRQ = %10000000
DMCFREQ_RATE428 = $0
DMCFREQ_RATE380 = $1
DMCFREQ_RATE340 = $2
DMCFREQ_RATE320 = $3
DMCFREQ_RATE286 = $4
DMCFREQ_RATE254 = $5
DMCFREQ_RATE226 = $6
DMCFREQ_RATE214 = $7
DMCFREQ_RATE190 = $8
DMCFREQ_RATE160 = $9
DMCFREQ_RATE142 = $a
DMCFREQ_RATE128 = $b
DMCFREQ_RATE106 = $c
DMCFREQ_RATE84 = $d
DMCFREQ_RATE72 = $e
DMCFREQ_RATE54 = $f
; Convenience settings
DMCFREQ_IRQ_RATE428 = DMCFREQ_IRQ | DMCFREQ_RATE428
DMCFREQ_IRQ_RATE380 = DMCFREQ_IRQ | DMCFREQ_RATE380
DMCFREQ_IRQ_RATE340 = DMCFREQ_IRQ | DMCFREQ_RATE340
DMCFREQ_IRQ_RATE320 = DMCFREQ_IRQ | DMCFREQ_RATE320
DMCFREQ_IRQ_RATE286 = DMCFREQ_IRQ | DMCFREQ_RATE286
DMCFREQ_IRQ_RATE254 = DMCFREQ_IRQ | DMCFREQ_RATE254
DMCFREQ_IRQ_RATE226 = DMCFREQ_IRQ | DMCFREQ_RATE226
DMCFREQ_IRQ_RATE214 = DMCFREQ_IRQ | DMCFREQ_RATE214
DMCFREQ_IRQ_RATE190 = DMCFREQ_IRQ | DMCFREQ_RATE190
DMCFREQ_IRQ_RATE160 = DMCFREQ_IRQ | DMCFREQ_RATE160
DMCFREQ_IRQ_RATE142 = DMCFREQ_IRQ | DMCFREQ_RATE142
DMCFREQ_IRQ_RATE128 = DMCFREQ_IRQ | DMCFREQ_RATE128
DMCFREQ_IRQ_RATE106 = DMCFREQ_IRQ | DMCFREQ_RATE106
DMCFREQ_IRQ_RATE84 = DMCFREQ_IRQ | DMCFREQ_RATE84
DMCFREQ_IRQ_RATE72 = DMCFREQ_IRQ | DMCFREQ_RATE72
DMCFREQ_IRQ_RATE54 = DMCFREQ_IRQ | DMCFREQ_RATE54

DMCADDR equ $4012
DMCLEN equ $4013

JOYPADLATCH equ $4016
JOYPADLATCH_FILLCONTROLLER equ %1
JOYPADP0READ equ $4016
JOYPADP1READ equ $4017
BUTTON_A      = 1 << 0
BUTTON_B      = 1 << 1
BUTTON_SELECT = 1 << 2
BUTTON_START  = 1 << 3
BUTTON_UP     = 1 << 4
BUTTON_DOWN   = 1 << 5
BUTTON_LEFT   = 1 << 6
BUTTON_RIGHT  = 1 << 7

VRAM_NAMETABLE0 equ $2000
VRAM_PALETTETABLE equ $3F00


; Macros

SETMEM_DMCADDRESS macro TARGETADDR
        if (TARGETADDR # 64) <> 0
            error "Address must be divisible by 64"
        endif
        if ~~(TARGETADDR >= $c000)
            error "Address must be >= $c000"
        endif
        lda #(TARGETADDR - $c000) / 64
        sta DMCADDR
    endm


JUMP_SLIDE macro CYCLES
        if CYCLES # 2 == 1
            error "Need a cycle count divisible by 2."
        endif
        ; jump slide
        rept (CYCLES / 2) - 2
            cmp #$C9
        endm
        bit $EA
    endm

SLEEP macro ARGCYCLES
        if ~~((ARGCYCLES # 1) == 0)
            error "Cycle must be even"
        endif
        if ARGCYCLES < 10
            rept ARGCYCLES / 2
                nop
            endm
        elseif ARGCYCLES > 138
            error "Cycles count cannot exceed 138"
        else
            jsr sleep_routine - ((ARGCYCLES - 10) / 2)
        endif
    endm



; Game variables

    org $0

zp_irq_jmp byt ?
zp_irq_lo byt ?
zp_irq_hi byt ?

zp_temp_a byt ?
zp_temp_y byt ?
zp_temp_x byt ?
zp_frame_index byt ?

zp_joypad_p0 byt ?
zp_joypad_p1 byt ?

zp_even_frame byt ?


; Game constants

DMC_SAMPLE_ADDR = $ffc0

DEFAULT_PPUMASK = PPUMASK_BACKGROUNDENABLE | PPUMASK_SPRITEENABLE | PPUMASK_BACKGROUNDLEFT8PX | PPUMASK_SPRITELEFT8PX
DEFAULT_PPUCTRL = PPUCTRL_NAMETABLE2000 | PPUCTRL_SPRITEPATTERN | PPUCTRL_SPRITE16PXMODE | PPUCTRL_BACKGROUNDPATTERN


; PRG start

    org $8000

reset:
        ; Disable interrupts.
        sei
        ; Reset all the flags and registers.
        lda #0
        sta PPUCTRL
        sta PPUMASK
        sta APUSTATUS
        lda #$40
        sta JOYPADP1READ
        cld
        ldx #$ff
        txs

        ; Wait for PPU
        ldx #3
    -:
        bit PPUSTATUS
        bpl -
        dex
        bne -

    .clear_internal_ram:
        ; Clear out console RAM
        lda #0
        ldx #0
    -:
        sta $0000,x
        sta $0100,x
        sta $0200,x
        sta $0300,x
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -

    .setup_ppu:
        ; Trigger OAM DMA. This has the side effect of aligning the APU and CPU on an
        ; even cycle. Though this feature is not used in this demo.
        lda #$07
        sta OAMDMA

        ; Set PPU control registers.
        lda #DEFAULT_PPUCTRL
        sta PPUCTRL

        ; Load palette table into palette VRAM.
        lda #hi(VRAM_PALETTETABLE)
        sta PPUADDR
        ldx #lo(VRAM_PALETTETABLE)
        stx PPUADDR
    -:
        lda table_palette,X
        sta PPUDATA
        inx
        cpx #$20
        bcc -

    .setup_nametable:
        ; Update all of nametable $2000 in a loop.
        lda #hi(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #$04
        ldx #(960 / 8)
    -:
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        sta PPUDATA
        dex
        bne -

        ; Update the left of the nametable with triangles.
        ; Do so using the 32-tile increment mode.
        lda #DEFAULT_PPUCTRL | PPUCTRL_INCREMENTMODE
        sta PPUCTRL
        lda #hi(VRAM_NAMETABLE0 + $e0)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + $e0)
        sta PPUADDR
        lda #$08
        ldx #16
    -:
        sta PPUDATA
        dex
        bne -
        lda #DEFAULT_PPUCTRL
        sta PPUCTRL

        ; Set some specific tiles in nametable $2000.
        lda #hi(VRAM_NAMETABLE0 + (32 * 4) + 4)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 4) + 4)
        sta PPUADDR
        lda #'P'
        sta PPUDATA
        lda #'R'
        sta PPUDATA
        lda #'E'
        sta PPUDATA
        lda #'S'
        sta PPUDATA
        lda #'S'
        sta PPUDATA
        lda #' '
        sta PPUDATA
        lda #'A'
        sta PPUDATA

        ; Set some specific tiles in nametable $2000.
        lda #hi(VRAM_NAMETABLE0 + (32 * 4))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 4))
        sta PPUADDR
        lda #5
        sta PPUDATA
        lda #6
        sta PPUDATA
        lda #7
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 5))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 5))
        sta PPUADDR
        lda #5+16
        sta PPUDATA
        lda #6+16
        sta PPUDATA
        lda #7+16
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 6))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 6))
        sta PPUADDR
        lda #5+32
        sta PPUDATA
        lda #6+32
        sta PPUDATA
        lda #7+32
        sta PPUDATA

        ; Set some specific tiles in nametable $2000.
        lda #hi(VRAM_NAMETABLE0 + (32 * 55))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 55))
        sta PPUADDR
        lda #5
        sta PPUDATA
        lda #6
        sta PPUDATA
        lda #7
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 56))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 56))
        sta PPUADDR
        lda #5+16
        sta PPUDATA
        lda #6+16
        sta PPUDATA
        lda #7+16
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 57))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 57))
        sta PPUADDR
        lda #5+32
        sta PPUDATA
        lda #6+32
        sta PPUDATA
        lda #7+32
        sta PPUDATA

        ; The vblank flag is in an unknown state after reset,
        ; so we perforrm two waits for vertical blank to make sure that the
        ; PPU has stabilized.
        bit PPUSTATUS
    -:
        bit PPUSTATUS
        bpl -

        ; Setup scroll registers.
        lda #$00
        sta PPUSCROLL
        lda #$00
        sta PPUSCROLL
        ; Setup PPUMASK.
        lda #DEFAULT_PPUMASK
        sta PPUMASK

        ; Wait for the user to press the A button.
    .button_a_wait:
        jsr routine_read_joypad
        lda zp_joypad_p0
        and #BUTTON_A
        beq .button_a_wait

        ; Begin DMC timer synchronization.
    .sync_dmc:
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
        lda #hi(main_loop)
        pha
        lda #lo(main_loop)
        pha
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


main_loop:
        ; Repeating cycle of opcodes on main thread,
        ; with some 7-cycle instructions to help
        ; demonstrate IRQ jitter.
        ldx #0
    .loop_end:
        inc $0100,X
        bne .loop_end
        inc $0101,X
        bne .loop_end
        jmp .loop_end


; --------ppu palette--------

; PPU Palette table
table_palette:
        ; Background
        byt $0f, $21, $0d, $8c
        byt $0f, $21, $14, $38
        byt $0f, $21, $14, $38 
        byt $0f, $21, $14, $0f
        ; Sprites
        byt $0f, $21, $11, $31
        byt $0f, $21, $11, $31
        byt $0f, $21, $11, $31
        byt $0f, $21, $11, $31


; --------joypad routines--------

; Also see https://www.nesdev.org/wiki/Controller_reading_code
routine_read_joypad:
        ; Start controller read.
        lda #JOYPADLATCH_FILLCONTROLLER
        sta JOYPADLATCH

        ; $80 is loaded into the result first.
        ; Once eight bits are shifted in, last bit will be shifted out, terminating the loop.
        lda #%10000000
        sta zp_joypad_p0
        sta zp_joypad_p1

        ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
        lda #$00
        sta JOYPADLATCH
    -:
        ; Read the latch for P0. Move bit D0 -> Carry, then into the top bit of P0.
        lda JOYPADP0READ
        lsr a
        ror zp_joypad_p0

        ; Read the latch for P1. Move bit D0 -> Carry, then into the top bit of P1.
        lda JOYPADP1READ
        lsr a
        ror zp_joypad_p1

        ; Once we've read all 8 bits (ZP value shifts off top bit), exit the loop.
        bcc -

        rts


routine_update_frame_from_joypad:
        ; Calculate frame adjustment based off joypad values.
        lda table_frame_offset,y
        tay
        ; If we have a positive offset, use it. Otherwise, evaluate joypad.
        bpl +

        ; Start checking joypad for P0.
        lda zp_joypad_p0
        ; BUTTON_RIGHT
        ldy #$00
        asl a
        bcs +
        ; BUTTON_LEFT
        ldy #$01
        asl a
        bcs +
        ; BUTTON_DOWN
        ldy #$04
        asl a
        bcs +
        ; BUTTON_UP
        ldy #$05
        asl a
        bcs +

        ; No directional buttons pressed, so restart the frame loop at x = 3.
        ldy #$03
    +:
        sty zp_frame_index

        rts


; ------ irq rows -------

    include "irq_routines.asm"


; --------DMC frequencies--------

    MACEXP_DFT  nomacro, noif

word macro reg
    if      "REG"<>""
        byt    lo(reg), hi(reg)
        shift
        word ALLARGS
    endif
    endm


; Frequencies to use for each frame index.

        align 256

IRQ_CALL macro ADDRESS, NEXTREG
        word ADDRESS
        if "NEXTREG" <> ""
            shift
            byt ALLARGS
        endif
    endm

        align 256
table_irq:
        include "irq_table.asm"


; --------long vblank routine--------

        include "sync_vbl_long.asm"


; --------sub start--------

        rept 128
            nop
        endm
sleep_routine:
        rts


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


    ; dummy nmi interrupt, unused by program
nmi:
        rti


; --------dmc sync lookup--------

    include "dmc_sync.asm"


; --------variable delay routine--------

    include "vdelay_short.asm"


; --------APU sample block--------

    org DMC_SAMPLE_ADDR

dmc_sample:
        byt $00, $01, $02, $03, $04, $05, $06, $07
        byt $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        byt $FF


; --------Reset Vectors--------

    org $FFFA

vectors:
        ; nmi
        byt lo(nmi), hi(nmi)
        ; reset
        byt lo(reset), hi(reset)
        ; irq
        byt lo(zp_irq_jmp), hi(zp_irq_jmp)

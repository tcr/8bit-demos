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

    MACEXP_DFT  nomacro, noif

WORD macro reg
    if      "REG"<>""
        byt    lo(reg), hi(reg)
        shift
        WORD ALLARGS
    endif
    endm


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


    ; SLEEP macro calls into sleep_routine method (with a nop slide before it to adjust timing)
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


    ; Simplify writing to nametable
PRINT_STRING macro XPOS, YPOS, STRING
        lda #(((YPOS * 32) + XPOS) / 256 + $20)
        sta PPUADDR
        lda #(((YPOS * 32) + XPOS) # 256)
        sta PPUADDR

I set 0
        while I < STRLEN(STRING)
            lda #CHARFROMSTR(STRING, I)
            sta PPUDATA      
I set I + 1
        endm
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

zp_irq_align_sequence byt ?


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
        ; Clear OAM DMA.
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
        lda #hi(VRAM_NAMETABLE0 + $e2)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + $e2)
        sta PPUADDR
        lda #$08
        ldx #16
    -:
        sta PPUDATA
        dex
        bne -
        lda #hi(VRAM_NAMETABLE0 + $e9)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + $e9)
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
        PRINT_STRING 4, 5, "PRESS A TO SYNC"

        ; Set some specific tiles in nametable $2000.
        lda #hi(VRAM_NAMETABLE0 + (32 * 4))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 4))
        sta PPUADDR
        lda #9
        sta PPUDATA
        lda #10
        sta PPUDATA
        lda #11
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 5))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 5))
        sta PPUADDR
        lda #9+16
        sta PPUDATA
        lda #10+16
        sta PPUDATA
        lda #11+16
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0 + (32 * 6))
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + (32 * 6))
        sta PPUADDR
        lda #9+32
        sta PPUDATA
        lda #10+32
        sta PPUDATA
        lda #11+32
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
        jsr read_joypad
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
        jmp nop_chain


    ; By the time this is called, the IRQ chain has now been initialized, so you can safely
    ; perform your game logic.
main_loop:
        ; Looping cycle of dummy opcodes on main thread,
        ; with some 7-cycle instructions to help demonstrate IRQ jitter.
        ldx #0
    .loop_end:
        inc $0100,X
        bne .loop_end
        inc $0101,X
        bne .loop_end
        jmp .loop_end


; -------vblank routine----------

    ; This "VBLANK" routine is not called from NMI, but from the IRQ routine that is
    ; synced to start at VBLANK (start of scanline 241)
vblank_from_irq:
        ; Update instructions
        lda PPUSTATUS
        PRINT_STRING 4, 5, "PRESS B TO RESET"
        ; Reset PPUADDR
        lda #0
        sta PPUADDR
        sta PPUADDR

        ; Read joypad and respond to some keys.
        jsr read_joypad
        lda zp_joypad_p0
        and #BUTTON_LEFT
        bne .button_left
        lda zp_joypad_p0
        and #BUTTON_RIGHT
        bne .button_right
        lda zp_joypad_p0
        and #BUTTON_B
        bne .button_b_reset
        rts

        ; Pressing left or right adjusts the "align" frame, just for debugging.
    .button_left:
        lda #lo(irq_routines_table_align_0)
        sta zp_irq_align_sequence
        rts

    .button_right:
        lda #lo(irq_routines_table_align_1)
        sta zp_irq_align_sequence
        rts
    
        ; Pressing button B resets the demo.
    .button_b_reset:
        ; Because this was called from a routine inside an interrupt, we have five stack values
        ; we need to clear.
        pla
        pla
        pla
        pla
        pla
        ; Add the reset vector to the stack as our return value.
        lda #hi(reset)
        pha
        lda #lo(reset)
        pha
        php
        ; We also acknowledge and disable DMC IRQ so it won't keep firing.
        lda #0
        sta APUSTATUS
        ; Return from IRQ, directly into the reset logic.
        rti

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

    include "joypad.asm"


; --------IRQ syncing code--------

    include "sync_vbl_long.asm"

    include "irq_initial_sync.asm"


; ------ game-specific IRQ routines -------

    include "irq_routines.asm"

    include "irq_routines_table.asm"


; --------sub start--------

        rept 128
            nop
        endm
sleep_routine:
        rts


; --------DMC sample block--------

    org DMC_SAMPLE_ADDR

    ; Use a 17-byte $00 sample in case IRQ logic ever needs it
    ; $00 will output nothing in the sound channel
dmc_sample:
        rept 17
            byt $00
        endm


; --------Reset Vectors--------

    ; Dummy nmi interrupt. NMI is never enabled by the program.
    org $fff0
nmi:
        rti


    ; Vectors table
    org $fffa
vectors:
        ; nmi
        byt lo(nmi), hi(nmi)
        ; reset
        byt lo(reset), hi(reset)
        ; irq trampoline
        byt lo(zp_irq_jmp), hi(zp_irq_jmp)

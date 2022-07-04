; PRG ROM for stableframe demo

    include "bitfuncs.inc"

    include "nes.s"

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

zp_joypad_p0 byt ?
zp_joypad_p1 byt ?

zp_irq_align_sequence byt ?


; Game constants

DMC_SAMPLE_ADDR = $ffc0

DEFAULT_PPUMASK = PPUMASK_BACKGROUNDENABLE | PPUMASK_SPRITEENABLE | PPUMASK_BACKGROUNDLEFT8PX | PPUMASK_SPRITELEFT8PX
DEFAULT_PPUCTRL = PPUCTRL_NAMETABLE2000 | PPUCTRL_SPRITEPATTERN | PPUCTRL_SPRITE16PXMODE | PPUCTRL_BACKGROUNDPATTERN


; ----------prg start-----------

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

        ; The vblank flag is in an unknown state after reset,
        ; so we perforrm two waits for vertical blank to make sure that the
        ; PPU has stabilized.
        ldx #3
    -:
        bit PPUSTATUS
        bpl -
        dex
        bne -

; pre_sync:
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

        ; Set upper icon.
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

        ; Set lower icon.
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


        ; Update the left of the nametable with triangles.
        ; Do so using the 32-tile increment mode.
        lda #DEFAULT_PPUCTRL | PPUCTRL_INCREMENTMODE
        sta PPUCTRL
        lda #hi(VRAM_NAMETABLE0 + $e1)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + $e1)
        sta PPUADDR
        lda #$08
        ldx #16
    -:
        sta PPUDATA
        dex
        bne -
        lda #hi(VRAM_NAMETABLE0 + $e8)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0 + $e8)
        sta PPUADDR
        lda #$08
        ldx #16
    -:
        sta PPUDATA
        dex
        bne -
        lda #DEFAULT_PPUCTRL
        sta PPUCTRL

pre_sync:
        ; Sync with VBLANK before writing to PPU.
    -:
        bit PPUSTATUS
        bpl -

        ; Set some on-screen instructions.
        PRINT_STRING 4, 5, "PRESS A TO SYNC  "

        ; Clear PPUADDR and PPUSCROLL.
        lda #0
        sta PPUADDR
        sta PPUSCROLL
        sta PPUSCROLL

        ; Reset PPUCTRL.
        lda #DEFAULT_PPUCTRL
        sta PPUCTRL
        ; Setup PPUMASK.
        lda #DEFAULT_PPUMASK
        sta PPUMASK

        ; Wait for the user to press the A button.
    .button_a_wait:
        jsr read_joypad
        lda zp_joypad_p0
        and #BUTTON_A
        beq .button_a_wait
    
        ; Begin DMC timer synchronization. Once complete we continue into main_loop.
    .dmc_sync:
        jsr initial_dmc_sync

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


; -------"vblank" routine----------

    ; This "VBLANK" routine is not called from NMI, but from the IRQ routine that is
    ; synced to start at VBLANK (start of scanline 241)
vblank_from_irq:
        ; Clear PPU latch.
        lda PPUSTATUS
        ; Update on-screen instructions.
        PRINT_STRING 4, 5, "PRESS B TO DESYNC"
        ; Reset PPUADDR after updating PPU.
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
        ; This method was called from a routine inside an interrupt, and we don't know what main
        ; loop code we were executing before this. So reset the stack now and push our return
        ; values onto it.
        ldx #$ff
        txs

        ; Clear out stack.
        lda #0
        ldx #$00
    -:
        sta $0100,x
        inx
        bne -

        ; Add the reset vector to the stack as our return value.
        lda #hi(pre_sync)
        pha
        lda #lo(pre_sync)
        pha
        lda #$04 ; processor state to enable interruptss
        pha
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


; --------DMC syncing code--------

    include "sync_vbl_long.asm"

    include "dmc_sync.asm"


; --------IRQ routines------------

    include "irq_routines.asm"

    include "irq_routines_table.asm"


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

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
DMCFREQ_RATE256 = $5
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
DMCFREQ_IRQ_RATE256 = DMCFREQ_IRQ | DMCFREQ_RATE256
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
BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0

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



; Game constants

DMC_SAMPLE_ADDR = $ffc0

; Unused/unknown
zp_00 equ $00
zp_01 equ $01
zp_02 equ $02
zp_03 equ $03
zp_04 equ $04

zp_irq_jmp equ $05
zp_irq_lo equ $06
zp_irq_hi equ $07

zp_temp_a equ $08
zp_ equ $09
zp_temp_x equ $0a
zp_0b equ $0b
zp_0c equ $0c
zp_frame_index equ $0d
zp_0e equ $0e
zp_0f equ $0f

zp_joypad_p0 equ $10
zp_joypad_p1 equ $11

zp_irq_temp_a equ $12
zp_irq_temp_y equ $13
zp_irq_pos_y equ $14

zp_irq_ptr_lo equ $15
zp_irq_ptr_hi equ $16


PPUMASK_COMMON = PPUMASK_BACKGROUNDENABLE | PPUMASK_SPRITEENABLE


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
        sta DMCFREQ
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
        lda #PPUCTRL_NAMETABLE2800 | PPUCTRL_SPRITEPATTERN | PPUCTRL_SPRITE16PXMODE
        sta PPUCTRL

        ; Clear out nametable $2000 in a loop.
        lda #hi(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #$00
        ldx #$00
        ldy #$08
    -:
        sta PPUDATA
        stx PPUDATA
        sta PPUDATA
        stx PPUDATA
        stx PPUDATA
        stx PPUDATA
        stx PPUDATA
        sta PPUDATA
        inx
        bne -

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

    .draw_specific_tiles:
        ; Set some specific tiles in nametable $2000.
        lda #hi(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0)
        sta PPUADDR
        lda #5
        sta PPUDATA
        lda #6
        sta PPUDATA
        lda #7
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0+32)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0+32)
        sta PPUADDR
        lda #5+16
        sta PPUDATA
        lda #6+16
        sta PPUDATA
        lda #7+16
        sta PPUDATA

        lda #hi(VRAM_NAMETABLE0+64)
        sta PPUADDR
        lda #lo(VRAM_NAMETABLE0+64)
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
        lda #$F8
        sta PPUSCROLL
        lda #$00
        sta PPUSCROLL

        lda #PPUMASK_COMMON
        sta PPUMASK

        ; Unused write (???)
        lda #$40
        sta zp_00

        ; Wait a long time (???)
        ldx #10
        ldy #0
    -:
        dey
        bne -
        dex
        bne -

        ; Switch backgrounnd nametable to $2400.
        lda #PPUCTRL_NAMETABLE2400 | PPUCTRL_SPRITEPATTERN | PPUCTRL_SPRITE16PXMODE | PPUCTRL_BACKGROUNDPATTERN
        sta PPUCTRL

    .setup_dmc:
        lda #0
        sta zp_irq_pos_y

        ; Store IRQ trampoline "jmp (table_irq_0)" into ZP.
        lda #$6C
        sta zp_irq_jmp
        lda #lo(table_irq_0)
        sta zp_irq_lo
        lda #hi(table_irq_0)
        sta zp_irq_hi

        ; Setup initial DMC.
        SETMEM_DMCADDRESS DMC_SAMPLE_ADDR
        lda #0
        sta DMCLEN
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; Due to a hardware quirk, we need to write the sample length three times in a row
        ; so as not to trigger an immediate IRQ. See https://www.nesdev.org/wiki/APU_DMC
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        sta APUSTATUS
        sta APUSTATUS
        ; Re-enable interrupts.
        cli

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


; --------data block--------

; PPU Palette table
table_palette:
        ; Background
        byt $22, $21, $14, $8c
        byt $22, $21, $14, $38
        byt $22, $21, $14, $38 
        byt $22, $21, $14, $38
        ; Sprites
        byt $22, $21, $11, $31
        byt $22, $21, $11, $31
        byt $22, $21, $11, $31
        byt $22, $21, $11, $31


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
        lda table_frame_offset,x
        tax
        ; If we have a positive offset, use it. Otherwise, evaluate joypad.
        bpl +

        ; Start checking joypad for P0.
        lda zp_joypad_p0
        ; BUTTON_RIGHT
        ldx #$01
        asl a
        bcs +
        ; BUTTON_LEFT
        ldx #$00
        asl a
        bcs +
        ; BUTTON_DOWN
        ldx #$04
        asl a
        bcs +
        ; BUTTON_UP
        ldx #$05
        asl a
        bcs +

        ; No directional buttons pressed, so restart the frame loop at x = 3.
        ldx #$03
    +:
        stx zp_frame_index

        rts


; ------ irq rows -------

IRQ_ADVANCE = 4

    ; Expect to be called with DMC P0 = 54.
    ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
    ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_row_medium:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        ; [= 3]

        ; [+ 6] Update DMC with P1 rate.
        lda #DMCFREQ_IRQ_RATE72
        sta DMCFREQ
        ; [= 9]

        ; [+10] Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        lda #PPUMASK_COMMON | PPUMASK_EMPHRED
        sta PPUMASK
        ; [=19]

        ; [+5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=24]

        ; [+10] Advance IRQ one jump cycle.
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo
        ; [=34]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=63]

        ; Restore registers and return.
        lda zp_temp_a
        rti

    ; Expect to be called with DMC P0 = 54.
    ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
    ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_row_dark:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        ; [= 3]

        ; [+ 6] Update DMC with P1 rate.
        lda #DMCFREQ_IRQ_RATE72
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

        ; [+10] Advance IRQ one jump cycle.
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo
        ; [=34]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=63]

        ; Restore registers and return.
        lda zp_temp_a
        rti


    ; Expect to be called with DMC P0 = 54.
    ; (IRQ can be called up to 22 CPU cycles late according to Mesen.)
    ; We change the DMC rate to P1 immediately, and at least P0 cycles to change to P2.
        JUMP_SLIDE 8
irq_row_light:
        ; [+ 3] Preserve registers.
        sta zp_temp_a
        ; [= 3]

        ; [+ 6] Update DMC with P1 rate.
        lda #DMCFREQ_IRQ_RATE84
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

        ; [+10] Advance IRQ one jump cycle.
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo
        ; [=34]

        ; [+24] Sleep.
        ; SLEEP 24
        ; [+ 5] After 54 (P0) cycles, update DMC with P2 rate.
        lda #DMCFREQ_IRQ_RATE54
        sta DMCFREQ
        ; [=63]

        ; Restore registers and return.
        lda zp_temp_a
        rti


; -------end of frame irq---------

routine_frame_blank_start:
        ; Preserve registers.
        sta zp_temp_a
        stx zp_temp_x

        ; Update DMC P1 and P2 with lookup0.
        ldx zp_frame_index
        lda table_frequencies_0,x
        sta DMCFREQ

        ; Change PPUMASK to greyscale during the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_GREYSCALE
        sta PPUMASK
        
        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        
        ; Advance IRQ trampoline
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo
        
        ; Restore registers and return.
        ldx zp_temp_x
        lda zp_temp_a
        rti


routine_frame_blank_split_1:
        ; Preserve registers.
        sta zp_temp_a
        stx zp_temp_x

        ; Update DMC P1 and P2 with lookup1.
        ldx zp_frame_index
        lda table_frequencies_1,x
        sta DMCFREQ

        ; Do any color updates if needed.

        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo

        ; Restore registers and return.
        ldx zp_temp_x
        lda zp_temp_a
        rti


routine_frame_blank_split_2:
        ; Preserve registers.
        sta zp_temp_a
        stx zp_temp_x

        ; Update DMC P1 and P2 with lookup2.
        ldx zp_frame_index
        lda table_frequencies_2,x
        sta DMCFREQ

        ; Do any color updates if needed.

        ; Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        lda zp_irq_lo
        clc
        adc #IRQ_ADVANCE
        sta zp_irq_lo

        ; Read joypads (CPU cycles in this subroutine are not bounded).
        jsr routine_read_joypad

        ; Restore registers and return.
        ldx zp_temp_x
        lda zp_temp_a
        rti


routine_frame_end:
        ; DMC P0=lookup2

        ; [+ 6] Preserve registers.
        sta zp_temp_a
        stx zp_temp_x
        ; [= 6]

        ; [+11] Update DMC P1 with lookup3.
        ldx zp_frame_index
        lda table_frequencies_3,x
        sta DMCFREQ
        ; [=17]

        ; [+ 5] Restore PPUMASK to start showing colors after the blanking period.
        lda #PPUMASK_COMMON | PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN
        sta PPUMASK
        ; [=22]

        ; [+ 5] Acknowledge IRQ.
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        ; [=34]

        ; [+ 5] Reset IRQ trampoline
        lda #lo(table_irq_0)
        sta zp_irq_lo
        ; [=29]

        ; [+42]
        SLEEP 82
        ; [=76]

        ; [+ 8] Update DMC P2 with lookup4.
        lda table_frequencies_4,x
        sta DMCFREQ
        ; [=84]

        jsr routine_update_frame_from_joypad

        ; Restore registers and return.
        ldx zp_temp_x
        lda zp_temp_a
        rti


; --------DMC frequencies--------

d8 macro
        byt ALLARGS
    endm

d16 macro reg
    if      "REG"<>""
        byt    lo(reg), hi(reg)
        shift
        d16 ALLARGS
    endif
    endm

d16hi macro reg
    if      "REG"<>""
        byt    hi(reg)
        shift
        d16hi ALLARGS
    endif
    endm

d16lo macro reg
    if      "REG"<>""
        byt    lo(reg)
        shift
        d16lo ALLARGS
    endif
    endm

DPAIR set ""

d16pair macro
        if (DPAIR<>"hi") && (DPAIR<>"lo")
            error "Expected dpair_hi or dpair_lo macro to be used, got \{DPAIR}"
        elseif DPAIR=="hi"
            d16hi ALLARGS
        else
            d16lo ALLARGS
        endif
    endm

d8pair macro reglo, reghi
        if (DPAIR<>"hi") && (DPAIR<>"lo")
            error "Expected dpair_hi or dpair_lo macro to be used, got \{DPAIR}"
        elseif DPAIR=="hi"
            d8 reglo
            shift
            shift
            d8pair ALLARGS
        else
            d8 reghi
            shift
            shift
            d8pair ALLARGS
        endif
    endm

dpair_hi macro
DPAIR set "hi"
    endm

dpair_lo macro
DPAIR set "lo"
    endm

dpair_end macro
DPAIR set ""
    endm

; Frequencies to use for each frame index.

        align 256

IRQ_STEP macro ADDRESS
        align 4
        d16 ADDRESS
    endm


        align 256
        dpair_lo
table_irq_0:
table_irq_lo:
        include "irq_table.asm"
        dpair_end

        align 256
        dpair_hi
table_irq_hi:
        include "irq_table.asm"
        dpair_end


; table_irq_end:
;         align 256
;         MACRO_IRQ_TABLE 1

        ; align 8
        ; d16 irq_row_light   - 4
        ; d8 DMCFREQ_IRQ_RATE84, DMCFREQ_IRQ_RATE54

        ; align 8
        ; d16 irq_row_dark   - 4
        ; d8 DMCFREQ_IRQ_RATE72, DMCFREQ_IRQ_RATE54

        ; align 8
        ; d16 routine_frame_blank_start
        ; d8 DMCFREQ_IRQ_RATE428, 0
        ; d8 0, PPUMASK_COMMON | PPUMASK_GREYSCALE
        ; d16 PPUMASK

        ; align 8
        ; d16 routine_frame_blank_split_1
        ; d8 DMCFREQ_IRQ_RATE214

        ; align 8
        ; d16 routine_frame_blank_split_2
        ; d8 DMCFREQ_IRQ_RATE54, 0
        ; d16 routine_read_joypad

        ; align 8
        ; d16 routine_frame_end
        ; d8 DMCFREQ_IRQ_RATE190, DMCFREQ_IRQ_RATE54
        ; d16 routine_update_frame_from_joypad


        align 256

; * 8
table_frequencies_0:
        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE380
        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE428

        byt DMCFREQ_IRQ_RATE428
        byt DMCFREQ_IRQ_RATE428

; * 8
table_frequencies_1:
        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE226
        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE214

        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE190

; * 8
table_frequencies_2:
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE106
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE72

        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE72

; * 1
table_frequencies_3:
        byt DMCFREQ_IRQ_RATE190
        byt DMCFREQ_IRQ_RATE72
        byt DMCFREQ_IRQ_RATE190
        byt DMCFREQ_IRQ_RATE54

        byt DMCFREQ_IRQ_RATE214
        byt DMCFREQ_IRQ_RATE160

; * 8
table_frequencies_4:
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54
        byt DMCFREQ_IRQ_RATE54

        byt DMCFREQ_IRQ_RATE72
        byt DMCFREQ_IRQ_RATE54

table_frame_offset:
        ; Frame loop 0-3, also
        ; 1: left, 2: right
        byt $FF, $00, $01, $02
        ; 4: down, 5: up
        byt $FF, $01


; --------irq routine--------

irq:
        sta zp_irq_temp_a
        sty zp_irq_temp_y

        ldy zp_irq_pos_y
        lda table_irq_lo,y
        sta zp_irq_ptr_lo
        lda table_irq_hi,y
        sta zp_irq_ptr_hi
        jmp (zp_irq_ptr_lo)



; --------sub start--------

        rept 128
            nop
        endm
sleep_routine:
        rts


; --------nmi--------

; In this setup, we do nothing with NMI and don't even enable it.
nmi:
        rti


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

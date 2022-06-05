    include "bitfuncs.inc"

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
zp_09 equ $09
zp_temp_x equ $0a
zp_0b equ $0b
zp_0c equ $0c
zp_frame_index equ $0d
zp_0e equ $0e
zp_0f equ $0f

zp_joypad_a equ $10
zp_joypad_b equ $11

PpuControl_2000 equ $2000

PPUMASK equ $2001
PPUMASK_GREYSCALE equ %1
PPUMASK_SHOWBG equ %1000
PPUMASK_SHOWSP equ %10000
PPUMASK_EMPHRED equ %100000
PPUMASK_EMPHGREEN equ %1000000
PPUMASK_EMPHBLUE equ %10000000

PpuStatus_2002 equ $2002
PpuScroll_2005 equ $2005
PpuAddr_2006 equ $2006
PpuData_2007 equ $2007
OAMDMA equ $4014

APUSTATUS equ $4015
APUSTATUS_ENABLE_DMC = %10000

DMCFREQ equ $4010
DMCFREQ_IRQ = %10000000
DMCFREQ_RATE428 = $0
DMCFREQ_RATE380 = $1
DMCFREQ_RATE72 = $e
; etc...

DMCADDR equ $4012
DMCLEN equ $4013

JOYPADLATCH equ $4016
JOYPADREAD equ $4017

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



; Game constants

DMC_SAMPLE_ADDR = $ffc0


; PRG start

    org $8000

reset:
        ; Clear all the flags
        sei
        lda #0
        sta PpuControl_2000
        sta PPUMASK
        sta APUSTATUS
        sta DMCFREQ
        lda #$40
        sta JOYPADREAD
        cld
        ldx #$ff
        txs

        ; Wait for PPU
        ldx #%00000011
    -:
        bit PpuStatus_2002
        bpl -
        dex
        bne -

        ; Clear out console RAM
        lda #$00
        ldx #$00
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

        ; Write out all zeroes to OAM.
        lda #$07
        sta OAMDMA

        lda #$2A
        sta PpuControl_2000
        lda #$20
        sta PpuAddr_2006
        lda #$00
        sta PpuAddr_2006

        lda #$00
        ldx #$00
        ldy #$08
    -:
        sta PpuData_2007
        stx PpuData_2007
        sta PpuData_2007
        stx PpuData_2007
        stx PpuData_2007
        stx PpuData_2007
        stx PpuData_2007
        sta PpuData_2007
        inx
        bne -

        lda #$20
        sta PpuAddr_2006
        lda #$00
        sta PpuAddr_2006
        lda #$FF
        sta PpuData_2007
        sta PpuData_2007

        jmp frame_loop

        
; ----------------

        JUMP_SLIDE 40
irq_row_dark:
        sta zp_temp_a
        ; Update DMC with P1 rate.
        lda #DMCFREQ_IRQ | DMCFREQ_RATE380
        sta DMCFREQ
        ; Now preserve X register as well.
        stx zp_temp_x

        ; Change PPUMASK twice in quick succession to see a visible artifact.
        lda #PPUMASK_GREYSCALE | PPUMASK_SHOWSP
        sta PPUMASK
        lda #PPUMASK_EMPHRED | PPUMASK_EMPHGREEN | PPUMASK_SHOWSP
        sta PPUMASK

        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ one jump cycle.
        lda zp_irq_lo
        clc
        adc #3
        sta zp_irq_lo

        jsr sleep_36_cycles

        ; Restore X register.
        ldx zp_temp_x
        ; Update DMC with P2 rate.
        lda #DMCFREQ_IRQ | DMCFREQ_RATE72
        sta DMCFREQ

        lda zp_temp_a
        rti


; ----------------

        JUMP_SLIDE 40
irq_row_light:
        sta zp_temp_a
        ; Update DMC with P1 rate.
        lda #DMCFREQ_IRQ | DMCFREQ_RATE428
        sta DMCFREQ
        ; Now preserve X register as well.
        stx zp_temp_x

        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ one jump cycle.
        lda zp_irq_lo
        clc
        adc #3
        sta zp_irq_lo

        nop
        nop
        nop
        nop

        lda #PPUMASK_GREYSCALE | PPUMASK_SHOWSP
        sta PPUMASK
        lda #PPUMASK_EMPHGREEN | PPUMASK_SHOWSP
        sta PPUMASK

        jsr sleep_36_cycles

        ; Restore X register.
        ldx zp_temp_x
        ; Update DMC with P2 rate.
        lda #DMCFREQ_IRQ | DMCFREQ_RATE72
        sta DMCFREQ

        lda zp_temp_a
        rti


; --------DMC frequencies--------

table_frequencies_0:
        byt $80, $80, $80, $80, $80, $80
table_frequencies_1:
        byt $87, $87, $87, $87, $87, $88
table_frequencies_2:
        byt $8F, $8E, $8F, $8F, $8F, $8E
table_frequencies_3:
        byt $86, $8D, $86, $86, $87, $89
table_frequencies_4:
        byt $8F, $8F, $8F, $8F, $8E, $8F

table_frame_offset:
        byt $FF, $00, $01, $02, $FF, $01


; ----------------

routine_8156:
        sta zp_temp_a
        stx zp_temp_x

        ldx zp_frame_index
        lda table_frequencies_0,x
        sta DMCFREQ

        lda #PPUMASK_GREYSCALE | PPUMASK_SHOWSP
        sta PPUMASK
        
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        
        ; Advance IRQ trampoline
        lda #lo(routine_irq_8175)
        sta zp_irq_lo
        
        ldx zp_temp_x
        lda zp_temp_a
        rti


; ----------------

routine_8175:
        sta zp_temp_a
        stx zp_temp_x

        ldx zp_frame_index
        lda table_frequencies_1,X
        sta DMCFREQ
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Advance IRQ trampoline
        lda #lo(routine_irq_818f)
        sta zp_irq_lo

        ldx zp_temp_x
        lda zp_temp_a

        rti


; ----------------

routine_818F:
        sta zp_temp_a
        stx zp_temp_x

        ldx zp_frame_index
        lda table_frequencies_2,X
        sta DMCFREQ
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Read joypads
        jsr routine_read_joypad

        ; Advance IRQ trampoline
        lda #lo(routine_irq_frame_end)
        sta zp_irq_lo

        ldx zp_temp_x
        lda zp_temp_a
        rti




; ----------------


routine_frame_end:
        sta zp_temp_a
        stx zp_temp_x

        ldx zp_frame_index
        lda table_frequencies_3,x
        sta DMCFREQ

        lda #PPUMASK_EMPHBLUE | PPUMASK_EMPHGREEN | PPUMASK_SHOWSP
        sta PPUMASK
        
        ; Useless load (???)
        lda #$86

        ; Reset IRQ trampoline
        lda #lo(routine_irq)
        sta zp_irq_lo

        jsr sleep_36_cycles

        lda table_frequencies_4,x
        sta DMCFREQ
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS

        ; Calculate frame adjustment based off joypad values.
        lda table_frame_offset,x
        tax
        bpl +
        lda zp_joypad_a
        ldx #$01
        asl a
        bcs +
        ldx #$00
        asl a
        bcs +
        ldx #$04
        asl a
        bcs +
        ldx #$05
        asl a
        bcs +
        ldx #$03
    +:
        stx zp_frame_index

        ldx zp_temp_x
        lda zp_temp_a
        rti


; --------nmi--------

nmi:
        rti




; --------unknown routine--------

routine_81F7:
        ; Unknown routine
        cli
        sta zp_01
        lda #$00
        sta zp_0F
        inc zp_04
        lda #$3F
        sta PpuAddr_2006
        lda #$01
        sta PpuAddr_2006
        lda zp_04
        lda #$01
        sta PpuData_2007
        lda zp_01
        rti


; --------sub start--------

routine_read_joypad:
        lda #$01
        sta JOYPADLATCH

        lda #$80
        sta zp_joypad_a
        sta zp_joypad_b

        lda #$00
        sta JOYPADLATCH
    -:
        lda JOYPADLATCH
        lsr a
        ror zp_joypad_a
        lda JOYPADREAD
        lsr a
        ror zp_joypad_b
        bcc -

        rts


; ----------------

frame_loop:
        ; Store "jmp $8300" into ZP.
        lda #$4C
        sta zp_irq_jmp
        lda #lo(routine_irq)
        sta zp_irq_lo
        lda #hi(routine_irq)
        sta zp_irq_hi

        ; Impossible write to APU sample block (???)
        ldx #$00
        lda dmc_sample,X
        sta dmc_sample,X

        ; Load palette table into palette VRAM.
        lda #$3F
        sta PpuAddr_2006
        ldx #$00
        stx PpuAddr_2006
    -:
        lda table_palette,X
        sta PpuData_2007
        inx
        cpx #$20
        bcc -

        ; The vblank flag is in an unknown state after reset,
        ; so we perforrm two waits for vertical blank to make sure that the
        ; PPU has stabilized.
        bit PpuStatus_2002
    -:
        bit PpuStatus_2002
        bpl -

        ; Setup scroll registers.
        lda #$F8
        sta PpuScroll_2005
        lda #$00
        sta PpuScroll_2005

        lda #PPUMASK_SHOWBG | PPUMASK_SHOWSP
        sta PPUMASK

        ; Unused write (???)
        lda #$40
        sta zp_00

        ; Wait a long time (???)
        ldx #$0A
        ldy #$00
    -:
        dey
        bne -
        dex
        bne -

        ; Useless write (???)
        ldx #$00
        stx zp_09

        ; Setup DMC.
        SETMEM_DMCADDRESS DMC_SAMPLE_ADDR
        lda #0
        sta DMCLEN
        lda #DMCFREQ_IRQ | DMCFREQ_RATE428
        sta DMCFREQ
        ; Due to a hardware quirk, we need to write the sample length three times in a row
        ; so as not to trigger an immediate IRQ. See https://www.nesdev.org/wiki/APU_DMC
        lda #APUSTATUS_ENABLE_DMC
        sta APUSTATUS
        sta APUSTATUS
        sta APUSTATUS

        ; Re-enable interrupts.
        cli

        lda #$29
        sta PpuControl_2000

        ; Impossible write (???)
        lda dmc_sample
        sta dmc_sample

        ; Repeating rough cycle counter on main thread.
        ldx #$00
    .loop_end:
        inc $0100,X
        bne .loop_end
        inc $0101,X
        bne .loop_end
        jmp .loop_end


; --------data block--------

; PPU Palette table
table_palette:
        byt $22, $21, $11, $31, $22, $21, $11, $31
        byt $22, $21, $11, $31, $22, $21, $11, $31
        byt $22, $21, $11, $31, $22, $21, $11, $31
        byt $22, $21, $11, $31, $22, $21, $11, $31



; ----------------

    ; IRQ trampoline routine must be aligned to a page boundary,
    ; because the zero page trampoline only ever rewrites the lower byte.
    align 256

routine_irq:
        jmp irq_row_light - 2
        jmp irq_row_dark - 3
        jmp irq_row_light - 4
        jmp irq_row_dark - 6
        jmp irq_row_light - 7
        jmp irq_row_dark - 8
        jmp irq_row_light - 10
        jmp irq_row_dark - 11
        jmp irq_row_light - 12
        jmp irq_row_dark - 14
        jmp irq_row_light - 15
        jmp irq_row_dark - 16
        jmp irq_row_light - 18
        jmp irq_row_dark - 19
        jmp irq_row_light - 20
        jmp irq_row_dark - 22
        jmp irq_row_light - 23
        jmp irq_row_dark - 24
        jmp irq_row_light - 26
        jmp irq_row_dark - 27
        jmp irq_row_light - 28
        jmp irq_row_dark - 30
        jmp irq_row_light - 31
        jmp irq_row_dark - 32
        jmp irq_row_light - 34
        jmp irq_row_dark - 35
        jmp routine_8156
routine_irq_8175:
        jmp routine_8175
routine_irq_818f:
        jmp routine_818F
routine_irq_frame_end:
        jmp routine_frame_end
        rts


; --------sub start--------

sleep_36_cycles:
        rept 16
            nop
        endm
        rts


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

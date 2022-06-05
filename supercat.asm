    include "bitfuncs.inc"

zp_00 equ $00
zp_01 equ $01
zp_02 equ $02
zp_03 equ $03
zp_04 equ $04
zp_05 equ $05
zp_06 equ $06
zp_07 equ $07
zp_08 equ $08
zp_09 equ $09
zp_0a equ $0a
zp_0b equ $0b
zp_0c equ $0c
zp_0d equ $0d
zp_0e equ $0e
zp_0f equ $0f
zp_10 equ $10
zp_11 equ $11

PpuControl_2000 equ $2000
PpuMask_2001 equ $2001
PpuStatus_2002 equ $2002
PpuScroll_2005 equ $2005
PpuAddr_2006 equ $2006
PpuData_2007 equ $2007
SpriteDma_4014 equ $4014
ApuStatus_4015 equ $4015
DmcFreq_4010 equ $4010
DmcAddress_4012 equ $4012
DmcLength_4013 equ $4013
Ctrl1_4016 equ $4016
Ctrl2_FrameCtr_4017 equ $4017


    org $8000

reset:
        ; Clear all the flags
        sei
        lda #$00
        sta PpuControl_2000
        sta PpuMask_2001
        sta ApuStatus_4015
        sta DmcFreq_4010
        lda #$40
        sta Ctrl2_FrameCtr_4017
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

        lda #$07
        sta SpriteDma_4014
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
        jmp routine_8233

        
routine_808A:
        ; jump slide
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        bit $EA
routine_808A_start:
        sta zp_08
        lda #$81
        sta DmcFreq_4010
        stx zp_0A
        lda #$11
        sta PpuMask_2001
        lda #$70
        sta PpuMask_2001
        lda #$10
        sta ApuStatus_4015
        lda zp_06
        clc
        adc #$03
        sta zp_06
        jsr routine_835B
        ldx zp_0A
        lda #$8E
        sta DmcFreq_4010
        lda zp_08
        rti

; ----------------
routine_80DC:
        ; jump slide
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        cmp #$C9
        bit $EA
routine_80DC_start:
        sta zp_08
        lda #$80
        sta DmcFreq_4010
        stx zp_0A
        lda #$10
        sta ApuStatus_4015
        lda zp_06
        clc
        adc #$03
        sta zp_06
        nop
        nop
        nop
        nop
        lda #$11
        sta PpuMask_2001
        lda #$50
        sta PpuMask_2001
        jsr routine_835B
        ldx zp_0A
        lda #$8E
        sta DmcFreq_4010
        lda zp_08
        rti

; --------data block--------

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
table_frequencies_5:
        byt $FF, $00, $01, $02, $FF, $01

; ----------------

routine_8156:
        sta zp_08
        stx zp_0A
        ldx zp_0D
        lda table_frequencies_0,x
        sta DmcFreq_4010
        lda #$11
        sta PpuMask_2001
        lda #$10
        sta ApuStatus_4015
        lda #$51
        sta zp_06
        ldx zp_0A
        lda zp_08
        rti


; ----------------

routine_8175:
        sta zp_08
        stx zp_0A
        ldx zp_0D
        lda table_frequencies_1,X
        sta DmcFreq_4010
        lda #$10
        sta ApuStatus_4015
        lda #$54
        sta zp_06
        ldx zp_0A
        lda zp_08
        rti


; ----------------

routine_818F:
        sta zp_08
        stx zp_0A
        ldx zp_0D
        lda table_frequencies_2,X
        sta DmcFreq_4010
        lda #$10
        sta ApuStatus_4015
        jsr routine_8214
        lda #$57
        sta zp_06
        ldx zp_0A
        lda zp_08
        rti




; ----------------


routine_81AC:
        sta zp_08
        stx zp_0A
        ldx zp_0D
        lda table_frequencies_3,x
        sta DmcFreq_4010
        lda #$D0
        sta PpuMask_2001
        lda #$86
        lda #$00
        sta zp_06
        jsr routine_835B
        lda table_frequencies_4,x
        sta DmcFreq_4010
        lda #$10
        sta ApuStatus_4015
        lda table_frequencies_5,x
        tax
        bpl +
        lda zp_10
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
        stx zp_0D
        ldx zp_0A
        lda zp_08
        rti


; --------nmi--------

nmi:
        rti




; ----------------

routine_81F7:
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

routine_8214:
        lda #$01
        sta Ctrl1_4016
        lda #$80
        sta zp_10
        sta zp_11
        lda #$00
        sta Ctrl1_4016
    -:
        lda Ctrl1_4016
        lsr a
        ror zp_10
        lda Ctrl2_FrameCtr_4017
        lsr a
        ror zp_11
        bcc -
        rts


; ----------------

routine_8233:
        ; store "jmp $8300" into ZP
        lda #$4C
        sta zp_05
        lda #lo(routine_8300)
        sta zp_06
        lda #hi(routine_8300)
        sta zp_07

        ldx #$00
        lda data_ffc0,X
        sta data_ffc0,X
        lda #$3F
        sta PpuAddr_2006
        ldx #$00
        stx PpuAddr_2006
    -:
        lda data_82BA,X
        sta PpuData_2007
        inx
        cpx #$20
        bcc -
        bit PpuStatus_2002
    -:
        bit PpuStatus_2002
        bpl -
        lda #$F8
        sta PpuScroll_2005
        lda #$00
        sta PpuScroll_2005
        lda #$18
        sta PpuMask_2001
        lda #$40
        sta zp_00
        ldx #$0A
        ldy #$00
    -:
        dey
        bne -
        dex
        bne -
        ldx #$00
        stx zp_09
        lda #$FF
        sta DmcAddress_4012
        lda #$00
        sta DmcLength_4013
        lda #$80
        sta DmcFreq_4010
        lda #$10
        sta ApuStatus_4015
        sta ApuStatus_4015
        sta ApuStatus_4015
        cli
        lda #$29
        sta PpuControl_2000
        lda data_ffc0
        sta data_ffc0
        ldx #$00
    -:
        inc $0100,X
        bne -
        inc $0101,X
        bne -
        jmp -


; --------data block--------

data_82BA:
        byt $01, $21, $11, $31, $01, $21, $11, $31
        byt $01, $21, $11, $31, $01, $21, $11, $31
        byt $01, $21, $11, $31, $01, $21, $11, $31
        byt $01, $21, $11, $31, $01, $21, $11, $31



; ----------------

    org $8300

routine_8300:
        jmp routine_80DC_start - 2
        jmp routine_80DC_start-($102-$ad)
        jmp routine_80DC_start-($102-$fe)
        jmp routine_80DC_start-($102-$aa)
        jmp routine_80DC_start-($102-$fb)
        jmp routine_80DC_start-($102-$a8)
        jmp routine_80DC_start-($102-$f8)
        jmp routine_80DC_start-($102-$a5)
        jmp routine_80DC_start-($102-$f6)
        jmp routine_80DC_start-($102-$a2)
        jmp routine_80DC_start-($102-$f3)
        jmp routine_80DC_start-($102-$a0)
        jmp routine_80DC_start-($102-$f0)
        jmp routine_80DC_start-($102-$9d)
        jmp routine_80DC_start-($102-$ee)
        jmp routine_80DC_start-($102-$9a)
        jmp routine_80DC_start-($102-$eb)
        jmp routine_80DC_start-($102-$98)
        jmp routine_80DC_start-($102-$e8)
        jmp routine_80DC_start-($102-$95)
        jmp routine_80DC_start-($102-$e6)
        jmp routine_80DC_start-($102-$92)
        jmp routine_80DC_start-($102-$e3)
        jmp routine_80DC_start-($102-$90)
        jmp routine_80DC_start-($102-$e0)
        jmp routine_80DC_start-($102-$8d)
        jmp routine_8156
        jmp routine_8175
        jmp routine_818F
        jmp routine_81AC
        rts


; --------sub start--------
routine_835B:
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rts

; ----------------

    org $FFC0

; --------mystery data block--------
data_ffc0:
        byt $00, $01, $02, $03, $04, $05, $06, $07
        byt $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
        byt $FF


; Reset vectors

    org $FFFA

    ; nmi
    byt lo(nmi), hi(nmi)
    ; reset
    byt lo(reset), hi(reset)
    ; irq
    byt lo(zp_05), hi(zp_05)

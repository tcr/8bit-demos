; vdelay (short version)
;
; Authors:
; - Eric Anderson
; - Joel Yliluoma
; - Brad Smith
; - Fiskbit
;
; Version 10
; https://github.com/bbbradsmith/6502vdelay

; delays for A cycles, minimum: 27 (includes jsr)
;   A = cycles to delay
;   A clobbered

VDELAY_MINIMUM = 27

    ; Code should be <32 bytes long
    align 32

vdelay:                             ; +6 = 6 (jsr)
        sec                         ; +2 = 8
        sbc #VDELAY_MINIMUM+4       ; +2 = 10
        bcc vdelay_low             ; +2 = 12
        ; 5-cycle coundown loop + 5 paths   +19 = 31 (end >= 31)
    -:
        sbc #5
        bcs -    ;  6 6 6 6 6  FB FC FD FE FF
        adc #3   ;  2 2 2 2 2  FE FF 00 01 02
        bcc +    ;  3 3 2 2 2  FE FF 00 01 02
        lsr      ;  - - 2 2 2  -- -- 00 00 01
        beq ++   ;  - - 3 3 2  -- -- 00 00 01
    +:  lsr      ;  2 2 - - 2  7F 7F -- -- 00
    +:  bcs +    ;  2 3 2 3 2  7F 7F 00 00 00
    +:  rts      ;  6 6 6 6 6

; 27-30 cycles handled separately
vdelay_low:                         ; +1 = 13 (bcc)
        adc #3                      ; +2 = 15
        bcc +    ;  3 2 2 2  <0 00 01 02
        beq +    ;  - 3 2 3  -- 00 01 02
        lsr      ;  - - 2 2  -- -- 00 01
    +:  bne *+2  ;  3 2 2 3  <0 00 00 01
        rts                         ; +6 = 27 (end < 31)

vdelay_end:
    if hi(vdelay_end-1) <> hi(vdelay)
        error  "\avdelay code must span just one page"
    endif

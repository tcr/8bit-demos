
    ; From blargg's full_pallete demo.
    ; Synchronizes precisely with PPU so that next frame will be long.
    ; Requires alignment because loops can't break over a page boundary.
    align 128
sync_vbl_long:
    -:
        ; Synchronize precisely to VBL. VBL occurs every 29780.67
        ; CPU clocks. Loop takes 27 clocks. Every 1103 iterations,
        ; the second LDA PPUSTATUS will read exactly 29781 clocks
        ; after a previous read. Thus, the loop will effectively
        ; read PPUSTATUS one PPU clock later each frame. It starts out
        ; with VBL beginning sometime after this read, so that
        ; eventually VBL will begin just before the PPUSTATUS read,
        ; and thus leave CPU exactly synchronized to VBL.
        bit PPUSTATUS
    -:	
        bit PPUSTATUS
        bpl -
    -:
        nop
        pha
        pla
        lda PPUSTATUS
        lda PPUSTATUS
        pha
        pla
        bpl -
        
        ; Now synchronize with short/long frames.
        
        ; Wait one frame with rendering off. This moves VBL time
        ; earlier by 1/3 CPU clock.
        
        ; Delay 29784 clocks
        ldx #24
        ldy #48
    -:	
        dey
        bne -
        dex
        bne -
        nop
        jmp * + 3 ; 3-cycle nop

        ; Render one frame. This moves VBL time earlier by either
        ; 1/3 or 2/3 CPU clock.
        lda #PPUMASK_BACKGROUNDENABLE | PPUMASK_BACKGROUNDLEFT8PX
        sta PPUMASK
        
        ; Delay 29752 clocks
        ldy #33
        ldx #24
    -:
        dey
        bne -
        nop
        dex
        bne -

        lda #0
        sta PPUMASK
        
        ; VBL flag will read set if rendered frame was short
        bit PPUSTATUS
        bmi .ret
        
        ; Rendered frame was long, so wait another (long)
        ; frame with rendering disabled. If rendering were enabled,
        ; this would be a short frame, so we end up in same state
        ; as if it were short frame above.
        
        ; Delay 29782 clocks
        ldy #39
        ldx #24
    -:	
        dey
        bne -
        nop
        dex
        bne -

    .ret:	; Now, if rendering is enabled, first frame will be long.

        ; NOTE: cut out delay 29782 - caller must manually position in frame

        rts

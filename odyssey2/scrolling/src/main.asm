	    cpu	8048
        
        include	"g7000.h"
        include	"codepage.h"
        include "bitfuncs.inc"

;-----------------
; Macros
;-----------------

; Turn on debugging colors
; DEBUG_COLORS equ 1

inline_external_vdc macro
        orl p1,#0bch                      ; set : !kbscan !vdcen !ramen  lumen
        anl p1,#0b7h                      ; clear : !vdcen copyen (?)
    endm

inline_external_ram macro
        orl p1,#0bch                      ; set : !kbscan !vdcen !ramen  lumen
        anl p1,#0afh                      ; clear : !ramen copyen
    endm

disable_vdc_foreground macro
        mov r0, #0a0h
        mov a,#8|128
        movx @r0,a
    endm

enable_vdc_foreground macro
        mov r0, #0a0h
        mov a,#8|32|128
        movx @r0,a
    endm

calc_char_2 function c, color, row, lo((c << 3) - 16 - (row*10))
calc_char_3 function c, color, row, col | getbit((c << 3) - 16 - (row*10), 8)

sleep_nop macro count
    rept count
        nop
    endm
    endm

sleep_loop macro reg, count
    if count < 5
        sleep_nop count
    else
        if ((count - 2) # 2) == 1
            nop
        endif
            mov reg,#((count - 2) / 2)
        -:
            djnz reg,-
    endif
    endm

TILE_WHITE      equ 00b
TILE_RED        equ 01b
TILE_GREEN      equ 10b
TILE_BLUE       equ 11b

read_extram_char macro x, y
        mov r0, #x + (y * 12)
        movx a, @r0
        rr a
        rr a
        rr a
        anl a, #00111111b
    endm

calc_extram_char function char, color, rotln((char << 2) | color, 8, 1)

write_extram_char macro char, x, y, color
        mov a, #rotln((char << 2) | color, 8, 1)
        mov r0, #x + (y * 12)
        movx @r0, a
    endm

write_extram_string macro str, x, y, color
        mov r0, #x + (y * 12)
.cnt set 0
        while .cnt < STRLEN(str)
            mov a, #rotln(lo(SUBSTR(str, .cnt, 1) << 2) | color, 8, 1)
            movx @r0, a
            inc r0
.cnt set .cnt + 1
        endm
    endm

assert macro expr
        if (~~val(expr))
            error expr
        endif
    endm

;-----------------
; Internal RAM values
;-----------------

; stuff values in top of stack
iram_vblank_bkp_a           equ 016h
iram_vblank_bkp_p1          equ 017h

iram_tile_compute_start     equ 020h
iram_tile_compute_end       equ 035h
iram_rewrite_start          equ 036h
iram_rewrite_end            equ 039h
iram_iram_index             equ 03ah
iram_keyboard               equ 03bh

; unused
iram_ictrl	    equ	03ch	    ; control irq
iram_random     equ 03dh
; 03d-03f are reserved from BIOS

; Flag values
ictrl_nextframe	            equ	080h	    ; if set, do the blinking
ictrl_lineirq	            equ	040h	    ; if set, do the lineirq
ictrl_gameover              equ 020h        ; if set, game over


TEXT_XPOS       equ 68h
TEXT_XPOS2      equ 28h

; Y offsets
TEXT_HI_YPOS                    equ 0x0c
TIMING_Y_START_OFFSET           equ -((TEXT_HI_YPOS / 2) + 10)
TIMING_SCANLINE_START           equ 0x100 - TEXT_HI_YPOS

; Timing constants for kernel
TIMING_CYCLES_TO_FIRST_ROW      equ 19
TIMING_AFTER_COMPUTE            equ 41
TIMING_VDC_WRITE_PADDING        equ 2


;-----------------
; Program start
;-----------------

        org	400h

        jmp	selectgame	; RESET
        jmp	irq		    ; interrupt
        jmp	timeirq		; timer
        jmp	myvsyncirq	; VSYNC-interrupt
        jmp	bank0_start	; after selectgame
        jmp	soundirq	; sound-interrupt

bank0_start:
        ; initialise variables
        mov	r0,#iram_ictrl
        mov	a,#0		; don't blink yet
        mov	@r0,a

        ; activate line irq
        mov	r0,#iram_ictrl
        mov	a,#ictrl_lineirq
        mov	@r0,a

        ; turn grid gfx off, the bios-routine is not safe
        ; to use in irq, it leaves with RB1 and EN I
        ; sel rb0
        ; mov	r0,#vdc_control
        ; movx	a,@r0
        ; ; mov	@r1,a		; store old vdc_control
        ; orl	a,#2 | 080h
        ; movx	@r0,a
        ; sel rb1

        ; Prepare for graphics initialization
        call	gfxoff


        ; Write some characters to display on-screen
write_extram_char_bytes:
        inline_external_ram
    
        mov r2, #112
    .write_to_external_ram:
        mov a, r2
        dec a
        mov r0, a
        mov a, r2
        dec a
        ; mov a, #55
        ; mov a, #' '
        anl a, #63
        rl a
        rl a
        orl a, #3     ; make it green
        rl a
        movx @r0, a
    .also_check_if_not_zero:
        djnz r2, .write_to_external_ram

        inline_external_vdc


init_grid:
        ; Initialize the vertical grid which serves as our full color background
        mov	r0, #vdc_gridv0+2
        mov	r2, #6
    .loopgv:
        mov	a, #10000001b		; get value
        movx @r0,a		    ; store in vdc
        inc	r0
        djnz r2, .loopgv

        ; left
        mov	r0, #vdc_gridv0+1
        mov	a, #11111111b		; get value
        movx @r0,a		    ; store in vdc

        ; right
        mov	r0, #vdc_gridv0+8
        mov	a, #11111111b		; get value
        movx @r0,a		    ; store in vdcv

init_text:
        ; Draw text
        ; call draw_helloworld
        call draw_helloworld

        ; Re-enable graphics
        ; call gfxon

        ; Start program
        jmp main


;------------------------------
; Quads and text
;------------------------------

draw_helloworld:
        mov     r0,#vdc_quad0       ; start char
        mov     r3,#TEXT_XPOS2       ; x-position
        mov     r4,#TEXT_HI_YPOS+20    ; y-position
        mov     r2,#0ch             ; length
        mov     r1,#hellostr & 0FFh ; the string to print
                                    ; must be in the same page
    .loop:
        mov     a,r1                ; get pointer
        movp    a,@a                ; get char
        mov     r5,a                ; into to right register
        inc     r1                  ; advance pointer
        mov     r6,#col_chr_white   ; colour
        call    printchar           ; print it
        djnz    r2,.loop             ; do it again

        mov     a,#TEXT_XPOS       ; x-position
        mov     r0,#vdc_quad2+12+1
        movx     @r0, a

    ifdef DEBUG_COLORS
        mov a, #1101b
    else
        mov a, #0000b
    endif
        mov r0, #vdc_quad2+8+3
        movx @r0,a
        mov r0, #vdc_quad2+12+3
        movx @r0,a

    ; ifdef DEBUG_COLORS
    ;     ; draw a white block at the top left using the unused quad
    ;     ; to show when VDC writing ends
    ;     ; (this won't work on a real console since it uses overlap)
    ;     mov     r0,#vdc_quad3+0       ; last quad char
    ;     mov     r3,#24                  ; x-position
    ;     mov     r4,#TEXT_HI_YPOS + 20    ; y-position
    ;     mov     r5,#47
    ;     call printchar
    ;     mov     r0,#vdc_quad3+4       ; last quad char
    ;     mov     r4,#TEXT_HI_YPOS + 20    ; y-position
    ;     mov     r5,#' '
    ;     call printchar
    ;     mov     r0,#vdc_quad3+8       ; last quad char
    ;     mov     r4,#TEXT_HI_YPOS + 20    ; y-position
    ;     mov     r5,#' '
    ;     call printchar
    ;     mov     r0,#vdc_quad3+12       ; last quad char
    ;     mov     r4,#TEXT_HI_YPOS + 20    ; y-position
    ;     mov     r5,#' '
    ;     call printchar
    ; endif

        mov     r0,#vdc_quad3+0
        mov     r3,#112
        mov     r4,#TEXT_HI_YPOS + (20 * 7)    ; y-position
        mov     r5,#'A'
        call printchar

        mov     r0,#vdc_quad3+8
        mov     r3,#112
        mov     r4,#TEXT_HI_YPOS + (20 * 7)    ; y-position
        mov     r5,#' '
        call printchar

        mov     r0,#vdc_quad3+12
        mov     r3,#112
        mov     r4,#TEXT_HI_YPOS + (20 * 7)    ; y-position
        mov     r5,#' '
        call printchar

        ; Position the twelve chars for columns 9 of 12
        mov r0, #vdc_char0
        mov r1, #TEXT_HI_YPOS
        mov r2, #6
    .column_9:
        mov r3, #112       ; x-position
        mov a, #20
        add a, r1
        mov r1, a
        mov r4, a
        mov r5, #47
        call printchar
        inc r3
        djnz r2, .column_9

        ; Position the twelve chars for columns 11 of 12
        mov r0, #vdc_char6
        mov r1, #TEXT_HI_YPOS
        mov r2, #6
    .column_11:
        mov r3, #128        ; x-position
        mov a, #20
        add a, r1
        mov r1, a
        mov r4, a
        mov r5, #47
        call printchar
        inc r3
        djnz r2, .column_11

        retr


hellostr
        db      "CAATHRCER1234"

;----------------------
; VSync IRQ
;----------------------

        align 16

; it starts the lineirq and does the blinking
myvsyncirq
        ; start lineirq, if needed
        mov	r0,#iram_ictrl	; control register
        mov	a,@r0
        cpl	a
        jb6	.skip_line_irq	; should we start line irq ?
        jmp .setup_frame

    .skip_line_irq:
        ; set grid+background color
        mov	r0,#vdc_color
        mov	a,#col_grd_violet | col_bck_blue
        movx	@r0,a

        jmp	vsyncirq	; thats all for now

    .setup_frame:
        mov	a,@r0
        mov	a,#TIMING_SCANLINE_START		; middle of the screen
        mov	t,a		    ; set # of lines to wait
        strt	cnt		; start line counting
        en	tcnti		; enable timer irq

        ; select base register set(?)
        sel	rb0

        ; set grid+background color
        mov	r0,#vdc_color
        mov	a,#col_grd_white | col_bck_black
        movx	@r0,a

        ; Clear sound registers
        clr a
        mov r0, #iram_irqctrl
        mov @r0, a
        mov r0, #vdc_soundctrl
        movx @r0, a

        ; Read joystick bit pattern
        mov r1, #0
        call getjoystick
        mov a, r1
        cpl a
        mov r2, a
        mov r1, #iram_keyboard
        mov a, @r1
        orl a, r2
        mov @r1, a

        ; Write columns 9 and 11 chars
    .write_individual_chars:
        disable_vdc_foreground
        orl p1,#07ch                      ; set : !kbscan !vdcen !ramen copyen
        anl p1,#0e7h                      ; clear : !vdcen !ramen

.count set 0
    while .count < 6
        ; column 9
        mov r0, #vdc_char0 + 2 + (.count * 4)
        mov r1, #9 + (.count * 12)
        mov r5, #TIMING_Y_START_OFFSET - (.count * 10)
        call compute_char_from_extram

        ; column 11
        mov r0, #vdc_char6 + 2 + (.count * 4)
        mov r1, #11 + (.count * 12)
        mov r5, #TIMING_Y_START_OFFSET - (.count * 10)
        call compute_char_from_extram
.count set .count + 1
    endm

        ; quad 4 on row 7
        mov r0, #vdc_quad3 + 0 + 2
        mov r1, #9 + (6 * 12)
        mov r5, #TIMING_Y_START_OFFSET - (6 * 10)
        call compute_char_from_extram
        ; quad 4 on row 7
        mov r0, #vdc_quad3 + 4 + 2
        mov r1, #11 + (6 * 12)
        mov r5, #TIMING_Y_START_OFFSET - (6 * 10)
        call compute_char_from_extram

        ; calculate the last entries for columns 9 and 11
        mov r0, #iram_rewrite_start
        mov r1, #9 + (7 * 12)
        mov r5, #TIMING_Y_START_OFFSET - (7 * 10)
        call compute_char_from_extram_mov
        mov r1, #11 + (7 * 12)
        mov r5, #TIMING_Y_START_OFFSET - (7 * 10)
        call compute_char_from_extram_mov

        mov r0, #vdc_char0
        mov a, #TEXT_HI_YPOS + (20 * 1)
        movx @r0, a
        mov r0, #vdc_char6
        mov a, #TEXT_HI_YPOS + (20 * 1)
        movx @r0, a

        orl p1,#0bch                      ; set : !kbscan !vdcen !ramen  lumen
        anl p1,#0b7h                      ; clear : !vdcen copyen
        enable_vdc_foreground

    .continue_vblank_irq:
        ; continue BIOS IRQ routine
        retr


;----------------------
; Line IRQ
;----------------------

        align 16

timeirq:
        ; select base register set(?)
        sel	rb0
        ; stop timer
        stop	tcnt

        ; backup a
        mov r0, #iram_vblank_bkp_a
        mov	@r0,a
        ; Backup P1
        in	a,P1
        mov r0, #iram_vblank_bkp_p1
        mov	@r0,a

        ; Enable VDC in extram
        inline_external_vdc

        ; r2 = eventual computed space character for quad2 each row
        mov r2, #0
        ; r3 = index into extram
        mov r0, #iram_iram_index
        mov a, #0
        mov @r0, a
        ; mov r4, #111b
        ; r5 = "Y offset" to add to VDC character writes
        mov r5, #TIMING_Y_START_OFFSET
        ; r6 = Y position to write to quads
        mov r6, #TEXT_HI_YPOS
        ; r7 = row counter
        ; mov r7, #08h

        ; Wait until the first row should start
        sleep_loop r0, TIMING_CYCLES_TO_FIRST_ROW

        ; Render all eight rows
        mov r3, #0ffh
        mov r4, #0ffh
        nop
        nop
        call compute_chars
        mov r3, #vdc_char0
        mov r4, #TEXT_HI_YPOS + (20 * 8)
        nop
        nop
        call compute_chars
        mov r3, #vdc_char6
        mov r4, #TEXT_HI_YPOS + (20 * 8)
        nop
        nop
        call compute_chars
        mov r3, #vdc_char0+2+0
        mov r0, #iram_rewrite_start+0
        mov a, @r0
        mov r4, a
        call compute_chars
        mov r3, #vdc_char0+2+1
        mov r0, #iram_rewrite_start+1
        mov a, @r0
        mov r4, a
        call compute_chars
        mov r3, #vdc_char6+2+0
        mov r0, #iram_rewrite_start+2
        mov a, @r0
        mov r4, a
        call compute_chars
        mov r3, #vdc_char6+2+1
        mov r0, #iram_rewrite_start+3
        mov a, @r0
        mov r4, a
        call compute_chars
        ; noop
        mov r3, #0ffh
        mov r4, #0ffh
        nop
        nop
        call compute_chars

    .finish_frame:
        ; Set the "frame done" flag
        mov r0, #iram_ictrl
        mov a, @r0
        ; orl a, #ictrl_nextframe
        mov a, #$ff
        mov @r0, a

        ; We're done, reset registers
        ; Reset P1
        mov r0, #iram_vblank_bkp_p1
        mov	a, @r0
        outl	P1,a
        ; Reset a
        mov r0, #iram_vblank_bkp_a
        mov	a,@r0

        ; Set extram enabled
        ; TODO: why is this necessary if we cache P1??
        inline_external_ram

        retr


;------------------------------------------
; Compute next row's chars, store in scratchpad ram
;------------------------------------------

        ; Align to page, since we use "movp a, @a" to lookup constants at start of page
        align 256

compute_page:
        ; color map from two bit reference => three bit color
        ; (we preserve the lowest bit of the three-bit lookup value
        ; since it's actually bit 9 of the character value)
        db col_chr_white | 0, col_chr_white | 1
        db col_chr_red | 0, col_chr_red | 1
        db col_chr_green | 0, col_chr_green | 1
        db col_chr_yellow | 0, col_chr_yellow | 1

        ; Load color from table
        ; a = tile color << 1
        ; out a = three bit color << 1
compute_color:
        movp a, @a
        retr

compute_char_macro macro opcode
        ; Load character byte (shifted left twice)
        movx a, @r1
        ; cut out the lower three bits
        anl a, #111b
        ; lookup in the color table and store temporarily in r7
        movp a, @a
        mov r7, a

        ; cut out the upper five bits
        movx a, @r1
        anl a, #11111000b
        ; add to the "-Y/2 offset" and hold onto carry outcome
        add a, r5
        ; write char value to the odd byte
        opcode @r0, a
        inc r0

        ; xor bit 0 of the color value in r7 with ~carry
        cpl c
        clr a
        rlc a
        xrl a, r7
        ; write color value to the even byte
        opcode @r0, a
        inc r0

        ; increment to next byte
        inc r1
    endm

        ; r0 = vdc pointer
        ; r1 = extram lookup
        ; r5 = -y/2 offset
        ; out r0 = r0 + 2
        ; out r1 = r1 + 1
        ; out r4 = (trashed)
        ; out r5 = r5
compute_char_from_extram:
        compute_char_macro movx
        retr

compute_char_from_extram_mov:
        compute_char_macro mov
        retr

compute_chars:

        inline_external_ram

        mov r0, #iram_tile_compute_start
        mov r1, #iram_iram_index
        mov a, @r1
        mov r1, a

        ; Compute the next ten characters and store in scratchpad RAM
        ; We unroll this loop to save 40 cycles doing call/retr
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        compute_char_macro mov
        ; for the last precompute, we skip the 10th character that gets written via a char move (r3/r4)
        inc r1
        compute_char_macro mov
        inc r1

        ; HACK
        ; inc r1

        assert "hi(compute_page) == hi($)"

        ; Compute space/empty character
    ifdef DEBUG_COLORS
        mov a, #lo(47 << 3) + 1
    else
        mov a, #lo(' ' << 3) + 1
    endif
        add a, r5
        dec a
        mov r2, a

        ; save iram_iram_index
        mov a, r1
        mov r1, #iram_iram_index
        mov @r1, a

        inline_external_vdc


;----------------------
; Row loop + write to VDC during critical period
;----------------------

        ; Timing-sensitive "inner loop" that writes to VDC before each row
        ; uses r0, r1, r2, r5, r6
row_write_to_vdc:
        ; increment r5 (Y offset for VDC)
        mov a, r5
        add a, #(-10)
        mov r5, a
        ; increment r6 (Y position for quads)
        mov a, r6
        add a, #20
        mov r6, a

        ; Base of scratchpad RAM
        mov r1, #iram_tile_compute_start

    .critical_zone:
        ; Disable foreground graphics
        disable_vdc_foreground

        ; Move all quads down
        mov a, r6
        mov r0, #vdc_quad0
        movx @r0,a
        mov r0, #vdc_quad1
        movx @r0,a
        mov r0, #vdc_quad2
        movx @r0,a
        ; mov r0, #vdc_quad3
        ; movx @r0,a

        ; Copy from scratchpad RAM into VDC registers (10 cycles)
write_to_char macro dest
        mov a, @r1
        inc r1
        mov r0, #dest+2
        movx @r0,a
        mov a, @r1
        inc r1
        inc r0
        movx @r0,a
    endm

        ; Repeat for each quad; to do this quickly we unroll the loop and repeat for each quad write
        ; We also do this in visual order, not memory order
        write_to_char vdc_quad0+0
        write_to_char vdc_quad1+0
        write_to_char vdc_quad0+4
        write_to_char vdc_quad1+4
        write_to_char vdc_quad0+8
        write_to_char vdc_quad1+8
        write_to_char vdc_quad0+12
        write_to_char vdc_quad1+12
        write_to_char vdc_quad2+0

        ; Can elide the last "inc r1" for the last quad
        mov a, @r1
        inc r1
        mov r0, #vdc_quad2+4+2
        movx @r0,a

        ; HACK for 13 wide row
        mov r0, #vdc_quad2+8+2     ; 2
        movx @r0, a

        mov a, @r1
        ; inc r1
        inc r0
        movx @r0,a

        ; Write out "empty" characters (last two entries in the third quad) using r2
        mov a, r2
        mov r0, #vdc_quad2+12+2     ; 2
        movx @r0, a

        ; Rewrite the last row
        mov a, r3
        mov r0, a
        mov a, r4
        movx @r0, a

        ; HACK for 13 wide row
        inc r1
        inc r1

        ; Pad out the rest of the cycles in the line
        ; TODO: this can be reused for something more interesting graphically
        sleep_loop r0, TIMING_VDC_WRITE_PADDING

        ; Enable foreground graphics
        enable_vdc_foreground

    .sleep_until_next_row:
        ; wait loop until next row
        sleep_loop r0, TIMING_AFTER_COMPUTE

        ; set grid+background color
    ifdef DEBUG_COLORS
        mov	r0,#vdc_color
        mov r1,#iram_iram_index
        mov	a,@r1
        movx	@r0,a
    else
        sleep_loop r0, 7
    endif

        ; VDC is enabled, start computing next row
        retr


;------------------------------
; Program loop, starts in bank 1
;------------------------------

EXTRAM_SCORE            equ 0x6a
; EXTRAM_APPLE_X          equ 0x62
; EXTRAM_APPLE_Y          equ 0x63
EXTRAM_SNAKE_START_X    equ 0x6b
EXTRAM_SNAKE_START_Y    equ 0x6c
EXTRAM_SNAKE_START_DIR  equ 0x6d
EXTRAM_SNAKE_END_X      equ 0x6e
EXTRAM_SNAKE_END_Y      equ 0x6f
EXTRAM_SNAKE_END_DIR    equ 0x70
EXTRAM_FRAME            equ 0x71
; EXTRAM_RANDOM           equ 0x6b

SNAKE_TILE              equ 58
SNAKE_LEFT              equ 52
SNAKE_RIGHT             equ 51
APPLE_TILE              equ 49
EMPTY_TILE              equ ' '

; Same as joystick bit pattern
DIR_UP                  equ 1 << 0
DIR_RIGHT               equ 1 << 1
DIR_DOWN                equ 1 << 2
DIR_LEFT                equ 1 << 3

        org $800

        ; main loop
main:
        dis i
        inline_external_vdc

        mov a, #70
        mov r0, #vdc_spr0_ctrl
        movx @r0, a  ;y
        inc r0
        mov a, #32
        movx @r0, a ;x
        inc r0
        mov a, #col_spr_blue
        movx @r0, a ;col

        mov a, #10101010b
        mov r0, #vdc_spr0_shape
        movx @r0, a
        mov r1, #8
    -:
        inc r0
        rl a
        movx @r0, a
        djnz r1, -
        

        inline_external_ram
        en i

        ; random byte
        mov a, #4
        mov r0, #iram_random
        mov @r0, a

        ; Write decorative tiles
        write_extram_string 'SNAKE', 2, 0, TILE_GREEN
        write_extram_char 54, 7, 0, TILE_BLUE
        write_extram_string '00', 8, 0, TILE_WHITE

        ; extram frame
        mov a, #0
        mov r0, #EXTRAM_FRAME
        movx @r0, a
        ; extram score
        clr a
        mov r0, #EXTRAM_SCORE
        movx @r0, a

        ; extram snake start x
        mov a, #3
        mov r0, #EXTRAM_SNAKE_START_X
        movx @r0, a
        ; extram snake start y
        mov a, #4
        mov r0, #EXTRAM_SNAKE_START_Y
        movx @r0, a
        ; extram snake start dir
        mov a, #DIR_RIGHT
        mov r0, #EXTRAM_SNAKE_START_DIR
        movx @r0, a
        ; extram snake end x
        mov a, #4
        mov r0, #EXTRAM_SNAKE_END_X
        movx @r0, a
        ; extram snake end y
        mov a, #4
        mov r0, #EXTRAM_SNAKE_END_Y
        movx @r0, a
        ; extram snake end dir
        mov a, #DIR_RIGHT
        mov r0, #EXTRAM_SNAKE_END_DIR
        movx @r0, a

        ; draw snake
        mov r1, #calc_extram_char(SNAKE_TILE, TILE_GREEN)
        mov r2, #3
        mov r3, #4
        call routine_write_extram_char
        mov r2, #4
        mov r3, #4
        call routine_write_extram_char

        ; TEMP snake extension
        ; mov r1, #calc_extram_char(SNAKE_RIGHT, TILE_GREEN)
        ; mov r2, #3
        ; mov r3, #4
        ; call routine_write_extram_char
        ; mov r1, #calc_extram_char(SNAKE_LEFT, TILE_GREEN)
        ; mov r2, #3
        ; mov r3, #5
        ; call routine_write_extram_char
        ; mov r1, #calc_extram_char(SNAKE_TILE, TILE_GREEN)
        ; mov r2, #2
        ; mov r3, #5
        ; call routine_write_extram_char

        call new_apple_position

        ; en i

main_loop:
        ; Clear the "frame done" flag
        mov r0, #iram_ictrl
        mov a, @r0
        anl a, #01111111b
        mov @r0, a
    
    .main_loop_start:
        ; Seed the randomizer with keyboard inputs
        mov r0, #iram_keyboard
        mov a, @r0
        anl a, #1111b
        jz +
        mov r0, #iram_random
        mov a, @r0
        rr a
        swap a
        rr a
        mov @r0, a
    +:
        
        ; until a frame has passed, do nothing
        mov r0, #iram_ictrl
        mov a, @r0
        cpl	a
        jb7	.main_loop_start

        ; bump frame
        mov r0, #EXTRAM_FRAME
        movx a, @r0
        jb3 .next_frame
        ; jb4 .next_frame
        ; jb5 .next_frame
        inc a
        movx @r0, a
        jmp main_loop
    .next_frame:
        ; Clear frameskip number
        mov a, #0
        movx @r0, a

        jmp change_direction



        align 128

change_direction:
        ; Move current direction into r4
        mov r0, #EXTRAM_SNAKE_END_DIR
        movx a, @r0
        mov r4, a

        ; load joystick ram
        mov r0, #iram_keyboard
        mov a, @r0
        ; clear joystick
        mov r5, a
        clr a
        mov @r0, a
        mov a, r5

        jb0 .up
        jb1 .right
        jb2 .down
        jb3 .left
        jmp .skip

    .up:
        mov r5, #DIR_UP
        mov a, r4
        anl a, #DIR_LEFT
        jz +
        mov r1, #calc_extram_char(SNAKE_RIGHT, TILE_GREEN)
        jmp .accept
    +:
        mov a, r4
        anl a, #DIR_RIGHT
        jz .skip
        mov r1, #calc_extram_char(SNAKE_LEFT, TILE_GREEN)
        jmp .accept

    .right:
        mov r5, #DIR_RIGHT
        mov a, r4
        anl a, #DIR_UP
        jz +
        mov r1, #calc_extram_char(SNAKE_RIGHT, TILE_GREEN)
        jmp .accept
    +:
        mov a, r4
        anl a, #DIR_DOWN
        jz .skip
        mov r1, #calc_extram_char(SNAKE_RIGHT, TILE_GREEN)
        jmp .accept

    .down:
        mov r5, #DIR_DOWN
        mov a, r4
        anl a, #DIR_LEFT
        jz +
        mov r1, #calc_extram_char(SNAKE_LEFT, TILE_GREEN)
        jmp .accept
    +:
        mov a, r4
        anl a, #DIR_RIGHT
        jz .skip
        mov r1, #calc_extram_char(SNAKE_RIGHT, TILE_GREEN)
        jmp .accept

    .left:
        mov r5, #DIR_LEFT
        mov a, r4
        anl a, #DIR_UP
        jz +
        mov r1, #calc_extram_char(SNAKE_LEFT, TILE_GREEN)
        jmp .accept
    +:
        mov a, r4
        anl a, #DIR_DOWN
        jz .skip
        mov r1, #calc_extram_char(SNAKE_LEFT, TILE_GREEN)
        jmp .accept

    .accept:
        ; extram snake end x
        mov r0, #EXTRAM_SNAKE_END_X
        movx a, @r0
        mov r2, a
        ; extram snake end y
        mov r0, #EXTRAM_SNAKE_END_Y
        movx a, @r0
        mov r3, a
        ; Write to current sprite pos
        call routine_write_extram_char

        ; Write direction to extram and continue
        mov a, r5
        mov r0, #EXTRAM_SNAKE_END_DIR
        movx @r0, a
        jmp move_head

    .skip:
        ; extram snake end x
        mov r0, #EXTRAM_SNAKE_END_X
        movx a, @r0
        mov r2, a
        ; extram snake end y
        mov r0, #EXTRAM_SNAKE_END_Y
        movx a, @r0
        mov r3, a
        ; Write to current sprite pos
        mov r1, #calc_extram_char(SNAKE_TILE, TILE_GREEN)
        call routine_write_extram_char

        jmp move_head

        align 16

move_head:
        ; extram snake end x
        mov r0, #EXTRAM_SNAKE_END_X
        movx a, @r0
        mov r2, a
        ; extram snake end y
        mov r0, #EXTRAM_SNAKE_END_Y
        movx a, @r0
        mov r3, a
        ; extram snake dir
        mov r0, #EXTRAM_SNAKE_END_DIR
        movx a, @r0

        jb0 .up
        jb1 .right
        jb2 .down
        ; jb3 .left
    .left:
        ; Check position
        mov a, r2
        add a, #0
        jnz +
        jmp game_over
        
        ; Update position
    +:
        dec r2
        mov r0, #EXTRAM_SNAKE_END_X
        mov a, r2
        movx @r0, a
        jmp .done
    .up:
        ; Check position
        mov a, r3
        add a, #-(2)
        jc +
        jmp game_over
        
        ; Update position
    +:
        dec r3
        mov r0, #EXTRAM_SNAKE_END_Y
        mov a, r3
        movx @r0, a
        jmp .done
    .right:
        ; Check position
        mov a, r2
        add a, #-11
        jnc +
        jmp game_over
        
        ; Update position
    +:
        inc r2
        mov r0, #EXTRAM_SNAKE_END_X
        mov a, r2
        movx @r0, a
        jmp .done
    .down:
        ; Check position
        mov a, r3
        add a, #-7
        jnc +
        jmp game_over
        
        ; Update position
    +:
        inc r3
        mov r0, #EXTRAM_SNAKE_END_Y
        mov a, r3
        movx @r0, a
        jmp .done

    .done:
        ; Copy X and Y to backup registers
        mov a, r2
        mov r4, a
        mov a, r3
        mov r5, a

check_target_tile:
        ; Read tile at this location
        call routine_read_extram_char
        mov r6, a

        ; Write tile
        mov a, r4
        mov r2, a
        mov a, r5
        mov r3, a
        mov r1, #calc_extram_char(SNAKE_TILE, TILE_BLUE)
        call routine_write_extram_char

        ; Check overwritten tile for apple
        mov a, r6
        add a, #-(APPLE_TILE)
        jz .ate_apple
        jmp .check_collision

    .ate_apple:
        ; Update the apple position
        call new_apple_position

        ; increment score
        mov r0, #EXTRAM_SCORE
        movx a, @r0
        add a, #01h
        da a
        movx @r0, a
        ; update display
        anl a, #1111b
        rl a
        rl a
        rl a
        mov r1, a
        mov r2, #9
        mov r3, #0
        call routine_write_extram_char
        mov r0, #EXTRAM_SCORE
        movx a, @r0
        swap a
        anl a, #1111b
        rl a
        rl a
        rl a
        mov r1, a
        mov r2, #8
        mov r3, #0
        call routine_write_extram_char

        ; loop game
        jmp main_loop

        ; Check overwritten tile for snake
    .check_collision:
        mov a, r6
        add a, #-(EMPTY_TILE)
        jz +
        jmp game_over

    +:
        jmp move_tail

        align 16

game_over:
        ; draw red X where we ended
        mov r1, #calc_extram_char('X', TILE_RED)
        ; extram snake end x
        mov r0, #EXTRAM_SNAKE_END_X
        movx a, @r0
        mov r2, a
        ; extram snake end y
        mov r0, #EXTRAM_SNAKE_END_Y
        movx a, @r0
        mov r3, a
        call routine_write_extram_char

        ; wait for keypress
        mov r0, #iram_keyboard
        clr a
        mov @r0, a

    -:
        mov a, @r0
        jb4 +
        jmp -
    +:
        dis i
        dis	tcnti
        jmp bank0_start



        ; load tail position
move_tail:
        ; extram snake end x
        mov r0, #EXTRAM_SNAKE_START_X
        movx a, @r0
        mov r4, a
        ; extram snake end y
        mov r0, #EXTRAM_SNAKE_START_Y
        movx a, @r0
        mov r5, a

        mov a, r4
        mov r2, a
        mov a, r5
        mov r3, a
        call routine_read_extram_char
        mov r0, a
        mov r1, #EXTRAM_SNAKE_START_DIR
        movx a, @r1
        mov r1, a
        call get_dir_from_char
        mov r1, #EXTRAM_SNAKE_START_DIR
        movx @r1, a
        ; Save the direction
        mov r6, a

    .erase_tile:
        mov r1, #calc_extram_char(EMPTY_TILE, TILE_GREEN)
        mov a, r4
        mov r2, a
        mov a, r5
        mov r3, a
        call routine_write_extram_char

update_tail_position:
        mov a, r6
        jb0 .up
        jb1 .right
        jb2 .down
    .left:
        mov r0, #EXTRAM_SNAKE_START_X
        movx a, @r0
        dec a
        movx @r0, a
        jmp .done
    .down:
        mov r0, #EXTRAM_SNAKE_START_Y
        movx a, @r0
        inc a
        movx @r0, a
        jmp .done
    .right:
        mov r0, #EXTRAM_SNAKE_START_X
        movx a, @r0
        inc a
        movx @r0, a
        jmp .done
    .up:
        mov r0, #EXTRAM_SNAKE_START_Y
        movx a, @r0
        dec a
        movx @r0, a
        ; jmp .done

    .done:
        jmp main_loop






; other methods

divide_method:
        mov r4, #0ffh
        mov a, r3
        cpl a
        inc a
        mov r6, a
        mov a, r2
    -:
        add a, r6	; r2 - r3
        inc r4
        jc -
        add a, r3
        mov r5, a
        ret



new_apple_position:

    .loop_to_find_locatioon:
        call get_random_number
        mov r2, a
        ; extram apple y
        ; mov a, #7
        ; mov r0, #EXTRAM_APPLE_Y
        ; movx @r0, a
        ; modulus
        mov r3, #7
        call divide_method
        mov a, r5
        inc a
        mov r7, a

        call get_random_number
        mov r2, a
        ; extram apple x
        ; mov a, #12
        ; mov r0, #EXTRAM_APPLE_X
        ; movx @r0, a
        ; modulus
        mov r3, #12
        call divide_method
        mov a, r5
        inc a
        mov r2, a
        mov r5, a
        ; move y register
        mov a, r7
        mov r3, a
        mov r6, a

        ; check tile contents
        call routine_read_extram_char
        add a, #-EMPTY_TILE
        ; jnz .main_loop_reset
        jnz .loop_to_find_locatioon

    draw_apple:
        ; draw apple tile
        mov r1, #calc_extram_char(APPLE_TILE, TILE_RED)
        mov a, r5
        mov r2, a
        mov a, r6
        mov r3, a
        ; mov r2, #8
        ; mov r3, #2
        call routine_write_extram_char

    +:
        retr


        ; lookup tile for the apple
    ;     mov r2, #8
    ;     mov r3, #2
    ;     call routine_read_extram_char
    ;     add a, #-APPLE_TILE
    ;     ; jnz .main_loop_reset
    ;     jnz .other_check

    ;     ; jmp bank0_start

    ;     ; write a blue apple
    ;     write_extram_char 48, 8, 2, TILE_BLUE

    ;     jmp .main_loop_reset
    
    ; .other_check:
    ;     write_extram_char 49, 8, 2, TILE_RED

    ;     jmp .main_loop_reset

        ; ; lookup tile for the snake end and set r2=x, r3=y
        ; mov r0, #EXTRAM_SNAKE_START_X
        ; movx a, @r0
        ; mov r2, a
        ; mov r0, #EXTRAM_SNAKE_START_Y
        ; movx a, @r0
        ; mov r3, a
        ; call routine_read_extram_char

        ; ; does R1 hold an APPLE_TILE icon
        ; ; mov r1, a
        ; add a, #-49
        ; jnz .main_loop_reset


        align 16

        ; out a = random
get_random_number:
        ; https://github.com/7800-devtools/lfsr6502/blob/master/README.txt
        mov r0, #iram_random
        mov a, @r0

        clr c
        rrc a
        jnc .no_eor
        xrl a, #$B4
    .no_eor:
        mov @r0, a
        retr

        ; r1 = calc_extram_char(char, color)
        ; r2 = x
        ; r3 = y
routine_write_extram_char:
        mov a, r3
        rl a
        rl a
        mov r3, a
        rl a
        add a, r3
        add a, r2

        ; prevent overflow
        mov r0, a
        add a, #-(12*8)
        jb7 +
        retr

    +:
        ; lookup
        ; mov r0, a
        mov a, r1
        movx @r0, a
        retr

        ; r2 = x
        ; r3 = y
        ; out a = character
routine_read_extram_char:
        mov a, r3
        rl a
        rl a
        mov r3, a
        rl a
        add a, r3
        add a, r2
        mov r0, a

        ; lookup
        movx a, @r0
        rr a
        rr a
        rr a
        anl a, #00111111b

        retr


        align 64

get_dir_from_char_lookup:
        db DIR_UP,      DIR_LEFT,   DIR_RIGHT
        db DIR_RIGHT,   DIR_UP,     DIR_DOWN
        db DIR_DOWN,    DIR_LEFT,   DIR_RIGHT
        db DIR_LEFT,    DIR_DOWN,   DIR_UP

        ; r0 = char
        ; r1 = input dir
        ; out a = dir
get_dir_from_char:
        mov a, r1
        jb0 .up
        jb1 .right
        jb2 .down
    .left:
        mov r1, #9
        jmp .char_lookup
    .down:
        mov r1, #6
        jmp .char_lookup
    .right:
        mov r1, #3
        jmp .char_lookup
    .up:
        mov r1, #0
        jmp .char_lookup

    .char_lookup:
        mov a, r0
        add a, #-SNAKE_RIGHT
        jnz +
        mov a, r1
        add a, #2 + lo(get_dir_from_char_lookup)
        movp a, @a
        retr
    +:
        mov a, r0
        add a, #-SNAKE_LEFT
        jnz +
        mov a, r1
        add a, #1 + lo(get_dir_from_char_lookup)
        movp a, @a
        retr
    +:
        mov a, r1
        add a, #0 + lo(get_dir_from_char_lookup)
        movp a, @a
        retr

        assert "hi(get_dir_from_char_lookup) == hi($)"

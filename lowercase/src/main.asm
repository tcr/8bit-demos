	cpu	8048




;-----------------
; Internal RAM values
;-----------------

iram_work	    equ	020h
iram_value	    equ	021h
iram_ictrl	    equ	022h	    ; control irq
iram_vdcctrl	equ	023h	    ; control value from VDC
iram_hcnt       equ 024h

; Flag values
ictrl_blink	    equ	080h	    ; if set, do the blinking
ictrl_lineirq	equ	040h	    ; if set, do the lineirq


TEXT_XPOS       equ 1bh
QUADA_XPOS      equ 19h
QUADB_XPOS      equ 21h
QUADC_XPOS      equ 49h
QUADD_XPOS      equ 51h
TEXT_UP_YPOS    equ 21h
TEXT_HI_YPOS    equ 23h
TEXT_LO_YPOS    equ 29h



;-----------------
; Program start
;-----------------

        org	400h
        
        include	"g7000.h"

        jmp	selectgame	; RESET
        jmp	irq		    ; interrupt
        jmp	timeirq		; timer
        jmp	myvsyncirq	; VSYNC-interrupt
        jmp	start		; after selectgame
        jmp	soundirq	; sound-interrupt

start:
        ; initialise variables
        mov	a,#025h		; the bit in the middle
        mov	r0,#iram_work
        mov	@r0,a
        mov	a,#1		; middle bit is set
        mov	r0,#iram_value
        mov	@r0,a
        mov	r0,#iram_ictrl
        mov	a,#0		; don't blink yet
        mov	@r0,a
        mov r0,#iram_hcnt
        mov @r0,a

        ; activate blinking and line irq
        mov	r0,#iram_ictrl
        mov	a,#ictrl_blink | ictrl_lineirq
        mov	@r0,a

        ; turn grid gfx off, the bios-routine is not safe
        ; to use in irq, it leaves with RB1 and EN I
        sel rb0
        mov	r0,#vdc_control
        movx	a,@r0
        ; mov	@r1,a		; store old vdc_control
        orl	a,#2 | 080h
        movx	@r0,a
        sel rb1


        ; Prepare for graphics initialization
        call	gfxoff


init_grid:
        ; Initialize the horizontal grid
    ;     mov	r0,#vdc_gridh0
    ;     mov	r2,#10
    ; .loopgh:
    ;     mov	a,#0ffh		; get value
    ;     movx	@r0,a		; store in vdc
    ;     inc	r0
    ;     djnz	r2,.loopgh

        ; Initialize the vertical grid
        mov	r0,#vdc_gridv0+1
        mov	r2,#8
    .loopgv:
        mov	a,#0ffh		; get value
        movx	@r0,a		; store in vdc
        inc	r0
        djnz	r2,.loopgv

init_text:
        ; Draw text
        call print_lowercase_string

        ; Re-enable graphics
        call gfxon

; main loop
main:
        jmp main



;----------------------
; VSync IRQ
;----------------------

gfx_off macro 
        mov r0, #0a0h
        movx a, @r0                    ; read $A0 VDC Control Register
        anl a, #0d6h                       ; Turn off foreground,grid
        movx @r0, a                    ; update VDC Control
    endm

gfx_on macro 
        mov r0, #0a0h
        movx a, @r0                    ; read $A0 VDC Control Register
        orl a, #028h                       ; Turn off foreground,grid
        movx @r0, a                    ; update VDC Control
    endm

; it starts the lineirq and does the blinking
myvsyncirq
        ; Enable foreground sprites
        mov r0, #0a0h
        mov a,#8|32|128
        movx @r0,a

        ; start lineirq, if needed
        mov	r0,#iram_ictrl	; control register
        mov	a,@r0
        cpl	a
        jb6	myvsyncnoline	; should we start line irq ?
        jmp myvsyncnext

    myvsyncnoline:
        ; set grid+background color
        mov	r0,#vdc_color
        mov	a,#col_grd_violet | col_bck_cyan
        movx	@r0,a

        jmp	vsyncirq	; thats all for now

myvsyncnext:
        mov	a,@r0
        mov	a,#0d4h		; middle of the screen
        mov	t,a		    ; set # of lines to wait
        strt	cnt		; start line counting
        en	tcnti		; enable timer irq

        ; set grid+background color
        mov	r0,#vdc_color
        mov	a,#col_grd_violet | col_bck_cyan
        movx	@r0,a

        jmp	vsyncirq


;----------------------
; Line IRQ
;----------------------

timeirq:
        ; select base register set(?)
        sel	rb0
        ; stop timer
        stop	tcnt

        ; backup a
        mov	r5,a
        ; Backup P1
        in	a,P1
        mov	r6,a

        ; Enable VDC in extram
        call	vdcenable

        ; Wait until off screen
        rept 13
	    nop
        endm

        ; vdc control
        mov r1, #0a0h

        ; set grid+background color
        mov	r0,#vdc_color
        mov	a,#col_grd_red | col_bck_blue
        movx	@r0,a
        
        ; kill the character text
        mov a,#8|128
        movx @r1,a

        ; Reset P1
        mov	a,r6
        outl	P1,a
        ; Reset a
        mov	a,r5

        retr



;------------------------------
; Quads and text
;------------------------------


printcharadj macro char, color, dir, count, ypos=TEXT_HI_YPOS
        mov     r4,#ypos
        mov     r5,#char
        mov     r6,#color
        call    printchar
        rept count
        dir     r5
        endm
        mov     a,r0
        mov     r1,a
        dec     r1
        dec     r1
        mov     a,r5
        movx     @r1,a
    endm

; A-Zu uppercase
print_Au_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Au_lo macro 
        printcharadj char=20h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Bu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Bu_lo macro 
        printcharadj char=25h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Cu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Cu_lo macro 
        printcharadj char=23h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Du_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Du_lo macro 
        printcharadj char=1ah, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Eu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Eu_lo macro 
        printcharadj char=12h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Fu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Fu_lo macro 
        printcharadj char=1bh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Gu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Gu_lo macro 
        printcharadj char=1ch, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Hu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Hu_lo macro 
        printcharadj char=1dh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Iu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Iu_lo macro 
        printcharadj char=16h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Ju_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Ju_lo macro 
        printcharadj char=1eh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Ku_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Ku_lo macro 
        printcharadj char=1fh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Lu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Lu_lo macro 
        printcharadj char=0eh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Mu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Mu_lo macro 
        printcharadj char=26h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Nu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Nu_lo macro 
        printcharadj char=2dh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Ou_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Ou_lo macro 
        printcharadj char=17h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Pu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Pu_lo macro 
        printcharadj char=0fh, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Qu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Qu_lo macro 
        printcharadj char=18h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Ru_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Ru_lo macro 
        printcharadj char=13h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Su_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Su_lo macro 
        printcharadj char=19h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Tu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Tu_lo macro 
        printcharadj char=14h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Uu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Uu_lo macro 
        printcharadj char=15h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Vu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Vu_lo macro 
        printcharadj char=24h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Wu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Wu_lo macro 
        printcharadj char=11h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Xu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Xu_lo macro 
        printcharadj char=22h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Yu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Yu_lo macro 
        printcharadj char=2ch, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm
print_Zu_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3
    endm
print_Zu_lo macro 
        printcharadj char=21h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_UP_YPOS
    endm


; a-z lowercase
print_a_hi macro 
        printcharadj char=02h, color=col_chr_white, dir=dec, count=1
    endm
print_a_lo macro
        printcharadj char=09h, color=col_chr_white, dir=inc, count=1, ypos=TEXT_LO_YPOS
    endm
print_b_hi macro 
        printcharadj char=06h, color=col_chr_white, dir=inc, count=2
    endm
print_b_lo macro
        printcharadj char=09h, color=col_chr_white, dir=inc, count=1, ypos=TEXT_LO_YPOS
    endm
print_c_hi macro 
        printcharadj char=03h, color=col_chr_white, dir=dec, count=1
    endm
print_c_lo macro
        printcharadj char=35, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_d_hi macro 
        printcharadj char=61, color=col_chr_white, dir=inc, count=1
    endm
print_d_lo macro
        printcharadj char=09h, color=col_chr_white, dir=inc, count=1, ypos=TEXT_LO_YPOS
    endm
print_e_hi macro 
        printcharadj char=0, color=col_chr_white, dir=dec, count=0
    endm
print_e_lo macro
        printcharadj char=05h, color=col_chr_white, dir=inc, count=0, ypos=TEXT_LO_YPOS-2
    endm
print_f_hi macro 
        printcharadj char=13, color=col_chr_white, dir=inc, count=2
    endm
print_f_lo macro
        printcharadj char=16, color=col_chr_white, dir=inc, count=3, ypos=TEXT_LO_YPOS
    endm
print_g_hi macro 
        printcharadj char=03h, color=col_chr_white, dir=dec, count=1
    endm
print_g_lo macro
        printcharadj char=33, color=col_chr_white, dir=inc, count=0, ypos=TEXT_LO_YPOS
    endm
print_h_hi macro 
        printcharadj char=06h, color=col_chr_white, dir=inc, count=2
    endm
print_h_lo macro
        printcharadj char=26, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_i_hi macro
        printcharadj char=10, color=col_chr_white, dir=inc, count=2
    endm
print_i_lo macro
        printcharadj char=20, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_j_hi macro 
        printcharadj char=10, color=col_chr_white, dir=inc, count=2
    endm
print_j_lo macro
        printcharadj char=53, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_k_hi macro 
        printcharadj char=14, color=col_chr_white, dir=inc, count=1
    endm
print_k_lo macro
        printcharadj char=31, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_l_hi macro 
        printcharadj char=20, color=col_chr_white, dir=inc, count=2
    endm
print_l_lo macro
        printcharadj char=20, color=col_chr_white, dir=inc, count=3, ypos=TEXT_LO_YPOS
    endm
print_m_hi macro
        printcharadj char=38, color=col_chr_white, dir=dec, count=1
    endm
print_m_lo macro
        printcharadj char=38, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_n_hi macro 
        printcharadj char=26, color=col_chr_white, dir=dec, count=1
    endm
print_n_lo macro
        printcharadj char=26, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_o_hi macro 
        printcharadj char=23, color=col_chr_white, dir=dec, count=1
    endm
print_o_lo macro
        printcharadj char=23, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_p_hi macro 
        printcharadj char=15, color=col_chr_white, dir=dec, count=1
    endm
print_p_lo macro 
        printcharadj char=15, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_q_hi macro 
        printcharadj char=9, color=col_chr_white, dir=dec, count=1
    endm
print_q_lo macro 
        printcharadj char=9, color=col_chr_white, dir=inc, count=2, ypos=TEXT_LO_YPOS
    endm
print_r_hi macro 
        printcharadj char=26, color=col_chr_white, dir=dec, count=1
    endm
print_r_lo macro 
        printcharadj char=14, color=col_chr_white, dir=inc, count=3, ypos=TEXT_LO_YPOS
    endm
print_s_hi macro 
        printcharadj char=5, color=col_chr_white, dir=dec, count=1
    endm
print_s_lo macro
        printcharadj char=53, color=col_chr_white, dir=inc, count=1, ypos=TEXT_LO_YPOS
    endm
print_t_hi macro 
        printcharadj char=16, color=col_chr_white, dir=inc, count=2
    endm
print_t_lo macro
        printcharadj char=20, color=col_chr_white, dir=inc, count=1, ypos=TEXT_LO_YPOS
    endm
print_u_hi macro 
        printcharadj char=21, color=col_chr_white, dir=dec, count=1
    endm
print_u_lo macro
        printcharadj char=21, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_v_hi macro 
        printcharadj char=36, color=col_chr_white, dir=dec, count=1
    endm
print_v_lo macro
        printcharadj char=36, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_w_hi macro 
        printcharadj char=17, color=col_chr_white, dir=dec, count=1
    endm
print_w_lo macro
        printcharadj char=17, color=col_chr_white, dir=inc, count=3, ypos=TEXT_LO_YPOS
    endm
print_x_hi macro 
        printcharadj char=41, color=col_chr_white, dir=inc, count=0
    endm
print_x_lo macro
        printcharadj char=34, color=col_chr_white, dir=inc, count=3, ypos=TEXT_LO_YPOS
    endm
print_y_hi macro 
        printcharadj char=9, color=col_chr_white, dir=inc, count=1
    endm
print_y_lo macro
        printcharadj char=9, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm
print_z_hi macro 
        printcharadj char=33, color=col_chr_white, dir=dec, count=1
    endm
print_z_lo macro
        printcharadj char=33, color=col_chr_white, dir=inc, count=4, ypos=TEXT_LO_YPOS
    endm

; space
print_sp_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=2
    endm
print_sp_lo macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=3, ypos=TEXT_HI_YPOS
    endm

; period
print_per_hi macro 
        printcharadj char=12, color=col_chr_white, dir=inc, count=2
    endm
print_per_lo macro 
        printcharadj char=27h, color=col_chr_white, dir=inc, count=1, ypos=TEXT_HI_YPOS
    endm

; Macro for printing letters

print_letters macro AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL
    ; quad 0
    mov     r0,#vdc_quad0       ; start char
    mov     r3,#QUADA_XPOS             ; x-position
    mov     r4,#TEXT_HI_YPOS             ; y-position
    print_AA_hi
    print_CC_hi
    print_EE_hi
    printcharadj char=12, color=col_chr_white, dir=inc, count=4

    ; quad 1
    mov     r0,#vdc_quad1       ; start char
    mov     r3,#QUADB_XPOS             ; x-position
    mov     r4,#TEXT_HI_YPOS             ; y-position
    print_BB_hi
    print_DD_hi
    print_FF_hi
    printcharadj char=12, color=col_chr_white, dir=inc, count=4

    ; quad 2
    mov     r0,#vdc_quad2       ; start char
    mov     r3,#QUADC_XPOS             ; x-position
    mov     r4,#TEXT_HI_YPOS             ; y-position
    print_GG_hi
    print_II_hi
    print_KK_hi
    printcharadj char=12, color=col_chr_white, dir=inc, count=4

    ; quad 3
    mov     r0,#vdc_quad3       ; start char
    mov     r3,#QUADD_XPOS             ; x-position
    mov     r4,#TEXT_HI_YPOS             ; y-position
    print_HH_hi
    print_JJ_hi
    print_LL_hi
    printcharadj char=12, color=col_chr_white, dir=inc, count=4

    ; lower characters
    mov     r0,#vdc_char0       ; start char
    mov     r3,#QUADA_XPOS             ; x-position
    print_AA_lo
    print_BB_lo
    print_CC_lo
    print_DD_lo
    print_EE_lo
    print_FF_lo
    print_GG_lo
    print_HH_lo
    print_II_lo
    print_JJ_lo
    print_KK_lo
    print_LL_lo
    ; printcharadj char=12, color=col_chr_white, dir=inc, count=4
    endm

;---------------------------------------------------
; Print a lowercase string
;---------------------------------------------------

print_lowercase_string:
        ; Letter a-z, A-Z+u (uppercase), sp (space), per (period)
        ; 12 letters in this kernel

        print_letters Ku, per, Cu, per, Mu, u, n, c, h, k, i, n
        ; print_letters Ou, d, y, s, s, e, y, sp, Tu, w, o, sp
        ; print_letters Su, e, l, e, c, t, sp, Gu, a, m, e, sp
        ; print_letters Lu, o, w, e, r, c, a, s, e, per, sp, sp
        ; print_letters Tu, h, e, sp, c, a, s, t, l, e, sp, sp
        ; print_letters a, b, c, d, e, f, g, h, i, j, k, l
        ; print_letters m, n, o, p, q, r, s, t, u, v, w, x
        ; print_letters y, z, sp, sp, sp, sp, sp, sp, sp, sp, sp, sp

        retr


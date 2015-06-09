$mod2051
;
TICS	equ	0ffffh-9216
;---------------------------------------------
; store times in binary in registers
;
mm	equ	R2
ss	equ	R3
hh	equ	R4
;
	dseg
	org	40h
buffer:	ds	32
	cseg
;---------------------------------------------
; uses interrupts !
; choose which routine you want to see working
; remember to swap to the correct ISR as well
;
	org	0h
;	acall	capture_rs232
; or perhaps
;	acall	start_timer
; or perhaps
	acall	rs232_to_lcd
;
	org	0bh
	sjmp	clock_interrupt
	
	org	23h
;	sjmp	capture_rs232_interrupt
; or perhaps
	sjmp	rs232_to_lcd_interrupt
;---------------------------------------------
; clock interrupt, start clock going for
; another 1/100 of a second
;
clock_interrupt:
	clr	tr0		;stop timer
	clr	tf0		;clear flag
	mov	th0,#(TICS/256)
	mov	tl0,#(TICS mod 256)
	setb	tr0		;start the timer
	call	inc_clock
	reti
;---------------------------------------------
; capture_rs232_interrupt, put data where r0
; points, then increment r0
;
capture_rs232_interrupt:
	jb	ti,l1
	clr	ri
	mov	@r0,sbuf
	inc	r0
	reti
l1:	clr	ti
	reti
;---------------------------------------------
; rs232_to_lcd_interrupt, display data on lcd
;
rs232_to_lcd_interrupt:
	jb	ti,l2
	clr	ri
	push	acc
	mov	a,sbuf
	acall	put_lcd
	pop	acc
	reti
l2:	clr	ti
	reti
;---------------------------------------------
; capture serial data - put into memory
;
capture_rs232:	
	mov	r0,#buffer
	anl	tmod,#0fh	;zero timer 1
	orl	tmod,#20h	;set mode 2
	mov	th1,#0fdh	;reload value
	mov	tl1,#0fdh	;initial value
	mov	scon,#50h	;serial mode
	setb	tr1		;start timer1
	setb	ea
	setb	es
	sjmp	$
;---------------------------------------------
; capture serial data - put to lcd
;
rs232_to_lcd:	
	acall	init_lcd
	anl	tmod,#0fh	;zero timer 1
	orl	tmod,#20h	;set mode 2
	mov	th1,#0fdh	;reload value
	mov	tl1,#0fdh	;initial value
	mov	scon,#50h	;serial mode
	setb	tr1		;start timer1
	setb	ea
	setb	es
	sjmp	$
;---------------------------------------------
;	start_timer(); /*1/100 second*/
; use timer 0
;
start_timer:
	clr	tr0		;stop the timer
	anl	tmod,#0f0h	;zero timer
	orl	tmod,#01h	;set mode 1
	clr	tf0		;clear flag
	mov	th0,#(TICS/256)
	mov	tl0,#(TICS mod 256)
	setb	tr0		;start the timer
	setb	ea
	setb	et0
	sjmp	$
;---------------------------------------------
;	inc_clock();
inc_clock:
	inc	hh	;add one to the hundreds
	cjne	hh,#100,inc_clock_end
	mov	hh,#0
	inc	ss	;add one to the seconds
	cjne	ss,#60,inc_clock_end
	mov	ss,#0
	inc	mm
	cjne	mm,#60,inc_clock_end
	mov	mm,#0
inc_clock_end:
	ret
;---------------------------------------------
;	delay(); /*~100 cycles*/
delay:	mov	r0,#50
	djnz	r0,$
	ret
;---------------------------------------------
;	init_lcd();
init_lcd:
	clr	a
	mov	dptr,#init_table
	clr	P3.4	;control not data
init_lcd_1:
	push	acc
	movc	a,@a+dptr
	setb	P3.5
	call	delay
	mov	P1,a
	call	delay
	clr	P3.5
	call	delay
	pop	acc
	inc	a
	cjne	a,#8,init_lcd_1
	setb	P3.4	;data not control
	ret
init_table:
	db	30h,30h,30h,38h,08h,01h,06h,0ch
;---------------------------------------------
;	put_lcd();
put_lcd:
	setb	P3.5
	call	delay
	mov	P1,a
	call	delay
	clr	P3.5
	call	delay
	ret
	end

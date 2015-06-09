$mod2051
;---------------------------------------------
; store times in binary in registers
;
mm	equ	R2
ss	equ	R3
hh	equ	R4
	cseg
;---------------------------------------------
; put your main function here!
; eg:
;
	org	0h

;	acall	init_lcd
;	mov	a,#'A'
;	acall	put_lcd
;
; or
;
	acall	polling_loop
	jmp	$
;---------------------------------------------
;	zero_clock();
;
zero_clock:
	clr	a
	mov	mm,a
	mov	ss,a
	mov	hh,a
	ret
;---------------------------------------------
;	inc_clock();
;
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
;	display_clock();
;
display_clock:
	mov	a,mm
	acall	put_digits
	mov	a,#':'
	acall	putch
	mov	a,ss
	acall	put_digits
	mov	a,#'.'
	acall	putch
	mov	a,hh
	acall	put_digits
	ret
;
put_digits:
	mov	b,#10
	div	ab
	add	a,#'0'
	acall	putch
	mov	a,b
	add	a,#'0'
	acall	putch
	ret
;---------------------------------------------
;	puts(s);
; r0 points to zero terminated string
; a and r0 are altered by this routine
;
puts:	mov	a,@r0
	jz	puts_end
	acall	putch
	inc	r0
	sjmp	puts
puts_end:
	mov	a,#0dh
	acall	putch
	mov	a,#0ah
	acall	putch
	ret
;---------------------------------------------
;	gets(s);
; r0 points to memory to place string
; nul will be added to string
; CR will terminate string LF are ignored
; a and r0 are altered by this routine
;
gets:	acall	getch
	cjne	a,#0ah,gets_1
	sjmp	gets
gets_1:	cjne	a,#0dh,gets_2
	sjmp	gets_end
gets_2:	mov	@r0,a
	inc	r0
	sjmp	gets
gets_end:
	mov	@r0,#0
	ret
;---------------------------------------------
;	init_rs232();
;
init_rs232:
	anl	tmod,#0fh	;zero timer 1
	orl	tmod,#20h	;set mode 2
	mov	th1,#0fdh	;reload value
	mov	tl1,#0fdh	;initial value
	mov	scon,#50h	;serial mode
	setb	tr1		;start timer1
	ret
;---------------------------------------------
;	init_lcd();
;
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
;	clear_lcd();
clear_lcd:
	clr	P3.4	;swap to control
	mov	a,#01h
	call	put_lcd
	setb	P3.4	;swap back to data
	ret
;---------------------------------------------
;	putch();
;
putch:
	acall	put_rs232
;	acall	put_lcd
	ret
;---------------------------------------------
;	put_rs232();
;
put_rs232:
	mov	sbuf,a
	jnb	ti,$	;wait for it to go
	clr	ti
	ret
;---------------------------------------------
;	put_lcd();
;
put_lcd:
	setb	P3.5
	call	delay
	mov	P1,a
	call	delay
	clr	P3.5
	call	delay
	ret
;---------------------------------------------
;	getch();
;
getch:
	acall	get_rs232
	ret
;---------------------------------------------
;	get_rs232();
;
get_rs232:
	jnb	ri,$
	clr	ri
	mov	a,sbuf
	ret
;---------------------------------------------
;	delay(); /*~100 cycles*/
;
delay:	mov	r0,#50
	djnz	r0,$
	ret
;---------------------------------------------
;	start_timer(); /*1/100 second*/
; use timer 0
TICS	equ	0ffffh-9216
start_timer:
	clr	tr0		;stop the timer
	anl	tmod,#0f0h	;zero timer
	orl	tmod,#01h	;set mode 1
	clr	tf0		;clear flag
	mov	th0,#(TICS/256)
	mov	tl0,#(TICS mod 256)
	setb	tr0		;start the timer
	ret
;---------------------------------------------
; piece of code to increment our clock every
; 1/100 sec and check whether a character
; has arrived at the rs232 interface, - 
; in which case display current clock
; uses polling!
polling_loop:
	acall	init_rs232
	acall	start_timer
check_rs232:
	jnb	ri,check_timer
	acall	getch
	acall	display_clock
	mov	a,#0dh		;carriage return
	acall	putch
check_timer:
	jnb	tf0,check_rs232
	acall	start_timer
	acall	inc_clock
	sjmp	check_rs232
;
	end
	
	
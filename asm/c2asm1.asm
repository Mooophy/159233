$mod2051
;	int i,j,k
;	char c;
;
;either one of these three methods
i1	data	40h
j1	data	41h
k1	data	42h
c1	data	43h
;
	dseg
	org	40h
i2:	ds	1
j2:	ds	1
k2:	ds	1
c2:	ds	1
	cseg
;
i3	equ	R2
j3	equ	R3
k3	equ	R4
c3	equ	R5
i3_	data	2
j3_	data	3
k3_	data	4
c3_	data	5
;---------------------------------------------
;	int i,j,k;
;	char cc;
	dseg
	org	40h
i:	ds	1
j:	ds	1
k:	ds	1
cc:	ds	1
	cseg

	org	0
;---------------------------------------------
;	i = 4;
;	j = 5;
;
	mov	i,#4
	mov	j,#5
;---------------------------------------------
;	i = 0;
;	j = 0;
;	k = 0;
;
	mov	i,#0
	mov	j,#0
	mov	k,#0
; or (better!)
	clr	a
	mov	i,a
	mov	j,a
	mov	k,a
;---------------------------------------------
;	cc = 'A'
;
	mov	cc,#'A'
;---------------------------------------------
;	i++;
;	j--;
;
	inc	i
	dec	j
;---------------------------------------------
;	k = i;
;
	mov	k,i
	mov	k3,i3_		;<-!
;---------------------------------------------
;	k = i + j;
;
	mov	a,i
	add	a,j
	mov	k,a
;---------------------------------------------
;	k = i - j;
;
	mov	a,i
	clr	c
	subb	a,j
	mov	k,a
;---------------------------------------------
;	k = i*j;
;
	mov	a,i
	mov	b,j
	mul	ab
	mov	k,a
;---------------------------------------------
;	k = i/j;
;
	mov	a,i
	mov	b,j
	div	ab
	mov	k,a
;---------------------------------------------
;	k = i%j;
;
	mov	a,i
	mov	b,j
	div	ab
	mov	k,b
;---------------------------------------------
;	cc = cc | 0x20h /*lowercase it*/
;
	orl	cc,#20h
	orl	c3_,#20h		;<-!
;---------------------------------------------
;	cc = cc & 0xdf /*uppercase it*/
;
	anl	cc,#0dfh
	anl	c3_,#0dfh		;<-!
;---------------------------------------------
;	if (i==j) { ... }
;
	mov	a,i
	cjne	a,j,l1
	nop	;...;
l1:
;
	mov	a,i3
	cjne	a,j3_,l1_3		;<-!
	nop	;...;
l1_3:
;---------------------------------------------
;	if (i!=j) {...}
;
	mov	a,i
	cjne	a,j,l2
	sjmp	l3
l2:	nop	;...;
l3:
;---------------------------------------------
;	if ((i!=j) && (i!=5)) {...}
;
	mov	a,i
	cjne	a,j,l5
	sjmp	l7
l5:	cjne	a,#5,l6
	sjmp	l7
l6:	nop	;...;
l7:
;---------------------------------------------
;	if ((i==j) || (i==5)) {...}
;
	mov	a,i
	cjne	a,j,l8
	sjmp	l9
l8:	cjne	a,#5,l10
l9:	nop	;...;
l10:
;---------------------------------------------
;	if (i<10) {...}
;
	mov	a,i
	clr	c
	subb	a,#10
	jnc	l11
	nop	;...;
l11:
;---------------------------------------------
;	for (i=0;i!=10;i++) {...}
;
	mov	i,#0
l12:	mov	a,i
	cjne	a,#10,l13
	sjmp	l14
l13:	nop	;...;
	inc	i
	sjmp	l12
l14:
;
	mov	i3,#0
l12_3:	cjne	i3,#10,l13_3		;<-!
	sjmp	l14_3
l13_3:	nop	;...;
	inc	i3
	sjmp	l12_3
l14_3:	nop
;---------------------------------------------
;	char s[32],t[32];
;
	dseg
s:	ds	32
t:	ds	32
	cseg
;---------------------------------------------
;	strcpy(s,"Peter");
;
	mov	r0,#s
	mov	dptr,#m1
l15:	clr	a
	movc	a,@a+dptr
	mov	@r0,a
	jz	l16
	inc	r0
	inc	dptr
	sjmp	l15
m1:	db	'Peter',0
l16:
;---------------------------------------------
;	strcpy(t,s);
;
	mov	r0,#t
	mov	r1,#s
l17:	mov	a,@r1
	mov	@r0,a
	jz	l18
	inc	r0
	inc	r1
	sjmp	l17
l18:
;---------------------------------------------
;	delay1();	/*delay ~100 cylces*/
;	void delay1(void);
;
	acall	delay1
	sjmp	l19
;
delay1:	mov	r0,#50
	djnz	r0,$
	ret
;
l19:
;---------------------------------------------
;	delay2(50);	/*delay ~2*argument cycles*/
;	void delay2(int);
;
	mov	r0,#50
	acall	delay2
	sjmp	l20
;
delay2:	djnz	r0,$
	ret
;
l20:
;---------------------------------------------
;	i = max(j,k);
;	int max(int,int);
;
	mov	r0,j
	mov	r1,k
	acall	max
	mov	i,a
	sjmp	l22
;
max:	mov	a,r0
	clr	c
	subb	a,r1
	jc	l21
	mov	a,r0
	ret
l21:	mov	a,r1
	ret
;
l22:

	end
	
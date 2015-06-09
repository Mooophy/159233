/* A simple ARM assembler program to draw a rotating cube on the screen
 * calls fb_setbuffer to set the address of the display frame buffer
 * for double buffering.
 * M.Johnson 2010
*/
		.global _start
		.equ	cx,320		@ centre of the
		.equ	cy,240		@ screen (320,240)
		.equ	sz,(120<<16)	@ size of cube

_start:		bl hardware_init	@ initialise the hardware

		ldr r8,=0x07800000	@ frame buffer 0
		ldr r9,=0x07900000	@ frame buffer 1
		adr r10,cube0		@ pointer to cube data
		adr r11,cube1		@ cube data for fb1
		ldr r12,=0x7fff		@ colour

redo:		mov r0,r8		@ fb0
		mov r1,r10		@ cube0
		mov r2,r12		@ colour
		bl cube			@ draw cube0 in fb
		
		bl fb_setbuffer		@ flip the buffer

		mov r0,r9		@ fb1
		mov r1,r11		@ cube1
		mov r2,#0		@ black
		bl cube                 @ undraw cube in fb1

		mov r0,r10		@ update cube0
		mov r1,r11		@ and put in cube1
		bl movecube

		mov r0,r9		@ fb1
		mov r1,r11		@ cube1
		mov r2,r12		@ colour
		bl cube			@ draw cube1 in fb1

		bl fb_setbuffer		@ flip the buffer to fb1
		
		mov r0,r8		@ fb
		mov r1,r10		@ cube0
		mov r2,#0		@ black
		bl cube                 @ undraw cube in fb

		mov r0,r11		@ update cube1
		mov r1,r10		@ and put in cube0
		bl movecube

		b redo			@ do again


movecube:	stmfd sp!,{r0-r8,lr}	@ move the cube
		mov r2,r0
		mov r5,#8		@ 8 points
moveloop:	ldr r3,[r2]		@ load x,y and z coords
		ldr r4,[r2,#4]
		ldr r8,[r2,#8]
		add r6,r3,r4,asr#12	@ x=x+y/4096
		sub r7,r4,r3,asr#12	@ y=y-x/4096
		add r7,r7,r8,asr#13	@ y=y+x/8192
		sub r8,r8,r4,asr#13	@ z=z-y/8192
		add r6,r6,r8,asr#14     @ x=x+z/16384
		sub r8,r8,r3,asr#14     @ z=z-x/16384
		str r6,[r1]		@ store x,y and z coords 
		str r7,[r1,#4]
		str r8,[r1,#8]
		add r2,r2,#12		@ move to next
		add r1,r1,#12		@ point
		subs r5,r5,#1
		bne moveloop
		ldmfd sp!,{r0-r8,pc}		  
		
@ draw a cube in fb given by r0
@ with 8 points pointed to by r1 and colour in r2
 
cube:		stmfd sp!,{r0-r12,lr} 
		mov r8,r1		@ save pointer
		mov r12,r2		@ save colour
		mov r9,#0		@ 8 points
cloop1:		add r10,r9,#1		@ look at other points
cloop2:		eors r5,r9,r10		@ find bit difference
		beq noline		@ don't draw if 0
		sub r1,r5,#1		@ clear single bit
		ands r5,r5,r1		@ using v = v & (v-1)
		bne noline		@ don't draw if more than one bit set

		add r11,r8,r9,lsl#3	@ get address of start coords
		add r11,r11,r9,lsl#2 	@ by multiplying the index by 12
		ldrsh r1,[r11,#2]	@ get top 16 bits of the x coord
		ldrsh r2,[r11,#6]	@ get top 16 bits of the y coord
		ldrsh r3,[r11,#10]	@ get top 16 bits of the z coord
		mul r6,r3,r1		@ adjust perspective
		add r1,r6,asr#9		@ x=x+(z*x/512)
		mul r6,r3,r2
		add r2,r6,asr#9		@ y=y+(z*y/512)

		add r11,r8,r10,lsl#3	@ get address of end coords
		add r11,r11,r10,lsl#2 	@ by multiplying the index by 12
		ldrsh r3,[r11,#2]	@ get top 16 bits of the x coord
		ldrsh r4,[r11,#6]	@ get top 16 bits of the y coord
		ldrsh r5,[r11,#10]	@ get top 16 bits of the z coord
		mul r6,r5,r3		@ adjust perspective
		add r3,r6,asr#9		@ x=x+(z*x/512)
		mul r6,r5,r4
		add r4,r6,asr#9		@ y=y+(z*y/512)
		
		mov r5,r12		@ set colour
		add r1,r1,#cx		@ move to centre
		add r2,r2,#cy
		add r3,r3,#cx
		add r4,r4,#cy
		bl line			@ draw line
noline:		add r10,r10,#1		@ increment end point index
		cmp r10,#8		@ while != 8
		bne cloop2
		add r9,r9,#1		@ increment start point index
		cmp r9,#7		@ while != 7
		bne cloop1
		ldmfd sp!,{r0-r12,pc}

cube0:		.word -sz,-sz,-sz	@ cube starting position
		.word -sz,-sz,sz
		.word -sz,+sz,-sz
		.word -sz,+sz,sz
		.word +sz,-sz,-sz 
		.word +sz,-sz,sz
		.word +sz,sz,-sz
		.word +sz,sz,sz
cube1:		.space 8*12		@ space for other cube


@ draw line in fb at r0 from (r1,r2) to (r3,r4) with colour r5
line:		@ unfinished..................
		mov pc,lr

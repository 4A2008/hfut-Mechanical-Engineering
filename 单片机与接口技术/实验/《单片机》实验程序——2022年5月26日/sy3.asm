;**************************************************************
;	程序名称:频率计(P3.5计数  1秒处理一次)
;***************************************************************	              
Count50ms	DATA	30H
PulseCount	DATA	31H		;脉冲计数第三个字节
buffer		DATA	32H		;8个字节显示缓冲区
EXTRN		CODE(Display8)

		ORG	0000H	
		LJMP	SUN

		ORG	000BH		;T0计时中断处理入口
		LJMP	TimerT0

		ORG	001BH		;T1计数中断处理入口
		LJMP	CounterT1

		ORG	0100H
SUN:		MOV	SP,#60H
	 	MOV	TMOD,#01010001B	;T0定时，T1计数方式1
	 	MOV	TH0,#4CH	;50ms定时
	 	MOV	TL0,#00H	 	
	 	MOV	Count50ms,#20	;20 * 50ms = 1s
	 	MOV	TH1,#00H	;计数
	 	MOV	TL1,#00H
	 	MOV	PulseCount,#0
	 	SETB	EA
	 	SETB	ET1
	 	SETB	ET0
	 	SETB	TR0
	 	SETB	TR1
SUN1:	 	JB	TR0,$
	 	SETB	TR0		;刷新显示
	 	SETB	TR1
	 	
		ACALL	B4toD4
Display:	MOV	R0,#buffer		;显示结果
		MOV	A,R7			;低位
		ACALL	B1toB2			;压缩BCD码转换成非压缩BCD码
		MOV	A,R6
		ACALL	B1toB2
		MOV	A,R5
		ACALL	B1toB2
		MOV	A,R4			;高位
		ACALL	B1toB2
		MOV	R0,#buffer+7
		MOV	R7,#7
		ACALL	BlackDisplay		;将高位0消隐
		MOV	R0,#buffer
		LCALL	Display8
		
		SJMP	SUN1
	 	
TimerT0:	MOV	TH0,#4CH		;50ms定时
	 	MOV	TL0,#00H	 	
		DJNZ	Count50ms,TimerT0_exit
		MOV	Count50ms,#20
		CLR	TR0
		CLR	TR1
		MOV	R1,PulseCount
		MOV	R2,TH1
		MOV	R3,TL1
		MOV	PulseCount,#0
		MOV	TH1,#0
		MOV	TL1,#0
TimerT0_exit:	RETI

CounterT1:	INC	PulseCount
		RETI	
									
;字节二进制数转十进制数
;R1R2R3为二进制数，R4R5R6R7为压缩BCD码
B4toD4:		CLR	A
		MOV	R4,A
		MOV	R5,A
		MOV	R6,A
		MOV	R7,A
		MOV	B,#24
LOOP:		CLR	C
		MOV	A,R3
		RLC	A
		MOV	R3,A
		MOV	A,R2
		RLC	A
		MOV	R2,A
		MOV	A,R1
		RLC	A
		MOV	R1,A
		MOV	A,R7
		ADDC	A,R7
		DA	A
		MOV	R7,A
		MOV	A,R6
		ADDC	A,R6
		DA	A
		MOV	R6,A
		MOV	A,R5
		ADDC	A,R5
		DA	A
		MOV	R5,A
		MOV	A,R4
		ADDC	A,R4
		DA	A
		MOV	R4,A
		DJNZ	B,LOOP
		RET

;将一个字节压缩BCD码转换成二个字节非压缩BCD码
B1toB2:		PUSH	ACC
		ANL	A,#0FH
		MOV	@R0,A
		INC	R0
		POP	ACC
		ANL	A,#0F0H
		SWAP	A
		MOV	@R0,A
		INC	R0
		RET

BlackDisplay:	MOV	A,@R0		;将高位0消隐
		JNZ	Exit
		MOV	A,#10H
		MOV	@R0,A
		DEC	R0
		DJNZ	R7,BlackDisplay
Exit:		RET

		END	

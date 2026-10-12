EXTRN	    CODE(Display8)
Addr_0809   XDATA	0F000H	
buffer	    DATA	30H	;8个字节的显示缓冲区
EOC_0809    BIT 	P1.2
	
	ORG	0000H	
	LJMP	SUNT
	
	ORG	0100H	
SUNT:	MOV	SP,#60H	;设堆栈
SUNT1:	ACALL	AD0809	
	ACALL	Display_Data	
	MOV	R0,#Buffer	;显示缓冲区首地址
	LCALL	DisPlay8	;调用显示子程序
	LCALL	TIME	;延时	
	SJMP	SUNT1	
	
Display_Data:	MOV	B,A	
	ANL	A,#0FH	
	MOV	buffer+4,A	
	MOV	A,B	
	ANL	A,#0F0H	
	SWAP	A	
	MOV	buffer+5,A	
	MOV		A,B	
	MOV	B,#51	;255/5 (16进制的1 = 1/51V)
	DIV		AB	
	ORL		A,#80H	;加上小数点
	MOV	buffer+2,A	
	ACALL	Display_Data_1	
	MOV	buffer+1,A	;第一位小数
	ACALL	Display_Data_1	
	MOV	buffer,A	;第二位小数
	MOV	buffer+3,#10H	
	MOV	buffer+6,#10H	
	MOV	buffer+7,#10H	;消隐
	RET
	
Display_Data_1:	MOV	A,#10	
	MUL	AB	
	ADD	A,B	
	JNC	Display_Data_11	
	INC	A	
	INC	B
	
Display_Data_11:MOV	R7,A	
	MOV	A,B	
	RL	A	
	RL	A	
	ADD	A,B	
	XCH	A,R7	
	MOV	B,#51	
	DIV	AB	
	ADD	A,R7	
	RET
		
AD0809:	MOV	A,#0	
	MOV	DPTR,#Addr_0809	
	MOVX	@DPTR,A		;启动AD转换
	JNB	EOC_0809,$	;是否转换完成
	MOVX	A,@DPTR		;读转换结果
	RET
		
TIME:	PUSH	06H	
	PUSH	07H	
	MOV	R6,#200	
TIME1S1:MOV	R7,#200	
	DJNZ	R7,$	
	DJNZ	R6,TIME1S1	
	POP	07H	
	POP	06H	
	RET
		
	END		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CHECK_VALID

	.ORIG X3000

	GETC

	LEA	R3, ROW1
	LD	R1, ASCII_1
	ADD	R2, R0, R1
	BRz	MATCH1
	LD	R1, ASCII_2
	ADD	R2, R0, R1
	BRz	MATCH2
	LD	R1, ASCII_3
	ADD	R2, R0, R1
	BRz	MATCH3
	LD	R1, ASCII_4
	ADD	R2, R0, R1
	BRz	MATCH4
	LD	R1, ASCII_5
	ADD	R2, R0, R1
	BRz	MATCH5
	LD	R1, ASCII_6
	ADD	R2, R0, R1
	BRz	MATCH6

	BR	NOMATCH


MATCH1	LDR	R4, R3, #0
	BRpn	
	AND	R6, R6, #0
	ADD	R6, R6, #1
	BR	DONE
MATCH2	LDR	R4, R3, #1
	AND	R6, R6, #0
	ADD	R6, R6, #2
	BR	DONE
MATCH3
	AND	R6, R6, #0
	ADD	R6, R6, #3
	BR	DONE
MATCH4
	AND	R6, R6, #0
	ADD	R6, R6, #4
	BR	DONE
MATCH5
	AND	R6, R6, #0
	ADD	R6, R6, #5
	BR	DONE
MATCH6
	AND	R6, R6, #0
	ADD	R6, R6, #6
	BR	DONE

NOMATCH	AND	R6, R6, #0
	
DONE
	HALT;RET

;NEG
ASCII_1		.FILL xFFCF
ASCII_2		.FILL xFFCE
ASCII_3		.FILL xFFCD
ASCII_4		.FILL xFFCC
ASCII_5		.FILL xFFCB
ASCII_6		.FILL xFFCA
	
	.END
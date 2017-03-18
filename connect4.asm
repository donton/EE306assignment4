;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	description: 	Connect 4 game!				;
;			EE 306 - Spring 2015			;
;			Programming Assignment #4 		;
; 								;
;	file:		connect4.asm				;
;	author:		Birgi Tamersoy				;
;	date:		04/09/2013				;
;		update:	04/10/2013 -> finished & tested.	;
;		update: 04/12/2013 -> re-arranged for students.	;
;				   -> added 2nd dia. check.	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x3000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Main Program						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR INIT
ROUND
	JSR DISPLAY_BOARD	;;;;;
	JSR GET_MOVE
	JSR UPDATE_BOARD
	JSR UPDATE_STATE

	ADD R6, R6, #0
	BRz ROUND

	JSR DISPLAY_BOARD	;;;;;
	JSR GAME_OVER		;;;;;

	HALT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Functions & Constants!!!				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_TURN						;
;	description:	Displays the appropriate prompt.	;
;	inputs:		None!					;
;	outputs:	None!					;
;	assumptions:	TURN is set appropriately!		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_TURN
	ST R0, DT_R0
	ST R7, DT_R7

	LD R0, TURN
	ADD R0, R0, #-1
	BRp DT_P2
	LEA R0, DT_P1_PROMPT
	PUTS
	BRnzp DT_DONE
DT_P2
	LEA R0, DT_P2_PROMPT
	PUTS

DT_DONE

	LD R0, DT_R0
	LD R7, DT_R7

	RET
DT_P1_PROMPT	.stringz 	"Player 1, choose a column: "
DT_P2_PROMPT	.stringz	"Player 2, choose a column: "
DT_R0		.blkw	1
DT_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GET_MOVE						;
;	description:	gets a column from the user.		;
;			also checks whether the move is valid,	;
;			or not, by calling the CHECK_VALID 	;
;			subroutine!				;
;	inputs:		None!					;
;	outputs:	R6 has the user entered column number!	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GET_MOVE
	ST R0, GM_R0
	ST R7, GM_R7

GM_REPEAT
	JSR DISPLAY_TURN
	GETC
	OUT
	JSR CHECK_VALID			;;;;
	LD R0, ASCII_NEWLINE
	OUT

	ADD R6, R6, #0
	BRp GM_VALID

	LEA R0, GM_INVALID_PROMPT
	PUTS
	LD R0, ASCII_NEWLINE
	OUT
	BRnzp GM_REPEAT

GM_VALID

	LD R0, GM_R0
	LD R7, GM_R7

	RET
GM_INVALID_PROMPT 	.stringz "Invalid move. Try again."
GM_R0			.blkw	1
GM_R7			.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_BOARD						;
;	description:	updates the game board with the last 	;
;			move!					;
;	inputs:		R6 has the column for last move.	;
;	outputs:	R5 has the row for last move.		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_BOARD
	ST R1, UP_R1
	ST R2, UP_R2
	ST R3, UP_R3
	ST R4, UP_R4
	ST R6, UP_R6
	ST R7, UP_R7

	; clear R5
	AND R5, R5, #0
	ADD R5, R5, #6

	LEA R4, ROW6
	
UB_NEXT_LEVEL
	ADD R3, R4, R6

	LDR R1, R3, #-1
	LD R2, ASCII_NEGHYP

	ADD R1, R1, R2
	BRz UB_LEVEL_FOUND

	ADD R4, R4, #-7
	ADD R5, R5, #-1
	BRnzp UB_NEXT_LEVEL

UB_LEVEL_FOUND
	LD R4, TURN
	ADD R4, R4, #-1
	BRp UB_P2

	LD R4, ASCII_O
	STR R4, R3, #-1

	BRnzp UB_DONE
UB_P2
	LD R4, ASCII_X
	STR R4, R3, #-1

UB_DONE		

	LD R1, UP_R1
	LD R2, UP_R2
	LD R3, UP_R3
	LD R4, UP_R4
	LD R6, UP_R6
	LD R7, UP_R7

	RET
ASCII_X	.fill	x0058
ASCII_O	.fill	x004f
UP_R1	.blkw	1
UP_R2	.blkw	1
UP_R3	.blkw	1
UP_R4	.blkw	1
UP_R5	.blkw	1
UP_R6	.blkw	1
UP_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHANGE_TURN						;
;	description:	changes the turn by updating TURN!	;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHANGE_TURN
	ST R0, CT_R0
	ST R1, CT_R1
	ST R7, CT_R7

	LD R0, TURN
	ADD R1, R0, #-1
	BRz CT_TURN_P2

	ST R1, TURN
	BRnzp CT_DONE

CT_TURN_P2
	ADD R0, R0, #1
	ST R0, TURN

CT_DONE
	LD R0, CT_R0
	LD R1, CT_R1
	LD R7, CT_R7

	RET
CT_R0	.blkw	1
CT_R1	.blkw	1
CT_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_WINNER						;
;	description:	checks if the last move resulted in a	;
;			win or not!				;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_WINNER
	ST R5, CW_R5
	ST R6, CW_R6
	ST R7, CW_R7

	AND R4, R4, #0
	
	JSR CHECK_HORIZONTAL		;;;;
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_VERTICAL		;;;;
	ADD R4, R4, #0
	BRp CW_DONE

	JSR CHECK_DIAGONALS		;;;;
	
CW_DONE

	LD R5, CW_R5
	LD R6, CW_R6
	LD R7, CW_R7

	RET
CW_R5	.blkw	1
CW_R6	.blkw	1
CW_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	UPDATE_STATE						;
;	description:	updates the state of the game by 	;
;			checking the board. i.e. tries to figure;
;			out whether the last move ended the game;
; 			or not! if not updates the TURN! also	;
;			updates the WINNER if there is a winner!;
;	inputs:		R6 has the column of last move.		;
;			R5 has the row of last move.		;
;	outputs:	R6 has  1, if the game is over,		;
;				0, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UPDATE_STATE
	ST R0, US_R0
	ST R1, US_R1
	ST R4, US_R4
	ST R7, US_R7
	
	; checking if the last move resulted in a win or not!
	JSR CHECK_WINNER
	
	ADD R4, R4, #0
	BRp US_OVER
	
	; checking if the board is full or not!
	AND R6, R6, #0
		
	LD R0, NBR_FILLED
	ADD R0, R0, #1
	ST R0, NBR_FILLED

	LD R1, MAX_FILLED
	ADD R1, R0, R1
	BRz US_TIE

US_NOT_OVER
	JSR CHANGE_TURN
	BRnzp US_DONE

US_OVER
	ADD R6, R6, #1
	LD R0, TURN
	ST R0, WINNER
	BRnzp US_DONE

US_TIE
	ADD R6, R6, #1

US_DONE
	LD R0, US_R0
	LD R1, US_R1
	LD R4, US_R4
	LD R7, US_R7

	RET
NBR_FILLED	.fill	#0
MAX_FILLED	.fill	#-36
US_R0		.blkw	1
US_R1		.blkw	1
US_R4		.blkw	1
US_R7		.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	INIT							;
;	description:	simply sets the BOARD_PTR appropriately!;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT
	ST R0, I_R0
	ST R7, I_R7

	LEA R0, ROW1
	ST R0, BOARD_PTR

	LD R0, I_R0
	LD R7, I_R7

	RET
I_R0	.blkw	1
I_R7	.blkw	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Global Constants!!!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCII_SPACE	.fill		x0020				;
ASCII_NEWLINE	.fill		x000A				;
TURN		.fill		1				;
WINNER		.fill		0				;
								;
ASCII_OFFSET	.fill		x-0030				;
ASCII_NEGONE	.fill		x-0031				;
ASCII_NEGSIX	.fill		x-0036				;
ASCII_NEGHYP	.fill	 	x-002d				;
								;
ROW1		.stringz	"------"			;
ROW2		.stringz	"------"			;
ROW3		.stringz	"------"			;
ROW4		.stringz	"------"			;
ROW5		.stringz	"------"			;
ROW6		.stringz	"------"			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;DO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;NOT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;CHANGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ANYTHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;ABOVE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;THIS!!!;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	DISPLAY_BOARD						;
;	description:	Displays the board.			;
;	inputs:		None!					;
;	outputs:	None!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISPLAY_BOARD
	
	ST	R0, DB_R0
	ST	R1, DB_R1
	ST	R2, DB_R2
	ST	R7, DB_R7

	LEA	R1, ROW1
LOOP1	LDR	R0, R1, #0
	BRz	NULL1	
	OUT
	LDR	R0, R1, #1
	BRz	LOOP11
	LD	R0, SPACE
	OUT
LOOP11	ADD	R1, R1, #1
	BR	LOOP1

NULL1	LD	R0, ENTER
	OUT
	LEA	R1, ROW2
LOOP2	LDR	R0, R1, #0
	BRz	NULL2
	OUT
	LDR	R0, R1, #1
	BRz	LOOP12
	LD	R0, SPACE
	OUT

LOOP12	ADD	R1, R1, #1
	BR	LOOP2


NULL2	LD	R0, ENTER
	OUT
	LEA	R1, ROW3
LOOP3	LDR	R0, R1, #0
	BRz	NULL3
	OUT
	LDR	R0, R1, #1
	BRz	LOOP13
	LD	R0, SPACE
	OUT
LOOP13	ADD	R1, R1, #1
	BR	LOOP3

NULL3	LD	R0, ENTER
	OUT
	LEA	R1, ROW4
LOOP4	LDR	R0, R1, #0
	BRz	NULL4
	OUT
	LDR	R0, R1, #1
	BRz	LOOP14
	LD	R0, SPACE
	OUT
LOOP14	ADD	R1, R1, #1
	BR	LOOP4

NULL4	LD	R0, ENTER
	OUT
	LEA	R1, ROW5
LOOP5	LDR	R0, R1, #0
	BRz	NULL5
	OUT
	LDR	R0, R1, #1
	BRz	LOOP15
	LD	R0, SPACE
	OUT
LOOP15	ADD	R1, R1, #1
	BR	LOOP5

NULL5	LD	R0, ENTER
	OUT
	LEA	R1, ROW6
LOOP6	LDR	R0, R1, #0
	BRz	NULL6
	OUT
	LDR	R0, R1, #1
	BRz	LOOP16
	LD	R0, SPACE
	OUT
LOOP16	ADD	R1, R1, #1
	BR	LOOP6

NULL6	LD	R0, ENTER
	OUT
	LD	R0, DB_R0
	LD	R1, DB_R1
	LD	R7, DB_R7

	RET

ENTER	.FILL	x0A
SPACE	.FILL	X20
DB_R0	.BLKW	1
DB_R1	.BLKW	1
DB_R2	.BLKW	1
DB_R7	.BLKW	1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VALID						;
;	description:	checks whether a move is valid or not!	;
;	inputs:		R0 has the ASCII value of the move!	;
;	outputs:	R6 has:	0, if invalid move,		;
;				decimal col. val., if valid.    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VALID

	ST	R0, CV_R0
	ST	R1, CV_R0
	ST	R2, CV_R0
	ST	R3, CV_R0
	ST	R4, CV_R0
	ST	R5, CV_R0
	ST	R7, CV_R0

	LEA	R3, ROW1
	LD	R5, UNDERSCR
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
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #1
	BR	DONE
MATCH2	LDR	R4, R3, #1
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #2
	BR	DONE
MATCH3	LDR	R4, R3, #2
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #3
	BR	DONE
MATCH4	LDR	R4, R3, #3
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #4
	BR	DONE
MATCH5	LDR	R4, R3, #4
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #5
	BR	DONE
MATCH6	LDR	R4, R3, #5
	ADD	R2, R4, R5
	BRnp	NOMATCH
	AND	R6, R6, #0
	ADD	R6, R6, #6
	BR	DONE

NOMATCH	AND	R6, R6, #0
	
DONE	LD	R0, CV_R0
	LD	R1, CV_R0
	LD	R2, CV_R0
	LD	R3, CV_R0
	LD	R4, CV_R0
	LD	R5, CV_R0
	LD	R7, CV_R0

	RET

;NEG
UNDERSCR	.FILL xFFD3
ASCII_1		.FILL xFFCF
ASCII_2		.FILL xFFCE
ASCII_3		.FILL xFFCD
ASCII_4		.FILL xFFCC
ASCII_5		.FILL xFFCB
ASCII_6		.FILL xFFCA
CV_R0		.BLKW	1
CV_R1		.BLKW	1	
CV_R2		.BLKW	1
CV_R3		.BLKW	1	
CV_R4		.BLKW	1
CV_R5		.BLKW	1	
CV_R7		.BLKW	1	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;USE THE FOLLOWING TO ACCESS THE BOARD!!!;;;;;;;;;;;;;;;;;;
;;;;;IT POINTS TO THE FIRST ELEMENT OF ROW1 (TOP-MOST ROW)!!!;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOARD_PTR	.blkw	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_HORIZONTAL					;
;	description:	horizontal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GETWINNER	
	LD	R0, WINNER
	RET

GETPTR
	LD	R4, BOARD_PTR
	RET

CHECK_HORIZONTAL

	AND	R0, R0, #0
	ADD	R0, R0, #-1
	ADD	R0, R5, R0
	BRz	ROW_1
	AND	R0, R0, #0
	ADD	R0, R0, #-2
	ADD	R0, R5, R0
	BRz	ROW_2
	AND	R0, R0, #0
	ADD	R0, R0, #-3
	ADD	R0, R5, R0
	BRz	ROW_3
	AND	R0, R0, #0
	ADD	R0, R0, #-4
	ADD	R0, R5, R0
	BRz	ROW_4
	AND	R0, R0, #0
	ADD	R0, R0, #-5
	ADD	R0, R5, R0
	BRz	ROW_5
	AND	R0, R0, #0
	ADD	R0, R0, #-6
	ADD	R0, R5, R0
	BRz	ROW_6

ROW_1
	LD 	R0, BOARD_PTR
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY12
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY13
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY14
	BR	WINNERR

TRY12	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY13	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY14	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

ROW_2
	LD 	R0, BOARD_PTR
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY22
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY23
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY24
	BR	WINNERR

TRY22	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY23	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY24	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

ROW_3
	LD 	R0, BOARD_PTR
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY32
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY33
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY34
	BR	WINNERR

TRY32	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY33	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY34	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

ROW_4	
	LD 	R0, BOARD_PTR
	ADD	R0, R0, #7
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY42
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY43
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY44
	BR	WINNERR

TRY42	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY43	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY44	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

ROW_5
	LD 	R0, BOARD_PTR
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY52
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY53
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY54
	BR	WINNERR

TRY52	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY53	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY54	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

ROW_6
	LD 	R0, BOARD_PTR
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	LDR	R2, R0, #1
	ADD	R1, R3, R2
	BRnp	TRY62
	LDR	R2, R0, #2
	ADD	R1, R3, R2
	BRnp	TRY63
	LDR	R2, R0, #3
	ADD	R1, R3, R2
	BRnp	TRY64
	BR	WINNERR

TRY62	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-3
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY63	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	LDR	R2, R0, #-2
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR
TRY64	LDR	R2, R0, #-1
	ADD	R1, R3, R2
	BRnp	NOWINNER
	BR	WINNERR

WINNERR	AND	R4, R4, #0
	ADD	R4, R4, #1	
	BR	CH_DONE
		
NOWINNER
	AND	R4, R4, #0	
CH_DONE
	RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	GAME_OVER						;
;	description:	checks WINNER and outputs the proper	;
;			message!				;
;	inputs:		none!					;
;	outputs:	none!					;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GAME_OVER
    
	ST	R7, GO_R7
	JSR	GETWINNER
	ADD	R0, R0, #0
	BRz	TIEE
	
	AND	R1, R1, #0
	ADD	R2, R1, #-1

	ADD	R1, R0, R2
	BRZ	PLR1WINS

	LEA	R0, PLAYER2WINS
	PUTS
	BR	WOOT

PLR1WINS
	LEA	R0, PLAYER1WINS
	PUTS
	BR	WOOT

TIEE
	LEA	R0, TIEGAME
	PUTS
	
WOOT	LD	R7, GO_R7
	RET

GO_R7		.BLKW		1
TIEGAME		.STRINGZ	"Tie Game."
PLAYER1WINS	.STRINGZ	"Player 1 Wins."
PLAYER2WINS	.STRINGZ	"Player 2 Wins."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_VERTICAL						;
;	description:	vertical check.				;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_VERTICAL

	ST	R7, VERT_R7
	JSR	GETPTR

	AND	R0, R0, #0
	AND	R1, R0, #0
	ADD	R1, R1, #-1
	ADD	R1, R5, R1
	BRz	ROW_V1
	AND	R1, R1, #0
	ADD	R1, R1, #-2
	ADD	R1, R5, R1
	BRz	ROW_V2
	AND	R1, R1, #0
	ADD	R1, R1, #-3
	ADD	R1, R5, R1
	BRz	ROW_V3
	AND	R1, R1, #0
	ADD	R1, R1, #-4
	ADD	R1, R5, R1
	BRz	NOVERT
	AND	R1, R1, #0
	ADD	R1, R1, #-5
	ADD	R1, R5, R1
	BRz	NOVERT
	AND	R1, R1, #0
	ADD	R1, R1, #-6
	ADD	R1, R5, R1
	BRz	NOVERT

ROW_V1	ADD	R0, R4, #0
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O
	
	ADD	R0, R4, #0
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT

	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	
	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	BR	VERT


ROW_V2
	ADD	R0, R4, #0
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O
	
	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT

	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	
	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	BR	VERT	

ROW_V3
	ADD	R0, R4, #0
	ADD	R0, R0, R6
	ADD	R0, R0, #14
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O
	
	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT

	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	
	ADD	R0, R4, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	LDR	R1, R0, #0
	ADD	R2, R1, R3
	BRnp	NOVERT
	BR	VERT

VERT	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	VERTDONE

NOVERT	AND 	R4, R4, #0

VERTDONE
	
	LD	R7, VERT_R7
	RET

VERT_R7	.BLKW	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_DIAGONALS						;
;	description:	checks diagonals by calling 		;
;			CHECK_D1 & CHECK_D2.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_DIAGONALS

	ST	R7, CHD_R7
	JSR	GETPTR
	ADD	R7, R4, #0
	
	AND	R1, R0, #0
	ADD	R1, R1, #-1
	ADD	R1, R5, R1
	BRz	ROW_CD1
	AND	R1, R1, #0
	ADD	R1, R1, #-2
	ADD	R1, R5, R1
	BRz	ROW_CD2
	AND	R1, R1, #0
	ADD	R1, R1, #-3
	ADD	R1, R5, R1
	BRz	ROW_CD3
	AND	R1, R1, #0
	ADD	R1, R1, #-4
	ADD	R1, R5, R1
	BRz	ROW_CD4
	AND	R1, R1, #0
	ADD	R1, R1, #-5
	ADD	R1, R5, R1
	BRz	ROW_CD5
	AND	R1, R1, #0
	ADD	R1, R1, #-6
	ADD	R1, R5, R1
	BRz	ROW_CD6

ROW_CD1
	ADD	R0, R7, #0
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

ROW_CD2
	ADD	R0, R7, #0
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

ROW_CD3
	ADD	R0, R7, #0
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

ROW_CD4
	ADD	R0, R7, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

ROW_CD5
	ADD	R0, R7, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

ROW_CD6
	ADD	R0, R7, #0
	ADD	R0, R0, #14
	ADD	R0, R0, #14
	ADD	R0, R0, #7
	ADD	R0, R0, R6
	ADD	R0, R0, #-1
	ADD	R5, R0, #0
	LDR	R1, R0, #0
	NOT	R3, R1
	ADD	R3, R3, #1 ; NEG OF X OR O

	JSR	CHECK_D1
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	JSR	CHECK_D2
	ADD	R4, R4, #0
	BRnp	DIAGMATCH

	AND 	R4, R4, #0
	BR	DIAGDONE

DIAGMATCH	
	AND 	R4, R4, #0
	ADD	R4, R4, #1

DIAGDONE
	LD	R7, CHD_R7

	RET

CHD_R7		.BLKW 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D1						;
;	description:	1st diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D1	

	ST	R7, CHD1_R7
	JSR	GETPTR
	ADD	R7, R4, #0

	ADD	R0, R5, #-6	; OFFSET
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C1T1
	ADD	R0, R5, #-12	; OFFSET
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C1T2
	ADD	R6, R5, #-12	; OFFSET
	ADD	R0, R6, #-6
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C1T3

C1T1	
	ADD	R0, R5, #6
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE
	ADD	R0, R5, #12
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE
	ADD	R6, R5, #12
	ADD	R0, R6, #6
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE
	
	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	WHOOP

C1T2
	ADD	R0, R5, #6
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE
	ADD	R0, R5, #12
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE
	
	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	WHOOP

C1T3	
	ADD	R0, R5, #6
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NOPE

	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	WHOOP

NOPE	AND	R4, R4, #0

WHOOP	LD	R7, CHD1_R7
	RET

CHD1_R7		.BLKW	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	CHECK_D2						;
;	description:	2nd diagonal check.			;
;	inputs:		R6 has the column of the last move.	;
;			R5 has the row of the last move.	;
;	outputs:	R4 has  0, if not winning move,		;
;				1, otherwise.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHECK_D2	
	ST	R7, CHD2_R7
	JSR	GETPTR
	ADD	R7, R4, #0

	ADD	R0, R5, #-8	; OFFSET
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C2T1
	ADD	R6, R5, #-8	; OFFSET
	ADD	R0, R6, #-8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C2T2
	ADD	R6, R5, #-8	; OFFSET
	ADD	R6, R6, #-8
	ADD	R0, R6, #-8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	C2T3

C2T1	
	ADD	R0, R5, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH
	ADD	R6, R5, #8
	ADD	R0, R6, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH
	ADD	R6, R5, #8
	ADD	R6, R6, #8
	ADD	R0, R6, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH
	
	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	YAS

C2T2
	ADD	R0, R5, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH
	ADD	R6, R5, #8
	ADD	R0, R6, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH
	
	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	YAS

C2T3	
	ADD	R0, R5, #8
	LDR	R1, R0, #0
	ADD	R2, R3, R1
	BRnp	NAH

	AND	R4, R4, #0
	ADD	R4, R4, #1
	BR	YAS

NAH	AND	R4, R4, #0

YAS	LD	R7, CHD2_R7
	RET

CHD2_R7		.BLKW	1
.END
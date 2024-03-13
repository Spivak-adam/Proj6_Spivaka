TITLE Low level I/O Procedures    (Proj6_Spivaka.asm)
; Author: Adam Spivak
; Last Modified: 3-17-24
; OSU email address: Spivaka@oregonstate.edu
; Course number/section: CS271 Section 271
; Project Number: 6           Due Date: 3-17-24
; Description: A program that demonstrates the understanding of Lower level programming. The program asks a user to enter 10 integers that
; can fit into a 32 bit register. It then prints out the 10 numbers, the sum of those numbers, and the truncated average. When the numbers are
; entered they are taken in as a string and translated from their ASCII strings into regular numbers by subtracting from their respective ASCII positions.
; It will chech for sign idications such as (e.g. "+", "-") and a decimal points for FPUs. It will also validate that the values entered are not letters
; by checking for nubmers within a specific range.

INCLUDE Irvine32.inc

; (insert constant definitions here)

;-----------------------------------------------------------------------------------------------------------
; Name: mGetstring
; Description: A macro that recieves three parameters and gets numbers from user, then sends that number back to Called PRROC
; Preconditions: Called from ReadVal procedure
; Postcondition: Sends numbers back to a called procedure
; Recieves:
;		promptUser	- message to prompt user to enter numbers
;		storeNum	- parameter by reference to store value
;		byteLength	- the length a number can be to fit into a 32 bit register
; Return:
;-----------------------------------------------------------------------------------------------------------
mGetstring MACRO promptUser, storeNum, byteLength
	PUSH EDX
	PUSH EAX
	PUSH ECX

_enter_Num:
	MOVE EDX, promptUser
	print_Text

	CALL ReadString
	MOVE ECX, 4
	MOVE storeNum, EDX
	
	CMP EAX, byteLength
	JE _valid_num_size
	JA _enter_Num

_valid_num_size:

ENDM

;-----------------------------------------------------------------------------------------------------------
; Name: mDisplayString
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
mDisplayString MACRO

ENDM

.data
intro_display			BYTE	"Programming assignment 6: Designing low-level I/O procedures",10,
								"Written by: Adam Spivak",0
prompt_user				BYTE	"Please enter number"

print_Text				EQU		<CALL WriteString>
new_Line				EQU		<CALL CrLf>
MOVE					TEXTEQU <MOV>					; Turns MOV into MOVE to help with text alignment with PUSH

.code
;-----------------------------------------------------------------------------------------------------------
; Name: main
; Description:

; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
main PROC

	CALL ReadVal

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------------------------
; Name:
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
ReadVal PROC
PUSH EBP
MOVE EBP, ESP

	CALL mGetString

POP EBP
RET
ReadVal ENDP

;-----------------------------------------------------------------------------------------------------------
; Name:
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
ReadFloatVal PROC
PUSH EBP
MOVE EBP, ESP



POP EBP
RET
ReadFloatVal ENDP

;-----------------------------------------------------------------------------------------------------------
; Name:
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
WriteFloatVal PROC
PUSH EBP
MOVE EBP, ESP



POP EBP
RET
WriteFloatVal ENDP

END main

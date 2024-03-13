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

ARRAYSIZE = 10
STRINGLEN = 4

;-----------------------------------------------------------------------------------------------------------
; Name: mGetstring
; Description: A macro that recieves three parameters and gets numbers from user, then sends that number back to Called PRROC
; Preconditions: Called from ReadVal procedure
; Postcondition: Sends numbers back to a called procedure
; Recieves:
;		promptUser	- message to prompt user to enter numbers
;		storeNum	- parameter by reference to store value
;		byteLength	- the length a number can be to fit into a 32 bit register
;		bytesRead	- numbers of bytes entered by user (length of string)
; Return:
;-----------------------------------------------------------------------------------------------------------
mGetstring MACRO promptUser, storeNum, byteLength

.code
	PUSH EDX
	PUSH ECX

	MOVE EDX, promptUser
	MOVE ECX, byteLength
	print_Text

	MOVE EDX, storeNum
	CALL ReadString
	MOVE storeNum, EDX

	POP ECX
	POP EDX

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
intro_Display			BYTE	"Programming assignment 6: Designing low-level I/O procedures",10,
								"Written by: Adam Spivak",0
user_Instructions		BYTE	"Please provide 10 signed decimal integers.",10,
								"Each number needs to be small enough to fit inside a 32 bit register. After you have finished",10,
								"inputting the raw numbers I will display a list of the integers, their sum, and their average value",0
prompt_User				BYTE	"Please enter a signed number: ",0
error_Message			BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
plus_symbol				BYTE	"+",0
minus_symbol			BYTE	"-",0
decimal_symbol			BYTE	".",0

store_Num				BYTE	STRINGLEN DUP(0)	; STRINGLEN (4) * BYTE = 32 bits
byte_string_len			DWORD	6					; 4 DWORDS = 32 bits. byte_string_len is at 6 (5 char + 0 null) to check if a string entered is > 4 DWORDs
num_List				DWORD	ARRAYSIZE DUP(?)

num_of_entries			DWORD	?
running_subtotal		SDWORD	?

print_Text				EQU		<CALL WriteString>
new_Line				EQU		<CALL CrLf>
MOVE					TEXTEQU <MOV>				; Turns MOV into MOVE to help with text alignment with PUSH

.code
;-----------------------------------------------------------------------------------------------------------
; Name: main
; Description: Controls the rest of program by calling readVal 10 times with a LOOP statement to get 10 integers.
; Once 10 integers have been recieved it will then use writeVal to print out the list of integers, their sum, and the truncated average.
; Once the process for the 10 integers is over it will the same thing for 10 FPU numbers.
; Preconditions: No numbers entered, and all initialized variables are empty
; Postcondition: All variables related to 10 integers and 10 FPUs are filled and have values in them
; Recieves: Global variables
; Return: None
;-----------------------------------------------------------------------------------------------------------
main PROC

	MOVE ECX, ARRAYSIZE
_enter_Num_Loop:
	MOVE EDX, OFFSET prompt_User
	PUSH EDX
	MOVE EDX, OFFSET store_Num
	PUSH EDX
	MOVE EAX, byte_string_len
	PUSH EAX
	MOVE EDX, OFFSET error_Message
	PUSH EDX
	MOVE EDI, OFFSET num_List
	PUSH EDI
	CALL ReadVal
	ADD  EDI, TYPE num_List

	LOOP _enter_Num_Loop

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------------------------
; Name: ReadVal
; Description: Invokes mGetString and translates the integers from strings to integers by subtracting 48 from their respective ASCII numbers 
; Preconditions: The calling procedure pushes the needed parameters to the stack
; Postcondition: All numbers entered by user are withing 32 bits and don't have symbols within them besides a positive or minus symbol
; Recieves:
;		[EBP + 8]  = OFFSET num_List 
;		[EBP + 12] = OFFSET error_Message
;		[EBP + 16] = byte_string_len 
;		[EBP + 20] = OFFSET store_Num
;		[EBP + 24] = OFFSET prompt_User
; Return: 12 to derefence any parameters pushed to the stack
;-----------------------------------------------------------------------------------------------------------
ReadVal PROC
PUSH EBP
MOVE EBP, ESP
	PUSH ECX

	MOVE EDI, [EBP + 8]
	MOVE ECX, [EBP + 16]
	MOVE EBX, [EBP + 20]
_call_mGetString:
	MOVE EDX, [EBP + 24]
	mGetString EDX, EBX, ECX
	
	; Check if string size is <= 32 bits. After mGetString is called the EAX will hold the value of the length of the string entered
	CMP EAX, 4
	JA _string_greater
	JBE _string_equal

_string_greater:
	MOVE EDX, [EBP + 12]
	print_Text
	new_Line
	JMP _call_mGetString

_string_equal:
	MOVE [EDI], EDX

	POP ECX
POP EBP
RET 20
ReadVal ENDP

;-----------------------------------------------------------------------------------------------------------
; Name:
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
WriteVal PROC
PUSH EBP
MOVE EBP, ESP



POP EBP
RET
WriteVal ENDP

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

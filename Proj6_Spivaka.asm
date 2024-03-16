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
BUFFERSIZE = 12
STRINGLEN = 4
TRANSLATINGCONSTANT = 10
ASCIICONSTANT = 48

POS_SIGN = "+"
NEG_SIGN = "-"

;-----------------------------------------------------------------------------------------------------------
; Name: mGetstring
; Description: A macro that recieves three parameters and gets numbers from user, then sends that number back to Called PRROC
; Preconditions: Called from ReadVal procedure
; Postcondition: Sends numbers back to a called procedure
; Recieves:
;		promptUser	- message to prompt user to enter numbers
;		storeNum	- parameter by reference to store value
;-----------------------------------------------------------------------------------------------------------
mGetstring MACRO promptUser, storeNum

	PUSH EDX
	PUSH ECX

	MOVE EDX, promptUser
	MOVE ECX, 14			; A string can only be 12-characters in order to fit into a 32-bit register. 14 is to test if greater than 12 char
	print_Text

	MOVE EDX, storeNum
	CALL ReadString
	MOVE storeNum, EDX

	POP ECX
	POP EDX

ENDM

;-----------------------------------------------------------------------------------------------------------
; Name: mDisplayString
; Description: prints string stored at specified memory
; Preconditions: The string to be printed is sent to Marco by parameters
; Postcondition: String is printed by MACRO
; Recieves:
;		messageForUser - A string to be printed by the MACRO
;-----------------------------------------------------------------------------------------------------------
mDisplayString MACRO	messageForUser
	MOVE EDX, messageForUser
	print_Text

ENDM

.data
intro_Display			BYTE	"Programming assignment 6: Designing low-level I/O procedures",10,
								"Written by: Adam Spivak",0
user_Instructions		BYTE	"Please provide 10 signed decimal integers.",10,
								"Each number needs to be small enough to fit inside a 32 bit register. After you have finished",10,
								"inputting the raw numbers I will display a list of the integers, their sum, and their average value",0
prompt_User				BYTE	"Please enter a signed number: ",0
error_Message			BYTE	"ERROR: You did not enter a signed number or your number was too big.",0
you_Have_Entered		BYTE	"You have entered the following numbers:",10,0
sum_Of_Num_Msg			BYTE	"The sum of these Numbers is: ",0
trunct_Avg				BYTE	"The truncated average is: ",0

store_Num				BYTE	STRINGLEN DUP(0)	; 4 * BYTE = 32 bits
translate_Num			SDWORD	STRINGLEN DUP(0)	; Used to translate SDWORD val to string
num_List				SDWORD	ARRAYSIZE DUP(?)

translated_Num			SDWORD	0
is_POS_BOOL				DWORD	0					; 0 = Positive Value, 1 = Negative Value
num_of_entries			DWORD	0
running_subtotal		SDWORD	0

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
	mDisplayString OFFSET intro_Display
	new_Line
	new_Line

	mDisplayString OFFSET user_Instructions
	new_Line
	new_Line

	MOVE ECX, ARRAYSIZE
_enter_Num_Loop:
	MOVE EAX, is_POS_BOOL
	PUSH EAX
	MOVE EAX, translated_Num
	PUSH EAX
	MOVE EDX, OFFSET prompt_User
	PUSH EDX
	MOVE EDX, OFFSET store_Num
	PUSH EDX
	MOVE EDX, OFFSET error_Message
	PUSH EDX
	MOVE EDI, OFFSET num_List
	PUSH EDI
	CALL ReadVal

	LOOP _enter_Num_Loop

	mDisplayString OFFSET you_Have_Entered
	MOVE ECX, LENGTHOF num_List
_disp_and_sum:
	MOVE EDX, OFFSET store_Num		; Pushes the string to use for later
	PUSH EDX
	MOVE ESI, OFFSET num_List		; Pushes value stored at ESI from num_List
	PUSH [ESI]
	CALL WriteVal

	MOVE EAX, running_subtotal
	ADD  EAX, [ESI]
	ADD  ESI, TYPE num_List
	CALL WriteInt

	LOOP _disp_and_Sum
	

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------------------------
; Name: ReadVal
; Description: Invokes mGetString and translates the integers from strings to integers by subtracting 48 from their respective ASCII numbers.
; It uses 4 conditions to check the string its translating numbers from. First condition, it checks if string size is <= 12. After mGetString is called
; the EAX will hold the value of the length of the string entered. Second condition, it starts translating each CHAR in string from ASCII to digits and
; validates there are no numbers or symbols. The third condition will iterate through the string and check for symbols within middle of string. If it encounters
; symbol in middle of string it jumps to _invalid_String for invalid string. If first 3 conditions are met the string is a valid num and it will start translating.
; After translating to a number from ASCII, check within range of a 32 bit SDWORD (-2^31 and 2^31-1), if it larger or smaller it will send it to _invalid_String
; It will translate by subtracting 48 from each BYTE to represent current integer and multiply it by 10 to store the next num
; Preconditions: The calling procedure pushes the needed parameters to the stack
; Postcondition: All numbers entered by user are withing 32 bits and don't have symbols within them besides a positive or minus symbol
; Recieves:
;		[EBP + 8]  = OFFSET num_List 
;		[EBP + 12] = OFFSET error_Message
;		[EBP + 16] = OFFSET store_Num
;		[EBP + 20] = OFFSET prompt_User
;		[EBP + 24] = translated_Num
;		[EBP + 28] = is_POS_BOOL
; Return: 24 to derefence any parameters pushed to the stack
;-----------------------------------------------------------------------------------------------------------
ReadVal PROC
PUSH EBP
MOVE EBP, ESP
	PUSH ECX

_call_mGetString:
	MOVE EDI, [EBP + 8]
	MOVE EBX, [EBP + 16]
	MOVE EDX, [EBP + 20]
	mGetString EDX, EBX
	
	; First step of validation:
	MOVE EBX, 0
	CMP  EAX, EBX
	JE  _invalid_string
	CMP EAX, BUFFERSIZE
	JA _invalid_String
	JBE _valid_String

_invalid_String:
	MOVE EAX, 0
	MOVE [EBP + 24], EAX		; Ensures the translated_Num is 0 before starting
	MOVE [EBP + 28], EAX 		; Ensures the is_POS_BOOL isn't set just yet
	MOVE EDX, [EBP + 12]
	mDisplayString EDX
	new_Line
	JMP _call_mGetString

	; Second step of validation:
_valid_String:
	; First condition: Is the first CHAR a "+" or "-"
	MOVE ECX, EAX				; EAX containts the length of the entered string
	MOVE ESI, [EBP + 16]		; Begining of list

	CLD							; Clear direction flag to move up the string
	MOVE EAX, 0					; Empty EAX to start translating and storing integer
_iterating_String:
	LODSB
	CMP AL, POS_SIGN
	JE _POS_VALUE_CHECK			; Check if sign is at beginning of String
	CMP AL, NEG_SIGN
	JE _NEG_VALUE_CHECK			; Check if sign is at beginning of String
	; No pos or neg sign, so just start translating
	JMP _start_Translating

_POS_VALUE_CHECK:
	MOVE EAX, [EBP + 16]
	INC  EAX
	CMP  ESI, EAX
	JA   _invalid_String		; If ESI is not beginning of string
	JE   _POS_VALUE

_NEG_VALUE_CHECK:
	MOVE EAX, [EBP + 16]
	INC  EAX
	CMP  ESI, EAX
	JA   _invalid_String		; If ESI is not beginning of string
	JE   _NEG_VALUE

_POS_VALUE:
	PUSH EAX
	MOVE EAX, 0
	MOVE [EBP + 28], EAX
	POP EAX
	DEC ECX
	LODSB
	JMP _start_Translating

_NEG_VALUE:
	PUSH EAX
	MOVE EAX, 1
	MOVE [EBP + 28], EAX
	POP EAX
	DEC ECX
	LODSB
	JMP _start_Translating

_start_Translating:
	; Second condition: no symbols in middle of string
	CMP AL, ASCIICONSTANT
	JB _is_Symbol
	CMP AL, ASCIICONSTANT + 9
	JA _is_Symbol

	; Finally, translation
	SUB  AL, ASCIICONSTANT
	ADD [EBP + 24], AL
	CMP  ECX, 1						; If ECX = 1, at end of string
	JE  _dont_multiply_constant
	JNE _multiply_constant

_dont_multiply_constant:
	JMP _check_for_NEG				; ECX = 1, leave Number as is and check for NEG

_multiply_constant:
	MOVE EBX, [EBP + 24]
	MOVE EAX, EBX
	MOVE EBX, TRANSLATINGCONSTANT
	MUL  EBX

	JO _invalid_String
	MOVE [EBP + 24], EAX
	LOOP _iterating_string			; ECX != 0, Muliplty by 10 and move to next num

_check_for_NEG:
	MOVE EAX, [EBP + 28]
	CMP  EAX, 0
	JNE _neg_Num
	JMP _string_Translated

_neg_Num:
	NEG SDWORD PTR [EBP + 24]
	JMP _string_Translated

_is_Symbol:
	JMP _invalid_String

_string_Translated:
	MOVE EAX, [EBP + 24]
	MOVE [EDI], EAX	; Stores nums in list	
	ADD  EDI, 4

	POP ECX
POP EBP
RET 24
ReadVal ENDP

;-----------------------------------------------------------------------------------------------------------
; Name: WriteVal
; Description: Takes in signed integer and translates it to their respective ASCII Values and prints out the string of values. Only a 
; few conditions are needed in order for this PROC to works: The first condition, if the number is negative or positive by checking the sign
; flag. If sign flag is set, and the number is negative, it would put a "-" in front. If it's positive it will just move to the next value.
; The second coniditon will be to just increment through the signed integer until it reaches the end, translating each number to ASCII values on the way.
; Preconditions: Any string values that were taken in by the ReadVal procedure have been translated into signed integers. It does this
; by iterating through a string of numbers and adding 48 to convert them to their repsecitve ASCII values and saves it byte-by-byte
; to build a new string of characters
; Postcondition: Prints out a string of values after they are converted from numbers to chars
; Recieves:
;		[EBP + 8] = Signed number to be translated to string
;		[EBP + 12] = OFFSET store_Num
; Return: 
;-----------------------------------------------------------------------------------------------------------
WriteVal PROC
PUSH EBP
MOVE EBP, ESP
	MOVE ESI, [EBP + 8]
	MOVE EDI, [EBP + 12]
	MOVE ECX, BUFFERSIZE

	CLD
	LODSD					; Load signed number into ESI

	ADD AL, ASCIICONSTANT
	STOSB

	mDisplayString EDX
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

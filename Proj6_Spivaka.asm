TITLE Program Template     (Proj6_Spivaka.asm)

; Author: Adam Spivak
; Last Modified: 3-17-24
; OSU email address: Spivaka@oregonstate.edu
; Course number/section: CS271 Section 271
; Project Number: 6           Due Date: 3-17-24
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data

new_Line				EQU		<CALL CrLf>
MOVE					TEXTEQU <MOV>					; Turns MOV into MOVE to help with text alignment with PUSH

.code
;-----------------------------------------------------------------------------------------------------------
; Name:
; Description:
; Preconditions:
; Postcondition:
; Recieves:
; Return:
;-----------------------------------------------------------------------------------------------------------
main PROC

; (insert executable instructions here)

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
template PROC
PUSH EBP
MOVE EBP, ESP



POP EBP
RET n
template ENDP

END main

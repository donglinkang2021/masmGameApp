.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
includelib kernel32.lib
include user32.inc
includelib user32.lib

.data
	MsgCaption      db "Message Box",0
	MsgBoxText      db "This is a Message",0

.code
	;------------------------------------------
	; WinMain - Entry point for our program
	; @param 
	; @author linkdom
	;------------------------------------------
	WinMain PROC
		invoke MessageBox, NULL,addr MsgBoxText, addr MsgCaption, MB_OK
	WinMain ENDP


	main PROC
		call WinMain
		invoke ExitProcess,NULL
		ret ; return to operating system, else stack will be corrupted
	main ENDP
	end main

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
main:
	invoke MessageBox, NULL,addr MsgBoxText, addr MsgCaption, MB_OK
	invoke ExitProcess,NULL
end main

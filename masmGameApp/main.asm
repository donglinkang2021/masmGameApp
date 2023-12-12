.386
.model flat, stdcall
option casemap:none

include windows.inc
include kernel32.inc
includelib kernel32.lib
include user32.inc
includelib user32.lib
include gdi32.inc
includelib gdi32.lib

.data
	MyWinClass   db "Simple Win Class",0
	AppName      db "My First Window",0
	stRect RECT <0,0,0,0>;客户窗口的大小，right代表长，bottom代表高

.data?
	hInstance dword ? 	;程序的句柄
	hWinMain dword ?	;窗体的句柄
	hBitmap dd ?		;bitmap图片的句柄

.const
	IDI_ICON1 equ 102 	;图标的ID
	IDB_BITMAP1 equ 103 ; 希望加载的一张bitmap图片的ID

.code

	;------------------------------------------
	; WndProc - Window procedure
	; @param hWnd:HWND
	; @param uMsg:UINT
	; @param wParam:WPARAM
	; @param lParam:LPARAM
	; @return LRESULT
	; @author linkdom
	;------------------------------------------
	WndProc PROC hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
		LOCAL ps:PAINTSTRUCT
		LOCAL hdc:HDC
		LOCAL hMemDC:HDC
		.if uMsg==WM_DESTROY
			invoke DeleteObject, hBitmap
			invoke	DestroyWindow,hWinMain
			invoke PostQuitMessage, NULL
		.elseif uMsg==WM_CREATE
			; invoke MessageBox, NULL, addr AppName, addr MyWinClass, MB_OK
			invoke LoadBitmap, hInstance, IDB_BITMAP1
			mov hBitmap, eax
		.elseif uMsg == WM_PAINT
			invoke BeginPaint, hWnd, addr ps
			mov hdc, eax
			invoke GetClientRect, hWnd, addr stRect
			invoke CreateCompatibleDC, hdc
			mov hMemDC, eax
			invoke SelectObject, hMemDC, hBitmap
			invoke BitBlt, hdc, 0, 0, stRect.right, stRect.bottom, hMemDC, 0, 0, SRCCOPY
			invoke DeleteDC, hMemDC
			invoke EndPaint, hWnd, addr ps
		.else
			invoke DefWindowProc, hWnd, uMsg, wParam, lParam		
			ret
		.endif
		xor eax,eax
		ret
	WndProc ENDP

	;------------------------------------------
	; WinMain - Entry point for our program
	; @param 
	; @author linkdom
	;------------------------------------------
	WinMain PROC
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax	;获取程序的句柄
		invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		invoke	LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		invoke LoadIcon, hInstance, IDI_ICON1 
		mov	@stWndClass.hIcon,eax
		mov	@stWndClass.hIconSm,eax
		push hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize,sizeof WNDCLASSEX
		mov	@stWndClass.style,CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc,offset WndProc ;指定窗口处理程序
		mov	@stWndClass.hbrBackground,COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName,offset MyWinClass;窗口的类名
		invoke	RegisterClassEx,addr @stWndClass
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,\
				offset MyWinClass,\	;窗口的类名
				offset AppName,\	;窗口的标题
				WS_OVERLAPPEDWINDOW,\
				100,100,800,600,\	;窗口的位置和大小
				NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke ShowWindow, hWinMain,SW_SHOWDEFAULT 
		invoke UpdateWindow, hWinMain 
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage,addr @stMsg
			invoke	DispatchMessage,addr @stMsg
		.endw
		ret
	WinMain ENDP


	main:
		call WinMain
		invoke ExitProcess,NULL
	end main

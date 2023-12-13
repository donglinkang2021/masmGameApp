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
	stRect RECT <0,0,0,0>	;客户窗口的大小，right代表长，bottom代表高
	freshTime dword 60		;刷新时间，以毫秒为单位
	

.data?
	hInstance dword ? 	;程序的句柄
	hWinMain dword ?	;窗体的句柄
	
	; bitmap
	hBmpTest dd ?		;测试图片的句柄
	hBmpBack dd ?		;背景图片的句柄

	hBmpPlayer dd ?		;玩家图片的句柄
	hBmpPlayerM dd ?	;玩家图片的句柄
	hBmpSurfB dd ?		;玩家图片的句柄
	hBmpSurfBM dd ?		;玩家图片的句柄

	hBmpPlayer01 dd ?	
	hBmpPlayerM01 dd ?	
	hBmpSurfB01 dd ?	
	hBmpSurfBM01 dd ?
	hBmpPlayer02 dd ?	
	hBmpPlayerM02 dd ?	
	hBmpSurfB02 dd ?	
	hBmpSurfBM02 dd ?
	hBmpPlayer03 dd ?	
	hBmpPlayerM03 dd ?	
	hBmpSurfB03 dd ?	
	hBmpSurfBM03 dd ?
	hBmpPlayer04 dd ?	
	hBmpPlayerM04 dd ?	
	hBmpSurfB04 dd ?	
	hBmpSurfBM04 dd ?
	hBmpPlayer05 dd ?	
	hBmpPlayerM05 dd ?	
	hBmpSurfB05 dd ?	
	hBmpSurfBM05 dd ?	

	ITEMBMP struct
		hbp dd ? 	;位图的句柄
		x dd ? 		;位图x坐标
		y dd ?		;位图y坐标
		w dd ?		;位图宽度
		h dd ?		;位图高度
		flag dd ?	;位图的展示方式
	ITEMBMP ends
	items ITEMBMP 4096 dup(<?,?,?,?,?,?>)
	itemsCount dd 0	;当前已经加载的图片的数量

.const
	MyWinClass   db "Simple Win Class",0
	AppName      db "My First Window",0
	IDI_ICON1 equ 101 	;图标的ID
	IDB_PLAYER01 equ 102
	IDB_PLAYER02 equ 103
	IDB_PLAYER03 equ 104
	IDB_PLAYER04 equ 105
	IDB_PLAYER05 equ 106
	IDB_PLAYERM01 equ 107
	IDB_PLAYERM02 equ 108
	IDB_PLAYERM03 equ 109
	IDB_PLAYERM04 equ 110
	IDB_PLAYERM05 equ 111
	IDB_SURFB01 equ 112
	IDB_SURFB02 equ 113
	IDB_SURFB03 equ 114
	IDB_SURFB04 equ 115
	IDB_SURFB05 equ 116
	IDB_SURFBM01 equ 117
	IDB_SURFBM02 equ 118
	IDB_SURFBM03 equ 119
	IDB_SURFBM04 equ 120
	IDB_SURFBM05 equ 121
	IDB_BACK equ 122

.code

	;------------------------------------------
	; LoadAllBmp - 加载所有的图片
	; @param
	; @return void
	;------------------------------------------
	LoadAllBmp PROC
		invoke LoadBitmap, hInstance, IDB_BACK
		mov hBmpBack, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER01
		mov hBmpPlayer01, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM01
		mov hBmpPlayerM01, eax
		invoke LoadBitmap, hInstance, IDB_SURFB01
		mov hBmpSurfB01, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM01
		mov hBmpSurfBM01, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER02
		mov hBmpPlayer02, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM02
		mov hBmpPlayerM02, eax
		invoke LoadBitmap, hInstance, IDB_SURFB02
		mov hBmpSurfB02, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM02
		mov hBmpSurfBM02, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER03
		mov hBmpPlayer03, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM03
		mov hBmpPlayerM03, eax
		invoke LoadBitmap, hInstance, IDB_SURFB03
		mov hBmpSurfB03, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM03
		mov hBmpSurfBM03, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER04
		mov hBmpPlayer04, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM04
		mov hBmpPlayerM04, eax
		invoke LoadBitmap, hInstance, IDB_SURFB04
		mov hBmpSurfB04, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM04
		mov hBmpSurfBM04, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER05
		mov hBmpPlayer05, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM05
		mov hBmpPlayerM05, eax
		invoke LoadBitmap, hInstance, IDB_SURFB05
		mov hBmpSurfB05, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM05
		mov hBmpSurfBM05, eax

		; 初始化player和surfB的图片, 之后初始化为00
		mov eax, hBmpPlayer03
		mov hBmpPlayer, eax
		mov eax, hBmpPlayerM03
		mov hBmpPlayerM, eax
		mov eax, hBmpSurfB03
		mov hBmpSurfB, eax
		mov eax, hBmpSurfBM03
		mov hBmpSurfBM, eax

		ret
	LoadAllBmp ENDP


	;------------------------------------------
	; DeleteBmp - 删除所有的图片
	; @param
	; @return void
	;------------------------------------------
	DeleteBmp PROC
		invoke DeleteObject, hBmpBack
		invoke DeleteObject, hBmpPlayer01
		invoke DeleteObject, hBmpPlayerM01
		invoke DeleteObject, hBmpSurfB01
		invoke DeleteObject, hBmpSurfBM01
		invoke DeleteObject, hBmpPlayer02
		invoke DeleteObject, hBmpPlayerM02
		invoke DeleteObject, hBmpSurfB02
		invoke DeleteObject, hBmpSurfBM02
		invoke DeleteObject, hBmpPlayer03
		invoke DeleteObject, hBmpPlayerM03
		invoke DeleteObject, hBmpSurfB03
		invoke DeleteObject, hBmpSurfBM03
		invoke DeleteObject, hBmpPlayer04
		invoke DeleteObject, hBmpPlayerM04
		invoke DeleteObject, hBmpSurfB04
		invoke DeleteObject, hBmpSurfBM04
		invoke DeleteObject, hBmpPlayer05
		invoke DeleteObject, hBmpPlayerM05
		invoke DeleteObject, hBmpSurfB05
		invoke DeleteObject, hBmpSurfBM05
		ret
	DeleteBmp ENDP


	;------------------------------------------
	; Bmp2Buffer - 将图片绘制到缓冲区
	; @param hBmp:HBITMAP
	; @param x:DWORD
	; @param y:DWORD
	; @param w:DWORD
	; @param h:DWORD
	; @param flag:DWORD
	; @return void
	;------------------------------------------
	Bmp2Buffer PROC hBmp:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD, flag:DWORD
		; get the top buffer
		mov eax, itemsCount
		mov edi, offset items
		mov ebx, TYPE ITEMBMP
		mul ebx
		add edi, eax

		; set the buffer
		mov eax, hBmp
		mov (ITEMBMP PTR [edi]).hbp, eax
		mov eax, x
		mov (ITEMBMP PTR [edi]).x, eax
		mov eax, y
		mov (ITEMBMP PTR [edi]).y, eax
		mov eax, w
		mov (ITEMBMP PTR [edi]).w, eax
		mov eax, h
		mov (ITEMBMP PTR [edi]).h, eax
		mov eax, flag
		mov (ITEMBMP PTR [edi]).flag, eax

		; add the count
		inc itemsCount
		ret
	Bmp2Buffer ENDP


	;------------------------------------------
	; Buffer2Window - 将缓冲区的图片绘制到窗口
	; @param hWnd:HWND
	; @return void
	;------------------------------------------
	Buffer2Window PROC
		LOCAL ps:PAINTSTRUCT
		LOCAL hdc:dword ;屏幕的hdc 全称是handle device context
		LOCAL hdc1:dword;缓冲区1
		LOCAL hdc2:dword;缓冲区2
		LOCAL hBmp:dword;缓冲区的位图
		LOCAL @bminfo :BITMAP

		invoke BeginPaint, hWinMain, addr ps
		mov hdc, eax
		invoke CreateCompatibleDC, hdc
		mov hdc1, eax
		invoke CreateCompatibleDC, hdc
		mov hdc2, eax

		; get the window size
		invoke CreateCompatibleBitmap,hdc,stRect.right,stRect.bottom
		mov hBmp,eax
		invoke SelectObject,hdc1,hBmp
		invoke SetStretchBltMode,hdc,HALFTONE
		invoke SetStretchBltMode,hdc1,HALFTONE

		mov esi, 0
		mov edi, offset items
		.while esi < itemsCount
			invoke GetObject,(ITEMBMP PTR [edi]).hbp,type @bminfo,addr @bminfo
			invoke SelectObject,hdc2,(ITEMBMP PTR [edi]).hbp
			invoke StretchBlt,hdc1,\
				(ITEMBMP PTR [edi]).x,(ITEMBMP PTR [edi]).y,\
				(ITEMBMP PTR [edi]).w,(ITEMBMP PTR [edi]).h,\
				hdc2,0,0,\
				@bminfo.bmWidth,@bminfo.bmHeight,\
				(ITEMBMP PTR [edi]).flag
			inc esi
			add edi,TYPE ITEMBMP
		.endw

		invoke StretchBlt,hdc,0,0,\
			stRect.right,stRect.bottom,\
			hdc1,0,0,\
			stRect.right,stRect.bottom,\
			SRCCOPY

		invoke DeleteDC,hBmp
		invoke DeleteDC,hdc2
		invoke DeleteDC,hdc1
		invoke DeleteDC,hdc
		invoke EndPaint, hWinMain, addr ps
		mov itemsCount, 0
		ret
	Buffer2Window ENDP

	
	;------------------------------------------
	; PlayerAction - 玩家的操作
	; @param wParam:WPARAM
	; @return void
	;------------------------------------------
	PlayerAction PROC wParam:WPARAM
		.if wParam==VK_LEFT
			mov eax, hBmpSurfBM01
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB01
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM01
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer01
			mov hBmpPlayer, eax
		.elseif wParam==VK_RIGHT
			mov eax, hBmpSurfBM05
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB05
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM05
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer05
			mov hBmpPlayer, eax
		.elseif wParam==VK_DOWN
			mov eax, hBmpSurfBM03
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB03
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM03
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer03
			mov hBmpPlayer, eax
		.elseif wParam==VK_UP
			; 这里应该是00才对的之后导入资源的时候再改
		.endif
		ret
	PlayerAction ENDP

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
		.if uMsg==WM_DESTROY
			invoke DeleteBmp
			invoke DestroyWindow, hWinMain
			invoke PostQuitMessage, NULL
		.elseif uMsg==WM_CREATE
			invoke LoadAllBmp
			invoke GetClientRect, hWnd, addr stRect
			invoke SetTimer,hWnd,1,freshTime,NULL ; 开始计时
			; 这里之后实现动态波浪移动
		.elseif uMsg==WM_KEYDOWN
			invoke PlayerAction, wParam
		.elseif uMsg == WM_PAINT
			invoke Bmp2Buffer, hBmpBack, 0, 0, stRect.right, stRect.bottom, SRCCOPY
			invoke Bmp2Buffer, hBmpSurfBM, 368, 268, 64, 64, SRCAND
			invoke Bmp2Buffer, hBmpSurfB, 368, 268, 64, 64, SRCPAINT
			invoke Bmp2Buffer, hBmpPlayerM, 368, 268, 64, 64, SRCAND
			invoke Bmp2Buffer, hBmpPlayer, 368, 268, 64, 64, SRCPAINT
			
			invoke Buffer2Window
		.elseif uMsg ==WM_TIMER ;刷新
			invoke InvalidateRect,hWnd,NULL,FALSE
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
		invoke ShowWindow, hWinMain, SW_SHOWDEFAULT 
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

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

	; player_action
	; 0 ~ 5 原地, 左左, 左, 中, 右, 右右
	; 6 ~ 7 落水0, 落水1
	; 8 站着 
	; 9 ~ 12 翻滚0, 翻滚1, 翻滚2, 翻滚3
	player_action dword 0   

	; player_state
	; 0 普通划水
	; 1 加速 无动作，只是变快
	; 2 起飞 翻滚开始动作
	; 3 落水
	; 4 站着
	player_state dword 2
	

.data?
	hInstance dword ? 	;程序的句柄
	hWinMain dword ?	;窗体的句柄
	
	; bitmap
	hBmpTest dd ?		;测试图片的句柄
	hBmpBack dd ?		;背景图片的句柄

	hBmpPlayer dd ?		;当前玩家图片的句柄
	hBmpPlayerM dd ?	;当前玩家图片的句柄
	hBmpSurfB dd ?		;当前玩家图片的句柄
	hBmpSurfBM dd ?		;当前玩家图片的句柄

	; 后面看能不能把这一段优化成数组的形式
	; 可以思考，这一个就是一个13x4的int数组存储就可以了
	; 后面的动画就是板子对应的更新，再说
	hBmpPlayer00 dd ?	
	hBmpPlayerM00 dd ?	
	hBmpSurfB00 dd ?	
	hBmpSurfBM00 dd ?
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
	hBmpPlayer06 dd ?	
	hBmpPlayerM06 dd ?	
	hBmpSurfB06 dd ?	
	hBmpSurfBM06 dd ?
	hBmpPlayer07 dd ?
	hBmpPlayerM07 dd ?
	hBmpSurfB07 dd ?
	hBmpSurfBM07 dd ?
	hBmpPlayer08 dd ?
	hBmpPlayerM08 dd ?
	hBmpSurfB08 dd ?
	hBmpSurfBM08 dd ?
	hBmpPlayer09 dd ?
	hBmpPlayerM09 dd ?
	hBmpSurfB09 dd ?
	hBmpSurfBM09 dd ?
	hBmpPlayer010 dd ?
	hBmpPlayerM010 dd ?
	hBmpSurfB010 dd ?
	hBmpSurfBM010 dd ?
	hBmpPlayer011 dd ?
	hBmpPlayerM011 dd ?
	hBmpSurfB011 dd ?
	hBmpSurfBM011 dd ?
	hBmpPlayer012 dd ?
	hBmpPlayerM012 dd ?
	hBmpSurfB012 dd ?
	hBmpSurfBM012 dd ?		

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
    IDI_ICON1 equ 101
    IDB_PLAYER00 equ 102
    IDB_PLAYER01 equ 103
    IDB_PLAYER02 equ 104
    IDB_PLAYER03 equ 105
    IDB_PLAYER04 equ 106
    IDB_PLAYER05 equ 107
    IDB_PLAYER06 equ 108
    IDB_PLAYER07 equ 109
    IDB_PLAYER08 equ 110
    IDB_PLAYER09 equ 111
    IDB_PLAYER010 equ 112
    IDB_PLAYER011 equ 113
    IDB_PLAYER012 equ 114
    IDB_PLAYERM00 equ 115
    IDB_PLAYERM01 equ 116
    IDB_PLAYERM02 equ 117
    IDB_PLAYERM03 equ 118
    IDB_PLAYERM04 equ 119
    IDB_PLAYERM05 equ 120
    IDB_PLAYERM06 equ 121
    IDB_PLAYERM07 equ 122
    IDB_PLAYERM08 equ 123
    IDB_PLAYERM09 equ 124
    IDB_PLAYERM010 equ 125
    IDB_PLAYERM011 equ 126
    IDB_PLAYERM012 equ 127
    IDB_SURFB00 equ 128
    IDB_SURFB01 equ 129
    IDB_SURFB02 equ 130
    IDB_SURFB03 equ 131
    IDB_SURFB04 equ 132
    IDB_SURFB05 equ 133
    IDB_SURFB06 equ 134
    IDB_SURFB07 equ 135
    IDB_SURFB08 equ 136
    IDB_SURFB09 equ 137
    IDB_SURFB010 equ 138
    IDB_SURFB011 equ 139
    IDB_SURFB012 equ 140
    IDB_SURFBM00 equ 141
    IDB_SURFBM01 equ 142
    IDB_SURFBM02 equ 143
    IDB_SURFBM03 equ 144
    IDB_SURFBM04 equ 145
    IDB_SURFBM05 equ 146
    IDB_SURFBM06 equ 147
    IDB_SURFBM07 equ 148
    IDB_SURFBM08 equ 149
    IDB_SURFBM09 equ 150
    IDB_SURFBM010 equ 151
    IDB_SURFBM011 equ 152
    IDB_SURFBM012 equ 153
    IDB_BACK equ 154
	
.code

	;------------------------------------------
	; LoadAllBmp - 加载所有的图片
	; @param
	; @return void
	;------------------------------------------
	LoadAllBmp PROC
		invoke LoadBitmap, hInstance, IDB_BACK
		mov hBmpBack, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER00
		mov hBmpPlayer00, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM00
		mov hBmpPlayerM00, eax
		invoke LoadBitmap, hInstance, IDB_SURFB00
		mov hBmpSurfB00, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM00
		mov hBmpSurfBM00, eax

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

		invoke LoadBitmap, hInstance, IDB_PLAYER06
		mov hBmpPlayer06, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM06
		mov hBmpPlayerM06, eax
		invoke LoadBitmap, hInstance, IDB_SURFB06
		mov hBmpSurfB06, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM06
		mov hBmpSurfBM06, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER07
		mov hBmpPlayer07, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM07
		mov hBmpPlayerM07, eax
		invoke LoadBitmap, hInstance, IDB_SURFB07
		mov hBmpSurfB07, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM07
		mov hBmpSurfBM07, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER08
		mov hBmpPlayer08, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM08
		mov hBmpPlayerM08, eax
		invoke LoadBitmap, hInstance, IDB_SURFB08
		mov hBmpSurfB08, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM08
		mov hBmpSurfBM08, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER09
		mov hBmpPlayer09, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM09
		mov hBmpPlayerM09, eax
		invoke LoadBitmap, hInstance, IDB_SURFB09
		mov hBmpSurfB09, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM09
		mov hBmpSurfBM09, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER010
		mov hBmpPlayer010, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM010
		mov hBmpPlayerM010, eax
		invoke LoadBitmap, hInstance, IDB_SURFB010
		mov hBmpSurfB010, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM010
		mov hBmpSurfBM010, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER011
		mov hBmpPlayer011, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM011
		mov hBmpPlayerM011, eax
		invoke LoadBitmap, hInstance, IDB_SURFB011
		mov hBmpSurfB011, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM011
		mov hBmpSurfBM011, eax

		invoke LoadBitmap, hInstance, IDB_PLAYER012
		mov hBmpPlayer012, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM012
		mov hBmpPlayerM012, eax
		invoke LoadBitmap, hInstance, IDB_SURFB012
		mov hBmpSurfB012, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM012
		mov hBmpSurfBM012, eax

		; 初始化player和surfB的图片, 之后初始化为00
		mov eax, hBmpPlayer00
		mov hBmpPlayer, eax
		mov eax, hBmpPlayerM00
		mov hBmpPlayerM, eax
		mov eax, hBmpSurfB00
		mov hBmpSurfB, eax
		mov eax, hBmpSurfBM00
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
		invoke DeleteObject, hBmpPlayer00
		invoke DeleteObject, hBmpPlayerM00
		invoke DeleteObject, hBmpSurfB00
		invoke DeleteObject, hBmpSurfBM00
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
		invoke DeleteObject, hBmpPlayer06
		invoke DeleteObject, hBmpPlayerM06
		invoke DeleteObject, hBmpSurfB06
		invoke DeleteObject, hBmpSurfBM06
		invoke DeleteObject, hBmpPlayer07
		invoke DeleteObject, hBmpPlayerM07
		invoke DeleteObject, hBmpSurfB07
		invoke DeleteObject, hBmpSurfBM07
		invoke DeleteObject, hBmpPlayer08
		invoke DeleteObject, hBmpPlayerM08
		invoke DeleteObject, hBmpSurfB08
		invoke DeleteObject, hBmpSurfBM08
		invoke DeleteObject, hBmpPlayer09
		invoke DeleteObject, hBmpPlayerM09
		invoke DeleteObject, hBmpSurfB09
		invoke DeleteObject, hBmpSurfBM09
		invoke DeleteObject, hBmpPlayer010
		invoke DeleteObject, hBmpPlayerM010
		invoke DeleteObject, hBmpSurfB010
		invoke DeleteObject, hBmpSurfBM010
		invoke DeleteObject, hBmpPlayer011
		invoke DeleteObject, hBmpPlayerM011
		invoke DeleteObject, hBmpSurfB011
		invoke DeleteObject, hBmpSurfBM011
		invoke DeleteObject, hBmpPlayer012
		invoke DeleteObject, hBmpPlayerM012
		invoke DeleteObject, hBmpSurfB012
		invoke DeleteObject, hBmpSurfBM012

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
	; UpdateActionBmp - 更新动作bmp的句柄
	;------------------------------------------
	UpdateActionBmp PROC
		.if player_action == 0
			; 之后这里要改成 00
			mov eax, hBmpSurfBM00
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB00
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM00
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer00
			mov hBmpPlayer, eax
		.elseif player_action == 1
			mov eax, hBmpSurfBM01
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB01
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM01
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer01
			mov hBmpPlayer, eax
		.elseif player_action == 2
			mov eax, hBmpSurfBM02
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB02
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM02
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer02
			mov hBmpPlayer, eax
		.elseif player_action == 3
			mov eax, hBmpSurfBM03
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB03
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM03
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer03
			mov hBmpPlayer, eax
		.elseif player_action == 4
			mov eax, hBmpSurfBM04
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB04
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM04
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer04
			mov hBmpPlayer, eax
		.elseif player_action == 5
			mov eax, hBmpSurfBM05
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB05
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM05
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer05
			mov hBmpPlayer, eax
		.elseif player_action == 6
			mov eax, hBmpSurfBM06
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB06
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM06
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer06
			mov hBmpPlayer, eax
		.elseif player_action == 7
			mov eax, hBmpSurfBM07
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB07
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM07
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer07
			mov hBmpPlayer, eax
		.elseif player_action == 8
			mov eax, hBmpSurfBM08
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB08
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM08
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer08
			mov hBmpPlayer, eax
		.elseif player_action == 9
			mov eax, hBmpSurfBM09
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB09
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM09
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer09
			mov hBmpPlayer, eax
		.elseif player_action == 10
			mov eax, hBmpSurfBM010
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB010
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM010
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer010
			mov hBmpPlayer, eax
		.elseif player_action == 11
			mov eax, hBmpSurfBM011
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB011
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM011
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer011
			mov hBmpPlayer, eax
		.elseif player_action == 12
			mov eax, hBmpSurfBM012
			mov hBmpSurfBM, eax
			mov eax, hBmpSurfB012
			mov hBmpSurfB, eax
			mov eax, hBmpPlayerM012
			mov hBmpPlayerM, eax
			mov eax, hBmpPlayer012
			mov hBmpPlayer, eax
		.endif
		ret
	UpdateActionBmp ENDP
	
	;------------------------------------------
	; PlayerAction - 玩家的操作
	; @param wParam:WPARAM
	; @return void
	;------------------------------------------
	PlayerAction PROC wParam:WPARAM
		.if wParam==VK_LEFT
			.if player_action > 1 && player_action < 6
				.if player_action > 3
					mov eax, 2
					mov player_action, eax
				.else
					dec player_action
				.endif
			.endif
		.elseif wParam==VK_RIGHT
			.if player_action < 5 && player_action > 0
				.if player_action < 3
					mov eax, 4
					mov player_action, eax
				.else
					inc player_action
				.endif
			.endif
		.elseif wParam==VK_DOWN
			.if player_state == 0
				mov eax, 3
				mov player_state, eax
			.elseif player_state == 2
				.if player_action < 6
					mov eax, 9
					mov player_action, eax
				.elseif player_action >= 9 && player_action < 12
					inc player_action
				.elseif player_action == 12
					mov eax, 3
					mov player_action, eax
				.endif
			.endif
		.elseif wParam==VK_UP
			; 这里应该是00才对的之后导入资源的时候再改
			mov eax, 0
			mov player_action, eax
		.endif
		invoke UpdateActionBmp
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

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
include resource.inc
include	masm32.inc
includelib msvcrt.lib
rand	proto C

.const
	MyWinClass   db "Simple Win Class",0
	AppName      db "Surf",0
.data
	stRect RECT <0,0,0,0>	;客户窗口的大小，right代表长，bottom代表高
	freshTime dword 16		;刷新时间，以毫秒为单位 帧率60

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
	player_state dword 0

	; 如果这一段放在.data?里面，那么在调用的时候会出现错误
	PosWater struct
		x dd ?
		y dd ?
	PosWater ends
	water PosWater <16,-84>

	; 添加相对速度，因为到时候所有物体速度都是一样的
	RelSpeed struct
		x dd ?
		y dd ?
	RelSpeed ends
	speed RelSpeed <0,0>

	; 用于控制surfB的动画
	aniTimer dword 0

	;当前已经加载的图片的数量
	itemsCount dd 0	

	; 记录生成的slowdown的数量
	slowdCount dd 0
	slowdInterval dd 20 ; 最开始时的生成间隔，80差不多应该，之后的生成间隔为随机数
	MAXSLOWD dd 8 ; 最多生成的slowdown的数量

.data?
	hInstance dword ? 	;程序的句柄
	hWinMain dword ?	;窗体的句柄
	
	; bitmap
	hBmpBack dd ?		;背景图片的句柄
	hBmpWater dd ?		;浪花的句柄, 浪花不需要mask
	hBmpSlowd dd ?		;slowdown的句柄

	hBmpPlayer dd ?		;当前玩家图片的句柄
	hBmpPlayerM dd ?	;当前玩家图片的句柄
	hBmpSurfB dd ?		;当前玩家图片的句柄
	hBmpSurfBM dd ?		;当前玩家图片的句柄

	SurferHandle struct
		Player dd ?	
		PlayerM dd ?
		SurfB dd ?	
		SurfBM dd ?	
	SurferHandle ends

	surfers SurferHandle 13 dup(<?,?,?,?>)

	; 后面的动画就是板子对应的更新
	SurfBoardHandle struct
		SurfB0 dd ?	
		SurfBM0 dd ?
		SurfB1 dd ?
		SurfBM1 dd ?
		SurfB2 dd ?
		SurfBM2 dd ?
	SurfBoardHandle ends

	surfBoardAni SurfBoardHandle 13 dup(<?,?,?,?,?,?>)

	; 添加slowdown及其动画，不需要mask
	SlowdownHandle struct
		SlowD0 dd ?
		SlowD1 dd ?
		SlowD2 dd ?
	SlowdownHandle ends

	slowdownAni SlowdownHandle 9 dup(<?,?,?>)

	; 添加Slowdown的位置
	PosSlowdown struct
		x dd ?
		y dd ?
		tp dd ?
		hBmp dd ?
	PosSlowdown ends
	slowdownPos PosSlowdown 16 dup(<?,?,?,?>)

	ITEMBMP struct
		hbp dd ? 	;位图的句柄
		x dd ? 		;位图x坐标
		y dd ?		;位图y坐标
		w dd ?		;位图宽度
		h dd ?		;位图高度
		flag dd ?	;位图的展示方式
	ITEMBMP ends
	items ITEMBMP 4096 dup(<?,?,?,?,?,?>)

	
.code

	;------------------------------------------
	; GetRandom - 获取一个随机数
	; @param left - 随机数的左边界
	; @param right - 随机数的右边界
	; @return 随机数
	;------------------------------------------
	GetRandom PROC left:dword,right:dword
		invoke rand
		xor edx,edx
		mov ebx,right
		sub ebx,left
		div ebx
		add edx,left
		mov eax,edx
		ret
	GetRandom ENDP

	;------------------------------------------
	; LoadSurfer - 加载surfer的图片
	; @param
	; @return void
	;------------------------------------------
	LoadSurfer PROC uses eax ebx ecx edx esi edi 
		mov edi, offset surfers
		invoke LoadBitmap, hInstance, IDB_PLAYER00
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM00
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB00
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM00
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER01
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM01
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB01
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM01
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER02
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM02
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB02
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM02
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER03
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM03
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB03
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM03
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER04
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM04
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB04
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM04
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER05
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM05
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB05
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM05
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER06
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM06
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB06
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM06
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER07
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM07
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB07
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM07
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER08
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM08
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB08
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM08
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER09
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM09
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB09
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM09
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER010
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM010
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB010
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM010
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER011
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM011
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB011
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM011
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		invoke LoadBitmap, hInstance, IDB_PLAYER012
		mov (SurferHandle PTR [edi]).Player, eax
		invoke LoadBitmap, hInstance, IDB_PLAYERM012
		mov (SurferHandle PTR [edi]).PlayerM, eax
		invoke LoadBitmap, hInstance, IDB_SURFB012
		mov (SurferHandle PTR [edi]).SurfB, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM012
		mov (SurferHandle PTR [edi]).SurfBM, eax
		add edi, TYPE SurferHandle

		; 初始化player和surfB的图片
		mov edi, offset surfers
		mov eax, (SurferHandle PTR [edi]).Player
		mov hBmpPlayer, eax
		mov eax, (SurferHandle PTR [edi]).PlayerM
		mov hBmpPlayerM, eax
		mov eax, (SurferHandle PTR [edi]).SurfB
		mov hBmpSurfB, eax
		mov eax, (SurferHandle PTR [edi]).SurfBM
		mov hBmpSurfBM, eax
		ret
	LoadSurfer ENDP

	;------------------------------------------
	; LoadSurfboard - 加载surfboard的图片
	; @param
	; @return void
	;------------------------------------------
	LoadSurfboard PROC uses eax ebx ecx edx esi edi 
		mov edi, offset surfBoardAni
		invoke LoadBitmap, hInstance, IDB_SURFB00
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM00
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB10
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM10
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax	
		invoke LoadBitmap, hInstance, IDB_SURFB20
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM20
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB01
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM01
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB11
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM11
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB21
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM21
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle	

		invoke LoadBitmap, hInstance, IDB_SURFB02
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM02
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB12
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM12
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB22
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM22
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB03
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM03
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB13
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM13
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB23
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM23
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB04
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM04
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB14
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM14
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB24
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM24
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB05
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM05
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB15
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM15
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB25
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM25
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB06
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM06
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB16
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM16
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB26
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM26
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB07
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM07
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB17
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM17
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB27
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM27
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB08
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM08
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB18
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM18
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB28
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM28
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB09
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM09
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB19
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM19
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB29
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM29
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB010
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM010
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB110
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM110
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB210
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM210
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB011
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM011
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB111
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM111
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB211
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM211
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle

		invoke LoadBitmap, hInstance, IDB_SURFB012
		mov (SurfBoardHandle PTR [edi]).SurfB0, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM012
		mov (SurfBoardHandle PTR [edi]).SurfBM0, eax
		invoke LoadBitmap, hInstance, IDB_SURFB112
		mov (SurfBoardHandle PTR [edi]).SurfB1, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM112
		mov (SurfBoardHandle PTR [edi]).SurfBM1, eax
		invoke LoadBitmap, hInstance, IDB_SURFB212
		mov (SurfBoardHandle PTR [edi]).SurfB2, eax
		invoke LoadBitmap, hInstance, IDB_SURFBM212
		mov (SurfBoardHandle PTR [edi]).SurfBM2, eax
		add edi, TYPE SurfBoardHandle
		ret
	LoadSurfboard ENDP

	;------------------------------------------
	; LoadSlowdown - 加载slowdown的图片
	; @param
	; @return void
	;------------------------------------------
	LoadSlowdown PROC uses eax ebx ecx edx esi edi 
		mov edi, offset slowdownAni
		invoke LoadBitmap, hInstance, IDB_SLOWD00
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD10
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD20
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD01
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD11
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD21
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD02
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD12
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD22
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD03
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD13
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD23
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD04
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD14
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD24
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD05
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD15
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD25
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD06
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD16
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD26
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD07
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD17
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD27
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		invoke LoadBitmap, hInstance, IDB_SLOWD08
		mov (SlowdownHandle PTR [edi]).SlowD0, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD18
		mov (SlowdownHandle PTR [edi]).SlowD1, eax
		invoke LoadBitmap, hInstance, IDB_SLOWD28
		mov (SlowdownHandle PTR [edi]).SlowD2, eax
		add edi, TYPE SlowdownHandle

		; 暂时只加载为00的图片
		mov edi, offset slowdownAni
		mov eax, (SlowdownHandle PTR [edi]).SlowD0
		mov hBmpSlowd, eax
		ret
	LoadSlowdown ENDP
	
	;------------------------------------------
	; LoadAllBmp - 加载所有的图片
	; @param
	; @return void
	;------------------------------------------
	LoadAllBmp PROC uses eax ebx ecx edx esi edi 
		invoke LoadBitmap, hInstance, IDB_BACK
		mov hBmpBack, eax
		invoke LoadBitmap, hInstance, IDB_WATERMD
		mov hBmpWater, eax

		; 初始化surfer的图片
		invoke LoadSurfer

		; 初始化surfBoard的图片
		invoke LoadSurfboard

		; 初始化slowdown的图片
		invoke LoadSlowdown
		
		ret
	LoadAllBmp ENDP


	;------------------------------------------
	; DeleteBmp - 删除所有的图片
	; @param
	; @return void
	;------------------------------------------
	DeleteBmp PROC uses eax ebx ecx edx esi edi 
		invoke DeleteObject, hBmpBack
		invoke DeleteObject, hBmpWater
		invoke DeleteObject, hBmpSlowd
		mov edi, offset surfers
		mov esi, 0
		.while esi < 13
			invoke DeleteObject, (SurferHandle PTR [edi]).Player
			invoke DeleteObject, (SurferHandle PTR [edi]).PlayerM
			invoke DeleteObject, (SurferHandle PTR [edi]).SurfB
			invoke DeleteObject, (SurferHandle PTR [edi]).SurfBM
			add edi, TYPE SurferHandle
			inc esi
		.endw
		mov edi, offset surfBoardAni
		mov esi, 0
		.while esi < 13
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfB0
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfBM0
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfB1
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfBM1
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfB2
			invoke DeleteObject, (SurfBoardHandle PTR [edi]).SurfBM2
			add edi, TYPE SurfBoardHandle
			inc esi
		.endw
		mov edi, offset slowdownAni
		mov esi, 0
		.while esi < 9
			invoke DeleteObject, (SlowdownHandle PTR [edi]).SlowD0
			invoke DeleteObject, (SlowdownHandle PTR [edi]).SlowD1
			invoke DeleteObject, (SlowdownHandle PTR [edi]).SlowD2
			add edi, TYPE SlowdownHandle
			inc esi
		.endw
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
	Bmp2Buffer PROC uses eax ebx ecx edx esi edi hBmp:DWORD, x:DWORD, y:DWORD, w:DWORD, h:DWORD, flag:DWORD
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
	Buffer2Window PROC uses eax ebx ecx edx esi edi 
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
	UpdateActionBmp PROC uses eax ebx ecx edx esi edi 
		mov edi, offset surfers
		mov esi, player_action
		imul esi, TYPE SurferHandle
		add edi, esi

		mov eax, (SurferHandle PTR [edi]).Player
		mov hBmpPlayer, eax
		mov eax, (SurferHandle PTR [edi]).PlayerM
		mov hBmpPlayerM, eax
		mov eax, (SurferHandle PTR [edi]).SurfB
		mov hBmpSurfB, eax
		mov eax, (SurferHandle PTR [edi]).SurfBM
		mov hBmpSurfBM, eax
		ret
	UpdateActionBmp ENDP
	
	;------------------------------------------
	; PlayerAction - 玩家的操作
	; @param wParam:WPARAM
	; @return void
	;------------------------------------------
	PlayerAction PROC uses eax ebx ecx edx esi edi wParam:WPARAM 
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
				mov player_action, eax
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
			mov eax, 0
			mov player_action, eax
		.endif
		invoke UpdateActionBmp
		ret
	PlayerAction ENDP

	;------------------------------------------
	; UpdateAniTimer - 更新动画的计时器
	; @param
	; @return void
	;------------------------------------------
	UpdateAniTimer PROC uses eax ebx ecx edx esi edi 
		inc aniTimer
		mov eax, aniTimer
		mov edx, 0    ; 清零edx，因为div指令会使用edx:eax作为被除数
		mov ecx, 24    ; 放入ecx，作为除数
		div ecx       ; 执行除法操作，eax = edx:eax / ecx，edx = edx:eax % ecx
		mov aniTimer, edx  ; 将余数（%结果）放回surfBtimer
		ret
	UpdateAniTimer ENDP

	;------------------------------------------
	; UpdateSurfBoard - 更新surfB的句柄
	; @param
	; @return void
	;------------------------------------------
	UpdateSurfBoard PROC uses eax ebx ecx edx esi edi 
		mov edi, offset surfBoardAni
		mov esi, player_action
		imul esi, TYPE SurfBoardHandle
		add edi, esi
		.if aniTimer == 0
			mov eax, (SurfBoardHandle PTR [edi]).SurfB0
			mov hBmpSurfB, eax
			mov eax, (SurfBoardHandle PTR [edi]).SurfBM0
			mov hBmpSurfBM, eax
		.elseif aniTimer == 8
			mov eax, (SurfBoardHandle PTR [edi]).SurfB1
			mov hBmpSurfB, eax
			mov eax, (SurfBoardHandle PTR [edi]).SurfBM1
			mov hBmpSurfBM, eax
		.elseif aniTimer == 16
			mov eax, (SurfBoardHandle PTR [edi]).SurfB2
			mov hBmpSurfB, eax
			mov eax, (SurfBoardHandle PTR [edi]).SurfBM2
			mov hBmpSurfBM, eax
		.endif
		ret
	UpdateSurfBoard ENDP

	;------------------------------------------
	; RenderWater - 绘制水面
	; @param
	; @return void
	;------------------------------------------
	RenderWater PROC uses eax ebx ecx edx esi edi 

		; 画水面
		; -------------
		; | 0 | 1 | 2 |
		; -------------
		; | 3 | 4 | 5 |
		; -------------
		; | 6 | 7 | 8 |
		; -------------

		; 画水面4
		invoke Bmp2Buffer, hBmpWater, water.x, water.y, 768, 768, SRCPAINT
		
		; 画水面7
		mov eax, water.y
		add eax, 768
		invoke Bmp2Buffer, hBmpWater, water.x, eax, 768, 768, SRCPAINT

		; 画水面3
		mov eax, water.x
		sub eax, 768
		invoke Bmp2Buffer, hBmpWater, eax, water.y, 768, 768, SRCPAINT

		; 画水面5
		mov eax, water.x
		add eax, 768
		invoke Bmp2Buffer, hBmpWater, eax, water.y, 768, 768, SRCPAINT

		; 画水面6
		mov eax, water.x
		sub eax, 768
		mov ecx, water.y
		add ecx, 768
		invoke Bmp2Buffer, hBmpWater, eax, ecx, 768, 768, SRCPAINT

		; 画水面8
		mov eax, water.x
		add eax, 768
		mov ecx, water.y
		add ecx, 768
		invoke Bmp2Buffer, hBmpWater, eax, ecx, 768, 768, SRCPAINT
		ret
	RenderWater ENDP
	
	;------------------------------------------
	; UpdateSpeed - 改变速度
	; @param
	; @return void
	;------------------------------------------
	UpdateSpeed PROC uses eax ebx ecx edx esi edi 
		mov eax, 0
		mov ecx, 0
		.if player_action == 0 || player_action == 6 || player_action == 7 || player_action == 8
			mov eax, 0
			mov ecx, 0
		.elseif player_action == 1
			add eax, 3
			sub ecx, 3
		.elseif player_action == 2
			add eax, 2
			sub ecx, 4
		.elseif player_action == 3
			sub ecx, 5
			.if player_state == 1
				mov ecx, 8
			.endif
		.elseif player_action == 4
			sub eax, 2
			sub ecx, 4
		.elseif player_action == 5
			sub eax, 3
			sub ecx, 3
		.else
			sub ecx, 8
		.endif
		mov speed.x, eax
		mov speed.y, ecx
		ret
	UpdateSpeed ENDP
	
	;------------------------------------------
	; UpdateWater - 更新波浪的位置
	; @param
	; @return void
	;------------------------------------------
	UpdateWater PROC uses eax ebx ecx edx esi edi 
		mov eax, water.x
		mov ecx, water.y
		add eax, speed.x
		add ecx, speed.y
		; 循环恢复
		cmp eax, -752 ; x0 - 768 = 16 - 768
		jg Update1
		mov eax, 16
		Update1:
		cmp eax, 784 ; x0 + 768 = 16 + 768
		jl Update2
		mov eax, 16
		Update2:
		cmp ecx, -852 ; y0 - 768 = -84 - 768
		jg Update3
		mov ecx, -84
		Update3:
		mov water.x, eax 
		mov water.y, ecx
		ret
	UpdateWater ENDP

	;------------------------------------------
	; GetRandPosX - 生成随机的X坐标 给障碍物用的
	; @param
	; @return void
	;------------------------------------------
	GetRandPosX PROC uses ebx ecx edx esi edi
		invoke GetRandom, 0, 17
		shl eax, 6
		.if player_action == 3
			mov ecx, -240
		.elseif player_action == 1 || player_action == 2
			mov ecx, -752
		.elseif player_action == 4 || player_action == 5
			mov ecx, 272
		.endif
		add ecx, eax
		mov eax, ecx
		ret
	GetRandPosX ENDP
	
	;------------------------------------------
	; GenerateSlowD - 生成slowdown
	; @param
	; @return void
	;------------------------------------------
	GenerateSlowD PROC uses eax ebx ecx edx esi edi
		mov eax, slowdCount
		cmp eax, MAXSLOWD
		jg GenerateSlowdRet
		cmp player_action, 0
		je GenerateSlowdRet
		cmp slowdInterval, 0
		jne GenerateSlowdEnd
		; 获得最新的一个Slowd
		mov edi, offset slowdownPos
		mov esi, slowdCount
		imul esi, TYPE PosSlowdown
		add edi, esi

		; 生成一个slowdown
		; mov esi, 0
		; .while esi < 3 ; 生成2个
			invoke GetRandom, 0, 8
			mov (PosSlowdown PTR [edi]).tp, eax
			imul eax, TYPE SlowdownHandle
			mov ebx, offset slowdownAni
			add ebx, eax
			mov eax, (SlowdownHandle PTR [ebx]).SlowD0
			mov (PosSlowdown PTR [edi]).hBmp, eax
			mov (PosSlowdown PTR [edi]).y, 700
			invoke GetRandPosX
			mov (PosSlowdown PTR [edi]).x, eax
			inc slowdCount
			; add edi, TYPE PosSlowdown
			; inc esi
		; .endw

		invoke GetRandom, 20, 30
		mov slowdInterval, eax
		GenerateSlowdEnd:
			dec slowdInterval
		GenerateSlowdRet:
			xor eax,eax
			ret
	GenerateSlowD ENDP

	;------------------------------------------
	; GetSlowdAniHandle - 获得slowdown的动画句柄
	; @param
	; @return void
	;------------------------------------------
	GetSlowdAniHandle PROC uses ebx ecx edx esi edi tp:DWORD, hBmp:DWORD
		; 暂时只是更新一个的动画
		mov edi, offset slowdownAni
		mov esi, tp
		imul esi, TYPE SlowdownHandle
		add edi, esi
		.if aniTimer == 0
			mov eax, (SlowdownHandle PTR [edi]).SlowD0
		.elseif aniTimer == 8
			mov eax, (SlowdownHandle PTR [edi]).SlowD1
		.elseif aniTimer == 16
			mov eax, (SlowdownHandle PTR [edi]).SlowD2
		.else
			mov eax, hBmp ; 否则等于之前的帧
		.endif
		ret
	GetSlowdAniHandle ENDP
	
	;------------------------------------------
	; UpdateSlowD - 更新slowdown的位置
	; @param
	; @return void
	;------------------------------------------
	UpdateSlowD PROC uses eax ebx ecx edx esi edi 
		mov edi, offset slowdownPos
		mov esi, 0
		.while esi < slowdCount
			mov eax, (PosSlowdown PTR [edi]).x
			mov ecx, (PosSlowdown PTR [edi]).y
			add eax, speed.x
			add ecx, speed.y
			; 这里暂时不做回收机制
			mov (PosSlowdown PTR [edi]).x, eax
			mov (PosSlowdown PTR [edi]).y, ecx
			invoke GetSlowdAniHandle, (PosSlowdown PTR [edi]).tp, (PosSlowdown PTR [edi]).hBmp
			mov (PosSlowdown PTR [edi]).hBmp, eax
			add edi, TYPE PosSlowdown
			inc esi
		.endw

		invoke GetSlowdAniHandle, 0, hBmpSlowd
		mov hBmpSlowd, eax
		xor eax, eax
		ret
	UpdateSlowD ENDP

	;------------------------------------------
	; RenderSlowd - 绘制slowdown
	; @param
	; @return void
	;------------------------------------------
	RenderSlowd PROC uses eax ebx ecx edx esi edi 
		mov edi, offset slowdownPos
		mov esi, 0
		; 暂时先只是加载一张图片
		.while esi < slowdCount
			invoke Bmp2Buffer, (PosSlowdown PTR [edi]).hBmp, (PosSlowdown PTR [edi]).x, (PosSlowdown PTR [edi]).y, 64, 64, SRCPAINT
			add edi, TYPE PosSlowdown
			inc esi
		.endw
		ret
	RenderSlowd ENDP

	;------------------------------------------
	; RecycleSlowd - 回收slowdown
	; @param
	; @return void
	;------------------------------------------
	RecycleSlowd PROC uses eax ebx ecx edx esi edi
		; 双指针
		mov edi, offset slowdownPos
		xor esi, esi
		.while esi < slowdCount
			mov eax, (PosSlowdown PTR [edi]).y
			add eax, 64
			cmp eax, 0
			jg RecycleSlowdEnd
			; 开始回收，即重新生成
			mov (PosSlowdown PTR [edi]).y, 700
			invoke GetRandPosX
			mov (PosSlowdown PTR [edi]).x, eax
			RecycleSlowdEnd:
			inc esi
			add edi, TYPE PosSlowdown
		.endw
		xor eax,eax
		ret
	RecycleSlowd ENDP

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
		.elseif uMsg==WM_KEYDOWN
			invoke PlayerAction, wParam
		.elseif uMsg == WM_PAINT
			invoke Bmp2Buffer, hBmpBack, 0, 0, stRect.right, stRect.bottom, SRCCOPY
			; invoke RenderWater
			invoke RenderSlowd
			
			invoke Bmp2Buffer, hBmpSlowd, 0, 0, 64, 64, SRCPAINT
			
			; 400 - 32 = 368
			; 300 - 32 = 268
			; 268 - 32 = 236
			invoke Bmp2Buffer, hBmpSurfBM, 368, 236, 64, 64, SRCAND
			invoke Bmp2Buffer, hBmpSurfB, 368, 236, 64, 64, SRCPAINT
			invoke Bmp2Buffer, hBmpPlayerM, 368, 236, 64, 64, SRCAND
			invoke Bmp2Buffer, hBmpPlayer, 368, 236, 64, 64, SRCPAINT
			
			invoke Buffer2Window
		.elseif uMsg ==WM_TIMER ;刷新
			invoke InvalidateRect,hWnd,NULL,FALSE
			invoke UpdateSpeed
			invoke UpdateAniTimer
			invoke UpdateSurfBoard
			; invoke UpdateWater
			invoke GenerateSlowD
			invoke UpdateSlowD
			.if slowdCount > 2
				invoke RecycleSlowd
			.endif
			
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
				100,100,800,700,\	;窗口的位置和大小
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

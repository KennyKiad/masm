include CTimer.asm
include CIMG.asm
include CTTF.asm

CApp_onExecute		proto
;CApp_GameController	proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.const
	ROOM_WIDTH				equ 1440
	ROOM_HEIGHT				equ 900 - 60		;464
	;WINDOW_WIDTH			equ 179
	;WINDOW_HEIGHT			equ 59

	STATE_NULL				equ 0
	STATE_TITLE				equ 1
	STATE_ROOM_1			equ 2
	STATE_ROOM_2			equ 3
	STATE_ROOM_3			equ 4
	STATE_EXIT				equ -1
	
	IDI_BACKGROUND			equ 100	
	IDF_GOTHAM				equ 106
	IDF_BAHAMAS				equ 107
	IDF_CITY				equ 108


.data
	id_state 		dd STATE_NULL
	next_state		dd STATE_NULL
	;
	hWnd			dd 0
	hInstance		dd 0
	window			dd 0
	screen			dd 0
	screenBmp		dd 0
	bmpOld			dd 0
	
	id_timer		dd 0
	minResolution	dd 0
	
	keys			db 256 dup(0)
	;
	include CScore.asm
	include CEntity.asm
	include CRoom.asm
	include CApp_onInit.asm
	include CApp_onStart.asm
	include CApp_onQuit.asm
	include CApp_onLoop.asm
	include CApp_onRender.asm
	include CApp_onEvent.asm
	include CApp_updateState.asm
	include CApp_onGame.asm
	

.code


CApp_onExecute proc uses ebx esi edi
	LOCAL dwReturnValue:DWORD
	
	mov dword ptr[dwReturnValue],STATE_NULL
	fn CApp_onInit
	or eax,eax
	jne @F
	fn MessageBox,0,"Game Initialize failed!","Error!",MB_ICONERROR
	xor eax,eax
	dec eax
	mov dword ptr[dwReturnValue],eax
	jmp @@ret
@@:
	fn CApp_onStart
	;=====================================
	;               GAME LOOP
	;=====================================
	
	fn CApp_onGame
	
	fn CApp_onQuit
	
@@ret:
	mov eax,dword ptr[dwReturnValue]
	ret
CApp_onExecute endp

;CApp_GameController	proc uses ebx esi edi idTimer:DWORD,uMsg:DWORD,dwUser:DWORD,res1:DWORD,res2:DWORD
;	
;	
;	fn CApp_onLoop
;	fn CApp_onRender
;	fn CApp_onEvent
;	fn CApp_updateState
;	
;	ret
;CApp_GameController endp
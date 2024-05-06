CRoom_CreateRoom			proto :DWORD
CRoom_GenerateRoom			proto :DWORD,:DWORD
CRoom_VirtualAlloc			proto
CRoom_VirtualFree			proto
CRoom_LoadBackground		proto :DWORD,:DWORD

CRoom_onLoop				proto
CRoom_onRender				proto
CRoom_onEvent				proto :DWORD
cRoom_onQuit				proto
CRoom_onKeyDown				proto :DWORD,:DWORD
CRoom_onExit 				proto 
CRoom_onKeyEnter			proto :DWORD

CRoom_move_camera			proto :DWORD
CRoom_set_camera			proto :DWORD,:DWORD,:DWORD,:DWORD

CGameRoom_onLoop			proto 
CGameRoom_onKeyDown			proto :DWORD,:DWORD
CGameRoom_onEvent			proto :DWORD
CGameRoom_onRender			proto 
CGameRoom_DrawTextMain		proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CGameRoom_DrawHighScore		proto :DWORD,:DWORD
CGameRoom_DrawScore			proto
CGameRoom_DrawLevel			proto
CGameRoom_DrawFPS			proto
CGameRoom_DrawText			proto :DWORD

CTitleRoom_onRender			proto
CCompletedRoom_onRender		proto

.const
LEVEL_BONUS 	equ 2000

.data
lpvBase			dd 0
background		dd 0
camera			RECT <0,0,ROOM_WIDTH,ROOM_HEIGHT>
horSpeed		dd 0
verSpeed		dd 0
completed		dd 0
failed			dd 0
ticks			dd 0

szEnter			db "Press Enter to Continue.",0
szTitle			db "Press any Key to Continue.",0

szBahamas		db "Bahamas",0
szCity			db "City",0

szFailed		db "Mission Failed!",0
szCompleted		db "Mission Completed!",0
szCongratz		db "Congrats! You've delivered all the mail!",0

;funcRoomRender	dd offset CRoom_onRender
;funcRoomLoop	dd offset CRoom_onLoop
;funcRoomEvent	dd offset CRoom_onEvent
;funcRoomQuit	dd offset CRoom_onQuit
;funcRoomKeyDown dd offset CRoom_onKeyDown

.code

CRoom_VirtualAlloc proc uses ebx esi edi
	LOCAL sSysInfo:SYSTEM_INFO
	
	fn GetSystemInfo,addr sSysInfo
	fn VirtualAlloc,0,sSysInfo.dwPageSize,MEM_COMMIT,PAGE_READWRITE
	mov dword ptr[lpvBase],eax
	or eax,eax
	jne @F
	fn MessageBox,0,"Failed Allocate Memory","Error!",MB_ICONERROR
	fn ExitProcess,-1
@@:
	mov dword ptr[eax],offset CRoom_onRender
	mov dword ptr[eax+4],offset CRoom_onLoop
	mov dword ptr[eax+8],offset CRoom_onEvent
	mov dword ptr[eax+12],offset CRoom_onQuit
	mov dword ptr[eax+16],offset CRoom_onKeyDown
	
	ret
CRoom_VirtualAlloc endp

CRoom_VirtualFree proc uses ebx esi edi
	
	fn VirtualFree,lpvBase,0,MEM_RELEASE
	
	ret
CRoom_VirtualFree endp

CRoom_GenerateRoom proc uses ebx esi edi ast:DWORD,moon:DWORD
	
	;Create Asteroids
	xor ebx,ebx
	jmp @@For
@@In:
	
	fn RangeRand,1,1441
	dec eax
	push eax
	fn RangeRand,1,901
	dec eax
	mov ecx,eax
	pop eax
	fn CEntity_Create,ASTEROID,183,10,50,50,eax,ecx
	
	inc ebx
	
@@For:
	cmp ebx,ast
	jl @@In
	
	;Create Moons
	xor ebx,ebx
	jmp @@For2
	
@@In2:
	
	fn RangeRand,1,1441
	dec eax
	push eax
	fn RangeRand,1,901
	dec eax
	mov ecx,eax
	pop eax
	fn CEntity_Create,MOON,8,0,64,64,eax,ecx
	
	inc ebx
	
@@For2:
	cmp ebx,moon
	jl @@In2
	
	ret
CRoom_GenerateRoom endp

CRoom_CreateRoom proc uses ebx esi edi idRoom:DWORD
	
	and dword ptr[completed],0
	and dword ptr[failed],0
	mov dword ptr[ticks],15
	switch idRoom
	
		case STATE_TITLE
			
			and dword ptr[highestScore],0
			
			fn CRoom_GenerateRoom,10,0
			fn CEntity_Create,ID_TITLE,1,0,500,300,500,250
			fn CRoom_GenerateRoom,0,10
			
			mov eax,lpvBase
			mov dword ptr[eax],offset CTitleRoom_onRender
		
		default
			fn CScore_ResetScore,1000
			
			mov ecx,dword ptr[id_state]
			
			
			
			fn CRoom_GenerateRoom,ecx,ecx
			
			
			fn CEntity_Create,BASE_MOON,8,0,64,64,300,120
			
			fn CEntity_Create,PLAYER,72,0,48,48,10,10
			
			
			mov eax,lpvBase
			mov dword ptr[eax],offset CGameRoom_onRender
			mov dword ptr[eax+4],offset CGameRoom_onLoop
			mov dword ptr[eax+8],offset CGameRoom_onEvent
			mov dword ptr[eax+16],offset CGameRoom_onKeyDown
;			
;		case STATE_ROOM_1
;			
;			fn CScore_ResetScore,1000
;			
;			fn CRoom_GenerateRoom,ROOM_WIDTN / 20,ROOM_WIDTN / 20
;			
;			
;			fn CEntity_Create,BASE_MOON,8,0,64,64,300,120
;			
;			fn CEntity_Create,PLAYER,72,0,48,48,10,10
;			
;			
;			mov eax,lpvBase
;			mov dword ptr[eax],offset CGameRoom_onRender
;			mov dword ptr[eax+4],offset CGameRoom_onLoop
;			mov dword ptr[eax+8],offset CGameRoom_onEvent
;			mov dword ptr[eax+16],offset CGameRoom_onKeyDown
;			
;		case STATE_ROOM_2
;			
;			fn CScore_ResetScore,1000
;			
;			fn CRoom_GenerateRoom,60,50
;			
;			
;			fn CEntity_Create,BASE_MOON,8,0,64,64,300,120
;			
;			fn CEntity_Create,PLAYER,72,0,48,48,10,10
;			
;			
;			mov eax,lpvBase
;			mov dword ptr[eax],offset CGameRoom_onRender
;			mov dword ptr[eax+4],offset CGameRoom_onLoop
;			mov dword ptr[eax+8],offset CGameRoom_onEvent
;			mov dword ptr[eax+16],offset CGameRoom_onKeyDown
;			
;		case STATE_ROOM_3
;			
;			fn CScore_ResetScore,1000
;			
;			fn CRoom_GenerateRoom,80,50
;			
;			
;			fn CEntity_Create,BASE_MOON,8,0,64,64,300,120
;			
;			fn CEntity_Create,PLAYER,72,0,48,48,10,10
;			
;			
;			mov eax,lpvBase
;			mov dword ptr[eax],offset CGameRoom_onRender
;			mov dword ptr[eax+4],offset CGameRoom_onLoop
;			mov dword ptr[eax+8],offset CGameRoom_onEvent
;			mov dword ptr[eax+16],offset CGameRoom_onKeyDown
;			
;		case STATE_ROOM_COMPLETED
;		
;			fn CScore_ResetScore,2000
;			
;			fn CRoom_GenerateRoom,4,0
;			
;			mov eax,lpvBase
;			mov dword ptr[eax],offset CCompletedRoom_onRender
;			mov dword ptr[eax+4],offset CRoom_onLoop
;			mov dword ptr[eax+8],offset CRoom_onEvent
;			mov dword ptr[eax+16],offset CRoom_onKeyDown
			
	endsw
	ret
CRoom_CreateRoom endp

CRoom_onRender proc uses ebx edi esi
	
	;invoke QueryPerformanceCounter,offset seconds
	
	fn CIMG_DrawBMP,background,screen,camera.left,camera.top,camera.right,camera.bottom
	
	
	mov esi,pEntity
	xor ebx,ebx
	assume esi: PTR ENTITY
	jmp @@For
@@In:	
	
	mov eax,dword ptr[esi].id
	.if eax != ID_NONE
		
		mov eax,dword ptr[esi].fRender
		push esi
		call eax
	.endif
	
	inc ebx
	add esi,sizeof ENTITY
@@For:
	cmp ebx,entity_num
	jl @@In
	
	assume esi:nothing
	
;	invoke QueryPerformanceCounter,offset seconds2
;	fld seconds2
;	fld seconds
;	fsubp st(1),st
;	
;	fld frequency
;	fdivp st(1),st
;	fstp st
;	push 1
;	fild dword ptr[esp]
;	fdiv st,st(1)
	
	ret
CRoom_onRender endp

CGameRoom_onRender proc uses ebx esi edi
	
	fn CRoom_onRender
	
	
	.if dword ptr[failed] == 1 || dword ptr[completed] == 1
		
		.if dword ptr[failed] == 1
	
			fn CGameRoom_DrawTextMain,offset szBahamas,offset szFailed,IDF_BAHAMAS,32,00434DDh
		
		.elseif dword ptr[completed] == 1
	
			fn CGameRoom_DrawTextMain,offset szBahamas,offset szCompleted,IDF_BAHAMAS,28,0080FF80h
		
		.endif
		
		fn CGameRoom_DrawHighScore,18,0
		
		fn CGameRoom_DrawText,offset szEnter
		
	.else
		fn CGameRoom_DrawScore
		
		fn CGameRoom_DrawLevel
		
		fn CGameRoom_DrawFPS
		
	.endif
	
	ret
CGameRoom_onRender endp

CTitleRoom_onRender proc uses ebx esi edi
	
	fn CRoom_onRender
	
	fn CGameRoom_DrawText,offset szTitle
	
	ret
CTitleRoom_onRender endp

CCompletedRoom_onRender proc uses ebx esi edi
	
	fn CRoom_onRender
	
	fn CGameRoom_DrawTextMain,offset szBahamas,offset szCongratz,IDF_BAHAMAS,24,0080FF80h
	
	fn CGameRoom_DrawHighScore,20,1
	
	fn CGameRoom_DrawText,offset szTitle
	
	ret
CCompletedRoom_onRender endp

CGameRoom_DrawTextMain proc uses ebx esi edi lpFontName:DWORD,lpText:DWORD,idFont:DWORD,FontSize:DWORD,color:DWORD
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	LOCAL xofText:DWORD
	
	
	fn CTTF_LoadFontMem,hInstance,idFont
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,lpFontName,FontSize
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret
	
	fn CTTF_GetTextWidth,screen,eax,lpText
	mov ebx,ROOM_WIDTH
	sub ebx,eax
	shr ebx,1
	mov dword ptr[xofText],ebx
	
	fn CTTF_GetTextHeight,screen,hFont,lpText
	mov ebx,ROOM_HEIGHT
	shr ebx,1
	sub ebx,eax
	
	fn CTTF_TextOut,screen,hFont,lpText,xofText,ebx,color
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	ret
CGameRoom_DrawTextMain endp

CGameRoom_DrawHighScore proc uses ebx esi edi FontSize:DWORD,flag:DWORD
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	LOCAL xofText:DWORD
	
	
	
	fn CTTF_LoadFontMem,hInstance,IDF_CITY
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,offset szCity,FontSize
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret

	cmp dword ptr[flag],0
	jne @F
	fn CScore_GetHighScore
	mov esi,eax
	jmp @@next
@@:
	fn CScore_GetHighestScore
	mov esi,eax
	
@@next:
	fn CTTF_GetTextWidth,screen,hFont,esi
	mov ebx,ROOM_WIDTH
	sub ebx,eax
	shr ebx,1
	mov dword ptr[xofText],ebx
	
	fn CTTF_GetTextHeight,screen,hFont,esi
	mov ebx,ROOM_HEIGHT
	shr ebx,1
	add ebx,eax
	
	fn CTTF_TextOut,screen,hFont,esi,xofText,ebx,0000FFFFh
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	
	ret
CGameRoom_DrawHighScore endp

CGameRoom_DrawScore proc uses ebx esi edi
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	
	
	fn CTTF_LoadFontMem,hInstance,IDF_CITY
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,offset szCity,18
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret

	fn CScore_GetScore
	
	mov ebx,ROOM_HEIGHT
	
	sub ebx,40
	
	fn CTTF_TextOut,screen,hFont,eax,10,ebx,0000FFFFh
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	
	ret
CGameRoom_DrawScore endp

CGameRoom_DrawLevel proc uses ebx esi edi 
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	
	fn CTTF_LoadFontMem,hInstance,IDF_CITY
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,offset szCity,18
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret

	szText szLevelFrm,"Level: %d"
	mov ebx,id_state
	dec ebx
	fn wsprintf,offset szBuffer,offset szLevelFrm,ebx
	
	fn CTTF_GetTextWidth,screen,hFont,offset szBuffer
	mov ecx,ROOM_WIDTH
	add eax,10
	sub ecx,eax
	
	mov ebx,ROOM_HEIGHT
	
	sub ebx,40
	
	fn CTTF_TextOut,screen,hFont,offset szBuffer,ecx,ebx,0000FFFFh
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	
	ret
CGameRoom_DrawLevel endp

CGameRoom_DrawFPS proc uses ebx esi edi
	
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	
	fn CTTF_LoadFontMem,hInstance,IDF_CITY
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,offset szCity,12
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret

	szText szFPSFrm,"FPS: %d"
	mov ebx,time
	fn wsprintf,offset szBuffer,offset szFPSFrm,ebx
	
	fn CTTF_GetTextWidth,screen,hFont,offset szBuffer
	mov ecx,ROOM_WIDTH
	add eax,10
	sub ecx,eax
	
	
	
	fn CTTF_TextOut,screen,hFont,offset szBuffer,ecx,0,0000FFFFh
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	
	ret
CGameRoom_DrawFPS endp

CGameRoom_DrawText proc uses ebx esi edi lpText:DWORD
	LOCAL hRes:DWORD
	LOCAL hFont:DWORD
	LOCAL xofText:DWORD
	
	szText szFontNameC,"City"
	
	mov esi,lpText
	
	fn CTTF_LoadFontMem,hInstance,IDF_CITY
	mov dword ptr[hRes],eax
	
	fn CTTF_CreateFont,screen,offset szFontNameC,20
	mov dword ptr[hFont],eax
	or eax,eax
	je @@ret
	
	fn CTTF_GetTextWidth,screen,eax,esi
	mov ebx,ROOM_WIDTH
	sub ebx,eax
	shr ebx,1
	mov dword ptr[xofText],ebx
	
	fn CTTF_GetTextHeight,screen,hFont,esi
	mov ebx,ROOM_HEIGHT
	add eax,10
	sub ebx,eax
	
	fn CTTF_TextOut,screen,hFont,esi,xofText,ebx,0000FFFFh
	fn CTTF_DeleteFont,hFont
	
@@ret:
	fn CTTF_UnloadFontMem,hRes
	
	ret
CGameRoom_DrawText endp

CGameRoom_onLoop proc uses ebx esi edi
	
	fn CRoom_onLoop
	
	xor ebx,ebx
	mov esi,pEntity
	assume esi:PTR ENTITY
	jmp @@for
@@in:
	
	mov eax,dword ptr[esi].id
	
	.if eax == PLAYER
		
		.if dword ptr[esi].sprite == 0
			
			fn CEntity_LoadSprite,hInstance,IDI_PLAYER
			mov dword ptr[esi].sprite,eax
			
		.endif
		
		jmp @@ret
		
	.endif
	
	add esi,sizeof ENTITY
	inc ebx
@@for:
	cmp ebx,entity_num
	jl @@in	

@@ret:
	assume esi:nothing
	ret
CGameRoom_onLoop endp

CRoom_onLoop proc uses ebx esi edi
	
	
	xor ebx,ebx
	jmp @@For
@@In:	
	mov esi,pEntity
	mov eax,sizeof ENTITY
	mul ebx
	add esi,eax
	
	mov eax,dword ptr[esi+17]
	.if eax != ID_NONE
		
		mov eax,dword ptr[esi+65]	;fLoop
		push esi
		call eax
	.endif
	
	inc ebx
	add esi,sizeof ENTITY
@@For:
	cmp ebx,entity_num
	jl @@In
	
	ret
CRoom_onLoop endp

CRoom_onEvent proc uses ebx esi edi idState:DWORD
	LOCAL dwRetVal:DWORD
	mov dword ptr[dwRetVal],STATE_NULL
	
	;fn Keyboard_check
	lea eax,dword ptr[keys]
	mov al,byte ptr[eax+VK_ESCAPE]
	and al,80h
	
		.if al == 1
			
			fn CRoom_onExit
			mov dword ptr[dwRetVal],eax
			
		.else
			push idState
			push eax
			;call dword ptr[funcRoomKeyDown]
			mov eax,lpvBase
			call dword ptr[eax+16]
			
			mov dword ptr[dwRetVal],eax
		.endif

	
	mov eax,dword ptr[dwRetVal]
	ret
CRoom_onEvent endp

CGameRoom_onEvent proc uses ebx edi esi idState:DWORD
	
	cmp dword ptr[completed],1
	je @@ret
	
	fn CEntity_IsEntityExist,MOON
	or eax,eax
	jne @@next
	fn CEntity_GetEntity,PLAYER
	or eax,eax
	je @F
	mov dword ptr[eax+17],PLAYER_COMPLETED
@@:	
	dec dword ptr[ticks]
	cmp dword ptr[ticks],0
	jg @@ret
	mov dword ptr[completed],1
	
	add dword ptr[score],LEVEL_BONUS
	mov ebx,dword ptr[score]
	cmp ebx,dword ptr[highestScore]
	jle @@ret
	mov dword ptr[highestScore],ebx
	
	jmp @@ret
	
@@next:
	cmp dword ptr[failed],1
	je @@ret
	
	fn CEntity_IsEntityExist,EXPLOSION
	or eax,eax
	je @@ret
	
	dec dword ptr[ticks]
	cmp dword ptr[ticks],0
	jg @@ret
	
	mov dword ptr[failed],1
	;
	;
	
@@ret:
	fn CRoom_onEvent,idState
	ret
CGameRoom_onEvent endp

CRoom_onKeyDown proc uses ebx esi edi dwKey:DWORD,idState:DWORD
	LOCAL dwRetVal:DWORD
	
	mov dword ptr [dwRetVal],STATE_NULL
	
	mov eax,dword ptr[dwKey+20h]
	and eax,80h
	
	or eax,eax
	jne @@ret
	mov eax,dword ptr[idState]
	inc eax
	;cmp eax,STATE_ROOM_COMPLETED
	;jg @F
	mov dword ptr[dwRetVal],eax
	jmp @@ret	
;@@:
	;mov dword ptr[dwRetVal],STATE_TITLE
	
@@ret:
	mov eax,dword ptr[dwRetVal]
	ret
CRoom_onKeyDown endp

CRoom_onKeyEnter proc uses ebx esi edi idState:DWORD
	LOCAL dwReturnValue:DWORD
	
	and dword ptr[dwReturnValue],0
	
	cmp dword ptr[failed],0
	je @F
	mov ebx,dword ptr[idState]
	mov dword ptr[dwReturnValue],ebx
	jmp @@ret
@@:
	cmp dword ptr[completed],0
	je @@ret
	
	mov ebx,dword ptr[idState]
	inc ebx
	mov dword ptr[dwReturnValue],ebx
		
@@ret:
	mov eax,dword ptr[dwReturnValue]
	ret
CRoom_onKeyEnter endp

CGameRoom_onKeyDown proc uses ebx edi esi dwKey:DWORD,idState:DWORD
	LOCAL dwRetVal:DWORD
	
	mov dword ptr [dwRetVal],STATE_NULL
	
	mov al,byte ptr[dwKey+75]
	and al,80h
	.if al == 1
		fn CPlayer_onKeyLeft
	.endif
	
;	switch dwKey
;	
;		case 75			; LeftArrow
;		
;			
;			fn CPlayer_onKeyLeft
;			
;		case 77			; RightArrow
;			
;			fn CPlayer_onKeyRight
;			
;		case VK_SPACE
;			fn CPlayer_onKeySpace
;			
;		case VK_RETURN
;		
;			fn CRoom_onKeyEnter,idState
;			mov dword ptr[dwRetVal],eax
;			
;		case 'n'
;		
;			mov ebx,dword ptr[idState]
;			inc ebx
;			mov dword ptr[dwRetVal],ebx
;	endsw
	
@@ret:
	mov eax,dword ptr[dwRetVal]
	ret
CGameRoom_onKeyDown endp

CRoom_move_camera proc uses ebx esi edi lvlWidth:DWORD
	
	mov eax,dword ptr[horSpeed]
	add dword ptr[camera.left],eax         ; x coord
	
	mov eax,dword ptr[verSpeed]
	add dword ptr[camera.top],eax
	
	mov eax,dword ptr[camera.left]
	add eax,dword ptr[camera.right]
	cmp eax,lvlWidth
	jge @F
	jmp @@ret
@@:
	mov eax,dword ptr[lvlWidth]
	sub eax,dword ptr[camera.right]
	mov dword ptr[camera.left],eax
@@ret:
	ret
CRoom_move_camera endp

CRoom_set_camera proc uses ebx esi edi left:DWORD,top:DWORD,right:DWORD,bottom:DWORD
	
	fn SetRect,offset camera,left,top,right,bottom
	
	ret
CRoom_set_camera endp

CRoom_onQuit proc uses ebx esi edi
	
	mov eax,dword ptr[pEntity]
	or eax,eax
	je @@ret
	xor ebx,ebx
	mov esi,pEntity
	assume esi:PTR ENTITY
	jmp @@for
@@in:
	
	mov eax,dword ptr[esi].sprite
	fn DeleteObject,eax
	add esi,sizeof ENTITY
	inc ebx
	
@@for:
	
	cmp ebx,entity_num
	jl @@in
	assume esi:nothing
	fn LocalFree,pEntity
	mov dword ptr[pEntity],0
	mov dword ptr[entity_num],0
	
@@ret:
	ret
CRoom_onQuit endp

CRoom_onExit proc
	
	mov eax,STATE_EXIT
	
	ret
CRoom_onExit endp

CRoom_LoadBackground proc uses ebx esi edi hInst:DWORD,idBmp:DWORD
	
	fn CIMG_LoadBMP,hInst,idBmp
	mov dword ptr[background],eax
	or eax,eax
	jne @F
	fn MessageBox,0,"Load Background failed.","Error!",MB_ICONERROR
	fn ExitProcess,-1
@@:
	
	
	ret
CRoom_LoadBackground endp
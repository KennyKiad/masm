;				Public Functions class Entity
CEntity_Create				proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CEntity_onRender			proto :DWORD
CEntity_onLoop				proto :DWORD
CEntity_IsCollide			proto :DWORD,:DWORD
CEntity_FillRect			proto :DWORD,:DWORD
CEntity_IsEntityExist		proto :DWORD
CEntity_GetEntity			proto :DWORD

;				Privite Functions class Entity

CEntity_LoadSprite			proto :DWORD,:DWORD
CEntity_GetCurrentFrame 	proto :DWORD
CEntity_SetSprite 			proto :DWORD,:DWORD,:DWORD,:DWORD
CEntity_SetCurrentFrame		proto :DWORD,:DWORD
CEntity_SetRandomFrame		proto :DWORD,:DWORD
CEntity_SetRandomFrameRate	proto :DWORD,:DWORD
CEntity_SetMask				proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CEntity_onAnimate			proto :DWORD
CEntity_onAnimationEnd		proto :DWORD
CEntity_onMove				proto :DWORD
CEntity_outsideRoom			proto :DWORD,:DWORD,:DWORD
CEntity_wrap				proto :DWORD,:DWORD,:DWORD
CEntity_JumpToPos			proto :DWORD,:DWORD,:DWORD


;------------------------- Fucntions Class Moon -------------------------
CMoon_onLoop				proto :DWORD

;------------------------- Functions Class Player -----------------------
CPlayer_onLoop				proto :DWORD
CPlayer_onKeyLeft			proto
CPlayer_onKeyRight			proto
CPlayer_onKeySpace			proto
CPlayer_onCollision			proto :DWORD

MemSet						proto :DWORD,:DWORD,:DWORD

SPRITE struct
	
	maxFrames 		dd ?
	currentFrame	dd ?   	;+4
	frameRate		dd ?	;+8
	oldTime			dd ?	;+12
	animate			db ?	;+16
	
SPRITE ends

ENTITY struct
	
				SPRITE <>
	id			dd ?		;+17
	sprite		dd ?		;+21
	x 			dd ?		;+25
	y 			dd ?		;+29
	w			dd ?		;+33
	h			dd ?		;+37
	speed		dd ?		;+41
	direction	dd ?		;+45
	rMask		RECT <>
	fLoop		dd ?
	fRender		dd ?
	Reserv		db 3 dup(?)
	
ENTITY ends

ID_NONE			= 0
MOON			= 1
BASE_MOON		= 2
ASTEROID		= 3
PLAYER			= 4
PLAYER_FLY		= 5
PLAYER_CRUSHED	= 6
PLAYER_COMPLETED = 7
EXPLOSION		= 8
ID_TITLE		= 9


.const
IDI_MOON  		equ 101
IDI_ASTEROID	equ 102
IDI_PLAYER		equ 103
IDI_PLAYER_FLY	equ 104
IDI_EXPLOSION	equ 105
IDI_TITLE		equ 109

MOON_BONUS		equ 500

.data

	pEntity			dd 0
	entity_num		dd 0
	basemoon		dd 0
	
	PI			REAL10 3.14159265r
	degree		REAL10 180.0r


.code

MemSet proc uses ebx esi edi pDest:DWORD,pSrc:DWORD,dwSize:DWORD
	
	mov edi,pDest
	mov esi,pSrc
	mov ecx,dwSize
	shr ecx,2
@@loop:
	lodsd
	stosd
	
	loop @@loop
	
	ret
MemSet endp

CEntity_Create proc uses ebx esi edi id:DWORD,maxFrame:DWORD,rate:DWORD,wd:DWORD,ht:DWORD,x:DWORD,y:DWORD
	LOCAL pTemp:DWORD
	
	.if pEntity == 0
		
		fn LocalAlloc,LPTR,sizeof ENTITY
		mov dword ptr[pEntity],eax
		
	.else
		
		mov eax,sizeof ENTITY
		mov ebx,entity_num
		inc ebx
		mul ebx
		;---------------------------
		fn LocalAlloc,LPTR,eax
		mov dword ptr[pTemp],eax
		
		mov eax,sizeof ENTITY
		mul entity_num
		fn MemSet,pTemp,pEntity,eax
		fn LocalFree,pEntity
		
		mov eax,dword ptr[pTemp]
		mov dword ptr[pEntity],eax
	.endif
	
	mov esi,pEntity
	mov eax,sizeof ENTITY
	mul entity_num
	add esi,eax
	
	
	assume esi:PTR ENTITY
	
	.if dword ptr[esi].sprite != 0
		
		mov eax,dword ptr[esi].sprite
		fn DeleteObject,eax
		
	.endif
	
	fn CEntity_SetSprite,esi,0,maxFrame,rate
	
	mov ebx,id
	mov dword ptr[esi].id,ebx
	
	.if ebx == MOON || ebx == BASE_MOON || ebx == ASTEROID
		
		mov dword ptr[esi].speed,2
		
		.if ebx == MOON || ebx == BASE_MOON
		
			fn CEntity_LoadSprite,hInstance,IDI_MOON
			mov dword ptr[esi].sprite,eax
			mov byte ptr[esi].animate,0
			fn CEntity_SetRandomFrame,esi,maxFrame
			fn CEntity_SetMask,esi,3,2,61,60
			
			
			
		.elseif ebx == ASTEROID
			fn RangeRand,1,3
			mov dword ptr[esi].speed,eax
			fn CEntity_LoadSprite,hInstance,IDI_ASTEROID
			mov dword ptr[esi].sprite,eax
			fn CEntity_SetRandomFrameRate,esi,rate
			fn CEntity_SetMask,esi,0,0,42,45
			
		.endif
		
		fn RangeRand,1,361
		dec eax
		mov dword ptr[esi].direction,eax
		
		mov dword ptr[esi].fLoop,offset CMoon_onLoop
		
	.elseif ebx == PLAYER
	
		mov dword ptr[esi].speed,3
		mov byte ptr[esi].animate,0
		
		fn CEntity_SetMask,esi,11,8,40,39	
		
		mov dword ptr[esi].fLoop,offset CPlayer_onLoop
		
		mov eax,esi
		sub eax,sizeof ENTITY
		mov dword ptr[basemoon],eax
		
	
	.elseif ebx == EXPLOSION
		
		fn CEntity_LoadSprite,hInstance,IDI_EXPLOSION
		mov dword ptr[esi].sprite,eax
		
		mov dword ptr[esi].fLoop,offset CEntity_onLoop
		
	.elseif ebx == ID_TITLE
	
		fn CEntity_LoadSprite,hInstance,IDI_TITLE
		mov dword ptr[esi].sprite,eax
		
		mov byte ptr[esi].animate,0
		
		mov dword ptr[esi].fLoop,offset CEntity_onLoop
		
	.endif
	
	mov dword ptr[esi].fRender,offset CEntity_onRender
	
	mov eax,wd
	mov dword ptr[esi].w,eax
	mov eax,ht
	mov dword ptr[esi].h,eax
	
	mov eax,x
	mov dword ptr[esi].x,eax
	mov eax,y
	mov dword ptr[esi].y,eax
	assume esi:nothing
	
	inc entity_num
	
	ret
CEntity_Create endp

CEntity_onRender proc uses ebx esi edi lpEntity:DWORD 
	
	mov edi,lpEntity
	.if dword ptr[edi+17] == ID_TITLE
		push 00FF4040h
	.else
		push 00FEFEFEh
		
	.endif
	
	push dword ptr[edi+37]		;h Sprite
	push dword ptr[edi+33]		;w Sprite
	push 0						;y Sprite
	
	;fn CEntity_getCurrentFrame,lpEntity
	mov eax,dword ptr[edi+4]		;current Frame
	mov ebx,dword ptr[edi+37]
	mul ebx
	;
	push eax					;x Sprite
	
	push dword ptr[edi+37]		;h Dest
	push dword ptr[edi+33]		;w Dest
	
	push dword ptr[edi+29]	;y Dest
	push dword ptr[edi+25]	;x Dest
	
	push screen
	push dword ptr[edi+21]
	call CIMG_DrawTransparentBmp
	
	ret
CEntity_onRender endp

CEntity_onLoop proc uses ebx esi edi lpEntity:DWORD
	
	
	fn CEntity_onAnimate,lpEntity
	
	ret
CEntity_onLoop endp

CMoon_onLoop proc uses ebx esi edi lpEntity:DWORD
	
	fn CEntity_onLoop,lpEntity
	
	fn CEntity_onMove,lpEntity
	
	fn CEntity_outsideRoom,lpEntity,ROOM_WIDTH,ROOM_HEIGHT
	or eax,eax
	je @@ret
	fn CEntity_wrap,lpEntity,ROOM_WIDTH,ROOM_HEIGHT
	
@@ret:
	ret
CMoon_onLoop endp

CPlayer_onLoop proc uses ebx esi edi lpEntity:DWORD
	
	mov esi,lpEntity
	; currentFrame = direction / 5    direction changes in CPlayer_onKeyLeft/Right
		
	mov eax,dword ptr[esi+45]		; direction
	mov edx,0CCCCCCCDh
	mul edx
	shr edx,2

	
	mov dword ptr[esi+4],edx		; currentFrame
	 
	.if dword ptr[esi+17] == PLAYER || dword ptr[esi+17] == PLAYER_COMPLETED
		
		mov edi,dword ptr[basemoon]
	
	
		mov eax,dword ptr[edi+25]		;x pos of basemoon
		add eax,8
		mov edx,dword ptr[edi+29]		;y pos of basemoon
		add edx,8
		
		fn CEntity_JumpToPos,esi,eax,edx
		jmp @@ExitFor
	
	
	
	@@ExitFor:
		.if dword ptr[esi+17] == PLAYER
			
			cmp dword ptr[score],0
			jle @@ret
			fn CScore_SetScore
			
		.endif		
		
	.elseif dword ptr[esi+17] == PLAYER_FLY
	
		fn CEntity_onMove,lpEntity
		fn CEntity_outsideRoom,lpEntity,ROOM_WIDTH,ROOM_HEIGHT
		or eax,eax
		je @F
		fn CEntity_wrap,lpEntity,ROOM_WIDTH,ROOM_HEIGHT
	@@:
		fn CPlayer_onCollision,lpEntity
		
	.endif
	
@@ret:
	ret
CPlayer_onLoop endp

CPlayer_onCollision proc uses ebx esi edi lpEntity:DWORD
	LOCAL rPlayer:RECT
	LOCAL rEntity:RECT
	
	mov esi,lpEntity
	assume esi:PTR ENTITY
	
	mov eax,dword ptr[esi].rMask.left
	add eax,dword ptr[esi].x
	mov rPlayer.left,eax
	
	mov eax,dword ptr[esi].rMask.top
	add eax,dword ptr[esi].y
	mov rPlayer.top,eax
	
	mov eax,dword ptr[esi].rMask.right
	add eax,rPlayer.left
	mov rPlayer.right,eax
	
	mov eax,dword ptr[esi].rMask.bottom
	add eax,rPlayer.top
	mov rPlayer.bottom,eax
	
	mov esi,pEntity
	xor ebx,ebx
	jmp @@for
@@in:
	.if dword ptr[esi].id == MOON
		
		fn CEntity_FillRect,addr rEntity,esi
		
		fn CEntity_IsCollide,addr rPlayer,addr rEntity
		or eax,eax
		je @@next
		
		mov dword ptr[esi].id,BASE_MOON
		mov dword ptr[basemoon],esi
		;
		;	adding score
		;
		
		add dword ptr[score],MOON_BONUS
	
		mov esi,lpEntity
		mov dword ptr[esi].id,PLAYER
		
		
		fn DeleteObject,[esi].sprite
		mov dword ptr[esi].sprite,0
		;mov dword ptr[addrPlayer],esi
		;
		;	Play music
		;
		jmp @@ret
		
	.elseif dword ptr[esi].id == ASTEROID
	
		fn CEntity_FillRect,addr rEntity,esi
	
		fn CEntity_IsCollide,addr rPlayer,addr rEntity
		or eax,eax
		je @@next
		mov esi,lpEntity
		mov dword ptr[esi].id,ID_NONE
		;mov dword ptr[addrPlayer],esi
		
		fn CEntity_Create,EXPLOSION,9,100,64,64,dword ptr[esi].x,dword ptr[esi].y
		;
		;	Music
		;
		jmp @@ret
	.endif
	
@@next:
	add esi,sizeof ENTITY
	inc ebx
@@for:
	cmp ebx,entity_num
	jl @@in
	
@@ret:
	assume esi:nothing
	ret
CPlayer_onCollision endp

CEntity_LoadSprite proc uses ebx esi edi hInst:DWORD,idRes:DWORD
	
	fn LoadBitmap,hInst,idRes
	or eax,eax
	jne @@ret
	fn MessageBox,0,"Load Sprite Failed","Error!",MB_ICONERROR
	fn ExitProcess,-1
@@ret:
	ret
CEntity_LoadSprite endp

CEntity_GetCurrentFrame proc lpEntity:DWORD
	
	mov eax,lpEntity
	mov eax,dword ptr[eax+4]
	
	ret
CEntity_GetCurrentFrame endp

CEntity_SetSprite proc uses ebx esi edi lpEntity:DWORD,currentFrame:DWORD,maxFrame:DWORD,rate:DWORD
	
	mov edi,lpEntity
	mov eax,currentFrame
	mov dword ptr[edi+4],eax
	
	mov eax,maxFrame
	mov dword ptr[edi],eax
	
	mov eax,rate
	mov dword ptr[edi+8],eax
	
	fn GetTickCount
	mov dword ptr[edi+12],eax
	
	mov byte ptr[edi+16],1
	
	ret
CEntity_SetSprite endp

CEntity_SetMask proc uses ebx esi edi lpEntity:DWORD,left:DWORD,top:DWORD,right:DWORD,bottom:DWORD
	
	mov esi,lpEntity
	assume esi:PTR ENTITY
	
	mov ebx,dword ptr[left]
	mov dword ptr[esi].rMask.left,ebx
	
	mov ebx,dword ptr[top]
	mov dword ptr[esi].rMask.top,ebx
	
	mov ebx,dword ptr[right]
	mov dword ptr[esi].rMask.right,ebx
	
	mov ebx,dword ptr[bottom]
	mov dword ptr[esi].rMask.bottom,ebx	
	
	
	assume esi:nothing
	
	ret
CEntity_SetMask endp

CEntity_SetCurrentFrame proc uses ebx esi edi lpEntity:DWORD,frame:DWORD
	
	mov edi,lpEntity
	
	mov ebx,frame
	mov dword ptr[edi+4],ebx
	
	
	ret
CEntity_SetCurrentFrame endp

CEntity_SetRandomFrameRate proc uses ebx esi edi lpEntity:DWORD,rate:DWORD
	
	mov edi,lpEntity
	
	fn RangeRand,1,rate
	mov ebx,dword ptr[edi+8] ;frameRate
	mul ebx
	
	mov dword ptr[edi+8],eax
	
	ret
CEntity_SetRandomFrameRate endp

CEntity_SetRandomFrame proc uses ebx edi esi lpEntity:DWORD,rmax:DWORD
	
	mov edi,lpEntity
	
	fn RangeRand,1,rmax
	dec eax
	mov dword ptr[edi+4],eax
	
	ret
CEntity_SetRandomFrame endp

CEntity_onAnimate proc uses ebx esi edi lpEntity:DWORD
	
	mov edi,lpEntity
	cmp byte ptr[edi+16],0
	je @@ret
	fn GetTickCount
	mov ebx,dword ptr[edi+12]		;oldTime
	add ebx,dword ptr[edi+8]		;frameRate
	cmp ebx,eax
	jg @@ret
	mov dword ptr[edi+12],eax
	
	inc dword ptr[edi+4]			;currentframe
	
	mov eax,dword ptr[edi+4]
	cmp eax,dword ptr[edi]			; maxFrames
	jl @F
	mov dword ptr[edi+4],0
@@:
	
	mov eax,dword ptr[edi+4]
	mov ebx,dword ptr[edi]
	dec ebx
	cmp eax,ebx
	jne @@ret
	
	fn CEntity_onAnimationEnd,edi
	
@@ret:
	ret
CEntity_onAnimate endp

CEntity_onAnimationEnd proc uses ebx esi edi lpEntity:DWORD
	
	mov edi,lpEntity
	
	.if dword ptr[edi+17] == EXPLOSION
		
		mov byte ptr[edi+16],0
		
	.endif
	
	ret
CEntity_onAnimationEnd endp

CEntity_onMove proc uses ebx esi edi lpEntity:DWORD
	LOCAL xOffset:DWORD
	LOCAL yOffset:DWORD
	LOCAL angle:REAL10
	
	;Degree to Rad = direction * PI/180
	
	and dword ptr[xOffset],0
	and dword ptr[yOffset],0
	mov edi,lpEntity
	assume edi:PTR ENTITY
	
	fld PI
	fld degree
	fdivp st(1),st
	fild dword ptr[edi].direction
	fmulp st(1),st
	fstp angle
	; xOffset = Speed * cos(angle)
	fld angle
	fcos
	fild dword ptr[edi].speed
	fmulp st(1),st
	fistp dword ptr[xOffset]
	; yOffset = speed * sin(angle)
	fld angle
	fsin
	fild dword ptr[edi].speed
	fmulp st(1),st
	fistp yOffset
	
	mov eax,dword ptr[xOffset]
	add dword ptr[edi].x,eax
	mov eax,dword ptr[yOffset]
	sub dword ptr[edi].y,eax
	
	
	assume edi:nothing
	
	ret
CEntity_onMove endp

CEntity_outsideRoom proc uses ebx esi edi lpEntity:DWORD,rw:DWORD,rh:DWORD
	LOCAL result:DWORD
	
	mov dword ptr[result],0
	mov edi,lpEntity
	assume edi:PTR ENTITY
	
	;	if (y + h < 0 || y >height)
;{
	mov eax,dword ptr[edi].y
	add eax,dword ptr[edi].h
	cmp eax,0
	jl @@True
	
	mov eax,dword ptr[edi].y
	cmp eax,rh
	jg @@True	
; }
	;if (x+W < 0 || x> width)
;{
	mov eax,dword ptr[edi].x
	add eax,dword ptr[edi].w
	cmp eax,0
	jl @@True
	
	mov eax,dword ptr[edi].x
	cmp eax,rw
	jle @@ret
@@True:
	mov dword ptr[result],1
;}
@@ret:
	assume edi:nothing
	mov eax,dword ptr[result]
	ret
CEntity_outsideRoom endp

CEntity_wrap proc uses ebx esi edi lpEntity:DWORD,rw:DWORD,rh:DWORD
	
	mov edi,lpEntity
	assume edi:PTR ENTITY
	; if (x + w < 0 )x = room_width
	; if (x > room_width) x = -w
	; if (y + h < 0) y = room_height
	; if (y > room_height) y = -h
	
	; if (x + w < 0 )x = room_width
	mov eax,dword ptr[edi].x
	add eax,dword ptr[edi].w
	cmp eax,0
	jge @F
	mov eax,rw
	mov dword ptr[edi].x,eax
@@:
	; if (x > room_width) x = -w
	mov eax,dword ptr[edi].x
	cmp eax,rw
	jle @F
	mov eax,dword ptr[edi].w
	neg eax
	mov dword ptr[edi].x,eax
@@:
	; if (y + h < 0) y = room_height
	mov eax,dword ptr[edi].y
	add eax,dword ptr[edi].h
	cmp eax,0
	jge @F
	mov eax,dword ptr[rh]
	mov dword ptr[edi].y,eax
@@:
	; if (y > room_height) y = -h
	mov eax,dword ptr[edi].y
	cmp eax,rh
	jle @F
	mov eax,dword ptr[edi].h
	neg eax
	mov dword ptr[edi].y,eax
@@:
	
	assume edi:nothing
	
	ret
CEntity_wrap endp

CEntity_JumpToPos proc uses ebx esi edi lpEntity:DWORD,x:DWORD,y:DWORD
	
	mov edi,lpEntity
	
	mov ebx,dword ptr[x]
	mov dword ptr[edi+25],ebx
	
	mov ebx,dword ptr[y]
	mov dword ptr[edi+29],ebx
	
	ret
CEntity_JumpToPos endp

CEntity_IsCollide proc uses ebx esi edi pRectA:DWORD,pRectB:DWORD
	
	mov esi,dword ptr[pRectA]
	mov edi,dword ptr[pRectB]
	; if (A.bottom <= B.y) return false
	mov eax,dword ptr[esi+12]
	cmp eax,dword ptr[edi+4]
	jle @@false
		
	; if (A.y >= B.bottom) return false
	mov eax,dword ptr[esi+4]
	cmp eax,dword ptr[edi+12]
	jge @@false
		
	; if (A.right <= B.x) return false
	mov eax,dword ptr[esi+8]
	cmp eax,dword ptr[edi]
	jle @@false
		
	; if (A.x >= B.right) return false
	mov eax,dword ptr[esi]
	cmp eax,dword ptr[edi+8]
	jge @@false
	
		
	xor eax,eax
	inc eax
	ret
@@false:
	xor eax,eax
	ret
CEntity_IsCollide endp

CEntity_IsEntityExist proc uses ebx esi edi id:DWORD
	
	mov esi,pEntity
	mov edx,dword ptr[id]
	xor eax,eax
	xor ebx,ebx
	jmp @@for
@@in:
	
	cmp dword ptr[esi+17],edx
	jne @@next
	inc eax
	jmp @@ret

@@next:
	add esi,sizeof ENTITY
	inc ebx	
@@for:
	cmp ebx,entity_num
	jl @@in
	
@@ret:
	ret
CEntity_IsEntityExist endp

CEntity_GetEntity proc uses ebx esi edi id:DWORD
	
	mov esi,pEntity
	mov eax,dword ptr[id]
	xor ebx,ebx
	jmp @@for
@@in:
	
	cmp dword ptr[esi+17],eax
	jne @@next
	mov eax,esi
	jmp @@ret

@@next:
	add esi,sizeof ENTITY
	inc ebx	
@@for:
	cmp ebx,entity_num
	jl @@in
	xor eax,eax
@@ret:
	ret
CEntity_GetEntity endp

CEntity_FillRect proc uses ebx esi edi pRect:DWORD,lpEntity:DWORD
	
	mov esi,dword ptr[lpEntity]
	mov edi,dword ptr[pRect]
	
	mov eax,dword ptr[esi+49]	;rMask left
	add eax,dword ptr[esi+25]	;x
	mov dword ptr[edi],eax
	
	mov eax,dword ptr[esi+53]	;rMask top
	add eax,dword ptr[esi+29]	;y
	mov dword ptr[edi+4],eax
	
	mov eax,dword ptr[esi+57]	;rMask right
	add eax,dword ptr[edi]		;
	mov dword ptr[edi+8],eax
	
	mov eax,dword ptr[esi+61]	;rMask bottom
	add eax,dword ptr[edi+4]	;
	mov dword ptr[edi+12],eax
	
	ret
CEntity_FillRect endp

CPlayer_onKeyLeft proc uses ebx esi edi
	
	
	xor edx,edx
	mov esi,pEntity
	mov eax,sizeof ENTITY
	mul entity_num
	sub eax,sizeof ENTITY
	add esi,eax

	;mov esi,dword ptr[addrPlayer]
	
	;invoke QueryPerformanceCounter,offset seconds
	mov eax,dword ptr[esi+17]
	.if eax == PLAYER
		
		add dword ptr[esi+45],10		;direction
	@@Cmp:
		cmp dword ptr[esi+45],360
		jl @@ret
		and dword ptr[esi+45],0
		jmp @@ret
		
	.elseif eax == PLAYER_FLY
		
		add dword ptr[esi+45],5		;direction
		jmp @@Cmp
		
	.endif
;	
;	invoke QueryPerformanceCounter,offset seconds2
;	fld seconds2
;	fld seconds
;	fsubp st(1),st
;	
;	fld frequency
;	fdivp st(1),st
;	fstp st

@@ret:	
	ret
CPlayer_onKeyLeft endp

CPlayer_onKeyRight proc uses ebx edi esi 
	
	xor edx,edx
	mov esi,pEntity
	mov eax,sizeof ENTITY
	mul entity_num
	sub eax,sizeof ENTITY
	add esi,eax
	
	mov eax,dword ptr[esi+17]
	.if eax == PLAYER
		
		sub dword ptr[esi+45],10		;direction
	@@Cmp:
		cmp dword ptr[esi+45],0
		jge @@ret
		and dword ptr[esi+45],359
		jmp @@ret
		
	.elseif eax == PLAYER_FLY
		
		sub dword ptr[esi+45],5		;direction
		jmp @@Cmp
		
	.endif

@@ret:	
	ret
CPlayer_onKeyRight endp

CPlayer_onKeySpace proc uses ebx esi edi
	
	xor edx,edx
	mov esi,pEntity
	mov eax,sizeof ENTITY
	mul entity_num
	sub eax,sizeof ENTITY
	add esi,eax
	
	mov eax,dword ptr[esi+17]
	.if eax == PLAYER && completed == 0
		
		mov dword ptr[esi+17],PLAYER_FLY
		;mov dword ptr[addrPlayer],esi
		fn DeleteObject,dword ptr[esi+21]
		
		fn CEntity_LoadSprite,hInstance,IDI_PLAYER_FLY
		mov dword ptr[esi+21],eax
		
		mov esi,dword ptr[basemoon]
		
		mov dword ptr[esi+17],ID_NONE
		
		
	.endif


@@ret:	
	ret
CPlayer_onKeySpace endp
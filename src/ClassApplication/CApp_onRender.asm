CApp_onRender 	proto



.code

CApp_onRender proc uses ebx esi edi
	
	
	;call dword ptr[funcRoomRender]
	mov eax,lpvBase
	call dword ptr[eax]
	
	
	fn StretchBlt,window,0,0,ROOM_WIDTH,ROOM_HEIGHT,screen,0,0,ROOM_WIDTH,ROOM_HEIGHT,SRCCOPY
	
	ret
CApp_onRender endp
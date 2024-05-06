CApp_updateState	proto


.code

CApp_updateState proc uses ebx esi edi
	
	.if next_state != STATE_NULL
		
		;call dword ptr[funcRoomQuit]
		mov eax,lpvBase
		call dword ptr[eax+12]
		
		
		switch next_state
		
			case STATE_TITLE
				fn CRoom_CreateRoom,STATE_TITLE
			default
				mov eax,dword ptr[next_state]
				fn CRoom_CreateRoom,eax 
;			case STATE_ROOM_1
;				fn CRoom_CreateRoom,STATE_ROOM_1
;			case STATE_ROOM_2
;				fn CRoom_CreateRoom,STATE_ROOM_2
;			case STATE_ROOM_3
;				fn CRoom_CreateRoom,STATE_ROOM_3
;			case STATE_ROOM_COMPLETED
;				fn CRoom_CreateRoom,STATE_ROOM_COMPLETED
		
		endsw
	mov ebx,dword ptr[next_state]
	mov dword ptr[id_state],ebx
	
	mov dword ptr[next_state],STATE_NULL

	.endif
	
	ret
CApp_updateState endp
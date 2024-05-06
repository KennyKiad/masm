CApp_onEvent 		proto


.code

CApp_onEvent proc uses ebx edi esi
	
	push id_state
	;call dword ptr[funcRoomEvent]
	mov eax,lpvBase
	call dword ptr[eax+8]
	
	mov dword ptr[next_state],eax	
	
	ret
CApp_onEvent endp
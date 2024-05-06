CApp_onLoop		proto


.code
CApp_onLoop proc uses ebx esi edi
	
	;call dword ptr[funcRoomLoop]	
	mov eax,lpvBase
	call dword ptr[eax+4]
	
	ret
CApp_onLoop endp
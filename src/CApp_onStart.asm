
CApp_onStart		proto


.code

CApp_onStart proc uses ebx esi edi
	LOCAL sTimeCaps:TIMECAPS
	LOCAL _st:SYSTEMTIME
	
	fn GetSystemTime,addr _st
	movzx ebx,SYSTEMTIME.wMilliseconds[_st]
@@:
	fn crt_rand
	dec ebx
	jne @B
	
	
	mov dword ptr[id_state],STATE_TITLE
	
	fn CRoom_LoadBackground,hInstance,IDI_BACKGROUND
	fn CRoom_VirtualAlloc
	;=========================================
	;			Load Music
	;=========================================
	fn CRoom_CreateRoom,STATE_TITLE
	
	
	
	ret
CApp_onStart endp
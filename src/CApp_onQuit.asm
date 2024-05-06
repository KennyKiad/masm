CApp_onQuit		proto


.code

CApp_onQuit proc uses ebx edi esi
	
	;call dword ptr[funcRoomQuit]
	mov eax,lpvBase
	call dword ptr[eax+12]
	
	fn VirtualFree,lpvBase,0,MEM_RELEASE
	
	fn DeleteObject,background
	
	fn SelectObject,screen,bmpOld
	
	fn DeleteDC,screen
	fn DeleteObject,screenBmp
	
	fn ReleaseDC,hWnd,window	
	
	ret
CApp_onQuit endp
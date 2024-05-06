CIMG_LoadBMP				proto :DWORD,:DWORD
CIMG_DrawBMP				proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CIMG_DrawTransparentBmp		proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.code
CIMG_LoadBMP proc uses ebx esi edi hInst:DWORD,idBmp:DWORD
	
	fn LoadBitmap,hInst,idBmp
	
	ret
CIMG_LoadBMP endp

CIMG_DrawBMP proc uses ebx esi edi hBitmap:DWORD,hScreen:DWORD,x:DWORD,y:DWORD,wd:DWORD,ht:DWORD
	LOCAL hOldBmp:DWORD
	LOCAL hMemDC:DWORD
	
	fn CreateCompatibleDC,hScreen
	mov dword ptr[hMemDC],eax
	
	fn SelectObject,eax,hBitmap
	mov dword ptr[hOldBmp],eax
	
	fn StretchBlt,hScreen,x,y,wd,ht,hMemDC,x,y,wd,ht,SRCCOPY
	
	fn SelectObject,hMemDC,hOldBmp
	fn DeleteDC,hMemDC
	
	ret
CIMG_DrawBMP endp

CIMG_DrawTransparentBmp proc uses ebx esi edi hBmp:DWORD,hScreen:DWORD,x1:DWORD,y1:DWORD,w1:DWORD,h1:DWORD,x2:DWORD,y2:DWORD,w2:DWORD,h2:DWORD,color:DWORD
	LOCAL hOldBmp:DWORD
	LOCAL hMemDC:DWORD
	
	fn CreateCompatibleDC,hScreen
	mov dword ptr[hMemDC],eax
	
	fn SelectObject,eax,hBmp
	mov dword ptr[hOldBmp],eax
	
	fn TransparentBlt,hScreen,x1,y1,w1,h1,hMemDC,x2,y2,w2,h2,color
	
	fn SelectObject,hMemDC,hOldBmp
	fn DeleteDC,hMemDC
	
	ret
CIMG_DrawTransparentBmp endp

;				Public Functions
CTTF_LoadFontMem		proto :DWORD,:DWORD
CTTF_UnloadFontMem		proto :DWORD
CTTF_CreateFont			proto :DWORD,:DWORD,:DWORD
CTTF_DeleteFont			proto :DWORD
CTTF_TextOut			proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CTTF_DrawText			proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CTTF_GetTextWidth		proto :DWORD,:DWORD,:DWORD
CTTF_GetTextHeight		proto :DWORD,:DWORD,:DWORD
CTTF_AddFont			proto :DWORD
CTTF_RemoveFont			proto :DWORD

;				Private Functions
CTTF_Lens				proto :DWORD

TSIZE struct
	
	tx 	dd ?
	ty 	dd ?
	
TSIZE ends

.code

CTTF_LoadFontMem proc uses ebx esi edi hInstance:DWORD,idFont:DWORD
	LOCAL hRes:DWORD
	LOCAL sizeRes:DWORD
	LOCAL hGlobal:DWORD
	LOCAL nRead:DWORD
	
	fn FindResource,hInstance,idFont,RT_RCDATA
	or eax,eax
	je @@ret
	mov dword ptr[hRes],eax
	
	fn SizeofResource,hInstance,eax
	mov dword ptr[sizeRes],eax
	
	fn LoadResource,hInstance,hRes
	mov dword ptr[hGlobal],eax
	
	fn LockResource,eax
	or eax,eax
	je @@ret
	
	lea ebx,nRead
	fn AddFontMemResourceEx,eax,sizeRes,0,ebx
	
@@ret:
	ret
CTTF_LoadFontMem endp

CTTF_UnloadFontMem proc uses ebx esi edi hFont:DWORD
	
	fn RemoveFontMemResourceEx,hFont
	
	ret
CTTF_UnloadFontMem endp

CTTF_CreateFont proc uses ebx esi edi hdc:DWORD,FaceName:DWORD,fSize:DWORD
	
	fn GetDeviceCaps,hdc,LOGPIXELSY
	fn MulDiv,fSize,eax,72
	neg eax
	fn CreateFont,eax,0,0,0,FW_DONTCARE,0,0,0,DEFAULT_CHARSET,OUT_TT_ONLY_PRECIS,CLIP_DEFAULT_PRECIS,CLEARTYPE_QUALITY,VARIABLE_PITCH,FaceName
	
	ret
CTTF_CreateFont endp

CTTF_TextOut proc uses ebx esi edi hdc:DWORD,hFont:DWORD,lpText:DWORD,x:DWORD,y:DWORD,color:DWORD
	LOCAL hFontOld:DWORD
	
	fn SelectObject,hdc,hFont
	mov dword ptr[hFontOld],eax
	
	fn SetBkMode,hdc,TRANSPARENT
	
	fn SetTextColor,hdc,color
	
	fn CTTF_Lens,lpText
	
	
	fn TextOut,hdc,x,y,lpText,eax
	fn SelectObject,hdc,hFontOld
	
	ret
CTTF_TextOut endp

CTTF_DrawText proc uses ebx esi edi hdc:DWORD,hFont:DWORD,lpText:DWORD,x:DWORD,y:DWORD,w:DWORD,h:DWORD,color:DWORD,flags:DWORD
	LOCAL hFontOld:DWORD
	LOCAL rc:RECT
	
	fn SetRect,addr rc,x,y,w,h
	
	fn SelectObject,hdc,hFont
	mov dword ptr[hFontOld],eax
	
	fn SetBkColor,hdc,TRANSPARENT  	; Set Color of Background to Transparent
	
	fn SetTextColor,hdc,color	   	; Set Color of Text
	
	mov ebx,dword ptr[flags]		; Set Flag
	or ebx,DT_NOCLIP				;
	
	fn DrawText,hdc,lpText,-1,addr rc,ebx
	
	fn SelectObject,hdc,hFontOld
	
	
	ret
CTTF_DrawText endp

CTTF_GetTextWidth proc uses ebx esi edi hdc:DWORD,hFont:DWORD,lpText:DWORD
	LOCAL hFontOld:DWORD
	LOCAL ts:TSIZE
	
	fn SelectObject,hdc,hFont
	mov dword ptr[hFontOld],eax
	
	lea ebx,ts
	
	fn CTTF_Lens,lpText
	
	fn GetTextExtentPoint32,hdc,lpText,eax,ebx
	
	fn SelectObject,hdc,hFontOld
	
	mov eax,dword ptr[ts]
	
	ret
CTTF_GetTextWidth endp

CTTF_GetTextHeight proc uses ebx esi edi hdc:DWORD,hFont:DWORD,lpText:DWORD
	LOCAL hFontOld:DWORD
	LOCAL ts:TSIZE
	
	fn SelectObject,hdc,hFont
	mov dword ptr[hFontOld],eax
	
	lea ebx,ts
	
	fn CTTF_Lens,lpText
	
	fn GetTextExtentPoint32,hdc,lpText,eax,ebx
	
	fn SelectObject,hdc,hFontOld
	
	mov eax,dword ptr[ts+4]
	
	ret
CTTF_GetTextHeight endp

CTTF_AddFont proc uses ebx esi edi lpFileName:DWORD
	
	fn AddFontResourceEx,lpFileName,FR_PRIVATE,0
	
	ret
CTTF_AddFont endp

CTTF_RemoveFont proc uses ebx esi edi lpFileName:DWORD
	
	fn RemoveFontResourceEx,lpFileName,FR_PRIVATE,0
	
	ret
CTTF_RemoveFont endp

CTTF_DeleteFont proc uses ebx esi edi hFont:DWORD
	
	fn DeleteObject,hFont
	
	ret
CTTF_DeleteFont endp

CTTF_Lens proc uses ebx esi edi lpString:DWORD
	
	xor eax,eax
	mov esi,lpString
@@while:
	mov bl,byte ptr[esi]
	or bl,bl
	je @@ret
	inc eax
	inc esi
	jmp @@while
	
@@ret:
	ret
CTTF_Lens endp




include main.inc
include book.asm
include menu.asm
;----------------


.code
start:
	fn SetConsoleTitle,"Phone Book"
	fn crt_system,"color 0B"
	;----------------------
	invoke GetCommandLine
	invoke MainProc,eax
	;----------------------
	fn ExitProcess,0
MainProc proc uses ebx esi edi lpCommandLine:DWORD
	LOCAL hIn:DWORD
	LOCAL nRead:DWORD
	
	fn MenuCreate
	mov hIn,rv(GetStdHandle,-10)
	fn SetConsoleMode,hIn,01E7h - ENABLE_QUICK_EDIT_MODE + ENABLE_MOUSE_INPUT 
@@do:
	lea ebx,nRead
	or rv(ReadConsoleInput,hIn,offset ir,1,ebx),eax
	je @@ret
	movzx eax,word ptr[ir.EventType]
	.if eax == KEY_EVENT && ir.KeyEvent.bKeyDown == 1
		mov al,byte ptr[ir.KeyEvent.AsciiChar]
		.if al == '6'
			jmp @@ret
		.elseif al == '1'
		@@Add:
		
			fn AddProc
			jmp @@do
		
			;
		
		.elseif al == '2'
		@@View:
			fn ViewProc
			jmp @@do
			
		.elseif al == '3'
		@@Find:
			fn FindProc
			jmp @@do
			
		.elseif al == '4'
		@@Delete:
			fn DeleteProc
			jmp @@do
			
		.elseif al == '5'
		@@Edit:
			fn EditProc
			jmp @@do
		.endif
	.elseif eax == MOUSE_EVENT	&& ir.MouseEvent.dwButtonState == 1
		
		mov eax,ir.MouseEvent.dwMousePosition
		mov ebx,eax
		shr ebx,16			;coord Y
		cwde				;coord X
		.if ebx == 0
			.if eax > 31 && eax < 39
				jmp @@Add
			.elseif eax > 40 && eax < 48
				jmp @@View
			.elseif eax > 49 && eax < 57
				jmp @@Find
			.elseif eax > 58 && eax < 66
				jmp @@Delete
			.elseif eax > 67 && eax < 75
				jmp @@Edit
			.elseif eax > 76 && eax < 84
				jmp @@ret
			.endif
		.endif
			
	.endif
	jmp @@do
;	
;

@@ret:
	ret
MainProc endp
;functions
AddProc proc uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL nRead:DWORD
	LOCAL hOut:DWORD
	local hIn:DWORD 

	fn GetStdHandle,-10
	mov hIn,eax
	fn GetStdHandle,-11
	mov hOut,eax
	
	fn CLS
	
	invoke CreateFile,offset szFileName,GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	jne @F
	fn crt_puts,offset szError
	jmp @@ret
@@:
	mov hFile,eax
	;
	invoke WriteFile,hOut,offset szStr2,sizeof szStr2,addr nRead,0
	fn crt_gets,offset ph.szName,sizeof ph.szName,addr nRead
	or byte ptr[ph.szName],0
	jne @F
	fn CLS
	jmp @@menu
@@:
	cmp byte ptr[ph.szName],20h
	jne @F
	fn CLS
	jmp @@menu
@@:
	invoke WriteFile,hOut,offset szStr3,sizeof szStr3,addr nRead,0
 	fn crt_gets,offset ph.szPhone,sizeof ph.szPhone,0
	or byte ptr[ph.szPhone],0
	jne @F
	fn CLS
	jmp @@menu
@@:
	cmp byte ptr[ph.szPhone],20h
	jne @F
	fn CLS
	jmp @@menu
@@:
	invoke SetFilePointer,hFile,0,0,FILE_END
			
	fn WriteToFile,hFile
	invoke SetEndOfFile,hFile
	invoke WriteFile,hOut,offset szDone,sizeof szDone,addr nRead,0
	fn Sleep,500
	
@@menu:
	fn CloseHandle,hFile
@@ret:
	ret
AddProc endp

ViewProc proc uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL nRead:DWORD
	LOCAL hOut:DWORD
	local hIn:DWORD 

	fn GetStdHandle,-10
	mov hIn,eax
	fn GetStdHandle,-11
	mov hOut,eax
	
	fn CLS
	
	invoke CreateFile,offset szFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	je @@ErrorRead
	mov hFile,eax
	;
	lea esi,ph
	mov byte ptr[esi],0
	mov edi,esi
	invoke ReadFile,hFile,esi,1,addr nRead,0
	or byte ptr[esi],0
	jne @F
	jmp @@Empty
		
@@readname:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	or byte ptr[esi],0
	jne @F
	invoke SetConsoleCursorPosition,hOut,0
	jmp @@menu
@@:
	cmp byte ptr[esi],10
	je @@phone
	inc esi
	jmp @@readname
			
@@phone:
	and byte ptr[esi],0
	push _NameRet
	push hOut
	jmp _NameFun
_NameRet:
	add esp,8
	lea esi,ph
	add esi,256
	mov edi,esi
@@readphone:
	invoke ReadFile,hFile,esi,1,addr nRead,0
			
	cmp byte ptr[esi],10
	je @@read
	inc esi
	jmp @@readphone
@@read:
	and byte ptr[esi],0
	push _PhoneRet
	push hOut
	jmp _PhoneFun
_PhoneRet:
	add esp,8
	mov edi,esi
	jmp @@readname
@@Empty:
	fn crt_puts,offset szEmpty
	jmp @@menu
@@ErrorRead:
	invoke WriteFile,hOut,offset szErrorRead,sizeof szErrorRead,addr nRead,0
	fn Quit
	
@@menu:
	fn CloseHandle,hFile
@@ret:
	ret
ViewProc endp

FindProc proc uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL nRead:DWORD
	LOCAL hOut:DWORD
	local hIn:DWORD 
	
	mov bFlagFind,0
	fn GetStdHandle,-10
	mov hIn,eax
	fn GetStdHandle,-11
	mov hOut,eax
	
	fn CLS
	
	invoke WriteFile,hOut,offset szStr4,sizeof szStr4,addr nRead,0
	fn crt_gets,offset szNameToFind,256,0
	or byte ptr[szNameToFind],0
	jne @F
	fn CLS
	jmp @@menu
@@:	
	cmp byte ptr[szNameToFind],20h
	jne @F
	fn CLS
	jmp @@menu
@@:
	invoke CreateFile,offset szFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	jne @F
	fn crt_puts,offset szError
@@:
	mov hFile,eax
	;
	lea esi,ph
	mov byte ptr[esi],0
	mov edi,esi
@@Read1:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	or byte ptr[esi],0
	jne @F
	fn Clear,offset szNameToFind
	invoke WriteFile,hOut,offset szNameNotFound,sizeof szNameNotFound,addr nRead,0
	jmp @@menu
@@:
			
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@Read1
@@:
	and byte ptr[esi],0
	fn lstrcmp,offset szNameToFind,offset ph.szName
	lea esi,ph
	jne @@ReadPhone
	mov bFlagFind,1
	mov ebx,1
	shl ebx,16
	fn FillConsoleOutputCharacter,hOut,0,31544,ebx,addr nRead
	mov eax,2
	shl eax,16
	invoke SetConsoleCursorPosition,hOut,eax
	invoke WriteFile,hOut,offset szResult,sizeof szResult,addr nRead,0
	invoke WriteFile,hOut,offset szNameToFind,sizeof szNameToFind,addr nRead,0
	mov eax,3
	shl eax,16
	fn SetConsoleCursorPosition,hOut,eax
	push @@NameRet
	push hOut
	jmp _NameFun
@@NameRet:
	add esp,8
	add esi,256
	mov edi,esi
@@Read2:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@Read2
@@:
	and byte ptr[esi],0
	push @@PhoneRet
	push hOut
	jmp _PhoneFun
@@PhoneRet:
	add esp,8
	fn Clear,offset szNameToFind
	jmp @@menu
	
@@ReadPhone:
	invoke ReadFile,hFile,esi,1,addr nRead,0
		
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@ReadPhone
@@:
	and byte ptr[esi],0
	fn lstrcmp,offset szNameToFind,offset ph.szPhone
	lea esi,ph
	jne @@Read1
	fn Clear,offset szNameToFind	
	fn WriteFile,hOut,offset szNameNotFound,sizeof szNameNotFound,addr nRead,0
@@menu:
	fn CloseHandle,hFile
	
@@ret:
	ret
FindProc endp

DeleteProc proc uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL nRead:DWORD
	LOCAL hOut:DWORD
	LOCAL hIn:DWORD 
	LOCAL hTemp:DWORD

	fn GetStdHandle,-10
	mov hIn,eax
	fn GetStdHandle,-11
	mov hOut,eax
	
	fn CLS
	
	mov bFlagDel,0
	invoke WriteFile,hOut,offset szStr5,sizeof szStr5,addr nRead,0
	invoke ReadFile,hIn,offset szNameToDelete,256,addr nRead,0
	cmp byte ptr[szNameToDelete],13
	jne @F
	fn CLS
	jmp @@menu
@@:
	cmp byte ptr[szNameToDelete],20h
	jne @F
	fn CLS
	jmp @@menu
@@:
	invoke lstrlen,offset szNameToDelete
	and byte ptr[szNameToDelete+eax-1],0
	and byte ptr[szNameToDelete+eax-2],0
			
	invoke CreateFile,offset szFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	jne @F
	fn CloseHandle,hTemp
	fn crt_puts, offset szError
	jmp @@ret
@@:
	mov hFile,eax
	invoke CreateFile,offset szTempFile,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	
	mov hTemp,eax
	
	lea esi,ph
@@ReadForName:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	or byte ptr[esi],0
	je @@Eof
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@ReadForName			
@@:
	and byte ptr[esi],0
	lea esi,ph
	add esi,256
@@ReadForPh:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@ReadForPh
@@:
	and byte ptr[esi],0
	or rv(lstrcmp,offset szNameToDelete,offset ph.szName),eax
	je @F
	fn WriteToFile,hTemp
			
@@NextFor:
	lea esi,ph
	jmp @@ReadForName
@@:
	mov bFlagDel,1
	jmp @@NextFor
@@Eof:
	invoke SetEndOfFile,hTemp
	fn CloseHandle,hTemp
	fn CloseHandle,hFile
	fn DeleteFile,offset szFileName
	fn MoveFile,offset szTempFile,offset szFileName
	xor bFlagDel,1
	jne @@if2
	invoke WriteFile,hOut,offset szDone,sizeof szDone,addr nRead,0
	fn Clear,offset szNameToDelete
	jmp @@menu	
@@if2:
	fn Clear,offset szNameToDelete
	invoke WriteFile,hOut,offset szNameNotFound,sizeof szNameNotFound,addr nRead,0
	
@@menu:
	
@@ret:
	ret
DeleteProc endp

EditProc proc uses ebx esi edi
	LOCAL hFile:DWORD
	LOCAL hTemp:DWORD
	LOCAL nRead:DWORD
	LOCAL hOut:DWORD
	LOCAL hIn:DWORD
	LOCAL phTemp:phone
	LOCAL answer:WORD
	
	
	and word ptr[answer],0
	
	xor ecx,ecx
	lea ebx,phTemp
@@clear:
	cmp ecx,512
	je @@end
	and byte ptr[ebx+ecx],0
	inc ecx
	jmp @@clear
@@end:
	
	fn GetStdHandle,-11
	mov hOut,eax
	fn GetStdHandle,-10
	mov hIn,eax
	fn FindProc
	cmp bFlagFind,1
	jne @@ret
	lea esi,ph
	fn lstrcpy,offset szNameToFind,esi
	fn WriteFile,hOut,offset szStr6,sizeof szStr6,addr nRead,0
	
	lea edi,nRead
	fn crt_gets,addr phTemp.szName,256,edi
	
	or byte ptr[phTemp.szName],0
	jne @F
	invoke lstrcpy,addr phTemp.szName,offset ph.szName
	jmp @@Ph
@@:
	cmp byte ptr[phTemp.szName],20h
	jne @@Ph
	invoke lstrcpy,addr phTemp.szName,offset ph.szName
@@Ph:
	fn WriteFile,hOut,offset szStr7,sizeof szStr7,edi,0
	fn crt_gets,addr phTemp.szPhone,256,edi
	or byte ptr[phTemp.szPhone],0
	jne @F
	invoke lstrcpy,addr phTemp.szPhone,offset ph.szPhone
	jmp @@Ok
@@:
	cmp byte ptr[phTemp.szPhone],20h
	jne @@Ok
	invoke lstrcpy,addr phTemp.szPhone,offset ph.szPhone
@@Ok:
	mov ebx,6
	shl ebx,16
	invoke FillConsoleOutputCharacter,hOut,20h,31544,ebx,addr nRead
	mov eax,6
	shl eax,16
	invoke SetConsoleCursorPosition,hOut,eax
	fn WriteFile,hOut,offset szStr8,sizeof szStr8,edi,0
	fn WriteFile,hOut,offset szNewLine,sizeof szNewLine,edi,0
	
	fn WriteFile,hOut,offset szName,sizeof szName,edi,0
	fn WriteFile,hOut,addr phTemp.szName,256,edi,0
	fn WriteFile,hOut,offset szNewLine,sizeof szNewLine,edi,0
	
	fn WriteFile,hOut,offset szPhone,sizeof szPhone,addr nRead,0
	fn WriteFile,hOut,addr phTemp.szPhone,256,edi,0  				; edited name
	fn WriteFile,hOut,offset szNewLine,sizeof szNewLine,edi,0
	
	fn WriteFile,hOut,offset szStr9,sizeof szStr9,edi,0				; question
	
	;fn ReadFile,hIn,addr answer,2,edi,0
	
	fn SetConsoleMode,hIn,0
    ;--------------------
    fn ReadFile,hIn,addr answer,1,edi,0
	fn SetConsoleMode,hIn,01E7h - ENABLE_QUICK_EDIT_MODE + ENABLE_MOUSE_INPUT
	
	
	cmp byte ptr[answer],79h
	je @@yes

	cmp byte ptr[answer],59h
	je @@yes

	cmp byte ptr[answer],6eh
	je @@no

	cmp byte ptr[answer],4eh
	je @@no
	mov ebx,10
	shl ebx,16
	invoke FillConsoleOutputCharacter,hOut,20h,31544,ebx,addr nRead
	mov eax,10
	shl eax,16
	invoke SetConsoleCursorPosition,hOut,eax
	fn crt_puts,"Urecognized command"
	and word ptr[answer],0
	fn Sleep,500
	jmp @@Ok
	
@@yes:
	
	invoke CreateFile,offset szFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	jne @F
	fn CloseHandle,hTemp
	fn crt_puts, offset szError
	jmp @@ret
@@:
	mov hFile,eax
	invoke CreateFile,offset szTempFile,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	
	mov hTemp,eax
	
	lea esi,ph
@@ReadForName:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	or byte ptr[esi],0
	je @@Eof
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@ReadForName			
@@:
	and byte ptr[esi],0
	lea esi,ph
	add esi,256
@@ReadForPh:
	invoke ReadFile,hFile,esi,1,addr nRead,0
	cmp byte ptr[esi],10
	je @F
	inc esi
	jmp @@ReadForPh
@@:
	and byte ptr[esi],0
	or rv(lstrcmp,offset szNameToFind,offset ph.szName),eax
	je @F
	fn WriteToFile,hTemp
			
@@NextFor:
	lea esi,ph
	jmp @@ReadForName
@@:
	jmp @@NextFor
@@Eof:
	invoke SetEndOfFile,hTemp
	fn CloseHandle,hTemp
	fn CloseHandle,hFile
	fn DeleteFile,offset szFileName
	fn MoveFile,offset szTempFile,offset szFileName
	
	
	invoke CreateFile,offset szFileName,GENERIC_WRITE,FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	cmp eax,-1
	jne @F
	fn crt_puts,offset szError
	jmp @@ret
@@:
	mov hFile,eax
	;
	invoke SetFilePointer,hFile,0,0,FILE_END
	invoke lstrlen,addr phTemp.szName
	mov ebx,eax
	invoke WriteFile,hFile,addr phTemp.szName,ebx,edi,0
	invoke WriteFile,hFile,offset szNewLine,1,edi,0
	;
	invoke lstrlen,addr phTemp.szPhone
	mov ebx,eax
	invoke WriteFile,hFile,addr phTemp.szPhone,ebx,edi,0
	invoke WriteFile,hFile,offset szNewLine,1,edi,0
	
	invoke SetEndOfFile,hFile
	fn CLS
	invoke WriteFile,hOut,offset szDone,sizeof szDone,edi,0
	fn Sleep,2000
	fn CloseHandle,hFile
	fn Clear,offset szNameToFind
	
@@no:
	fn CLS
@@ret:
	ret
EditProc endp
;
WriteToFile proc hFile:DWORD
	LOCAL nRead:DWORD
	invoke lstrlen,offset ph.szName
	mov ebx,eax
	invoke WriteFile,hFile,offset ph.szName,ebx,addr nRead,0
	invoke WriteFile,hFile,offset szNewLine,1,addr nRead,0
	;
	invoke lstrlen,offset ph.szPhone
	mov ebx,eax
	invoke WriteFile,hFile,offset ph.szPhone,ebx,addr nRead,0
	invoke WriteFile,hFile,offset szNewLine,1,addr nRead,0
	ret
WriteToFile endp

Clear proc uses ebx szNameTo:DWORD
	xor ecx,ecx
	mov ebx,szNameTo
@@clear:
	or byte ptr[ebx+ecx],0
	je @@end
	and byte ptr[ebx+ecx],0
	inc ecx
	jmp @@clear
@@end:
	ret
Clear endp

CLS proc uses ebx
	LOCAL hOut:DWORD
	LOCAL nRead:DWORD
	
	fn GetStdHandle,-11
	mov hOut,eax
	mov ebx,1
	shl ebx,16
	fn FillConsoleOutputCharacter,hOut,20h,31544,ebx,addr nRead
			
	mov eax,2
	shl eax,16
	invoke SetConsoleCursorPosition,hOut,eax
	ret
CLS endp
Quit proc uses ebx
	LOCAL WherToRead:DWORD
	LOCAL NumOfRead:DWORD
	fn GetStdHandle,-10
	mov ebx,eax
	fn SetConsoleMode,ebx,0
    ;--------------------
    fn ReadConsole,ebx,addr WherToRead,1,addr NumOfRead,0
	fn SetConsoleMode,ebx,01E7h - ENABLE_QUICK_EDIT_MODE + ENABLE_MOUSE_INPUT
	ret
Quit endp
end start
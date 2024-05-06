
menuCreate 		proto



.const
Max_size 		equ   54

.data

ci 				CHAR_INFO Max_size dup(<>)
cr 				COORD     	<Max_size,1>
crd 			COORD     	<0,0>
srect 			SMALL_RECT 	<30,0,90,1>

.code

MenuCreate proc uses ebx esi edi
	cls
	
	lea esi,ci
	mov byte ptr[esi],20h    ; space
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],31h   ; 1
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'A'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'d'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'d'   
	mov word ptr[esi+2],37h
	add esi,4
	mov ebx,1
_LO:
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	inc ebx
	cmp ebx,3
	jbe _LO
	;
	mov byte ptr[esi],20h  
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],32h   
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'V'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'i'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'e'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'w'   
	mov word ptr[esi+2],37h
	add esi,4
	mov ebx,1
_LO1:
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	inc ebx
	cmp ebx,2
	jbe _LO1
	;
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],33h   
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'F'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'i'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'n'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'d'   
	mov word ptr[esi+2],37h
	add esi,4
	mov ebx,1
_LO2:
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	inc ebx
	cmp ebx,2
	jbe _LO2
	;
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],34h   
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'D'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'e'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'l'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'e'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'t'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'e'   
	mov word ptr[esi+2],37h
	add esi,4
	;
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],35h   
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'E'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'d'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'i'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'t'   
	mov word ptr[esi+2],37h
	add esi,4
	mov ebx,1
_LO3:
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	inc ebx
	cmp ebx,2
	jbe _LO3
	;
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],36h   
	mov word ptr[esi+2],7
	add esi,4
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'Q'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'u'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'i'   
	mov word ptr[esi+2],37h
	add esi,4
	mov byte ptr[esi],'t'   
	mov word ptr[esi+2],37h
	add esi,4
	mov ebx,1
_LO4:
	mov byte ptr[esi],20h    
	mov word ptr[esi+2],37h
	add esi,4
	inc ebx
	cmp ebx,2
	jbe _LO4
	
	mov ebx,[cr]
	mov edx,[crd]
	fn GetStdHandle,-11
	mov edi,eax
	invoke WriteConsoleOutput,edi,offset ci,ebx,edx,offset srect
	mov ebx,2
	shl ebx,16
	fn SetConsoleCursorPosition,edi,ebx
	
	
	ret
MenuCreate endp
CApp_onGame 	proto

.code

CApp_onGame	proc uses ebx edi esi
	LOCAL count:DWORD
	LOCAL delay:DWORD
	LOCAL loops:DWORD
	LOCAL max_frameskip:DWORD
	
	and delay,0
	mov max_frameskip,10
	and loops,0
	
	
	fn GetTickCount
	mov count,eax
	
	.while id_state != STATE_EXIT
		
		
	
	invoke QueryPerformanceCounter,offset seconds
	;@@:
	
		;fn CTimer_start
		
	@@loop:
		
		fn GetTickCount
		cmp eax,count
		jle @@next
		mov eax,loops
		cmp eax,max_frameskip
		jge @@next
		
		fn CApp_onLoop
		mov eax,count
		add eax,frame_rate
		mov count,eax
		inc loops
		jmp @@loop
	@@next:
		
		and loops,0
		
		fn CApp_onRender	
		
		fn CApp_onEvent
		
		
		fn CApp_updateState
		
		
		
		;fn CTimer_delay
;		inc delay
;		cmp delay,5
;		jl @B
;		and delay,0
		
	invoke QueryPerformanceCounter,offset seconds2
	fld seconds2
	fld seconds
	fsubp st(1),st
	
	fld frequency
	fdivp st(1),st
	;fistp time
	push 1
	fild dword ptr[esp]
	pop eax
	fdiv st,st(1)
	fistp time
	fstp st
	

	.endw
	
	ret
CApp_onGame endp
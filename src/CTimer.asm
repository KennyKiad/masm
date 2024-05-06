;====================================================
;				public functions					;
;====================================================

CTimer_start		proto
CTimer_delay		proto

;====================================================
;				private function					;
;====================================================

;CTimer_get_ticks	proto


.data

frame_rate 			dd 20	;25 fps
deltaTicks			REAL10 0.0
prevTicks			REAL10 0.0
startTicks			REAL10 0.0



.code
CTimer_start proc uses ebx esi edi 
	
	fn GetTickCount
	
	ret
CTimer_start endp

CTimer_delay proc uses ebx esi edi
	LOCAL temp:REAL10
	
	fn GetTickCount
	
;	fld temp
;	fld startTicks
;	fsubp st(1),st
	
	sub eax,dword ptr[startTicks]
;	fild frame_rate
;	fcom
;	fstsw ax
;	sahf	
	cmp eax,dword ptr[frame_rate]
;	jge @@ret
;	fsub st,st(1)
;	fstp 
	mov ebx,dword ptr[frame_rate]
	sub ebx,eax
	
	fn Sleep,ebx
	
@@ret:
	ret
CTimer_delay endp
;
;CTimer_get_ticks proc
;	
;	fn GetTickCount
;	
;	sub eax,dword ptr[startTicks]
;	
;	ret
;CTimer_get_ticks endp









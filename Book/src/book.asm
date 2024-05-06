strlen 		proto :DWORD
WriteToFile proto :DWORD
Clear 		proto :DWORD
CLS 		proto

phone STRUCT
	szName 		db 256 dup(?)
	szPhone 	db 256 dup(?)
phone ends

.data?
ph 		 		phone <>
szBuffer2 		db 256 dup(?)
szNameToFind	db 256 dup(?)
szNameToDelete  db 256 dup(?)
szRead 			db 1   dup(?)

.data
szName 			db "Name:		",0
szPhone 		db "Phone:		",0
szComm 			db "------------------",10,0
szNewLine   	db 10,0

.code
_NameFun:
	invoke WriteFile,dword ptr[esp+16],offset szName,sizeof szName,offset szRead,0
	fn crt_puts,edi
	jmp dword ptr[esp+4]
_PhoneFun:
	invoke WriteFile,dword ptr[esp+16],offset szPhone,sizeof szPhone,offset szRead,0
	fn crt_puts,edi
	invoke WriteFile,dword ptr[esp+16],offset szComm,sizeof szComm,offset szRead,0
	jmp dword ptr[esp+4]


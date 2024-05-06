include \masm32\include\masm32rt.inc
include \masm32\include\msvcrt.inc

include \masm32\macros\macros.asm

includelib \masm32\lib\msvcrt.lib
;------------------------------------
MainProc 			proto :DWORD			
Quit 				proto 

AddProc 			proto 
ViewProc 			proto
FindProc 			proto
DeleteProc 			proto
EditProc 			proto

.const


.data?
ir       	INPUT_RECORD <>

.data

align 4

bFlagDel		db 0
bFlagFind 		db 0
szTest 			db "%d)",0
szStr2 			db "Enter a name <press ENTER to cancel>",10,0
szStr3 			db "Enter a phone number <press ENTER to cancel>",10,0
szStr4 			db "Enter a name to find <press ENTER to cancel>",10,0
szStr5 			db "Enter a name to delete <press ENTER to cancel>",10,0
szStr6 			db "Enter a new name <press Enter to skip>",10,0
szStr7 			db "Enter a new phone <press Enter to skip>",10,0
szStr8 			db "Edited name:",10,0
szStr9 			db "Do you want to save the changes? Y/N",10,0
szDone 			db "Done!",10,0
szEmpty 		db "The Phone Book is empty!",10,0
szClear 		db "Press any key to clear. . .",0
szError 		db "Create File Failed",0
szErrorRead 	db "No Input data",10,0
szNameNotFound 	db "The name wasn't found",10,0
szResult 		db "Search result for name: ",0
;
szFileName  db "book.txt",0
szTempFile  db "temp.txt",0
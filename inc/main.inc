include \masm32\congamelib\congame.inc

includelib \masm32\congamelib\congame.lib

Main 		proto


.data

time		dd 0

seconds		LARGE_INTEGER <>
seconds2 	LARGE_INTEGER <>
frequency 	LARGE_INTEGER <>
testn		LARGE_INTEGER <>

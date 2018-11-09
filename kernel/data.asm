; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		data.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		8th November 2018
;		Purpose :	Data area
;
; ***************************************************************************************
; ***************************************************************************************

; ***************************************************************************************
;
;									System Information
;
; ***************************************************************************************

SystemInformation:

SINextFreeCode: 									; +0 	Next Free Code Byte
		dw 		FreeMemory,0
SINextFreeCodePage: 								; +4 	Next Free Code Byte Page
		dw 		FirstCodePage,0
SIBootCodeAddress:									; +8	Run from here
		dw 		HaltZ80,0
SIBootCodePage: 									; +12   Run page.
		db		FirstCodePage,0,0,0
SIPageUsage:										; +16 	Page Usage Table
		dw 		PageUsage,0 			
SIStack:											; +xx 	Initial stack value
		dw 		StackTop,0							
SIScreenWidth:										; +xx 	Screen Width
		dw 		0,0
SIScreenHeight:										; +xx 	Screen Height
		dw 		0,0
SIScreenDriver:										; +xx 	Screen Driver
		dw 		0,0 								
SIFontBase:											; +xx 	768 byte font, begins with space
		dw 		AlternateFont,0 							
		
; ***************************************************************************************
;
;								 Other data and buffers
;
; ***************************************************************************************

IOScreenPosition:									; Position on screen
		dw 		0
IOColour: 											; writing colour
		db 		7

PageUsage:
		db 		1									; $20 (dictionary) [1 = system]
		db 		2 									; $22 (first code) [2 = code]
		db 		0,0,0,0,0,0 						; $24-$2E 		   [0 = unused]
		db 		0,0,0,0,0,0,0,0 					; $30-$3E
		db 		0,0,0,0,0,0,0,0 					; $40-$4E
		db 		0,0,0,0,0,0,0,0 					; $50-$5E
		db 		$FF 								; end of page.
		
		org 	$A000
FreeMemory:		
; ***************************************************************************************
; ***************************************************************************************
;
;		Name : 		kernel.asm
;		Author :	Paul Robson (paul@robsons.org.uk)
;		Date : 		8th November 2018
;		Purpose :	MZ Kernel
;
; ***************************************************************************************
; ***************************************************************************************

StackTop   = 	$7EF0 								; Top of stack

DictionaryPage = $20 								; dictionary page
FirstCodePage = $22

			opt 	zxnextreg
			org 	$8000
			jr 		Boot
			org 	$8004
			dw 		SystemInformation

Boot:		ld 		sp,(SIStack)					; reset Z80 Stack
			di										; enable interrupts
			nextreg	7,2								; set turbo port (7) to 2 (14Mhz)
			call 	GraphicInitialise 				; initialise and clear screen.
			ld 		a,(SIBootCodePage) 				; get the page to start
			nextreg $56,a
			inc 	a
			nextreg $57,a
			dec 	a
			ex 		af,af' 							; set the current code page in A'
			ld 		hl,(SIBootCodeAddress)
			jp 		(hl)


			include "support/multiply.asm"			; support functions
			include "support/divide.asm"
			include "support/keyboard.asm"

AlternateFont:
			include "font.inc"

			include "__words.asm"
			include "data.asm"		

			org 	$C000
			db 		0 								; start of dictionary, which is empty.


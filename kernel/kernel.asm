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
			db 		$DD,$01
			di										; enable interrupts
			nextreg	7,2								; set turbo port (7) to 2 (14Mhz)
			call 	SetScreenMode48kSpectrum 		; set screen mode
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
			include "support/drivers/screen48k.asm"
			include "support/drivers/screen_layer2.asm"
			include "support/drivers/screen_lores.asm"

AlternateFont:
			include "font.inc"

			include "__words.asm"
			include "data.asm"		

			org 	$C000
			db 		0 								; start of dictionary, which is empty.


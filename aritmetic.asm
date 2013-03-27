;This is to test aritmetic instructions on AVR
; it is written to be easy to execute on a simulator

.include "tn13def.inc"

.org 0000
	rjmp Reset

.def ah = r25
.def al = r24

Reset:
	ldi r16, low(511)
	ldi r17, high(511)
	ldi al, low(0)
	ldi ah, high(0)
	
	; sub al, r16
	; sbc ah, r17

	ldi r16, 1
	clr r17
	; com ah
	; com al
	; add al, r16
	; adc ah, r17
	neg al
	com ah
	
	;adiw ah:al, 1
	
	rjmp Reset

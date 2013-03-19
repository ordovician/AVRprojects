; Blink LED automatically using hardware. Not interrupt or polling loop
; Connect LED to PB0 (pin 5)
.include "tn13def.inc"

.def a = r16

.org 0000
	rjmp Reset
	
Reset:
	;define output
	sbi DDRB, PB0
	sbi DDRB, PB1
	cbi PORTB, PB0	;turn off LED
	cbi PORTB, PB1
	
	;set prescaler to divide clock freq by 1024
	ldi a, 1<<CS02 | 1<<CS00
	out TCCR0B, a
	
	;set blink frequency
	ldi a, 250
	out OCR0A, a
	ldi a, 250
	out OCR0B, a
	
	;set CTC mode (clear timer/counter on compare)
	ldi a, 1<<WGM01 | 1<<COM0B0 | 1<<COM0A0
	out TCCR0A, a
	
loop:
	nop
	rjmp loop
	
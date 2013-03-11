;--------------------------------------------------
; Blink a LED using the timer
;
; We setup an interrupt to happen each time
; our 'timer counter' (TCNT0) equals
; 'compare register b' (OCR0B). The interrupt run
; subroutine 'on_counter_compare'.
; It turns on a LED on pin 0
;--------------------------------------------------

.include "tn13def.inc"   ;(attiny13 definitions)

.def a = r16             ;general purpose accumulator
.def i = r20             ;index
.def n = r22             ;counter

.org 0000
	rjmp on_reset
.org 0007
	rjmp on_counter_compare
	
on_reset:
	;enable output to pin 0 on portb
	cbi DDRB, PB0
	
	;turn LED low
	sbi PORTB, PB0
	
	;set clock rate to F_CPU/1024 with prescaler
	ldi a, 0b00000101
	out TCCR0B, a
	
	;LED frequence F_CPU/(2 * 1024 * 128)
	ldi a, 128
	out OCR0B, a
	
	;clear Timer on Compare Match (CTC) and set OC0A (in TIFR0)
	ldi a, 1<<WGM01 | 1<<COM0B1 | 1<<COM0B0
	out TCCR0A, a
	
	;turn on interrupt for compare match
	ldi a, 1<<OCIE0B
	out TIMSK0, a
	sei		;Interrupts turned on globally
	
loop:
	nop
	rjmp loop
	
on_counter_compare:
	sbi PORTB, PB0
	reti
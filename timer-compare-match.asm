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

.def rsreg = r15		 ;save SREG in interrupt
.def a = r16             ;general purpose accumulator
.def n = r22             ;counter
.def m = r23

;Safe method to set up interrupt vectors. If you skip some
; you might get hard to debug ghost interrupts.
.org 0000
	rjmp on_reset		;reset
	reti				;external interrupt 0
	reti				;pin change interrupt 0
	reti				;timer/counter overflow
	reti				;eeprom ready
	reti				;analog comparator
	reti 				;timer/counter compare match A
	rjmp on_counter_compare	;timer/counter compare match B
	reti				;watchdog time-out
	reti				;ADC conversion complete
	
on_reset:
	;need stack pointer set for interrupts
	ldi	a, LOW(RAMEND)
	out	SPL, a

	;enable output to pin 0 on portb
	sbi DDRB, PB0
	
	;turn LED low
	cbi PORTB, PB0
	
	;set clock rate to F_CPU/1024 with prescaler
	ldi a, 0b00000101
	out TCCR0B, a
	
	;LED frequence F_CPU/(2 * 1024 * 128)
	ldi a, 128
	out OCR0A, a
	
	;turn on interrupt for compare match
	ldi a, 1<<OCIE0B
	out TIMSK0, a
	
	;turn on CTC mode (TCNT0 == OCR0A)
	ldi a, 1<<WGM01
	out TCCR0A, a
	
	sei		;Interrupts turned on globally
	
loop:
	nop
	rjmp loop
	
on_counter_compare:
	;Good habit to save status register when using interrupts
	; but not needed here since interrupt does not affect any status register
	in rsreg, SREG
	sbi PINB, PB0	;setting bit on PINB instead of PORTB is a trick to flip it
	out SREG, rsreg
	reti
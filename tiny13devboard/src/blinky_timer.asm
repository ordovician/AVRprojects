;--------------------------------------------------
; blinky_timer.asm                                 
; author: Daniel J. Dorey (retrodan@gmail.com)     
; modified by: Erik Engheim
;
; Blink a LED using the timer
;--------------------------------------------------

.include "tn13def.inc"   ;(attiny13 definitions)

.def a = r16             ;general purpose accumulator
.def i = r20             ;index
.def n = r22             ;counter

.org 0000
on_reset:
	sbi DDRB,0	;set portb0 for output
	;set timer prescaler to 1025. Clock frequency will be divided by 1024
	ldi a, 0b00000101
	out TCCR0B, a
	cbi PORTB,0
;--------------;
; main routine ;
;--------------;
main_loop:
	sbi   PINB,0	;toggle the 0 bit
	rcall pause
	rjmp main_loop	;go back and do it again

;----------------;
;pause routines  ;
;----------------;
pause:	
	in   a,TIFR0	;bit 1 is HIGH when TCNT0 timer counter overflows
	andi a, 1<<TOV0
	breq pause		;keep looping until timer counter overflows
	;cleared by writing HIGH. LOW does not change value of a bit. See datasheet p75
	ldi a, 1<<TOV0
	out TIFR0, a	
	ret


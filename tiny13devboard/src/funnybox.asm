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
.def b = r17
.def i = r20             ;index
.def n = r22             ;counter
.def m = r23

.org 0000
	rjmp on_reset		;reset
	reti				;external interrupt 0
	reti				;pin change interrupt 0
	reti				;timer/counter overflow
	reti				;eeprom ready
	reti				;analog comparator
	rjmp on_cca				;timer/counter compare match A
	rjmp on_counter_compare	;timer/counter compare match B
	reti				;watchdog time-out
	reti				;ADC conversion complete
	
on_reset:
	; TODO erik try this commented out lines. Interrupts require a stack which you forgot
	ldi	a, LOW(RAMEND)
	out	SPL, a

	;enable output to pin 0 on portb
	sbi DDRB, PB0
	sbi DDRB, PB1 ;debug
	
	;turn LED low
	cbi PORTB, PB0
	cbi PORTB, PB1 ;debug
	
	;set clock rate to F_CPU/1024 with prescaler
	ldi a, 0b00000101
	out TCCR0B, a
	
	;LED frequence F_CPU/(2 * 1024 * 128)
	ldi a, 128
	out OCR0B, a
	
	;clear Timer on Compare Match (CTC) and set OC0A (in TIFR0)
	;ldi a, 1<<WGM01 | 1<<COM0B1 | 1<<COM0B0
	ldi a, 1<<WGM01
	
	out TCCR0A, a
	
	;turn on interrupt for compare match
	ldi a, 1<<OCIE0B
	out TIMSK0, a
	
	clr b	;for debug
	sei		;Interrupts turned on globally
	
loop:
	cpi b, 4
	breq yellow
	; rcall pause
	; sbi PORTB,PB1	
	; rcall pause
	; cbi PORTB,PB1	
	; rcall pause
	; cbi PORTB,PB0
	rjmp loop
	
	yellow:
	sbi PINB, PB1
	ldi n, 250
	rcall Pause
	sbi PINB, PB1
	ldi n, 250
	rcall Pause
	clr b
	rjmp loop
	
on_cca:
	sbi PINB,PB1
	reti
	
on_counter_compare:
	in rsreg, SREG
	sbi PINB, PB0
	ldi a, 1<<OCF0B
	out TIFR0, a
	; ldi i, 5
	; debug_loop:
	; ldi n, 250
	; rcall Pause
	; sbi PINB,PB0
	; dec i
	; brne debug_loop
	; ldi b, 4 
	out SREG, rsreg
	reti
	
;-------------------------------------------
; Pause
; Standard clock frequency is 9.6Mhz/8 = 1.2Mhz
; which gives a maximum wait time of 258ms
; That means we wait 1.01ms per n.
;
; Load n with desired pause
; wait for n * (1205+7) + 6 cyles
;-------------------------------------------
Pause:
	push m
	mov m, n
PauseLoop:
	ldi n, 240		;240*5 cycles = 1200 cycles
	rcall MiniPause	;3 cycles 
	dec m
	brne PauseLoop	;2 cycles when true, otherwise 1
	pop m
	ret				;4 cycles
	
;-------------------------------------------
; Pause
; Load n with desired pause
; wait for n * 4 + 5 cycles
; n = 0, gives 240*5+5 = 1205 cycles
;-------------------------------------------
MiniPause:
	nop
	nop
	dec n
	brne MiniPause	;2 or 1 cycle. 2 for true
	ret				;4 cycles

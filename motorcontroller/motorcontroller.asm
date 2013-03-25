;PWM to control a motor, at 100 Hz. 10ms period.
;With CPU clock of 1.2e6 and prescaller 1/1024, each clock tick is about 0.8ms
;That means we have to count to about 12 to get 10ms.

.include "tn13def.inc"

.def a = r16
.def b = r17

.org 0000
	rjmp Reset			;reset
	reti				;external interrupt 0
	reti				;pin change interrupt 0
	reti				;timer/counter overflow
	reti				;eeprom ready
	reti				;analog comparator
	reti 				;timer/counter compare match A
	reti				;timer/counter compare match B
	reti				;watchdog time-out
	rjmp ADCComplete	;ADC conversion complete
	
Reset:
	ldi a, low(RAMEND)
	out SPL, a
	
	;set outputs (LEDs)
	sbi DDRB, PB0
	sbi DDRB, PB1		;debug
	cbi PORTB, PB0		;turn off LED
	cbi PORTB, PB1
	
	;set inputs
	cbi DDRB, PB2	;button to enable configuration of max, min, middle
	sbi PORTB, PB2	;enable pullup for button
	
	;setup prescaler to 1/1024, and phase correct PWM, with variable duty cycle
	ldi a, 1<<CS02 | 1<<CS00
	out TCCR0B, a
	ldi a, 1<<WGM00 | 1<<COM0A1		;Toggle OC0A on compare match
	out TCCR0A, a
	
	ldi a, 128
	out OCR0A, a
	
	;ADC
	;ADc ENable, ADc Start Conversion, ADc Auto upDATE, ADc Interrupt Enable
	; with 50-200KHz, SYS CLOCK IS 1.2MHz 
	ldi a, 1<<ADEN | 1<<ADSC | 1<<ADATE | 1<<ADIE | 1<<ADPS1 | 1<<ADPS0
	out ADCSRA, a
	
	;Input ADC on pin PB4/ADC2
	ldi a, 1<<MUX1
	out ADMUX, a
	sei	

loop:
	nop
	rjmp loop

ADCComplete:
	in a, ADCL
	in b, ADCH
	out OCR0A, a
	reti




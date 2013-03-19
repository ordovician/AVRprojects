; Connect a potentiometer to PB4 to adjust frequency of LED blinking
; Uses ADC and waveform generator
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
	ldi a, 1<<WGM01 | 1<<COM0A0
	out TCCR0A, a
	
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
	
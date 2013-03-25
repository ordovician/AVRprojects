;Phase correct PWM of a motor on pin PB0
;page 67 of datasheet says equation for frequency is:
;fc/(N*510), where fc is clock frequency and N is prescaller (8, 64, 256, 1024).
;We let the clock frequency be fc = 9.6Mhz, and use prescaller N = 256.
;Then we get 9.6e6/(256*510) Hz = 73.5 Hz
;73.5Hz is close to 100Hz which is ideal for motor controll.

.include "tn13def.inc"

.def a = r16
.def b = r17
.def n = r18

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
	
	;setup prescaler to 1/256, and phase correct PWM, with variable duty cycle
	ldi a, 1<<CS02					;1/256 prescaler
	out TCCR0B, a
	ldi a, 1<<WGM00 | 1<<COM0A1		;Waveform gen mode 1, Toggle OC0A on compare match
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
	
	;ADC gives a 10bit value. The two MSBs are in ADCH
	; we want to compress 10bit value to a 8bit value
	lsr b	;move 2 bits to the right
	ror b	;and make them pop up on left side
	ror b
	lsr a	;discard two least significant byts
	lsr a
	or a, b	;combine ADCH and ADCL in a 8bit value
	
	out OCR0A, a	;set duty cycle
	reti




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

.def flag = r19

.def midl = r4
.def midh = r5
.def rangel = r6
.def rangeh = r7
.def beginl = r8
.def beginh = r9
.def endl = r10
.def endh = r11

;position of bits for use with flag register
.define GO_CCW 0	;bit 0 in flag set to 1 if motor should rotate ccw

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
	in	r24, ADCL		;using r25:r24 because they work with ADWI
	in	r25, ADCH
	clr r26
	cbr flag, 1<<GO_CCW	;assume motor goes clockwise
	
	;assume clockwise. range = end - mid
	mov rangel, endl
	mov rangeh, endh
	sub rangel, midl
	sbc rangeh, midh
		
	;dial - mid
	sub r24, midl
	sbc r25, midh
	brsh positive
	;dialed value is less than our defined middle posision for dial
	; get how far it is from middle by taking two's compliment
	com r24
	com r25
	adiw r25:r24, 1	;two's complement is one's complement +1
	
	;previous assumption about range wrong. Recalc as range = mid - begin
	mov rangel, midl
	mov rangel, midh
	sub rangel, beginl
	sbc rangeh, beginh
	
	;make a note that dial is left of middle
	sbr flag, 1<<GO_CCW
	
positive:	
	;abs(dial - mid)*256
	ldi n, 8
	rcall ShiftLeft
	
	;(abs(dial - mid)*256)/range
	rcall Divide
	
	out OCR0A, n	;set duty cycle
	reti

Divide:
	ldi n, -1
	clr r4
divide_loop:
	inc n				
	sub r0, rangel
	sbc r1, rangeh
	sbc r2, r4
	brsh divide_loop	;remaineder in r2:r1:r0 still higher than rangeh:rangel
	ret
	
; Shifts r2:r1:r0 left by amount given in n.
ShiftLeft:
	lsl r0
	rol r1
	rol r2
	dec n
	brne ShiftLeft
	ret
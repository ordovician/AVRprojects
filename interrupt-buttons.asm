; Blink LED automatically using hardware. Not interrupt or polling loop
; Connect LED to PB0 (pin 5)
.include "tn13def.inc"

;general registers
.def a = r16
.def b = r17

.def btnstat = r18 ;last state of buttons


;before and after time
.def t0 = r21
.def t1 = r22

;backup status register SREG 
.def rsreg = r23

.org 0000
	rjmp Reset			;reset
	reti				;external interrupt 0
	rjmp ButtonToggle	;pin change interrupt 0
	reti				;timer/counter overflow
	reti				;eeprom ready
	reti				;analog comparator
	reti 				;timer/counter compare match A
	reti				;timer/counter compare match B
	reti				;watchdog time-out
	reti 				;ADC conversion complete

	
Reset:
	;init Stackpointer
	ldi	a, low(RAMEND)
	out	SPL, a

	;define output
	sbi DDRB, PB0
	sbi DDRB, PB1
	cbi PORTB, PB0	;turn off LED
	cbi PORTB, PB1
	
	;define pins used for button inputs
	cbi DDRB, PB2
	cbi DDRB, PB3
	;turn on pullups (buttons connect directly to ground)
	sbi PORTB, PB2
	sbi PORTB, PB3
	
	;set prescaler to divide clock freq by 1024. Each count is about 0.8ms at 1.2MHz
	ldi a, 1<<CS02 | 1<<CS00
	out TCCR0B, a
	
	;set blink frequency
	ldi a, 128
	out OCR0A, a
	
	;set CTC mode (clear timer/counter on compare)
	ldi a, 1<<WGM01 | 1<<COM0A0
	out TCCR0A, a
	
	;enable interrupt for when external buttons are pressed
	ldi a, 1<<PCIE
	out GIMSK, a
	ldi a, 1<<PCINT2 | 1<<PCINT3
	out PCMSK, a
	
	;enable sleep
	ldi a, 1<<SE
	out MCUCR, a
	
	clr btnstat
	sei
	
loop:
	sleep	
	nop
	;go to sleep again if button was not pressed down
	andi btnstat, 1<<PB2 | 1<<PB3
	breq loop
	sbi PORTB, PB1 
	
wait:
	in t1, TCNT0
	sub t1, t0
	cpi t1, 10	;check if 10 * 0.8ms have passed. Debounce
	brge debounced
	rjmp wait
	
debounced:
cbi PORTB, PB1
	in a, PINB
	com a
	and a, btnstat
	sbrc a, PB2
	rcall button2_down
	sbrc a, PB3
	rcall button3_down	
	rjmp loop
	
button2_down:
	in a, OCR0A
	ldi b, 10
	add a, b
	out OCR0A, a
	ret

button3_down:
	in a, OCR0A
	subi a, 10
	out OCR0A, a
	ret

ButtonToggle:
	in rsreg, SREG
	
	;get current buttons state
	in btnstat, PINB
	com btnstat						;we want 1 to represent button down
	andi btnstat, 1<<PB2 | 1<<PB3	;remove non button related bits
	in t0, TCNT0					;time button was changed

button_done:	
	out SREG, rsreg
	reti
	
	
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
	rjmp loop
	

ButtonToggle:
	in rsreg, SREG
	
	;get current buttons state
	in a, PINB
	com a					;we want 1 to represent button down
	andi a, 1<<PB2 | 1<<PB3	;remove non button related bits
	mov b, a
	and b, btnstat

	in t0, TCNT0			;time button was changed

button_done:	
	out SREG, rsreg
	reti
	
	
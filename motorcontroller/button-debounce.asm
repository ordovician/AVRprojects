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
.def state = r21
.def rsreg = r22
.def button_state = r23

;start code segment
.cseg

.org 0x0000
	rjmp Reset			;reset
	reti				;external interrupt 0
	rjmp ButtonToggle	;pin change interrupt 0
	reti				;timer/counter overflow
	reti				;eeprom ready
	reti				;analog comparator
	rjmp DebounceTimePassed ;timer/counter compare match A
	reti				;timer/counter compare match B
	reti				;watchdog time-out
	reti 				;ADC conversion complete

Reset:
	ldi a, low(RAMEND)
	out SPL, a
	
	clr state		;start with motor controll
	
	;set outputs (LEDs)
	sbi DDRB, PB0
	sbi DDRB, PB1		;debug
	cbi PORTB, PB0		;turn off LED
	cbi PORTB, PB1
	
	;set inputs
	cbi DDRB, PB2	;button to enable configuration of max, min, middle
	cbi DDRB, PB3
	sbi PORTB, PB2	;enable pullup for button
	sbi PORTB, PB3
	rcall EnableButtonInterrupt
	sei 
	
loop:
	nop
	rjmp loop

;Setup timer to do debounce of button. Debounce wait time in 'a'
EnableDebounceTimer:
	mov b, a	;save a
	;set clock rate to F_CPU/1024 with prescaler
	ldi a, 1<<CS02 | 1<<CS00
	out TCCR0B, a

	;LED frequence F_CPU/(2 * 1024 * b)
	out OCR0A, b
	clr b
	out TCNT0, b	;so when we start it will take 10ms from now

	;turn on interrupt for compare match
	ldi a, 1<<OCIE0A
	out TIMSK0, a

	;turn on CTC mode (TCNT0 == OCR0A)
	ldi a, 1<<WGM01
	out TCCR0A, a
	mov a, b	;restore a
	ret

DebounceTimePassed:
	;Good habit to save status register when using interrupts
	; but not needed here since interrupt does not affect any status register
	in rsreg, SREG
	push a
	
	in a, PINB
	eor a, button_state
	andi a, 1<<PB2
	breq dtp_exit
	clr a
	out TIMSK0, a
	rjmp EnableButtonInterrupt
	

dtp_exit:	
	pop a
	out SREG, rsreg
	reti
		
;Called when one of the buttons are toggled
ButtonToggle:
	in rsreg, SREG
	push a
	
	ldi a, 46				;see page 64, attiny datasheet how we calculated this 100Hz freq
	rcall EnableDebounceTimer

	;previous downs stay down
	;previous ups stay up if current is up
	;previous ups go down if current is down
	; prevUp & currDown -> down
	; button_state == 1 & a == 0 -> button_state = 0
	in a, PINB
	and button_state, a
	
	sbi PINB, PB1	;use yellow LED just to show that we registered a toggle
	
	pop a
	out SREG, rsreg
	reti
	
;enable interrupt for when external buttons are pressed
EnableButtonInterrupt:
	ldi a, 1<<PCIE
	out GIMSK, a
	ldi a, 1<<PCINT2 | 1<<PCINT3
	out PCMSK, a
	in PINB, button_state	;all buttons should in princile be HIGH (not pressed)
	ret
	

	
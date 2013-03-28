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
.def addr = r20

.def flag = r19
.def state = r21
.def rsreg = r22
.def button_state = r23

.def dialMidL = r4
.def dialMidH = r5
.def rangeL = r6
.def rangeH = r7
.def dialLowL = r8
.def dialLowH = r9
.def dialHighL = r10
.def dialHighH = r11

;position of bits for use with flag register
.define GO_CCW 0	;bit 0 in flag set to 1 if motor should rotate ccw

;current state of program
.define STATE_MOTOR_CONTROL 0	;program is controlling speed of motor
.define STATE_DIAL_LOW 1		;program is setting low position for dial
.define STATE_DIAL_MID 2		;setting middle position for dial
.define STATE_DIAL_HIGH 3		;setting high position for dial
.define STATE_LAST  STATE_DIAL_HIGH + 1 ;not a legal state

.macro  EEReadData
.message "no parameters specified"
.endm

;Read a word from EEPROM at given address
.macro EEReadData_i_16
	ldi addr, @0
	rcall EERead
	mov @1, a
	inc addr
	rcall EERead
	mov @2, a
.endm

.macro  EEWriteData
.message "no parameters specified"
.endm

;Read a word from EEPROM at given address
.macro EEWriteData_i_16
	ldi addr, @0
	rcall EEErase
	mov a, @1
	rcall EEWrite
	inc addr
	rcall EEErase
	mov a, @2
	rcall EEWrite
.endm

;start EEPROM segment (this will be stored in EEPROM memory and must be accessed with through IO registers)
.eseg
.org 0x0004
DialLow:	.dw 0		;dial position for full speed ccw
DialMid:	.dw 511		;dial position for neutral
DialHigh:	.dw 1023	;dial position for full speed cw

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
	rjmp ADCComplete	;ADC conversion complete

ADCStateSwitch:
	rjmp ADCMotorControl
	rjmp ADCDialLow
	rjmp ADCDialMid
	rjmp ADCDialHigh
	
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
	sbi PORTB, PB2	;enable pullup for button
	
	rcall EnableMotorControl	;Set up PWM to generate phase correct 70Hz signal
	
	;read dial positions from EEPROM
	EEReadData [DialLow, dialLowH:dialLowL]
	EEReadData [DialMid, dialMidH:dialMidL]
	EEReadData [DialHigh, dialHighH:dialHighL]
	
	rcall EnableADC

loop:
	nop
	rjmp loop

;if we are doing ADC and we are in Motor controll state, this code should run
ADCMotorControl:
	in	r24, ADCL		;using r25:r24 because they work with ADWI
	in	r25, ADCH
	clr r26

	cbr flag, 1<<GO_CCW	;assume motor goes clockwise
	
	;assume clockwise. range = end - mid
	mov rangeL, dialHighL
	mov rangeH, dialHighH
	sub rangeL, dialMidL
	sbc rangeH, dialMidH
		
	;dial - mid
	sub r24, dialMidL
	sbc r25, dialMidH
	brsh positive
	;dialed value is less than our defined middle posision for dial
	; get how far it is from middle by taking two's compliment
	com r24
	com r25
	adiw r25:r24, 1	;two's complement is one's complement +1
	
	;previous assumption about range wrong. Recalc as range = mid - begin
	mov rangeL, dialMidL
	mov rangeL, dialMidH
	sub rangeL, dialLowL
	sbc rangeH, dialLowH
	
	;make a note that dial is left of middle
	sbr flag, 1<<GO_CCW
	
positive:	
	;abs(dial - mid)*256
	ldi n, 8
	rcall ShiftLeft
	
	;(abs(dial - mid)*256)/range
	rcall Divide
	
	out OCR0A, n	;set duty cycle
	ret
	
ADCDialLow:
	in dialLowL, ADCL
	in dialLowH, ADCH
	ret
	
ADCDialMid:
	in dialMidL, ADCL
	in dialMidH, ADCH
	ret
	
ADCDialHigh:
	in dialHighL, ADCL
	in dialHighH, ADCH
	ret


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
	rjmp EnableMotorControl
	rjmp EnableButtonInterrupt
	
	inc state
	cpi state, STATE_LAST	;if we were at the last state, we need to wrap around
	brne dtp_exit
	clr state				;go to first state
	
	;store values we recorded in EEPROM
	EEWriteData [DialLow, dialLowH:dialLowL]
	EEWriteData [DialMid, dialMidH:dialMidL]
	EEWriteData [DialHigh, dialHighH:dialHighL]
	
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
	clr a
	out GIMSK, a			;stop waiting for button toggles
	
	in button_state, PINB	;preserve state of all buttons on first button toggle
	
	pop a
	out SREG, rsreg
	reti
	
;enable interrupt for when external buttons are pressed
EnableButtonInterrupt:
	ldi a, 1<<PCIE
	out GIMSK, a
	ldi a, 1<<PCINT2 | 1<<PCINT3
	out PCMSK, a
	ret
	
;enable ADC on pin PB4
EnableADC:
	;ADc ENable, ADc Start Conversion, ADc Auto upDATE, ADc Interrupt Enable
	; with 50-200KHz, SYS CLOCK IS 1.2MHz 
	ldi a, 1<<ADEN | 1<<ADSC | 1<<ADATE | 1<<ADIE | 1<<ADPS1 | 1<<ADPS0
	out ADCSRA, a

	;Input ADC on pin PB4/ADC2
	ldi a, 1<<MUX1
	out ADMUX, a
	sei
	ret

;enable motor controll by turning on phase correct PWM outputing 70Hz.
;duty cycle set with OCR0A (duty cycle is period where motor is on)
EnableMotorControl:
	;setup prescaler to 1/256, and phase correct PWM, with variable duty cycle
	ldi a, 1<<CS02					;1/256 prescaler
	out TCCR0B, a
	ldi a, 1<<WGM00 | 1<<COM0A1		;Waveform gen mode 1, Toggle OC0A on compare match
	out TCCR0A, a
	ret
	
ADCComplete:
	in rsreg, SREG
	push a
	
	;jump to one of the subroutines under ADCStateSwitch
	; this kind of works like a switch case on state
	ldi yl, low(ADCStateSwitch)
	ldi yh, high(ADCStateSwitch)
	mov a, state
	lsl a
	add yl, a
	icall
	
	pop a
	out SREG, rsreg
	reti

; Divide r2:r1:r0 by rangeH:rangeL
; result returned in n
Divide:
	ldi n, -1
	clr r4
divide_loop:
	inc n				
	sub r0, rangeL
	sbc r1, rangeH
	sbc r2, r4
	brsh divide_loop	;remaineder in r2:r1:r0 still higher than rangeH:rangeL
	ret
	
; Shifts r2:r1:r0 left by amount given in n.
ShiftLeft:
	lsl r0
	rol r1
	rol r2
	dec n
	brne ShiftLeft
	ret
	
;Erase EEPROM address stored in addr
;will only erase if it has not already been erased	
EEErase:
	mov  b,a             ;preserve value of "a"
	rcall EERead        ;read eeprom location
	cpi  a,0xff          ;check if its erased
	mov  a,b             ;restore "a"
	breq eee_exit        ;if already erased then exit

eee_wait:
	sbic EECR,EEPE      ;check if eeprom available
	rjmp eee_wait       ;loop-back if not available
	ldi b,0b00000001    ;set eepm0,eeprom erase mode
	out EECR,b          ;set mode to erase
	out EEARL,addr      ;eprom address
	out EEDR,a          ;eeprom data to write
	cli					;must disable interrupts when accessing EECR
	sbi EECR,EEMPE      ;enable eeprom
	sbi EECR,EEPE       ;enable erase
	sei					;done with EECR ready for interrupts again
eee_exit: 
	ret

;Write to EEPROM location 'addr' content of 'a'
EEWrite:
	mov  b,a             ;preserve "a"
	rcall EERead        ;read eeprom location
	cp   a,b             ;check if already programmed
	mov  a,b             ;restore "a"
	breq eew_exit        ;already programmed so exit

eew_wait:
	sbic EECR,EEPE       ;check if eeprom available
	rjmp eew_wait       ;loop-back if not available
	ldi b,0b00000010    ;set eepm1, eeprom write only
	out EECR,b           ;set mode to write only
	out EEARL,addr        ;eprom address
	out EEDR,a           ;eeprom data to write
	cli					;protect EEPROM against interrupts
	sbi EECR,EEMPE       ;enable eeprom
	sbi EECR,EEPE        ;enable write
	sei
eew_exit: 
	ret                ;return

;Read content at 'addr' into 'a'
EERead:
	sbic EECR,EEPE       ;check if eeprom busy
	rjmp EERead        ;its busy so we wait
	out EEARL,addr        ;set-up the address
	cli
	sbi EECR,EERE        ;set-up to read
	sei
	in  a,EEDR           ;read the data register		   
	ret                 ;return
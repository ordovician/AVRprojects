; Blink LED automatically using hardware. No interrupt or polling loop. 
; Hold down button connected to PB2 to decrease blink frequency
; Hold down PB3 increase blink frequency
; Connect LED to PB0 (pin 5)
; Connect buttons to PB2 and PB2 (pin 7 and 2)
.include "tn13def.inc"

.define STEP 3			;How big the steps in increase/decrease of LED frequency is
.define WAIT 60			;Wait before sampling button state
.define SMALLEST 30		;Lowest time between LED toggle.
.define HIGHEST 255

.def a = r16	;general purpose accumulator
.def b = r21
.def b0 = r17	;previous button state
.def b1 = r18	;current button state

.def n = r19	;counters
.def m = r20

.org 0000
	rjmp Reset
	
Reset:
	;define LED output
	sbi DDRB, PB0
	sbi DDRB, PB1	;for debug
	cbi PORTB, PB0	;turn off LED
	cbi PORTB, PB1
	
	;define button input
	cbi DDRB, PB2
	cbi DDRB, PB3
	sbi PORTB, PB2	;enable pullup
	sbi PORTB, PB3
	
	;set prescaler to divide clock freq by 1024. Each count is about 0.8ms at 1.2MHz
	ldi a, 1<<CS02 | 1<<CS00
	out TCCR0B, a
	
	;set blink frequency
	ldi a, 250
	out OCR0A, a
	
	;set CTC mode (clear timer/counter on compare)
	ldi a, 1<<WGM01 | 1<<COM0A0
	out TCCR0A, a
	
loop:
	in b0, PINB
	ldi n, WAIT
	rcall Pause
	in b1, PINB
	
	;1 if button was 0 now AND previously
	com b0
	com b1
	and b1, b0
	
	sbrc b1, PB2	;skip if button UP
	rcall DecSpeed	
	sbrc b1, PB3	;skip if button UP
	rcall IncSpeed
	rjmp loop
	
DecSpeed:
	ldi a, STEP
	in b, OCR0A
	add a, b
	brcc decspeed_done	;we don't want a wrap around effect
	ldi a, HIGHEST
decspeed_done:
	out OCR0A, a
	ret

IncSpeed:
	in a, OCR0A
	;will OCR0A get smaller than allowed value if we reduce it by STEP?
	cpi a, SMALLEST+STEP	
	brsh high_enough
	ldi a, SMALLEST
	out OCR0A, a
	ret

high_enough:
	subi a, STEP
	out OCR0A, a
	ret
	
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

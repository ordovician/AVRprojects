Sunday march 10, 2013
---------------------
Trying to design schematic of tiny13 devboard in eagle. Have no previous experience, trying to follow Sparkfun tutorial. I can not figure out how to add something simple like resistors and capacitors. The number of choices are staggering. Fortunatly there is an [instructables][resitorhowto] for how to do it. Summary:

* Resistors are named R-US, and capacitors C-US. Don't search for resistor.
* A standard through hole 1/w resistor is named R-US_0207/10.
	* 2mm radius, 7mm length and 10mm  hole spacing (I do not get the latter part)

Monday march 11, 2013
---------------------
Finnished drawing the schematic of the curcuit in Eagle. Still find the software cumbersome to use. Although in some ways the tools work more effeciently than Fritzing, but Fritzing works more like how you expect a vector drawing application to work.

Description of circuit from left to right: A voltage regulator takes in 9V and gives out a stable 5V to power our AVR Microcontroller Unit (MCU). This is taken straight from a Sparkfun tutorial. D1 is there to protect us from attaching the power with the wrong polarity (mixing up + and -). C1 and C2 are capacitors to even out spikes. LED1 is to show us that power has been turned on.

The ATtiny13 has its MISO, MOSI, Clock and Target Vcc connected to a standard 6pin AVR SPI plug/socket. 

LED2 and LED3 are used to experiment with PWM (pulse width modulation), and thus needs to be connected to same pins as MISO and MOSI because that is the only place with hardware PWM on the tiny13. That is why the LEDs are powered through two transistors. To not interfere with the operations of the programmer which they share lines with the lines have have at least 10KOhm resistors connected. This is documented in ATMELs AVR ISP programmer documentation. A 10K resistor would reduce the current too much to drive the LEDs for this reason, they we use transistors. Then the AVR chip can stay in circuit while we program it.

Friday march 15, 2013
---------------------
I was stuck the whole previous day trying to program my ATtiny13. I kept getting:

	avrdude: stk500v2_command(): warning: Command timed out
	avrdude: initialization failed, rc=-1
	Double check connections and try again, or use -F to override
	this check.

To figure out what was wrong I:

1. Tried with and without 5V from voltage regulator. Same error.
2. Double checked the cables going from programmer to chip.
3. Disconnected all other parts of the circuit.

I found out I had made all the wire connections wrong. It is easy to do that with the ISP6 connector, because the numbering sort of gets reversed at the end of the cable. Finally I thought I had gotten it right when I plugged jumper wires directly onto the ISP6 connector, instead of at the end of the ISP6 cable. I only realized by accident later when I was looking at the schematics for another project when I saw they used another pin for the clock input than me. I checked the datasheet again. I had used pin 2 (CLKI) on the tiny13, which is for generating an external clock signal. For SPI communication you are supposed to connect the clock signal from the ISP6 connector of the programmer to pin 7 SCK (Serial clock). For some reasons I did this correct the first time, but not the second time and I was sure my programmer was broken.

So lesson learned. I think I had to correct my cable connects 3 times, and every time I was certain I had gotten it right. I guess you can never check the cable connections well enough.

Saturday march 16, 2013
-----------------------
I wrote an assembly program to blink the LEDs using interrupts and the output  compare register. It did not work. I tried to debug why the blinking of my green LED did not work by turning on my yellow LED and particular points in the program. It was not hard to check if the interrupt service routine got called but it was hard to check if it got called more than once. So I tried to blink it. However I realized blinking a LED using pooling and timer overflow in an interrupt service routine does not work well. Especially since my timer counter would be cleared on each output compare so it would never overflow.

This I stepped back from that program and focused on getting a LED to blink by just wasting CPU cycles looping and calling NOP. I studied the datasheet to figure out how many CPU cycles was spent and I calculated how many CPU cycles was needed to get 1ms.

The next problem was checking for button presses. This did not work well. First my attempt at using macros failed. Seems like AVRA is a bit flaky in this department when it comes to labels with running numbers.

Sunday march 17, 2013
---------------------
Still working on button pushes. Implemented it using a subroutine, but status registers did not seem to work the way I expected. By debugging using a yellow LED that I would turn on to check if my program had reached a certain line number I could determine that my button press check subroutine was mostly working, but something about how I returned the result was not working.

By accident I noticed when reading some docs that it said that when you use interrupts you should set the stack pointer. I had not done that in my output compare interrupt program I had abandoned earlier. I went back to the program and tried that. Still did not work. But using my pause routine developed earlier I was able to find out more about what had gone wrong. I found sevaral mistakes.

1. My PB0 and PB1 was supposed to be output but I had set the corresponding bits to 0 in DDRB, although they should be 1 for ouput.
2. The interrupt service routine gets called.
3. We return successfully from it. I found that out by setting a register in it and checking whether it had been set in main loop.
4. The interrupt never gets triggered a second time. 

Monday morning march 18, 2013
-----------------------------
Finnaly my output compare code using interrupts works. My mistake was to turn on CTC mode. This is only used when automatically toggling output to go HIGH or LOW when TCNT0 equals OCR0A or OCR0B. So by just removing this line setting the CTC flag in TCCR0A everything worked fine.

Next step was automatic wave form generation using CTC (set TCNT0 to 0 when TCNT0 == OCR0A). In english that means making the LED blink automatically without using any interrupt or polling. My first mistake here was thinking that the two registers OCR0A and OCR0B which get compared to timer/counter TCNT0 every clock cycle were completely symetrical. They are NOT. You can only use OCR0A to set the frequency of the LED blinking. Page 72 of the attiny13 datasheet shows how the WGM0..2 in TCCR0A and TCCR0B are used to set when the TCNT0 counter will be cleared. When bit WGM01 is set it will be cleared when TCNT0 == OCR0A. But there is no option for when it is equal to OCR0B. Keep that in mind!

COM0A1, COM0A0, COM0B1, COM0B0 bits in TCCR0A register are symetrical on the other hand. If you have set COM0A0..1 bits, then the OC0A pin will be toggled or set when TCNT0 == OCR0A. Likewise pin OC0B will be toggled when TCNT0 == OCR0B if the COM0B0..1 bits have been set.

So really it is only OCR0A which lets you set the frequence of the wave. But OCR0B lets you control the phase of the other output. So if you have two LEDs one connected to OC0A and one to OC0B. If OCR0A == OCR0B then they will blink in phase. But if they are different they will blink out of phase.

Monday evening march 18, 2013
-----------------------------
So I figured out I was slightly wrong about why my timer output compare program didn't work. It was not because I had turned on CTC. It only made it fail indirectly. When turning on CTC, TCNT0 will reset every time TCNT0 == OCR0A, and OCR0A would probably be at 0. So when TCNT0 gets reset it gets the same value as OCR0. That sounds like trouble. And the result is that the interrupt only triggers once.

So the actual problem was that I did not set a value for OCR0A. It is okay to set a value for OCR0B but that only affects the phase.

Thursday march 21, 2013
-----------------------
So it seems I have LED blinking under control. Button pressing has proved more complicated however. The issue is debouncing. Meaning when you press a mechanical button it actually bounces up and down for a few milliseconds. To little for you to notice, but your MCU (Microcontroller unit) will. It will look like the button gets toggled multiple times. You can fix this by adding capacitors, resitors etc on the input. Or you can write code to figure out when the button is done bouncing.

Fortunatly I did not need to check for debouncing because I just want to increase or decrease the speed of the LED blinking depending on how long the increase speed, or decrease speed buttons are held down.

The problem I ran into this time was poor understanding on my part of issues surrounding signed and unsigned math and assembly instructions. So here is the issue: The blinking speed is determined by a number between 0 - 255 stored in IO port OCR0A. The number indicates timer counts between each LED toggle. So a low number means high blinking frequency. But if it is too low, the LED will blink so fast you can not see it. It will then act as a dimmer. Each number corresponds roughtly to 1ms. 30ms is roughly the minimum. At lower value we can't see the blinking.

We loop indefinitly checking whether the button is down for a whole 60ms at a time. If it is we increase or decrease the OCR0A by 3 depending on which button is pressed. Doing this there is a number of checks when decreasing the speed to not go below 30ms waiting time between LED toggles.

I used BRLT (branch if less than) instead of BRLO (branch if lower) since I thought signed meant that it would handle cases where the end result was negative. It turns out BRLO already does that. The problem with BRLT is that it treats the operands of previous comparisons as signed numbers. So instead of OCR0A having a range of 0 - 255, it gets a range from -128 to 127. So values from 128 and above a treated as smaller than values below 128. That gives odd results.

Second mistake was thinking that BRMI (branch if minus) only kicked in when a big number was subrtracted from a small. In fact it is much simpler. If the result has bit 8 (MSB) set then BRMI will branch. So it treats all results as signed numbers, and thus anything above 127 will be treated as negative and cause a branch. Thus one must use BRLO for unsigned numbers.

Summary:

1. BRLO instead of BRLT
2. BRSH instead of BRGE
3. BRLO instead of BRMI 
4. I Thought BRSH meant higher than. But it is higher or equal. (Branch Same or Higher)

Friday march 22, 2013
---------------------
Got my prototype developer board finnished. It seemed to take the whole day wiring up everything, testing and soldering. No particular problems except I kept forgetting to connect every needed place to GND. E.g. on first test run LEDs did not blink because neither transistor had its emitter connected to GND. Being melticulous thought made it all time consuming.

I started thinking, that making a prober PCB  might take less time despite all the mucking about in Eagle, since it is easier to make sure you connected everything correctly. A prototype board simple becomes a big mess of cables very quickly.

Saturday march 23, 2013
-----------------------
Really just watched TED talks and documented my project on the web.

Sundary march 24, 2013
----------------------
Added two connection points to be able to easily connect a tachometer and electric motor. The tachometer is on a a small electric motor and send a pulses as the disk with slits rotates and alternates between letting through IR to an IR sensor. Thus one can figure out rotation speed by numbere of pulses per second. This worked fine. I wrote a quick program which used an interrupt whenever the input changed and flashed a LED each time. The motor output did not work as well though. When my 9V battery driving the whole circuit attempted to drive the motor in addition the load was so high that the voltage dropped to about 7.3V. It was impossible to connect it through the PWM output sendt through one of my 2N2222 transistors. The LED would stop flashing. But connecting a second LED worked fine, so it seems like the load was to high for this to work properly. I probably have to have another transitor stage.

Monday march  25, 2013
----------------------
Not much done because I spent all day watching TED videos and reading about Elon Musk. Got phase  correct PWM at 73Hz working though which should be ideal for motor controll.

I set COM0A1 and COM0A0 bit in TCCR0A to 01. Which is the correct thing to do in CTC mode. That will toggle pin OC0A on OCR0A match. However I had set WGM02 to 1. Which gave another phase correct PWM which I was supposed to use. The result was a blank LED. But I am not sure why. Perhaps because output would come on OC0B or because that made OC0A get disconnected.

[resitorhowto]: http://www.instructables.com/id/Draw-Electronic-Schematics-with-CadSoft-EAGLE/step5/Add-resistors/

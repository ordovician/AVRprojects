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

[resitorhowto]: http://www.instructables.com/id/Draw-Electronic-Schematics-with-CadSoft-EAGLE/step5/Add-resistors/

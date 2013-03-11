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

[resitorhowto]: http://www.instructables.com/id/Draw-Electronic-Schematics-with-CadSoft-EAGLE/step5/Add-resistors/

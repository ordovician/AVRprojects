Introduction
------------
Here is a description of the project as it was originally planned and what the final results or conclusions were.

Original plan
-------------
Although we have a AVR-ISP500 programmer from Olimex, it is akward to connect it to the pins of the tiny13 each time. We should create a board with an IC socket for putting it in. The board should be general purpose for trying out different programming. Here are the steps.

1. Design it on a breadboard.
2. Create a voltage regulator. Input 9V, output 5V. See sparkfun beginning embedded electronics:
	* LM7805 regulator
	* 100uF Capacitor
	* 10uF Capacitor
	* red LED + 330Ohm resistor
	* diode	
3. Add a tiny13 with a yellow LED to test it. Connect the cables for ISP:
	* clock
	* serial in
	* serial out
4. Make it blink with simple program.
5. Add a second green LED. Make sure both are on connected to pin 5 and 6, since those support PMW.
6. Test PWM with different programs.
7. Add two push buttons to inputs, through a pull up resistor or voltage divider.
8. Experiment with program for changing PWM frequence based on how long buttons are pressed.
9. Add a potmeter to pin 3, since that has a ADC and few other functions. Use voltage divider.
	
We need to find out if any of these addons can interfere with ISP. Does programmer need to be disconnected when the chip is running its program etc. So to sum  up we should have:

* 3 LEDs
	* Red power is on
	* Yellow and green PWM output (pin 5 and 6)
* 2 Push buttons connected to inputs (pin 2 and 7)
* 1 Potmeter connected to ADC input (pin 3)
	
We should check if interrupts can be triggered on all inputs. If all works fine, then we know this can serve as the basis for a board to program and test tiny13 chips. But before that we should test if the programming board can double as a "fun buttons toy". We should put in a switch so that one can chose whether to output to LED or speaker. The speaker should be used to make fun sounds. Then the board could triple as the "come find me toy".

Before building the programmer we should check whether it can also be used for experimenting with sensors for measuring revolutions on toy motors. Is is possible to input this without removing the two push buttons? 

Conclusions
-----------
Any pin, marked PCINTx, where x is 0, 1, 2, 3, 4, 5 can be used for external interrupt. INT0 simple has more configuration options than PCINTx when it comes to deciding whether rising or falling edge triggers an interrupt. PCINTx generates an interrupt whenever connected pin changes. It was also possible to program the AVR without external voltage and with external voltage of +5V from voltage regulator. No need to unplug programmer while running circuit. Neither was there a need to turn of the circuit while programming.

[motodriver]: http://www.electrokit.com/motordrivare-l298-dubbel-hbrygga.49762 "Dual  full-bridge motor driver"
[electrokit]: http://www.electrokit.com "Electro:kit"
[botdino]: http://www.lynxmotion.com/c-153-botboarduino.aspx
[botdinobuy]: http://www.electrokit.com/en/botboarduino.50217
[lynx]: http://www.lynxmotion.com
Collection of Maker and Electronics Projects
============================================
My intention is to store everything related to development of different projects based on the AVR microcontroller by itself or in or with an Arduino board. If the project gets big, then possibly it will get its own repository.

I also intent to store notes, and observations about how to do AV*R development. AVR development is not as easy and well documented as Arduino development so one need to do a lot of googling to find out things. I want to store all that knowledge in one place.

The projects
============
This is a list of things I want to be able to do or have already done, but not documented well yet.

Electric spinning wheel motor controller
----------------------------------------
There is already one out there based on Arduino. But I want to create one based on ATtiny13 written in assemly. Why? We only need one input for potmeter and one output for driving the motor. Thus we should not need anything more complicated than a ATtiny13 which has 6 IO pins. The program is also fairly small so it would be a fun excersise to write it in assembly rather than C. It could also serve as a good example for others who want to experiment with assembly programming.

Fischertechnik Arduino based ROBO Controller
--------------------------------------------
Fischertechnik is a building system similar to Lego mindstorm, used a lot in education. IMHO it is better than Lego, because the building blocks can be more naturally combined in 3 dimensions and they are quite sturdy. You can often drop a fischertechnik creation on the floor and it wont come apart.

Anyway a lot of the parts like the ROBO TX controller used to control robots or machines you have built in Fischertechnik are quite expensive. A much cheaper version can be built based on Arduino. I have already built one working prototype, but want to build a second and document it better for those who want to replicate my steps. The ROBO TX controller has following inputs and outputs or interest:

* 8 Universal inputs: Digital, analog 0-9V DC, analog 0-5kΩ
* 4 fast counting inputs: Digital, frequency up to 1kHz
* 4 motor outputs, 9V, 250mA: Speed infinitely variable, short circuit proof, alternatively 8 individual outputs

My Arduino based prototype had:

* 2 motor outputs
* 1 relay output (can only be used to drive a motor at full speed in one direction)
* 4 universal inputs/outputs (2 could be used to trigger interrupts)
* 4 analog inputs, but 1 used with a potmeter for calibration (often needed in projects).

My experience with that is that one really needs a lot more motor outputs. The project was done by creating a custom motor controller on a prototyping shield for Arduino. The motor controller was based on the L293 chip.

For my next version I intent to use a simpler approach which will also get more motor outputs. I'll use off the shelf modules or kits with motor controlles which are not Arduino shields. They do not need to be shields to use them with Arduino. It just means you can not stack them. Only using shields limits your choices a lot. It is more flexible with separate modules because they you can use two identical motor controllers and not worry about them using the same IO pins. The box was also too small. It made it really difficult to fix anything inside it if a cable came lose.

So my current plan is build the next version using:

* 1 Arduino Uno as the main brain controlling everything else.
* 2 motor driver modules based on L298 chip. That gives me 4 motor outputs.
* 1 Custom made board for inputs. Arduino can't directly use fischertechnik sensors.
	* inputs from Fischertechnik sensors
	* On/Off button
	* potmeters for calibration
	* a couple of buttons for misc used
	* LEDs for showing status and help debugging problems
* A big board on which everything is screwed on. Makes it easy to change things.
	
I am buying my [motor driver modules][motodriver] from [electrokit][electrokit] in Sweden (since I live in Norway that is convenient.)

A line following or avoidance robot
-----------------------------------
I have a chassis from DFRobot with to motors on where sensors for revolutions per second can be measured. I think a nice project would be to make it follow a line or avoid obstacles with IR sensors or ultrasound. It could be controlled by a ATtiny13. We need inputs and outputs for the following:

* 2 PWM outputs for the two motors.
* 2 inputs to measure how many degrees or rotations the motors have made
	
The ATtiny13 can do this. With ISP programming it has 5 IO pins. Two of those can do PWM in hardware.

Come find me box
----------------
My kids had fun trying to find my iPhone when I hid it and set it up to make random sounds. But I am afraid of the iPhone getting damaged by accident while playing this game. So why not make a dedicated box which can be turned on and made to produce sounds at random times? Again I am thinking of using the ATtiny13 for this.

I do not know much about sound. Perhaps the PWM pins can be used to produce sounds. It should preferably not be single tones but some funny sounds which kids will like.

So the box should consist of the following:

* On/Off button
* LED indicating it is on or off
* small speaker to make sounds
* buttons or dials to configure type of sound
* buttons or dials to configure time interval between sounds
	

Fun buttons and lights toy
------------------------------
This is another kid project. Small kids like to push buttons. The idea of this project is just to have lots of different kinds of buttons and light diodes, and possibly buzzer which make sounds when the buttons are pressed in different combinations.

I might not need a microcontroller for this. Some logic chips like AND and OR gates, 555 timer etc might be enough. Or perhaps they can be combined with a ATtiny13.

Some ideas for features:
	
* LEDs with different color: red, green blue.
* A LED in which one can mix colors
* Holding down a button affects frequence of LED blinking. Or a potmeter.
	
Automatic DVD changer and burner
--------------------------------
I have a whole bunch of DVDs I want to make copies of but I do not want to sit and manually change the DVDs. Commercial DVD changers are very expensive. My idea is to use vacume suction to lift the DVDs up. I am thinking of two possible solutions to this:

1. Building a machine in Fischertechnik and controll it with my Arduino ROBO Controller.
2. A solution based on Lynxmotion servo erector sets controlled by a BotBoarduino.
	
There are obviously pros and cons of both solutions. Fischertechnik is more suited for making machines in general while [Lynxmotion][lynx] is more geared towards robots. The Fischertechnik solution will allow for making movements which are not easily supported with the lynxmotion kits, like going straight up and down. However [Lynxmotion][lynx] based robot arms could do the same using inverse kinamatics, even though the programming would be more complicated. The advantage over Fischertechnik would be that they are much more sturdy and durable.

The [BotBoarduino][botdino] is described [here][botdino]. You can buy it at [electrokit][botdinobuy].

Experimentation projects
========================
To actually realize the projects described it is usefull to create simpler projects to figure out how key parts of the whole project works.

ATtiny13 programmer board
-------------------------
See appropriate folder for more details on the project.

[motodriver]: http://www.electrokit.com/motordrivare-l298-dubbel-hbrygga.49762 "Dual  full-bridge motor driver"
[electrokit]: http://www.electrokit.com "Electro:kit"
[botdino]: http://www.lynxmotion.com/c-153-botboarduino.aspx
[botdinobuy]: http://www.electrokit.com/en/botboarduino.50217
[lynx]: http://www.lynxmotion.com
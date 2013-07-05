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
See appropriate folder for more details on the project.


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
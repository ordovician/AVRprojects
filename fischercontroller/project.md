# Fischertechnik Arduino based ROBO Controller

This controller is for using an arduino to control fischertechnik based creations. It will read inputs and sensors and run motors.

## Background

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

# Planned Design
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

# Actual Design

The document *"L298 Dual H-Bridge Motor Driver datasheet"* describes the inputs and outputs of the motor controller. *"fischer-controller"* Omni Graffle document describes a plexiglas board onto which the two motor controllers, arduino and input/output sockets are placed. The inputs and outputs sockets are compatible with fischertechnik plugs. 

They are placed on a smaller 75x125 mm board kept high above main board with 20 mm screws. That leaves room for attaching cables to the fischertechnik sockets from below.

**Part list:**

* Plexiglas 300x200x2 mm
* 4 screws 3 mm diameter and 20 mm length. Attaching fischertechnik plugs.
* 12 screws 3 mm diameter. For attaching PCB boards.
* 2 motor controllers. L298 Dual H-Bridge Motor Driver.
* 1 arduino UNO
* 1 10 K potentiometer
* 1 On / Off button

[motodriver]: http://www.electrokit.com/motordrivare-l298-dubbel-hbrygga.49762 "Dual  full-bridge motor driver"
[electrokit]: http://www.electrokit.com "Electro:kit"
[botdino]: http://www.lynxmotion.com/c-153-botboarduino.aspx
[botdinobuy]: http://www.electrokit.com/en/botboarduino.50217
[lynx]: http://www.lynxmotion.com
#include "Arduino.h"

#include <EEPROM.h>

// Maurice Ribble 
// 2-4-2010
// http://www.glacialwanderer.com/hobbyrobotics
// Open Source, licensed under a Creative Commons Attribution 3.0 License (http://creativecommons.org/licenses/by-sa/3.0/)
// Compiled with Arduino Software 0017 (http://arduino.cc)

// This program reads an input potentiometer and uses that value to set a motor controller's direction and speed.

// REVISIONS:
// Initial Version

// Frequency for updating motor
#define UPDATE_HZ   100

// Define digital/analog pins
#define BUTTON_PIN        2
#define MOTOR_ENABLE_PIN  3
#define MOTOR_IN1_PIN     4
#define MOTOR_IN2_PIN     5

#define DIAL_APIN         0

// Positions that different data is stored in eeprom
#define EEPROM_DIAL_LOW  0
#define EEPROM_DIAL_MID  1
#define EEPROM_DIAL_HIGH 2

enum { BUTTON_PRESSED=0, BUTTON_NOT_PRESSED=1 };

// Globals
unsigned long g_dialLow;
unsigned long g_dialMid;
unsigned long g_dialHigh;

void waitTillAllButtonsReleased();
void eepromWriteInt(int addr, int val);
int eepromReadInt(int addr, int minVal, int maxVal);

void setup()
{
  int button;

  //Serial.begin(9600); // open hw serial for debugging

  pinMode(BUTTON_PIN, INPUT);
  pinMode(MOTOR_ENABLE_PIN, OUTPUT);
  pinMode(MOTOR_IN1_PIN, OUTPUT);
  pinMode(MOTOR_IN2_PIN, OUTPUT);

  // Default values  
  digitalWrite(MOTOR_ENABLE_PIN, LOW);
  digitalWrite(MOTOR_IN1_PIN, LOW);
  digitalWrite(MOTOR_IN2_PIN, LOW);

  button = digitalRead(BUTTON_PIN);
 
  // If the button is pressed during startup enter a special mode to set the min, max and mid dial readings
  // Should only need to do this once (unless you change the the potentiometer is changed)
  if (button == BUTTON_PRESSED)
  {
    waitTillAllButtonsReleased();                   // debounce
    g_dialLow = analogRead(DIAL_APIN);              // save low speed position
    
    button = digitalRead(BUTTON_PIN);               // wait for button to be pressed again
    while(button == BUTTON_NOT_PRESSED)
    {
       button = digitalRead(BUTTON_PIN);
    }
    
    waitTillAllButtonsReleased();                   // debounce
    g_dialHigh = analogRead(DIAL_APIN);             // save high speed position
    
    button = digitalRead(BUTTON_PIN);               // wait for button to be pressed again
    while(button == BUTTON_NOT_PRESSED)
    {
       button = digitalRead(BUTTON_PIN);
    }
    
    waitTillAllButtonsReleased();                   // debounce
    g_dialMid = analogRead(DIAL_APIN);              // save middle speed position

    eepromWriteInt(EEPROM_DIAL_LOW, g_dialLow);    // save dial position references to eeprom
    eepromWriteInt(EEPROM_DIAL_MID, g_dialMid);
    eepromWriteInt(EEPROM_DIAL_HIGH, g_dialHigh);
  }
  else
  {
    g_dialLow  = eepromReadInt(EEPROM_DIAL_LOW, 0, 1023);  // read dial position references from eeprom
    g_dialMid  = eepromReadInt(EEPROM_DIAL_MID, 0, 1023);
    g_dialHigh = eepromReadInt(EEPROM_DIAL_HIGH, 0, 1023);
  }
}

void loop()
{
  unsigned long dialVal = analogRead(DIAL_APIN);
  long percentOn;
  unsigned long usTotal = 0;
  unsigned long usOn = 0;
  unsigned long usOff = 0;
  int forward;

  if (g_dialHigh > g_dialLow)
  {
    if (dialVal >= g_dialMid)
    {
      forward = 0;
      percentOn = 100*(dialVal-g_dialMid)/(g_dialHigh-g_dialMid);
    }
    else
    {
      forward = 1;
      percentOn = 100*(g_dialMid-dialVal)/(g_dialMid-g_dialLow);
    }
  }
  else // g_dialHigh < g_dialLow
  {
    if (dialVal <= g_dialMid)
    {
      forward = 0;
      percentOn = 100*(g_dialMid-dialVal)/(g_dialMid-g_dialHigh);
    }
    else
    {
      forward = 1;
      percentOn = 100*(dialVal-g_dialMid)/(g_dialLow-g_dialMid);
    }
  }
  
  if (percentOn <= 5)  // Turn motors off when they are close to off
  {
    percentOn = 0;
  }
  else if (percentOn >= 95)  // Turn motors full on when they are close to full on
  {
    percentOn = 100;
  }
 
  usTotal = 1000000/UPDATE_HZ;
  usOn = usTotal*percentOn/100;
  usOff = usTotal - usOn;

  if (forward)
  {
    digitalWrite(MOTOR_IN1_PIN, HIGH);
    digitalWrite(MOTOR_IN2_PIN, LOW);
  }
  else
  {
    digitalWrite(MOTOR_IN1_PIN, LOW);
    digitalWrite(MOTOR_IN2_PIN, HIGH);
  }

  if (usOn)
  {
    unsigned int msOn = usOn/1000;
    usOn %= 1000;
    digitalWrite(MOTOR_ENABLE_PIN, HIGH);
    if (msOn)
      delay(msOn);
    if (usOn)
      delayMicroseconds(usOn);
  }

  if (usOff)
  {
    unsigned int msOff = usOff/1000;
    usOff %=1000;
    digitalWrite(MOTOR_ENABLE_PIN, LOW);
    if (msOff)
      delay(msOff);
    if (usOff)
      delayMicroseconds(usOff);
  }
}

////////////////////////////////////////////////////////////////////////////////
// Helper functions
////////////////////////////////////////////////////////////////////////////////

// Writes an integer to eeprom
void eepromWriteInt(int addr, int val)
{
  addr *= 2;  // int is 2 bytes
  EEPROM.write(addr+1, val&0xFF);
  val /= 256;
  EEPROM.write(addr+0, val&0xFF);
}

// Reads an integer from eeprom
int eepromReadInt(int addr, int minVal, int maxVal)
{
  int val;

  addr *= 2;  // int is 2 bytes
  val = EEPROM.read(addr+0);
  val *= 256;
  val |= EEPROM.read(addr+1);
  val = constrain(val, minVal, maxVal);
  return val;
}

// Wait for all the current button presses to end (handles debouncing buttons)
void waitTillAllButtonsReleased()
{
  while(1)
  {
    int i;
    int button;

    // Need to sample many times to makes sure the button isn't currently bouncing
    for(i=0; i<100; ++i)
    {
      button  = digitalRead(BUTTON_PIN);
      delayMicroseconds(10);
    }

    if (button == BUTTON_NOT_PRESSED)
    {
      break;
    }
  }
}

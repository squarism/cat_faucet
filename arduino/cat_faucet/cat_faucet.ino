#include <VarSpeedServo.h>

/*
 Detect a cat with an IR sensor and move a Servo.
 Send status over serial/Xbee to a ruby script for a webservice call.
  
 Chris Dillon - squarism.com
 
 smoothing code taken from David A. Mellis <dam@mellis.org>
 http://www.arduino.cc/en/Tutorial/Smoothing
 
 This code is in the public domain.
 */
 
String sensor = "sinks";
String name = "basement";
String sBuffer = "";
String sensorTemp = "";
int sensorTempSize = 0;

char str[32];
 

// servo constants, ajust for sink handle and desired water speed
const int ON_POSITION = 110;
const int OFF_POSITION = 75;
const int SERVO_SPEED = 12;    // from VarSpeedServo library (thx Korman)

VarSpeedServo servo;  // create servo object to control a servo

// Define the number of samples to keep track of.  The higher the number,
// the more the readings will be smoothed, but the slower the output will
// respond to the input.  Using a constant rather than a normal variable lets
// use this value to determine the size of the readings array.
const int numReadings = 10;

// number of milliseconds when detecting cat coming or going
// increase this if faucet is finicky while cat drinks
// decrease if it takes too long for faucet to turn one when cat appears
int detectWaitTime = 2000;

// make faucet stay on longer when detected
int stayOnTime = 60000;


int readings[numReadings];      // the readings from the analog input
int index = 0;                  // the index of the current reading
int total = 0;                  // the running total
int average = 0;                // the average

int inputPin = A0;              // input pin of IR sensor

int catDetected = false;        // is there a cat nearby?
int catToggle = false;          // toggle for old cat state
unsigned long time;             // time counter for detectWaitTime

int servoPosition;

// init
void setup()
{
  // initialize serial communication with XBee:
  Serial.begin(9600);
  Serial.println("Starting ...");
  
  // attaches the servo on pin 9 to the servo object
  servo.attach(9);
  servoPosition = 0;
  
  // initialize all the readings to 0:
  for (int thisReading = 0; thisReading < numReadings; thisReading++)
    readings[thisReading] = 0;

  time = millis();
}

// move goddamn servo
void move(int position) {  
  servo.attach(9);      // servo is off to negate buzzing, need to attach to pin "turn it on" again
  servo.slowmove(position, SERVO_SPEED);
  delay(2000);          // wait for servo, this is ABSOLUTELY NECCESSARY
  servo.detach();       // avoid buzzing and excessive movement
  servoPosition = position;
}

// run loop
void loop() {
  
  // here we read the range sensor and average the readings to detect a cat smoothly
  total = total - readings[index];           // subtract the last reading: 
  readings[index] = analogRead(inputPin);    // read from the sensor
  total = total + readings[index];           // add the reading to the total:
  index = index + 1;                         // advance to the next position in the array:  
  if (index >= numReadings) index = 0;       // if we're at the end of the array, wrap around to the beginning.

  average = total / numReadings;             // calculate the average

  if (average > 350 && average < 550) {
    //Serial.println("Found cat.");
    catDetected = true;
    
    // turn on the arduino light for instant feedback
    digitalWrite(13, HIGH);
    
    //Serial.println("on");
    if (isLongEnough()) {
      // move faucet to on position
      if (servoPosition != ON_POSITION) {
        //Serial.println("Turning Faucet On.");
        move(ON_POSITION);
        sendJSON();
      }
    }
  } 
  else {
    catDetected = false;
    
    // turn off light right away for instant feedback (though normally hidden in project box underneath sink)
    digitalWrite(13, LOW);
    
    if (isLongEnough()) {
      // move faucet to off position
      if (servoPosition != OFF_POSITION) {
        move(OFF_POSITION);
        sendJSON();
      }
    }
  }

  delay(100);  // adjust this to taste, longer delay vs power usage(unverified)?
}

// delay for switching states
boolean isLongEnough() {
  if (catDetected != catToggle) {
    catToggle = catDetected;    
    time = millis();  // reset time to avoid overrun
  }
  
  // make faucet stay on longer once triggered
  if (servoPosition == ON_POSITION) {
    if (millis() - time > stayOnTime) {
      return true;
    }
  } else {
    if (millis() - time > detectWaitTime) {
      return true;
    } else {
      return false;
    }
  }
}

// this keeps bugging out when called mulitple times during runtime
// probably due to the MD5 crap, not because of the Xbee/USB serial jumper
// MD5 checksum taken out of here
void sendJSON() {
  // example JSON message
  /*
    {
      "sensor": "sinks",
      "name": "basement",
      "proximity": "false",
      "running": "true",
      "hash": "ED076287532E86365E841E92BFC50D8C",
      "type": "metric"
    } 
  */
  
  Serial.println("{");
  Serial.println("\t\"sensor\": \"" + sensor + "\",");
  Serial.println("\t\"name\": \"" + name + "\",");
  
  Serial.print("\t\"hash\": \"");
  Serial.print("nohash");
  Serial.println("\",");
  
  Serial.print("\t\"proximity\": \"");
  Serial.print(catDetected);
  Serial.println("\",");

  Serial.print("\t\"running\": \"");
  if (servoPosition == 90) {
    Serial.print(false);
  } else if (servoPosition == 110) {
    Serial.print(true);
  } else {
    Serial.print("UNKNOWN");
  }
  Serial.println("\",");
  
  Serial.println("\t\"type\": \"metric\"");
  Serial.println("}");
  
  delay(250);
}


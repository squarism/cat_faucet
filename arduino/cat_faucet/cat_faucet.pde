#include <VarSpeedServo.h>
#include <md5.h>

/*
 Detect a cat with an IR sensor and move a Servo.
 Send status over serial/Xbee to a ruby script for a webservice call.
  
 Chris Dillon - squarism.com
 
 smoothing code taken from David A. Mellis <dam@mellis.org>
 http://www.arduino.cc/en/Tutorial/Smoothing
 
 This code is in the public domain.
 */
 
MD5 md5Hasher;
md5_hash_t destination; // Create an array to hold the hash; md5_hash_t is defined as uint8_t[16] in the header.

String sensor = "sinks";
String name = "basement";
String sBuffer = "";
String sensorTemp = "";
int sensorTempSize = 0;

char str[32];
 

// servo constants, ajust for sink handle and desired water speed
const int ON_POSITION = 105;
const int OFF_POSITION = 85;
const int SERVO_SPEED = 10;    // from VarSpeedServo library (thx Korman)

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
  //delay(2000);
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
  delay(1500);          // wait for servo, this is ABSOLUTELY NECCESSARY
  servo.detach();       // avoid buzzing and excessive movement
  servoPosition = position;
}

// run loop
void loop() {
  // subtract the last reading:
  total = total - readings[index];
  // read from the sensor:  
  readings[index] = analogRead(inputPin);
  //Serial.println(analogRead(inputPin)); 
  // add the reading to the total:
  total = total + readings[index];       
  // advance to the next position in the array:  
  index = index + 1;                    

  // if we're at the end of the array, wrap around to the beginning.
  if (index >= numReadings) index = 0;

  // calculate the average:
  average = total / numReadings;         
  // send it to the computer (as ASCII digits) 
  //Serial.println(average, DEC);

  if (average > 350 && average < 550) {
    //Serial.println("Found cat.");
    catDetected = true;
    
    // turn on light right away for instant feedback
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
    
    // turn off light right away for instant feedback
    digitalWrite(13, LOW);
    
    if (isLongEnough()) {
      // move faucet to off position
      if (servoPosition != OFF_POSITION) {
        //Serial.println("Turning Faucet Off.");
        move(OFF_POSITION);
        sendJSON();
      }
    }
  }

  // adjust this to taste
  delay(100);
}

// delay for switching states
boolean isLongEnough() {
  if (catDetected != catToggle) {
    //Serial.print("Toggling cat.  Cat is:");
    //Serial.println(catDetected);
    
    catToggle = catDetected;
    
    // reset time to avoid overflow
    time = millis();
  }

  if (millis() - time > detectWaitTime) {
    return true;
  } else {
    return false;
  }
}

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
  
  // create a buffer for our MD5 hash
  //sBuffer = "";
  sensorTemp = "";
  sensorTemp += sensor;
  sensorTemp += " ";
  sensorTemp += name;

  // pad it up, only way I could get this goddamn string concat to work
  sensorTempSize = sizeof(sensor) + 3 + sizeof(name);
  char buf[sensorTempSize];
  sensorTemp.toCharArray(buf, sensorTempSize);
  
  Serial.println("{");
  Serial.println("\t\"sensor\": \"" + sensor + "\",");
  Serial.println("\t\"name\": \"" + name + "\",");
  
  Serial.print("\t\"hash\": \"");
  Serial.print(hash(buf));
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
  
  // memory test for debugging
  //Serial.println(memoryTest());
  
  //delay(1000);
}

String hash(char *string) {
  // Calling the ComputeHash method will generate the hash for the string.
  // It fills the destination variable with a byte array.
  md5Hasher.ComputeHash(&destination, string);
	
  // Calling the static ToHexString method will allow you to convert this byte array to a string.
  // This is primarily for debugging.
  //char str[32];
  
  MD5::ToHexString(destination, str);
  //Serial.println(str);
  
  return String(str);
  //return hash;  // Output: ED076287532E86365E841E92BFC50D8C

  // You do not need to reinitialize the md5Hasher object, just call ComputeHash again.
  //md5Hasher.ComputeHash(&destination, "Goodnight Moon.");
  //MD5::ToHexString(destination, str);
  //Serial.println(str);  // Output: 998A9262F578EA4892FC01A8A5CEF42F
    
}


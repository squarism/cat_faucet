// Generating an MD5 Hash using code from the AVR-Crypto-Lib.
// Chet Zema <http://www.chetos.net/> April 29, 2010.

#include <md5.h>

MD5 md5Hasher;
md5_hash_t destination; // Create an array to hold the hash; md5_hash_t is defined as uint8_t[16] in the header.

String sensor = "sinks";
String name = "basement";
String sBuffer = "";
String sensorTemp = "";
int sensorTempSize = 0;


void setup() {
  Serial.begin(9600);
}

void loop() {
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
  Serial.print(true);
  Serial.println("\",");

  Serial.print("\t\"running\": \"");
  Serial.print(false);
  Serial.println("\",");
  
  Serial.println("\t\"type\": \"metric\"");
  Serial.println("}");
  
  // memory test for debugging
  //Serial.println(memoryTest());
  
  delay(1000);
}

String hash(char *string) {
  // Calling the ComputeHash method will generate the hash for the string.
  // It fills the destination variable with a byte array.
  md5Hasher.ComputeHash(&destination, string);
	
  // Calling the static ToHexString method will allow you to convert this byte array to a string.
  // This is primarily for debugging.
  char str[32];
  
  MD5::ToHexString(destination, str);
  //Serial.println(str);
  
  String hash = String(str);
  return hash;  // Output: ED076287532E86365E841E92BFC50D8C

  // You do not need to reinitialize the md5Hasher object, just call ComputeHash again.
  //md5Hasher.ComputeHash(&destination, "Goodnight Moon.");
  //MD5::ToHexString(destination, str);
  //Serial.println(str);  // Output: 998A9262F578EA4892FC01A8A5CEF42F
    
}

int memoryTest() {
  int byteCounter = 0; // initialize a counter
  byte *byteArray; // create a pointer to a byte array
  // More on pointers here: http://en.wikipedia.org/wiki/Pointer#C_pointers

  // use the malloc function to repeatedly attempt
  // allocating a certain number of bytes to memory
  // More on malloc here: http://en.wikipedia.org/wiki/Malloc
  while ( (byteArray = (byte*) malloc (byteCounter * sizeof(byte))) != NULL ) {
    byteCounter++; // if allocation was successful, then up the count for the next try
    free(byteArray); // free memory after allocating it
  }

  free(byteArray); // also free memory after the function finishes
  return byteCounter; // send back the highest number of bytes successfully allocated
}

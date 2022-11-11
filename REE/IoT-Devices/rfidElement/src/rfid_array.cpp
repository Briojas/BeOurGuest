#include <Arduino.h>

//Time management
#include <time.h>
  //need absolute time for syncing across devices
const char timeServer1[] = "pool.ntp.org"; 
const char timeServer2[] = "time.nist.gov"; 
const char timeServer3[] = "time.google.com"; 

//RFID PN532 Card
#include <Wire.h>
#include <PN532.h>
#include <PN532_I2C.h>
#include <NfcAdapter.h>
PN532_I2C pn532i2c(Wire);
PN532 nfc(pn532i2c);
#define NUM_RFID_READERS 4 //max: 8 devices per multiplexer

//LEDs
#include <FastLED.h>
#define LEDS_DATA_PIN 15
#define NUM_LEDS 12
#define CHIPSET WS2811
#define COLOR_ORDER GRB
#define BRIGHTNESS 4
CRGB leds[NUM_LEDS];
String currentProfile;

//Button
#define BUTTON_PIN 27

//WiFi
#include <wifiSetup.h>
#include <wifiLogin.h>
WiFiClient wifi_client;


//MQTT
#include <mqttSetup.h>
#include <mqttLogin.h>
MQTTClient mqtt_client;
const int port = 8883;
const char clientName[] = "rfidElement";
const int numPubs = 1;
mqtt_pubSubDef_t pubs[numPubs];
const int numSubs = 1;
mqtt_pubSubDef_t subs[numSubs];
  //callback function
void readSubs(String &topic, String &payload){
    Serial.println("incoming: " + topic + " - " + payload);
    for(int i=0; i < numSubs; i++){
        if(topic == subs[i].topic){ //check each message in the array for the correct subscriber
            subs[i].payload = payload; //store payload in the correct subscriber message
            break;
        }
    }
}

//General inits and defs
void multiplexer(uint8_t bus)
MQTT_Client_Handler rfid_mqtt_client(mqtt_client, wifi_client, brokerName, subs, numSubs, readSubs, port); //initialize the mqtt handler
void checkAndPublishTag();
void updateLEDs(int numToShow);
String getTimestamp();

int tempNum;


void setup() {
  Serial.begin(115200);
///////////////   RFID   ///////////////
    // initiates boards on the multiplexer to start reading
  for(uint8_t i = 0; i < (NUM_RFID_READERS - 1); i++){
    
    multiplexer(i); //switch multiplexer to next board
    //TODO: add function to reset board on startup
    nfc.begin(); //start board
      
      // Connected, show version
    uint32_t versiondata = nfc.getFirmwareVersion();
    if (! versiondata){
      Serial.println("PN53x card not found!");
    } else {
        //port
      Serial.print("Found chip PN5"); Serial.println((versiondata >> 24) & 0xFF, HEX);
      Serial.print("Firmware version: "); Serial.print((versiondata >> 16) & 0xFF, DEC);
      Serial.print('.'); Serial.println((versiondata >> 8) & 0xFF, DEC);
        // Set the max number of retry attempts to read from a card
        // This prevents us from waiting forever for a card, which is
        // the default behaviour of the PN532.
      nfc.setPassiveActivationRetries(0xFF);
        // configure board to read RFID tags
      nfc.SAMConfig();
  }
///////////////   LEDS   ///////////////
  FastLED.addLeds<CHIPSET, LEDS_DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalSMD5050);
  FastLED.setBrightness(BRIGHTNESS);
  tempNum = 0;
///////////////   WiFi   ///////////////
  wifi_init(wifiName, wifiPW);
///////////////   MQTT   ///////////////
  String deviceName = clientName; //converting const char to str
                //$$ SUBS $$//
    //listening to broker status
  subs[0].topic = "/LEDs"; 
                //$$ PUBS $$//
    //posting score data from rfid readings
  pubs[0].topic = "/" + deviceName + "/tag";
  pubs[0].qos = 2; 
                //$$ connect $$//
  // rfid_mqtt_client.connect(clientName, brokerLogin, brokerPW);
///////////////   Time   ///////////////
  configTime(-5 * 3600, 0, timeServer1, timeServer2, timeServer3);
}

void loop() {
  // if(!rfid_mqtt_client.loop()){
  //   rfid_mqtt_client.connect(clientName, brokerLogin, brokerPW);
  // }
   for(uint8_t i = 0; i < (NUM_RFID_READERS - 1); i++){
    
    multiplexer(i); //switch multiplexer to next board
    checkAndPublishTag();
    //TODO: publish tag to topic based on multiplexer channel
   }
}

void multiplexer(uint8_t bus){
  Wire.beginTransmission(0x70);  // TCA9548A address
  Wire.write(1 << bus);          // send byte to select bus
  Wire.endTransmission();
  Serial.print(bus);
}

void checkAndPublishTag(){
  bool success; 
  uint8_t uid[] = { 0, 0, 0, 0, 0, 0, 0 };  // Buffer to store the returned UID
  uint8_t uidLength;  // Length of the UID (4 or 7 bytes depending on ISO14443A card type)

  success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, &uid[0], &uidLength);
  if (success) {
    Serial.print("read the card: ");
    for (uint8_t i=0; i < uidLength; i++){
      Serial.print(uid[i], HEX);
    }
    Serial.println("");

    tempNum ++;
    updateLEDs(tempNum);
  } 
  delay(10);
}

void updateLEDs(int numToShow){
    numToShow = numToShow % (NUM_LEDS + 1);
    for(int i = 0; i < numToShow; i++){
      leds[i] = CRGB::BlueViolet;
    }
    for(int i = numToShow; i < NUM_LEDS; i++){
      leds[i] = CRGB::Black;
    }
    FastLED.show();
}

String getTimestamp(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return "0000-00-00T-00:00:00-00:00";
  }

  char timeYear[5];
  strftime(timeYear, 5, "%Y", &timeinfo);
  char timeMonth[3];
  strftime(timeMonth, 5, "%m", &timeinfo);
  char timeDay[3];
  strftime(timeDay, 3, "%d", &timeinfo);
  char timeHr[3];
  strftime(timeHr, 3, "%H", &timeinfo);
  char timeMin[3];
  strftime(timeMin, 3, "%M", &timeinfo);
  char timeSec[3];
  strftime(timeSec, 3, "%S", &timeinfo);

  String timestamp;
  timestamp.concat(timeYear);
  timestamp.concat("-");
  timestamp.concat(timeMonth);
  timestamp.concat("-");
  timestamp.concat(timeDay);
  timestamp.concat("T-");
  timestamp.concat(timeHr);
  timestamp.concat(":");
  timestamp.concat(timeMin);
  timestamp.concat(":");
  timestamp.concat(timeSec);
  timestamp.concat("-");
  timestamp.concat("05:00"); //cst offset
  return timestamp;
}
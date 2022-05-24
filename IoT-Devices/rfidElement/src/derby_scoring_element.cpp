#include <Arduino.h>

//Time management
#include <time.h>
  //need absolute time for syncing across devices
const char timeServer1[] = "pool.ntp.org"; 
const char timeServer2[] = "time.nist.gov"; 
const char timeServer3[] = "time.google.com"; 

//RFID Card
#include <MFRC522.h> //library responsible for communicating with the module RFID-RC522
#include <SPI.h> //library responsible for communicating of SPI bus
#define SS_PIN 5
#define RST_PIN 33
MFRC522 mfrc522(SS_PIN, RST_PIN);
//TODO: add pubsub logic to release/lock when rfid reading can occur
int delay_between_reads_ms;

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
//TODO: Manage secure vs unsecure wifi_client selection based on MQTT port selection
// WiFiClient wifi_client;
WiFiClientSecure wifi_client;

//MQTT
#include <mqttSetup.h>
#include <mqttLogin.h>
MQTTClient mqtt_client;
const int port = 8883;
const char clientName[] = "score_element_1";
const int numPubs = 2;
mqtt_pubSubDef_t pubs[numPubs];
const int numSubs = 1;
mqtt_pubSubDef_t subs[numSubs];
  //callback function for grabbing sub data
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
MQTT_Client_Handler rfid_mqtt_client(mqtt_client, wifi_client, brokerName, subs, numSubs, readSubs, port); //initialize the mqtt handler
void checkAndPublishTag(int read_delay_ms);
void updateLEDs(int numToShow);
String getTimestamp();

void setup() {
  Serial.begin(115200);
///////////////   RFID   ///////////////
  SPI.begin(); // Init SPI bus
  mfrc522.PCD_Init(); // Init MFRC522 readers
  delay_between_reads_ms = 1000;
  delay(4);				// time after init to be fully setup and ready 
///////////////   LEDS   ///////////////
  FastLED.addLeds<CHIPSET, LEDS_DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalSMD5050);
  FastLED.setBrightness(BRIGHTNESS);
///////////////   WiFi   ///////////////
  wifi_init(wifiName, wifiPW);
  wifi_client.setInsecure(); //TODO: only call when WiFiClientSecure used
///////////////   MQTT   ///////////////
  String deviceName = clientName; //converting const char to str
                //$$ SUBS $$//
  //   //LED assignment
  // subs[0].topic = "/" + deviceName + "/LEDs"; //for now, LEDs are being set directly to score
  // subs[0].qos = 2;
    //score data
  subs[0].topic = "/" + deviceName + "/score"; 
  subs[0].qos = 2;
                //$$ PUBS $$//
    //rfid readings
  pubs[0].topic = "/" + deviceName + "/tag";
  pubs[0].qos = 2; 
  pubs[0].retained = true;
    //score updates
  pubs[1].topic = "/" + deviceName + "/score";
  pubs[1].payload = "0"; //initial value
  pubs[1].qos = 2; 
  pubs[1].retained = true;
                //$$ connect $$//
  rfid_mqtt_client.connect(clientName, brokerLogin, brokerPW);
                //$$ INIT PUBSUBS $$//
  rfid_mqtt_client.publish(pubs[1]);
///////////////   Time   ///////////////
  configTime(-5 * 3600, 0, timeServer1, timeServer2, timeServer3);
}

void loop() {
  if(!rfid_mqtt_client.loop()){
    rfid_mqtt_client.connect(clientName, brokerLogin, brokerPW);
  }
  checkAndPublishTag(delay_between_reads_ms);
  updateLEDs(subs[0].payload.toInt());
}

void checkAndPublishTag(int read_delay_ms){
  if (!mfrc522.PICC_IsNewCardPresent()){return;} //waiting for an RFID tag to approach
  Serial.println("checking card...");
  if (!mfrc522.PICC_ReadCardSerial()){return;} //check if it's readable
  Serial.println("card reads:");

    //obtain the tag's UID
  String uid = "";
  byte letter;
  for (letter = 0; letter < mfrc522.uid.size; letter++) {
     uid.concat(String(mfrc522.uid.uidByte[letter] < 0x10 ? " 0" : " "));
     uid.concat(String(mfrc522.uid.uidByte[letter], HEX));
  }

    //publish the uid read at the timestamp
  uid.toUpperCase();
  Serial.print(uid);
  pubs[0].payload = uid + " @" + getTimestamp();
  rfid_mqtt_client.publish(pubs[0]);
  int device_score = subs[0].payload.toInt();
  device_score ++;
  pubs[1].payload = String(device_score);
  rfid_mqtt_client.publish(pubs[1]);
    //wait before reading, scoring, and publishing another tag  
  delay(read_delay_ms); 
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

// #include <SPI.h>
// #include <MFRC522.h>

// #define RST_PIN         33           // Configurable, see typical pin layout above
// #define SS_PIN          5          // Configurable, see typical pin layout above

// MFRC522 mfrc522(SS_PIN, RST_PIN);   // Create MFRC522 instance.

// MFRC522::MIFARE_Key key;

// void dump_byte_array(byte *buffer, byte bufferSize);

// /**
//  * Initialize.
//  */
// void setup() {
//     Serial.begin(115200);	// Initialize serial communications with the PC
//     while (!Serial);    // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
//     SPI.begin();		// Init SPI bus
//     mfrc522.PCD_Init();	// Init MFRC522 card

//     // Prepare the key (used both as key A and as key B)
//     // using FFFFFFFFFFFFh which is the default at chip delivery from the factory
//     for (byte i = 0; i < 6; i++) {
//         key.keyByte[i] = 0xFF;
//     }

//     Serial.println(F("Scan a MIFARE Classic PICC to demonstrate Value Block mode."));
//     Serial.print(F("Using key (for A and B):"));
//     dump_byte_array(key.keyByte, MFRC522::MF_KEY_SIZE);
//     Serial.println();
    
//     Serial.println(F("BEWARE: Data will be written to the PICC, in sector #1"));
// }

// /**
//  * Main loop.
//  */
// void loop() {
//     // Reset the loop if no new card present on the sensor/reader. This saves the entire process when idle.
//     if ( ! mfrc522.PICC_IsNewCardPresent())
//         return;

//     // Select one of the cards
//     if ( ! mfrc522.PICC_ReadCardSerial())
//         return;

//     // Show some details of the PICC (that is: the tag/card)
//     Serial.print(F("Card UID:"));
//     dump_byte_array(mfrc522.uid.uidByte, mfrc522.uid.size);
//     Serial.println();
//     Serial.print(F("PICC type: "));
//     MFRC522::PICC_Type piccType = mfrc522.PICC_GetType(mfrc522.uid.sak);
//     Serial.println(mfrc522.PICC_GetTypeName(piccType));
// }

// void dump_byte_array(byte *buffer, byte bufferSize) {
//     for (byte i = 0; i < bufferSize; i++) {
//         Serial.print(buffer[i] < 0x10 ? " 0" : " ");
//         Serial.print(buffer[i], HEX);
//     }
// }
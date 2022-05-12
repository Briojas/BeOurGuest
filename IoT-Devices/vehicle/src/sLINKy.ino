//sLINKy's robot brain
  //Blake Riojas

  //Game Data
typedef struct sLINKy_command {
  double power; //power (percentage), Options: 0.0%-100.0%
  String dir; //direction, Options: "FOR"(forward), "REV"(reverse), "RCW"(rotate-cw), "CCW"(rotate-ccw), "STL"(strafe-left),"STR(strafe-right)"
  double dur; //duration (seconds), Options: <20s
} sLINKy_command;
sLINKy_command move; //any robot move will have the sLINKy command structure
double commandStartTime;
bool runningCommand;
  //use enum instead for gameState?
String gameState = "WT"; //robot will initialize into waiting for new game to be ready
bool newGameNeeded = true; 

  //Comms
#include <WiFi.h>
const char * ssid = "Ponderosa";
const char * password = "Zaq12wsx";
WiFiClient client;
//TODO: Rename to piControlServer
const uint16_t pyGameServerPort = 2727;
const char* pyGameServerIP = "192.168.0.58"; //local rpi IP

//int motor[4] = {PWM_channel, PWM_pin, forward_pin, reverse_pin}
int FrontLeft[4] = {0, 27, 14, 18};
int FrontRight[4] = {1, 13, 5, 12};
int BackRight[4] = {2, 33, 21, 25};
int BackLeft[4] = {3, 4, 2, 19};

//PWM settings
const int frequency = 30000;
const int resolution = 8;

void setup() {
  Serial.begin(115200);
    //setup wifi connection
  WiFi.mode(WIFI_STA); //Needed for connection to local rpi server
  WiFi.begin(ssid, password);
  Serial.println("waiting for wifi to be connected...");
  while (WiFi.status() != WL_CONNECTED){delay(500);} //wait for connection
  Serial.println("WiFi connected");
    //init motors
  setMotorPins(FrontLeft);
  setMotorPins(FrontRight);
  setMotorPins(BackRight);
  setMotorPins(BackLeft);
}

void loop() {
  if (serverComms()){
    if (gameState == "PL"){
      if (!runningCommand){
          //get current player's next command
        commandStartTime = millis()/1000; //start time for next command
        runningCommand = true; //current player's command received
      }
        //run current player's command
      if(!powAtDirForDur(move.power,move.dir,move.dur, commandStartTime)){
        runningCommand = false; //current player's command ended, need new one
        stopAll();
      }
    }else{
      stopAll(); //robot not running unless in play state
    } 
  }else{
    stopAll(); //robot disconnected from server should not run
  }
}

bool serverComms(){
  String request, response;
  if(!runningCommand){
    request = "SLINKY_NXTCOM";
  }else{
    request = "SLINKY_UPDATE";
  }
  if (!client.connect(pyGameServerIP, pyGameServerPort)) {
    Serial.println("Connection to pyGameServer failed. Retrying...");
    delay(5); //delay may not be needed
      //comms unsuccessful, return false
    return false;
  }

    //debug
  Serial.print("Requesting: ");
  Serial.println(request);

    //send request
  client.print(request);
    //retrieve response
  response = gameResponse(); 
    //disconnect to free resources
  client.stop(); 
    //parse response
  gameState = parseGameState(response);
  move = parseMoveCommand(response);
    //comms successful, return true
  return true;
}

String gameResponse(){
  char response[50];
  char nextChar;
  bool received = false;
  bool start = false;
  int i = 0;
  while(!received){
    nextChar = client.read();
    if(nextChar == ';'){
      if(start){
        received = true;
        response[i] = '\0';
      }else{
        start = true;
      }
    }else if(i < 50 && start){
      response[i] = nextChar;
      i++;
    }
  }
  return String(response);
}

String parseGameState(String response){
  int delim = response.indexOf('x');
  return response.substring(0, delim);
}

sLINKy_command parseMoveCommand(String response){
  sLINKy_command parsedCommand;
  int dec1 = 6;
  int dec2 = 15;
  int delims[3];

  int last = 0;
  for (int i = 0; i < 3; i++){
    delims[i] = response.indexOf('x', last + 1);
    last = delims[i];
  }

  Serial.println(response);
  String powerWhole = response.substring(delims[0] + 1, dec1);
  String powerDeci = response.substring(delims[0] + 1 + dec1 + 1, delims[1]);
  parsedCommand.power = powerWhole.toDouble() + powerDeci.toDouble()/10;
  Serial.print("pow: ");
  Serial.println(parsedCommand.power);

  parsedCommand.dir = response.substring(delims[1] + 1, delims[2]);
  Serial.print("dir: ");
  Serial.println(parsedCommand.dir);

  String durWhole = response.substring(delims[2] + 1, dec2);
  String durCenti = response.substring(dec2 + 1);
  parsedCommand.dur = durWhole.toDouble() + durCenti.toDouble()/100;
  Serial.print("dur: ");
  Serial.println(parsedCommand.dur);
  
  return parsedCommand;
}

bool powAtDirForDur(double power, String dir, double dur, double startTime){
  double currTime = millis()/1000;
  if((currTime - startTime) < dur){
    if(dir == "FOR"){
      forwardDrive(power);
    }else if(dir == "REV"){
      reverseDrive(power);
    }else if(dir == "RCW"){
      rotateCW(power);
    }else if(dir == "CCW"){
      rotateCCW(power);
    }else if(dir == "STL"){
      strafeLeft(power);
    }else if(dir == "STR"){
      strafeRight(power);
    }else{
      stopAll();
    }
    return true;
  }else{
    stopAll();
    delay(25);
    return false;
  }
}

void stopAll(){
  stopMotor(FrontLeft);
  stopMotor(FrontRight);
  stopMotor(BackRight);
  stopMotor(BackLeft);
}

void forwardDrive(double power){  //dir = "FOR"
  forwardMotor(FrontLeft, power);
  forwardMotor(FrontRight, power);
  forwardMotor(BackRight, power);
  forwardMotor(BackLeft, power);
}

void reverseDrive(double power){ //dir = "REV"
  reverseMotor(FrontLeft, power);
  reverseMotor(FrontRight, power);
  reverseMotor(BackRight, power);
  reverseMotor(BackLeft, power);
}

void rotateCW(double power){ //dir = "RCW"
  forwardMotor(FrontLeft, power);
  reverseMotor(FrontRight, power);
  reverseMotor(BackRight, power);
  forwardMotor(BackLeft, power);
}

void rotateCCW(double power){//dir = "CCW" 
  reverseMotor(FrontLeft, power);
  forwardMotor(FrontRight, power);
  forwardMotor(BackRight, power);
  reverseMotor(BackLeft, power);
}

void strafeLeft(double power){//dir = "STL"
  reverseMotor(FrontLeft, power);
  forwardMotor(FrontRight, power);
  reverseMotor(BackRight, power);
  forwardMotor(BackLeft, power);
}

void strafeRight(double power){//dir = "STR"
  forwardMotor(FrontLeft, power);
  reverseMotor(FrontRight, power);
  forwardMotor(BackRight, power);
  reverseMotor(BackLeft, power);
}

void setMotorPins(int motor[4]){
  ledcSetup(motor[0], frequency, resolution);
  for (int i = 1; i < 4; i++){
    pinMode(motor[i], OUTPUT);
  }
  ledcAttachPin(motor[1], motor[0]);
}

double mapPowerToDuty(double percentage){
  double duty; //256-bit
  double minPower = 62; //62% of 255 is min operating power for sLINKy
  double maxPower = 77; //77% of 255 is max operating power for sLINKy
  if (percentage <= 0){
    duty = 255 * (minPower / 100);
  }else if (percentage >= 100){
    duty = 255 * (maxPower / 100);
  }else {
    duty = 255 * ((((maxPower - minPower)/ 100))*percentage + minPower)/100;
  }
  return duty;
}

void stopMotor(int motor[4]){
  digitalWrite(motor[2], LOW); 
  digitalWrite(motor[3], LOW);
  ledcWrite(motor[0], 0);
}

void forwardMotor(int motor[4], double power){
  digitalWrite(motor[2], HIGH);
  digitalWrite(motor[3], LOW);
  ledcWrite(motor[0], mapPowerToDuty(power));
}

void reverseMotor(int motor[4], double power){
  digitalWrite(motor[3], HIGH);
  digitalWrite(motor[2], LOW);
  ledcWrite(motor[0], mapPowerToDuty(power));
}

  //for debugging
void testMotor(int motor[4]){
  Serial.print("Testing motor running on PWM channel: ");
  Serial.println(motor[0]);
  forwardMotor(motor, 70);
  Serial.println("Motor driving forward at 70% for 2s");
  delay(2000);
  stopMotor(motor);
  Serial.println("Motor stopped for 1s");
  delay(1000);
  reverseMotor(motor, 70);
  Serial.println("Motor driving reverse at 70% for 2s");
  delay(2000);
  stopMotor(motor);
  Serial.println("Motor stopped. Testing finished.");
  delay(1000);
}

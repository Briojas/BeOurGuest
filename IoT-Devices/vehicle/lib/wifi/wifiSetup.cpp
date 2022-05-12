#include <Arduino.h>
#include <wifiSetup.h>

void wifi_init(char* wifiName, char* wifiPW, bool softAccessPoint, int hiddenAccessPoint){
    IPAddress myIP;
    if (softAccessPoint){ 
            //create an access point
        WiFi.enableAP(true);
        Serial.println(WiFi.softAP(wifiName, wifiPW, 1, hiddenAccessPoint, 4)); //ssid,pw,channel,hidden,connections
        myIP = WiFi.softAPIP();
        Serial.print("Created new access point called: ");
        Serial.println(wifiName);
    } else {
            //connect to existing WiFi network
        WiFi.mode(WIFI_STA); 
        WiFi.begin(wifiName, wifiPW);
        Serial.println("waiting for wifi to be connected...");
        while (WiFi.status() != WL_CONNECTED){delay(500);} //wait for connection
        Serial.println("WiFi connected");
        myIP = WiFi.localIP();
    }
        //display IP address
    Serial.print("IP address: ");
    Serial.print(myIP);
}
/*
Creates, or connects to, an access Point
    - Blake Riojas
*/        

//$$ Libraries $$//
#include <WiFi.h>

//$$ Functions $$//
    /*Inputs: 
        accessPointName     - name of soft access point
        accessPointPW       - password, must be 8 chars
        accessPointSoft     - True: creates an access point with the name and password given
                            - False: connects to an existing access point with the name and password given
        accessPointHidden   - 0: visible, 1: hidden (default)
    */
void wifi_init(char* accessPointName, char* accessPointPW, bool accessPointSoft, int accessPointHidden = 1);

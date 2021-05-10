#include <Arduino.h>
#include <ArduinoJson.h>

struct gps_message_t {
    String message_ID;
    float time;
    float lat;
    float lon;
    float speed;
}gps_message;

void setup() {
    Serial.begin(250000);  // opens serial port, sets data rate to 250kbps
}

void loop() {
    StaticJsonDocument<200> doc;  
    if (Serial.available() > 0) {
        // read the incoming number:
        char buffer[200];
        Serial.readBytesUntil('\n', buffer, 200);

        /* TBC: Parse received message into gps_message struct */
        char *pch;
        pch = strtok(buffer,",");
        gps_message.message_ID = (String) (pch+1); 
        pch = strtok(NULL,",");
        gps_message.time = atof(pch);


        /* - - - - - - - - */

        /* TBC: Serialize gps_message into JSON */



        /* - - - - - - - - */
        
        serializeJson(doc, Serial);
        /* At the end, we send a new line character to denote line termination */
        Serial.println();
 
    }
}
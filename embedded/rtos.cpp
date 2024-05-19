#include <Arduino.h>

void blinkRedLED(void *arg) {
  while (1) {
    Serial.println("RED");
    delay(1000);
  }
}

void blinkGreenLED(void *arg) {
  while (1) {
    Serial.println("GREEN");
    delay(500);
  }
}

void setup() {
  Serial.begin(115200);

  xTaskCreate(
    blinkRedLED    // Specific Red LED C Function
    ,  "Red Blink" // A name just for humans
    ,  2048        // The stack size
    ,  NULL        // Task parameter - NONE - all info in the Task Function
    ,  2           // Priority
    ,  NULL        // Task handle is not used here - simply pass NULL
    );
  xTaskCreate(
    blinkGreenLED    // Specific Green LED C Function
    ,  "Green Blink" // A name just for humans
    ,  2048          // The stack size
    ,  NULL          // Task parameter - NONE - all info in the Task Function
    ,  2             // Priority
    ,  NULL          // Task handle is not used here - simply pass NULL
    );
}

void loop() {
  Serial.println("MAIN");
  delay(5000);
}

#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
  #error Bluetooth is not enabled. Run `make menuconfig` to enable it
#endif

void setup() {
  Serial.begin(115200);
  SerialBT.begin("Smart Clock");
  Serial.println("Clock is ready for pairing...");
}

void loop() {
  if (Serial.available()) {
    SerialBT.write(Serial.read());
  }
  if (SerialBT.available()) {
    String data = SerialBT.readString();
    Serial.print(data);
  }
  delay(20);
}

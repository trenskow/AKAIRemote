#include <CurieBLE.h>

BLEPeripheral blePeripheral;
BLEService remoteService("4D77A91A-559E-11E6-BEB8-9E71128CAE78");

BLEUnsignedCharCharacteristic writeCharacteristic("4D77A91A-559E-11E6-BEB8-9E71128CAE78", BLEWrite | BLERead);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

  //while (!Serial);

  blePeripheral.setLocalName("AKAI GX-630DB Remote");
  blePeripheral.setAdvertisedServiceUuid(remoteService.uuid());

  blePeripheral.addAttribute(remoteService);
  blePeripheral.addAttribute(writeCharacteristic);

  writeCharacteristic.setValue(0);

  for (int pin = 0 ; pin < 7 ; pin++) {
    pinMode(pin + 2, OUTPUT);
    digitalWrite(pin + 2, LOW);
  }

  if (blePeripheral.begin()) {
    Serial.println("BLE Started.");
  } else {
    Serial.println("BLE Failed.");
  }

}

void loop() {
  
  // put your main code here, to run repeatedly:
  BLECentral central = blePeripheral.central();

  if (central.connected()) {
    if (writeCharacteristic.written()) {
      char val = writeCharacteristic.value();
      for (int pin = 2 ; pin <= 6 ; pin++) {
        Serial.print(pin);
        Serial.print(": ");
        Serial.println(val & (1 << pin) ? "ON" : "OFF");
        digitalWrite(pin, val & (1 << pin) ? HIGH : LOW);
      }
      Serial.println("--------");
    }
  }
}

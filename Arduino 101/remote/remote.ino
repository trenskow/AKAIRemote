#include <CurieBLE.h>

BLEPeripheral blePeripheral;
BLEService remoteService("4D77A91A-559E-11E6-BEB8-9E71128CAE78");

BLEUnsignedCharCharacteristic writeCharacteristic("4D77A91A-559E-11E6-BEB8-9E71128CAE78", BLEWrite | BLERead);

void setup() {
  blePeripheral.setLocalName("AKAI GX-630DB Remote");
  blePeripheral.setAdvertisedServiceUuid(remoteService.uuid());

  blePeripheral.addAttribute(remoteService);
  blePeripheral.addAttribute(writeCharacteristic);

  writeCharacteristic.setValue(0);

  for (int pin = 0 ; pin < 7 ; pin++) {
    pinMode(pin + 2, OUTPUT);
    digitalWrite(pin + 2, LOW);
  }

  blePeripheral.begin()

}

void loop() {
  
  BLECentral central = blePeripheral.central();

  if (central.connected()) {
    if (writeCharacteristic.written()) {
      char val = writeCharacteristic.value();
      for (int pin = 2 ; pin <= 6 ; pin++) {
        digitalWrite(pin, val & (1 << pin) ? HIGH : LOW);
      }
    }
  }
}

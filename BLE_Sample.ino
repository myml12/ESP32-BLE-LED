#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>

#define SERVICE_UUID        "951d154b-7c11-adc9-e6ac-3ec1b4cb77bd"
#define CHARACTERISTIC_UUID "bdadc788-d355-0d84-f5af-11b799a05f62"
#define LED_PIN D1

BLECharacteristic *pCharacteristic;

class LEDControlCallback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override {
    String value = String(pChar->getValue().c_str());
    digitalWrite(LED_PIN, value == "1" ? HIGH : LOW);
  }
};

class ServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) override {
    Serial.println("Client connected");
  }
  void onDisconnect(BLEServer* pServer) override {
    Serial.println("Client disconnected → restart advertising");
    pServer->getAdvertising()->start();
  }
};

void setup() {
  Serial.begin(115200);
  Serial.print("aaa");
  pinMode(LED_PIN, OUTPUT);

  BLEDevice::init("LED-Device");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_WRITE
  );
  pCharacteristic->setCallbacks(new LEDControlCallback());

  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->start();
  Serial.println("BLE advertising as LED-Device...");
}

void loop() {
  // 何もしない
}

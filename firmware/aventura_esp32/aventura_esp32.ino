// USB-tested MPU-6880-compatible module; MPU-6500/9250/9255 share this accel/gyro map.
// No magnetometer is used for jump detection.
#include <Arduino.h>
#include <Wire.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_system.h>
#if __has_include("config.h")
#include "config.h"
#else
#error "Copy config.example.h to config.h and confirm the board and wiring first."
#endif
static_assert(IMU_SDA_PIN >= 0 && IMU_SCL_PIN >= 0, "Confirm SDA/SCL pins in config.h.");
WiFiUDP udp;
IPAddress destination;
uint8_t imuAddress=0;
uint32_t sequence=0, lastSample=0, lastReconnect=0;
char bootId[9], deviceId[17];
bool imuReady=false;
bool udpReady=false;

bool readRegisters(uint8_t reg, uint8_t *out, size_t count) {
  Wire.beginTransmission(imuAddress); Wire.write(reg);
  if (Wire.endTransmission(false)!=0) return false;
  if (Wire.requestFrom(imuAddress,count,true)!=count) return false;
  for (size_t i=0;i<count;i++) out[i]=Wire.read();
  return true;
}
bool writeRegister(uint8_t reg,uint8_t value) {
  Wire.beginTransmission(imuAddress);Wire.write(reg);Wire.write(value);
  return Wire.endTransmission()==0;
}
bool initializeImu() {
  uint8_t identity=0;
  const uint8_t addresses[]={0x68,0x69};
  for (uint8_t address: addresses) {
    imuAddress=address;
    if (readRegisters(0x75,&identity,1) && (identity==0x70 || identity==0x71 || identity==0x73 || identity==0x78)) break;
    imuAddress=0;
  }
  if (!imuAddress) return false;
  if (!writeRegister(0x6B,0x80)) return false; // Reset.
  delay(100);
  if (!writeRegister(0x6B,0x01) || !writeRegister(0x6C,0x00)) return false;
  delay(30);
  // 100 Hz, gyro +/-500 dps (65.5 LSB/dps), accelerometer +/-4g (8192 LSB/g).
  return writeRegister(0x1A,0x03) && writeRegister(0x19,9) &&
         writeRegister(0x1B,0x08) && writeRegister(0x1C,0x08) && writeRegister(0x1D,0x03);
}
int16_t signedWord(const uint8_t *b) { return int16_t((uint16_t(b[0])<<8)|b[1]); }
void setup() {
  Serial.begin(230400);delay(300);
  snprintf(bootId,sizeof(bootId),"%08lx",(unsigned long)esp_random());
  snprintf(deviceId,sizeof(deviceId),"%012llx",(unsigned long long)ESP.getEfuseMac());
  if (strlen(PAIR_TOKEN)<32 || strncmp(PAIR_TOKEN,"REPLACE",7)==0) {
    Serial.println("# Configure a unique PAIR_TOKEN before testing.");return;
  }
  Wire.setPins(IMU_SDA_PIN,IMU_SCL_PIN);Wire.begin();Wire.setClock(100000);Wire.setTimeOut(20);
  imuReady=initializeImu();
  if (!imuReady) { Serial.println("# Compatible MPU not detected (WHO_AM_I 0x70/71/73/78). Check module/wiring.");return; }
  if (USE_WIFI) {
    if (!destination.fromString(MAC_IP)) {imuReady=false;Serial.println("# Invalid Mac IP.");return;}
    WiFi.mode(WIFI_STA);WiFi.setSleep(false);WiFi.setAutoReconnect(true);
    WiFi.begin(WIFI_SSID,WIFI_PASSWORD);
  }
  Serial.println("# IMU ready. Raw data only: the Mac recognizes the jump.");
}
void loop() {
  if (!imuReady) {delay(100);return;}
  uint32_t now=millis();
  if (USE_WIFI) {
    if (WiFi.status()==WL_CONNECTED) {
      if (!udpReady) udpReady=udp.begin(9252)==1;
    } else {
      if (udpReady) {udp.stop();udpReady=false;}
      if (uint32_t(now-lastReconnect)>5000) {lastReconnect=now;WiFi.reconnect();}
    }
  }
  if (uint32_t(now-lastSample)<10) {delay(1);return;}
  lastSample=now;
  uint8_t b[14];
  if (!readRegisters(0x3B,b,14)) return; // No fabricated data or heartbeat on I2C failure.
  char packet[384];
  int n=snprintf(packet,sizeof(packet),
    "{\"v\":1,\"token\":\"%s\",\"device\":\"%s\",\"boot\":\"%s\",\"seq\":%lu,\"ms\":%lu,\"a\":[%.4f,%.4f,%.4f],\"g\":[%.2f,%.2f,%.2f]}\n",
    PAIR_TOKEN,deviceId,bootId,(unsigned long)++sequence,(unsigned long)now,
    signedWord(b)/8192.0,signedWord(b+2)/8192.0,signedWord(b+4)/8192.0,
    signedWord(b+8)/65.5,signedWord(b+10)/65.5,signedWord(b+12)/65.5);
  if (n<=0 || n>=int(sizeof(packet))) return;
  if (!USE_WIFI) Serial.write((const uint8_t*)packet,n);
  else if (udpReady && WiFi.status()==WL_CONNECTED) {
    udp.beginPacket(destination,9251);udp.write((const uint8_t*)packet,n);udp.endPacket();
  }
}

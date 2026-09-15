#include <Arduino.h>
#include <Wire.h>

uint8_t sensorAddress=0;
uint8_t sensorIdentity=0;
bool configured=false;
uint32_t lastScan=0,lastSample=0;

bool readBytes(uint8_t address,uint8_t reg,uint8_t *out,size_t count) {
  Wire.beginTransmission(address);Wire.write(reg);
  if (Wire.endTransmission(false)!=0) return false;
  if (Wire.requestFrom(address,count,true)!=count) return false;
  for(size_t i=0;i<count;i++) out[i]=Wire.read();
  return true;
}
bool writeReg(uint8_t reg,uint8_t value) {
  Wire.beginTransmission(sensorAddress);Wire.write(reg);Wire.write(value);
  return Wire.endTransmission()==0;
}
int16_t wordAt(const uint8_t *b) { return int16_t((uint16_t(b[0])<<8)|b[1]); }
void scanSensor() {
  configured=false;sensorAddress=0;
  for(uint8_t address=1;address<127;address++) {
    Wire.beginTransmission(address);
    if (Wire.endTransmission()!=0) continue;
    Serial.printf("{\"event\":\"i2c_device\",\"address\":%u}\n",address);
    if(address!=0x68 && address!=0x69)continue;
    uint8_t identity=0;
    if(!readBytes(address,0x75,&identity,1))continue;
    Serial.printf("{\"event\":\"identity\",\"address\":%u,\"who_am_i\":%u}\n",address,identity);
    if(identity==0x71 || identity==0x70 || identity==0x73 || identity==0x78) {sensorAddress=address;sensorIdentity=identity;}
  }
  if(!sensorAddress) {Serial.println("{\"event\":\"sensor_not_found\"}");return;}
  // MPU-6880 (WHO_AM_I 0x78) uses the same accel/gyro register map.
  // Reference: Linux drivers/iio/imu/inv_mpu6050/inv_mpu_core.c, hw_info MPU6880.
  if(!writeReg(0x6B,0x01)||!writeReg(0x6C,0x00))return;
  delay(100);
  configured=writeReg(0x1A,3)&&writeReg(0x19,9)&&writeReg(0x1B,0x08)&&writeReg(0x1C,0x08)&&writeReg(0x1D,3);
  Serial.printf("{\"event\":\"configured\",\"ok\":%s,\"who_am_i\":%u}\n",configured?"true":"false",sensorIdentity);
}
void setup() {
  Serial.begin(115200);delay(600);
  Wire.begin(21,22);Wire.setClock(100000);Wire.setTimeOut(20);
  Serial.println("{\"event\":\"diagnostic_started\",\"sda\":21,\"scl\":22}");
  scanSensor();lastScan=millis();
}
void loop() {
  uint32_t now=millis();
  if(!configured) {
    if(uint32_t(now-lastScan)>2500) {lastScan=now;scanSensor();}
    delay(10);return;
  }
  if(uint32_t(now-lastSample)<100) {delay(1);return;}
  lastSample=now;uint8_t b[14];
  if(!readBytes(sensorAddress,0x3B,b,14)) {
    configured=false;Serial.println("{\"event\":\"read_failed\"}");return;
  }
  Serial.printf("{\"event\":\"sample\",\"ms\":%lu,\"a\":[%.4f,%.4f,%.4f],\"g\":[%.2f,%.2f,%.2f]}\n",
    (unsigned long)now,wordAt(b)/8192.0,wordAt(b+2)/8192.0,wordAt(b+4)/8192.0,
    wordAt(b+8)/65.5,wordAt(b+10)/65.5,wordAt(b+12)/65.5);
}

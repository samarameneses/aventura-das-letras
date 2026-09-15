#pragma once
// Copy to config.h only after confirming your board/module and wiring.
#define IMU_SDA_PIN -1  // Classic ESP32 DevKit often uses 21; confirm your actual wiring.
#define IMU_SCL_PIN -1  // Classic ESP32 DevKit often uses 22; not universal across ESP32 boards.
#define USE_WIFI false // USB bench first. Set true for wireless operation.
#define WIFI_SSID ""
#define WIFI_PASSWORD ""
#define MAC_IP "192.168.1.100" // Replace with this Mac's LAN IPv4 address.
#define PAIR_TOKEN "REPLACE_WITH_A_RANDOM_TOKEN_MIN_32_CHARS"

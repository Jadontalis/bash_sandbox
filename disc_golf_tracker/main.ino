#include <Arduino.h>
#include <Wire.h>
#include <LSM6DS3.h>
#include <ArduinoBLE.h>



//-------------------HARDWARE MACROS-------------------//

#define GPS_SERIAL Serial1
#define GPS_BAUD 9600
#define BLE_PAYLOAD_SIZE 64
#define SLEEP_SAMPLE_DELAY_MS 50
#define LANDING_SETTLE_TIME_MS 50
#define GPS_LOCK_WAIT_TIME_MS 5000

//-------------------------DEFS & GLOBALS----------------------------//

typedef enum {
  STATE_SLEEP,
  STATE_FLIGHT,
  STATE_LANDED,
} device_state_t;

device_state_t current_state = STATE_SLEEP;

const float THROW_G_THRESHOLD = 5.0;
const float IDLE_G_THRESHOLD = 1.2;

unsigned long last_flight_time = 0;

LSM6DS3 imu_sensor(ISC_MODE, 0x6A);
TinyGPSPlus gps_parser;


BLEService tracker_service("//tbd id");
BLECharacteristic ping_charist("//tbd characteristic");

//-----------------------FUNCTION PROTOTYPES--------------------------//

void sleep_gps(void);
void wake_gps(void);
void process_gps_n_broadcast(float accel_x, float accel_y, float accel_z);
size_t build_mock_protobuf(uint8_t* buffer, float accel_x, float accel_y, float accel_y); //this will get changed to pass more telemetry data


void setup() {
  Serial.begion(115200);
  GPS_SERIAL.begin(GPS_BAUD);
  
  if(imu_sensor.begin() != 0) 
  {
    Serial.println("ERROR: IMU INIT FAILED");
    while(1);
  }

  if(!BLE.begin())
  {
    Serial.println("ERROR: BLE INIT FAILED");
    while(1);
  }

  BLE.setLocalName("DiscTracker_01");
  BLE.setAdvertisedService(tracker_service);
  tracker_service.addCharacteristic(ping_charist);
  BLE.addService(tracker_service);
  BLE.advertise();
  
  sleep_gps();
}

// main loop


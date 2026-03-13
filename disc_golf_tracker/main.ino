#include <Arduino.h>
#include <Wire.h>
#include <LSM6DS3.h>
#include <ArduinoBLE.h>
#include <TinyGPS++.h>

#include "pb_encode.h"
#include "tracker.pb.h"


//-------------------HARDWARE MACROS-------------------//

#define GPS_SERIAL Serial1
#define GPS_BAUD 9600
#define BLE_PAYLOAD_SIZE 64

//#define THROW_G_THRESHOLD 5.0
//#define IDLE_G_THRESHOLD 1.2

#define SLEEP_SAMPLE_DELAY_MS 50
#define LANDING_SETTLE_TIME_MS 2000
#define GPS_LOCK_FINAL_MS 3000

#define BATTERY_PIN A0
#define LOW_BATTERY_MV 3300

//-------------------------DEFS & GLOBALS----------------------------//

typedef enum {
  STATE_SLEEP,
  STATE_FLIGHT,
  STATE_LANDED,
} device_state_t;

device_state_t current_state = STATE_SLEEP;

unsigned long start_flight_time = 0;
unsigned long last_motion_time = 0;

const float THROW_G_THRESHOLD = 5.0;
const float IDLE_G_THRESHOLD = 1.2;

unsigned long last_flight_time = 0;

LSM6DS3 imu_sensor(ISC_MODE, 0x6A);
TinyGPSPlus gps_parser;
BLEService tracker_service("19B10000-E8F2-537E-4F6C-D104768A1214");
BLECharacteristic ping_characteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, BLE_PAYLOAD_SIZE);

//-----------------------FUNCTION PROTOTYPES--------------------------//

void sleep_gps(void);
void wake_gps(void);
uint16_t read_battery_voltage(void);
void process_telemetry(float accel_x, float accel_y, float accel_z);
size_t encode_ping_message(uint8_t* buffer, float accel_x, float accel_y, float accel_y); //this will get changed to pass more telemetry data

//---------------------------MAIN SETUP------------------------------//

void setup() 
{
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
  tracker_service.addCharacteristic(ping_characteristic);
  BLE.addService(tracker_service);
  BLE.advertise();
  
  sleep_gps();
}

// main logic

void loop() {
  BLE.poll();

  if (read_battery_voltage() < LOW_BATTERY_MV) 
  {
    sleep_gps();
    sleep_deep();//add extra sleep logic to prevent battery damage if something is wrong
  }

  float accel_x = imu.sensor.readFloatAccelX();
  float accel_y = imu.sensor.readFloatAccelY();
  float accel_z = imu.sensor.readFloatAccelZ();

  float resultant_g = sqrt(pow(accel_x, 2) + pow(accel_y, 2) + pow(accel_z, 2);

  switch (current_state) 
  {
    case STATE_SLEEP:
        if (resultant_g > IDLE_G_THRESHOLD) 
      {
        current_state = STATE_FLIGHT;
        start_flight_time = millis();
        wake_gps();
        Serial.println("EVENT: LAUNCH DETECTED..");
      }
      delay(50)
      break;

    case STATE_FLIGHT:
      process_telemetry(accel_x, accel_y, accel_z);

      if (resultant_g < IDLE_G_THRESHOLD) 
      {
        if (millis() - last_motion_time > LANDING_SETTLE_TIME_MS)
        {
          current_state = STATE_LANDING;
          Serial.println("EVENT: LANDING DETECTED...");
        }
      } else {
        last_motion_time = millis();
      }
      break;

    case STATE_LANDED:
        //allow GPS time to get stationary position lock
        unsigned long land_time = millis();

        while (millis() - lock_timer < GPS_LOCK_FINAL_MS) 
        {
            process_telemetry(accel_x, accel_y, accel_z);
        }

        sleep_gps();
        current_state = STATE_SLEEP;
        Serial.println("EVENT: GPS LOCKED.. ENTERING SLEEP MODE....");
        break;
  }
}

//func implementation

void process_telemetry(float accel_x, float accel_y, float accel_z)
{
  while (GPS_SERIAL.available() > 0) 
  {
    gps_parser.encode(GPS_SERIAL.read());
  }

  if (gps_parser.location.isUpdated()) 
  {
    encode_ping_message(a_x, a_y, a_z);
  }
}


size_t encode_ping_message(float a_x, float a_y, float a_z)
{
  uint8_t buffer[BLE_PAYLOAD_SIZE];

  tracker_Ping message = tracker_Ping_init_default;

  strncpy(message.device_id, "DISC_01", sizeof(message.device_id));

  message.lat = gps_parser.location.lat();
  message.lon = gps_parser.location.lng();
  message.alt = gps_parser.altitude.meters();
  message.hdop = gps_parser.hdop.hdop();
  message.accel_x = a_x;
  message.accel_y = a_y;
  message.accel_z = a_z;
  message.timestamp = millis();
  
  //serialize the binary stream
  pb_onstream_t stream = pb_ostream_from_buffer(buffer, sizeof(buffer));

  if (pb_encode(&stream, tracker_Ping_fields, &message)) 
  {
    ping_characteristic.writeValue(buffer, stream.bytes_written);
    return stream.bytes_written;
  }
  return 0;

}

void sleep_gps(void)
{
  uint8_t sleep_cmd[] = {0xB5, 0x62, 0x02, 0x41, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x4D, 0x3B};
  GPS.SERIAL.write(sleep_cmd, sizeof(sleep_cmd));
}

void wake_gps()
{
  GPS.SERIAL.write(OxFF);
}


uint16_t read_battery_voltage(void)
{
  uint32_t raw = analogRead(BATTERY_PIN);
  return (uint16_t)((raw* 3300) / 4095) * 2); //this is assuming 1 to 1 voltages


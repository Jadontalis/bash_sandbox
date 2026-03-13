import asyncio
from bleak import BleakScanner, BleakClient
import tracker_pb2  # This is your freshly compiled Python file!

# Match the names and UUIDs from your Arduino firmware
DEVICE_NAME = "DiscTracker_01"
CHAR_UUID = "19B10001-E8F2-537E-4F6C-D104768A1214"

def notification_handler(sender, data):
    """
    This function fires every time the Seeed XIAO broadcasts a new BLE packet.
    It takes the raw binary 'data' and unpacks it using your Protobuf schema.
    """
    ping = tracker_pb2.Ping()
    ping.ParseFromString(data)
    
    print("\n--- New Throw Telemetry Received ---")
    print(f"Device ID: {ping.device_id}")
    print(f"Location:  {ping.lat:.6f}, {ping.lon:.6f} (Alt: {ping.alt}m)")
    print(f"Accuracy:  {ping.hdop} HDOP")
    print(f"IMU Gs:    X:{ping.accel_x:.2f} | Y:{ping.accel_y:.2f} | Z:{ping.accel_z:.2f}")
    print(f"Timestamp: {ping.timestamp}")

async def main():
    print(f"Scanning the area for {DEVICE_NAME}...")
    
    # 1. Find the disc
    device = await BleakScanner.find_device_by_name(DEVICE_NAME, timeout=10.0)
    
    if not device:
        print(f"Could not find {DEVICE_NAME}.")
        print("Is it powered on? (Remember, you may need to shake it to wake it up!)")
        return

    print(f"Found {DEVICE_NAME} at MAC Address {device.address}. Connecting...")
    
    # 2. Connect to the disc
    async with BleakClient(device) as client:
        print("Connected! Subscribing to the telemetry stream...")
        
        # 3. Listen for the Protobuf broadcasts
        await client.start_notify(CHAR_UUID, notification_handler)
        
        print("Listening... (Press Ctrl+C to stop)")
        
        # Keep the script running forever so it can catch every ping
        while True:
            await asyncio.sleep(1)

if __name__ == "__main__":
    # Run the asynchronous Bluetooth loop
    asyncio.run(main())

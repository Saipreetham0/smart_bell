# Smart College Bell Automation System

A complete offline smart bell automation system using ESP32 and Flutter mobile app. The system allows colleges to automate bell schedules without requiring internet connectivity.

## Features

### ESP32 Firmware
- ✅ Offline operation with DS3231 RTC module
- ✅ WiFi Access Point mode (no internet required)
- ✅ Flash memory storage for schedules
- ✅ Relay control for bell activation
- ✅ Manual override button
- ✅ LED status indicator
- ✅ RESTful API endpoints
- ✅ Automatic schedule triggering

### Flutter Mobile App
- ✅ Home screen with current time and next schedule
- ✅ Schedule management (CRUD operations)
- ✅ Time synchronization with ESP32
- ✅ Manual bell control
- ✅ Connection status monitoring
- ✅ Material Design 3 UI

## Hardware Requirements

### ESP32 Components
- ESP32 Development Board
- DS3231 RTC Module
- 5V Relay Module
- Push Button (for manual override)
- LED Indicator
- College Bell/Buzzer
- Jumper Wires

### Wiring Diagram
```
ESP32 Pin    →    Component
GPIO25       →    Relay IN
GPIO2        →    LED Indicator
GPIO34       →    Manual Button (with pull-up)
GPIO21       →    DS3231 SDA
GPIO22       →    DS3231 SCL
GND          →    All GND connections
5V           →    Relay VCC, DS3231 VCC
```

## Installation

### ESP32 Firmware Setup

1. Install PlatformIO IDE or CLI
2. Navigate to the firmware directory:
   ```bash
   cd esp32_firmware
   ```
3. Connect ESP32 via USB
4. Upload firmware:
   ```bash
   pio run --target upload
   ```
5. Monitor serial output:
   ```bash
   pio device monitor
   ```

### Flutter App Setup

1. Ensure Flutter is installed (3.x or higher)
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Usage Guide

### Initial Setup

1. **Power on ESP32**
   - ESP32 creates WiFi hotspot: `SmartBell_AP`
   - Password: `smartbell123`

2. **Connect Mobile Device**
   - Connect phone to `SmartBell_AP` WiFi network
   - Open the Smart Bell app

3. **Sync Time**
   - Go to Settings tab
   - Tap "Sync Time to ESP32"
   - This sets the RTC to current phone time

### Managing Schedules

1. **Add Schedule**
   - Go to Schedules tab
   - Tap the + (Add) button
   - Fill in:
     - Label (e.g., "Morning Bell", "Lunch Break")
     - Day of week
     - Time (HH:MM)
     - Duration (seconds)
   - Tap Save

2. **Delete Schedule**
   - Go to Schedules tab
   - Tap the delete icon on any schedule
   - Confirm deletion

3. **View Schedules**
   - Schedules are grouped by day
   - Shows time, label, and duration
   - Next scheduled bell shown on Home screen

### Manual Control

1. **From App**
   - Go to Home screen
   - Tap "Ring Bell Now" button
   - Bell rings for 5 seconds

2. **From ESP32**
   - Press the manual button on ESP32
   - Bell rings for 5 seconds

### Time Synchronization

- Initial sync required after setup
- Sync again if time drifts
- RTC maintains time even when powered off (coin battery)

## API Documentation

### Base URL
```
http://192.168.4.1
```

### Endpoints

#### Get Schedules
```
GET /get_schedules
Response: Array of schedule objects
```

#### Add Schedule
```
POST /add_schedule
Body: {
  "hour": 9,
  "minute": 0,
  "duration": 5,
  "dayOfWeek": 1,
  "label": "Morning Bell",
  "enabled": true
}
Response: {"success": true, "id": 1}
```

#### Delete Schedule
```
POST /delete_schedule
Body: {"id": 1}
Response: {"success": true}
```

#### Ring Bell Now
```
POST /ring_now
Body: {"duration": 5}
Response: {"success": true}
```

#### Sync Time
```
POST /time_sync
Body: {
  "year": 2025,
  "month": 10,
  "day": 3,
  "hour": 14,
  "minute": 30,
  "second": 0
}
Response: {"success": true}
```

#### Get Current Time
```
GET /get_time
Response: {
  "year": 2025,
  "month": 10,
  "day": 3,
  "hour": 14,
  "minute": 30,
  "second": 15,
  "dayOfWeek": 1
}
```

## Technical Details

### ESP32 Firmware
- **Framework**: Arduino (PlatformIO)
- **Libraries**:
  - WiFi.h - WiFi AP mode
  - WebServer.h - HTTP server
  - Preferences.h - Flash storage
  - RTClib.h - DS3231 RTC
  - ArduinoJson.h - JSON handling
- **Storage**: Up to 20 schedules in flash memory
- **RTC**: I2C communication with DS3231

### Flutter App
- **Framework**: Flutter 3.x
- **State Management**: Provider
- **HTTP Client**: http package
- **Date Formatting**: intl package
- **Architecture**: Provider pattern with separate models, services, and screens

## Troubleshooting

### ESP32 Not Connecting
- Ensure ESP32 is powered on
- Check if WiFi AP `SmartBell_AP` is visible
- Verify password: `smartbell123`
- Restart ESP32 if needed

### Time Not Syncing
- Check WiFi connection
- Ensure app has proper permissions
- Verify ESP32 is responding to API calls
- Check RTC battery if time resets

### Bell Not Ringing
- Check relay connections
- Verify relay is getting power
- Test relay with manual button
- Check bell/buzzer power supply

### Schedules Not Triggering
- Ensure time is synced correctly
- Verify schedule day matches RTC day
- Check if schedule is enabled
- Confirm schedule time format (24-hour)

## Security Notes

- System designed for local network only
- No authentication implemented (school premises only)
- WiFi password should be changed for security
- Not exposed to internet by design

## Future Enhancements

- [ ] Multiple bell patterns
- [ ] Holiday schedule management
- [ ] Schedule import/export
- [ ] Bell volume control
- [ ] Weekly schedule templates
- [ ] Notification logs
- [ ] Web dashboard

## License

This project is provided as-is for educational and commercial use.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review API documentation
3. Verify hardware connections
4. Check serial monitor output from ESP32

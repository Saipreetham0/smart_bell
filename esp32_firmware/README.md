# Smart Bell ESP32 Firmware

## Hardware Requirements
- ESP32 Development Board
- DS3231 RTC Module
- Relay Module (5V)
- Push Button (Manual Override)
- LED Indicator
- Bell/Buzzer

## Wiring Diagram
```
ESP32          Component
GPIO25    -->  Relay IN
GPIO2     -->  LED Indicator
GPIO34    -->  Manual Button (with pull-up)
GPIO21    -->  DS3231 SDA
GPIO22    -->  DS3231 SCL
GND       -->  All GND
5V        -->  Relay VCC, DS3231 VCC
```

## Installation

1. Install PlatformIO IDE or CLI
2. Open this folder in PlatformIO
3. Connect ESP32 via USB
4. Upload firmware:
   ```
   pio run --target upload
   ```

## WiFi Access Point
- SSID: `SmartBell_AP`
- Password: `smartbell123`
- IP Address: `192.168.4.1`

## API Endpoints
- `GET /get_schedules` - Get all schedules
- `POST /add_schedule` - Add new schedule
- `POST /delete_schedule` - Delete schedule by ID
- `POST /ring_now` - Ring bell manually
- `POST /time_sync` - Sync RTC with app time
- `GET /get_time` - Get current RTC time

## Features
- Offline operation with RTC
- Flash memory storage for schedules
- Manual button override
- WiFi AP mode (no internet required)
- LED status indicator
- Auto bell trigger based on schedule

# ESP32 Smart Bell System - Complete User Manual

## Table of Contents
1. [Overview](#overview)
2. [Hardware Requirements](#hardware-requirements)
3. [Wiring Diagram](#wiring-diagram)
4. [Software Requirements](#software-requirements)
5. [Installation Steps](#installation-steps)
6. [System Configuration](#system-configuration)
7. [API Endpoints](#api-endpoints)
8. [Troubleshooting](#troubleshooting)
9. [Technical Specifications](#technical-specifications)

---

## Overview

The ESP32 Smart Bell System is an automated bell controller with real-time clock (RTC) functionality. It allows you to schedule bell rings at specific times and days, with precise timekeeping using the DS3231 RTC module. The system operates as a WiFi Access Point and provides a REST API for remote control.

### Key Features
- Automated bell scheduling with day-of-week support
- Accurate timekeeping with DS3231 RTC (battery backup supported)
- WiFi Access Point for wireless configuration
- REST API for remote control
- Up to 20 scheduled bell times
- Temperature monitoring (built-in DS3231 sensor)
- Manual trigger via API
- Persistent storage in flash memory

---

## Hardware Requirements

### Components List

| Component | Specification | Quantity |
|-----------|--------------|----------|
| ESP32 Development Board | ESP32-DOIT-DEVKIT-V1 or compatible | 1 |
| DS3231 RTC Module | High-precision I2C RTC with temperature sensor | 1 |
| Relay Module | 5V Single Channel Relay (supports 3.3V trigger) | 1 |
| Bell/Buzzer | 12V/5V Electric Bell or Buzzer | 1 |
| LED | Standard LED (any color) | 1 |
| Resistor | 220Ω - 330Ω (for LED) | 1 |
| Power Supply | 5V 2A USB or DC adapter for ESP32 | 1 |
| Jumper Wires | Male-to-Female and Male-to-Male | 10-15 |
| CR2032 Battery | 3V coin cell for RTC backup (optional) | 1 |

### Optional Components
- Enclosure/Case for the project
- Terminal blocks for secure connections
- Heat shrink tubing for wire management

---

## Wiring Diagram

### Pin Connections

#### DS3231 RTC Module to ESP32
```
┌─────────────────┬──────────────────┐
│ DS3231 RTC      │ ESP32 Pin        │
├─────────────────┼──────────────────┤
│ VCC             │ 3V3              │
│ GND             │ GND              │
│ SDA             │ GPIO 21          │
│ SCL             │ GPIO 22          │
│ SQW (optional)  │ GPIO 4           │
└─────────────────┴──────────────────┘
```

#### Relay Module to ESP32
```
┌─────────────────┬──────────────────┐
│ Relay Module    │ ESP32 Pin        │
├─────────────────┼──────────────────┤
│ VCC             │ 5V (VIN)         │
│ GND             │ GND              │
│ IN (Signal)     │ GPIO 27          │
└─────────────────┴──────────────────┘
```

#### LED to ESP32
```
┌─────────────────┬──────────────────┐
│ LED             │ ESP32 Pin        │
├─────────────────┼──────────────────┤
│ Anode (+)       │ GPIO 15 → 330Ω   │
│ Cathode (-)     │ GND              │
└─────────────────┴──────────────────┘
```

#### Bell Connection (via Relay)
```
┌─────────────────┬──────────────────┐
│ Bell            │ Relay Module     │
├─────────────────┼──────────────────┤
│ Positive (+)    │ COM (Common)     │
│ Negative (-)    │ Bell Power GND   │
│ Power Supply +  │ NO (Normally Open)│
└─────────────────┴──────────────────┘
```

### Complete Wiring Diagram

```
                    ┌──────────────┐
                    │   ESP32      │
                    │ DOIT-DEVKIT  │
                    │     V1       │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
┌───────▼────────┐  ┌──────▼──────┐   ┌──────▼──────┐
│  DS3231 RTC    │  │ Relay Module│   │     LED     │
│                │  │             │   │             │
│ SDA → GPIO 21  │  │ IN → GPIO 27│   │ + → GPIO 15 │
│ SCL → GPIO 22  │  │             │   │ - → GND     │
│ VCC → 3V3      │  │ VCC → 5V    │   │  (330Ω)     │
│ GND → GND      │  │ GND → GND   │   └─────────────┘
│ SQW → GPIO 4   │  │             │
└────────────────┘  │ COM ←──┐    │
                    │ NO  ←──┼────┼─→ Bell (+)
                    └────────┼────┘
                             │
                    ┌────────▼────────┐
                    │  Bell Power     │
                    │  Supply         │
                    │  (12V/5V DC)    │
                    └─────────────────┘
```

### Important Wiring Notes
1. **DS3231 VCC:** Connect to 3V3, NOT 5V (DS3231 supports 3.3V-5V, but 3.3V recommended)
2. **Relay VCC:** Connect to 5V (VIN) for proper relay coil operation
3. **GPIO Protection:** ESP32 GPIOs are 3.3V only - never connect to 5V directly
4. **Relay NO vs NC:** Use NO (Normally Open) for bell to be OFF by default
5. **LED Resistor:** 220Ω-330Ω protects LED from overcurrent
6. **RTC Battery:** Insert CR2032 with correct polarity (+) facing up

---

## Software Requirements

### Development Environment
- **PlatformIO IDE** (VS Code extension recommended)
  - OR **Arduino IDE** (version 1.8.x or 2.x)
- **USB Driver** for ESP32 (CP210x or CH340)

### Required Libraries
```ini
bblanchon/ArduinoJson @ ^6.21.3
adafruit/RTClib @ ^2.1.1
```
These are automatically installed by PlatformIO.

---

## Installation Steps

### Step 1: Hardware Assembly

1. **Connect DS3231 RTC Module:**
   - Connect SDA to GPIO 21
   - Connect SCL to GPIO 22
   - Connect VCC to 3V3
   - Connect GND to GND
   - Insert CR2032 battery in RTC module (optional, for backup)

2. **Connect Relay Module:**
   - Connect IN to GPIO 27
   - Connect VCC to 5V (VIN)
   - Connect GND to GND

3. **Connect LED:**
   - Connect LED positive (long leg) to GPIO 15 through 330Ω resistor
   - Connect LED negative to GND

4. **Connect Bell:**
   - Connect bell positive wire to relay COM terminal
   - Connect bell power supply positive to relay NO terminal
   - Connect bell negative and power supply negative together

5. **Safety Check:**
   - Verify all connections match the wiring diagram
   - Ensure no short circuits
   - Check polarity of LED and power supplies
   - Test bell with power supply before connecting to relay

### Step 2: Software Installation

#### Using PlatformIO (Recommended)

1. **Install PlatformIO:**
   ```bash
   # Install VS Code from https://code.visualstudio.com/
   # Then install PlatformIO extension from Extensions marketplace
   ```

2. **Open Project:**
   - Open VS Code
   - File → Open Folder
   - Navigate to `esp32_firmware` folder
   - PlatformIO will auto-detect the project

3. **Build Project:**
   - Click PlatformIO icon in sidebar
   - Select "Build" or press Ctrl+Alt+B
   - Wait for compilation to complete

4. **Upload to ESP32:**
   - Connect ESP32 to computer via USB
   - Click "Upload" or press Ctrl+Alt+U
   - Wait for upload to complete

5. **Monitor Serial Output:**
   - Click "Serial Monitor" or press Ctrl+Alt+S
   - Baud rate should be 115200

#### Using Arduino IDE

1. **Install ESP32 Board Support:**
   - Go to File → Preferences
   - Add to Additional Board Manager URLs:
     ```
     https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
     ```
   - Go to Tools → Board → Board Manager
   - Search "ESP32" and install "esp32 by Espressif Systems"

2. **Install Libraries:**
   - Go to Sketch → Include Library → Manage Libraries
   - Search and install:
     - **ArduinoJson** (by Benoit Blanchon) version 6.21.3 or higher
     - **RTClib** (by Adafruit) version 2.1.1 or higher

3. **Open Source Code:**
   - Copy content of `src/main.cpp` to a new Arduino sketch

4. **Configure Board:**
   - Tools → Board → "ESP32 Dev Module"
   - Upload Speed: 115200
   - Flash Frequency: 80MHz
   - Flash Mode: QIO
   - Flash Size: 4MB
   - Port: Select your ESP32 COM port

5. **Upload:**
   - Click Upload button (→)
   - Wait for "Done uploading" message

### Step 3: First Time Setup

1. **Power On ESP32:**
   - Connect ESP32 to USB power or 5V adapter
   - Blue LED on ESP32 should light up

2. **Check Serial Monitor:**
   - Open serial monitor (115200 baud)
   - You should see output similar to:
   ```
   Initializing DS3231 RTC...
   DS3231 RTC initialized successfully!
   Current RTC time: 2024-01-01 00:00:00
   RTC Temperature: 25.00 C
   AP IP address: 192.168.4.1
   HTTP server started
   ```

3. **If RTC Error Appears:**
   ```
   ERROR: Couldn't find DS3231 RTC!
   Please check wiring:
     SDA -> GPIO 21
     SCL -> GPIO 22
     VCC -> 3V3
     GND -> GND
   ```
   - Double-check I2C connections
   - Verify RTC module is powered (LED on module lit)
   - See [Troubleshooting](#troubleshooting) section

4. **Connect to WiFi:**
   - On your phone/computer, scan for WiFi networks
   - Look for network: **SmartBell_AP**
   - Password: **smartbell123**
   - Once connected, device IP: **192.168.4.1**

5. **Test Connection:**
   - Open web browser
   - Navigate to: `http://192.168.4.1/get_time`
   - You should see JSON response:
   ```json
   {
     "year": 2024,
     "month": 1,
     "day": 1,
     "hour": 0,
     "minute": 0,
     "second": 15,
     "dayOfWeek": 1,
     "temperature": 25.50
   }
   ```

6. **Sync Time (Important!):**
   - Use the time sync API to set correct time
   - See [System Configuration](#system-configuration)

---

## System Configuration

### Initial Time Synchronization

The RTC needs to be set with the correct time. You can do this using:

#### Method 1: Using curl (Command Line)
```bash
curl -X POST http://192.168.4.1/time_sync \
  -H "Content-Type: application/json" \
  -d '{
    "year": 2024,
    "month": 10,
    "day": 16,
    "hour": 14,
    "minute": 30,
    "second": 0
  }'
```

#### Method 2: Using Postman
1. Open Postman
2. Create new POST request
3. URL: `http://192.168.4.1/time_sync`
4. Headers: `Content-Type: application/json`
5. Body (raw JSON):
```json
{
  "year": 2024,
  "month": 10,
  "day": 16,
  "hour": 14,
  "minute": 30,
  "second": 0
}
```
6. Click Send

#### Method 3: Using Flutter App
The time sync is handled automatically by the Flutter app when it connects.

### Configuring WiFi Credentials

To change the Access Point name and password:

1. Open `src/main.cpp`
2. Find lines:
```cpp
const char* AP_SSID = "SmartBell_AP";
const char* AP_PASSWORD = "smartbell123";
```
3. Modify values:
```cpp
const char* AP_SSID = "YourCustomName";
const char* AP_PASSWORD = "YourPassword123";
```
4. Re-upload firmware

### Adjusting Pin Assignments

If your hardware uses different pins:

1. Open `src/main.cpp`
2. Find pin definitions:
```cpp
#define RELAY_PIN 27
#define LED_PIN 15
#define SQW_PIN 4
#define SDA_PIN 21
#define SCL_PIN 22
```
3. Modify as needed:
```cpp
#define RELAY_PIN 25  // Example: Change to GPIO 25
#define LED_PIN 2     // Example: Change to GPIO 2
```
4. Re-upload firmware

---

## API Endpoints

### Base URL
```
http://192.168.4.1
```

### 1. Get Current Time

**Endpoint:** `GET /get_time`

**Description:** Retrieves current time from RTC including temperature

**Request:** No parameters required

**Response:**
```json
{
  "year": 2024,
  "month": 10,
  "day": 16,
  "hour": 14,
  "minute": 30,
  "second": 45,
  "dayOfWeek": 3,
  "temperature": 25.50
}
```

**Field Descriptions:**
- `year`: Current year (2024, etc.)
- `month`: Month (1-12)
- `day`: Day of month (1-31)
- `hour`: Hour in 24-hour format (0-23)
- `minute`: Minute (0-59)
- `second`: Second (0-59)
- `dayOfWeek`: Day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
- `temperature`: RTC chip temperature in Celsius

**Example:**
```bash
curl http://192.168.4.1/get_time
```

### 2. Sync Time

**Endpoint:** `POST /time_sync`

**Description:** Sets the RTC to specified date and time

**Request Body:**
```json
{
  "year": 2024,
  "month": 10,
  "day": 16,
  "hour": 14,
  "minute": 30,
  "second": 0
}
```

**Response:**
```json
{
  "success": true
}
```

**Error Response:**
```json
{
  "error": "RTC not available"
}
```

**Example:**
```bash
curl -X POST http://192.168.4.1/time_sync \
  -H "Content-Type: application/json" \
  -d '{"year":2024,"month":10,"day":16,"hour":14,"minute":30,"second":0}'
```

### 3. Get All Schedules

**Endpoint:** `GET /get_schedules`

**Description:** Retrieves all configured bell schedules

**Request:** No parameters required

**Response:**
```json
[
  {
    "id": 1,
    "hour": 8,
    "minute": 0,
    "duration": 10,
    "dayOfWeek": 1,
    "label": "Morning Bell",
    "enabled": true
  },
  {
    "id": 2,
    "hour": 12,
    "minute": 30,
    "duration": 5,
    "dayOfWeek": 1,
    "label": "Lunch Bell",
    "enabled": true
  }
]
```

**Field Descriptions:**
- `id`: Unique schedule ID
- `hour`: Hour (0-23, 24-hour format)
- `minute`: Minute (0-59)
- `duration`: Bell ring duration in seconds (1-60)
- `dayOfWeek`: Day of week (0=Sunday to 6=Saturday)
- `label`: Schedule description/name
- `enabled`: Whether schedule is active

**Example:**
```bash
curl http://192.168.4.1/get_schedules
```

### 4. Add Schedule

**Endpoint:** `POST /add_schedule`

**Description:** Creates a new bell schedule (max 20 schedules)

**Request Body:**
```json
{
  "hour": 8,
  "minute": 0,
  "duration": 10,
  "dayOfWeek": 1,
  "label": "Morning Bell",
  "enabled": true
}
```

**Parameters:**
- `hour` (required, 0-23): Hour of the day
- `minute` (required, 0-59): Minute of the hour
- `duration` (required, 1-60): Bell ring duration in seconds
- `dayOfWeek` (required, 0-6): Day of week
  - 0 = Sunday
  - 1 = Monday
  - 2 = Tuesday
  - 3 = Wednesday
  - 4 = Thursday
  - 5 = Friday
  - 6 = Saturday
- `label` (optional): Description (max 49 characters)
- `enabled` (optional, default: true): Schedule active state

**Response:**
```json
{
  "success": true,
  "id": 1
}
```

**Error Response:**
```json
{
  "error": "Maximum schedules reached"
}
```

**Example:**
```bash
curl -X POST http://192.168.4.1/add_schedule \
  -H "Content-Type: application/json" \
  -d '{
    "hour": 8,
    "minute": 0,
    "duration": 10,
    "dayOfWeek": 1,
    "label": "Morning Bell",
    "enabled": true
  }'
```

### 5. Delete Schedule

**Endpoint:** `POST /delete_schedule`

**Description:** Removes an existing schedule by ID

**Request Body:**
```json
{
  "id": 1
}
```

**Response:**
```json
{
  "success": true
}
```

**Error Response:**
```json
{
  "error": "Schedule not found"
}
```

**Example:**
```bash
curl -X POST http://192.168.4.1/delete_schedule \
  -H "Content-Type: application/json" \
  -d '{"id": 1}'
```

### 6. Ring Bell Now

**Endpoint:** `POST /ring_now`

**Description:** Manually triggers the bell immediately

**Request Body:**
```json
{
  "duration": 5
}
```

**Parameters:**
- `duration` (optional, 1-60, default: 5): Ring duration in seconds

**Response:**
```json
{
  "success": true
}
```

**Example:**
```bash
curl -X POST http://192.168.4.1/ring_now \
  -H "Content-Type: application/json" \
  -d '{"duration": 5}'
```

**Example (ring for 3 seconds):**
```bash
curl -X POST http://192.168.4.1/ring_now \
  -H "Content-Type: application/json" \
  -d '{"duration": 3}'
```

---

## Troubleshooting

### RTC Not Detected

**Symptom:**
```
ERROR: Couldn't find DS3231 RTC!
Please check wiring:
  SDA -> GPIO 21
  SCL -> GPIO 22
  VCC -> 3V3
  GND -> GND
```

**Solutions:**

1. **Verify I2C Connections:**
   - SDA → GPIO 21 (double-check continuity)
   - SCL → GPIO 22 (double-check continuity)
   - VCC → 3V3 (measure voltage: should be 3.3V)
   - GND → GND

2. **Check RTC Module Power:**
   - Look for LED on RTC module (should be lit)
   - Measure voltage between VCC and GND (should be 3.3V)

3. **Use I2C Scanner:**
   Run I2C scanner code (see Appendix) to detect devices:
   ```
   I2C device found at address 0x68  ← DS3231 should be here
   ```

4. **Check Module Type:**
   - Ensure it's DS3231 (not DS1307 or DS3232)
   - DS3231 address: 0x68

5. **Test Different Wires:**
   - Try different jumper wires
   - Check for broken wires with multimeter

6. **Try Lower I2C Speed:**
   Add to code before `Wire.begin()`:
   ```cpp
   Wire.setClock(100000); // 100kHz instead of default 400kHz
   ```

### WiFi Not Visible

**Symptom:** Cannot find `SmartBell_AP` network

**Solutions:**

1. **Check Serial Monitor:**
   - Should show: "AP IP address: 192.168.4.1"
   - If not, ESP32 may be stuck in boot loop

2. **Restart ESP32:**
   - Press EN button on ESP32
   - Or power cycle (unplug/replug USB)

3. **Verify Power Supply:**
   - ESP32 needs 5V, minimum 500mA
   - USB ports may not provide enough current
   - Try different USB cable or power adapter

4. **Check WiFi Channel:**
   - Some devices don't see all channels
   - Try changing channel in code:
   ```cpp
   WiFi.softAP(AP_SSID, AP_PASSWORD, 1); // Try channel 1, 6, or 11
   ```

5. **Reset WiFi Settings:**
   - Add to setup():
   ```cpp
   WiFi.disconnect(true);
   delay(1000);
   WiFi.mode(WIFI_AP);
   ```

### Bell Not Ringing

**Symptom:** Relay clicks but bell doesn't sound

**Solutions:**

1. **Check Bell Power Supply:**
   - Measure voltage at bell terminals
   - Verify matches bell requirements (5V, 12V, etc.)
   - Test bell directly with power supply

2. **Verify Relay Connections:**
   - Check wiring: COM and NO terminals
   - Listen for relay click (should be audible)
   - Measure voltage across NO when relay activates

3. **Test Relay:**
   - Disconnect bell
   - Use multimeter in continuity mode
   - Trigger relay via API
   - Should see continuity between COM and NO

4. **Check Bell Current:**
   - Relay must handle bell's current draw
   - Typical 5V relay: 10A max
   - Measure bell current with multimeter

5. **Monitor Serial Output:**
   - Should show: "Bell ringing for X seconds"
   - Then: "Bell stopped"

### Relay Always ON at Startup

**Symptom:** Bell rings when ESP32 boots

**Solutions:**

1. **Code Already Has Protection:**
   - Relay is set LOW before and after pinMode
   - Check if relay module is "active low"

2. **Check Relay Module Type:**
   - **Active LOW:** Relay triggers when GPIO is LOW
   - **Active HIGH:** Relay triggers when GPIO is HIGH

3. **If Active LOW Module:**
   Change logic in code:
   ```cpp
   digitalWrite(RELAY_PIN, HIGH); // Start with HIGH (OFF)
   pinMode(RELAY_PIN, OUTPUT);
   digitalWrite(RELAY_PIN, HIGH); // Ensure HIGH (OFF)
   ```

   And in ringBell():
   ```cpp
   digitalWrite(RELAY_PIN, LOW);  // LOW = ON for active-low
   ```

   And in stopBell():
   ```cpp
   digitalWrite(RELAY_PIN, HIGH); // HIGH = OFF for active-low
   ```

4. **Add External Pull-up:**
   - 10kΩ resistor between GPIO 27 and 3.3V
   - Keeps pin HIGH during boot

### Time Keeps Resetting

**Symptom:** RTC loses time after power cycle

**Solutions:**

1. **Install CR2032 Battery:**
   - Insert battery in RTC module holder
   - Ensure correct polarity (+) facing up

2. **Check Battery Voltage:**
   - Measure with multimeter
   - Should be 3.0V minimum
   - Replace if below 2.7V

3. **Clean Battery Contacts:**
   - Use contact cleaner or isopropyl alcohol
   - Ensure good connection

4. **Test Battery Backup:**
   - Set RTC time
   - Remove ESP32 power
   - Wait 5 minutes
   - Restore power and check time
   - Time should be correct

5. **RTC Module May Be Faulty:**
   - Try different DS3231 module
   - Some cheap modules have defective backup circuit

### Schedules Not Triggering

**Symptom:** Bell doesn't ring at scheduled times

**Solutions:**

1. **Verify RTC Time:**
   - Check: `GET /get_time`
   - Ensure time is correct
   - Sync time if needed

2. **Check Schedule Configuration:**
   - Get schedules: `GET /get_schedules`
   - Verify `enabled: true`
   - Check `dayOfWeek` matches (0=Sunday, 1=Monday, etc.)
   - Confirm `hour` and `minute` are correct

3. **Monitor Serial Output:**
   - Should show: "Schedule triggered: [label] at HH:MM"
   - If not appearing, schedule not matching

4. **Verify RTC Available:**
   - Serial should show: "DS3231 RTC initialized successfully!"
   - If RTC unavailable, schedules won't trigger

5. **Test with Near-Future Schedule:**
   - Create schedule for 1 minute from now
   - Watch serial monitor for trigger message

6. **Check Day of Week:**
   - RTC dayOfWeek: 0=Sunday
   - Ensure schedule matches correct day

### Serial Monitor Shows Gibberish

**Symptom:** Unreadable characters in serial output

**Solutions:**

1. **Set Correct Baud Rate:**
   - Must be 115200
   - PlatformIO: Set in monitor settings
   - Arduino IDE: Select 115200 in dropdown

2. **Check USB Cable:**
   - Try different USB cable
   - Some cables are charge-only (no data)

3. **Verify USB Drivers:**
   - Install CP210x or CH340 driver
   - Check Device Manager (Windows) for COM port

4. **Try Different USB Port:**
   - Some USB hubs cause issues
   - Try direct connection to computer

### Cannot Upload Firmware

**Symptom:** Upload fails with errors

**Solutions:**

1. **Press BOOT Button:**
   - Hold BOOT button on ESP32
   - Click Upload
   - Release BOOT when "Connecting..." appears

2. **Check USB Connection:**
   - Verify ESP32 recognized by computer
   - Check Device Manager / System Report

3. **Select Correct Port:**
   - PlatformIO: Auto-detects
   - Arduino IDE: Tools → Port → Select ESP32 port

4. **Erase Flash:**
   ```bash
   pio run --target erase
   ```
   Then upload again

5. **Reduce Upload Speed:**
   In `platformio.ini`:
   ```ini
   upload_speed = 115200
   ```

---

## Technical Specifications

### ESP32 Specifications

| Parameter | Value |
|-----------|-------|
| Microcontroller | ESP32 (Dual-core Xtensa LX6) |
| Clock Speed | 240 MHz |
| Operating Voltage | 3.3V (5V via USB/VIN) |
| Flash Memory | 4MB |
| SRAM | 520KB |
| WiFi | 802.11 b/g/n (2.4 GHz) |
| Operating Temperature | -40°C to +85°C |
| GPIO Pins | 30+ |
| I2C | Hardware supported |

### DS3231 RTC Specifications

| Parameter | Value |
|-----------|-------|
| Model | DS3231 Extremely Accurate I2C RTC |
| Accuracy | ±2ppm (±1 minute/year at 25°C) |
| Temperature Range | -40°C to +85°C |
| Supply Voltage | 2.3V - 5.5V |
| Backup Battery | CR2032 (3V) |
| Battery Life | 5-10 years (typical) |
| I2C Address | 0x68 |
| Clock Speed | 100kHz or 400kHz |
| Temperature Sensor | Built-in (±3°C accuracy) |
| Temperature Resolution | 0.25°C |

### Power Consumption

| Mode | Current Draw |
|------|--------------|
| Idle (WiFi on, LED off) | ~80mA |
| Active (WiFi + LED) | ~100mA |
| Bell ringing | ~120mA + Bell current |
| Deep sleep (not implemented) | ~10µA |

**Note:** Bell current depends on bell type (5-12V, 0.5-2A typical)

### Relay Specifications

| Parameter | Recommended Value |
|-----------|-------------------|
| Coil Voltage | 5V DC |
| Trigger Voltage | 3.3V compatible |
| Contact Rating | 10A @ 250V AC / 10A @ 30V DC |
| Switching Time | <10ms |
| Isolation | Optocoupler isolated |

### Storage Capacity

| Item | Capacity |
|------|----------|
| Maximum Schedules | 20 (configurable up to 50+) |
| Schedule Storage | Non-volatile (Flash memory) |
| Flash Endurance | 100,000 write cycles |
| Data Retention | 20+ years |

---

## Safety Warnings

### ⚠️ Electrical Safety
- **DANGER:** This project may involve mains voltage if using AC-powered bells
- Only qualified electricians should work with mains voltage (110V/220V AC)
- Use proper insulation, enclosures, and follow local electrical codes
- **Recommended:** Use low-voltage bells (12V DC or 5V DC) for safety

### ⚠️ Relay Safety
- Do not exceed relay contact ratings (typically 10A max)
- Ensure proper heat dissipation for high-current loads
- Use flyback diodes for inductive loads (coils, motors)
- Verify relay can handle bell's current draw

### ⚠️ ESP32 Safety
- **NEVER** exceed 3.3V on GPIO pins (will damage ESP32)
- Maximum current per GPIO: 12mA (40mA absolute maximum)
- Use level shifters for 5V devices if needed
- Relay modules usually have built-in level shifting

### ⚠️ Power Supply Safety
- Use quality power adapters (avoid cheap knockoffs)
- Ensure adequate current rating (2A recommended for ESP32)
- Separate high-current loads (bell) from ESP32 power
- Use proper fusing for bell power circuits

### ⚠️ Enclosure Safety
- House electronics in insulated enclosure
- Ensure proper ventilation for heat dissipation
- Keep away from water and moisture
- Label all connections clearly

---

## Maintenance

### Regular Maintenance Schedule

#### Weekly
- Check bell operation via `/ring_now` API
- Verify scheduled rings are working
- Check LED indicator functionality

#### Monthly
- Verify RTC time accuracy (compare with network time)
- Check all physical connections for looseness
- Clean dust from enclosure and components
- Verify WiFi Access Point is accessible

#### Every 6 Months
- Check relay operation (listen for click)
- Inspect wiring for damage or wear
- Test battery backup (power off ESP32, check time retention)
- Verify temperature readings are reasonable

#### Yearly
- **Replace RTC backup battery (CR2032)**
- Inspect relay contacts for wear (if bell used frequently)
- Check power supply voltage output
- Clean relay contacts if needed
- Review schedule configuration for relevance

### Battery Replacement Procedure

1. **Power off ESP32**
2. **Note current time** (write it down)
3. **Remove old CR2032 battery** from RTC module
4. **Insert new CR2032 battery** (+ facing up)
5. **Power on ESP32**
6. **Sync time** using `/time_sync` API
7. **Verify time** using `/get_time` API

### Updating Firmware

#### Preserving Data
Schedules are stored in ESP32 flash memory and will be preserved during firmware updates (unless you erase flash).

#### Update Procedure
1. **Backup schedules** (note them down or use API)
2. Connect ESP32 via USB
3. Upload new firmware using PlatformIO or Arduino IDE
4. Verify schedules: `GET /get_schedules`
5. If schedules missing, re-add them via API
6. RTC time is preserved (battery backup)

---

## Advanced Configuration

### Changing Maximum Schedules

To increase schedule capacity:

1. Edit `src/main.cpp`:
```cpp
Schedule schedules[20];  // Change to 50, 100, etc.
```

2. Re-upload firmware

**Note:** Limited by ESP32 flash memory (Preferences library limit: ~6KB per namespace)

### Adding Multiple Bells

To control multiple bells:

1. Add relay pin definitions:
```cpp
#define RELAY_PIN_1 27
#define RELAY_PIN_2 26
#define RELAY_PIN_3 25
```

2. Initialize all pins in `setup()`
3. Modify `ringBell()` to accept bell ID
4. Add schedule field for bell selection

### Enabling Deep Sleep (Power Saving)

For battery-powered operation:

```cpp
void loop() {
  // ... existing code ...

  // Calculate time until next schedule
  int secondsUntilNext = calculateNextSchedule();

  // Sleep if > 1 minute away
  if (secondsUntilNext > 60) {
    esp_sleep_enable_timer_wakeup(secondsUntilNext * 1000000);
    esp_deep_sleep_start();
  }
}
```

### Adding MQTT Support

For IoT integration:

```cpp
#include <PubSubClient.h>

WiFiClient espClient;
PubSubClient mqtt(espClient);

void publishBellStatus() {
  mqtt.publish("smartbell/status", "ringing");
}
```

### Creating Web Interface

Serve simple HTML dashboard:

```cpp
const char* htmlPage = R"(
<!DOCTYPE html>
<html>
<head><title>Smart Bell</title></head>
<body>
  <h1>Smart Bell Control</h1>
  <button onclick="fetch('/ring_now',{method:'POST',body:JSON.stringify({duration:5})})">
    Ring Bell
  </button>
</body>
</html>
)";

server.on("/", HTTP_GET, []() {
  server.send(200, "text/html", htmlPage);
});
```

---

## Appendix

### I2C Scanner Code

Use this to detect I2C devices:

```cpp
#include <Wire.h>

void setup() {
  Wire.begin(21, 22);
  Serial.begin(115200);
  Serial.println("\nI2C Scanner");
}

void loop() {
  byte error, address;
  int nDevices = 0;

  Serial.println("Scanning...");

  for(address = 1; address < 127; address++) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("I2C device found at address 0x");
      if (address < 16) Serial.print("0");
      Serial.print(address, HEX);
      Serial.println(" !");
      nDevices++;
    }
  }

  if (nDevices == 0)
    Serial.println("No I2C devices found\n");
  else
    Serial.println("Done\n");

  delay(5000);
}
```

### Quick Command Reference

```bash
# Get current time
curl http://192.168.4.1/get_time

# Set time to Oct 16, 2024 2:30 PM
curl -X POST http://192.168.4.1/time_sync \
  -H "Content-Type: application/json" \
  -d '{"year":2024,"month":10,"day":16,"hour":14,"minute":30,"second":0}'

# Get all schedules
curl http://192.168.4.1/get_schedules

# Add Monday 8:00 AM schedule (10 seconds)
curl -X POST http://192.168.4.1/add_schedule \
  -H "Content-Type: application/json" \
  -d '{"hour":8,"minute":0,"duration":10,"dayOfWeek":1,"label":"Morning","enabled":true}'

# Delete schedule ID 1
curl -X POST http://192.168.4.1/delete_schedule \
  -H "Content-Type: application/json" \
  -d '{"id":1}'

# Ring bell now for 5 seconds
curl -X POST http://192.168.4.1/ring_now \
  -H "Content-Type: application/json" \
  -d '{"duration":5}'
```

### PlatformIO Commands

```bash
# Build project
pio run

# Upload firmware
pio run --target upload

# Monitor serial output
pio device monitor

# Build + Upload + Monitor
pio run -t upload && pio device monitor

# Clean build files
pio run --target clean

# Erase flash
pio run --target erase
```

### Useful Resources

- **ESP32 Documentation:** https://docs.espressif.com/projects/esp-idf/en/latest/esp32/
- **DS3231 Datasheet:** https://datasheets.maximintegrated.com/en/ds/DS3231.pdf
- **RTClib Documentation:** https://adafruit.github.io/RTClib/html/index.html
- **ArduinoJson Documentation:** https://arduinojson.org/
- **PlatformIO Docs:** https://docs.platformio.org/

---

## Frequently Asked Questions

**Q: Can I use a different ESP32 board?**
A: Yes, most ESP32 development boards will work. Verify GPIO compatibility and pinout.

**Q: Can I control multiple bells?**
A: Yes, add more relay modules connected to different GPIO pins and modify the code.

**Q: What if I don't have a CR2032 battery?**
A: System will work, but RTC will reset to default time on power loss. Battery highly recommended.

**Q: Can I add a physical button to ring the bell?**
A: Yes, connect button to GPIO with INPUT_PULLUP and add handler in code (previously removed).

**Q: How accurate is the DS3231?**
A: Extremely accurate - ±2ppm means approximately ±1 minute drift per year at 25°C.

**Q: Can I use this outdoors?**
A: ESP32 and electronics must be in weatherproof enclosure. Ensure proper temperature range (-40°C to +85°C).

**Q: What's the maximum bell current?**
A: Depends on relay rating. Typical 5V relays handle 10A. Check your relay specifications.

**Q: Can I integrate with Home Assistant?**
A: Yes, Home Assistant can make HTTP POST/GET requests to the API endpoints.

**Q: Can I use DS1307 instead of DS3231?**
A: Code is specifically for DS3231. DS1307 is less accurate and code would need modification.

**Q: How long do schedules persist?**
A: Schedules are stored in flash memory - persist through power cycles (100,000+ write cycles).

**Q: Can I connect this to the internet?**
A: Current code runs in AP mode. Modify WiFi setup to connect to existing WiFi network for internet access.

**Q: Why use GPIO 27 for relay instead of GPIO 25?**
A: Updated configuration. GPIO 27 avoids conflicts with boot strapping pins.

**Q: What if relay triggers backwards (ON when should be OFF)?**
A: Your relay is "active LOW". Invert the logic in `ringBell()` and `stopBell()` functions.

**Q: Can I schedule different durations for different days?**
A: Yes, create separate schedules for each day with different durations.

**Q: How do I reset everything to defaults?**
A: Use `pio run --target erase` to erase flash, then re-upload firmware.

---

## Support

For additional support, bug reports, or feature requests:
- Check the Troubleshooting section
- Review serial monitor output for error messages
- Verify hardware connections match wiring diagram
- Test with I2C scanner to confirm RTC detection

---

**Document Version:** 1.0
**Last Updated:** October 16, 2024
**Compatible Firmware:** ESP32 Smart Bell v1.0

---

**End of Manual**

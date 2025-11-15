# Smart Bell - Mode-Based Schedule System

## Overview

The Smart Bell system now supports **three different schedule modes**, allowing you to easily switch between different timetables without manually enabling/disabling individual schedules.

### Available Modes

1. **Mode 1: Regular** - Normal class timetable
2. **Mode 2: Mids** - Mid-term examination schedule
3. **Mode 3: Semester** - Semester/final examination schedule

## How It Works

### Concept

- Each schedule is tagged with a mode (1, 2, or 3)
- Only schedules matching the **active mode** will trigger bells
- You can create schedules for all three modes in advance
- Switch between modes instantly without deleting or recreating schedules

### Example Scenario

```
Regular Mode Schedules (Mode 1):
- 08:00 AM - Morning Bell (5s)
- 08:45 AM - Period 1 End (3s)
- 09:30 AM - Period 2 End (3s)
... (normal 45-minute classes)

Mids Exam Mode Schedules (Mode 2):
- 09:00 AM - Exam Start (5s)
- 11:00 AM - Exam End (5s)
- 12:00 PM - Lunch Break (5s)
... (2-hour exam slots)

Semester Exam Mode Schedules (Mode 3):
- 10:00 AM - Exam Start (5s)
- 01:00 PM - Exam End (5s)
... (3-hour exam slots)
```

When you switch from **Regular Mode** to **Mids Mode**, all regular class bells stop, and only mid-term exam bells will ring.

## Technical Implementation

### Backend (ESP32 Firmware)

#### New Data Structure

```cpp
struct Schedule {
  int id;
  int hour;
  int minute;
  int duration;
  int dayOfWeek;
  char label[50];
  bool enabled;
  int mode;  // 1=Regular, 2=Mids, 3=Semester
};

int activeMode = 1;  // Current active mode
```

#### New API Endpoints

**Set Active Mode**
```
POST /set_mode
Body: {"mode": 2}
Response: {"success": true, "mode": 2, "modeName": "Mids"}
```

**Get Active Mode**
```
GET /get_mode
Response: {"mode": 1, "modeName": "Regular"}
```

#### Schedule Checking Logic

The system now checks THREE conditions before ringing a bell:
1. Schedule is enabled
2. **Schedule mode matches active mode**
3. Time and day match

```cpp
if (schedules[i].enabled &&
    schedules[i].mode == activeMode &&  // NEW: Mode check
    schedules[i].hour == currentHour &&
    schedules[i].minute == currentMinute &&
    schedules[i].dayOfWeek == currentDayOfWeek) {
  ringBell(schedules[i].duration);
}
```

### Frontend (Flutter App)

#### Updated Schedule Model

```dart
class Schedule {
  final int id;
  final int hour;
  final int minute;
  final int duration;
  final int dayOfWeek;
  final String label;
  final bool enabled;
  final int mode; // NEW: 1=Regular, 2=Mids, 3=Semester

  String get modeName {
    const modes = ['Unknown', 'Regular', 'Mids', 'Semester'];
    return modes[mode];
  }
}
```

#### New Provider Methods

```dart
// Set active mode
await provider.setMode(2); // Switch to Mids mode

// Get current mode
int currentMode = provider.activeMode;
String modeName = provider.activeModeName;

// Get schedules by mode
List<Schedule> regularSchedules = provider.getSchedulesByMode(1);
List<Schedule> midsSchedules = provider.getSchedulesByMode(2);
List<Schedule> semesterSchedules = provider.getSchedulesByMode(3);

// Get only active mode schedules
List<Schedule> activeSchedules = provider.getActiveSchedules();
```

#### Adding Schedules with Mode

```dart
await provider.addSchedule(
  hour: 9,
  minute: 0,
  duration: 5,
  dayOfWeek: 1, // Monday
  label: "Exam Start",
  mode: 2, // Mids mode
);
```

## Usage Guide

### For School Administrators

#### Setup Phase (One-time)

1. **Create Regular Schedules (Mode 1)**
   ```
   - Add all normal class period bells
   - Tag each with mode = 1
   ```

2. **Create Mids Schedules (Mode 2)**
   ```
   - Add all mid-term exam bells
   - Tag each with mode = 2
   ```

3. **Create Semester Schedules (Mode 3)**
   ```
   - Add all semester/final exam bells
   - Tag each with mode = 3
   ```

#### Daily Operation

**During Regular Classes:**
- Active Mode: **1 (Regular)**
- All regular class bells ring automatically
- Exam bells are ignored

**When Mid-Terms Start:**
- Switch Active Mode to: **2 (Mids)**
- Regular class bells stop
- Mid-term exam bells start ringing

**When Semester Exams Start:**
- Switch Active Mode to: **3 (Semester)**
- Only semester exam bells ring

**When Exams End:**
- Switch Active Mode back to: **1 (Regular)**
- Resume normal class schedule

### Switching Modes via Mobile App

*Note: UI updates will be needed to expose mode switching in the app*

**Settings Screen** (Proposed UI):
```
┌─────────────────────────────────┐
│  Schedule Mode                  │
├─────────────────────────────────┤
│  Current Mode: Regular          │
│                                 │
│  ○ Regular Classes              │
│  ○ Mid-Term Exams              │
│  ○ Semester Exams              │
│                                 │
│  [Switch Mode]                  │
└─────────────────────────────────┘
```

**Schedules Screen** (Show mode badges):
```
┌─────────────────────────────────┐
│  MONDAY                         │
│  ┌─────────────────────────────┐│
│  │ 08:00  Morning Bell    [5s] ││
│  │ [Regular] 🔔 ✏️ 🗑️         ││
│  └─────────────────────────────┘│
│  ┌─────────────────────────────┐│
│  │ 09:00  Exam Start      [5s] ││
│  │ [Mids] 🔔 ✏️ 🗑️            ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

## API Usage Examples

### Using curl

**Check Current Mode:**
```bash
curl http://192.168.4.1/get_mode
```

**Switch to Regular Mode:**
```bash
curl -X POST http://192.168.4.1/set_mode \
  -H "Content-Type: application/json" \
  -d '{"mode": 1}'
```

**Switch to Mids Mode:**
```bash
curl -X POST http://192.168.4.1/set_mode \
  -H "Content-Type: application/json" \
  -d '{"mode": 2}'
```

**Switch to Semester Mode:**
```bash
curl -X POST http://192.168.4.1/set_mode \
  -H "Content-Type: application/json" \
  -d '{"mode": 3}'
```

**Add a Mids Schedule:**
```bash
curl -X POST http://192.168.4.1/add_schedule \
  -H "Content-Type: application/json" \
  -d '{
    "hour": 9,
    "minute": 0,
    "duration": 5,
    "dayOfWeek": 1,
    "label": "Mids Exam Start",
    "enabled": true,
    "mode": 2
  }'
```

## Benefits

### 1. **No Manual Schedule Management**
- No need to disable/enable 10+ schedules when switching between regular and exam periods
- One-click mode switch

### 2. **Advance Planning**
- Create all three types of schedules ahead of time
- Switch instantly when needed

### 3. **No Data Loss**
- All schedules remain in memory
- Switching modes doesn't delete anything
- Can switch back and forth freely

### 4. **Clear Organization**
- Schedules are clearly labeled with their mode
- Easy to see which schedules are for which period
- Reduces confusion

### 5. **Persistent Configuration**
- Active mode is saved to flash memory
- Survives power cycles
- System remembers mode after restart

## Backward Compatibility

### Existing Schedules

All existing schedules (created before this feature) will:
- Default to mode = 1 (Regular)
- Continue working as before
- No data migration needed

### Old Firmware Compatibility

If you upload old firmware without mode support:
- Mode field will be ignored
- All schedules will trigger as before
- Backward compatible

## Data Storage

### Flash Memory

```
Preferences Namespace: "schedules"
├─ count: 20 (number of schedules)
├─ activeMode: 1 (current mode)
├─ sch_0: {schedule 1 data with mode}
├─ sch_1: {schedule 2 data with mode}
└─ ... (up to sch_19)
```

### Size Impact

- Adding mode field: +4 bytes per schedule
- Total additional storage: 80 bytes (20 schedules × 4 bytes)
- Well within ESP32 flash capacity

## Testing Checklist

### After Uploading New Firmware

- [ ] Create a schedule with mode=1, verify it saves
- [ ] Create a schedule with mode=2, verify it saves
- [ ] Create a schedule with mode=3, verify it saves
- [ ] Switch to mode 1, verify only mode-1 schedules trigger
- [ ] Switch to mode 2, verify only mode-2 schedules trigger
- [ ] Switch to mode 3, verify only mode-3 schedules trigger
- [ ] Power cycle ESP32, verify active mode persists
- [ ] Check serial monitor shows correct mode on boot
- [ ] Verify /get_mode API returns correct data
- [ ] Verify /set_mode API switches correctly

### Mode Switching Test

1. Create test schedules:
   ```
   Mode 1: 14:00 "Regular Test"
   Mode 2: 14:01 "Mids Test"
   Mode 3: 14:02 "Semester Test"
   ```

2. Set mode to 1, wait until 14:00
   - Should ring "Regular Test" only

3. Set mode to 2, wait until 14:01
   - Should ring "Mids Test" only

4. Set mode to 3, wait until 14:02
   - Should ring "Semester Test" only

## Troubleshooting

### Problem: Wrong schedules are ringing

**Check:**
1. Verify current active mode: `GET /get_mode`
2. Check schedule's mode field matches expectation
3. Ensure you set mode, not just created schedules

### Problem: No schedules ringing

**Check:**
1. Are there any schedules for the active mode?
2. Use `getSchedulesByMode(activeMode)` to verify
3. Check if schedules are enabled
4. Verify time is synced correctly

### Problem: Mode doesn't persist after restart

**Check:**
1. Ensure `saveSchedules()` is called after setMode
2. Check preferences namespace is correct
3. Flash memory may be full (unlikely)

### Problem: Old schedules don't have mode

**Solution:**
- Old schedules default to mode=1 automatically
- Edit and re-save to set different mode
- Or delete and recreate with mode field

## Future Enhancements

### Potential Features

1. **More Modes**
   - Holiday schedule (Mode 4)
   - Half-day schedule (Mode 5)
   - Custom modes

2. **Automatic Mode Switching**
   - Schedule mode changes by date
   - Example: "Switch to Mids on Nov 15"

3. **Mode Templates**
   - Import/export mode schedules
   - Share between schools

4. **Mode Schedule Preview**
   - See all schedules for a mode before switching
   - Compare modes side-by-side

5. **Quick Mode Toggle**
   - Physical button to cycle modes
   - Voice command mode switching

## Summary

The mode-based schedule system transforms the Smart Bell into a truly flexible solution that adapts to different school scenarios without manual schedule management. Whether it's regular classes, mid-terms, or semester exams, switching is now as simple as changing a single mode setting.

### Key Takeaways

✅ **Three modes**: Regular, Mids, Semester
✅ **One-click switching**: Change modes instantly
✅ **Persistent storage**: Mode survives power cycles
✅ **Backward compatible**: Existing schedules work fine
✅ **No data loss**: All schedules preserved
✅ **Easy to use**: Simple API and future UI integration

---

**Version:** 1.0
**Last Updated:** November 2025
**Feature Status:** Implemented and Ready for Testing

# Smart Bell Automation System
## Complete User Manual

---

## Table of Contents

1. [Welcome](#welcome)
2. [What is Smart Bell?](#what-is-smart-bell)
3. [Quick Start Guide](#quick-start-guide)
4. [Hardware Setup](#hardware-setup)
5. [Mobile App Installation](#mobile-app-installation)
6. [Using the Mobile App](#using-the-mobile-app)
7. [Managing Schedules](#managing-schedules)
8. [Settings and Configuration](#settings-and-configuration)
9. [Common Tasks](#common-tasks)
10. [Troubleshooting](#troubleshooting)
11. [Frequently Asked Questions](#frequently-asked-questions)
12. [Safety and Maintenance](#safety-and-maintenance)
13. [Support and Contact](#support-and-contact)

---

## Welcome

Welcome to the Smart Bell Automation System! This manual will help you set up and use your automated bell system. Whether you're a teacher, administrator, or technical staff member, this guide will walk you through everything step-by-step.

### Who Should Read This Manual?

- **School Administrators** - Learn how to manage bell schedules
- **Teachers** - Understand how to use the manual bell feature
- **Technical Staff** - Set up and maintain the system
- **IT Personnel** - Install and configure the hardware

### What You'll Learn

- How to connect to the Smart Bell system
- How to add, edit, and delete bell schedules
- How to ring the bell manually
- How to troubleshoot common issues
- How to maintain the system

---

## What is Smart Bell?

The Smart Bell Automation System is a modern solution that automatically rings your school bell at scheduled times. No more manual bell ringing or missed classes!

### Key Benefits

✅ **Automatic Operation** - Bells ring automatically based on your schedule
✅ **No Internet Required** - Works completely offline
✅ **Easy to Use** - Control everything from your smartphone
✅ **Accurate Timing** - Never miss a bell with precise timekeeping
✅ **Flexible Scheduling** - Different schedules for different days
✅ **Manual Override** - Ring the bell anytime you need

### How It Works

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│ Your Phone   │  WiFi   │   ESP32      │  Relay  │  School Bell │
│ with App     │ ←────→  │  Controller  │ ────→   │    Rings     │
└──────────────┘         └──────────────┘         └──────────────┘
```

1. **ESP32 Controller** - The brain of the system, keeps track of time and schedules
2. **Mobile App** - Your control panel for managing schedules
3. **WiFi Connection** - Direct connection between your phone and the controller
4. **School Bell** - Your existing bell, now automated!

---

## Quick Start Guide

### For First-Time Users

Follow these simple steps to get started in under 15 minutes:

#### Step 1: Power On (2 minutes)
1. Plug in the ESP32 controller to power
2. Wait for the blue LED to light up
3. The controller creates a WiFi network named **SmartBell_AP**

#### Step 2: Connect Your Phone (3 minutes)
1. Open WiFi settings on your phone
2. Look for network: **SmartBell_AP**
3. Password: **smartbell123**
4. Connect to this network

#### Step 3: Open the App (2 minutes)
1. Install the Smart Bell app on your phone
2. Open the app
3. You should see the home screen with current time

#### Step 4: Set the Time (3 minutes)
1. Tap the **Settings** tab at the bottom
2. Tap **"Sync Time to ESP32"**
3. Wait for confirmation message
4. Check that the displayed time is correct

#### Step 5: Add Your First Schedule (5 minutes)
1. Tap the **Schedules** tab
2. Tap the **+** (Plus) button
3. Fill in:
   - **Label**: "Morning Bell"
   - **Day**: Monday
   - **Time**: 08:00 AM
   - **Duration**: 5 seconds
4. Tap **Save**
5. Your first schedule is now active!

#### Step 6: Test the Bell
1. Go to **Home** tab
2. Tap **"Ring Bell Now"**
3. The bell should ring for 5 seconds

🎉 **Congratulations!** Your Smart Bell system is now set up and ready to use.

---

## Hardware Setup

### What's in the Box?

Your Smart Bell system includes:

- **ESP32 Development Board** - The main controller
- **DS3231 RTC Module** - Keeps accurate time
- **Relay Module** - Controls the bell
- **LED Indicator** - Shows when bell is active
- **Power Supply** - Powers the system
- **Jumper Wires** - Connects everything together

### Basic Setup for Non-Technical Users

**Important:** If you're not comfortable with electronics, please ask your school's technical staff or an electrician to perform the hardware setup.

#### Safety First!

⚠️ **WARNING**: Installation involves electrical connections. Please follow these safety rules:

- ✋ Never work on the system while it's powered on
- 🔌 Disconnect all power before making any changes
- 👨‍🔧 If connecting to mains voltage (110V/220V), hire a qualified electrician
- 🏫 We recommend using low-voltage bells (12V or 5V DC) for safety

### Installation Location

Choose a good location for the controller:

✅ **Good Locations:**
- Near the bell
- In a secure room (office, server room)
- Away from water and moisture
- Good WiFi signal range
- Protected from tampering

❌ **Avoid:**
- Outdoor locations without weatherproof enclosure
- Areas with extreme heat or cold
- Near water sources
- Where students can access it

### Wiring Overview (For Technical Staff)

```
ESP32 Controller Connections:

DS3231 RTC Module:
├─ VCC → ESP32 3V3
├─ GND → ESP32 GND
├─ SDA → ESP32 GPIO 21
└─ SCL → ESP32 GPIO 22

Relay Module:
├─ VCC → ESP32 5V
├─ GND → ESP32 GND
└─ IN  → ESP32 GPIO 27

LED Indicator:
├─ Positive (+) → ESP32 GPIO 15 (with 330Ω resistor)
└─ Negative (-) → ESP32 GND

School Bell:
├─ Connected through relay
└─ Requires separate power supply
```

**Note:** Detailed wiring diagrams are available in the technical manual (MANUAL.md) for your technical staff.

---

## Mobile App Installation

### For Android Users

#### Option 1: Install from APK File

1. **Get the APK File**
   - Download `smart_bell.apk` from your administrator
   - Transfer it to your phone via USB or email

2. **Enable Unknown Sources**
   - Open **Settings** → **Security**
   - Enable **"Install from Unknown Sources"**
   - Or grant permission when prompted

3. **Install the App**
   - Locate the APK file in your phone's Downloads folder
   - Tap on it
   - Tap **Install**
   - Wait for installation to complete
   - Tap **Open**

4. **Allow Permissions**
   - The app may request permissions
   - Allow all requested permissions for proper functionality

#### Option 2: Build from Source (For Developers)

```bash
# Clone the repository
git clone [repository-url]
cd smart_bell

# Install dependencies
flutter pub get

# Connect your Android device via USB
# Enable USB Debugging on your device

# Build and install
flutter run
```

### For iOS Users (Optional)

iOS installation requires:
- macOS computer with Xcode
- Apple Developer account (for deployment)
- Physical iOS device or simulator

Contact your technical administrator for iOS builds.

---

## Using the Mobile App

### Understanding the Interface

The Smart Bell app has three main screens, accessible via tabs at the bottom:

```
┌─────────────────────────────────────┐
│         Smart Bell App              │
├─────────────────────────────────────┤
│                                     │
│        [Main Content Area]          │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  🏠 Home  |  📅 Schedules | ⚙️ Settings │
└─────────────────────────────────────┘
```

---

### Home Screen

The **Home** screen is your dashboard. Here's what you'll see:

#### Current Time Display
```
┌─────────────────────────┐
│   Current Time          │
│                         │
│      14:30:25           │
│   Wednesday, Nov 3      │
└─────────────────────────┘
```

Shows the current time from the ESP32 controller. If this doesn't match your phone's time, go to Settings to sync.

#### Next Scheduled Bell
```
┌─────────────────────────┐
│   Next Bell             │
│                         │
│   15:00 - Lunch Bell    │
│   In 30 minutes         │
└─────────────────────────┘
```

Displays when the next bell will ring automatically.

#### Ring Bell Now Button
```
┌─────────────────────────┐
│  [ 🔔 Ring Bell Now ]   │
└─────────────────────────┘
```

Tap this button to ring the bell immediately for 5 seconds. Use this for:
- Testing the system
- Emergency announcements
- Special occasions
- Manual class changes

#### Connection Status
```
● Connected to ESP32
```

- **Green dot** = Connected and working
- **Red dot** = Not connected (check WiFi)

---

### Schedules Screen

The **Schedules** screen lets you manage all bell schedules.

#### Viewing Schedules

Schedules are organized by day:

```
┌─────────────────────────────────────┐
│  Schedules                    [+]   │
├─────────────────────────────────────┤
│  MONDAY                             │
│  ┌───────────────────────────────┐ │
│  │ 08:00  Morning Bell    [5s]   │ │
│  │ 🔔 Toggle  ✏️ Edit  🗑️ Delete │ │
│  └───────────────────────────────┘ │
│  ┌───────────────────────────────┐ │
│  │ 12:30  Lunch Bell      [3s]   │ │
│  │ 🔔 Toggle  ✏️ Edit  🗑️ Delete │ │
│  └───────────────────────────────┘ │
│                                     │
│  TUESDAY                            │
│  ┌───────────────────────────────┐ │
│  │ 08:00  Morning Bell    [5s]   │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

Each schedule shows:
- **Time** - When the bell will ring (24-hour format)
- **Label** - Description (e.g., "Morning Bell", "Lunch Break")
- **Duration** - How long the bell rings (in seconds)
- **Toggle** - Enable/disable without deleting
- **Edit** - Modify the schedule
- **Delete** - Remove permanently

#### Adding a New Schedule

1. **Tap the + Button** (top right)

2. **Fill in the Form:**

```
┌─────────────────────────────────────┐
│  Add Schedule                       │
├─────────────────────────────────────┤
│  Label                              │
│  [Morning Bell____________]         │
│                                     │
│  Day of Week                        │
│  [Monday ▼]                         │
│                                     │
│  Time                               │
│  [08] : [00]                        │
│                                     │
│  Duration (seconds)                 │
│  [5________]                        │
│                                     │
│  [ Cancel ]      [ Save ]           │
└─────────────────────────────────────┘
```

**Field Descriptions:**

- **Label**: Give your schedule a name
  - Examples: "Morning Bell", "Lunch", "Recess", "End of Day"
  - Maximum 50 characters

- **Day of Week**: Choose when this bell rings
  - Sunday = 0
  - Monday = 1
  - Tuesday = 2
  - Wednesday = 3
  - Thursday = 4
  - Friday = 5
  - Saturday = 6

- **Time**: When to ring (24-hour format)
  - 08:00 = 8:00 AM
  - 13:00 = 1:00 PM
  - 18:30 = 6:30 PM

- **Duration**: How long the bell rings
  - Recommended: 3-5 seconds
  - Maximum: 60 seconds
  - Minimum: 1 second

3. **Tap Save**

4. **Confirmation** appears: "Schedule added successfully"

#### Editing a Schedule

1. Tap the **✏️ Edit** icon on any schedule
2. Modify the fields you want to change
3. Tap **Save**
4. Changes take effect immediately

#### Deleting a Schedule

1. Tap the **🗑️ Delete** icon on any schedule
2. Confirm deletion when prompted
3. The schedule is removed permanently

**Tip:** Instead of deleting, use the Toggle switch to temporarily disable schedules!

#### Enabling/Disabling Schedules

Use the **Toggle Switch** (🔔) to:
- ✅ **Enabled** (green) - Bell will ring automatically
- ⭕ **Disabled** (gray) - Schedule is kept but won't ring

**Use Cases:**
- Disable schedules during holidays
- Temporarily skip certain bells
- Keep schedules for later without deleting

---

### Settings Screen

The **Settings** screen provides system configuration and testing options.

```
┌─────────────────────────────────────┐
│  Settings                           │
├─────────────────────────────────────┤
│  Server Configuration               │
│  ┌───────────────────────────────┐ │
│  │ Server URL                    │ │
│  │ [http://192.168.4.1_______]   │ │
│  │ [Update URL]                  │ │
│  └───────────────────────────────┘ │
│                                     │
│  Time Synchronization               │
│  ┌───────────────────────────────┐ │
│  │ ESP32 Time: 14:30:25          │ │
│  │ [Sync Time to ESP32]          │ │
│  └───────────────────────────────┘ │
│                                     │
│  Bell Testing                       │
│  ┌───────────────────────────────┐ │
│  │ Test Duration:                │ │
│  │ [3s] [5s] [10s]               │ │
│  │ [Ring Test Bell]              │ │
│  └───────────────────────────────┘ │
│                                     │
│  Connection Status                  │
│  ┌───────────────────────────────┐ │
│  │ ● Connected to ESP32          │ │
│  │ [Test Connection]             │ │
│  └───────────────────────────────┘ │
│                                     │
│  About                              │
│  Version 1.0.0                      │
└─────────────────────────────────────┘
```

#### Server URL Configuration

**Default:** `http://192.168.4.1`

Only change this if:
- Your IT department modified the default IP
- Using multiple Smart Bell systems
- Instructed by technical support

**To Change:**
1. Tap on the URL field
2. Enter new URL
3. Tap **Update URL**
4. App will test connection to new URL

#### Time Synchronization

**Why Sync Time?**

The ESP32 controller keeps its own time using a Real-Time Clock (RTC). You need to sync it:
- When first setting up the system
- After power loss (if RTC battery is dead)
- If you notice time drift

**How to Sync:**

1. Make sure your phone has correct time
2. Tap **"Sync Time to ESP32"**
3. Wait for confirmation: "Time synced successfully"
4. The displayed ESP32 time should match your phone

**When to Sync:**
- ✅ During initial setup (required)
- ✅ Once a month to ensure accuracy
- ✅ After any power outage
- ✅ If bells are ringing at wrong times

**RTC Battery Note:**
The system has a backup battery (CR2032) that keeps time even when unplugged. If time resets after power loss, the battery needs replacement.

#### Bell Testing

Test your bell without affecting schedules:

1. **Choose Test Duration:**
   - Tap **[3s]**, **[5s]**, or **[10s]**
   - Selected button will be highlighted

2. **Ring Test Bell:**
   - Tap **"Ring Test Bell"**
   - Bell will ring for selected duration
   - Use this to:
     - Verify hardware is working
     - Adjust bell volume
     - Train staff on bell sound
     - Test after maintenance

#### Connection Testing

**Test Connection Button:**

Tap this to verify communication with ESP32:
- ✅ **Success** - "Connected to ESP32" (green indicator)
- ❌ **Failed** - "Cannot connect to ESP32" (red indicator)

**If Connection Fails:**
1. Check WiFi connection to SmartBell_AP
2. Verify ESP32 is powered on
3. Check Server URL is correct
4. See [Troubleshooting](#troubleshooting) section

---

## Managing Schedules

### Planning Your Bell Schedule

#### Typical School Day Schedule

Here's an example schedule for a typical school:

**Monday - Friday:**
```
08:00 - Morning Bell (5 seconds)
08:45 - End of 1st Period (3 seconds)
09:30 - End of 2nd Period (3 seconds)
10:15 - Morning Break (5 seconds)
10:30 - End of Break (5 seconds)
11:15 - End of 3rd Period (3 seconds)
12:00 - Lunch Break (5 seconds)
13:00 - End of Lunch (5 seconds)
13:45 - End of 4th Period (3 seconds)
14:30 - End of 5th Period (3 seconds)
15:15 - End of School Day (5 seconds)
```

#### Best Practices

**Naming Schedules:**
- ✅ Use clear, descriptive names
  - Good: "Morning Bell", "Lunch Start", "End of Period 1"
  - Bad: "Bell 1", "Ring", "Test"

**Bell Duration:**
- **Short rings (3 seconds)**: Period changes
- **Medium rings (5 seconds)**: Major transitions (morning, lunch, end)
- **Long rings (7-10 seconds)**: Special events, emergencies

**Organizing by Day:**
- Create separate schedules for different days
- Use Monday-Friday for regular school days
- Different schedules for half-days, exam days, etc.

#### Schedule Limits

- **Maximum schedules**: 20 total
- **Schedules per day**: No limit (up to total maximum)
- **Time precision**: Minutes (not seconds)

**Tip:** If you reach the 20-schedule limit, delete unused schedules or consolidate similar ones.

### Creating Different Day Schedules

#### Regular School Days (Monday - Friday)

Create identical schedules for each weekday:

1. Create schedule for Monday
2. Duplicate for Tuesday, Wednesday, Thursday, Friday
3. Adjust times if needed for specific days

#### Special Schedules

**Early Dismissal Days:**
- Create separate Friday schedule with earlier times
- Disable regular Friday schedules
- Enable early dismissal schedule

**Exam Days:**
- Create longer period schedules
- Disable break bells if needed
- Use toggle to switch between normal and exam schedules

**Event Days:**
- Create custom schedules for assemblies, sports days
- Add extra bells for special events
- Temporarily disable regular schedules

### Managing Many Schedules

#### Organization Tips

1. **Use Clear Labels:**
   ```
   ✅ Good: "Mon-8AM-Morning", "Tue-12PM-Lunch"
   ❌ Bad: "Bell1", "Ring2"
   ```

2. **Group by Day:**
   - All Monday schedules together
   - All Tuesday schedules together
   - Makes viewing easier

3. **Document Your Schedules:**
   - Keep a printed copy of all schedules
   - Update when making changes
   - Share with staff

#### Seasonal Changes

**Summer Schedule:**
- Adjust times for summer session
- Use toggle to disable instead of deleting
- Re-enable in fall

**Holiday Periods:**
- Disable all schedules during breaks
- No need to delete
- Re-enable when school resumes

---

## Common Tasks

### Daily Operations

#### Starting Your Day

**Morning Checklist (5 minutes):**

1. ✅ Check ESP32 is powered on (blue LED lit)
2. ✅ Connect to SmartBell_AP WiFi
3. ✅ Open Smart Bell app
4. ✅ Verify time on Home screen is correct
5. ✅ Check "Next Bell" shows correct schedule
6. ✅ Test bell once if desired (Settings → Ring Test Bell)

**You're all set!** The system will now ring bells automatically.

#### Manual Bell Ringing

**When to Use Manual Bell:**
- Fire drills
- Emergency dismissals
- Assembly announcements
- Special events
- Testing

**How to Ring Manually:**
1. Open Smart Bell app
2. Go to **Home** tab
3. Tap **"Ring Bell Now"**
4. Bell rings for 5 seconds
5. Can be repeated immediately if needed

**Quick Access Tip:** Keep the app open on the Home screen for fastest access to manual bell.

### Weekly Maintenance

**Every Monday (2 minutes):**

1. Test the bell:
   - Settings → Ring Test Bell → [5s]
   - Verify bell sounds clearly

2. Check time accuracy:
   - Compare ESP32 time with phone
   - Sync if more than 1 minute difference

3. Review schedules:
   - Verify all needed schedules are enabled
   - Disable any special day schedules from previous week

### Monthly Maintenance

**First Day of Each Month (5 minutes):**

1. **Time Check:**
   - Settings → Sync Time to ESP32
   - Even if time looks correct

2. **Schedule Review:**
   - Schedules → Review all entries
   - Delete unused schedules
   - Add any new schedules needed

3. **Hardware Check:**
   - Verify ESP32 LED is on
   - Check for loose wires (if accessible)
   - Ensure bell is functioning properly

4. **Backup Schedules:**
   - Take screenshots of all schedules
   - Or write them down
   - Keep in safe place

### Changing Schedules

#### Temporary Changes (Use Toggle)

**Example: School Assembly**

1. Go to **Schedules** tab
2. Find conflicting schedules
3. Tap toggle switch to **disable** (turns gray)
4. Schedules won't ring but remain saved
5. After assembly, tap toggle to **enable** again (turns green)

#### Permanent Changes (Edit)

**Example: New Lunch Time**

1. Go to **Schedules** tab
2. Find "Lunch Bell" schedule
3. Tap **✏️ Edit**
4. Change time from 12:00 to 12:30
5. Tap **Save**
6. New time takes effect immediately

#### Seasonal Changes (Multiple Schedules)

**Example: Summer Schedule**

**Spring - Preparing for Summer:**
1. Create all summer schedules
2. Keep them disabled (toggle off)
3. Label clearly: "Summer - Morning Bell"

**First Day of Summer:**
1. Disable all regular schedules
2. Enable all summer schedules

**First Day of Fall:**
1. Disable all summer schedules
2. Enable all regular schedules

### Handling Emergencies

#### Bell Won't Ring

**Quick Fix Steps:**

1. **Manual Override:**
   - Try Home → Ring Bell Now
   - If works: Schedule issue (check time/day)
   - If doesn't work: Hardware issue (see below)

2. **Check Power:**
   - Verify ESP32 has power (blue LED on)
   - Check power cable connections

3. **Check WiFi:**
   - Settings → Test Connection
   - Reconnect to SmartBell_AP if needed

4. **Restart System:**
   - Unplug ESP32 power
   - Wait 10 seconds
   - Plug back in
   - Wait 30 seconds for boot
   - Try manual bell again

5. **Emergency Backup:**
   - Use traditional manual bell if available
   - Contact technical support

#### Time is Wrong

**Quick Fix:**

1. Settings → Check ESP32 time
2. If wrong: Tap "Sync Time to ESP32"
3. Verify time is now correct
4. Check schedules will ring at right times

**If time keeps resetting:**
- RTC battery (CR2032) needs replacement
- Contact technical staff

#### Can't Connect to WiFi

**Quick Fix:**

1. **Forget Network:**
   - Phone Settings → WiFi
   - Tap SmartBell_AP
   - Tap "Forget Network"

2. **Reconnect:**
   - Find SmartBell_AP in WiFi list
   - Enter password: smartbell123
   - Wait for connection

3. **Verify:**
   - Open Smart Bell app
   - Should connect automatically
   - Settings → Test Connection

4. **Still Not Working:**
   - Restart ESP32 (unplug/replug power)
   - Wait 30 seconds
   - Try connecting again

---

## Troubleshooting

### Connection Issues

#### Problem: Cannot Find SmartBell_AP WiFi Network

**Symptoms:**
- WiFi network "SmartBell_AP" not visible in WiFi list

**Solutions:**

1. **Check ESP32 Power:**
   - ✅ Is the blue LED on ESP32 lit?
   - ❌ If not: Check power cable, try different outlet

2. **Wait for Boot:**
   - ESP32 takes 30 seconds to start WiFi after power on
   - Wait, then refresh WiFi list

3. **Check Distance:**
   - WiFi range: approximately 50-100 meters
   - Move closer to ESP32 controller
   - Remove obstacles (thick walls, metal objects)

4. **Restart ESP32:**
   - Unplug power cable
   - Wait 10 seconds
   - Plug back in
   - Wait 30 seconds
   - Look for SmartBell_AP again

5. **Check Device Compatibility:**
   - Some older phones don't see 2.4 GHz networks on certain channels
   - Try different phone if available

#### Problem: Connected to WiFi But App Won't Connect

**Symptoms:**
- Phone shows connected to SmartBell_AP
- App shows "Not Connected" or red indicator
- Settings → Test Connection fails

**Solutions:**

1. **Verify Correct Network:**
   - Open phone WiFi settings
   - Confirm connected to **SmartBell_AP** (not your regular WiFi)
   - Check password was entered correctly

2. **Check Server URL:**
   - Open Settings in app
   - Verify URL is: `http://192.168.4.1`
   - If different, update and tap "Update URL"

3. **Restart App:**
   - Close Smart Bell app completely
   - Wait 5 seconds
   - Reopen app

4. **Forget and Reconnect WiFi:**
   - Phone Settings → WiFi
   - Forget SmartBell_AP
   - Reconnect with password: smartbell123
   - Reopen app

5. **Restart Phone:**
   - Turn off phone completely
   - Turn back on
   - Reconnect to SmartBell_AP
   - Try app again

#### Problem: Connection Keeps Dropping

**Symptoms:**
- App connects, then disconnects repeatedly
- Red/green indicator keeps changing

**Solutions:**

1. **Check WiFi Signal Strength:**
   - Move closer to ESP32
   - WiFi signal may be weak
   - Consider relocating ESP32 to central location

2. **Check for Interference:**
   - Other WiFi networks on same channel
   - Microwave ovens, Bluetooth devices
   - Try using system in different location

3. **Check ESP32 Power Supply:**
   - Weak power supply causes instability
   - Use recommended 5V, 2A adapter
   - Try different power source

4. **Reduce Connected Devices:**
   - ESP32 supports 4-8 simultaneous connections
   - Disconnect other phones if multiple users

---

### Schedule Issues

#### Problem: Bell Not Ringing at Scheduled Time

**Symptoms:**
- Schedule exists and is enabled
- Time passes but bell doesn't ring
- Manual bell works fine

**Solutions:**

1. **Check Time Accuracy:**
   - Home → Check current time display
   - Compare with your phone/clock
   - If wrong: Settings → Sync Time to ESP32

2. **Verify Schedule Settings:**
   - Schedules → Find the schedule
   - Check:
     - ✅ Toggle is **enabled** (green)
     - ✅ Day of week is correct (Monday = 1, etc.)
     - ✅ Time is in 24-hour format (13:00 = 1 PM)
     - ✅ Not a past time

3. **Check Day of Week:**
   - Common mistake: Wrong day number
   - Sunday = 0, Monday = 1, Tuesday = 2, etc.
   - Edit schedule and verify correct day

4. **Time Format:**
   - Use 24-hour format
   - 8:00 AM = 08:00
   - 3:00 PM = 15:00
   - Not 3:00 (which is 3 AM!)

5. **Wait for Next Minute:**
   - Schedules check every minute
   - If current time is 12:30:45 and schedule is 12:30
   - Wait until 12:31:00 and re-add schedule for 12:31 to test

#### Problem: Bell Rings at Wrong Time

**Symptoms:**
- Bell rings but at incorrect time
- Consistent offset (e.g., 5 minutes early)

**Solutions:**

1. **Time Sync Issue:**
   - Settings → Check ESP32 time
   - If wrong: Sync Time to ESP32
   - Verify time after sync

2. **Timezone Confusion:**
   - App uses phone's timezone
   - Ensure phone timezone is correct
   - Phone Settings → Date & Time → Set timezone

3. **Schedule Hour/Minute Wrong:**
   - Schedules → Edit the schedule
   - Double-check hour and minute values
   - Save changes

4. **RTC Battery Low:**
   - If time drifts constantly
   - RTC battery (CR2032) may need replacement
   - Contact technical staff

#### Problem: Bell Rings Continuously

**Symptoms:**
- Bell won't stop ringing
- Rings longer than duration setting

**Solutions:**

1. **Emergency Stop:**
   - Open app immediately
   - Disconnect from SmartBell_AP WiFi
   - OR unplug ESP32 power

2. **Software Issue:**
   - After stopping, restart ESP32
   - If problem persists: Firmware may need reflashing
   - Contact technical support

3. **Hardware Issue:**
   - Relay may be stuck
   - Requires physical inspection
   - Unplug power and contact technical staff

#### Problem: Duplicate Schedules Ringing

**Symptoms:**
- Bell rings twice at same time
- Multiple bells for one schedule

**Solutions:**

1. **Check for Duplicate Schedules:**
   - Schedules → Review all entries
   - Look for identical time/day combinations
   - Delete duplicates

2. **Multiple Days:**
   - Verify you didn't create same schedule for multiple days
   - Use edit to modify or delete as needed

---

### App Issues

#### Problem: App Won't Open or Crashes

**Solutions:**

1. **Restart Phone:**
   - Simple restart often fixes app crashes

2. **Clear App Cache:**
   - Phone Settings → Apps → Smart Bell
   - Tap "Clear Cache" (not "Clear Data")

3. **Reinstall App:**
   - Uninstall Smart Bell app
   - Reinstall from APK file
   - Note: Schedules are stored on ESP32, not app

4. **Check Android Version:**
   - App requires Android 5.0 or higher
   - Settings → About Phone → Android version

#### Problem: Can't Add More Schedules

**Symptoms:**
- "Maximum schedules reached" error
- Plus button doesn't work

**Solutions:**

1. **Check Schedule Count:**
   - Maximum: 20 schedules total
   - Schedules → Count your entries

2. **Delete Unused Schedules:**
   - Remove old or unused schedules
   - Or use toggle to disable instead

3. **Consolidate Schedules:**
   - Combine similar schedules if possible
   - Example: Same time every weekday

#### Problem: Changes Not Saving

**Symptoms:**
- Edit schedule, but changes don't stick
- New schedules disappear after adding

**Solutions:**

1. **Check Connection:**
   - Settings → Test Connection
   - Must be connected to save changes

2. **Wait for Save:**
   - Don't close app immediately after saving
   - Wait for "Success" message

3. **Verify by Refreshing:**
   - Close and reopen Schedules tab
   - Changes should persist

4. **ESP32 Storage Full:**
   - Unlikely but possible
   - Try deleting some schedules first

---

### Hardware Issues

#### Problem: Bell Makes No Sound

**Symptoms:**
- App works fine
- Relay clicks but no bell sound

**Solutions:**

1. **Check Bell Power:**
   - Verify bell has power supply
   - Check bell power switch (if any)
   - Test bell directly with power supply

2. **Check Bell Connections:**
   - Verify wires are secure
   - Check relay terminal connections
   - Ensure no loose wires

3. **Test Relay:**
   - Listen for clicking sound when testing
   - If no click: Relay issue
   - If clicks but no bell: Wiring issue

4. **Bell Volume:**
   - Some bells have volume adjustment
   - Check if volume is turned down

5. **Call Technical Support:**
   - May require electrician
   - Especially if mains voltage involved

#### Problem: LED Not Working

**Symptoms:**
- Bell rings but LED doesn't light
- Not critical but indicates issue

**Solutions:**

1. **LED Direction:**
   - LEDs have polarity
   - May be installed backwards
   - Technical staff can check

2. **LED Burned Out:**
   - LEDs can fail
   - Easy replacement
   - Not essential for operation

3. **Resistor Issue:**
   - LED needs 330Ω resistor
   - May be missing or wrong value

**Note:** LED is for visual indication only. System works fine without it.

---

## Frequently Asked Questions

### General Questions

**Q: Does the system need internet to work?**

A: No! The Smart Bell system works completely offline. It creates its own WiFi network (SmartBell_AP) and doesn't need internet access.

**Q: How many schedules can I create?**

A: Maximum 20 schedules total. This includes schedules for all days of the week combined.

**Q: Can multiple people control the system at the same time?**

A: Yes, the ESP32 can handle 4-8 simultaneous phone connections. Multiple staff members can use the app at the same time.

**Q: What happens if there's a power outage?**

A: When power returns:
- ESP32 restarts automatically (takes 30 seconds)
- All schedules are preserved (stored in flash memory)
- Time is maintained by RTC battery (if installed)
- System resumes normal operation

**Q: How accurate is the timing?**

A: The DS3231 RTC is extremely accurate: ±1 minute per year at room temperature. In practice, bells ring within 1 second of scheduled time.

**Q: Can I use my regular school WiFi instead of SmartBell_AP?**

A: The system is designed to create its own network for simplicity and reliability. Using school WiFi would require firmware modifications and IT department approval.

### Technical Questions

**Q: What is the WiFi range?**

A: Approximately 50-100 meters in open space. Range is reduced by:
- Thick walls
- Metal objects
- Other WiFi networks
- Concrete construction

Consider the controller's location for best coverage.

**Q: Can I change the WiFi name and password?**

A: Yes, but requires reprogramming the ESP32 firmware. Contact your technical staff or see the technical manual (MANUAL.md).

**Q: How long do schedules stay in memory?**

A: Indefinitely. Schedules are stored in flash memory with 100,000+ write cycles and 20+ year data retention. They survive:
- Power outages
- ESP32 restarts
- Firmware updates (usually)

**Q: Can I backup my schedules?**

A: Currently, schedules are only stored on ESP32. Best practices:
- Take screenshots of all schedules
- Write them down
- Keep documentation up to date

Future versions may include export/import features.

**Q: What if I need more than 20 schedules?**

A: Options:
1. Use toggle to disable/enable schedules seasonally
2. Combine similar schedules
3. Upgrade firmware (requires technical expertise)

Most schools find 20 schedules sufficient for all needs.

**Q: Can the system control multiple bells?**

A: Current hardware controls one bell. To control multiple bells:
- Add additional relay modules
- Modify firmware (advanced)
- Or use multiple Smart Bell systems

### Troubleshooting Questions

**Q: Why does the time keep resetting?**

A: The RTC backup battery (CR2032) is dead or missing. This battery keeps time when ESP32 is unpowered. Replace battery:
- Open RTC module (if accessible)
- Remove old CR2032
- Insert new CR2032 (+ side up)
- Sync time after replacement

**Q: Bell rang at wrong time. Why?**

A: Common causes:
1. **Time not synced** - Settings → Sync Time
2. **Wrong day selected** - Check day of week (0=Sunday)
3. **24-hour format confusion** - 15:00 = 3 PM, not 3:00
4. **Phone timezone** - Ensure phone has correct timezone

**Q: App won't connect even though WiFi is connected. Help!**

A: Step-by-step fix:
1. Open phone WiFi settings
2. Verify connected to **SmartBell_AP** (not regular school WiFi)
3. Forget network and reconnect with password: smartbell123
4. Open app → Settings → Test Connection
5. If still failing: Restart ESP32 and phone

**Q: Can I use this with iOS?**

A: Yes, the app is built with Flutter which supports iOS. However:
- Requires macOS and Xcode to build
- Needs Apple Developer account for deployment
- Contact your IT department for iOS builds

**Q: What if I lose the phone with the app?**

A: No problem:
1. Install app on another phone
2. Connect to SmartBell_AP
3. All schedules are on ESP32, not phone
4. System continues working automatically

### Safety Questions

**Q: Is it safe for students to be near the controller?**

A: The ESP32 controller uses low voltage (5V) and is safe. However:
- Install in secure location away from students
- Use enclosure for physical protection
- Bell connections may involve higher voltage

**Q: What if there's a fire/emergency?**

A: Fire safety considerations:
- Manual bell override available in app
- Traditional manual bell as backup recommended
- Don't rely solely on automated system for emergency alerts
- Follow school emergency procedures

**Q: Can the system be hacked?**

A: Security considerations:
- Local network only (not exposed to internet)
- No sensitive data stored
- Simple password protection
- Physical security of device is primary concern
- For higher security, change default WiFi password

---

## Safety and Maintenance

### Safety Guidelines

#### Electrical Safety

⚠️ **Important Safety Rules:**

1. **Power Off First:**
   - Always disconnect power before making any changes
   - Unplug ESP32 from power source
   - Disconnect bell power supply

2. **Qualified Personnel:**
   - Electrical work should be done by qualified persons
   - If connecting to mains voltage (110V/220V), hire licensed electrician
   - School maintenance staff should handle hardware installation

3. **Use Proper Power Supplies:**
   - ESP32: 5V, 2A USB adapter (quality brand)
   - Bell: As per bell specifications
   - Don't use damaged cables or adapters

4. **Enclosure Required:**
   - House ESP32 and connections in proper enclosure
   - Prevents accidental contact
   - Protects from dust and moisture
   - Keep away from water sources

5. **Grounding:**
   - Ensure proper electrical grounding
   - Especially important if using high-voltage bells
   - Follow local electrical codes

#### User Safety

**For Teachers and Administrators:**

✅ **Do:**
- Use the app for all interactions
- Keep phone charged for manual bell access
- Report any unusual behavior immediately
- Keep backup manual bell method available

❌ **Don't:**
- Touch electrical components
- Open controller enclosure without authorization
- Modify hardware without technical staff
- Use near water or in wet conditions

**For Technical Staff:**

✅ **Do:**
- Follow all electrical safety procedures
- Use insulated tools
- Test with multimeter when troubleshooting
- Document all changes
- Wear appropriate safety equipment

❌ **Don't:**
- Work on live circuits
- Bypass safety features
- Use makeshift connections
- Ignore warning signs

### Regular Maintenance Schedule

#### Daily (2 minutes)

**By: Designated staff member (teacher/administrator)**

- ✅ Verify system powered on (quick visual check)
- ✅ Test manual bell function (if needed that day)
- ✅ Monitor first bell of day rings correctly

**Action if Issues:** Contact technical staff

---

#### Weekly (5 minutes)

**By: Designated staff member**

**Monday Morning:**
- ✅ Test bell using app (Settings → Ring Test Bell)
- ✅ Check time accuracy (Home screen vs. phone)
- ✅ Review week's schedule for special events
- ✅ Enable/disable schedules as needed for week

**Friday Afternoon:**
- ✅ Quick test to verify system ready for next week
- ✅ Report any issues to technical staff

**Checklist:**
```
□ System powered on
□ Test bell sounds clear
□ Time is accurate (within 1 minute)
□ Next week's schedules reviewed
□ Any issues reported
```

---

#### Monthly (15 minutes)

**By: Technical staff or designated administrator**

**First of Month Tasks:**

1. **Time Synchronization:**
   - Settings → Sync Time to ESP32
   - Even if time appears correct
   - Document sync date

2. **Schedule Review:**
   - Review all 20 schedules
   - Delete unused schedules
   - Verify all times correct
   - Update for upcoming events

3. **Physical Inspection:**
   - Check ESP32 for dust buildup
   - Verify LED indicator working
   - Check all cable connections secure
   - Ensure enclosure is closed properly

4. **Bell Testing:**
   - Test bell at various durations (3s, 5s, 10s)
   - Check volume is appropriate
   - Listen for any unusual sounds

5. **App Testing:**
   - Test all app functions
   - Verify WiFi connection stable
   - Check manual bell override works
   - Test schedule add/edit/delete

6. **Documentation:**
   - Update schedule log
   - Note any issues observed
   - Record next maintenance date

**Monthly Checklist:**
```
□ Time synced to ESP32
□ All schedules reviewed and accurate
□ Physical components inspected
□ Bell tested at multiple durations
□ App functions tested
□ Connections checked
□ Documentation updated
□ Issues logged
```

---

#### Quarterly (30 minutes)

**By: Technical staff**

**Every 3 Months:**

1. **Deep System Check:**
   - Review all system logs (if available)
   - Check ESP32 for overheating
   - Verify power supply voltage stable
   - Test WiFi signal strength at various distances

2. **Electrical Inspection:**
   - Check all wire connections
   - Look for signs of wear
   - Tighten screw terminals
   - Test relay operation

3. **RTC Battery Check:**
   - Measure CR2032 battery voltage (should be 3.0V+)
   - Replace if below 2.8V
   - Test time retention (power off, wait, check time)

4. **Backup and Documentation:**
   - Screenshot all schedules
   - Update printed documentation
   - Verify backup procedures
   - Review troubleshooting logs

5. **Performance Review:**
   - Review any missed bells
   - Check timing accuracy
   - User feedback collection
   - Identify improvements needed

**Quarterly Checklist:**
```
□ System logs reviewed
□ ESP32 temperature check
□ Power supply tested
□ WiFi signal strength verified
□ All connections inspected
□ Relay operation tested
□ RTC battery voltage checked
□ Schedules backed up
□ Documentation updated
□ Performance metrics reviewed
□ User feedback collected
```

---

#### Annually (1-2 hours)

**By: Technical staff or qualified electrician**

**Once Per Year (Summer Break Recommended):**

1. **Complete Hardware Inspection:**
   - Remove from enclosure
   - Visual inspection of all components
   - Check for corrosion, damage
   - Clean dust with compressed air
   - Verify no loose components

2. **Replace Consumables:**
   - Replace RTC CR2032 battery (even if still good)
   - Check all power adapters
   - Replace any damaged wires
   - Clean/replace enclosure if needed

3. **Comprehensive Testing:**
   - Test all 20 schedule slots
   - Extended duration tests
   - WiFi range testing
   - Stress test (multiple manual rings)
   - Verify backup time retention

4. **Software Check:**
   - Verify firmware version
   - Check for updates
   - Backup and restore test
   - App functionality complete test

5. **Bell Hardware:**
   - Inspect bell mechanism
   - Check bell volume/sound quality
   - Test bell power supply
   - Verify bell wiring secure

6. **Documentation and Training:**
   - Update all documentation
   - Train new staff on system
   - Review emergency procedures
   - Update contact information

7. **Planning:**
   - Review past year's issues
   - Plan improvements
   - Budget for replacements
   - Consider upgrades

**Annual Checklist:**
```
□ Complete hardware inspection
□ All consumables replaced
□ RTC battery replaced
□ Comprehensive testing completed
□ Bell hardware inspected
□ Firmware version checked
□ All wiring inspected and secure
□ Enclosure cleaned
□ Documentation fully updated
□ Staff training completed
□ Emergency procedures reviewed
□ Next year maintenance planned
□ Replacement parts budgeted
```

---

### Cleaning and Care

#### Cleaning the Controller

**Monthly:**
- Use compressed air to remove dust
- Don't use liquids on electronics
- Clean enclosure exterior with damp cloth
- Ensure ventilation holes are clear

**Never:**
- Spray water or cleaning solutions on electronics
- Use abrasive materials
- Clean while powered on
- Disassemble without proper training

#### Environmental Considerations

**Good Operating Conditions:**
- Temperature: 0°C to 40°C (32°F to 104°F)
- Humidity: 20% to 80% (non-condensing)
- Clean, dust-free environment
- Away from direct sunlight
- Good air circulation

**Avoid:**
- Extreme temperatures
- High humidity or moisture
- Direct sunlight
- Dusty or dirty environments
- Near heat sources

### Replacement Parts

#### Common Replacement Items

**Consumable Parts:**

1. **CR2032 Battery (RTC Backup)**
   - Replace annually
   - Cost: $1-2
   - Easy replacement

2. **Power Supply**
   - Replace if damaged or unstable
   - 5V, 2A USB adapter
   - Cost: $5-10

3. **Jumper Wires**
   - Replace if damaged
   - Keep spares on hand
   - Cost: $5 for set

**Component Replacements (Rare):**

4. **ESP32 Board**
   - If damaged or defective
   - Cost: $5-10
   - Requires firmware reflash

5. **DS3231 RTC Module**
   - If time keeping fails
   - Cost: $2-5
   - Includes new battery

6. **Relay Module**
   - If relay won't click or stuck
   - Cost: $2-3
   - Check ratings match

7. **LED Indicator**
   - If burned out
   - Cost: $0.10
   - Not critical for operation

**Keeping Spares:**

Recommended spare parts to keep on hand:
- ✅ CR2032 batteries (2-3)
- ✅ USB power cable
- ✅ Jumper wires set
- ⚠️ Complete ESP32 module (optional, for quick replacement)

### When to Call Technical Support

**Call Immediately For:**

🚨 **Safety Issues:**
- Burning smell
- Sparks or smoke
- Very hot components
- Exposed wires
- Water damage

🚨 **System Failures:**
- Complete system failure
- Continuous bell ringing that won't stop
- Firmware corruption
- Hardware damage

📞 **Call Within 24 Hours For:**
- Time constantly resetting
- Schedules not triggering reliably
- WiFi network not appearing
- Relay clicking but bell not working
- Any unexplained behavior

**Can Wait For Regular Maintenance:**
- LED not working (not critical)
- Minor time drift (< 5 minutes)
- App UI glitches (restart usually fixes)
- Cosmetic enclosure issues

### Emergency Backup Plan

**Always Have a Backup Plan:**

1. **Traditional Manual Bell:**
   - Keep manual bell accessible
   - Train staff on manual operation
   - Test regularly
   - Use during system maintenance

2. **Backup Phone:**
   - Install app on 2-3 phones
   - Keep one fully charged in office
   - Train multiple staff members

3. **Printed Schedule:**
   - Keep current printed schedule
   - Update when making changes
   - Post in main office
   - Use for manual bell if system fails

4. **Emergency Contacts:**
   - Technical support phone number
   - School IT department
   - Electrician contact
   - Vendor/supplier contact

**Emergency Contact Sheet Template:**
```
SMART BELL SYSTEM - EMERGENCY CONTACTS

Technical Support: ___________________
School IT: ___________________________
Electrician: _________________________
Vendor: ______________________________

Backup Manual Bell Location: _________
App Installed On Phones:
1. _________________________________
2. _________________________________
3. _________________________________

Last Maintenance Date: _______________
Next Scheduled Maintenance: __________
```

---

## Support and Contact

### Getting Help

#### Before Contacting Support

**Try These Steps First:**

1. ✅ Check this manual's Troubleshooting section
2. ✅ Restart the app
3. ✅ Restart ESP32 (unplug/replug)
4. ✅ Verify WiFi connection
5. ✅ Check Settings → Test Connection

Many issues can be resolved quickly with basic troubleshooting.

#### How to Report Issues

**When Contacting Support, Include:**

1. **System Information:**
   - When system was installed
   - Last successful operation
   - Recent changes made

2. **Problem Description:**
   - What isn't working
   - When it started
   - What you've tried

3. **Error Messages:**
   - Exact text of any error messages
   - Screenshots if possible

4. **Current Status:**
   - Is ESP32 powered on?
   - Can you connect to WiFi?
   - Does manual bell work?

### Support Resources

#### Documentation

- **This User Manual** - For daily operation
- **MANUAL.md** - Detailed technical manual (esp32_firmware/MANUAL.md)
- **README.md** - Project overview and quick reference
- **PROJECT_DOCUMENTATION.md** - Academic and technical details

#### Online Resources

- Project repository: [Contact administrator for link]
- Technical documentation: See MANUAL.md in esp32_firmware folder
- Community forum: [If applicable]

### Contacting Technical Support

**Technical Support Contact Information:**

```
Smart Bell System Support
━━━━━━━━━━━━━━━━━━━━━━━━━━

School IT Department:
Phone: _______________________
Email: _______________________
Hours: ________________________

Technical Vendor:
Phone: _______________________
Email: _______________________
Support Hours: ________________

Emergency Contact (After Hours):
Phone: _______________________

Response Time:
- Critical Issues: Within 4 hours
- Normal Issues: Within 24 hours
- Questions: Within 48 hours
```

### Feedback and Suggestions

We value your feedback! Please share:

- Feature requests
- Usability improvements
- Documentation suggestions
- Bug reports
- Success stories

**How to Provide Feedback:**
- Email: [Contact administrator]
- Feedback form: [If applicable]
- In person: [IT department contact]

---

## Appendix

### Quick Reference Card

**Print this page and keep near your desk!**

```
╔═══════════════════════════════════════════════════════╗
║         SMART BELL - QUICK REFERENCE CARD             ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║  WiFi Connection:                                     ║
║  • Network: SmartBell_AP                             ║
║  • Password: smartbell123                            ║
║                                                       ║
║  Manual Bell (Emergency):                             ║
║  1. Open app                                          ║
║  2. Home tab                                          ║
║  3. Tap "Ring Bell Now"                              ║
║                                                       ║
║  Add Schedule:                                        ║
║  1. Schedules tab                                     ║
║  2. Tap + button                                      ║
║  3. Fill in details                                   ║
║  4. Save                                              ║
║                                                       ║
║  Sync Time:                                           ║
║  1. Settings tab                                      ║
║  2. Tap "Sync Time to ESP32"                         ║
║  3. Confirm success                                   ║
║                                                       ║
║  Emergency Restart:                                   ║
║  • Unplug ESP32 power                                ║
║  • Wait 10 seconds                                    ║
║  • Plug back in                                       ║
║  • Wait 30 seconds                                    ║
║                                                       ║
║  Day of Week Numbers:                                 ║
║  • Sunday = 0    • Wednesday = 3    • Saturday = 6   ║
║  • Monday = 1    • Thursday = 4                       ║
║  • Tuesday = 2   • Friday = 5                         ║
║                                                       ║
║  Time Format:                                         ║
║  • 24-hour format: 08:00 = 8 AM, 15:00 = 3 PM       ║
║                                                       ║
║  Support Contact:                                     ║
║  • Phone: ___________________                         ║
║  • Email: ___________________                         ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
```

### Schedule Planning Template

**Use this template to plan your schedules before entering them in the app:**

```
SCHOOL BELL SCHEDULE PLANNING SHEET

School: _________________________  Date: ____________

MONDAY (Day 1)
┌──────┬─────────────────────┬──────────┬───────────┐
│ Time │ Label               │ Duration │ Enabled   │
├──────┼─────────────────────┼──────────┼───────────┤
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
└──────┴─────────────────────┴──────────┴───────────┘

TUESDAY (Day 2)
┌──────┬─────────────────────┬──────────┬───────────┐
│ Time │ Label               │ Duration │ Enabled   │
├──────┼─────────────────────┼──────────┼───────────┤
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
│      │                     │          │ □ Yes     │
└──────┴─────────────────────┴──────────┴───────────┘

[Continue for other days...]

Total Schedules: _____ / 20 maximum

Notes:
_________________________________________________
_________________________________________________
_________________________________________________

Reviewed by: ________________  Date: ___________
Entered by: _________________  Date: ___________
```

### Glossary of Terms

**Technical Terms Explained:**

- **Access Point (AP)**: A device that creates a WiFi network. The ESP32 operates as an AP.

- **API (Application Programming Interface)**: The way the app communicates with the ESP32 controller.

- **CR2032**: A coin cell battery (3V) used for RTC backup power.

- **DS3231**: The Real-Time Clock chip that keeps accurate time.

- **Duration**: How long the bell rings, measured in seconds.

- **ESP32**: The microcontroller (small computer) that controls the bell system.

- **Flash Memory**: Permanent storage on ESP32 that keeps schedules even when powered off.

- **Firmware**: The software program running on the ESP32.

- **GPIO**: General Purpose Input/Output - pins on ESP32 that connect to hardware.

- **I2C**: A communication method used between ESP32 and RTC.

- **LED**: Light Emitting Diode - the indicator light.

- **Relay**: An electronic switch that controls the bell's power.

- **REST API**: A standard way for the app to communicate with ESP32 using HTTP.

- **RTC (Real-Time Clock)**: A chip that keeps track of time, even when main power is off.

- **Schedule**: A programmed time when the bell should ring automatically.

- **SSID**: The name of a WiFi network (SmartBell_AP).

- **Toggle**: A switch that turns something on or off without deleting it.

- **24-Hour Format**: Time notation where 15:00 = 3:00 PM.

### Time Format Conversion Chart

**Converting 12-hour to 24-hour format:**

```
12-Hour (AM/PM)  →  24-Hour Format
─────────────────────────────────────
12:00 AM (midnight) →  00:00
01:00 AM            →  01:00
02:00 AM            →  02:00
...
11:00 AM            →  11:00
12:00 PM (noon)     →  12:00
01:00 PM            →  13:00
02:00 PM            →  14:00
03:00 PM            →  15:00
04:00 PM            →  16:00
05:00 PM            →  17:00
06:00 PM            →  18:00
07:00 PM            →  19:00
08:00 PM            →  20:00
09:00 PM            →  21:00
10:00 PM            →  22:00
11:00 PM            →  23:00
```

**Quick Conversion:**
- AM times: Use as-is (but 12:xx AM = 00:xx)
- PM times: Add 12 (but 12:xx PM stays 12:xx)

**Examples:**
- 8:30 AM → 08:30
- 3:45 PM → 15:45 (3 + 12 = 15)
- 12:15 PM → 12:15 (noon stays 12)

### Day of Week Reference

```
Smart Bell uses numbers for days of the week:

┌────────┬────────────┐
│ Number │    Day     │
├────────┼────────────┤
│   0    │  Sunday    │
│   1    │  Monday    │
│   2    │  Tuesday   │
│   3    │  Wednesday │
│   4    │  Thursday  │
│   5    │  Friday    │
│   6    │  Saturday  │
└────────┴────────────┘

⚠️ Common Mistake:
Don't confuse Monday (1) with Sunday (0)!

✅ Monday = 1 (most schools start week here)
❌ Monday ≠ 0 (that's Sunday!)
```

---

## Conclusion

Thank you for choosing the Smart Bell Automation System! We hope this manual helps you get the most out of your automated bell system.

### Remember:

- 📱 Keep the app installed on multiple devices
- 🔔 Test the system weekly
- ⏰ Sync time monthly
- 📋 Keep printed schedule backup
- 🔧 Perform regular maintenance
- 📞 Contact support when needed

### Success Tips:

1. **Start Simple**: Begin with a few schedules and add more as you get comfortable
2. **Document Changes**: Keep a log of schedule modifications
3. **Train Staff**: Ensure multiple people know how to use the system
4. **Plan Ahead**: Update schedules before holidays and special events
5. **Stay Connected**: Keep at least one phone connected during school hours

### We're Here to Help!

If you have any questions, encounter issues, or need assistance, don't hesitate to reach out to technical support. We want your Smart Bell system to work perfectly for your school.

**Happy Automated Bell Ringing! 🔔**

---

*Smart Bell Automation System - User Manual Version 1.0*
*Last Updated: November 2025*
*Document Status: Complete User Guide for Non-Technical Users*

---

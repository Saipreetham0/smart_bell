#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <RTClib.h>

// Pin Definitions
#define RELAY_PIN 27
#define LED_PIN 15
#define SQW_PIN 4  // DS3231 Square Wave output (optional)
#define SDA_PIN 21 // DS3231 I2C Data
#define SCL_PIN 22 // DS3231 I2C Clock

// WiFi AP Configuration
const char* AP_SSID = "SmartBell_AP";
const char* AP_PASSWORD = NULL;  // Open network (no password)

// Objects
WebServer server(80);
Preferences preferences;
RTC_DS3231 rtc;

// Schedule Structure
struct Schedule {
  int id;
  int hour;
  int minute;
  int duration;
  int dayOfWeek;  // 0=Sunday, 1=Monday, etc.
  char label[50];
  bool enabled;
  int mode;  // 1=Regular, 2=Mids, 3=Semester
};

// Global Variables
Schedule schedules[100];  // Increased to 100 schedules (supports ~33 per mode)
int scheduleCount = 0;
int activeMode = 1;  // Current active mode: 1=Regular, 2=Mids, 3=Semester
unsigned long bellStartTime = 0;
bool bellRinging = false;
int bellDuration = 0;
bool rtcAvailable = false;

// Function Declarations
void setupWiFiAP();
void setupRTC();
void loadSchedules();
void saveSchedules();
void checkSchedules();
void ringBell(int duration);
void stopBell();
void handleGetSchedules();
void handleAddSchedule();
void handleUpdateSchedule();
void handleDeleteSchedule();
void handleRingNow();
void handleTimeSync();
void handleGetTime();
void handleSetMode();
void handleGetMode();

void setup() {
  Serial.begin(115200);

  // Initialize pins FIRST before any digitalWrite calls
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(SQW_PIN, INPUT_PULLUP);  // Optional: for RTC square wave

  // Now set relay and LED LOW to ensure they start OFF
  digitalWrite(RELAY_PIN, LOW);
  digitalWrite(LED_PIN, LOW);

  delay(1000);

  // Initialize I2C for RTC
  Wire.begin(SDA_PIN, SCL_PIN);

  // Initialize RTC
  setupRTC();

  // Initialize WiFi AP
  setupWiFiAP();

  // Load schedules from flash
  loadSchedules();

  // Setup web server routes
  server.on("/get_schedules", HTTP_GET, handleGetSchedules);
  server.on("/add_schedule", HTTP_POST, handleAddSchedule);
  server.on("/update_schedule", HTTP_POST, handleUpdateSchedule);
  server.on("/delete_schedule", HTTP_POST, handleDeleteSchedule);
  server.on("/ring_now", HTTP_POST, handleRingNow);
  server.on("/time_sync", HTTP_POST, handleTimeSync);
  server.on("/get_time", HTTP_GET, handleGetTime);
  server.on("/set_mode", HTTP_POST, handleSetMode);
  server.on("/get_mode", HTTP_GET, handleGetMode);

  // Enable CORS
  server.enableCORS(true);

  server.begin();
  Serial.println("HTTP server started on port 80");
  Serial.println("Smart Bell System Ready!");
  Serial.println("========================================");
}

void loop() {
  server.handleClient();
  checkSchedules();

  // Handle bell duration
  if (bellRinging && (millis() - bellStartTime >= bellDuration * 1000)) {
    stopBell();
  }
}

void setupWiFiAP() {
  WiFi.mode(WIFI_AP);

  // Create open network (no password)
  if (AP_PASSWORD == NULL || strlen(AP_PASSWORD) == 0) {
    WiFi.softAP(AP_SSID);
    Serial.println("WiFi AP started (Open Network - No Password)");
  } else {
    WiFi.softAP(AP_SSID, AP_PASSWORD);
    Serial.println("WiFi AP started (Password Protected)");
  }

  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);
}

void setupRTC() {
  Serial.println("Initializing DS3231 RTC...");

  // rtc.begin() will use the existing Wire instance initialized in setup()
  if (!rtc.begin(&Wire)) {
    Serial.println("ERROR: Couldn't find DS3231 RTC! Please check wiring.");
    rtcAvailable = false;
    return;
  }

  rtcAvailable = true;
  Serial.println("DS3231 RTC initialized!");

  // Check if RTC lost power and time is invalid
  if (rtc.lostPower()) {
    Serial.println("RTC lost power - setting default time. Please sync via app.");
    // Set to a default time (will be synced from app)
    rtc.adjust(DateTime(2024, 1, 1, 0, 0, 0));
  }

  // Print current RTC time
  DateTime now = rtc.now();
  Serial.printf("RTC Time: %d-%02d-%02d %02d:%02d:%02d\n",
                now.year(), now.month(), now.day(),
                now.hour(), now.minute(), now.second());
}

void loadSchedules() {
  preferences.begin("schedules", false);
  scheduleCount = preferences.getInt("count", 0);
  activeMode = preferences.getInt("activeMode", 1);  // Load active mode, default to Regular

  for (int i = 0; i < scheduleCount; i++) {
    String key = "sch_" + String(i);
    size_t schLen = preferences.getBytesLength(key.c_str());
    if (schLen > 0) {
      preferences.getBytes(key.c_str(), &schedules[i], sizeof(Schedule));
    }
  }

  preferences.end();
  Serial.printf("Loaded %d schedules (Active Mode: %d)\n", scheduleCount, activeMode);
}

void saveSchedules() {
  preferences.begin("schedules", false);
  preferences.putInt("count", scheduleCount);

  for (int i = 0; i < scheduleCount; i++) {
    String key = "sch_" + String(i);
    preferences.putBytes(key.c_str(), &schedules[i], sizeof(Schedule));
  }

  preferences.end();
  Serial.printf("Saved %d schedules\n", scheduleCount);
}

void checkSchedules() {
  if (!rtcAvailable) {
    return;  // Cannot check schedules without RTC
  }

  static int lastMinute = -1;
  DateTime now = rtc.now();

  // Only check once per minute
  if (now.minute() == lastMinute) {
    return;
  }
  lastMinute = now.minute();

  int currentHour = now.hour();
  int currentMinute = now.minute();
  int currentDayOfWeek = now.dayOfTheWeek();  // 0=Sunday, 1=Monday, etc.

  for (int i = 0; i < scheduleCount; i++) {
    // Check if schedule matches current time, day, and active mode
    if (schedules[i].enabled &&
        schedules[i].mode == activeMode &&  // Only trigger schedules matching active mode
        schedules[i].hour == currentHour &&
        schedules[i].minute == currentMinute &&
        schedules[i].dayOfWeek == currentDayOfWeek) {

      ringBell(schedules[i].duration);
      Serial.printf("Schedule triggered: %s (Mode %d) at %02d:%02d\n",
                    schedules[i].label, schedules[i].mode, currentHour, currentMinute);
      break;
    }
  }
}

void ringBell(int duration) {
  if (!bellRinging) {
    digitalWrite(RELAY_PIN, HIGH);
    digitalWrite(LED_PIN, HIGH);
    bellRinging = true;
    bellStartTime = millis();
    bellDuration = duration;
    Serial.printf("Bell ringing for %d seconds\n", duration);
  }
}

void stopBell() {
  digitalWrite(RELAY_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  bellRinging = false;
  Serial.println("Bell stopped");
}

void handleGetSchedules() {
  DynamicJsonDocument doc(4096);
  JsonArray array = doc.to<JsonArray>();

  for (int i = 0; i < scheduleCount; i++) {
    JsonObject obj = array.createNestedObject();
    obj["id"] = schedules[i].id;
    obj["hour"] = schedules[i].hour;
    obj["minute"] = schedules[i].minute;
    obj["duration"] = schedules[i].duration;
    obj["dayOfWeek"] = schedules[i].dayOfWeek;
    obj["label"] = schedules[i].label;
    obj["enabled"] = schedules[i].enabled;
    obj["mode"] = schedules[i].mode;
  }

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleAddSchedule() {
  if (scheduleCount >= 100) {
    server.send(400, "application/json", "{\"error\":\"Maximum schedules reached (100)\"}");
    return;
  }

  DynamicJsonDocument doc(1024);
  deserializeJson(doc, server.arg("plain"));

  Schedule newSchedule;
  newSchedule.id = scheduleCount > 0 ? schedules[scheduleCount - 1].id + 1 : 1;
  newSchedule.hour = doc["hour"];
  newSchedule.minute = doc["minute"];
  newSchedule.duration = doc["duration"];
  newSchedule.dayOfWeek = doc["dayOfWeek"];
  strncpy(newSchedule.label, doc["label"] | "Bell", 49);
  newSchedule.label[49] = '\0';
  newSchedule.enabled = doc["enabled"] | true;
  newSchedule.mode = doc["mode"] | 1;  // Default to Regular mode

  schedules[scheduleCount] = newSchedule;
  scheduleCount++;

  saveSchedules();

  DynamicJsonDocument response(256);
  response["success"] = true;
  response["id"] = newSchedule.id;

  String responseStr;
  serializeJson(response, responseStr);
  server.send(200, "application/json", responseStr);
}

void handleUpdateSchedule() {
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, server.arg("plain"));

  int id = doc["id"];
  bool found = false;

  for (int i = 0; i < scheduleCount; i++) {
    if (schedules[i].id == id) {
      // Update the schedule
      schedules[i].hour = doc["hour"];
      schedules[i].minute = doc["minute"];
      schedules[i].duration = doc["duration"];
      schedules[i].dayOfWeek = doc["dayOfWeek"];
      strncpy(schedules[i].label, doc["label"] | "Bell", 49);
      schedules[i].label[49] = '\0';
      schedules[i].enabled = doc["enabled"] | true;
      schedules[i].mode = doc["mode"] | 1;
      found = true;
      break;
    }
  }

  if (found) {
    saveSchedules();
    server.send(200, "application/json", "{\"success\":true}");
  } else {
    server.send(404, "application/json", "{\"error\":\"Schedule not found\"}");
  }
}

void handleDeleteSchedule() {
  DynamicJsonDocument doc(256);
  deserializeJson(doc, server.arg("plain"));

  int id = doc["id"];
  bool found = false;

  for (int i = 0; i < scheduleCount; i++) {
    if (schedules[i].id == id) {
      // Shift remaining schedules
      for (int j = i; j < scheduleCount - 1; j++) {
        schedules[j] = schedules[j + 1];
      }
      scheduleCount--;
      found = true;
      break;
    }
  }

  if (found) {
    saveSchedules();
    server.send(200, "application/json", "{\"success\":true}");
  } else {
    server.send(404, "application/json", "{\"error\":\"Schedule not found\"}");
  }
}

void handleRingNow() {
  DynamicJsonDocument doc(256);
  deserializeJson(doc, server.arg("plain"));

  int duration = doc["duration"] | 5;
  ringBell(duration);

  server.send(200, "application/json", "{\"success\":true}");
}

void handleTimeSync() {
  if (!rtcAvailable) {
    server.send(500, "application/json", "{\"error\":\"RTC not available\"}");
    return;
  }

  DynamicJsonDocument doc(512);
  deserializeJson(doc, server.arg("plain"));

  int year = doc["year"];
  int month = doc["month"];
  int day = doc["day"];
  int hour = doc["hour"];
  int minute = doc["minute"];
  int second = doc["second"];

  // Set RTC time
  rtc.adjust(DateTime(year, month, day, hour, minute, second));

  Serial.printf("RTC time synced to: %d-%02d-%02d %02d:%02d:%02d\n",
                year, month, day, hour, minute, second);

  server.send(200, "application/json", "{\"success\":true}");
}

void handleGetTime() {
  if (!rtcAvailable) {
    server.send(500, "application/json", "{\"error\":\"RTC not available\"}");
    return;
  }

  DateTime now = rtc.now();

  DynamicJsonDocument doc(256);
  doc["year"] = now.year();
  doc["month"] = now.month();
  doc["day"] = now.day();
  doc["hour"] = now.hour();
  doc["minute"] = now.minute();
  doc["second"] = now.second();
  doc["dayOfWeek"] = now.dayOfTheWeek();

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleSetMode() {
  DynamicJsonDocument doc(256);
  deserializeJson(doc, server.arg("plain"));

  int newMode = doc["mode"] | 1;

  // Validate mode (1=Regular, 2=Mids, 3=Semester)
  if (newMode < 1 || newMode > 3) {
    server.send(400, "application/json", "{\"error\":\"Invalid mode. Must be 1, 2, or 3\"}");
    return;
  }

  activeMode = newMode;

  // Save active mode to preferences
  preferences.begin("schedules", false);
  preferences.putInt("activeMode", activeMode);
  preferences.end();

  const char* modeNames[] = {"Unknown", "Regular", "Mids", "Semester"};
  Serial.printf("Active mode changed to: %d (%s)\n", activeMode, modeNames[activeMode]);

  DynamicJsonDocument response(256);
  response["success"] = true;
  response["mode"] = activeMode;
  response["modeName"] = modeNames[activeMode];

  String responseStr;
  serializeJson(response, responseStr);
  server.send(200, "application/json", responseStr);
}

void handleGetMode() {
  const char* modeNames[] = {"Unknown", "Regular", "Mids", "Semester"};

  DynamicJsonDocument doc(256);
  doc["mode"] = activeMode;
  doc["modeName"] = modeNames[activeMode];

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

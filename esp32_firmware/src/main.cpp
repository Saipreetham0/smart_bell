#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <Wire.h>
#include <RTClib.h>
#include <ArduinoJson.h>

// Pin Definitions
#define RELAY_PIN 25
#define LED_PIN 2
#define MANUAL_BUTTON_PIN 34
#define SDA_PIN 21
#define SCL_PIN 22

// WiFi AP Configuration
const char* AP_SSID = "SmartBell_AP";
const char* AP_PASSWORD = "smartbell123";

// Objects
RTC_DS3231 rtc;
WebServer server(80);
Preferences preferences;

// Schedule Structure
struct Schedule {
  int id;
  int hour;
  int minute;
  int duration;
  int dayOfWeek;  // 0=Sunday, 1=Monday, etc.
  char label[50];
  bool enabled;
};

// Global Variables
Schedule schedules[20];
int scheduleCount = 0;
unsigned long bellStartTime = 0;
bool bellRinging = false;
int bellDuration = 0;
bool manualButtonPressed = false;
unsigned long lastButtonCheck = 0;

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
void handleDeleteSchedule();
void handleRingNow();
void handleTimeSync();
void handleGetTime();
void checkManualButton();

void setup() {
  Serial.begin(115200);

  // Initialize pins
  pinMode(RELAY_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);
  pinMode(MANUAL_BUTTON_PIN, INPUT_PULLUP);
  digitalWrite(RELAY_PIN, LOW);
  digitalWrite(LED_PIN, LOW);

  // Initialize I2C
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
  server.on("/delete_schedule", HTTP_POST, handleDeleteSchedule);
  server.on("/ring_now", HTTP_POST, handleRingNow);
  server.on("/time_sync", HTTP_POST, handleTimeSync);
  server.on("/get_time", HTTP_GET, handleGetTime);

  // Enable CORS
  server.enableCORS(true);

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  server.handleClient();
  checkSchedules();
  checkManualButton();

  // Handle bell duration
  if (bellRinging && (millis() - bellStartTime >= bellDuration * 1000)) {
    stopBell();
  }
}

void setupWiFiAP() {
  WiFi.mode(WIFI_AP);
  WiFi.softAP(AP_SSID, AP_PASSWORD);

  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);
}

void setupRTC() {
  if (!rtc.begin()) {
    Serial.println("Couldn't find RTC");
    while (1);
  }

  if (rtc.lostPower()) {
    Serial.println("RTC lost power, setting default time");
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  }
}

void loadSchedules() {
  preferences.begin("schedules", false);
  scheduleCount = preferences.getInt("count", 0);

  for (int i = 0; i < scheduleCount; i++) {
    String key = "sch_" + String(i);
    size_t schLen = preferences.getBytesLength(key.c_str());
    if (schLen > 0) {
      preferences.getBytes(key.c_str(), &schedules[i], sizeof(Schedule));
    }
  }

  preferences.end();
  Serial.printf("Loaded %d schedules\n", scheduleCount);
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
  DateTime now = rtc.now();
  int currentHour = now.hour();
  int currentMinute = now.minute();
  int currentSecond = now.second();
  int currentDayOfWeek = now.dayOfTheWeek();

  // Only check at the start of each minute
  if (currentSecond != 0) return;

  for (int i = 0; i < scheduleCount; i++) {
    if (schedules[i].enabled &&
        schedules[i].hour == currentHour &&
        schedules[i].minute == currentMinute &&
        schedules[i].dayOfWeek == currentDayOfWeek) {

      ringBell(schedules[i].duration);
      Serial.printf("Schedule triggered: %s\n", schedules[i].label);
      break;
    }
  }
}

void checkManualButton() {
  if (millis() - lastButtonCheck < 200) return;
  lastButtonCheck = millis();

  if (digitalRead(MANUAL_BUTTON_PIN) == LOW && !manualButtonPressed) {
    manualButtonPressed = true;
    ringBell(5);  // Ring for 5 seconds on manual press
    Serial.println("Manual button pressed");
  } else if (digitalRead(MANUAL_BUTTON_PIN) == HIGH) {
    manualButtonPressed = false;
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
  }

  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleAddSchedule() {
  if (scheduleCount >= 20) {
    server.send(400, "application/json", "{\"error\":\"Maximum schedules reached\"}");
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
  DynamicJsonDocument doc(512);
  deserializeJson(doc, server.arg("plain"));

  int year = doc["year"];
  int month = doc["month"];
  int day = doc["day"];
  int hour = doc["hour"];
  int minute = doc["minute"];
  int second = doc["second"];

  rtc.adjust(DateTime(year, month, day, hour, minute, second));

  Serial.printf("RTC synced to: %d-%02d-%02d %02d:%02d:%02d\n",
                year, month, day, hour, minute, second);

  server.send(200, "application/json", "{\"success\":true}");
}

void handleGetTime() {
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

#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <time.h>
#include <vector>
#include <ArduinoJson.h>
#include <FastLED.h>

// server
#include <credentials.h>
const String SERVER_URL = "";

// LEDs
#define NUM_LEDS 12
#define DATA_PIN 32
#define BRIGHTNESS 50
uint8_t max_bright = BRIGHTNESS;
CRGB leds[NUM_LEDS];

void alarmFlashes(void *arg)
{
  for (int a = 0; a < 10; a++)
  {
    for (int r = 0; r < 4; r++)
    {
      for (int i = 0; i < NUM_LEDS; i++)
      {
        leds[i] = CRGB::White;
      }
      FastLED.show();
      delay(20);
      for (int i = 0; i < NUM_LEDS; i++)
      {
        leds[i] = CRGB::Black;
      }
      FastLED.show();
      delay(100);
    }
    for (int i = 255; i >= 0; i--)
    {
      for (int j = 0; j < NUM_LEDS; j++)
      {
        leds[j] = CRGB(i, i, i);
      }
      FastLED.show();
      delay(2);
    }
  }
  vTaskDelete(NULL);
}

typedef struct
{
  long value;
} alarm_data_t;

String getAlarms()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String serverPath = SERVER_URL + "/alarms";
    http.begin(serverPath.c_str());
    http.addHeader("Authorization", SERVER_PASS);
    int responseCode = http.GET();

    if (responseCode == 200)
    {
      String payload = http.getString();
      return payload;
    }
    Serial.print("Error code: " + responseCode);
    http.end();
  }
  else
    Serial.println("Could not connect to WiFi");
  return "";
}

JsonDocument loadAlarms()
{
  String alarmJSON = getAlarms();
  JsonDocument doc;
  deserializeJson(doc, alarmJSON);
  return doc;
}

void runAlarmStandard(void *pvParameters)
{
  alarm_data_t *data = (alarm_data_t *)pvParameters;
  long value = data->value;
  Serial.print("RUNNING ALARM in ");
  Serial.println(value);
  delay(value);
  Serial.println("\nALARM ALARM ALARM");
  xTaskCreate(alarmFlashes, "", 2048, NULL, 2, NULL);
  vTaskDelete(NULL);
}

void pulseLEDs(void *arg)
{
  for (int i = 0; i < NUM_LEDS; i++)
  {
    leds[i] = CRGB::White;
  }
  FastLED.show();
  delay(500);
  for (int i = 255; i >= 0; i--)
  {
    for (int j = 0; j < NUM_LEDS; j++)
    {
      leds[j] = CRGB(i, i, i);
    }
    FastLED.show();
    delay(2);
  }
  vTaskDelete(NULL);
}

void initLEDs()
{
  FastLED.addLeds<WS2812B, DATA_PIN, GRB>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(max_bright);
  set_max_power_in_volts_and_milliamps(5, 8000);

  FastLED.clear();
  FastLED.show();
}

bool shouldUpdate()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String serverPath = SERVER_URL + "/should-update";
    http.begin(serverPath.c_str());
    http.addHeader("Authorization", SERVER_PASS);
    int responseCode = http.GET();

    if (responseCode == 200)
    {
      String payload = http.getString();
      return payload == "true";
    }
    Serial.print("Error code: " + responseCode);
    http.end();
  }
  else
    Serial.println("Could not connect to WiFi");
  return false;
}

bool shouldPulse()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String serverPath = SERVER_URL + "/should-pulse";
    http.begin(serverPath.c_str());
    http.addHeader("Authorization", SERVER_PASS);
    int responseCode = http.GET();

    if (responseCode == 200)
    {
      String payload = http.getString();
      return payload == "true";
    }
    Serial.print("Error code: " + responseCode);
    http.end();
  }
  else
    Serial.println("Could not connect to WiFi");
  return false;
}

void setAlarms()
{

  JsonDocument alarms = loadAlarms();
  Serial.println("\nUPDATING\n");
  for (JsonObject elem : alarms.as<JsonArray>())
  {
    int hour = elem["Hour"];
    int min = elem["Minute"];

    // get time
    int gmtOffsetHours = -8; // consult https://en.wikipedia.org/wiki/List_of_UTC_offsets
    configTime(gmtOffsetHours * 3600, 3600, "pool.ntp.org");
    struct tm timeinfo;
    if (!getLocalTime(&timeinfo))
    {
      Serial.println("Failed to obtain time");
      return;
    }
    int curHour = timeinfo.tm_hour;
    int curMin = timeinfo.tm_min;
    Serial.println(curHour);
    Serial.println(curMin);
    // calculate ms until alarm is due
    long timeTillAlarm = (hour - curHour) * 3600000 + (min - curMin) * 60000;
    Serial.print("Alarm schedule for ");
    Serial.println(timeTillAlarm);
    alarm_data_t *data = (alarm_data_t *)pvPortMalloc(sizeof(alarm_data_t));
    // Check for allocation failure
    if (data == NULL)
    {
      return;
    }
    data->value = timeTillAlarm;
    if (timeTillAlarm > 0)
    {
      xTaskCreate(runAlarmStandard, "", 2048, data, 2, NULL);
    }
  }
}

void setup()
{
  Serial.begin(115200);

  // connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.println("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(250);
    Serial.print("*");
  }
  Serial.println("\nConnected as " + WiFi.localIP());

  // initialize FastLED for 12 LEDs
  initLEDs();

  // set existing alarms
  setAlarms();
}

void loop()
{
  if (shouldUpdate())
  {
    // update alarms
    setAlarms();
  }
  if (shouldPulse())
  {
    // flash in response to webhook
    Serial.println("\nPULSE\n");
    xTaskCreate(pulseLEDs, "", 2048, NULL, 2, NULL);
  }
  delay(500);
}

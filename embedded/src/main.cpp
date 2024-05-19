#include <Arduino.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <time.h>

#include <credentials.h>

void setup()
{
  Serial.begin(115200);

  // connect to WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  Serial.println("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(250);
    Serial.print(".");
  }
  Serial.println("\nConnected as " + WiFi.localIP());

  // get time
  int gmtOffsetHours = -8; // consult https://en.wikipedia.org/wiki/List_of_UTC_offsets
  configTime(gmtOffsetHours * 3600, 3600, "pool.ntp.org");
}

void loop()
{
  if (WiFi.status() == WL_CONNECTED)
  {
    HTTPClient http;
    String serverPath = "https://sortify.rishiroy.com/verify";
    http.begin(serverPath.c_str());
    http.setAuthorization(SERVER_USER, SERVER_PASS);

    int httpResponseCode = http.GET();
    if (httpResponseCode > 0)
    {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println(payload);
    }
    else
    {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  }
  else
  {
    Serial.println("Could not connect to WiFi");
  }

  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");

  delay(500);
}

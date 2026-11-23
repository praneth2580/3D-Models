// Handlebar Dash, phase 1: CAN bus logger (listen only) with GPS speed, for working out the bike's CAN messages.
//
// Board: ESP32-C6-DevKitC-1 (the interface box's future microcontroller). Also builds for an ESP32-S3 or ESP32
// board: change the pins below. Arduino core: esp32 by Espressif, version 3.x (Boards Manager).
// Parts and wiring: ../../PHASE1_LOGGER.md.
//
// What it does:
//  - Listens to the bike's CAN bus in LISTEN-ONLY mode: it never transmits, not even acknowledgements, so it cannot
//    disturb the engine ECU, the ABS unit or the cluster.
//  - Finds the bus's bit rate by itself (500, 250, 1000 or 125 kbit/s).
//  - Writes every frame to a new file on the microSD card, in candump's log format:
//        (12.345678) can0 1A0#0011223344556677
//    The time is seconds since the logger started.
//  - Adds GPS readings as comment lines:  # GPS 12.400000 kmh=42.7 fix=1 utc=083015.00
//    (the analysis script uses them to find the speed message).
//  - Press the BOOT button to add a marker:  # MARK 12.500000 3
//    Use it to note what you did ("mark 3 = indicator on"), and write it down.
//  - The LED (on the C6 board's RGB LED): blue = looking for the bus, green blink = logging,
//    orange = frames but no SD card, red = bus quiet, white flash = marker.
//
// It flushes the file every second: switching off loses at most the last second.

#include <Arduino.h>
#include <SPI.h>
#include <SD.h>
#include "driver/twai.h"

// ------------------------- PINS (ESP32-C6-DevKitC-1) -------------------------
const int PIN_CAN_TX = 4;     // to the transceiver's TX (D) pin. Unused in listen-only mode, but the driver needs it
const int PIN_CAN_RX = 5;     // from the transceiver's RX (R) pin
const int PIN_SD_SCK = 6;
const int PIN_SD_MOSI = 7;
const int PIN_SD_MISO = 2;
const int PIN_SD_CS = 10;
const int PIN_GPS_RX = 20;    // from the GPS module's TX
const int PIN_GPS_TX = 21;    // to the GPS module's RX (not really needed)
const int PIN_BUTTON = 9;     // the BOOT button (pressed = LOW)
const long GPS_BAUD = 9600;   // most NEO-6M/M8N and ATGM336H modules start at 9600

// ------------------------- STATE ---------------------------------------------
File logFile;
uint32_t frames = 0, framesThisSecond = 0, lastStats = 0, lastFlush = 0, marks = 0, ids = 0;
uint32_t seenIds[256];        // a small list of the IDs seen, for the serial monitor's summary
long bitrate = 0;
bool sdOk = false;

double nowSeconds() { return esp_timer_get_time() / 1e6; }

void led(uint8_t r, uint8_t g, uint8_t b) {
#ifdef RGB_BUILTIN
  rgbLedWrite(RGB_BUILTIN, r, g, b);
#endif
}

// ------------------------- CAN -----------------------------------------------
bool startCan(long kbps) {
  twai_general_config_t g = TWAI_GENERAL_CONFIG_DEFAULT((gpio_num_t)PIN_CAN_TX, (gpio_num_t)PIN_CAN_RX, TWAI_MODE_LISTEN_ONLY);
  g.rx_queue_len = 128;
  twai_timing_config_t t;
  switch (kbps) {
    case 1000: t = TWAI_TIMING_CONFIG_1MBITS(); break;
    case 250: t = TWAI_TIMING_CONFIG_250KBITS(); break;
    case 125: t = TWAI_TIMING_CONFIG_125KBITS(); break;
    default: t = TWAI_TIMING_CONFIG_500KBITS(); break;
  }
  twai_filter_config_t f = TWAI_FILTER_CONFIG_ACCEPT_ALL();
  if (twai_driver_install(&g, &t, &f) != ESP_OK) return false;
  if (twai_start() != ESP_OK) { twai_driver_uninstall(); return false; }
  return true;
}

void stopCan() { twai_stop(); twai_driver_uninstall(); }

// Try each bit rate for 1.5 s: the right one receives frames without bus errors.
long findBitrate() {
  const long rates[] = {500, 250, 1000, 125};
  for (long kbps : rates) {
    if (!startCan(kbps)) continue;
    uint32_t got = 0, t0 = millis();
    twai_message_t m;
    while (millis() - t0 < 1500) if (twai_receive(&m, pdMS_TO_TICKS(50)) == ESP_OK) got++;
    twai_status_info_t st;
    twai_get_status_info(&st);
    Serial.printf("  %4ld kbit/s: %lu frames, %lu bus errors\n", kbps, (unsigned long)got, (unsigned long)st.bus_error_count);
    if (got >= 5 && st.bus_error_count < got / 10 + 2) return kbps;   // keep it running
    stopCan();
  }
  return 0;
}

// ------------------------- SD ------------------------------------------------
bool openLog() {
  SPI.begin(PIN_SD_SCK, PIN_SD_MISO, PIN_SD_MOSI, PIN_SD_CS);
  if (!SD.begin(PIN_SD_CS, SPI)) return false;
  char name[24];
  for (int n = 1; n < 1000; n++) {
    snprintf(name, sizeof name, "/canlog_%03d.log", n);
    if (!SD.exists(name)) {
      logFile = SD.open(name, FILE_WRITE);
      if (!logFile) return false;
      Serial.printf("Logging to %s\n", name);
      return true;
    }
  }
  return false;
}

void logLine(const char *s) {
  if (sdOk) logFile.println(s);
}

// ------------------------- GPS (NMEA $GxRMC: speed, fix, time) ---------------
char nmea[100];
int nmeaLen = 0;
uint32_t lastGpsLog = 0;

// Field k (0 = sentence name) of a comma-separated sentence, copied into out.
bool field(const char *s, int k, char *out, int n) {
  int i = 0;
  while (k > 0 && *s) { if (*s++ == ',') k--; }
  if (k > 0) return false;
  while (*s && *s != ',' && *s != '*' && i < n - 1) out[i++] = *s++;
  out[i] = 0;
  return true;
}

void handleNmea(const char *s) {
  if (strlen(s) < 6 || strncmp(s + 3, "RMC", 3) != 0) return;
  char utc[16], status[4], knots[16];
  if (!field(s, 1, utc, sizeof utc) || !field(s, 2, status, sizeof status) || !field(s, 7, knots, sizeof knots)) return;
  if (millis() - lastGpsLog < 200) return;          // at most 5 a second
  lastGpsLog = millis();
  char line[96];
  snprintf(line, sizeof line, "# GPS %.6f kmh=%.2f fix=%d utc=%s", nowSeconds(), atof(knots) * 1.852, status[0] == 'A', utc);
  logLine(line);
}

void pollGps() {
  while (Serial1.available()) {
    char c = Serial1.read();
    if (c == '\n' || c == '\r') {
      if (nmeaLen) { nmea[nmeaLen] = 0; handleNmea(nmea); nmeaLen = 0; }
    } else if (nmeaLen < (int)sizeof nmea - 1) {
      nmea[nmeaLen++] = c;
    }
  }
}

// ------------------------- MAIN ----------------------------------------------
void setup() {
  Serial.begin(115200);
  delay(300);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  Serial1.begin(GPS_BAUD, SERIAL_8N1, PIN_GPS_RX, PIN_GPS_TX);
  Serial.println("\nHandlebar Dash phase-1 CAN logger (listen only)");

  sdOk = openLog();
  if (!sdOk) Serial.println("No microSD card (or it isn't FAT32): logging to the serial monitor only.");

  led(0, 0, 40);
  Serial.println("Looking for the bus (switch the ignition on)...");
  while ((bitrate = findBitrate()) == 0) {
    led(40, 0, 0);
    Serial.println("No CAN traffic yet: is the ignition on, and are CAN H and CAN L the right way round? Trying again.");
    delay(1000);
    led(0, 0, 40);
  }
  Serial.printf("Bus found: %ld kbit/s\n", bitrate);
  char line[64];
  snprintf(line, sizeof line, "# START bitrate=%ld listen_only=1", bitrate * 1000);
  logLine(line);
}

void loop() {
  twai_message_t m;
  while (twai_receive(&m, 0) == ESP_OK) {
    frames++; framesThisSecond++;
    char line[64];
    int n = snprintf(line, sizeof line, m.extd ? "(%.6f) can0 %08lX#" : "(%.6f) can0 %03lX#", nowSeconds(), (unsigned long)m.identifier);
    if (m.rtr) n += snprintf(line + n, sizeof line - n, "R");
    else for (int i = 0; i < m.data_length_code && i < 8; i++) n += snprintf(line + n, sizeof line - n, "%02X", m.data[i]);
    logLine(line);
    if (!sdOk) Serial.println(line);
    bool known = false;
    for (uint32_t i = 0; i < ids; i++) if (seenIds[i] == m.identifier) { known = true; break; }
    if (!known && ids < 256) seenIds[ids++] = m.identifier;
  }

  pollGps();

  // Marker button (debounced): press, then note what you did.
  static bool wasDown = false;
  static uint32_t downAt = 0;
  bool down = digitalRead(PIN_BUTTON) == LOW;
  if (down && !wasDown) downAt = millis();
  if (!down && wasDown && millis() - downAt > 30) {
    char line[48];
    snprintf(line, sizeof line, "# MARK %.6f %lu", nowSeconds(), (unsigned long)++marks);
    logLine(line);
    Serial.printf("Marker %lu\n", (unsigned long)marks);
    led(60, 60, 60);
  }
  wasDown = down;

  if (millis() - lastFlush >= 1000) {
    lastFlush = millis();
    if (sdOk) logFile.flush();
    if (!framesThisSecond) led(40, 0, 0);                        // bus quiet: red
    else if (!sdOk) led(40, 20, 0);                              // frames, but no SD card: orange
    else led(0, (millis() / 1000) % 2 ? 30 : 0, 0);              // logging: green blink
    framesThisSecond = 0;
  }
  if (millis() - lastStats >= 5000) {
    lastStats = millis();
    twai_status_info_t st;
    twai_get_status_info(&st);
    Serial.printf("%lu frames, %lu IDs, %lu markers, rx missed %lu, bus errors %lu%s\n", (unsigned long)frames, (unsigned long)ids,
                  (unsigned long)marks, (unsigned long)st.rx_missed_count, (unsigned long)st.bus_error_count, sdOk ? "" : " (no SD)");
  }
}

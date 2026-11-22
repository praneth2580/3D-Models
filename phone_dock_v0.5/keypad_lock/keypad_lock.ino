/*
  Keypad lock (DEMO) for the handlebar phone dock: a dial code on a rotary encoder, a servo moves the bolt.
  See ../KEYPAD_LOCK.md. License: CC BY-NC-SA 4.0 (../LICENSE.md).

  Board: ATtiny85 with ATTinyCore ("ATtiny25/45/85 (No bootloader)", 8 MHz internal). Program it with a
  USBasp or "Arduino as ISP"; run "Burn Bootloader" once to set the 8 MHz fuses.

  Wiring (ATtiny85 pin numbers):
    pin 5 (PB0)  servo signal (orange)
    pin 2 (PB3)  encoder A          (encoder C to GND; internal pull-ups)
    pin 3 (PB4)  encoder B
    pin 7 (PB2)  encoder push switch (other side to GND)
    pin 8 VCC = 5 V, pin 4 GND. 100 nF across VCC/GND at the chip, 100 uF across the servo's supply.
    5 V comes from the dock board, after the fuse F1 and before the MOSFET switch (always on with the ignition).

  Using it (like a safe dial, counting clicks):
    - UNLOCK: turn RIGHT (clockwise) CODE[0] clicks, then LEFT CODE[1] clicks, then RIGHT CODE[2] clicks,
      and stop. After a short pause the code is checked; if it is right, the servo drops the bolt.
    - LOCK: press the knob. The servo raises the bolt. (Pressing also clears a half-entered code.)
    - A wrong code makes it ignore the knob for a while (3 s, doubling up to 60 s).
*/

// ---- change these ----
const uint8_t CODE[3] = {7, 12, 4};        // your code: clicks right, left, right (1..30 each)
const uint16_t SERVO_LOCKED_US = 1500;     // pulse width with the horn's pin straight up (bolt up). Calibrate!
const uint16_t SERVO_UNLOCKED_US = 2400;   // a quarter turn from there, pin toward the rider side (bolt down)
const bool ENCODER_REVERSED = false;       // set true if "right" counts as left

// ---- pins ----
const uint8_t PIN_SERVO = 0, PIN_A = 3, PIN_B = 4, PIN_SW = 2;

const uint16_t SUBMIT_MS = 1500;           // pause after the last click that submits the code
const uint8_t STEPS_PER_CLICK = 4;         // EC11: one full quadrature cycle per detent

int8_t enc_acc = 0;
uint8_t last_ab = 0;
int8_t dir = 0;                            // direction of the current group: +1 right, -1 left
uint8_t groups[3], ngroups = 0, count = 0;
bool group_dirs_ok = true;
unsigned long last_click = 0, ignore_until = 0, penalty = 3000;

void servo_to(uint16_t us) {               // ~0.8 s of 50 Hz pulses, then stop (the servo holds by friction)
  for (uint8_t i = 0; i < 40; i++) {
    digitalWrite(PIN_SERVO, HIGH); delayMicroseconds(us);
    digitalWrite(PIN_SERVO, LOW);  delay(20 - us/1000);
  }
}

void clear_entry() { ngroups = 0; count = 0; dir = 0; group_dirs_ok = true; }

void close_group() {
  if (count > 0 && ngroups < 3) groups[ngroups++] = count;
  count = 0;
}

void submit() {
  close_group();
  bool ok = group_dirs_ok && ngroups == 3;
  for (uint8_t i = 0; ok && i < 3; i++) ok = groups[i] == CODE[i];
  if (ok) { servo_to(SERVO_UNLOCKED_US); penalty = 3000; }
  else if (ngroups > 0) { ignore_until = millis() + penalty; penalty = min(penalty*2, 60000UL); }
  clear_entry();
}

void click(int8_t d) {                     // one detent, d = +1 right / -1 left
  if (millis() < ignore_until) return;
  if (d != dir) {                          // direction changed: the previous number is done
    if (dir != 0) close_group();
    if (ngroups == 0 && d != +1) group_dirs_ok = false;   // the first number is turned to the right
    dir = d;
  }
  if (count < 255) count++;
  last_click = millis();
}

void setup() {
  pinMode(PIN_SERVO, OUTPUT);
  pinMode(PIN_A, INPUT_PULLUP); pinMode(PIN_B, INPUT_PULLUP); pinMode(PIN_SW, INPUT_PULLUP);
  last_ab = (digitalRead(PIN_A) << 1) | digitalRead(PIN_B);
}

void loop() {
  // Quadrature decoder: +1 / -1 per valid transition, a click per full cycle.
  static const int8_t table[16] = {0, -1, 1, 0, 1, 0, 0, -1, -1, 0, 0, 1, 0, 1, -1, 0};
  uint8_t ab = (digitalRead(PIN_A) << 1) | digitalRead(PIN_B);
  if (ab != last_ab) {
    enc_acc += table[(last_ab << 2) | ab];
    last_ab = ab;
    if (enc_acc >= STEPS_PER_CLICK)  { enc_acc = 0; click(ENCODER_REVERSED ? -1 : +1); }
    if (enc_acc <= -STEPS_PER_CLICK) { enc_acc = 0; click(ENCODER_REVERSED ? +1 : -1); }
  }
  // A pause after the last click submits the code.
  if (dir != 0 && millis() - last_click > SUBMIT_MS) submit();
  // Press: lock.
  if (digitalRead(PIN_SW) == LOW) {
    delay(30);
    if (digitalRead(PIN_SW) == LOW) {
      clear_entry();
      servo_to(SERVO_LOCKED_US);
      while (digitalRead(PIN_SW) == LOW) delay(10);
    }
  }
}

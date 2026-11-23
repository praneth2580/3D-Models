# Phase 1: log the bike's CAN bus, and measure its sensors

Before the dash can show the bike's speed, we need to know **which CAN messages carry what**. Royal Enfield doesn't publish this. So phase 1 is a small logger that only listens, plus a few multimeter checks. The logger's parts are reused in the interface box later.

**What you send back:** the log files from the microSD card, your list of markers, and the measurements below. From them I'll write the bike's signal map (speed, engine speed, temperature, neutral and anything else on the bus).

> **The logger never transmits.** It runs the CAN controller in listen-only mode: it doesn't even acknowledge frames. It can't upset the engine ECU, the ABS or the stock cluster, which stays fitted and working throughout phase 1.

## Parts (INR, estimates)

**Exact items and Amazon.in / Flipkart links: [`COMPONENTS.md`](COMPONENTS.md)** (phase 1 section). The board, the transceiver and the GPS are the ones the dash's housings will be modelled around, so buy those exactly.

| Part | Notes | Price |
|---|---|---|
| ESP32-C6-DevKitC-1 | The future interface box's microcontroller (two CAN controllers) | ₹700–1,000 (est.) |
| SN65HVD230 CAN transceiver module (3.3 V) | **Remove its 120 Ω resistor** (see Wiring) | ₹120–200 (est.) |
| microSD card module (SPI) + a microSD card, 32 GB or less, FAT32 | | ₹200–500 (est.) |
| GPS module: NEO-M8N, NEO-6M or ATGM336H, with its antenna | For finding the speed message; reused in the dash | ₹500–1,200 (est.) |
| Royal Enfield 6-pin to 16-pin OBD-II adapter cable | **Check your socket first** (see Before you buy) | ₹800–1,800 (est.) |
| 16-pin OBD-II male plug with flying leads ("OBD2 pigtail") | So nothing is cut on the bike | ₹200–400 (est.) |
| 12 V to USB car charger + a USB-C cable | Powers the board from the OBD socket | ₹200–400 (est.) |
| Jumper wires, a small box or zip bag, tape | | ₹100–200 (est.) |
| **Total** | | **about ₹2,800–5,700 (est.)** |

Sources: Robu.in, Amazon.in, Lamington Road. The adapter cable is easiest on Amazon; search "Royal Enfield 6 pin OBD2 adapter".

## Before you buy: check the service socket

The Meteor's schematic shows two 6-pin service sockets, "OBD-2" and "Diagnostic", both carrying the CAN bus. Find them (usually under the seat or a side panel) and note their colour:
- Some adapter cables are sold for the **black** (Euro 4) socket only, and one seller says theirs won't fit the **red** (Euro 5) socket. Buy one that matches your socket.
- Photograph the socket face and send it with the logs.

What the adapter gives you, on the standard OBD-II side: **pin 6 = CAN H, pin 14 = CAN L, pin 4 and 5 = ground, pin 16 = +12 V**. Check this with a multimeter before connecting the board, with the ignition on and the adapter plugged in:
- pin 16 to pin 4: about 12–13 V;
- pin 6 to pin 4: about 2.5–3.5 V;
- pin 14 to pin 4: about 1.5–2.5 V.

## Wiring

```
Bike 6-pin socket ── RE adapter ── 16-pin OBD-II ── pigtail leads:
   pin 16 (+12 V) ─────────── car charger +        car charger USB ── USB-C ── ESP32-C6 board
   pin 4/5 (ground) ───────── car charger −  and  board GND
   pin 6 (CAN H) ──────────── transceiver CANH
   pin 14 (CAN L) ─────────── transceiver CANL

ESP32-C6 board          Transceiver (SN65HVD230)    microSD module (SPI)     GPS module
  3V3 ───────────────── 3V3                         VCC (3.3 V type)         VCC (3.3 or 5 V, per module)
  GND ───────────────── GND                         GND                      GND
  GPIO4 ─────────────── CTX (D)                     GPIO6 ─ SCK              GPIO20 ── TX of the GPS
  GPIO5 ─────────────── CRX (R)                     GPIO7 ─ MOSI
                                                    GPIO2 ─ MISO
                                                    GPIO10 ─ CS
```

- **Remove the transceiver's 120 Ω resistor.** Most SN65HVD230 modules have one fitted between CANH and CANL (often marked R2, "121" or "120"). The bike's bus already has its two terminators. Check with a multimeter across the module's CANH and CANL: 120 Ω means it's there. Lift or cut it off.
- **microSD:** use a module with a 3.3 V supply (or one with its own regulator fed from the board's 5V pin). Format the card FAT32.
- **GPS:** put the module (or its antenna) where it sees the sky, for example taped on the tank or in a pocket of a tank bag.
- **Short wires** from the OBD plug to the transceiver (under 30 cm), CAN H and CAN L twisted together.
- **Pin labels:** check the pin names printed on your board. If your board differs, change the pin numbers at the top of the sketch.

## Flash the firmware

1. Install the Arduino IDE (or arduino-cli), then in **Boards Manager** install **"esp32 by Espressif Systems" version 3.x**.
2. Open `firmware/can_logger/can_logger.ino`, choose **ESP32C6 Dev Module**, set **USB CDC On Boot: Enabled**, and upload.
3. Open the serial monitor at 115200 baud. On the bench, with no bus, it says it's looking for the bus (blue LED, then red).

## Log a ride

1. Plug in, switch the ignition on. Within a few seconds the serial monitor (or the LED) shows the bus is found (green blink = logging).
2. **Press the BOOT button to add a marker**, then write down what you did: "marker 1: engine on". Press it at the moment you **start** an action, and hold the action for a few seconds.
3. Suggested list:
   1. Ignition on, engine off, 30 s.
   2. Engine on; idle 30 s.
   3. Rev to about 3,000 rpm, hold 5 s; then about 5,000, hold 5 s.
   4. Clutch in (hold); clutch out.
   5. Neutral → 1st (engine running, clutch in); 1st → neutral.
   6. Side stand down; side stand up (engine off, ignition on, if the bike allows).
   7. Left indicator, right indicator, hazards, high beam (these are wires, not CAN, but log them anyway).
   8. **Ride 15–20 minutes** with the GPS locked: from standstill up to 80–100 km/h where safe, including about 20 s steady at 30, 50 and 70 km/h, and some time in each gear.
   9. Engine off, ignition on, 30 s; ignition off.
4. **Unplug the logger after logging.** The OBD socket's +12 V is live with the ignition off, and the logger would slowly drain the battery.

## Measure on the bike (multimeter)

**1. The bus's terminators.**
- With the ignition off for 10 minutes, measure the resistance between OBD-II pin 6 and pin 14 on the adapter: **about 60 Ω** means two 120 Ω terminators, as expected.
- Then unplug the stock cluster's connector and measure again:
  - **120 Ω:** the cluster held one terminator, so the dash must provide it;
  - **still 60 Ω:** it didn't.
- Plug the cluster back in.

**2. The fuel level sender** (cluster unplugged, ignition off).
- Measure the resistance from the harness plug's **pin 2 (light green, LG)** to ground (the battery's negative terminal).
- Write it down with the fuel level: full tank, and then each time you refuel, with how many litres went in.

**3. The gear position sensor** (cluster plugged in, ignition on, engine off).
- Back-probe the cluster plug with a thin pin. Do not pierce the insulation.
- **Pin 15 (yellow) to pin 18 (black/yellow):** should be about 5.0 V.
- **Pin 16 (brown/black) to pin 18:** write down the voltage in neutral and in each gear (rock the bike to engage each one).
- If your bike has no gear sensor (late-2024-on bikes may not), write down what you find on these pins.

**4. The lamp and warning wires** (cluster plugged in, back-probed against ground).
- Pin 6 (left indicator) and pin 12 (right indicator): the voltage when the indicator is on (it pulses).
- Pin 9 (high beam): the voltage with the high beam on and off.
- Pin 11 (engine light) and pin 14 (ABS light) just after the ignition is switched on, while the lights are lit for the bulb check, and again after they go out. This tells whether a lit warning pulls the wire to ground or raises it to 12 V.

**5. The INFO button** (cluster unplugged).
- Resistance from pin 13 (grey) to ground, button pressed and released.

**6. Photos:** the cluster's plug (face and the back), and the space behind the headlamp where the interface box would go.

## Work it out

On a computer with Python 3:

```sh
python3 tools/can_analyze.py canlog_001.log            # every message: how often, which bytes change
python3 tools/can_analyze.py canlog_001.log --speed    # the speed message: fields that follow the GPS speed
python3 tools/can_analyze.py canlog_001.log --marks    # what changed at each marker (switches, neutral, clutch...)
python3 tools/can_analyze.py canlog_001.log --field 1A0:2:2:le --csv speed.csv   # one field over time
```

The analysis tool was tested on a made-up log with a hidden speed signal, a switch and noise: it found the speed field (and its scale) first and the switch alone. **The real bike is the test that matters.** Send me the logs, the marker notes and the measurements, and I'll do the analysis and write the signal map.

**Compiled, not yet run on a board:** the firmware builds with no errors or warnings (Arduino ESP32 core 3.3.13, for the ESP32-C6 and the ESP32-S3, all warnings on). It hasn't run on real hardware yet.

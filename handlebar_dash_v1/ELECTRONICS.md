# Electronics: what's inside the two boxes, how it's wired, and what to buy

This is the electronics design for the dash: the **interface box** (behind the headlamp, on the bike's 18-pin cluster plug) and the **display head** (the round gauge on the handlebar). It builds on the plan in [`README.md`](README.md) and the parts in [`COMPONENTS.md`](COMPONENTS.md). Phase 1 ([`PHASE1_LOGGER.md`](PHASE1_LOGGER.md)) still comes first: some values here (the fuel sender's pull-up, the lamp lines' polarity, the bus termination) are set from its measurements, and are marked **(phase 1)**.

**Build it on perfboard** with plug-in modules (the transceivers, the motion sensor and the I/O expander are ready-made boards), all through-hole, so everything can be hand-soldered. A small ordered PCB can replace the perfboard later, with the same circuit.

## The whole system

```
                    BIKE (18-pin cluster plug, via an adapter harness: no wires cut)
   +12 V battery (8) ─┐   ignition (1) ─┐   lamp signals (6, 9, 11, 12, 14)   INFO (13)
   ground (5) ────────┤   CAN H/L (4/3) ┤   fuel sender (2)   gear sensor (15, 16, 18)
                      ▼                 ▼
 ┌──────────────────────── INTERFACE BOX (on the frame) ──────────────────────────┐
 │ fuse, spike clamp, power latch ─► switched 12 V ─► 5 V supply (3 A)            │
 │ ESP32-C6: bike bus (listen only) + dash bus, both its own CAN controllers       │
 │ 8 optocoupler inputs ─► I/O expander (I2C)    fuel, gear, battery ─► ADC        │
 │ motion sensor (lean angle, on the frame)      air temperature probe             │
 │ OBD+ socket (bike bus)   3 expansion slots (dash bus + 12 V + 5 V + 1 I/O)      │
 └─────────────────────────────────┬──────────────────────────────────────────────┘
                                   │ 4-wire cable, GX12: +5 V, ground, dash bus H, L
                                   ▼
 ┌──────────────────────── DISPLAY HEAD (on the handlebar) ───────────────────────┐
 │ Waveshare ESP32-S3 2.8" round display (its own RTC keeps the clock)            │
 │ CAN transceiver (dash bus)   8 RGB LED tell-tales   GPS   light sensor          │
 └────────────────────────────────────────────────────────────────────────────────┘
```

**Who does what:**
- **Interface box:** reads everything from the bike. It **only listens** to the bike's CAN bus, and its transceiver's transmit pin is tied off in hardware, so it physically can't send. It works out speed, gear, fuel, lamps and so on, keeps the **odometer**, and sends ready-made readings to the head on the dash bus about 20 times a second.
- **Display head:** draws the screens, lights the tell-tales, reads the GPS (speed fallback, clock) and the light sensor (brightness). It sends back only what the rider does (INFO-button actions arrive from the box anyway).

## Interface box

### Power: fuse, spike clamp and a power latch

The stock cluster takes the always-on battery feed (pin 8) to keep its clock and odometer. The box does the same with a **power latch**: the ignition switches the box on, and the box keeps itself on for a few seconds after the ignition goes off, to save the odometer, then switches itself fully off (no drain when parked).

```
 pin 8 (+12 V) ──[ 3 A blade fuse ]──┬──► IRF4905 source           IRF4905 drain ──► SWITCHED 12 V
                                     └──► P6KE24A ──► ground                          (470 µF 35 V to ground)

 IRF4905 gate:  10k to its source (keeps it off)
                15 V zener to its source (protects the gate)
                1k to the BC547's collector (pulling the gate down turns it on)
 BC547:         emitter to ground, 100k from base to ground
                base ──[10k]──┬── 1N4148 ──[47k]── pin 1 (ignition)
                              └── 1N4148 ──[4.7k]── GPIO19 (HOLD)
 pin 5 (ground) ── ground
```
The switched 12 V feeds the 5 V supply, the expansion slots, the OBD+ socket and the battery sense.

In plain words: the MOSFET is the switch. It's on while either the ignition **or** the ESP32's HOLD pin pulls the transistor's base up. At ignition off, the ESP32 sees it (on an optocoupler input), saves the odometer, then drops HOLD and everything switches off.
- **Spike clamp:** P6KE24A from the fused 12 V to ground: it soaks up spikes above about 26 V. Connected the wrong way round, it conducts and the fuse blows, which protects the rest.
- **The 15 V zener** across the MOSFET's gate and source keeps its gate safe during spikes.
- **5 V supply:** the Envistia 12 V → 5 V 3 A converter (COMPONENTS.md), from the switched 12 V. Its input is rated to 24 V; the clamp handles anything above that briefly. If you'd rather have margin, any sealed **8–36 V input** 5 V 3 A converter of the same size works.

**Power budget (5 V):** display head 0.5–0.9 A (the screen at full brightness and the LEDs), the box's own boards about 0.15 A, the 3 expansion slots up to 0.5 A each. Worst case about 2.6 A, inside the converter's 3 A. From the battery: about 0.3 A typical, 1.2 A worst case.

### The ESP32-C6's pins

| GPIO | Job | Notes |
|---|---|---|
| 0 | Battery voltage (ADC) | divider from the switched 12 V |
| 1 | Fuel level (ADC) | from the fuel sender, see below |
| 2 | Gear position (ADC) | from the gear sensor, see below |
| 3 | I/O expander interrupt | an input changed |
| 4 | Bike bus CAN TX | **not connected** (jumper, open): listen only |
| 5 | Bike bus CAN RX | |
| 6, 7 | I2C SDA, SCL | the motion sensor (0x68) and the I/O expander (0x20) |
| 10 | Dash bus CAN TX | |
| 11 | Dash bus CAN RX | |
| 18 | Air temperature (1-Wire) | DS18B20 probe, 4.7k pull-up to 3.3 V |
| 19 | HOLD (power latch) | high = keep the box on |
| 20, 21, 22 | Expansion slots' spare I/O (slots 1–3) | protected, see below |
| 8, 9, 15 | **leave free** | start-up (strapping) pins and the board's LED / BOOT button |

The two CAN controllers are the ESP32-C6's own ("TWAI"): bike bus and dash bus, 500 kbit/s each (the bike's rate is checked in phase 1).

### Lamp signals and switches: 8 optocoupler inputs

The indicators, high beam and the two warning lights are 12 V lamp signals. Each one reaches the ESP32 through an **optocoupler** (PC817: an LED and a light-sensitive transistor in one package). The bike's 12 V only ever lights a tiny LED, so spikes and wrong voltages can't reach the ESP32.

```
 one channel, lamp signal that goes to +12 V when on (indicators, high beam):
   bike wire ──[2.2k]──► PC817 LED ──► ground      (1N4148 backwards across the LED)
   PC817 transistor: collector ── I/O expander pin,  emitter ── ground

 a signal that is pulled to ground when on (warning lights, maybe the INFO button: phase 1):
   switched 12 V ──[2.2k]──► PC817 LED ──► bike wire
```

Each channel has a **3-pin jumper** that picks which way round its LED is wired, so either kind of signal works; phase 1 measures which kind each wire is.

| Expander pin | Signal | Cluster pin |
|---|---|---|
| P0 | Left indicator | 6 |
| P1 | Right indicator | 12 |
| P2 | High beam | 9 |
| P3 | Engine warning (MIL) | 11 |
| P4 | ABS warning | 14 |
| P5 | INFO button | 13 |
| P6 | Ignition on | 1 |
| P7 | Spare (a neutral or oil switch on other bikes) | |

**I/O expander:** a PCF8574 board on the I2C bus. Its pins are pulled up inside it; an optocoupler that turns on pulls its pin low, and its interrupt line tells the ESP32 right away.

**Phase 1 check:** the warning-light wires come from the ECU and the ABS unit, which may check that a lamp is connected. Measure the current the stock cluster draws on pins 11 and 14 with the light on; the optocoupler draws about 5 mA.

### The bike's sensors

**Fuel level (pin 2).** The tank's float sender is a variable resistor to ground. The box feeds it through a pull-up resistor from 5 V and reads the voltage:
```
 5 V ──[ R_fuel, 1 W ]──┬── pin 2 (sender to ground)
                        └──[10k]──┬──[10k]── ground
                                  └── GPIO1 (100 nF to ground)
```
`R_fuel` is chosen after phase 1 measures the sender from full to empty: about the middle of its range (100 Ω until then). The firmware maps the voltage to the 7-bar gauge with a calibration table.

**Gear position (pins 15, 16, 18).** The sensor needs 5 V and gives a different voltage in each gear:
```
 5 V ──[ 100 mA self-resetting fuse ]── pin 15 (sensor supply)
 pin 16 (signal) ──[10k]──┬──[15k]── ground          (5 V becomes 3.0 V at most)
                          └── GPIO2 (100 nF to ground)
 pin 18 (sensor ground) ── ground
```
Phase 1 measures the voltage in each gear (and neutral); bikes built without the sensor just show neutral from the bus, if it's there.

**Battery voltage:** switched 12 V ──[100k]──┬──[22k]── ground, the middle to GPIO0 with 100 nF, and a BAT85 diode from GPIO0 to 3.3 V as a clamp (16 V reads 2.9 V).

**Motion sensor (GY-521, MPU-6050)** on the I2C bus, fixed flat to the box, which is fixed to the frame (lean angle needs the frame, not the handlebar).

**Air temperature:** the DS18B20 probe on its 1 m lead, outside the box in the shade, away from the engine.

### CAN buses

- **Bike bus:** an SN65HVD230 board, its 120 Ω resistor **removed**, its **D (transmit) pin tied to 3.3 V** (permanently "silent"). A jumper can connect it to GPIO4 later, only if phase 1 shows the bike needs something the stock cluster used to send. A second jumper adds a 120 Ω terminator, if phase 1 shows the cluster carried one.
- **Dash bus:** another SN65HVD230 board, its 120 Ω resistor **kept** (the box is one end of the dash bus; the head is the other).
- Twist each pair of CAN H and CAN L wires.

### OBD+ socket and expansion slots

```
 OBD+ (16-pin):  6 ── bike CAN H     14 ── bike CAN L     4, 5 ── ground
                 16 ── switched 12 V through a 2 A self-resetting fuse (only with the ignition on: no drain when parked)

 each expansion slot (GX12 6-pin):
   1 ── switched 12 V through a 1 A self-resetting fuse
   2 ── 5 V through a 0.5 A self-resetting fuse
   3 ── ground
   4, 5 ── dash bus CAN H, CAN L
   6 ── spare I/O: ESP32 pin ──[1k]──┬── slot pin 6      (10k to ground, BAT85 to 3.3 V)
```

### Cable to the display head

GX12 4-pin: **1 = +5 V** (through a 1.5 A self-resetting fuse), **2 = ground**, **3 = dash bus CAN H**, **4 = dash bus CAN L**. 4-core shielded cable, 0.5 mm²; the shield is connected to ground at the box only.

## Display head

The Waveshare board uses almost all of its ESP32-S3's pins for the screen. What's left (from Waveshare's wiki for the ESP32-S3-Touch-LCD-2.8C):
- **GPIO0:** the spare pin on its 12-pin header.
- **GPIO19 and GPIO20:** the native USB port's pins, also on the header. We use them, so **program the board through its other USB-C port** (the "USB to UART" one).
- **GPIO43 and GPIO44:** the serial port's pins, shared with that USB to UART port.
- **The I2C connector** (GPIO7 clock, GPIO15 data, 3.3 V), shared with the touch panel, the RTC and the motion sensor on the board.

That's just enough:

| Board pin | Job |
|---|---|
| 12-pin header 2 (VBus / 5 V) | power in: +5 V from the cable through an SS34 diode (so a USB cable plugged in on the bench can't feed back into the bike) |
| header 3 (GPIO19) | CAN transceiver D (transmit) |
| header 4 (GPIO20) | CAN transceiver R (receive) |
| header 12 (GPIO0) | the tell-tale LEDs' data, through a level shifter |
| header 10 (GPIO44, RXD) | the GPS's TX, through a 1 kΩ resistor (so the USB to UART chip wins while you program it) |
| header 6 (3V3), 1/5 (GND) | the CAN transceiver's supply |
| I2C connector | the BH1750 light sensor (address 0x23: no clash with the board's own chips) |

**The tell-tale LEDs (8 × WS2812B on 10 mm boards):** powered straight from the cable's 5 V (not through the display board), with a 1000 µF capacitor where the 5 V enters the head. Their data line needs 5 V logic: a **74HCT125** buffer (one of its four gates) turns GPIO0's 3.3 V into 5 V, then a 330 Ω resistor to the first LED's DIN. Chain them DOUT → DIN round the face (the wire channel in the CAD).

**GPS (NEO-M8N + 18 mm active patch):** 5 V and ground from the cable, its TX to the board as above. It sends position and speed at 5 times a second; it needs no setting up.

**What's already on the display board:** an RTC (PCF85063) keeps the clock between rides, set from the GPS; a microSD slot (a ride log, later); a buzzer (alerts); a motion sensor, which is on the handlebar, so it isn't used for lean angle.

**The dash bus's other end:** the head's SN65HVD230 keeps its 120 Ω resistor.

## What to buy

**Already in COMPONENTS.md** (the modules the housings are modelled around): the display, the GPS and its 18 mm patch, the light sensor, 3 × SN65HVD230, 8 × WS2812B boards, the ESP32-C6 board, the GY-521, the 12 V → 5 V supply, the OBD-II socket, 3 GX12 6-pin sockets, the GX12 4-pin set and cable, the DS18B20 probe.

**New for the circuits** (Amazon.in, Robu.in, or Lamington Road; all estimates):

| Part | Qty | For | Price |
|---|---|---|---|
| PCF8574 I/O expander board (I2C) | 1 | the 8 inputs | ₹80–150 (est.) |
| PC817 optocouplers | 8 (buy 10) | the inputs | ₹50–100 (est.) |
| IRF4905 P-channel MOSFET (TO-220) | 1 | power latch | ₹40–80 (est.) |
| BC547 NPN transistor | 2 | power latch | ₹10 (est.) |
| 15 V zener (1N4744A), 1N4148 diodes (10), BAT85 diodes (5), SS34 Schottky (1) | | latch, clamps, head power | ₹60–120 (est.) |
| P6KE24A TVS diode | 1 | spike clamp | ₹20–40 (est.) |
| Self-resetting fuses (PTC): 3 × 1 A, 3 × 0.5 A, 1 × 2 A, 1 × 1.5 A, 1 × 0.1 A | 9 | slots, OBD+, head cable, gear sensor | ₹150–300 (est.) |
| Inline blade fuse holder + 3 A fuses | 1 | main feed | ₹50–100 (est.) |
| 74HCT125 (DIP-14) | 1 | LED data level shifter (in the head) | ₹30–60 (est.) |
| Resistor kit (1/4 W), plus 2 × 1 W (100 Ω for the fuel sender; the final value after phase 1) | | | ₹150–300 (est.) |
| Capacitors: 100 nF ceramic (20), 470 µF 35 V, 1000 µF 10 V | | | ₹80–150 (est.) |
| 3-pin jumpers and header pins, IC socket, JST-XH connectors | | | ₹150–300 (est.) |
| Perfboard, about 9 × 15 cm (box) and 5 × 7 cm (head) | 2 | | ₹80–150 (est.) |
| Hook-up wire (24 AWG), 30 AWG wire-wrap (LEDs), heat shrink | | | ₹200–400 (est.) |
| Conformal coating spray (protects the boards from damp) | 1 | | ₹300–600 (est.) |
| **The bike-side 18-pin plug** | 1 | the adapter harness | **unknown: to identify in phase 1** |

**About ₹1,400–2,800 (est.) on top of COMPONENTS.md.** Tools you'll want if you don't have them: a multimeter, a 12 V 3 A bench supply or adapter (for the bench tests), and optionally a cheap USB logic analyser (₹500–800 (est.)) for watching the CAN and LED signals.

## Build and bring-up order

1. **Phase 1 first** (the logger and the measurements): it sets `R_fuel`, the jumpers' directions, the termination, and the bike's CAN messages.
2. **Interface box, power only:** the fuse, clamp, latch and 5 V supply, on a 12 V bench supply. Check: ignition wire to 12 V switches it on; off switches it off; HOLD keeps it on.
3. **Add the ESP32-C6 and the inputs:** feed 12 V to each input in turn and watch the expander's readings.
4. **Add the CAN buses:** play a phase 1 log into the bike-bus side from a second board (on the bench only) and check the box decodes it.
5. **Display head on the bench:** 5 V and the dash bus from the box. Check the screen, the LEDs (all 8, each colour), the GPS (outdoors), the light sensor.
6. **On the bike,** with the stock cluster kept so it can go back on.

## Open points (from phase 1)

- The fuel sender's resistance from full to empty (sets `R_fuel`).
- The gear sensor's voltage in each gear.
- Each lamp wire's polarity, and the current the stock cluster draws on the two warning-light pins.
- Whether the stock cluster carries a 120 Ω terminator, and whether the bike complains with it unplugged.
- The bike-side 18-pin plug's part number.

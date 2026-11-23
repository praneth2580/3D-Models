# Handlebar Dash (v1): a round digital dash that replaces the stock instruments

**Status: planning.** Nothing is built yet. This file is the design brief: what we know about the bike, the plan, and the open questions.

A round colour display on its own handlebar clamp that **replaces the stock instrument cluster**. It reads the bike's own signals (speed, fuel, gear, indicators, warning lights) and adds its own sensors: GPS (speed, trip, clock), battery voltage, air temperature, and lean angle and g-force.

- **Reference bike:** a 2021-on single-cylinder 350 on the "J" platform, harness **J1D3** (the Meteor 350). Every bike-specific value (handlebar size, clamp position, harness adapter, signal map, fuel and gear sensor calibration) will be a setting, so the other bikes on the same platform can be added with the least work (see [Other bikes](#other-bikes)).
- **Owner's choices (2026-11-23):** replace the stock instruments; a large round display; its own handlebar clamp; show GPS speed and trip, clock, battery voltage, air temperature, lean angle and g-force, and the bike's own signals (gear, fuel, indicators); read the bike's documentation.

## What we know about the bike

**Source:** Royal Enfield's own wiring schematic, *"J1D3 Meteor overall schematics (Applicable for Euro V regulations)"*, edition 22-11-2024. The owner's manual links it with a QR code on its wiring-diagram page (p. 121). The schematic and the manual are kept locally in `reference/`, which is never published (they are Royal Enfield's documents). The table below states the facts from them in our own words. Check them against your bike: markets and model years differ.

### The stock instrument cluster's connector (18 pins)

| Pin | Signal | Wire | Comes from / goes to |
|---|---|---|---|
| 1 | Ignition (switched +12 V) | WH | ignition switch |
| 2 | Fuel level sensor | LG | fuel pump module (float sender) |
| 3 | CAN L | WH/BU | CAN bus |
| 4 | CAN H | WH | CAN bus |
| 5 | Ground | BK | |
| 6 | Left indicator (lamp signal) | WH/BK | flasher / indicator switch |
| 7 | not used | | |
| 8 | Battery (+12 V, always on) | RD | |
| 9 | High beam (lamp signal) | YE/BU | headlamp switch |
| 10 | not used | | |
| 11 | Engine warning light (EMS MIL) | BU/YE | engine ECU, pin 15 |
| 12 | Right indicator (lamp signal) | WH/GN | flasher / indicator switch |
| 13 | INFO button | GY | left switch module |
| 14 | ABS warning light (ABS MIL) | GN/YE | ABS unit, pin 7 |
| 15 | Sensor supply +5 V (out) | YE | gear position sensor |
| 16 | Gear position signal (in) | BR/BK | gear position sensor |
| 17 | not used | | |
| 18 | Sensor ground | BK/YE | gear position sensor |

Fuse **F4, 10 A** ("signalling") feeds the cluster, the indicators, the wheel speed sensors and the stop lamp.

### The CAN bus

- On the bus: the **engine ECU** (pins 12 CAN H, 25 CAN L), the **ABS unit** (pins 3 CAN H, 4 CAN L), the **instrument cluster**, and two service sockets: **"OBD-2"** (pin 2 CAN H, pin 5 CAN L, pin 3 ground) and **"Diagnostic"** (pin 2 CAN H, pin 5 CAN L, pin 4 ground, pin 1 red, likely +12 V).
- The **wheel speed sensors** (front and rear) are wired only to the ABS unit. So **road speed reaches the cluster as a CAN message**; there is no speed wire.
- The clutch switch and the side-stand switch go to the engine ECU, not to the cluster.
- The Tripper navigation pod ("display device") only takes power (battery, switched +12 V, ground): its data comes from the phone over Bluetooth.
- **Not published:** which CAN messages carry speed, engine speed, temperature and the rest. They have to be logged and worked out on the bike (phase 1).

### What the stock cluster shows (owner's manual, pp. 31-37)

Speed (needle), odometer, trips A, B and F (distance since low fuel), 12-hour clock, fuel gauge (7 bars), service reminder, ECO indicator, gear position, and warning lights: ABS, low battery, low fuel, left and right indicators, high beam, engine malfunction, neutral. The INFO button cycles the trips and sets the clock.

**Note:** bikes built from late 2024 were reported to leave the factory without the gear position sensor (a parts shortage), with only the neutral light working. The dash must work with or without it.

## What this means for the design

1. **Speed needs the CAN bus.** Until the messages are worked out, the dash can show **GPS speed**. After phase 1 it shows the bike's own wheel speed, and probably engine speed, engine temperature and neutral too.
2. **Unplugging the stock cluster may upset the bus.** The cluster may carry one of the bus's two 120 Ω terminating resistors, and the ECU or ABS unit may report it missing. Phase 1 checks both. The dash will have a switchable 120 Ω terminator, and will only listen to the bus (it never sends) unless a missing-cluster fault forces otherwise.
3. **The dash takes over the cluster's sensor jobs:** a 5 V supply and an input for the gear position sensor, and the bias current for the fuel level sender. Both need calibrating on the bike.
4. **The lamp signals are 12 V wires** (indicators, high beam, the two warning lights): each input needs a divider and clamping before it reaches the microcontroller.
5. **The odometer is a legal requirement.** The dash keeps its own odometer, starting from the stock cluster's reading, saved so it survives power cuts.
6. **Lean angle needs a sensor fixed to the frame,** not on the handlebar, which turns with the steering. So the motion sensor goes in the interface box, not in the display.

## Plan

**Proposed layout: two boxes.**
- **Interface box**, where the stock cluster's connector is (behind the headlamp). It plugs into the bike's 18-pin cluster connector through an adapter harness, so no wires are cut, and it holds:
  - the CAN transceiver;
  - the gear sensor's 5 V supply and the fuel sender bias;
  - the 12 V inputs, with protection;
  - the motion sensor;
  - an automotive 12 V to 5 V supply.
  
  It sends ready-made readings to the display.
- **Display head** on the handlebar clamp: a round ESP32-S3 display with GPS, a light sensor for automatic brightness, and a sun hood. It connects to the interface box by one thin 4-wire cable.
- **Why two boxes:** round ESP32-S3 displays use most of their pins for the screen, leaving too few for the bike's signals. Lean angle also needs the motion sensor on the frame.

**Phases:**
1. **Logger and measurements (needs the bike).** A small ESP32 and CAN transceiver plugged into the OBD-2 socket, listening only, logging to a microSD card. Ride, rev, change gear, use the indicators and so on, then work out the messages. Also measure:
   - the bus's termination, with the cluster in and out;
   - the fuel sender's resistance from full to empty;
   - the gear sensor's voltage in each gear;
   - whether the bike reports anything with the cluster unplugged.
   
   The logger's parts are reused in the interface box.
2. **Electronics on the bench:** interface box and display working together, with a recorded log played back as if it were the bike.
3. **Enclosures (OpenSCAD):** the display head with its clamp and sun hood, and the interface box. Like the other projects: parametric, printable, with asserts and fit checks.
4. **Firmware:** the screens (speed, gear, fuel, trips, clock, tell-tales, lean angle), the odometer, brightness, the INFO button.
5. **On the bike,** keeping the stock cluster so it can be refitted (for servicing or inspection).

## Other bikes

The other 350s on the same platform (the Classic, Hunter, Bullet and Goan Classic 350s) share the engine, ECU and ABS. They probably share the CAN messages, but their cluster connector, wiring and handlebars may differ. For each one:
- get its schematic;
- check the cluster connector;
- log its bus once;
- set its handlebar size.

Only the Meteor's schematic has been read so far; the Hunter 350's owner's manual (dual-channel ABS) has no wiring QR code.

## Legal and warranty

- A working speedometer (and odometer) is required on the road. The dash must always show speed, and must fall back to GPS speed if the bus goes quiet.
- Royal Enfield's manuals say electrical changes not done by an authorised centre can void the warranty. The adapter harness avoids cutting wires, and the stock cluster can be plugged back in.
- The display must be readable in direct sun (the stock LCD also looks dull in overhead sun, as its manual says). Pick a bright IPS panel and fit a hood.

## Rough cost (INR, all estimates)

| Part | Price |
|---|---|
| Round ESP32-S3 touch display, 2.1" (480 × 480) or 2.8" (480 × 480) | ₹3,000–5,000 (est.) |
| ESP32-S3 board for the interface box (the phase-1 logger) | ₹500–800 (est.) |
| CAN transceiver module (SN65HVD230, 3.3 V) | ₹120–200 (est.) |
| GPS module (u-blox M8/M10 class) | ₹600–1,500 (est.) |
| Motion sensor (6-axis IMU) | ₹150–700 (est.) |
| Air temperature sensor, light sensor | ₹100–300 (est.) |
| Automotive 12 V → 5 V supply, protection parts | ₹200–500 (est.) |
| microSD socket and card (logger) | ₹300–600 (est.) |
| Connectors, adapter harness, cable | ₹300–1,000 (est.) |
| Printing (two enclosures, clamp, hood) | ₹600–1,500 (est.) |
| **Total** | **about ₹6,000–12,000 (est.)** |

## Open questions

- **Display size:** 2.1" or 2.8" round (both 480 × 480): the bigger one is easier to read, costs more and needs a larger housing.
- **The connector:** the mating part for the bike's 18-pin cluster plug, so the adapter harness doesn't need any cutting. Find its part number, or take one from a used cluster.
- **Room for the interface box** behind the headlamp, once the stock cluster is gone.
- **Other bikes:** which ones to support first.

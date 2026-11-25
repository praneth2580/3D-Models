# Handlebar Remote (v1): a slim thumb controller between the grip and the switch cube

**Status: designed and modelled (v1, checked in CAD, not printed or built yet).** The firmware comes next.

A slim control collar on the **left handlebar, between the grip and the bike's switch cube**, under your thumb, to work **digital displays without letting go of the bar**: the [Handlebar Dash](../handlebar_dash_v1/) over its own wiring, and a **phone** (or anything else that takes a Bluetooth keyboard or remote) over Bluetooth. It's general purpose: the bar size, the gap and the controls' angle are settings, so it fits any bike.

![The control collar between the grip and the switch cube, from the rider's seat](images/hr_rider.png)

**Owner's choices:**
- 2026-11-24: a 5-way joystick (up, down, left, right, press) and 2 buttons, glove-friendly and used without looking; wired to the dash (one of its expansion slots: power and the dash bus) **and** Bluetooth for a phone.
- 2026-11-25: "I want it between the grips and the control panel, a slim control unit". The first version (a box on an arm over the switch cube) is in git history.

## What it does

| Control | On the dash | On a phone (Bluetooth) |
|---|---|---|
| Joystick up / down | move through the menu or the screens | arrow keys up / down |
| Joystick left / right | previous / next screen | arrow keys left / right |
| Joystick press | select | Enter |
| Button 1 (upper, toward the front) | back | Escape (back) |
| Button 2 (lower, toward you) | the trip / INFO screen | play / pause (media) |
| Button 2, held 1 s | switch between controlling the dash and the phone | the same |

- **On a phone**, the remote is a standard Bluetooth keyboard with media keys, so it needs no app. Navigation apps that take a keyboard or a "remote" (for example OsmAnd, Locus Map and DMD2) can be driven with the arrows; media keys work with any music app. Google Maps reacts to few keys, so it's mostly music and volume there.
- **On the dash**, the remote sends its keys as messages on the dash bus (below), and the dash's firmware decides what each one does.
- **Without the dash:** it also works alone, as a Bluetooth remote, powered from any 5 V USB socket on the bike.

## How it's built: two parts on the bike

![Seen from above: 19 mm wide, between the grip and the switch cube](images/hr_top.png)

**1. The control collar** (on the bar, between the grip and the switch cube). **19 mm wide** along the bar, so it needs a 20 mm gap there (`gap_w`). On most bikes the switch cube sits against the grip: slide it about 20 mm inboard (if it has a locating pin, the bar needs a new 4–5 mm hole for it, or file the pin off). It holds only the switches:
- **A ring round the bar** in two halves (2 M3 screws up from below into inserts, a 1 mm rubber strip inside).
- **A low pod** on its upper rear quarter, facing up and back toward your thumb (`pod_a` 125°), standing 9 mm above the ring. Its face, 19 × 41 mm, has **the joystick in the middle and a button either side of it round the bar**, so your thumb rolls from one to the next.
- **Inside:** a small perfboard (14 × 30 mm) with a 10 mm 5-way switch and 2 low tactile switches, resting on steps at the pod's corners.
- **The keypad (TPU)** lies on the pod's rim under the face plate: it's the seal, its 2 hollow domes are the buttons (a nub under each presses its switch), and it hugs the joystick cap's sleeve. The **face plate** screws down on it with 4 M2 screws, squeezing it 0.2 mm.
- **The joystick cap** (13 mm) pushes onto the switch's stem through the plate and the keypad.
- **An 8-core cable** (7 switches + their common) leaves the pod's inboard side and runs along the bar under the switch cube's own wires.

![The face: a button either side of the joystick](images/hr_face.png)

**2. The electronics box** (anywhere near: zip-tied under the bar inside the switch cube, or on the frame), 48 × 38 × 18 mm: the **ESP32-C3 Super Mini** and the **CAN transceiver** side by side, a lid on a TPU gasket (4 M2 screws), 2 cable holes at one end (the collar's 8-core in, the 4-core to the dash out), sealed with silicone, and 2 slots underneath for zip ties.

![The electronics box, opened](images/hr_box.png)

![Taken apart](images/hr_exploded.png)

## Electronics

| Part | Job |
|---|---|
| **5-way navigation switch**, 10 × 10 mm, about 7 mm tall | the joystick. It's the switch on the common "5-way navigation button module": buy the module and take the switch off (or buy the switch on its own) |
| **2 low tactile switches**, 6 × 6 × 3.5 mm | the 2 buttons |
| **ESP32-C3 Super Mini** (22.5 × 18 mm) | reads the switches; Bluetooth LE (keyboard + media keys); its own CAN controller for the dash bus |
| **SN65HVD230 CAN transceiver module** | the dash bus (remove its 120 Ω resistor: see below) |

**The 8-core cable, collar to box:** UP, DOWN, LEFT, RIGHT, PRESS, BUTTON 1, BUTTON 2 and COMMON (every switch connects its wire to COMMON when pressed).

**In the box (ESP32-C3 Super Mini):**

| GPIO | To |
|---|---|
| 0, 1, 3, 4, 5 | UP, DOWN, LEFT, RIGHT, PRESS (the ESP32's own pull-ups; COMMON to ground) |
| 6, 7 | BUTTON 1, BUTTON 2 |
| 21 | CAN TX → transceiver D |
| 20 | CAN RX ← transceiver R |
| 5V, GND | from the dash's cable |
| 3V3 | the transceiver's supply |

GPIO 2, 8 and 9 are left free (start-up pins, the board's LED and BOOT button).

**The cable to the dash:**
- **To the dash:** a 4-core cable and a **GX12 6-pin plug** into one of the dash's expansion slots. Slot pin 2 is +5 V, 3 ground, 4 CAN H and 5 CAN L; pins 1 (12 V) and 6 (spare) aren't used.
- **Without the dash:** a USB-A plug into the bike's USB socket for 5 V (Bluetooth only).
- **Termination:** the dash bus already has its two 120 Ω terminators, at the dash's interface box and its display. The remote is a short branch, so **remove the 120 Ω resistor** from its SN65HVD230 module.

## Messages on the dash bus

The remote's messages, so the dash (or anything else on the dash bus) can use them. 500 kbit/s, standard 11-bit IDs:

| ID | Sent | Bytes |
|---|---|---|
| **0x340** keys | on every change, every 100 ms while a key is held, and every second as a heartbeat | 0: the keys held, one bit each (0 up, 1 down, 2 left, 3 right, 4 press, 5 button 1, 6 button 2). 1: the event (0 none, 1 pressed, 2 released, 3 held 1 s, 4 repeat). 2: which key (its bit number). 3: a counter |
| **0x341** status | every second | 0: what it's controlling (0 the dash, 1 the phone). 1: Bluetooth (0 off, 1 waiting to pair, 2 connected) |

## Settings to measure

None of these parts has a published drawing, so the sizes in `handlebar_remote.scad` are placeholders (marked MEASURE):
- **Your bike:** the bar's diameter (`bar_d`, 22.2 mm); the gap you can make between the grip and the switch cube (`gap_w`, 20 mm); the switch cube's size and the grip's diameter (only for the fit check). And `pod_a`, where the pod faces round the bar (125°: up and back), to suit your thumb.
- **The switches:** the 5-way switch's body (10 × 10 × 4 mm) and its stem (7 mm above the board, 3.5 mm across); the tactile switches' height (3.5 mm).
- **The boards in the box:** the ESP32-C3 Super Mini's height with its parts; the SN65HVD230 module's size.

The model adapts and refuses what doesn't fit: a gap under 19 mm, tactile switches too tall for the joystick, a stem too short for its cap to grip, boards too big for the box.

## Checks done (CAD)

- every part exports as one watertight body;
- the switches fit the pod (the board only touches its steps); the joystick's stem grips the cap, the keypad hugs the cap's sleeve and is squeezed by the face plate (all deliberate);
- the collar's halves, the face plate, the keypad and the cap only touch where they should;
- the collar clears the grip and the switch cube;
- the boards fit the box; its gasket is squeezed by the lid.

**Not yet:** printed and tried on a bike; the firmware; the real parts measured.

## Printing

| Part | Material | How |
|---|---|---|
| `collar_top`, `collar_bottom` | ASA (PETG for a first try), 100 % infill round the ring | on their side (the rings print round) |
| `face_plate` | ASA / PETG | its top down |
| `joy_cap` | ASA / PETG (or TPU for grip) | flat top down |
| `keypad`, `box_gasket` | TPU 85A–95A | domes down; flat |
| `box`, `box_lid` | ASA / PETG | flat |

Parts and where to buy them: [`COMPONENTS.md`](COMPONENTS.md), and the project's page on the website.

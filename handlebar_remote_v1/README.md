# Handlebar Remote (v1): a thumb controller for the left handlebar

**Status: designed and modelled (v1, checked in CAD, not printed or built yet).** The firmware comes next.

A small controller on the **left handlebar**, under your thumb, to work **digital displays without letting go of the bar**: the [Handlebar Dash](../handlebar_dash_v1/) over its own wiring, and a **phone** (or anything else that takes a Bluetooth keyboard or remote) over Bluetooth. It's general purpose: the bar size, the bike's switch cube and the controller's position are all settings, so it fits any bike.

![The remote on the left handlebar, from the rider's seat](images/hr_rider.png)

**Owner's choices (2026-11-24):**
- **Controls:** a 5-way joystick (up, down, left, right, press) and 2 buttons, all glove-friendly and usable without looking.
- **Connection:** wired to the dash (one of its expansion slots: power and the dash bus) **and** Bluetooth for a phone.
- **Mounting:** its own slim clamp on the bar, just inside the bike's left switch cube, with the head reaching over the cube to your thumb.

## What it does

| Control | On the dash | On a phone (Bluetooth) |
|---|---|---|
| Joystick up / down | move through the menu or the screens | arrow keys up / down |
| Joystick left / right | previous / next screen | arrow keys left / right |
| Joystick press | select | Enter |
| Button 1 (upper) | back | Escape (back) |
| Button 2 (lower) | the trip / INFO screen | play / pause (media) |
| Button 2, held 1 s | switch between controlling the dash and the phone | the same |

- **On a phone**, the remote is a standard Bluetooth keyboard with media keys, so it needs no app. Navigation apps that take a keyboard or a "remote" (for example OsmAnd, Locus Map and DMD2) can be driven with the arrows; media keys work with any music app. Google Maps reacts to few keys, so it's mostly music and volume there.
- **On the dash**, the remote sends its keys as messages on the dash bus (below), and the dash's firmware decides what each one does.
- **Without the dash:** it also works alone, as a Bluetooth remote, powered from any 5 V USB socket on the bike.

## How it's built

![The face: the joystick and the 2 buttons](images/hr_face.png)

1. **Head:** a rounded box, 48 × 33 × 27 mm. Its face has the joystick's round hole and the 2 buttons' holes.
2. **Keypad (TPU):** one printed sheet under the face, glued round its edge to the face's underside. The 2 button domes come up through their holes, and the joystick's stem pierces it. It seals the holes, like a phone's rubber keypad. The domes are hollow, with a nub underneath that presses the switch.
3. **Joystick module:** the common "5-way navigation button module". Its own 2 small push buttons (SET and RST) are the 2 buttons, under the keypad's big domes, so there are no extra switches to wire. It's held between 4 posts on the face and 4 posts on the back lid.
4. **Back lid:** closes the head on a TPU gasket in a groove (squeezed 0.2 mm), with 2 M2.5 screws in ears at the ends. The ESP32-C3 and the CAN transceiver stick to it, stacked on foam tape. The cable comes in through an M8 cable gland in it.
5. **Mount:** a slim clamp (12 mm wide) on the bar just inside the switch cube, with an arm up to a boss on the back lid (2 M3 screws into inserts). The clamp's cap comes up from below on 2 M4 bolts into inserts, with a 1 mm rubber strip inside.
6. **Joystick cap:** a low mushroom cap (17 mm) that pushes onto the stem, over the keypad.

![Taken apart](images/hr_exploded.png)

**Where it sits** (settings, in the bike's frame, from the clamp on the bar):
- `head_pos` [−18, −32, 63]: the face's centre, 18 mm outward over the switch cube, 32 mm behind the bar and 63 mm above it;
- `face_tilt` 50°: tilted back toward the thumb.

Set these where your thumb falls: the joystick should be about a thumb's reach from the grip without moving your hand.

![From the side](images/hr_side.png)

## Electronics

| Part | Job |
|---|---|
| **ESP32-C3 Super Mini** (22.5 × 18 mm) | reads the joystick and buttons; Bluetooth LE (keyboard + media keys); its own CAN controller for the dash bus |
| **SN65HVD230 CAN transceiver module** | the dash bus (no 120 Ω resistor: see below) |
| **5-way navigation button module** | the joystick and the 2 buttons (each switch connects its pin to COM) |

**Wiring (ESP32-C3 Super Mini):**

| GPIO | To |
|---|---|
| 0, 1, 3, 4, 5 | joystick UP, DWN, LFT, RHT, MID (the ESP32's own pull-ups; COM to ground) |
| 6, 7 | SET (button 1), RST (button 2) |
| 21 | CAN TX → transceiver D |
| 20 | CAN RX ← transceiver R |
| 5V, GND | from the cable |
| 3V3 | the transceiver's supply |

GPIO 2, 8 and 9 are left free (start-up pins, the board's LED and BOOT button).

**The cable:**
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

These boards have **no published drawings**, so the sizes in `handlebar_remote.scad` are placeholders (marked MEASURE):
- **The 5-way module:** its board (about 41 × 26 mm), where the joystick and the SET and RST buttons sit on it, the stem's height (about 12 mm) and diameter, and the header's position.
- **The ESP32-C3 Super Mini's** thickness with its parts; **the SN65HVD230 module's** size.
- **Your bike:** the bar's diameter (`bar_d`, 22.2 mm) and the left switch cube's size (`cube`: width along the bar, depth, top above and bottom below the bar's centre). The cube is used only for the fit check.

## Checks done (CAD)

- every part exports as one watertight body;
- the boards fit (they only touch their posts); the joystick's stem grips the keypad and the cap (a deliberate light press fit);
- the parts only touch where they should; the lid's gasket is squeezed;
- the clamp's two halves are clear;
- the head, the arm and the clamp clear the bike's switch cube (the estimate) and the grip.

**Not yet:** printed and tried on a bike; the firmware; the real modules measured.

## Printing

| Part | Material | How |
|---|---|---|
| `head` | ASA (PETG for a first try) | face down |
| `back_lid` | ASA / PETG | its boss down |
| `arm_clamp`, `clamp_cap` | ASA / PETG, 100 % infill round the clamp | the split face down |
| `joy_cap` | ASA / PETG (or TPU for grip) | flat top down |
| `keypad`, `lid_gasket` | TPU 85A–95A | domes down; flat |

Parts and where to buy them: [`COMPONENTS.md`](COMPONENTS.md), and the project's page on the website.

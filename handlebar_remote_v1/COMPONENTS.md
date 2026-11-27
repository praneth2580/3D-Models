# Components: what the remote is built (and modelled) around

**The printed parts are modelled around the items marked "Model fits this".** None has a published drawing: measure yours and set the sizes in `handlebar_remote.scad` (the MEASURE lines) before printing.

**Prices:** estimates (not checked on a listing), marked (est.). Where to buy each item, with search links at the Indian stores: the project's page on the website ("What to buy").

## The controls (in the collar's curved face)

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Joystick** | **5-way navigation switch, 10 × 10 mm, about 7 mm tall** (up, down, left, right, press). The easiest source is the common "5-way navigation button module" (5D rocker joystick module): take its switch off. Or buy the switch alone ("5-way tactile switch 10x10") | **Yes** (MEASURE) | ₹60–150 (est.) |
| **Buttons** | **4 tactile switches, 6 × 6 × 6 mm** (2 with `buttons` = 2) (through-hole, round actuator; the height matters: it reaches just up into the keypad's dome. The model picks the height and prints it) | **Yes** (MEASURE) | ₹20–50 (est.) |
| **Wires to the bay** | 30 AWG wire-wrap wire (10 short lengths: soldered to the switches' legs under their printed carriers, then along the ring's groove) | No | ₹100–200 (est.) |

No switch board: the face curves round the bar, so the switches sit in **2 printed carriers** (their legs through the carrier, the wires soldered underneath).

## The electronics (in the capsule under the bar)

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Microcontroller** | **ESP32-C3 Super Mini** (22.52 × 18 mm, USB-C): Bluetooth LE and a CAN controller | **Yes** (MEASURE its thickness) | ₹250–450 (est.) |
| **CAN transceiver** | **SN65HVD230 chip, SOIC-8 (SN65HVD230DR)** on a **SOIC-8 adapter board** (about 10 × 12 mm), + a **100 nF** capacitor; stuck to the ESP32's bare back with foam tape (the smallest bay). No terminator on it (the dash bus has its two). Or, with `can_board` = "module", the common SN65HVD230 module (the dash's 3-pack has a spare; remove its 120 Ω resistor; the capsule is then wider and deeper) | **Yes** (MEASURE the adapter) | ₹60–150 (est.) for the chip, adapter and capacitor |
| **Cable to the dash** | 4-core cable (shielded is better), 1–1.5 m, and a **GX12 6-pin plug** (the dash's expansion slots) | **Yes** (through the capsule's rubber plug: a 4.8 mm cable) | ₹150–350 (est.) |
| **Back button** | a **6 × 6 × 5 mm tactile switch** (the model picks the height; through-hole) on a small piece of perfboard (about 9 × 13.5 mm) at the capsule's back | **Yes** (MEASURE) | ₹10–30 (est.) |
| **Status LEDs** | **2 × 3 mm LEDs** (green: power; blue: Bluetooth / status) + **2 × 1 kΩ** resistors, on the same small board | **Yes** (MEASURE their length: 5.3 mm from the board to the tip) | ₹10–30 (est.) |
| **Without the dash** | a USB-A plug or an old USB cable to cut (5 V from the bike's USB socket) | No | ₹50–100 (est.) |
| Foam tape, heat shrink | | No | ₹50–100 (est.) |

## Hardware

- 1 × M2.5 heat-set insert (3.6 mm hole, 4 mm long) + 1 × **M2.5 × 8 socket cap**: the front screw that closes the collar, from underneath;
- a **2 mm steel pin, 19 mm long** (or an M2 × 20 screw): the hinge at the back;
- a 1 mm self-adhesive rubber strip, inside both halves of the ring (in the top half it also holds the switch carriers in);
- clear silicone (the wire slot into the capsule).

About ₹100–250 (est.).

## Printing

About 24 g of ASA or PETG and 3 g of TPU (the keypad, the capsule's plug, the back pad and the USB-C plug): about ₹150–400 (est.) from a print service.

## Rough total

About **₹750–1,700 (est.)** with printing (the transceiver chip is cheaper than the module).

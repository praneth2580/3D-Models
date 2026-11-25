# Components: what the remote is built (and modelled) around

**The printed parts are modelled around the items marked "Model fits this".** None has a published drawing: measure yours and set the sizes in `handlebar_remote.scad` (the MEASURE lines) before printing.

**Prices:** estimates (not checked on a listing), marked (est.). Where to buy each item, with search links at the Indian stores: the project's page on the website ("What to buy").

## The control collar (on the bar)

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Joystick** | **5-way navigation switch, 10 × 10 mm, about 7 mm tall** (up, down, left, right, press). The easiest source is the common "5-way navigation button module" (5D rocker joystick module): take its switch off. Or buy the switch alone ("5-way tactile switch 10x10") | **Yes** (MEASURE) | ₹60–150 (est.) |
| **Buttons** | **2 low tactile switches, 6 × 6 × 3.5 mm** (through-hole) | **Yes** (MEASURE) | ₹20–50 (est.) |
| **Switch board** | a piece of perfboard, 14 × 30 mm | **Yes** | (from a ₹50–100 sheet) |
| **Cable to the box** | **8-core cable**, 26 AWG (an alarm or flat-to-round 8-core cable, about 4.5–5 mm across), about 1 m | **Yes** (a 4.8 mm hole) | ₹50–150 (est.) |

**Hardware:** 4 × M2 heat-set inserts (3.2 mm hole) + 4 × M2 × 6 countersunk screws (the face plate); 2 × M3 heat-set inserts (4.2 mm hole) + 2 × M3 × 8 screws (the collar's halves); a 1 mm rubber strip (inside the ring); clear silicone (the cable hole). About ₹80–200 (est.).

## The electronics box

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Microcontroller** | **ESP32-C3 Super Mini** (22.52 × 18 mm, USB-C): Bluetooth LE and a CAN controller | **Yes** | ₹250–450 (est.) |
| **CAN transceiver** | **SN65HVD230 module** (the dash's 3-pack has a spare). Remove its 120 Ω resistor | **Yes** (MEASURE) | ₹150–300 (est.), or the dash's spare |
| **Cable to the dash** | 4-core cable (shielded is better), 1–1.5 m, and a **GX12 6-pin plug** (the dash's expansion slots) | No | ₹150–350 (est.) |
| **Without the dash** | a USB-A plug or an old USB cable to cut (5 V from the bike's USB socket) | No | ₹50–100 (est.) |
| Foam tape, hook-up wire, heat shrink, zip ties | | No | ₹100–200 (est.) |

**Hardware:** 4 × M2 heat-set inserts (3.2 mm hole) + 4 × M2 × 8 screws (the lid); clear silicone (the 2 cable holes).

## Printing

About 25 g of ASA or PETG and 2 g of TPU (the keypad and the box's gasket): about ₹200–450 (est.) from a print service.

## Rough total

About **₹900–1,900 (est.)** with printing; less with the dash's spare transceiver.

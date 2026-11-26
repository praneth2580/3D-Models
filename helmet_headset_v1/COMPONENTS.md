# Components: what the headset is built (and modelled) around

**The printed parts are modelled around the items marked "Model fits this".** The neckband has no published drawing or teardown: open it, measure its board and battery, and set the sizes in `helmet_headset.scad` (the MEASURE lines) before printing.

**Prices:** estimates (not checked on a listing), marked (est.). Where to buy each item, with search links at the Indian stores: the project's page on the website ("What to buy").

## The neckband (the electronics)

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Neckband** | **boAt Rockerz 255 Pro+** (Bluetooth 5.0, IPX7, one mic, per boAt's manual). Any neckband works once you've measured it | **Yes** (MEASURE its board and battery) | ₹1,100–1,300 (est.; Smartprix showed ₹1,199 in Nov 2025) |
| **Battery** (only if the neckband's own doesn't fit) | **502540 LiPo, 3.7 V, about 500 mAh, with a protection board** (40 × 25 × 5 mm) | **Yes** | ₹150–300 (est.) |
| **Mic capsule** (only if the neckband's mic is an analog MEMS mic) | 6 × 2.7 mm electret capsule + a 2.2 kΩ resistor | **Yes** (the mic cup) | ₹10–40 (est.) |

## Sound

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Speakers** | **2 × 40 mm, 32 Ω speakers**, about 5.5 mm thick (helmet speakers, or bare 40 mm 32 Ω mylar speakers). Not 8 Ω | **Yes** (MEASURE: `spk`) | ₹100–600 the pair (est.) |
| **Hook-and-loop dots** | self-adhesive Velcro coins, about 40 mm | No | ₹50–150 (est.) |
| **Foam windscreen** | lapel-mic foam cover, about 10–13 mm | No | ₹50–150 for a pack (est.) |

## The pod

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Switches** | **3 tactile switches, 6 × 6 × 7 mm** (through-hole, round actuator; the height matters) | **Yes** | ₹10–30 (est.) |
| **Switch board** | perfboard, a 50 × 28 mm piece | **Yes** | (from a ₹50–100 sheet) |
| **Inserts and screws** | 4 × M2 heat-set inserts (3.2 mm hole, 4 mm long) + 4 × M2 × 6 countersunk screws | **Yes** | ₹50–150 (est.) |
| **VHB tape** | **3M VHB 4910 or 5952, 1.1 mm** (a short length, 25 mm wide or wider) | **Yes** (`vhb_t`) | ₹150–400 (est.) |
| **Silicone** | neutral-cure clear silicone (the cable holes; dabs on the shell) | No | ₹100–200 (est.) |

## Cables and boom

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Speaker cable** | thin 4-core cable, about 4 mm (an old USB cable works), about 1 m | **Yes** (a 4.2 mm hole) | ₹0–100 (est.) |
| **Mic cable** | thin shielded cable, about 3 mm (an old 3.5 mm audio cable works), about 60 cm | **Yes** (a 3.4 mm hole) | ₹0–100 (est.) |
| **Boom** | 2 mm aluminium craft (armature) wire, 15 cm, and 5 mm heat-shrink | **Yes** (`boom_d`) | ₹50–150 (est.) |
| **Wire** | 28–30 AWG wire for the switches | No | ₹50–150 (est.) |

## Printing

About 30–35 g of PETG or ASA and 5 g of TPU (the keypad and the USB plug): about ₹200–450 (est.) from a print service.

## Total

About **₹2,000–4,000** (est.) with printing, most of it the neckband. Less if you reuse old cables and the neckband's own battery.

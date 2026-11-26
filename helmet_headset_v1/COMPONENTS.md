# Components: what the headset is built (and modelled) around

**The neckband gives all the electronics and sound parts: its board, battery, both speakers and its mic.** Besides it you only buy small hardware bits. The printed parts are modelled around the items marked "Model fits this". The neckband has no published drawing or teardown: open it, measure its board, battery and speakers, and set the sizes in `helmet_headset.scad` (the MEASURE lines) before printing.

**Prices:** estimates (not checked on a listing), marked (est.). Where to buy each item, with search links at the Indian stores: the project's page on the website ("What to buy").

## The neckband: everything electronic and everything you hear

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Neckband** | **boAt Rockerz 255 Pro+** (Bluetooth 5.0, IPX7, one mic, 10 mm drivers, per boAt). Used whole: its board (in the pod), its battery (in the pod), its 2 speakers (in the ear pockets), its mic (on the boom). Any neckband works once you've measured it | **Yes** (MEASURE its board, battery, speakers and mic) | ₹1,100–1,300 (est.; Smartprix showed ₹1,199 in Nov 2025) |

## Small bits to buy

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Switches** | **3 tactile switches, 6 × 6 × 7 mm** (through-hole, round actuator; the height matters), wired across the neckband's own buttons | **Yes** | ₹10–30 (est.) |
| **Switch board** | perfboard, a 50 × 28 mm piece | **Yes** | (from a ₹50–100 sheet) |
| **Inserts and screws** | 4 × M2 heat-set inserts (3.2 mm hole, 4 mm long) + 4 × M2 × 6 countersunk screws | **Yes** | ₹50–150 (est.) |
| **VHB tape** | **3M VHB 4910 or 5952, 1.1 mm** (a short length, 25 mm wide or wider) | **Yes** (`vhb_t`) | ₹150–400 (est.) |
| **Silicone** | neutral-cure clear silicone (the cable holes; dabs on the shell) | No | ₹100–200 (est.) |
| **Boom** | 2 mm aluminium craft (armature) wire (or a stiff copper wire), 15 cm, and 5 mm heat-shrink | **Yes** (`boom_d`) | ₹50–150 (est.) |
| **Foam windscreen** | a lapel-mic foam cover (or a scrap of open-cell foam) | No | ₹0–150 (est.) |
| **Wire** | 28–30 AWG wire (the switches; extending the mic and speaker wires) | No | ₹50–150 (est.) |
| **Cables** | an old USB cable (4-core, for the speakers, about 1 m) and an old audio cable (shielded, for the mic, about 60 cm) | **Yes** (4.2 and 3.4 mm holes) | free (old cables) |

## Optional (only if needed)

| Part | When | Model fits this? | Price |
|---|---|---|---|
| 2 × **40 mm, 32 Ω speakers**, about 5.5 mm thick | only if the earbuds' speakers are too quiet at speed (try them first). Not 8 Ω | **Yes** (`spk_d` 40, `spk_t` 5.5) | ₹100–600 the pair (est.) |
| **502540 LiPo**, 3.7 V about 500 mAh, with a protection board | only if the neckband's own battery can't fit the pod | **Yes** (40 × 25 × 5) | ₹150–300 (est.) |
| **6 mm electret capsule** + 2.2 kΩ resistor | only if the neckband's MEMS mic can't be moved (see the README) | **Yes** (the mic cup) | ₹10–40 (est.) |

## Printing

About 30 g of PETG or ASA and 5 g of TPU (the keypad and the USB plug): about ₹200–450 (est.) from a print service.

## Total

About **₹1,800–3,200** (est.) with printing, most of it the neckband.

# Components: what the headset is built (and modelled) around

**The neckband gives all the electronics and sound parts: its board, battery, both speakers and its mic.** Besides it you only buy 3 small magnetic connectors (so the pod and the back box clip off their cradles for cleaning) and small hardware bits. The printed parts are modelled around the items marked "Model fits this". By default the pod has room for a board up to 50 × 12 mm and a battery up to 35 × 20 × 6 mm (300 mAh class) or a long thin one up to 12 × 50 mm, stacked: that fits most cheap neckbands, not all (no maker publishes the insides, so these are estimates). If yours is bigger, open it, measure its board and battery and set them in `helmet_headset.scad` (the MEASURE lines): the pod grows. Always measure the speakers.

**Prices:** estimates (not checked on a listing), marked (est.). Where to buy each item, with search links at the Indian stores: the project's page on the website ("What to buy").

## The neckband: everything electronic and everything you hear

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Neckband** | **boAt Rockerz 255 Pro+** (Bluetooth 5.0, IPX7, one mic, 10 mm drivers, per boAt). Used whole: its board (in the pod), its battery (in the pod), its 2 speakers (in the ear pockets), its mic (on the boom). Most other neckbands fit the pod too | **Yes** (check its battery: boAt lists 300 mAh for this model, likely a 602030-size cell, which fits the default room; check it. Measure its speakers and mic) | ₹1,100–1,300 (est.; Smartprix showed ₹1,199 in Nov 2025) |

## Small bits to buy

| Part | Exact item | Model fits this? | Price |
|---|---|---|---|
| **Connectors** | **3 × 5-pin magnetic pogo connector, 2.54 mm pitch** (a male + female pair each; spring pins, magnets that mate one way only; 5 V 1 A per pin): 2 for the pod, 1 for the back box (2 with the battery in the pod). [Probots](https://probots.co.in/5p-magnetic-spring-loaded-pogo-pin-male-female-connector-socket-2-54-mm-pitch-dip.html) ₹239 each (checked 2026-11-27); the same item is common at other Indian stores | **Yes, once measured**: the size isn't published (`mag_l` 18, `mag_h` 5, `mag_m` 6, `mag_f` 4.5, `mag_tail` 3: MEASURE) | ₹717 |
| **Epoxy** | 5-minute epoxy (or neutral-cure silicone): glues the connectors in, pots the cradles' pockets over the solder tails | No | ₹80–200 (est.) |
| **Switches** | **3 tactile switches, 6 × 6 × 7 mm** (through-hole, round actuator; the height matters), wired across the neckband's own buttons: one under the play/call button, two under the volume rocker | **Yes** | ₹10–30 (est.) |
| **Switch board** | perfboard, a piece about 27 × 30 mm | **Yes** | (from a ₹50–100 sheet) |
| **Foam** | thin double-sided foam tape and a scrap of soft foam: pack the board and the battery so they don't rattle, and shim the board so its USB-C lines up with the hole | No | ₹50–150 (est.) |
| **Inserts and screws** | 4 × M2 heat-set inserts (3.2 mm hole, 4 mm long) + 4 × M2 × 6 countersunk screws | **Yes** | ₹50–150 (est.) |
| **VHB tape** | **3M VHB 4910 or 5952, 1.1 mm** (about 30 cm, 25 mm wide or wider: the 2 cradles, and thin strips under the back channel's flanges) | **Yes** (`vhb_t`) | ₹150–400 (est.) |
| **Silicone** | neutral-cure clear silicone (round the cables where they leave the cradles; dabs on the shell) | No | ₹100–200 (est.) |
| **Boom** | 2 mm aluminium craft (armature) wire (or a stiff copper wire), 15 cm, and 5 mm heat-shrink | **Yes** (`boom_d`) | ₹50–150 (est.) |
| **Foam windscreen** | a lapel-mic foam cover (or a scrap of open-cell foam) | No | ₹0–150 (est.) |
| **Wire** | 28–30 AWG wire (the switches; extending the mic and speaker wires) | No | ₹50–150 (est.) |
| **Cables** | an old USB cable (4-core, for the speakers, about 1 m) and an old audio cable (shielded, for the mic, about 60 cm) | **Yes** (4.2 and 3.4 mm holes) | free (old cables) |
| **Battery lead** (back box) | a thin 2-core cable, about 50 cm (26 AWG is plenty), from the back box's cradle to the pod's (the connectors let the box come off) | **Yes** (`bat_cable`, 3 mm) | ₹10–30 (est.) |

## Optional (only if needed)

| Part | When | Model fits this? | Price |
|---|---|---|---|
| 2 × **40 mm, 32 Ω speakers**, about 5.5 mm thick | only if the earbuds' speakers are too quiet at speed (try them first). Not 8 Ω | **Yes** (`spk_d` 40, `spk_t` 5.5) | ₹100–600 the pair (est.) |
| **602030 LiPo**, 3.7 V about 300 mAh, with a protection board | only if the neckband's own battery is a long curved cell that can't fit the pod | **Yes** (30 × 20 × 6) | ₹150–300 (est.) |
| **USB-C charging breakout** (6-pin, with 5.1 kΩ CC resistors) | only if the board's charging socket is on its side or is micro-USB, so it can't line up with the pod's hole: glue it in the hole, wire it to the board's +5 V and ground pads | **Yes** (the USB-C hole) | ₹20–60 (est.) |
| **6 mm electret capsule** + 2.2 kΩ resistor | only if the neckband's MEMS mic can't be moved (see the README) | **Yes** (the mic cup) | ₹10–40 (est.) |

## Printing

About 46 g of PETG or ASA and 7 g of TPU with the back box and the 2 cradles (the keypad, the USB plug, the back box's cover and its channel are TPU; the rocker's pivot post is a tiny PETG part): about ₹270–550 (est.) from a print service.

## Total

About **₹2,650–4,100** (est.) with printing, the back box and the cradles, most of it the neckband and the 3 connectors (₹717).

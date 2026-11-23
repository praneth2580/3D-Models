# Components: what the dash is built (and modelled) around

**The printed parts will be modelled around the parts marked "Model fits this".** Buy exactly those: another make of "the same" module usually has a different board size or hole pattern, and won't fit. Parts marked "Any equivalent" can come from any seller.

**Where to buy:** Amazon.in or Flipkart first, as the owner prefers. For a few modules, the Indian electronics stores (Robu.in, Hubtronics, Evelta) list the same board for a fraction of the Amazon price: noted where it matters.

**Prices:** as listed on 2026-11-23 (they change often). "(est.)" means not checked on a listing.

## Display head (on the handlebar)

| Part | Exact item | Model fits this? | Where | Price |
|---|---|---|---|---|
| **Display** | **Waveshare ESP32-S3 2.8" round display board, 480 × 480**: `ESP32-S3-Touch-LCD-2.8C` (touch) or `ESP32-S3-LCD-2.8C` (no touch). Touch isn't needed on a bike (gloves); the INFO button and the dash bus do the work | **Yes**: the housing, the window and the screw bosses are modelled on this board | Amazon.in: only a rebadged `ESP32-S3-LCD-2.8C` ("UeeKKoo"), [₹9,224](https://www.amazon.in/ESP32-S3-Development-Resolution-Dual-Core-Processor/dp/B0DXF39GPM). **Much cheaper:** [Hubtronics](https://hubtronics.in/esp32-s3-touch-lcd-2.8c) about ₹3,677 incl. GST, [Evelta](https://evelta.com/esp32-s3-2-8inch-480x480-capacitive-touch-round-display-development-board) ₹4,396, [Robu](https://robu.in/?p=2382855) | ₹3,700–9,200 |
| **GPS** | **u-blox NEO-M8N module with a 25 × 25 mm ceramic active patch antenna** (GPS + GLONASS) | **Yes**: the antenna sits under the housing's top, facing the sky | Amazon.in: Robocraze NEO-M8N with active ceramic antenna (about ₹1,731), or [Techtonics NEO-M8N with ceramic active antenna](https://www.amazon.in/m8n-gps-module/s?k=m8n+gps+module) (₹1,490). Avoid the "for Pixhawk" round-puck versions (drone GPS with compass, different size) | ₹1,490–1,750 |
| **Light sensor** (auto brightness) | **BH1750 board, GY-302** | **Yes**: a small window in the housing | Amazon.in, search "BH1750 GY-302" | ₹120–250 (est.) |
| **Dash bus transceiver** | **SN65HVD230 module**, the common blue board (HiLetgo 3-pack: one here, two in the interface box) | **Yes**: a slot in the housing | Amazon.in: [HiLetgo 3 pcs SN65HVD230](https://www.amazon.in/HiLetgo-SN65HVD230-Transceiver-Communication-Protection/dp/B07ZT7LLSK) (about ₹1,502 for 3) | ₹1,500 for 3 |
| **Tell-tale LEDs** (brow option) | **8 × 5 mm addressable RGB LEDs, WS2812B family**: XINGLIGHT XL-504RGBC-WS2812B or WS2812D-F5, diffused or clear | **Yes**: 5.2 mm holes behind the icons | Amazon.in: "WS2812 5MM LED (5 Pcs) XL-504RGBC-WS2812B" (2 packs) | ₹300–700 (est.) |
| **Cable to the interface box** | 4-core shielded cable, 0.5 mm², about 1 m, and a **GX12 4-pin** plug and panel socket | **Yes** (the GX12 socket's 12 mm hole) | Amazon.in: [GX12 aviation connector sets](https://www.amazon.in/10Sets-Aviation-Connector-Diameter-Circular/dp/B0CPV765NQ); cable: any | ₹300–600 (est.) |

**Tell-tale diffusers:** print `telltale_diffusers` in white or natural PETG, or cut 8 squares (9.2 × 11 mm) from thin white translucent plastic.

**Hardware for the display head and clamp** (any equivalent; Amazon.in, or Nagdevi Street):
- 4 × M2 × 6 screws (display to carrier);
- 4 × M3 heat-set inserts (5.7 mm long, 4.2 mm hole), 2 × M3 × 8 and 2 × M3 × 12 countersunk screws;
- **on the bar (cradle):**
  - 2 × M4 heat-set inserts (8 mm long, 5.6 mm hole) and 2 × M4 × 12 bolts (cover to cradle);
  - 4 × M4 × 20 bolts and nuts (the 2 bar clamps);
- **on a stalk:** 1 × M5 × 20 bolt with a nyloc nut (the joint), 2 × M4 × 20 bolts and nuts (the clamp);
- a 1 mm rubber strip for inside the clamp;
- 0.8 mm closed-cell foam sheet (or print `lip_gasket` in TPU);
- double-sided foam tape.

About ₹300–600 (est.).

## Interface box (behind the headlamp)

| Part | Exact item | Model fits this? | Where | Price |
|---|---|---|---|---|
| **Microcontroller** | **Espressif ESP32-C6-DevKitC-1-N8** (the official Espressif board: two CAN controllers) | **Yes**: the board's outline and header rows | Amazon.in: [Espressif ESP32-C6-DevKitC-1-N8](https://www.amazon.in/Espressif-ESP32-C6-DevKitC-1-N8-Development-Board/dp/B0BRMSDR4R) (₹2,439–2,650). Robu and Hubtronics usually list it for much less: check | ₹800–2,650 |
| **CAN transceivers** (bike bus, dash bus) | **SN65HVD230 modules** (2 of the HiLetgo 3-pack above). **Remove the 120 Ω resistor** from the bike-bus one | **Yes** | (above) | (above) |
| **Motion sensor** (lean angle, g-force) | **MPU-6050 board, GY-521** (the common one). Upgrade later: BNO085 (does the angle maths itself, about ₹2,900) | **Yes**: GY-521 size and holes; fixed to the box, which is fixed to the frame | Amazon.in, search "GY-521 MPU6050" (about ₹249) | ₹250 |
| **12 V → 5 V supply** | **Envistia 12 V to 5 V 3 A, epoxy-sealed** (8–24 V in, bare wires) | **Yes**: a pocket in the box | Amazon.in: [Envistia 12V to 5V 3A waterproof](https://www.amazon.in/Step-Down-Waterproof-Miniature-Converter-Supply/dp/B07MYPCM73) (about ₹1,142) | ₹1,142 |
| **OBD+ port** | **STAR055 16-pin OBD-II female connector with shell, terminals and screws** (made in India) | **Yes**: its panel cut-out and screw holes | Amazon.in: [STAR055 OBD2 female connector](https://www.amazon.in/StarAutolink-Female-Connector-Diagnostic-Terminals/dp/B0FN4GV5YL) | ₹300–700 (est.) |
| **Expansion slots** (3) | **GX12 6-pin panel sockets** (12 mm thread) with **GX12 metal dust caps** | **Yes**: 12 mm holes, nut clearance | Amazon.in: [panel-mount 12 mm 6-pin aviation connectors](https://www.amazon.in/Panel-Mounted-Thread-Aviation-Connectors/dp/B00OK6G6QW), [GX12 dust caps with chain](https://www.amazon.in/Metal-Connector-Protective-Waterproof-Dust-Proof/dp/B0C2M3KDRH) | ₹500–900 (est.) |
| **Air temperature** | **DS18B20 waterproof probe**, 1 m lead | No: it goes outside the box, in the shade | Amazon.in or Flipkart, search "DS18B20 waterproof" | ₹150–300 (est.) |
| Self-resetting fuses, 1 A (4), inline blade fuse holder with a 3 A fuse, TVS diode, a few resistors | | No | Amazon.in, or Lamington Road | ₹200–400 (est.) |
| **Bike-side plug** (adapter harness) | The mating half of the bike's **18-pin cluster connector** | **To find**: its part number isn't known yet. Take one from a used cluster if needed | (phase 1 photos will identify it) | (unknown) |

**About the GX12 sockets:** they keep dust and splashes out when plugged or capped, but they aren't rated for pressure washing. If the box ends up where water hits it directly, M12 IP67 sockets (more expensive) are the upgrade; the model will have a setting for either.

## Phase 1 (the logger)

| Part | Exact item | Where | Price |
|---|---|---|---|
| ESP32-C6-DevKitC-1-N8 | (the interface box's board, above) | | |
| SN65HVD230 module | (one of the 3-pack, above) | | |
| NEO-M8N GPS with ceramic antenna | (the display head's GPS, above) | | |
| microSD module (SPI, 3.3 V) + microSD card 8–32 GB | Any equivalent | Amazon.in or Flipkart, search "micro SD card module SPI" | ₹100–200 (est.) + card |
| **Royal Enfield 6-pin → 16-pin OBD-II adapter** | **Check your bike's service socket first** (black or red, 6 pins). Amazon.in: ["16 PIN to 6 PIN OBD cable for Royal Enfield Himalayan and Hunter"](https://www.amazon.in/Diagnostic-Connector-Adapter-Enfield-Himalayan/dp/B0BRZWPHYC). The Hunter is on the same platform as the Meteor, but **ask the seller to confirm the Meteor 350**. One Flipkart scanner cable for Royal Enfield bikes was confirmed by its seller **not** to fit the Meteor | Amazon.in | ₹1,000–1,900 (est.) |
| 16-pin OBD-II **male** plug to open wires | iKKEGOL J1962 male to open wire | Amazon.in: [iKKEGOL OBD-II male to open wire](https://www.amazon.in/iKKEGOL-Connector-Diagnostic-Extension-Pigtail/dp/B0828YHWFG) | ₹400–1,000 (est.) |
| 12 V → USB car charger + USB-C cable | Any equivalent | Amazon.in or Flipkart | ₹200–400 (est.) |

## Rough total

| | Amazon.in / Flipkart only | Using Indian electronics stores for the display and the ESP32-C6 |
|---|---|---|
| Phase 1 logger | about ₹7,300–9,800 | about ₹5,600–8,100 |
| The whole dash (phase 1 parts reused) | about ₹20,000–23,000 | about ₹13,000–16,000 |

Plus printing (the two housings, the cradle and the brow), about ₹600–1,500 (est.), and the bike-side plug. All estimates, from listings on 2026-11-23.

## Not chosen, and why

- **2.1" round display:** you chose the bigger one.
- **ESP32-S3 in the interface box:** it has one CAN controller; the C6 has two (bike bus and dash bus) with no extra chip.
- **"For Pixhawk" GPS pucks:** they carry a compass and a drone mount, and don't fit the housing.
- **BNO085 motion sensor:** better, but about ₹2,900 against ₹250. The GY-521 is enough to start; the box will take either.

# Shopping list and cost: India (Mumbai)

This covers one complete set (dock + case), assuming:
- no 3D printer (the parts are printed by a service);
- you do the soldering and assembly yourself;
- you already have a soldering iron, solder and a multimeter.

**Prices:**
- Where a link is given, the price is as listed on 2026-11-20 on Amazon.in, Robu or the seller linked. Prices change often, so recheck before ordering.
- Prices marked "est." are estimates.
- Delivery is extra unless noted.

## Summary

| | Cost |
|---|---|
| **Option A: dock board hand-wired on perfboard** | **≈ ₹3,400–5,000** |
| **Option B: dock board on an ordered PCB** | **≈ ₹4,100–7,300** (Option A + ₹700–2,300) |

The case, the dock, the printed parts and the components are identical. Only the dock board (and, if you like, the pin and pad strips) differs. See [`WIRING.md`](WIRING.md).

3D printing is the biggest variable. At ₹5/g it is about ₹1,500, but at ₹8/g it would be about ₹2,500, which pushes Option A just over ₹5,000. Get 2–3 quotes first.

## Parts

| Part | Where | Price |
|---|---|---|
| **3D printing**, about 340 cm³ of parts, roughly 280–320 g as printed. PETG or ASA; clamps 100 % infill, the rest 4 walls and 30–40 % infill. Skip `bar_shim` (see below) | A Mumbai FDM service at about ₹5–6/g: [Robu (EasyMech)](https://robu.in/?p=901845), [Zbotic](https://zbotic.in/3d-printing-service/), [iamRapid](https://iamrapid.com/3d-printing-services/), [Makenica (Mumbai)](https://makenica.com/3d-printing-services-in-mumbai). Upload the STLs for an exact price | ₹1,500–2,000 |
| AO3401A P-MOSFET × 2 (1 spare) | [Robu](https://robu.in/?s=AO3401&post_type=product), ₹4.47 each | ₹9 |
| 2N7002 MOSFET × 2 | [Robu](https://robu.in/?s=2N7000&post_type=product), ₹2.80 each | ₹6 |
| USBLC6-2SC6 USB ESD (ST) × 1 | [Robu](https://robu.in/?s=USBLC6&post_type=product), ₹20 | ₹20 |
| Resettable fuse 1.5 A (ASMD1210-150) × 2 | [Robu](https://robu.in/?s=resettable+fuse+1.5A&post_type=product), ₹4.98 each | ₹10 |
| 3 mm LEDs: yellow, green, red (2 each) | [Robu](https://robu.in/?s=3mm+led+green&post_type=product), about ₹1 each | ₹7 |
| Resistors (1 k × 4, 10 k, 100 k × 2) + 10 µF capacitor | Lamington Road or Robu | ₹25 (est.) |
| Perfboard 8 × 12 cm, double-sided (Option A) | [Robu](https://robu.in/?s=zero+pcb&post_type=product), ₹114 | ₹114 |
| Robu shipping | | ₹50–100 (est.) |
| **P75-B1 pogo pins, 2 packs of 5** (all 10 used, in 2 rows). A third pack for spares is optional, ₹199 | [Amazon.in](https://www.amazon.in/dp/B0FBMK81HZ), ₹199 per pack | ₹398 |
| Thermostat KSD9700, **45 °C, NC** | [iFuturetech](https://ifuturetech.org/product/ksd9700-250v-5a-plastic-thermostatic-temperature-switch-nc-45-c/) ₹25 + delivery, or Lamington Road | ₹40–60 (est.) |
| 16 mm cam lock (quarter turn; confirm with the seller) | [Amazon.in](https://www.amazon.in/dp/B0HDJVVXCW) (the same lock is ₹275 on Flipkart) | ₹270 |
| 14 × 9 mm key steel (DIN 6885), cut into 15 mm (bolt) + 10 mm (bearing block) | A bearing or power-transmission shop; ask them to cut it | ₹100–200 (est.) |
| 3.2 mm drill bit + M3 bolt, nut and a 4 mm OD spacer (crank pin) | Hardware shop | ₹40–60 (est.) |
| M3 heat-set inserts (about 14) | Lamington Road or Nagdevi Street (or [Amazon, 50 pcs ₹289](https://www.amazon.in/dp/B0DZFR748C)) | ₹60–100 (est.) |
| M3 / M5 screws, nuts, washers | Nagdevi Street | ₹150–200 (est.) |
| 4 rubber grommets with sleeves (bike side-panel type) | Bike spares shop | ₹60–120 (est.) |
| 1.5 mm silicone O-ring cord | Rubber or seal shop | ₹50–100 (est.) |
| 2 mm **polycarbonate** offcut for the window (not acrylic: it cracks) | Plastic-sheet dealer | ₹100–200 (est.) |
| Araldite Klear 10 g × 3 (window bond, potting, bearing block) | [Amazon.in](https://www.amazon.in/dp/B0BXY85PXH), ₹68 each | ₹200 |
| Case lead: USB-A to 90° USB-C (or [90° micro-USB](https://www.amazon.in/dp/B0DTJZP5ZS), ₹249) | [Amazon.in](https://www.amazon.in/dp/B0GKQ4VF41) | ₹141–249 |
| Bike lead: any USB-A cable, to cut | Any | ₹100–140 |
| Bike USB supply, only if the bike has no USB socket | [12 V handlebar USB charger](https://www.amazon.in/dp/B0HNTBGQBT); wire it after the ignition | ₹0–249 |
| Bar shims: strips of old bicycle inner tube | | ₹0 |
| *Optional:* thermal pad 0.5 mm (better heat sensing) | [Amazon.in](https://www.amazon.in/dp/B0DGXFS866) | ₹0–199 |
| **Total, Option A** | | **≈ ₹3,400–5,000** |

## One-piece dock base (`mount = "merged"`): changes

Only if you print `dock_base` instead of `base_plate` + `receiver` (see the README). Net change about **+₹250–650**.

| Item | Where | Price |
|---|---|---|
| Leave out: the 4 rubber grommets with sleeves | | −₹60–120 |
| Extra printing: about 55 cm³ more part (the walls and the full-size floor), plus supports under the floor. Its own shoe and back cover replace the standard ones, at the same size | The same print service | +₹250–500 (est.) |
| 4 × M5 round spacers, 8 mm OD, 10 mm long (aluminium or steel), plus 4 × M5 plain washers to make 11 mm | Lamington Road or Nagdevi Street | +₹40–80 (est.) |
| 4 × M5 rubber washers, about 2 mm thick, and 4 × M5 × 15 large (DIN 9021) steel washers | Nagdevi Street, or a rubber/seal shop | +₹30–60 (est.) |
| 2 mm neoprene or EPDM sheet offcut, for the 2 pads (24 × 50 mm each). Or print `iso_pad` in TPU 95A | Rubber/seal shop | +₹30–80 (est.) |

This can push the top of Option A's range over ₹5,000 (to about ₹5,600). Ask the print service to quote `dock_base` at 3 walls and 20–25 % infill to keep it down.

## Option B: PCB extras

| Item | Where | Price |
|---|---|---|
| PCBs: dock board (21.5 × 14.5 mm), plus the pin strip and pad strip if you want them as PCBs too. 2-layer, 1.6 mm | [Lion Circuits](https://lioncircuits.com/) (Indian fab): ₹799 per 5 boards of one design. Its 1.6 mm fixed thickness is what the pocket assumes. JLCPCB is the alternative (cheap boards, but international delivery and duty) | ₹800 (dock board only, or all three on one panel if the fab allows) to ₹2,400 (three separate designs), plus delivery |
| ENIG (gold) finish on the pad strip | The fab's quote | Extra; check the quote |
| Perfboard not needed | | −₹114 |
| **Extra over Option A** | | **≈ ₹700–2,300** |

You get 5 of each board, so spares or a second set cost nothing more.

## Optional: printed lock instead of the cam lock

If you print the lock ([`PRINTED_LOCK.md`](PRINTED_LOCK.md)), leave out the ₹270 cam lock, the 3.2 mm drill bit and the crank-pin screw and spacer, and add:

| Item | Where | Price |
|---|---|---|
| Printing the lock parts: shuttle, 4 wafers, key, lifter, cover (about 9 cm³, 12 g). They replace `lock_yoke` and `lock_cover`, and you print the printed-lock version of the dock (`receiver_plock` or `dock_base_plock`) instead of the standard one, at the same size | Add them to the main print order | ₹60–120 (est.) |
| 4 small compression springs: 3 mm OD, 0.3 mm wire, about 8 mm long, **9 coils or fewer** (stainless) | A spring assortment kit (Amazon.in, "mini compression spring assortment"), or Lamington Road | ₹100–300 (est.) |

The total is a little under the store lock. Choose it for your own key code, no drilling and a key you can reprint, not to save money.

## Buy locally to save money

| Part | Where |
|---|---|
| Resistors, LEDs, capacitor, hook-up wire (28–26 AWG) | Lamington Road |
| Screws, nuts, inserts | Nagdevi Street |
| Grommets | A bike spares shop: side-panel or fairing grommets |

## Before ordering

1. **Cam lock:** neither listing states the turn angle. You need a **quarter turn (90°)** whose key is removable only when locked (see the README's *Lock (SELECT)*). Confirm with the seller.
2. **Pogo pins:** measure the P75 barrel before ordering a pin-strip PCB, and size its holes to suit (about 1.1–1.2 mm).
3. **Phone cable:** check the 90° plug head is no more than 7 mm (USB-C) or 8 mm (micro-USB), measured from the phone's edge. See `WIRING.md`.

## Sources (non-listing figures)

- 3D printing rates: [Zbotic guide](https://zbotic.in/custom-3d-printing-service-india-guide/), [IndiaMART FDM listings](https://m.indiamart.com/impcat/fdm-3d-printing.html)
- PCB price: [Lion Circuits](https://lioncircuits.com/)

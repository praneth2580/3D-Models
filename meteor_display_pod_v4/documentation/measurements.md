# Measurements and sources

Every input dimension lives in `scad/parameters.scad`. This file records where each one came from and whether it still needs checking.

**Status key:**
- ✅ from the manufacturer's drawing or another reliable source
- 🟡 estimate: check before the final print
- 🔴 unknown: must be measured on the bike

## Display board — ESP32-2424S012 (sold as "Electrobot ESP32-C3 1.28in")

The board model is confirmed by the "ESP32-2424S012" silkscreen visible in the Amazon listing photo (`reference/listing_screenshots/`). The vendor spec sheet and drawings are in `reference/vendor/`. That folder isn't published, because those are the vendor's files: get the ESP32-2424S012 spec sheet and structure drawing from the board's seller.

| Parameter | Value | Source | Status |
|---|---:|---|---|
| Board outline diameter `board_d` | 37.00 | Vendor structure drawing | ✅ |
| Height including USB tab `board_total_h` | 38.50 | Vendor structure drawing | ✅ |
| USB tab width `board_tab_w` | 14.23 | Vendor structure drawing | ✅ |
| Tab height from shoulder | 3.74 | Vendor structure drawing | ✅ |
| Active display diameter `display_active_d` | 32.4 | Vendor spec sheet ("Φ32.4") | ✅ |
| Operating temperature | −20 … 70 °C | Vendor spec sheet | ✅ |
| Glass front → PCB `glass_to_pcb` | 3.7 (4.0 free / 3.0 pressed) | Measured by another maker ([MagSafe case](https://github.com/mk0000001/ESP32-2424S012-MagSafe-Case)) | ✅ |
| PCB thickness `pcb_t` | 1.2 | Same maker's CAD (modelled, not stated as measured) | 🟡 |
| Display glass diameter `display_glass_d` | 36.0 | Estimate: not published | 🟡 |
| Tallest rear part incl. battery plug `rear_component_h` | 4.0 | Estimate | 🟡 |
| USB-C lateral offset `usb_offset_x` | −2.4 (front view) | Scaled from vendor rear image | 🟡 |
| USB-C centre behind PCB rear face | 1.2 | Other maker's CAD | 🟡 |
| USB cable over-mould `usb_plug_w × usb_plug_h` | 12.5 × 7.0 | Typical cable | 🟡 Measure your own cable |
| Slide switch angle / protrusion | 175° / 1.0 | Scaled from vendor rear image | 🟡 |
| RST / BOOT (front-view angle, radius) | 40°, 16.5 / 135°, 15.0 | Scaled from vendor rear image | 🟡 |
| Battery JST socket | 215°, r 13.5 | Scaled from vendor rear image | 🟡 |

Angles are given as seen from the front: 0° = right, 90° = top. The vendor rear-layout drawing is a back view, so its left and right are mirrored.

## Battery

| Parameter | Value | Status |
|---|---:|---|
| Cell size (t × w × l) | 4 × 20 × 30 (402030, about 200–250 mAh) | 🟡 Default only. Set it to your actual cell. |
| Protection | Use a cell with its own protection PCB | — |

## Bayonet hardware

| Parameter | Value | Status |
|---|---:|---|
| Ball plunger | M4 stainless spring-ball plunger, ball Ø2.5 | 🟡 Check the stroke is at least 0.8 mm (`plunger_stroke_min`) |
| Cover screws | 3 × M2 × 8 socket cap + 3 × M2 × 3 heat-set inserts (Ø3.2 hole) | 🟡 Check the hole size for your insert brand |
| Receiver screws | 3 × M3 × 6–8 thread-forming (for plastic), pan head | — |

## Motorcycle (Royal Enfield Meteor 350)

| Parameter | Value | Status |
|---|---:|---|
| Handlebar diameter at the clamp `bar_d` | 22.2 | 🔴 Not measured. Measure it with calipers. |
| Free straight bar length at the centre `clamp_w` | 22 | 🔴 Measure the gap between the riser clamps and cables |
| Display tilt toward rider `display_tilt` | 40° | 🔴 Set this from your riding position |
| Cup offset / height `cup_offset_y`, `cup_floor_z` | −8 / 26 | 🔴 Check clearance to the instrument cluster, cables and steering lock |

## What to measure, in priority order

1. Handlebar diameter at the mounting point, and the free length there.
2. Your USB-C cable's plug head (width × height of the plastic part).
3. Total board thickness, from the glass front to the tallest rear part with the battery plug fitted.
4. Glass outer diameter.
5. Battery size, if you buy a different one.

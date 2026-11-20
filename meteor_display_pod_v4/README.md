# Meteor 350 display pod — v4

A round, minimal-bezel enclosure for the **ESP32-2424S012** 1.28" round display (sold as "Electrobot ESP32-C3 1.28in"), with a battery and a three-lug quick-release bayonet for the Royal Enfield Meteor 350 handlebar.

> **Website:** https://praneth2580.github.io/3D-Models/meteor_display_pod_v4/ (3D viewer and free downloads). **License:** CC BY-NC-SA 4.0, see the [repository license](../LICENSE.md).

> **Prototype.** It has not been fit-tested, vibration-tested or water-tested. Several dimensions are still estimates; see [documentation/measurements.md](documentation/measurements.md). Don't use it on the road until it passes the checks in [documentation/assembly.md](documentation/assembly.md).

## Layout

```
scad/
  parameters.scad        all dimensions, with source tags + sanity asserts
  lib.scad               helper modules
  front_bezel.scad       outer shell profile, lens seat, display ledge
  display_housing.scad   Part A housing + TPU USB plug
  pcb_mounts.scad        board retainer plate, foam template, board/battery envelopes
  rear_cover.scad        Part B cover: battery bay, gasket seat, bayonet, gasket
  bayonet_lugs.scad      male spigot + lugs + detent dimple
  bayonet_receiver.scad  Part C receiver ring
  handlebar_mount.scad   Part D split clamp + tilted receiver cup
  main.scad              part selector, assembly view, clearance checks
tools/   check.sh, export.sh, stl_check.py
exports/ STL (print orientation) + DXF templates
documentation/ measurements.md, assembly.md, print_settings.md
reference/ vendor spec + drawings, Amazon listing screenshots (kept locally, not published: they are the vendor's files)
archive/v3/ the previous design (kept for reference; it doesn't work, see below)
```

## Main dimensions (defaults)

| | |
|---|---|
| Front diameter / rear diameter | 45 / 52 mm (tapered) |
| Visible pod depth (front face → cover rear) | 20.3 mm |
| Viewing aperture / active display | Ø33.4 / Ø32.4 mm |
| Front ring outside the lens | 4.25 mm per side (v3: 16 mm) |
| Lock | push in, turn 30° clockwise, detent click |

## How it works (short version)

- **Housing (A):** a one-piece front and side wall. A polycarbonate lens is bonded into a recess under a 0.4 mm protective rim. The display presses against a 1 mm ledge behind the lens. There are no front screws.
- **Board retention:** the board has no mounting holes. A printed retainer plate with a foam pad pushes it forward onto the ledge, with holes so the foam doesn't press RST/BOOT. The plate also separates the battery from the electronics.
- **Rear cover (B):**
  - Holds the battery in its own bay with 1 mm of room to swell.
  - Seals to the housing with a flat gasket compressed 30 %.
  - Carries the male bayonet.
  - Three hidden M2 screws hold it on, and their uneven spacing means it fits only one way.
- **Bayonet (B to C):**
  - Three lugs, solidly attached to the spigot, run in L-shaped paths: an axial entry slot, then a 30° circumferential track.
  - The closed track end is the rotation stop, and the track ceiling holds the pod in axially.
  - A metal M4 spring-ball plunger in the receiver pushes the pod outward, which preloads the lugs against the track ceilings (no rattle) and clicks into a dimple when locked.
  - One wider lug means the pod can only lock with the display upright.
- **Mount (D):** a split clamp with a real 1.5 mm gap so it can grip the bar, a rubber shim, and M5 bolts with nyloc nuts. The receiver sits in a cup tilted toward the rider, with a drain at the lowest point.

## Why v3 was replaced

When I checked the v3 STLs:
- The spigot and all three lugs were separate floating pieces (the pod STL had 9 shells).
- The rear cover occupied the same space as the spigot.
- The detent hole was drilled into the open track.
- The cam ramp jammed by 0.15 mm.
- The clamp halves could not grip.
- The M4 nut pockets were too small.
- The USB cutout was never applied.
- The design assumed a 42 × 42 mm square board, but the real board is round, Ø37.

## Build

```bash
tools/check.sh     # all checks must PASS
tools/export.sh    # writes exports/
```

Needs OpenSCAD (2021.01 or newer).

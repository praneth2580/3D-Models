# Meteor 350 centre-mount navigation dock

**Project:** Old phone converted into a permanent motorcycle navigation screen
**Bike:** Royal Enfield Meteor 350 (2025)
**Revision:** 0.3 concept prototype (0.2 is kept in `archive/v0.2/`)
**CAD:** OpenSCAD 2021.01, millimetres

> **Prototype status:** this is a dimensioned concept model. It has not been tested on the road, for water ingress, for heat or for vibration. Anything marked **MEASURE** or **SELECT** in the `.scad` file is a placeholder.

## What it does

- **Sealed case.** The old phone lives in it permanently, with a short USB-C cable always plugged in.
- **Quick release with a key lock.**
  - The case slides down into the dock on dovetail rails.
  - A quarter-turn **tubular cam lock** with a unique key blocks it from sliding back out.
  - The case can only be removed with the key.
- **No cable to plug in.**
  - A 5-pin spring-loaded (pogo) contact block sits in the dock's bottom ledge.
  - A matching flat pad board sits in the case's bottom face.
  - The pads press onto the pins as the case slides home, carrying power and USB 2.0 data.
- **USB-C socket on the dock.** The lead from the bike plugs into a waterproof panel socket under the dock.
- **Centre mount between the tank and the instrument cluster.**
  - A metal plate fits under the rear handlebar-clamp bolts, the same way Evotech's Meteor 350 phone mounts attach.
  - A toothed pivot sets the tilt toward the rider in 10° steps.
- **Vibration damping.**
  - Four rubber grommets with steel sleeves sit under the pivot base.
  - The bolts and washers stay captive, so the dock cannot come off if a grommet tears.

## Files

| File | What it is | Make it from |
|---|---|---|
| `phone_dock_v1.scad` | Full parametric model (`PART` selects the output) | |
| `case.stl` | Phone-specific shell | ASA (FDM) or PA12 (SLS/MJF) |
| `bezel.stl` | Front frame that holds the window | ASA / PA12 |
| `window_template.stl` | Template for the window, with 8 screw holes | **2 mm polycarbonate sheet**, not printed |
| `shoe.stl` | Rear plate with dovetail rails and lock striker, common to every case | PA12 / ASA (striker should become stainless) |
| `receiver.stl` | The dock: rails, ledge with pins, electronics cavity, lock tower and pivot ear | PA12 / ASA |
| `ledge_lid.stl` | Cover for the electronics cavity | PA12 / ASA plus a 1 mm foam gasket |
| `mount_base.stl` | Pivot fork on the grommet base | PA12 / ASA |
| `bar_plate.dxf` / `.stl` | Plate under the handlebar-clamp bolts | **Metal only:** 5 mm 6061 aluminium or 3 mm steel |
| `cam_template.stl` | Template for cutting the lock's steel cam to length | Steel cam supplied with the lock |
| `WIRING.md` | Contact pinout, dock circuit, case cable | |
| `CAD_QA.md` | What was checked in CAD, and what was not | |

### Exporting

Set `PART` to `"assembly"` for the preview. Set it to a part name and press **F6**, then **Export as STL**. Use `"bar_plate_2d"` and **Export as DXF** for the laser-cut plate.

From the command line:

```sh
openscad -D 'PART="receiver"' -o receiver.stl phone_dock_v1.scad
```

## Measure before printing

**Phone (no soft case):**
- body width, length and thickness, and corner radius;
- camera island size, position and how far it sticks out;
- USB-C port position.

These go in `phone_*` and `camera_*`. The current values describe a dummy phone of 75 × 160 × 9 mm.

**Bike:**
- `bar_bolt_spacing`: centre distance between the two **rear** handlebar-clamp bolts. Also check the bolt size; M8 is assumed.
- `plate_reach`: how far behind those bolts the pivot can sit before the dock hits the tank **at full steering lock, in both directions**.
- `pivot_h` and `tilt`: set these so the phone does not hide the speedometer or warning lights from your normal riding position.
- Where the bike's USB/12 V feed is, so you can route the lead to the dock's USB-C socket.

The handlebar diameter is not needed, because this design does not clamp the tube. If it is ever needed, aftermarket bars listed for the Meteor 350 are 22 mm (7/8"); this is unconfirmed for the stock bar.

## Fitment warning: the speedometer

The case is about 100 × 197 mm and sits upright (portrait). At the default 40° tilt, the assembly rises about **186 mm** above the clamp and reaches about **55 mm forward** of the clamp bolts, which is toward the instrument cluster. At 20° it is lower (about 148 mm) but reaches further forward (about 93 mm).

Before printing anything, cut the case outline (100 × 197 mm) from cardboard and tape it in place at the planned angle. Sit on the bike and check:
- the speedometer and warning lights are visible;
- there is clearance to the tank at full lock left and right;
- there is clearance to the cables and the brake reservoir.

If portrait does not fit, a landscape layout is the likely fix. That would move the contact pads and USB bay to a long edge of the case.

## How docking works

1. With the key turned to unlocked, slide the case down the rails. The rails are open at the top.
2. Near the bottom, the pads in the case's bottom face meet the spring pins in the ledge, and a foam seal around the pins compresses.
3. Turn the key a quarter turn. The steel cam swings up over the striker bar on the shoe.
   - The pin springs push the case up against the cam, which takes out the slack.
   - The rail end stop stops the pins from being over-compressed.
4. The dock only switches power to the pins once the case's detect pad is connected (see `WIRING.md`). The exposed pins are not live in the rain.
5. To remove the case, unlock it and slide it up.

The rail and channel flanks now have the **same slope** and a constant 0.25 mm clearance. Version 0.2 had mismatched slopes, so the rails jammed in the slots. If the case rattles in the rails after the first print, tune `rail_side_clearance`, or add thin PTFE tape to the rail flanks.

## Lock (SELECT)

- **Lock:** a 19 mm (3/4") tubular quarter-turn cam lock.
  - Choose one where the **key can only be removed when locked**, so you cannot ride off with it unlocked.
  - Choose a unique key, not a common "keyed-alike" one.
  - Edit `lock_bore_d`, `lock_bore_flat`, `lock_panel_t` and `lock_body_len` to the lock's drawing.
- **Cam:** use the lock's steel cam, cut to `cam_arm` = 14 mm from the axis (see `cam_template.stl`).
- **Striker:** the striker on the printed shoe is for prototypes only. Replace it with a bolted stainless strip.
- **Security level:** a printed dock stops casual grab-and-go theft. It will not stop someone with tools. Removing the phone when parked for long is still sensible.

## Mounting and damping (SELECT)

- **Plate:**
  - The `bar_plate` goes under the two rear handlebar-clamp bolts.
  - Use bolts of the **same grade** as the originals, only longer by the plate thickness.
  - Keep at least the original thread engagement and torque to the factory figure.
  - **Never put printed plastic under these bolts.** Plastic creeps and lets the handlebar clamp loosen.
  - If the instrument-cluster bracket shares those bolts, stack the plate under it and re-check.
- **Grommets:** four rubber grommets with steel sleeves for M5, made for a 9.5 mm hole in a 3 mm panel. The `grommet_*` parameters set the hole size.
  - Use M5 bolts through the sleeves into the plate (tapped M5, or nyloc nuts).
  - Use a large washer on top so the base stays captive if the rubber fails.
- **Pivot:** an M6 bolt with a nyloc nut through the fork and ear, with 36 teeth (10° steps). Default tilt is 40°.
- **Safety tether:** add a short steel tether from the case to the bar plate until the system has been tested.

## Sealing and materials

| Item | Starting choice |
|---|---|
| Case, bezel | ASA (FDM) or PA12 (SLS/MJF) |
| Shoe, receiver, base | PA12 / ASA prototype; the striker and cam must be metal |
| Window | 2 mm polycarbonate, deburred, with 8 holes drilled from the template |
| Window seal | Silicone cord about 2 mm, in a 2.4 × 1.5 mm groove |
| Contact pads in the case | Flat-pad board potted in place with epoxy; the wire hole is potted too |
| Seal around the dock pins | Closed-cell foam or silicone cord, 2.0 × 1.2 mm groove |
| Fasteners | M3 stainless (bezel, lid) into heat-set inserts; M4 countersunk (shoe) into heat-set inserts; M5 (grommets); M6 (pivot) |

The back of the case **no longer has any hole through it**: the cable gland of v0.2 is gone. The only opening is the potted contact-pad board.

## Things to watch with a full-time phone

- **Heat.** A phone charging inside a sealed case in direct sun can overheat. An old phone's battery may also swell, and a swollen battery pushes on the screen. Use the phone's battery-protection or charge-limit setting if it has one. Watch the temperature during the first long rides, and inspect the battery regularly.
- **Data link.** USB data only works if the bike-side device is a USB **host**. Treat the bike's built-in USB socket as power-only unless you have proved otherwise (see `WIRING.md`).

## Build order

1. Make the cardboard mock-up on the bike (see the fitment warning above).
2. Measure the phone, update the profile and print the case only. Check the fit, the camera relief and the USB-C plug clearance.
3. Buy the lock, the pogo/target connector pair, the panel USB-C socket and the grommets. Update the SELECT parameters.
4. Print the shoe and receiver. Check the slide-in, the lock action and the pin compression on the bench.
5. Get the bar plate cut in metal and fit it with the correct bolts. Check steering lock and visibility.
6. Do a spray test with dry tissue inside, then a ride test without the phone, then a heat test with the phone while charging and navigating.

## Changes from 0.2

- Replaced the key draw-in mechanism, which needed an unobtainable draw-cam, with bottom-ledge spring contacts and a standard cam lock.
- Fixed the dovetail slope mismatch that jammed the rails.
- Fixed the window template, which had no screw holes even though the bezel screws pass through the window.
- Bezel inserts now have 2.9 mm of outer wall (was 1.9 mm); the flange went from 11 to 12 mm.
- Fixed the shoe bosses, which overlapped the shoe plate. They are now inside the case.
- Fixed the shoe insert holes, which were M3 size for M4 screws.
- Shoe screws are now countersunk, so they no longer hit the receiver.
- Removed the rear cable gland.
- Added the dock electronics cavity, panel USB-C socket, pivot, damped base and metal bar plate.

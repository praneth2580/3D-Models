# CAD checks: revision 0.5 (2026-11-19)

Update: base plate shortened from 228 to 172 mm (`slot_out` 105 → 77, default `clamp_spacing` 160 → 150). Plate re-exported and re-checked: watertight, one body; all asserts pass.

Update 2: stack lowered. `arm_up` is now worked out from the bike's handlebar clamp (`riser_h`, `riser_d`, placeholders 10 / 22 mm), giving 33.5 mm (was 38); the plate's under-ribs are removed. Re-checked at tilt 0, 40 and 70°, all with no overlap:
- the bike-clamp envelope (`riser_reach` + 3 mm, between the two clamps) vs base plate, dock and case;
- a Ø29.6 mm bar (largest the clamp takes) vs base plate, dock and case;
- clamps vs dock and case.
`clamp_body`, `clamp_cap`, `base_plate`, `pad_spacer` re-exported: watertight, one body each. New asserts: plate clear of the bike clamp, plate clear of the bar, plate-bolt inserts clear of clamp-bolt inserts, at least 6 mm of clamp over the bore.
Not checked: the real shape of the bike's handlebar clamp (only its two measurements are modelled, as a cylinder round the bar).

Update 3 (2026-11-20): **lock moved to the top, flat bolt + steel keeper.**
- **What changed:**
  - The lock pod moved from the lower-right to the upper-right of the dock. Its position is now worked out from the base plate and clamp pads.
  - `amps_offset_y` changed from +10 to −10.
  - The 8 mm round bolt and its bushing are replaced by a 14 × 9 mm flat key-steel bolt in a 6 mm steel keeper (new parts `strike_keeper`, `strike_keeper_2d`).
  - The dock-board pocket is 2.7 mm shorter (`pcb_y1` −31.5 → −34.2), because the AMPS inserts moved onto it.
- **Re-exported:**
  - `case_back`, `shoe`, `receiver`, `dock_lid`;
  - `lock_yoke`, `lock_cover`, `crank_template` (these three were not exported before);
  - `strike_keeper.stl`, `strike_keeper_2d.dxf`.
- **Mesh and render checks:**
  - All 15 STL parts and both DXFs render with no warnings.
  - Every STL is watertight with consistent winding and is one body (`bar_shim` is two, on purpose).
  - The parts that weren't re-exported render identically to the files on disk (same volume and bounding box).
- **New asserts:**
  - keeper engagement ≥ 5.5 mm;
  - ≥ 2 mm of steel around the keeper window;
  - strike screws clear of the window;
  - bolt-arm pocket inside the pod walls;
  - pod clear of the base plate, the clamp pads, the bar and the bike-clamp envelope;
  - pod no more than 7 mm above the case;
  - plate not below the case;
  - AMPS inserts clear of the dock-board pocket.
- **Interference results** (intersection renders, measured in mm³):

| Check | Result |
|---|---|
| Case sliding in with the lock unlocked, 20 positions from 0 to 75 mm, vs receiver, pod, lock cover, yoke and bolt | touch only (0.000 mm³) at every position |
| Case docked and locked vs the dock and lock parts | touch only |
| Locked bolt vs case, docked | no overlap |
| Locked bolt vs case pulled up 0.5 mm | overlaps by 30 mm³ (the full 14 × 6 mm face), so the bolt blocks removal |
| Shoe + keeper vs receiver; keeper vs shoe | touch only |
| Keeper vs back cover | no overlap |
| Crank, yoke and bolt (locked and unlocked) vs receiver and lock cover | no overlap |
| Lock cover vs receiver | no overlap |
| Base plate vs dock, case and lock parts | no overlap |
| Clamps vs dock, case and lock, at tilt 0, 40 and 70° | no overlap |
| Ø29.6 mm bar vs dock, case, lock and plate, at tilt 0, 40 and 70° | no overlap |
| Bike-clamp envelope (+3 mm) vs dock, case, lock and plate, at tilt 0, 40 and 70° | no overlap |

- **Measured position on the bike** (40° tilt, case + dock):
  - lowest point 8.9 mm above bar level (was 18.9 mm below);
  - rearmost edge 72.8 mm behind the bar (was 88.1 mm);
  - top 90.8 mm above the bar (was 78.0 mm).
- **Not checked:**
  - clearance of the pod to the real instrument cluster and switch cables;
  - press-fit retention of the bolt in the 4.3 mm yoke arm;
  - laser-cut tolerance of the keeper window.


Update 4 (2026-11-20): **USB-C or micro-USB phones.**
- **What changed:**
  - New `phone_port` setting (`"usbc"`, the default, or `"microusb"`). Micro-USB makes the plug bay 9 mm instead of 8 mm, so the case is 1 mm wider.
  - New `usb_port_y` setting, which moves the end of the cable channel under an off-centre port.
  - New asserts: `phone_port` must be one of the two values; the channel end stays clear of the cavity's rounded corner.
- **Default (USB-C) geometry is unchanged:** `case_back` and `case_shell` render with the same volume and bounding box as the files on disk, so nothing was re-exported.
- **Micro-USB variant:**
  - `case_back`, `case_shell` and `window_template` render with no warnings, watertight, one body each.
  - Case sliding in at 0, 10, 30, 50 and 70 mm, and docked + locked: touch only.
  - Bolt vs case pulled up 0.5 mm: overlaps by 30 mm³, so the bolt still blocks removal.
  - Clamps vs dock and case at 40°: no overlap.
  - Phone vs shell, back cover and window: touch only (it rests on the pads), with the port centred and with `usb_port_y` = 12.
- **Not checked:** real plug-head sizes. The 9 mm micro-USB bay is a placeholder until the cable is bought and measured.

Update 5 (2026-11-20): **dock board with real parts, status LEDs.**
- **What changed:**
  - The dock-board pocket is 2.5 mm longer (`pcb_x1` −16 → −13.5), stopping 1.5 mm short of the pin stop block.
  - New placeholder envelope for the GCT USB4720 socket (`usbc_body_w/len/h` = 11.6 / 9.5 / 5.2 mm, **not yet checked against GCT's drawing**).
  - Two Ø2.5 mm LED light pipes through the pocket roof (`led_*`).
  - **New asserts:** socket envelope inside the pocket; LEDs inside the pocket and clear of the socket; LEDs at least 0.8 mm outside the case outline, so they stay visible; pocket clear of the stop block.
- **Re-exported:** `receiver`, `dock_lid`. Both render with no warnings and are watertight, one body each.
- **Checks:**
  - Lid vs receiver: no overlap.
  - Socket envelope vs receiver: no overlap (it sits in empty pocket space).
  - LED light-pipe columns vs receiver: no overlap (they run cleanly through the roof).
  - Case docked + locked, and at 30 mm along the rails: touch only.
  - Base plate vs dock: no overlap.
  - All asserts pass.
- **LED visibility:** checked in renders from the rider's eye direction (about 37° above horizontal, from behind; also 50°, and 15° to the left). Both LEDs show below the case's lower edge in every view.
- **Not checked:**
  - the real USB4720 outline and footprint;
  - LED brightness in sunlight;
  - the TPS2552 current-limit resistor value (it must be set from the datasheet).


Update 6 (2026-11-20): **detent, drains, red OFF LED, over-heat cut-off.**
- **What changed:**
  - **Detent:** two Ø4 × 6 mm ball-plunger bores in the walls of the centre channel (`plunger_*`). They line up with 90° conical dimples (Ø1.8 mm) in the sides of the nose, and 0.6 mm lead-in chamfers on the nose's leading edges let the balls ride on.
  - **Drains:** three Ø3 mm holes (`drain_points()`) at the low ends of the centre channel and both rail channels, out through the back.
  - **Third LED light pipe** (`led_x_off`); the DOCK pipe moved to x = −18.3.
  - **Wire tunnel** widened to 3.6 mm for 6 wires.
  - **Thermostat:** 20 × 10 mm pocket in the back cover on a 1 mm skin (`therm_*`, `thermal_cutoff`), plus a lead groove to the pass-through.
  - **Pass-through:** 4.5 → 5.5 mm.
  - **Contacts:** 6 on a 2.8 mm pitch, in the same 17 mm pad board.
- **New asserts:**
  - plungers clear of the AMPS inserts and rail channels, and level with the nose;
  - dimples on the nose;
  - drains clear of the board pocket and AMPS inserts;
  - LED pipe spacing;
  - thermostat skin ≥ 1 mm, inside the phone area, clear of the shoe and strike screws.

  All asserts pass.
- **Re-exported:** `receiver`, `shoe`, `case_back`, `dock_lid`. All render with no warnings and are watertight, one body each. The first attempt left `shoe` non-manifold (8 bad edges); it was fixed by giving the dimple cone a true point and ending the chamfer cut exactly at the shoe plate.
- **Checks:**

| Check | Result |
|---|---|
| Case sliding in at 0, 2, 6, 13, 20, 40 and 70 mm; docked + locked | touch only |
| Bolt vs case pulled up 0.5 mm | overlaps by 30 mm³, so it still blocks removal |
| Base plate vs dock; clamps vs dock and case at 40° | no overlap |
| Detent balls (modelled protruding 0.8 mm) vs nose | ride on the nose from 1 to 12 mm of travel (1.0–1.6 mm³); seated in the dimples when docked (0.33 mm³ preload); free from 13 mm up |
| Thermostat + pad vs case parts | no overlap |
| Thermostat + pad vs phone | touch |
| Phone vs case | touch only |

- **Not checked:**
  - the real plunger force and the pogo-pin force (the detent sizing assumes about 0.5 N per pin);
  - real thermostat dimensions;
  - whether the drains stay clear of mud.


Update 7 (2026-11-20): **no custom steel parts.**
- **What changed:**
  - **Strike:** the strike block is now printed with the shoe (`steel_keeper = false`, the default). It has a 14.3 × 9.3 mm bolt window, blind under the shoe plate.
  - **Bearing block:** a 14 × 9 × 10 mm pocket on the window's load side takes a block of the bolt's key steel lying on its side (`bearing_block`, `strike_bearing_block()`). The 9 mm side of the key steel equals the strike's height, and an assert checks that.
  - **Strike screws:** now M3 socket heads, counterbored from below, moved below the block (`strike_screw_y` 23.2 → 13.8); the strike starts at y = 9.2.
  - **Crank:** the lock's own cam, drilled through the printed `crank_template` guide.
  - `steel_keeper = true` restores the laser-cut keeper geometry.
- **Asserts:** pass for all three variants: default; `steel_keeper = true`; `bearing_block = false`.
- **Re-exported:** `shoe` (watertight, one body, 27.9 cm³) and `case_back` (strike inserts moved).
- **Checks:**

| Check | Result |
|---|---|
| Case sliding in at 0, 2, 10, 25, 45 and 70 mm; docked + locked | touch only |
| Bearing block vs its pocket in the shoe | no overlap |
| Locked bolt vs block / shoe, docked | no overlap |
| Case pulled up 0.5 mm | the bolt overlaps the **steel block** by 30.4 mm³ (its full 14 × 6 mm face), so it blocks removal on steel |
| Case pushed down 0.5 mm | the bolt meets the printed window's far side (30.4 mm³); the rail end stop also takes this |
| Base plate vs dock; clamps vs dock and case | no overlap |

- **Not checked:**
  - strength of the printed strike behind the block;
  - whether a given lock's cam is long, straight and flat enough to drill.


Update 8 (2026-11-20): **budget build (default) and full build.**
- **What changed:** new `build` setting, `"budget"` by default. For the budget build:
  - `receiver_bottom_y` −48 → −53;
  - `pin_block_depth` 8 → 15.6, for P75 pogo pins;
  - `pcb_y0` −46.5 → −49.5;
  - the bike lead goes in through a Ø4.2 mm hole (`dock_input = "cable"`) instead of the USB-C slot;
  - Ø3.2 mm LED pipes for 3 mm LEDs (`led_x_dock` −19.8, `led_x_off` −15.5, `led_y` −46);
  - `detent = false` (no plunger bores or dimples).

  `build = "full"` restores the previous geometry exactly.
- **Asserts:** pass for both builds. New ones: the pin pocket stays inside the dock's lower edge; the LEDs stay clear of the cable hole.
- **Re-exported:**
  - budget `receiver`, `shoe` and `dock_lid`, in the main folder;
  - full-build `receiver`, `shoe` and `dock_lid`, in `full_build/`.

  All are watertight, one body each. `case_back` is the same for both builds.
- **Checks (budget build):**

| Check | Result |
|---|---|
| Case sliding in at 0, 10, 30 and 60 mm; docked + locked | touch only |
| Case pulled up 0.5 mm | the bolt bears on the steel block (30.4 mm³) |
| Base plate vs dock; clamps vs dock and case at 40° | no overlap |
| Ø29.6 bar and bike-clamp envelope at 0, 40 and 70° | no overlap |
| Lowest point at 40° | 5.7 mm above bar level (full build 8.9 mm) |
| Top of case | 90.8 mm above the bar (unchanged) |

- **Renders:** the video and the main wiring renders are pinned to `build = "full"` (`make_video.py` passes it), so they match their labels. `images/wiring_diagram_budget.svg` shows the budget circuit.


Update 9 (2026-11-20): **budget build gets USB data and a printed snap detent.**
- **Detent:** `detent` is now `"flexure"` (budget), `"plunger"` (full) or `"none"`.
  - **Arms:** two cantilever arms in the nose-channel walls, 15 × 1.6 mm, freed by back, under and end slots, with bumps (30° entry, 60° hold, 0.9 mm high).
  - **Notches:** matching V-notches in the nose, 0.5 mm deep.
  - **New asserts:** arms clear of the AMPS inserts and rail channels; notch on the nose; arm strain ≤ 1 %. The strain is 0.64 % for PETG/ASA.
- **Contacts:** budget now has 6 P75 pins at 2.54 mm (the pocket is unchanged). USB data passes straight through (USBLC6 ESD on the perfboard; optional JP1 charge-only jumper).
- **Re-exported:** budget `receiver` and `shoe` (watertight, one body each). The full-build parts are unchanged: same volumes, 56.32 and 27.92 cm³.
- **Checks:**

| Check | Result |
|---|---|
| Snap bumps vs the nose | ride on its side (3.75 mm³: the arms flex the full 0.6 mm) from 1 to 10 mm of travel; seated in the notches when docked (1.15 mm³ ≈ 0.1 mm preload); clear from 13 mm |
| Case sliding in at 0, 10, 30 and 60 mm, and locked (bumps excluded) | touch only |
| Base plate vs dock; clamps vs dock and case | no overlap |


Update 10 (2026-11-20): **budget build uses all 10 pogo pins (2 rows).**
- **Rows:**
  - Row 1: DET, VBUS, D+, D−, GND, PRESENT.
  - Row 2: VBUS2, GND2 (bridged to VBUS, GND), SPARE1, SPARE2.
  - The rows are 2.54 mm apart, both within the existing nose pad pocket.
- **Pocket and tunnel:** budget `pin_block_h` 5.2 → 6.0; wire tunnel 3.6 × 2.0 → 4.5 × 2.5 mm, for 8 wires.
- **New asserts:** the pin pocket stays inside the stop block, and the tunnel inside the board pocket. Both builds pass.
- **Re-exported:** budget `receiver` (watertight, one body). The full-build receiver is unchanged (56.32 cm³).
- **Checks:** docked + locked and sliding at 20 mm are touch only (snap bumps excluded, as before); base plate vs dock, no overlap.


Update 11 (2026-11-20): **one design; the budget/full split is removed.**
- **What the design now uses:**
  - the bike lead wired in through a Ø4.2 mm potted hole;
  - a dock board 21.5 × 14.5 × 1.6 mm, either hand-wired perfboard or an ordered PCB (same circuit);
  - 10 P75 pins in 2 rows;
  - 3 mm LEDs in Ø3.2 mm light pipes;
  - the printed flexure snap;
  - the dock 5 mm longer at its lower edge.
- **Removed:**
  - the `build` switch;
  - the USB-C socket geometry and its assert;
  - the ball-plunger bores, nose dimples and plunger asserts;
  - `full_build/`, `BUDGET_BUILD.md`, `mechanism_demo_budget.mp4` and the separate budget diagrams.
- **`detent`** is now a boolean.
- **Single sources:**
  - `WIRING.md` covers both ways to build the board;
  - `SHOPPING_LIST_INDIA.md` has one list plus the PCB extras;
  - `images/make_wiring_diagram.py` draws the full, dock and case views of this circuit.
- **Re-exported:** `receiver`, `shoe`, `dock_lid`, `case_back`. All are watertight single bodies, and the asserts pass.
- **Checks (snap excluded where noted):**
  - docked and sliding at 20 mm: touch only;
  - locked, lifted 0.5 mm: 30.4 mm³ overlap with the bolt, so it blocks removal;
  - snap bumps vs shoe: 1.15 mm³ docked (preload), 3.75 mm³ at 5 mm, clear at 15 mm;
  - plate and clamps vs dock: no overlap.


Update 12 (2026-11-20): **optional printed lock and key** (`printed_lock.scad`, `PRINTED_LOCK.md`, STLs in `printed_lock/`).
- **Design:**
  - A 4-wafer lock in the store lock's exact envelope: 16 mm D-shaped body, retaining C-clip in the nut cavity, crank with the same outline and 7 mm pin radius.
  - The receiver is unchanged.
  - The wafers and key print flat. Each wafer has 2 metal springs (2 mm OD).
  - `lock_code`: 3 depths in 0.5 mm steps, 81 codes.
  - `lock_type = "printed"` shows it in the assembly.
- **Asserts:** walls at least 1 mm at the channels and groove, spring working length 2.0–3.9 mm, key tip under dropped wafers, clip fits the cavity.
- **Checks (built in as `PART="plock_check_*"`):**
  - Body and clip vs receiver: no overlap.
  - Crank and pin vs receiver and yoke, at turn 0, 0.5 and 1: no overlap.
  - Right key, turned 0°, 45° and 90°: no overlap.
  - Wafers in the plug at -0.9, 0 and +1.0 mm: no overlap.
  - Key vs plug: touching only.
  - No key, turned 8°: blocked, 1.68 mm³.
  - Wrong key (each wafer one step off), turned 8°: blocked, 0.59 mm³.
  - Wafers at the unlocked position, moved to release the key: blocked, so the key comes out only when locked.
  - Lock, key and flange vs case, shoe and strike, docked and sliding at 5, 20 and 40 mm: no overlap.
- **STLs:** all watertight single bodies, in print orientation.
- **Changed during design:**
  - The first version used a printed nut on a printed thread. It could not be fitted, because the nut would have to pass over the body's rear part, so it was replaced by a C-clip in a groove.
  - The wafer body was narrowed, so only its 4 mm tab enters a channel; the wide body's corners gave only a weak, corner-only block.
- **Spotted, not changed:** the store lock's own cam screw or nut, on the axis behind the crank, has only 0.5 mm to the yoke (`crank_x0 - yoke_x1`). Check your lock's cam fixing; the yoke may need a relief pocket. The printed crank has nothing on the axis behind it.

Update 13 (2026-11-22): **optional one-piece dock base** (`mount = "merged"`; `"modular"` stays the default and is unchanged).
- **Design:**
  - `dock_base` = the receiver (without its AMPS inserts) + the base plate at the same height + the 2 mm grommet gap filled solid under the receiver's outline only. The dock frame is unchanged, so the dock, pod, pins and snap sit exactly where they were relative to the plate.
  - A window through the plate under the board pocket keeps the lid fitted from behind; the 3 drains run on through the plate.
  - Damping at the clamp bolts: `iso_pad` (2 mm rubber, on each clamp pad), a 2 mm rubber washer + M5 × 15 steel washer on top, and an 8 mm × 11 mm M5 spacer in each 9.5 mm slot as a compression limiter (1 mm total squeeze). The whole mount sits `iso_pad_t` = 2 mm higher (`dock_z` 55.48 → 57.48).
  - The slots have no counterbore, so the bolt heads stand on the plate (top 5.8 mm behind the case back). The inner slot end is set by the strike block sliding past the upper bolts: `iso_slot_in` = 66, so clamp spacing is 132–154 mm.
- **New asserts:** `mount` value; clamp spacing within the merged slot range; slot length left; washer on the plate; bolt heads clear of the case back; slot narrower than the clamp pad. Both `mount` values pass with no warnings.
- **Exported:** `dock_base.stl` (148.6 cm³; receiver + plate were 132.5 cm³) and `iso_pad.stl` (2.2 cm³). Both are watertight with consistent winding and one body. Modular parts are unchanged, so nothing else was re-exported.
- **Checks** (intersection renders, merged mode):

| Check | Result |
|---|---|
| Case (shell, back, shoe, bearing block) sliding in at 0, 10, 30 and 60 mm vs `dock_base` (snap off) | touch only |
| Docked, snap on | 1.15 mm³ (the usual 0.1 mm snap preload) |
| Locked bolt vs case pulled up 0.5 mm | 30.38 mm³: the bolt still blocks removal on the steel block |
| Dock lid vs `dock_base` | no overlap |
| Crank, yoke, bolt (turn 0, 0.5, 1) + lock cover vs `dock_base` | no overlap |
| Spacers, washers, bolt heads vs `dock_base`, clamp spacing 132, 150, 154 | touch only |
| Rubber pads vs `dock_base` | touch only |
| Bolt hardware + pads vs the sliding case at 0, 15 and 40 mm, clamp spacing 132, 150, 154 | no overlap |
| **Must collide:** clamp spacing 110 with the slots forced to 55 mm, docked | washer hits the strike block (85.5 mm³), so the 132 mm limit is real |
| Clamps + pads + bolts vs `dock_base`, case and lock, tilt 0, 40, 70° | touch only |
| Bar / bike-clamp envelope (+3 mm) vs `dock_base`, case and lock, tilt 0, 40, 70° | no overlap |

- **Position at 40° tilt** (case, dock base and lock): top 92.4 mm above the bar (modular 90.8), rearmost edge 74.1 mm behind it (72.8), lowest point 6.6 mm above bar level (5.1).
- **Images:** `images/merged_exploded.png`, `merged_dock_base.png`, `merged_underside.png`. The video stays on the modular mount.
- **Not checked:** how well 2 mm rubber pads damp compared with the grommets; rubber creep loosening the bolts (the spacers should prevent it); print supports under the plate.

Update 14 (2026-11-22): **one-piece dock base reshaped for looks** (merged mount only; the modular parts are unchanged, checked: the modular lock stays at y = 36.2).
- **Goal (owner):** an aesthetic, minimal one-piece base. Kept fixed: the clamp bolt pattern and slots, and the docking interface (rails, nose, pins, snap, lock mechanism).
- **What changed:**
  - **Outline:** the floor (old plate: same height, 8 mm thickness, slots) is grown to the case outline: x ±88 (flush with the keyhole face `lock_face_x`), y ±42.15 (0.5 mm inside the case), r 3.5, plus the LED chin with 4 mm fillets. Rounded underside edge, r 3 (6 steps). The slots are cut straight, after the rounding, so they don't break through the side faces.
  - **Walls:** 3 mm side walls up to z −0.5 (the right one is the lock's face panel, with the D-bore and keyhole cut through it). End walls at the bottom either side of the chin, and at the top left of the dock (0.5 mm clear of the shoe). Four Ø3 drains at the low corners of the two tray pockets.
  - **Lock pod 7 mm lower:** with no separate plate to clear, `pod_y0` is now set by the clamp pads alone (`amps_offset_y + pad_l/2 + 1.5` = 16.5, was 23.5). The pod's top is now y 41.7, under the case's 42.65 mm edge. The strike on the shoe and its 2 inserts in the back cover follow automatically: `one_piece/shoe_one_piece.stl`, `one_piece/case_back_one_piece.stl`.
  - `lock_pod_cuts()` is re-applied after the floor and walls, so they never fill the lock's bores, pockets or keyhole.
  - The printed lock's `plock_check_pod` and `plock_check_crank` now test whichever dock the `mount` option uses.
  - The one-piece STLs moved into `one_piece/`.
- **New asserts:** pod under the outline; washers clear of the side walls; edge radius fits the floor; tray drains clear of the lid window, bolt washers and clamp pads. Both `mount` values pass with no warnings.
- **Exported** (all watertight, consistent winding, one body): `dock_base` 186.8 cm³, `shoe_one_piece` 29.5 cm³, `case_back_one_piece` 55.8 cm³, `iso_pad` 2.2 cm³.
- **Checks** (merged mode):

| Check | Result |
|---|---|
| Case sliding in at 0, 10, 30, 45, 60 and 80 mm (snap off) | touch only. First run: 0.08 mm³ at 30 and 60 mm, where the top-left end wall started exactly at the shoe's edge; fixed with 0.5 mm clearance |
| Docked, snap on | 1.15 mm³ (the usual preload) |
| Locked bolt vs case pulled up 0.5 mm | 30.38 mm³: still blocks removal on the steel block |
| Store lock envelope (D-shaped thread, 1.2 mm flange) vs `dock_base` | touch only (a round envelope overlaps the D-flats by 14.1 mm³, the same as on the modular receiver) |
| Crank, yoke, bolt at turn 0, 0.5, 1 + lock cover vs `dock_base` | no overlap |
| Printed lock: body + clip, and crank at 3 turns | touch only / no overlap |
| Dock lid | no overlap |
| Bolt hardware and rubber pads vs `dock_base`, clamp spacing 132 and 154 | touch only |
| Hardware + pads vs the sliding case, at 0 and 30 mm | no overlap |
| Clamps + pads + bolts vs everything, tilt 0, 40, 70° | touch only |
| Bar / bike-clamp envelope (+3 mm), tilt 0, 40, 70° | no overlap |

- **Position at 40° tilt:** top 92.4 mm above the bar, rearmost edge 74.1 mm behind it (both unchanged from Update 13). The lowest point is now 0.4 mm above bar level (was 6.6), because the full-size floor reaches further down. The bar and bike-clamp checks still pass.
- **Images:** `merged_side`, `merged_rear`, `merged_front`, `merged_exploded`, `merged_dock_base`, `merged_underside`.
- **Not checked:** print supports under the floor; how the walls look in a real print; clearance of the walls and the now lower lock to the real cluster and switch cables.

Tool: OpenSCAD 2021.01, command-line render of every `PART`, default parameters.

## Renders
- These parts all render with **no warnings and no errors**:
  - `case_shell`, `case_back`, `window_template`;
  - `shoe`, `receiver`, `dock_lid`;
  - `base_plate`, `base_plate_2d` (DXF);
  - `clamp_body`, `clamp_cap`, `bar_shim`, `pad_spacer`, `cam_template`.
- All of the file's built-in design checks (`assert`s) pass, including the new ones:
  - corner-insert walls;
  - tongue below the window;
  - cable pass-through inside the sealed cavity;
  - cable channel clear of the support pads;
  - AMPS inserts clear of the nose and rail channels;
  - lock body clear of the nose channel;
  - cam reach into the nose slot;
  - base plate clear of the lock pod.
  - base plate and clamps within the case outline (`hide_plate`);
  - base plate clear of the bike's handlebar clamp, and of the bar.

## Mesh checks
- Every STL is watertight: every edge is shared by exactly two faces.
- Winding is consistent.
- Each file is one connected body, except `bar_shim`, which is intentionally two half-shells.

## Interference checks

These are intersection renders. "Touch" means faces meet with zero volume.

| Check | Result |
|---|---|
| Front shell vs back cover | touch only (tongue 0.15 mm clear of the shell wall) |
| Window vs shell / back cover | touch on the lip only / no overlap |
| Phone vs shell, cover and window | no overlap (rests on the pads) |
| Support pads vs tongue and shell; pads outside the phone outline; cable channel vs pads | no overlap (fixed in this revision: the pads used to overhang the phone's rounded corners) |
| Shoe vs back cover | touch only |
| Shoe vs receiver, docked and at the rail end stop | touch only |
| Shoe sliding in, 3–75 mm | touch only (rails and nose run in their channels) |
| Case sliding in, 0–75 mm, and docked | no overlap |
| Locked cam vs nose, docked | touch (cam sits on the lock lip) |
| Locked cam vs case lifted 0.5 mm | overlaps, so the cam blocks removal |
| Unlocked cam vs shoe at 17 positions, 0–70 mm | no overlap |
| Cam (locked and unlocked) vs receiver | no overlap |
| Dock lid vs receiver | no overlap |
| Dock and case vs base plate | no overlap |
| Clamp pads vs base plate | touch only |
| Bar vs base plate, dock and case, tilt 0–70° | no overlap |

## Not validated
Nothing above tests any of these:
- clamp grip, strength and fatigue;
- strength of the window bond;
- O-ring sealing;
- lock security;
- pogo-pin current or USB signal integrity;
- water ingress;
- heat (the case is smaller now);
- vibration;
- clearance to the actual bike.

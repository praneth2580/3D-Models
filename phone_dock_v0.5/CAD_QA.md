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

Update 15 (2026-11-22): **printed lock redesigned as a push-key lock, for 3D printing** (owner: "no need for it to be a regular lock"). The store lock stays the default; its parts are unchanged, checked: `receiver` and `one_piece/dock_base` render with the same volume and bounding box as the files on disk.
- **Design (`printed_lock.scad`, rewritten):**
  - A 3.5 mm card key slides straight into a slot in the pod's side wall and pushes a printed shuttle (18.2 mm long) 7 mm along a channel.
  - A pin on the printed lifter runs in a slanted track (57°) on the shuttle's side. The lifter carries the steel bolt and replaces the yoke. There is a 1.2 mm flat at each end of the track: when locked, nothing can back-drive it.
  - 4 flat 2.4 mm wafers ride in the shuttle, each pushed down by a 3 mm spring onto the key's top edge. Each wafer's side tab must line up with a groove in the pod wall (±0.25 mm), and there are pockets only at the locked position.
  - Code steps are 1 mm, giving 81 codes. A dropped wafer blocks by 1.05 mm, a one-step wrong cut by 0.75 mm.
  - The shuttle sits on the lock cover. Assembly is from underneath: the tab pockets run down to the pod's underside, and the track's entry slot drops over the pin from above. The lifter can rise only 0.5 mm (its arm meets the roof), so the pin can't leave the track.
  - Removed: body, plug, clip, crank, grub screw and insert, and the 8 × 2 mm springs.
- **Main file:**
  - `lock_pod_cuts()` now calls `store_lock_cuts()` or `plk_pod_cuts()` by `lock_type`; the arm pocket, bolt guide and cover recess are shared.
  - `lock_cover_screws()` moves its second screw for the printed lock, and the printed lock's cover has a second drain.
  - `yoke_dz()` follows the shuttle's track for the printed lock.
  - `lock_mechanism()` draws the lifter instead of the crank and yoke.
- **Asserts (new set):** code digits; wafers fit the shuttle; spring pockets apart; key tip under dropped wafers; window clearance; wrong cut and dropped wafer block by ≥ 0.6 mm; springs ≥ 3.2 mm at full lift; track inside the shuttle; innermost wafer clear of its pocket when unlocked; channel, groove and lifter pocket inside the pod; lifter joins the arm; full push reaches the channel's end stop; keyhole above the cover. All 4 combinations (store or printed lock × modular or one-piece mount) pass with no warnings.
- **Exported** to `printed_lock/` (all watertight and consistent; one body each, `plock_wafers` 4 on purpose): `plock_shuttle` 2.96 cm³, `plock_key` 2.19, `plock_lifter` 1.44, `plock_cover` 1.92, `plock_wafer_1`…`4` and `plock_wafers`, `receiver_plock` 59.1, `dock_base_plock` 187.4.
- **Checks:**

| Check | Modular | One-piece |
|---|---|---|
| Shuttle, wafers, key and lifter vs the dock, at 0, 25, 50, 75 and 100 % of the travel | no overlap | no overlap |
| Same parts vs the lock cover | touch only | touch only |
| Wafers in the shuttle (dropped, level, lifted); key in the shuttle; key in the wafers | touch only | — |
| Lifter pin in the track, 6 points of the travel | no overlap | — |
| **Must collide:** no key, pushed 0.5 mm | 1.26 mm³ | 1.26 mm³ |
| **Must collide:** each wafer one step off, pushed 0.5 mm | 0.90 mm³ | 0.90 mm³ |
| **Must collide:** key pulled out while unlocked | 5.67 mm³ | 5.67 mm³ |
| **Must collide:** bolt pushed down 0.5 mm while locked | 0.63 mm³ | — |
| Case sliding on at 0, 30 and 60 mm (snap off) | — | touch only |
| Locked bolt vs case pulled up 0.5 mm | — | 30.38 mm³: still blocks removal |
| Clamps at 40°; bar / bike-clamp envelope at 40° | — | touch only; no overlap |

- **First attempts:**
  - One assert required the travel not to be near a multiple of the wafer pitch. That was the wrong condition: only the innermost wafer has to clear its own pocket. Fixed.
  - The shuttle sat 0.1 mm above the cover, because the cover is printed 0.1 mm thin. It is now seated on it.
- **Images:** `plock_exploded.png` and `plock_cutaway.png` (coloured slices through wafer 2) re-rendered.
- **Not checked:** spring force and how the wafers feel; friction of the 57° track; how the tabs fit a real print of the dock's groove; wear of the key's cuts.

Update 16 (2026-11-22): **one dock for either lock: the lock goes in a printed cartridge** (owner: make the slot the same size and adjust the lock, or make a housing for the store-bought one). Before this, each lock needed its own dock, because the inside of the pod was cut for one lock or the other.
- **Design:**
  - The tall part of the pod is now one plain **bay**, open underneath. It is the box around the store lock's crank sweep: x from `pod_high_x0 + 1.2` to the side wall, y and top at `lock_y ± crank_sweep_r` and `lock_z + crank_sweep_r`. The side wall gets a **notch** (`lock_y ± notch_hw`, up to `lock_z + notch_hw`, `notch_hw = 9.5`).
  - `lock_cartridge()` fills the bay (0.2 mm clear) and the notch (its face plate, flush). `lock_type` picks what is cut into it: `store_lock_cuts()` (bore, D-hole through the face plate, nut cavity, crank sweep, yoke pocket) or `plk_pod_cuts()` (channel, lifter pocket, tab groove and pockets, key slot). Both cartridges share the outside shape. The dock (`receiver`, `one_piece/dock_base`) and the lock cover are now the same for both locks.
  - **Retention:** inside the wall the cartridge is wider than the notch by 1.3 mm each side and at the top, so it can't be pulled out sideways. It sits on the lock cover, and the cover is screwed into it with an M3 × 8 self-tapping screw (2.5 mm pilot) as well as into the dock. Both of the cover's dock screws are now behind the bay, at `bolt_x - 2` and `pod_high_x0 - 2`. The cover has a tab that closes the bottom of the notch, flush with the wall.
  - **Store lock:** the nut cavity opens on the cartridge's upper side, not underneath. Otherwise the face plate was a separate body (first export: 2 bodies). The strip under the nut joins it, and the nut goes on at the bench. The store lock, crank, yoke and bolt go in with the cartridge as one unit. A drain runs from the nut cavity to the cover's front drain.
  - **Printed lock:** unchanged parts. The groove is now in the cartridge, so if the tabs rub, only the small cartridge is reprinted. The shuttle's end stop is the bay's back wall (the channel runs out of the cartridge's open back).
  - The cover's front drain moved to `lock_panel_inner_x - lock_nut_len/2`, under the shuttle or the store lock's nut; it is on both covers now.
- **Asserts (new):** bay inside the pod walls; face plate covers the 16 mm bore; nut fits the cartridge with the strip under it; cartridge screw clear of the store lock's cavities and of the printed lock's lifter pocket and channel; key slot inside the face plate. The printed lock's pod asserts now check against the cartridge. All 4 combinations pass with no warnings.
- **Exported** (watertight, consistent winding, one body each): `receiver` 51.2 cm³ and `one_piece/dock_base` 179.5 cm³ (identical for both locks; checked by exporting `receiver` with each `lock_type`), `lock_cartridge` 6.95 cm³ (new), `printed_lock/plock_cartridge` 7.30 cm³ (new), `lock_cover` 2.00 cm³. Removed: `printed_lock/receiver_plock`, `dock_base_plock`, `plock_cover`.
- **Checks:**

| Check | Modular | One-piece |
|---|---|---|
| Cartridge vs dock, store and printed | no overlap | no overlap |
| Cartridge on its way in, lowered 3, 8, 15, 25 and 32 mm, store and printed | no overlap | no overlap |
| **Must collide:** cartridge pulled 0.5 mm out through the side wall | 13.17 mm³ | 13.17 mm³ |
| Cartridge vs lock cover | touch only | touch only |
| Lock cover vs dock | no overlap | no overlap |
| Store crank, yoke and bolt vs cartridge and vs dock, turn 0, 0.5, 1 | no overlap | no overlap |
| Store lock body (D section) and face flange vs cartridge / dock | touch only | touch only |
| Printed lock: `plock_check_pod`, `_cover`, `_parts`, `_pin` (with the cartridge) | no overlap / touch | no overlap / touch |
| Printed lock, **must collide:** no key, wrong key, key out while unlocked, bolt pushed down | 1.26, 0.90, 5.67, 0.63 mm³ | the same |

- **Images:** new `lock_bay_store.png` and `lock_bay_printed.png` (`PART="lock_bay_exploded"`: the dock, the cartridge with its lock lowered out of the bay, the cover below). `plock_cutaway.png` (now shows the cartridge inside the dock) and `merged_underside.png` (the open bay) re-rendered. `video/mechanism_anim.scad` now draws the cartridge; **the video itself is not re-rendered** (it needs the Linux toolchain: Pillow and imageio-ffmpeg).
- **Trade-off:** the pod's side walls are 1.0–1.2 mm and its roof 1.5 mm over the whole bay, where before they were that thin only along the crank sweep. The cartridge fills the bay and backs them.
- **Not checked:** how the cartridge fits a real print of the bay; how well the self-tapping screw holds in PETG; whether the store lock's nut can be turned by hand or with a spanner through the side opening.

Update 17 (2026-11-22): **printed lock: a chunky key** (owner: a printed key "could easily break, it's not a metal key"; chose "chunky printed key" over a combination-dial or magnetic-key lock). Also **the video now shows the lock cartridge**.
- **Key:** 6 × 10 mm (`plk_key_t` 6, `plk_kt` 5, `plk_kb` −5), up from 3.5 × 7. Section modulus about 4.2× sideways and 3.5× up and down. 3 mm fillets where the blade meets the bow (`plk_key_fillet`); the bow moved 3 mm out (`bow_x`), so pushed fully in, the fillets stay 1 mm off the face plate. 4.88 cm³, printed flat.
- **What grew with it:** the wafer window (half-width 3.25), the wafers and shuttle (now derived from the window: `plk_wy_tab = −(win_hw + 2.0)`, `plk_wy_pin = win_hw + 1.5`, `plk_sy_pin` from the track wall), the shuttle height (24.4 mm), the keyhole (6.5 × 12.5 mm). The width is the most the cartridge allows: the groove assert ends exactly at its 1.5 mm wall (46.0 mm), and the shuttle channel's top is 0.1 mm inside its limit. The tab-side wafer wall went from 2.8 to 2.0 mm to make room.
- **Asserts:** all 4 combinations pass with no warnings.
- **Exported** (watertight, one body each; `plock_wafers` 4 on purpose): `plock_key` 4.88 cm³, `plock_shuttle` 3.34, `plock_lifter` 1.44, `plock_wafer_1`…`4` 0.18–0.21, `plock_cartridge` 5.30, `lock_cover` 2.00 (its front drain follows the shuttle).
- **Checks** (modular and one-piece, the same results): `plock_check_pod` no overlap (the key, its fillets and the bow at every point of the travel); `_cover`, `_parts` touch only; `_pin` no overlap; must collide: no key 1.26 mm³, wrong key 0.90, key out while unlocked 5.67, bolt pushed down 0.63. Cartridge vs dock, on its way in (3, 15, 32 mm), vs cover, cover vs dock: no overlap / touch.
- **Images:** `plock_exploded.png`, `plock_cutaway.png` and `lock_bay_printed.png` re-rendered.
- **Video:** a new 8 s scene at 70.5 s. Seen from below the pod with the dock level, the cover drops, the store lock's cartridge drops out with its lock, crank, yoke and bolt, the printed lock's cartridge (with its key) goes up into the same bay, and the cover goes back on. Total 96.5 s.
  - `mechanism_anim.scad`: `A_cart_drop`, `A_cover_drop`; `lock_type` set per frame picks the cartridge and the lock drawn (`plk_placed` for the printed lock; the store key and body only for the store lock).
  - `make_video.py`: `cart_state()`, with `CART_T0`/`CART_LEN` shifting the later base scenes. It now runs on Windows: `OPENSCAD` env var for the binary, ECHO read from stdout as well as stderr (Windows' `openscad.com` prints it there), Arial when DejaVu is missing.
- **Not checked:** how strong the printed key really is (no load test), and whether the wider wafers still slide freely in a real print.

Update 18 (2026-11-22): **the one-piece dock base is now the main build** (owner: "I want the merge one to be v5"; chose "make merged the default" over a separate v5 project or a rename).
- **CAD:** `mount = "merged"` is the default; `"modular"` is the option. Comments and the PART list updated (the PART list was also stale for the printed lock). `clamp_spacing` note: 132–154 mm by default.
- **Files:** the one-piece parts moved to the top level: `dock_base`, `iso_pad`, `shoe` (was `one_piece/shoe_one_piece`), `case_back` (was `one_piece/case_back_one_piece`); `one_piece/` removed. The modular parts moved to `modular/`: `receiver`, `base_plate` (+ DXF), `shoe_modular`, `case_back_modular`, `strike_keeper_modular` (+ `strike_keeper_2d_modular.dxf`). Re-exported in the new default frame (same shapes, 7 mm lower pod position): `lock_yoke`, `lock_cover`, `lock_cartridge`, `printed_lock/plock_cartridge`, `plock_lifter`, and the merged `strike_keeper` + DXF (`steel_keeper = true`; 2.64 cm³, longer than the modular one because the strike block is 7 mm longer). Checked before moving: the default `shoe` and `case_back` exports match `one_piece/*_one_piece.stl` exactly (volume and bounding box), and every part that doesn't depend on the mount (case shell, window template, clamps, shims, spacer, crank template, dock lid) renders identically to the file on disk.
- **Asserts:** all 4 combinations (store or printed lock × merged or modular) and `steel_keeper = true` pass with no warnings.
- **Images:** `v05_rider_view`, `merged_side` (now orthographic, from the lock side), `merged_rear`, `merged_front`, `merged_exploded`, `merged_dock_base` re-rendered (they now include the lock cartridge). The modular pictures were renamed `modular_exploded`, `modular_dock`, `modular_rear`.
- **Video:** the default scenes now show the one-piece base: the clamps carry the rubber pads and the clamp-bolt hardware, the vibration scene rocks the dock base on that rubber, and the title says "one-piece dock base". The smart-base scene is labelled as the modular option and renders with `mount="modular"` per frame. The closing orbit shows the one-piece base. The cartridge scene's camera now follows the lock position read from the CAD (`CART_FOCUS`).
- **Docs:** README (the mount section rewritten: the one-piece base first, the modular option after it; sizes at the default; build order; exports), SHOPPING_LIST_INDIA (the main list is now the one-piece build: ≈ ₹3,650–5,600 for Option A, over the ₹5,000 target at the top; the modular option is the "changes" section), WIRING (the smart base needs the modular option), PRINTED_LOCK, website (`features.html`, `adjust.html`, `project.json`: parts, gallery, poster, viewer default `dock_base`), CLAUDE.md.

Update 19 (2026-11-22): **dial-code lock, a demo** (owner: "a version which has keys for password, just as a demo"; then "a rotary knob that enters the key and a button to lock it", as a third lock cartridge).
- **Design (`keypad_lock.scad`, new; `lock_type = "keypad"`):** an EC11 rotary encoder with push switch behind the cartridge's face plate (printed knob outside), an ATtiny85 board above the servo, and a 3.7 g class micro servo lying on the lock cover with its shaft pointing -x. Its horn is the crank: an M2 pin at 7 mm in a horizontal slot in a new lifter (same arm and bolt pocket as the yoke). The pin is horizontal toward +y when unlocked, and straight up (top dead centre) when locked, so the bolt can't back-drive it. Code: right-left-right click counts, submitted after a 1.5 s pause; press to lock; wrong codes back off 3–60 s (`keypad_lock/keypad_lock.ino`).
- **Main file:** `lock_cartridge()` picks `kp_cuts()`; `lock_mechanism()` draws `kp_placed()`; `yoke_dz()` uses the crank formula for it; a `lock_type` assert. `lock_cover()` gets a Ø3 cable hole under the keypad cartridge's cable channel (`kp_cable`); for the other locks it is one more drain (checked: cartridge vs cover still touch only, for all three). `lock_bay_exploded` draws the store lock body only for the store lock.
- **Asserts (new):** the servo fits the bay (its far end 0.1 mm from the face plate at the 17.5 mm default); lifter joins the arm and stays inside the cartridge and above the cover; horn hub above the cover; encoder and bushing inside the face plate; encoder pins clear the board; board fits its cavity. All 6 combinations (3 locks × 2 mounts) pass with no warnings.
- **Exported** to `keypad_lock/` (watertight, one body each): `kp_cartridge` 6.70 cm³, `kp_lifter` 1.04, `kp_horn` 0.07, `kp_knob` 1.23. `lock_cover` re-exported (cable hole).
- **Checks** (one-piece and modular, the same results): moving parts + visual servo, encoder, knob and board vs cartridge at 0/50/100 % no overlap; the same + bolt vs dock no overlap; pin in slot at 5 points no overlap; vs cover touch only; cartridge vs dock, on its way in (3, 15, 32 mm) no overlap; pulled out 0.5 mm must collide 55.89 mm³; locked bolt vs case lifted 0.5 mm 30.38 mm³; clamps and bar at 0/40/70° touch / no overlap.
- **First attempt:** the board's visual block ran 1.3 mm below its cavity into the cartridge (6.12 mm³). It now sits on the servo, and an assert checks it. The knob's grip ribs were tangent to its body (10 bad edges); they now overlap it by 0.2 mm.
- **Images:** `kp_exploded.png` (the cartridge lowered out of the bay), `kp_side.png` (the knob on the pod).
- **Not checked:** real servo sizes and torque, the firmware on hardware, rain.

Update 20 (2026-11-22): **lock video** (owner: "show me a video of how specifically these locks work").
- `video/lock_anim.scad` (new) draws the lock pod see-through (the dock and shoe cropped to the pod, plus the cartridge and cover) with the moving lock parts and the bolt solid. `lock_type` is set per frame, so one video shows all three cartridges. The printed lock's shuttle has its near half cut away so the wafers show. The keypad lock's servo is drawn see-through so its horn shows.
- `video/make_lock_video.py` (new): 43 s. Title; store lock (key in, quarter turn, crank and yoke drop the bolt, case off and on, turn back); printed lock (wafers dropped, the key lifts them, pushed 7 mm, the track drops the bolt, case off and on, pulled back); dial-code demo (right 7, left 12, right 4 on the knob, the servo turns, case off and on, press to lock); closing title. Rendered on Windows in about 2.5 minutes with 8 jobs, to `video/lock_demo.mp4`.
- `keypad_lock.scad`: `kp_knob_a`, `kp_knob_press` and `kp_vis_alpha` (pictures and animation only).
- **Website:** `site/build.py` takes an optional `videos` list in `project.json` (more videos, each with a title, after the main one; documented in `site/README.md`). The phone dock page now shows the lock video under the main one.

Update 21 (2026-11-22): **the dial-code lock is now mechanical: a single-dial combination lock, like a safe** (owner: "I don't want it to be electronic, rather mechanical"; a 3-thumbwheel version was drafted first, then "I instead want a single dial lock... a dial that has all numbers, and it types all the digits, 4-6"). The electronic demo of Update 19 is removed (`keypad_lock.scad`, `keypad_lock/`, `KEYPAD_LOCK.md`, `kp_*` images), and so is the lock cover's cable hole (`lock_cover` is back to 2.00 cm³).
- **Design (`dial_lock.scad`, new; `lock_type = "dial"`):**
  - A dial numbered 0-9 (15 mm) on a 3 mm spindle, through a fixed tube (part of the cartridge) in the face plate. Behind the wheels sits a drive cam (r 6) on the spindle.
  - One wheel per digit (r 7.5, 2 mm thick, 0.6 mm apart) on the tube. `dial_code` sets the length (4 to 6) and the digits.
  - Flies: 1.4 mm pins at r 5 on the wheels' faces and the cam pick each wheel up after nearly a turn (lost motion 360° − 2 × 16.1°).
  - A V notch in each rim. Its angle on the wheel comes from the pickup kinematics: `dl_gate_a(i) = 36·digit − dir·(chain place)·dl_delta`, with dl_delta = 2·asin(0.7/5) = 16.1°.
  - A fence bar under the wheels, pushed up by a 3 mm spring, rises 1.5 mm into the notches when all are at the bottom. Its front tooth leaves the notch in the button bar's stem.
  - The button bar (12 mm stroke, spring out) has a 40° ramp that lifts the lifter's 3 mm pin 7 mm. Locked, the pin sits on the flat (no back-drive).
  - Lock: hold the button in and spin the dial a turn. A wheel moves, its V side pushes the fence down, and the tooth drops into the notch.
  - Index mark: an engraved triangle at the dial's 9 o'clock.
- **Main file:** `lock_cartridge()` picks `dl_cuts()` and adds `dl_fingers()` (here the fixed tube); `lock_mechanism()` draws `dl_placed()`; `yoke_dz()` follows the ramp; the `lock_type` assert takes "dial"; `PART` takes `dl_*`.
- **Fixed on the way:**
  - The rear button-spring tab was 0.1 mm into the fence spring (assert).
  - The pin vs wheels assert was too strict for 4-5 wheels (now: the pin is behind the wheels, or clear below them).
  - The tube touched the face plate only at a face: 2 bodies. It now runs 1 mm into the plate.
  - CGAL manifold warning: the wheel cavity's top edge met the face plate's top edge exactly. The cavity now stops 0.3 mm short of the plate; found by switching each cut off in turn.
  - That exposed the front wheel's front fly (0.52 mm³): the front wheel has nothing in front to pick up, so it has none. The spindle's bore now starts 0.6 mm inside the cavity.
  - The dial's grip ribs were tangent (32 bad edges); they now overlap the rim.
- **Asserts (new):** 4-6 digits; cam clear of the lifter (6 wheels fit with 0.6 mm); wheels inside the cartridge; index mark on the plate; the latch arm clears the stem; the rise frees the latch and fits the notches; the tab and the flat clear the tooth; the fence spring clears the lifter and the tab; the pin rests above the cover; notches don't cut the flies. All pass for 4, 5 and 6 digits, both mounts, and with the store and printed locks.
- **Exported** to `dial_lock/` (watertight, one body each; `dl_wheels` 4 on purpose): `dl_cartridge` 6.96 cm³, `dl_wheel_1`…`4` 0.31 each, `dl_spindle` 0.42, `dl_dial` 1.03, `dl_fence` 0.06, `dl_plunger` 0.64, `dl_lifter` 1.49.
- **Checks** (4 states: locked; code set; half out; out):
  - parts vs cartridge: no overlap (4 and 6 digits, both mounts); parts, dial and bolt vs dock: no overlap;
  - parts vs each other: touch only; vs cover: no overlap;
  - **must collide:** fence pushed up 0.5 mm with the wheels scrambled 2.76 mm³ (4 wheels) / 4.14 mm³ (6); button pushed out 0.5 mm while latched 0.54 mm³; bolt pushed down 0.5 mm when locked 2.64 mm³;
  - cartridge on its way in: no overlap; pulled out 0.5 mm: 63.72 mm³.
- **Dialling, simulated:** `video/make_lock_video.py` models the chain (each part sits between +16.1° and +343.9° of the one driving it), dials the code right, left, right, left with the shortest turns that set each wheel, and asserts every notch ends within 0.5° of the bottom. For [3, 7, 1, 9] the wheels end at 187.6, 156.3, 291.8 and 52.1°, against notches at 172.4, 203.7, 68.2 and 307.9° (each pair sums to 360). A spin of the dial afterwards moves the rear wheel 164° off and the fence goes down.
- **Images:** `dl_side.png` (the dial and the button on the pod), `dl_exploded.png`.
- **Lock video:** the third part is the dial lock (see `video/README.md`); about 49 s in all.
- **Not checked:** the springs' real forces, friction of the wheels on the tube, how sharply the latch lets go, the small flies in print, rain.

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

# Design log

## Session 1 — 2026-11-16: v3 review and v4 redesign

### 1. v3 review
I checked the v3 bundle (now in `archive/v3/`), and none of it could be printed as designed:
- **Pod pieces not attached.** The pod STL was 9 separate pieces. The spigot floated 0.1 mm away from the pod, and each lug floated 1 mm away from the spigot.
- **Cover clash.** The rear cover occupied the same space as the bayonet spigot.
- **Detent.** The detent hole was drilled into the open locking track, so there was nothing to thread into.
- **Cam ramp.** The ramp drop (0.4) was bigger than the track clearance (0.25), so the lugs jammed by 0.15 mm at lock.
- **Clamp.** The two halves had no split gap, so they couldn't grip the bar. The M4 nut pockets were 6.24 mm across flats, too small for a 7 mm nut.
- **Missing features.** The USB cutout module was never called. The PCB ledges floated in mid-air. The O-ring groove was broken by the entry slots.
- **Wrong board size.** It assumed a 42 × 42 mm square PCB.

### 2. Board identification
- **Board identity.** The Amazon listing (ASIN B0GW3Z3BJJ) photo shows "ESP32-2424S012" on the silkscreen, a JCZN/Sunton/Jingcai board.
- **Official data.** The vendor spec sheet and structure drawing came from a GitHub repo (mk0000001/ESP32-2424S012-MagSafe-Case). Copies are in `reference/vendor/`.
  - Outline Ø37.00; 38.50 including the USB tab. Tab 14.23 wide, 3.74 tall from its shoulder.
  - Active display area Φ32.4.
  - Operating temperature −20 to 70 °C.
- **Other maker's measurement.** The same repo measured glass front to PCB as 4.0 mm free and 3.0 mm pressed.
- **Board features.**
  - ESP32-C3-MINI-1U with an IPEX socket and no on-board antenna, so the flex antenna must fit inside the pod.
  - IP5306 charger.
  - JST1.25-2P battery socket.
  - SH1.0-4P UART connector.
  - RST and BOOT buttons on the back.
  - Edge slide switch.
  - USB-C on the bottom tab, with no CC resistors.
  - No mounting holes.

### 3. Decisions
- **Battery.** The user wants a small LiPo in the pod. Default cell: 402030 with a protection PCB, in the rear-cover bay with 1 mm of room to swell.
- **Heat warning.** The charger has no temperature cut-off. Use a light-coloured housing, and do a heat test before relying on it.
- **Architecture.** The male bayonet is on the rear cover. A retainer plate with a foam pad presses the board forward onto the front ledge. The PC lens is bonded into the front.
- **Bayonet.**
  - 3 lugs with one wide key lug. The pod locks with a 30° clockwise twist.
  - An M4 axial ball plunger preloads the lugs against the track ceilings and clicks into a dimple at the lock position.
  - For road use, metal lugs or pins are worth considering later.
- **Mount.** A split clamp with a 1.5 mm gap and a rubber shim. The receiver sits in a cup tilted 40°, held by radial M3 thread-forming screws.

### 4. Validation
OpenSCAD 2021.01 is installed. `tools/check.sh` passes all 12 checks. `tools/export.sh` writes 9 STLs and 4 DXFs, and every STL is a single shell with no non-manifold edges.

Fixes made while validating:
- **FPC fold pocket.** Extended up to the ledge.
- **Receiver mounting screws.** Moved to z = 3.0, with no spot faces. The hull target was moved inside the cup, and the screw-hole facets were twisted half a step to stop the CGAL non-manifold edges.

### Still open (next session)
1. **Handlebar.** Measure your bike's bar diameter at the mount point, the free length there, and the tilt and cup position. These are needed before printing the clamp.
2. **USB cable.** Measure the plug head (assumed 12.5 × 7).
3. **Board.** Measure the total thickness and the glass diameter, and confirm the touch or non-touch variant.
4. **Battery and plunger.** Confirm the battery model and size, and check the plunger's stroke is at least 0.8 mm.
5. **Antenna.** Find out its size so a mounting spot can be added (only needed if Wi-Fi/BLE is used).
6. **Fit test.** Print `receiver.stl` and `bayonet_test_male.stl` first and tune `entry_clear` / `track_clear`.
7. **CLAUDE.md.** Optionally update its status table, which still says "Pending" for the board dimensions.

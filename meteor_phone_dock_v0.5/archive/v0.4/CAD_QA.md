# CAD checks: revision 0.4 (2026-11-19)

Tool: OpenSCAD 2021.01, command-line render of every `PART`, default parameters.

## Renders
- These parts all render with **no warnings and no errors**:
  - `case`, `bezel`, `window_template`, `shoe`, `receiver`, `ledge_lid`;
  - `base_plate`, `base_plate_2d` (DXF);
  - `clamp_body`, `clamp_cap`, `bar_shim`, `pad_spacer`, `cam_template`.
- All of the file's built-in design checks (`assert`s) pass.

## Mesh checks
- Every STL is watertight: every edge is shared by exactly two faces.
- Winding is consistent.
- Each file is one connected body, except `bar_shim`, which is intentionally two half-shells.

## Interference checks

These are intersection renders. "Touch" means faces meet with zero volume.

| Check | Result |
|---|---|
| Shoe vs receiver, docked and at the rail end stop | touch only |
| Shoe sliding in, 3–69 mm | touch only (rails run in their channels) |
| Case sliding in, 0–68 mm | no overlap |
| Case vs receiver, docked | no overlap |
| Locked cam vs case, docked | touch (cam sits on the lock lip) |
| Locked cam vs case lifted 0.5 mm | overlaps, so the cam blocks removal |
| Unlocked cam vs case sliding in, 0–70 mm | no overlap |
| Cam (locked and unlocked) vs receiver | no overlap |
| Ledge lid vs receiver | touch only |
| Receiver vs base plate (2 mm grommet float) | no overlap |
| Clamp body vs cap | no overlap (1 mm clamping gap) |
| Clamp pads vs base plate | touch only |
| 22.2 mm bar vs clamps + shims | no overlap |
| Bar vs base plate, dock and case, tilt 0–70° | no overlap |

## Not validated
Nothing above tests any of these:
- clamp grip and slip torque, or strength and fatigue;
- lock security;
- pogo-pin current or USB signal integrity;
- water ingress;
- heat;
- vibration;
- clearance to the actual bike (riser clamps, cluster, tank, mirrors, cables).

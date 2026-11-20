# CAD checks: revision 0.3 (2026-11-19)

Tool: OpenSCAD 2021.01, command-line render of every `PART`.

## Renders
- `case`, `bezel`, `window_template`, `shoe`, `receiver`, `ledge_lid`, `mount_base`, `bar_plate`, `cam_template` and `bar_plate_2d` (DXF) all render with **no warnings and no errors**.
- All of the file's built-in design checks (`assert`s) pass: gasket and insert clearance, insert skin, dock seal on the case face, cam reach, lock body vs striker, and tooth pitch vs tilt.

## Mesh checks (all STLs)
- Watertight: every edge is shared by exactly two faces.
- Consistent winding.
- One connected body per file.

## Interference checks (intersection renders; "touch" means faces meet with zero volume)

| Check | Result |
|---|---|
| Shoe vs receiver, docked | touch only (rails clear in their channels) |
| Shoe vs receiver, at the rail end stop | touch only |
| Shoe sliding in from the top, 3–63 mm, cam unlocked | no overlap |
| Case sliding in, 3–63 mm | no overlap |
| Case vs receiver/ledge, docked | no overlap (0.8 mm contact gap) |
| Locked cam vs striker | touching when docked; overlaps if the case is moved 0.5 mm up, so the cam blocks removal |
| Unlocked cam vs sliding shoe | no overlap |
| Lid vs receiver | touch only |
| Pivot teeth at 40° | touch only (teeth mesh) |
| Dock and case vs base and bar plate, tilt 0–70° | no overlap |

## Not validated
Nothing above tests any of these:
- strength or fatigue;
- lock security;
- pogo-pin current or USB signal integrity;
- water ingress;
- heat;
- vibration;
- fit on the actual Meteor 350.

The bike interface numbers are placeholders until measured.

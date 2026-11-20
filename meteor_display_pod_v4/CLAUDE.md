# CLAUDE.md
# Meteor 350 Minimal-Bezel Circular Display Enclosure

## 1. Project Overview

Design a compact, 3D-printable circular enclosure for an **Electrobot ESP32-C3 1.28-inch round IPS display (240 × 240)**.

The enclosure is intended to be mounted at the centre of a Royal Enfield Meteor 350 handlebar.

The design should look like a professionally manufactured motorcycle instrument pod, not a generic electronics project box.

The primary objective is a **minimal-bezel, rounded circular enclosure** with a practical, serviceable mechanical design.

Use parametric OpenSCAD for the mechanical model.

## 2. Primary Design Goals

Priorities, in order:

1. Minimum possible visible front bezel.
2. Smooth, rounded circular exterior.
3. Compact overall dimensions.
4. Secure display and PCB mounting.
5. Removable rear service cover.
6. Rain protection.
7. Quick-release motorcycle mounting.
8. Easy 3D printing and assembly.
9. Parametric dimensions for future revisions.

Do not sacrifice mechanical strength or display protection simply to make the bezel thinner.

## 3. Display Specifications

| Parameter | Value |
|---|---|
| Display manufacturer | Electrobot |
| Controller board | ESP32-C3 |
| Display size | 1.28 inches |
| Resolution | 240 × 240 |
| Display shape | Circular |
| PCB dimensions | Not yet measured |
| Active display diameter | Not yet measured |
| PCB component height | Not yet measured |
| USB-C position | Not yet measured |
| Button positions | Not yet measured |

### Important

Do not assume the PCB is 42 × 42 mm.

Do not assume the active display diameter is exactly 33 mm.

The advertised display diagonal is not necessarily the diameter of the active circular area.

Keep these dimensions configurable until actual measurements are supplied.

## 4. Front Enclosure Design

The front face must be extremely minimalist.

### Design requirements

- Circular body.
- Very narrow visible bezel.
- Nearly flush display window.
- Smooth transitions between the front face and outer housing.
- Rounded exterior edges.
- No unnecessary decorative rings.
- No oversized retaining lip.
- No visible front screws.
- A small protective rim around the display window.

### Initial design targets

These are provisional modelling targets, not verified measurements.

| Parameter | Initial target |
|---|---:|
| Outer diameter | 60 mm |
| Overall depth | 18–20 mm |
| Window opening | Parametric |
| Protective rim | Approximately 0.4 mm |
| Outer edge radius | Approximately 2 mm |

The final window opening must be based on the actual visible display area.

### Bezel philosophy

Separate the following concepts:

1. Visible bezel: the ring visible from the front.
2. Structural material: the material supporting the display and housing.
3. Protective rim: the small raised edge protecting the window.
4. Window seat: the recessed area retaining the transparent protective window.

Keep the visible bezel minimal without compromising the structural material.

## 5. Housing Construction

Use a multi-part construction.

### Part A: Main enclosure

Contains:

- Front display opening.
- Display window seat.
- PCB cavity.
- PCB mounting supports.
- Rear cover mounting points.
- USB-C access provision.
- Button access provision.
- Rear mounting interface.

### Part B: Rear service cover

Requirements:

- Removable.
- Securely fastened.
- Allows PCB servicing.
- Does not interfere with the bayonet mount.
- Includes a provision for a perimeter gasket.

### Part C: Bayonet receiver

Requirements:

- Separate mechanical component.
- Three-lug bayonet interface.
- Replaceable if damaged.
- Mechanically secured to the handlebar mount.

### Part D: Handlebar mount

Requirements:

- Parametric clamp or mounting interface.
- Designed around actual handlebar dimensions.
- Replaceable mounting insert if needed.
- Must not interfere with controls or cables.

## 6. Quick-Release Mounting Mechanism

Use a three-lug bayonet mechanism.

### Desired operation

1. Align three lugs with the receiver entry slots.
2. Push the display pod into the receiver.
3. Rotate approximately 30 degrees clockwise.
4. Detent engages in the locked position.
5. Rotate anticlockwise to unlock.
6. Lift the display pod out.

### Mechanical requirements

- Three equally spaced lugs.
- Entry slots.
- L-shaped locking tracks.
- Proper circumferential travel.
- Positive rotation stops.
- Axial retention.
- Spring-ball detent.
- Clearance for 3D printing.
- No accidental release during vibration.

The spring-ball detent prevents unwanted rotation. The bayonet track itself must provide axial retention.

Do not implement a simple sleeve with straight entry slots and claim it is a completed bayonet lock.

The final receiver must contain actual curved locking tracks and a defined locked position.

Do not assume that printed plastic lugs are safe for highway use. Evaluate metal reinforcement or a metal retaining component where appropriate.

## 7. Weather Protection

The enclosure is intended for motorcycle use in rain.

Include provisions for:

- Silicone or EPDM perimeter gasket.
- Sealed display window.
- Sealed rear cover.
- USB-C access protection.
- Drainage considerations where appropriate.
- Avoidance of water traps.

Suggested materials:

| Component | Material |
|---|---|
| Main housing | ASA |
| Prototype housing | PETG |
| Rear cover | ASA or PETG |
| Gasket | Silicone or EPDM |
| Protective window | Polycarbonate or suitable glass |
| Reinforcement | Metal inserts where necessary |

Avoid PLA for the final outdoor motorcycle enclosure because of heat and sunlight exposure.

Do not claim an IP rating without actual testing.

## 8. Parametric OpenSCAD Architecture

Organise the project into separate modules and files where practical.

Suggested structure:

```text
meteor-display-pod/
│
├── CLAUDE.md
├── README.md
│
├── scad/
│   ├── main.scad
│   ├── parameters.scad
│   ├── display_housing.scad
│   ├── front_bezel.scad
│   ├── rear_cover.scad
│   ├── pcb_mounts.scad
│   ├── bayonet_receiver.scad
│   ├── bayonet_lugs.scad
│   └── handlebar_mount.scad
│
├── exports/
│   ├── housing.stl
│   ├── rear_cover.stl
│   ├── receiver.stl
│   └── handlebar_mount.stl
│
└── documentation/
    ├── measurements.md
    ├── assembly.md
    └── print_settings.md
```

Use reusable modules and centralised parameters.

Example parameter groups:

```scad
// Display
display_active_diameter = 0;
display_pcb_width = 0;
display_pcb_height = 0;
display_component_depth = 0;

// Housing
housing_outer_diameter = 60;
housing_depth = 19;
front_wall_thickness = 1.8;
front_edge_radius = 2;

// Window
window_diameter = 0;
window_clearance = 0.25;
protective_rim_height = 0.4;

// PCB
pcb_mount_clearance = 0.5;
pcb_standoff_height = 5;

// Bayonet
bayonet_lug_count = 3;
bayonet_rotation = 30;
bayonet_clearance = 0.25;
```

Zero values must be treated as unresolved dimensions, not valid final geometry.

Do not silently substitute guessed measurements.

## 9. Modelling Standards

- Use millimetres.
- Use `$fn` appropriate for smooth circular surfaces.
- Use consistent tolerances.
- Avoid non-manifold geometry.
- Avoid overlapping solids where they cause export problems.
- Use rounded edges wherever practical.
- Keep components independently exportable.
- Add assembly alignment features.
- Use descriptive variable names.
- Add comments for important mechanical features.
- Ensure parts can actually be assembled.
- Check screw access and tool clearance.
- Consider print orientation and support requirements.

Do not create cosmetic geometry that makes the part impossible to print or assemble.

## 10. 3D Printing Considerations

Design for FDM printing.

Consider:

- Nozzle size.
- Layer height.
- Wall thickness.
- Minimum feature size.
- Overhang angles.
- Support requirements.
- Screw insert installation.
- Gasket compression.
- Printing tolerances.

Start with a PETG prototype.

Use ASA for the final housing after fitment and mechanical testing.

Do not assume that a successful OpenSCAD render means the STL is mechanically printable.

## 11. Validation Requirements

Before declaring the model complete, check:

### Geometry

- All parts render.
- All parts export independently.
- No missing geometry.
- No unintended intersections.
- Correct dimensions.
- Correct alignment.

### Assembly

- PCB fits.
- Display window aligns with active screen.
- USB-C remains accessible.
- Buttons remain accessible.
- Rear cover can be removed.
- Gasket has a defined seating surface.
- Bayonet can engage and disengage.

### Mechanical

- Locking tracks prevent axial withdrawal.
- Rotation stops work.
- Detent engages at the locked position.
- Lugs have adequate strength.
- Mount does not obstruct motorcycle controls.

### Physical testing

CAD validation is not physical validation.

Test fit, retention, vibration, heat, water resistance and fatigue before motorcycle road use.

Never describe the mount as highway-safe solely because the CAD model renders correctly.

## 12. Development Workflow

Follow this sequence:

1. Inspect the existing project and preserve useful existing work.
2. Establish a central parameter file.
3. Refine the front face and minimum-bezel geometry.
4. Build the display window seat.
5. Build the main housing.
6. Add PCB supports after dimensions are known.
7. Build the rear service cover.
8. Design the complete three-lug bayonet receiver.
9. Add the spring-ball detent.
10. Design the handlebar mounting interface.
11. Check assembly clearances.
12. Export individual STL parts.
13. Prepare assembly and printing documentation.

Work incrementally. Do not regenerate the entire project unnecessarily when only one component needs modification.

## 13. Instructions for Claude

Act as a mechanical product designer with strong experience in:

- OpenSCAD.
- Parametric CAD.
- FDM 3D printing.
- Motorcycle mounting hardware.
- Bayonet locking mechanisms.
- Electronics enclosure design.

When editing this project:

1. Inspect existing files before making changes.
2. Preserve existing working geometry.
3. Explain significant design changes.
4. Keep dimensions configurable.
5. Never invent unknown PCB measurements.
6. Do not simplify the bayonet into a non-locking sleeve.
7. Check that the model is physically assemblable.
8. Prefer practical engineering solutions over decorative complexity.
9. Provide complete updated files, not isolated fragments, when replacing a file.
10. Identify assumptions and unresolved measurements clearly.

The user is comfortable with electronics and Arduino but is still developing mechanical CAD skills. Explain important mechanical decisions in practical language.

Do not generate or share images unless the user explicitly requests them.

## 14. Current Design Status

| Item | Status |
|---|---|
| Display model | Identified |
| Display resolution | Known |
| PCB dimensions | Pending |
| Active display diameter | Pending |
| Component height | Pending |
| USB-C position | Pending |
| Button positions | Pending |
| Front bezel concept | Defined |
| Housing concept | Defined |
| Rear cover | To be refined |
| Bayonet mechanism | To be engineered |
| Handlebar dimensions | Pending |
| Physical validation | Pending |

## Final Design Objective

Create a premium-looking, compact, round motorcycle display pod with the thinnest practical visible bezel, smooth rounded edges, a protected display window, serviceable electronics and a reliable three-lug quick-release mounting system.

The result must be a genuinely manufacturable mechanical design, not merely a visually attractive CAD render.

# Meteor phone enclosure + keyed quick-release dock

**Project:** Parametric motorcycle phone enclosure  
**Revision:** 0.2 concept prototype  
**CAD:** OpenSCAD, millimetres

This is a reusable CAD architecture for a phone-specific, rain-resistant enclosure with a common handlebar dock. Change the phone profile and regenerate the case; the rear shoe, receiver, locking interface and electrical architecture are intended to remain common.

> **Prototype status:** this is a dimensioned concept model, not a road-validated mount and not an IP-rated enclosure. Do not put a valuable phone in it until the fit, sealing, retention, temperature and vibration tests in this file have passed.

## Project files

- `phone_dock_v1.scad` — complete parametric OpenSCAD model.
- `case.stl` — phone-specific main shell.
- `bezel.stl` — front window-retaining bezel.
- `shoe.stl` — common rear quick-release shoe.
- `receiver.stl` — handlebar-side receiver.
- `window_template.stl` — dimensional template only; cut the real window from polycarbonate.
- `WIRING.md` — USB and bike-power interface notes.

## OpenSCAD use

1. Open `phone_dock_v1.scad` in OpenSCAD.
2. Change the values under `PHONE PROFILE` to measurements from the exact phone.
3. Start with `PART = "assembly"` for the preview.
4. For individual exports, set `PART` to `"case"`, `"bezel"`, `"shoe"`, `"receiver"` or `"window_template"`.
5. Press **F6** to render, then use **File → Export → Export as STL**.

The STL files in this folder were generated from this revision. They are useful for checking fit and planning a prototype, not final road-use parts.

## Architecture

### 1. Phone-specific waterproof shell

- Main shell with a phone cavity and a 12 mm example connector bay beyond the phone's USB edge.
- 2 mm polycarbonate front window. Do not 3D-print the window.
- Separate bezel, fastened with eight M3 screws into heat-set inserts.
- Continuous silicone gasket groove around the viewing opening.
- Four rear support pads, camera-island relief and a protected shallow cable raceway.
- Sealed cable-gland entry through the rear wall. The USB pigtail remains inside the dry cavity until it passes through the gland.

The touchscreen is operated through the real polycarbonate sheet. The example screen gap is 0.8 mm; this needs testing with the chosen phone and screen protector. Too much gap can make touch unreliable; too little can place pressure on the display.

### 2. Common rear shoe

The shoe bolts to four blind inserts in the back of the shell. Its two dovetail rails are the common interface for every phone-specific shell. The shoe contains a replaceable contact-cartridge pocket and a cable pass-through. Do not hardwire electrical contacts into the printed plastic.

### 3. Handlebar-side receiver and keyed draw-in

The receiver is fixed to a **metal handlebar clamp/bracket**, not directly to the handlebar using printed plastic. The rails enter from the top and slide down to the lower stop.

The design intentionally has a **2.0 mm pre-seat gap** between the shoe and receiver. Once the rails are seated, a keyed metal draw-cam catches the metal striker and pulls the shoe inward by approximately 2.0 mm. That final movement brings the recessed electrical contact cartridges together along their mating axis. The contacts therefore do not scrape while the case slides into the rails.

This requires a genuine keyed draw-in cam or a metal cam/pawl with a ramped engagement face. A simple quarter-turn cam that merely blocks the striker will not provide the required draw-in stroke. Match the striker notch and lock bore to the purchased lock's technical drawing before printing a final receiver.

The current receiver includes a 19 mm example lock bore and an 8 mm example striker. Those dimensions are placeholders, not a commitment to a particular lock. The striker, cam and final retention load path should be metal. Add an independent secondary safety catch or tether before road use.

The receiver's four M6 holes are a 96 × 68 mm example mounting pattern for a metal adapter plate. Measure the actual handlebar diameter and selected clamp location before designing that plate. Do not assume a handlebar size from the motorcycle model name.

## Example envelope (not your phone's measured dimensions)

The source currently contains a dummy profile of 75 × 160 × 9 mm. With its current clearances, bottom plug bay and flange, the shell is approximately 98 × 195 mm before considering the handlebar receiver. Replace the dummy values before printing a phone shell.

Measure the phone itself, without a soft case:

- body width, length and thickness;
- corner radius or corner-profile tracing;
- camera island width, height, centre position and protrusion;
- USB port position, orientation and plug clearance;
- active display boundary and safe bezel overlap;
- side-button positions, if sealed button actuators are required.

The V1 model does not yet include sealed side-button actuators. Keep the phone accessible for power-button operation until a phone-specific actuator design is added.

## Sealing and materials

| Part | Starting material / component |
|---|---|
| Main case and bezel | ASA for FDM, or PA12 from SLS/MJF |
| Rear shoe and receiver | Prototype in PA12/ASA; replace or reinforce load-bearing features with metal |
| Front window | 2 mm polycarbonate sheet, edges deburred |
| Window seal | Approximately 2 mm silicone cord; current groove is 2.4 mm wide × 1.5 mm deep |
| Cable entry | Correctly sized IP-rated cable gland with strain relief |
| Fasteners | Stainless M3 bezel screws, M4 shoe screws, M6 receiver-to-bracket hardware |
| Phone supports | Thin silicone or EVA pads on the four support pads |

The present groove is designed around a 2 mm cord protruding about 0.5 mm above the case face before compression. Confirm the actual cord supplier's compression guidance and tune the groove. The outer flange should act as a compression stop; the window must not bow.

A printed part is not automatically waterproof. Layer porosity, print orientation, seam quality, insert holes, window flatness and cable-gland installation all affect leakage. Seal the printed shell after a test print if necessary, and do not use a coating that attacks the phone, polycarbonate or gasket.

For rain protection, use a hydrophobic pressure-equalisation vent only if needed and only as a rated component with its own sealed mounting. Do not drill an unsealed vent hole. Add a small replaceable desiccant pack during early tests, but do not treat it as a substitute for sealing.

## Electrical design summary

The dock carries a four-wire USB 2.0 path through the contact cartridge:

| USB signal | Purpose |
|---|---|
| VBUS | Regulated +5 V |
| D− | USB data pair |
| D+ | USB data pair |
| GND | Power and signal return |
| Shield | Connector/cable shield, bonded according to the selected connector and host design |

The cartridge pocket dimensions in the SCAD file are **placeholders**. Before revising them, select an actual blind-mate USB 2.0 connector that supports the 2 mm axial draw-in movement, carries the required current, and is sealed for the mated condition. Do not substitute generic loose pogo pins for the USB data pair. USB 2.0 high-speed routing requires a controlled differential pair; the nominal differential impedance is 90 Ω ±15% in the cited Renesas guidance.

Use a dock-detect switch or fifth auxiliary contact to keep VBUS disabled until the cradle is fully seated and locked. It is an interlock only; it is not one of the four USB wires. Prefer a connector with ground-first / ground-last sequencing if the selected design supports it.

The bike-side supply should be ignition-switched and include a fuse close to the source, reverse-polarity protection, transient suppression and an automotive-rated 12 V-to-5 V converter. Set the current limit to the selected connector's rating. A USB connector's current rating does not by itself mean that a USB host can provide that current.

**Important USB-role distinction:** 5 V power alone does not create a data link. For the phone to enumerate as a USB device, the bike-side unit must be a USB host and the exact Android phone must support the required USB data/charging arrangement. Test simultaneous charging and data transfer with the actual phone before committing to the connector.

See `WIRING.md` for the signal path and bring-up checklist.

## Prototype sequence

1. Print a low-cost phone-profile gauge or an open-top fit shell first. Check phone fit and camera/port clearances without a window.
2. Print the shell and bezel in the intended material. Fit the real polycarbonate sheet and silicone cord; check even gasket compression.
3. Fit the actual cable gland and phone-side USB pigtail. Confirm the phone charges and transfers data through the chosen host arrangement.
4. Prototype the rear shoe and receiver with dummy connector blocks. Verify top-in rail travel, 2 mm draw-in, lock engagement and release.
5. Only after choosing the real blind-mate connector, update the contact-cartridge pockets from its manufacturer drawing.
6. Replace the printed striker/cam load path with metal components. Attach the receiver to a metal handlebar clamp adapter and add a secondary safety catch.
7. Test the empty enclosure with dry tissue inside: light rain spray from several angles, then a longer low-pressure spray test. Do not use a pressure washer or immersion test for this rain-only design.
8. Test on the bike without a phone first. Check vibration, steering clearance, cable strain relief, connector retention and visibility. Then run a phone-temperature test in direct sun while charging and navigating.

## Current limitations

- Phone dimensions, camera and USB-port positions are dummy values.
- The selected keyed draw-cam and blind-mate USB 2.0 cartridge are not yet specified by manufacturer part number.
- The receiver-to-handlebar metal adapter is not included because the actual bar diameter and mounting location have not been measured.
- The case has not been water-spray, thermal, drop or vibration tested.
- The design is intended for rain resistance, not immersion or pressure washing.
- The enclosed phone may overheat in direct sun while charging. Reduce/disable charging if temperature rises, and do not place the case near exhaust or cylinder-head heat.

## References

- [Amphenol LTW USB Type-A 2.0 connector example](https://amphenolltw.com/product-info/USB/USB.TypeA2.0/UA20FL-NAML-SA004.html) — manufacturer listing shows USB 2.0, 1.5 A nominal current and IP67 when mated. This is a reference for the kind of sealed USB assembly to investigate, **not** the selected blind-mate cartridge for this CAD.
- [Renesas: Guidelines for Hi-Speed USB 2.0 Board Design](https://www.renesas.com/en/document/apn/guidelines-hi-speed-usb-20-board-design-rej06b0918-0100) — USB 2.0 differential impedance guidance.

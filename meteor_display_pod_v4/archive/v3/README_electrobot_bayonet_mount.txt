ELECTROBOT ROUND DISPLAY - MOTORCYCLE BAYONET MOUNT (PROTOTYPE)

Files
- electrobot_bayonet_mount_v3.scad : editable parametric source
- pod_v3.stl                    : circular display enclosure
- rear_cover_v3.stl             : removable service cover
- receiver_v3.stl               : 3-lug female bayonet receiver
- clamp_lower_v3.stl            : lower handlebar clamp half
- clamp_upper_v3.stl            : upper clamp half / receiver seat
- fit_coupon_v3.stl             : female bayonet fit coupon
- male_coupon_v3.stl            : matching male spigot/lug fit coupon

Open the SCAD file in OpenSCAD and set `part` to one of:
assembly, pod, rear_cover, receiver, clamp_lower, clamp_upper, fit_coupon, male_coupon.

MECHANISM
- Three lugs at 120 degrees.
- Straight axial entry slots followed by 30 degree circumferential tracks.
- Track has a nominal 0.4 mm axial cam ramp to compress a 1.5 mm cross-section O-ring.
- A commercial M5 stainless spring-ball plunger engages a notch on a lug at the locked position.
- Unlock by rotating the pod counter-clockwise about 30 degrees and lifting. No release button.

STARTING PARAMETERS (MUST BE VERIFIED)
- PCB envelope: 42 x 42 x 9.8 mm, provisional only.
- Pod outside diameter: 66 mm.
- Display aperture: 34 mm.
- Handlebar bore: 22.2 mm + 0.5 mm diametral clearance.
- Receiver socket ID: spigot diameter + 0.8 mm diametral entry clearance.
- Bayonet track clearance: 0.25 mm per side.
- M5 clamp bolts; M4 receiver bolts; M2.5 cover screws with heat-set inserts.
- USB-C opening is enabled but its angle/height are provisional. Buttons are disabled by default.

FIRST PRINT / FITTING
1. Print fit_coupon_v3.stl and male_coupon_v3.stl first.
2. Test insertion and rotation. Adjust entry_clear and track_clear in the SCAD file for your printer/material.
3. Only then print the receiver and pod.
4. Measure the actual Electrobot PCB, USB-C position, button locations, and handlebar centre diameter. Update parameters before final printing.
5. Fit a 1.5 mm cross-section silicone O-ring in the receiver groove.
6. Tap the receiver detent bore M5 and install a stainless spring-ball plunger. Confirm plunger thread, length and ball travel before drilling/tapping.
7. Use M5 clamp bolts with locking nuts, M4 receiver fasteners, and M2.5 heat-set inserts for the rear cover.

PRINT / SAFETY NOTES
- Prototype only. The model has not been physically fit-tested or vibration-tested on a motorcycle.
- Do not rely on this printed version for highway use until tested for retention, vibration, fatigue, heat, UV, water ingress and steering clearance.
- Use ASA or another UV/heat-resistant engineering filament; avoid PLA for a sun-exposed motorcycle part.
- The printed bayonet lugs and receiver are prototype geometry. For a road-going build, consider metal lug/receiver reinforcement and verify the assembly with a proper pull-off and vibration test.
- Clamp bore is nominal. Measure the actual straight centre section of the handlebar and check that the clamp does not interfere with the risers, cables, controls, tank or steering movement.
- Rain-splash design only; not an IP-rated enclosure. Seal the screen edge, USB port and rear cover appropriately.

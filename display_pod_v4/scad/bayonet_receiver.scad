// =============================================================================
// Part C — Bayonet receiver (female), a separate replaceable ring
//
// Receiver frame: z = 0 at the top land, the part extends to z = -receiver_h.
// Angles match the pod frame with the pod LOCKED.
//
// Each lug has an L-shaped path:
//   1. Axial ENTRY SLOT at (lock angle + 30°), open at the top. The lug drops
//      until the cover rear face lands on the receiver top (insertion stop).
//   2. Circumferential TRACK from the entry slot back to the lock angle. The
//      track's closed end is the positive ROTATION STOP. The track ceiling
//      (3.2 mm of material) gives AXIAL RETENTION.
// The detent ball sits in the top land. It pushes the pod outward, so in the
// locked position the lugs are preloaded up against the track ceilings with no
// rattle, and the ball clicks into the cover dimple.
// The slots and tracks do NOT break through the outside wall: the receiver is a
// closed ring from outside. A notch at the bottom drains water.
//
// Print: TOP LAND DOWN. The track ceilings (load faces) then print as clean top
// surfaces, and the entry slots open onto the bed.
// =============================================================================
include <parameters.scad>
use <lib.scad>

module receiver() {
    r_cut_in = receiver_id / 2 - 1;
    difference() {
        translate([0, 0, -receiver_h]) cylinder(d = receiver_od, h = receiver_h);

        // Bore + lead-in chamfer
        translate([0, 0, -receiver_h - 1]) cylinder(d = receiver_id, h = receiver_h + 2);
        translate([0, 0, -receiver_lead_chamfer])
            cylinder(d1 = receiver_id, d2 = receiver_id + 2 * receiver_lead_chamfer, h = receiver_lead_chamfer + eps);

        for (i = [0 : lug_count - 1]) {
            L = lug_angles[i];
            w = lug_widths[i];
            // 1. Axial entry slot (at the insertion angle)
            radial_block(L + lock_rotation, r_cut_in, track_r_out, w + 2 * entry_clear,
                         z_track_floor, 1);
            // Lead-in chamfer on the slot mouth
            hull() {
                radial_block(L + lock_rotation, r_cut_in, track_r_out, w + 2 * entry_clear, -0.6, 1);
                radial_block(L + lock_rotation, r_cut_in, track_r_out + 0.6, w + 2 * entry_clear + 1.2, -eps, 1);
            }
            // 2. Circumferential locking track, ending in the rotation stop at angle L
            arc_sweep(L, L + lock_rotation, r_cut_in, track_r_out, w + 2 * track_clear,
                      z_track_floor, z_track_ceiling);
        }

        // M4 spring-ball plunger: tapped hole straight through (adjust from below)
        at_polar(detent_angle, detent_r, -receiver_h - 1) cylinder(d = detent_tap_d, h = receiver_h + 2, $fn = 32);

        // Radial pilot holes for M3 thread-forming screws from the mount cup
        for (a = receiver_mount_screw_angles)
            at_polar(a, receiver_od / 2 + 1, -receiver_h + receiver_mount_screw_z)
                rotate([0, -90, 0]) cylinder(d = receiver_pilot_d, h = 5.5, $fn = 24);

        // Anti-rotation key notch (matches rib in the mount cup)
        radial_block(receiver_key_angle, receiver_od / 2 - key_rib_depth - 0.2, receiver_od / 2 + 1,
                     key_rib_w + 0.4, -receiver_h - 1, -receiver_h + receiver_base_t);

        // Drain notch at the lowest point
        radial_block(receiver_drain_angle, r_cut_in, receiver_od / 2 + 1, 3.0,
                     -receiver_h - 1, -receiver_h + 1.5);
    }
}

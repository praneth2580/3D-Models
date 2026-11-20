// =============================================================================
// Part D — Handlebar mount (two-piece split clamp + tilted receiver cup)
//
// Mount frame: X = handlebar axis, Y = forward, Z = up, origin on the bar axis.
//
//  * A 1.5 mm split gap between the halves lets the bolts actually squeeze
//    the bar. In v3 the halves met face to face, so they could never grip.
//    Wrap the bar in a 1 mm rubber shim (EPDM or inner tube).
//  * Two M5 bolts go in from below. M5 nyloc nuts slide into side slots in
//    the upper half (correct 8 mm across-flats hex pockets).
//  * The receiver sits in a cup tilted `display_tilt` toward the rider. Three
//    radial M3 thread-forming screws hold it, plus a key rib so it can only go
//    in one way. A drain slot sits at the cup's lowest point.
//
// PROVISIONAL: the bar diameter, free bar length, tilt and cup position must be
// checked on your own bike before printing.
// Print: clamp_upper with the split face down. clamp_lower with the split face down.
// =============================================================================
include <parameters.scad>
use <lib.scad>

// Transform into the cup frame (= receiver frame, with z = 0 on the cup floor)
module cup_frame() {
    translate([0, cup_offset_y, cup_floor_z]) rotate([display_tilt, 0, 0]) children();
}

// Clamp block with rounded long edges (edges parallel to the bar)
module clamp_block(z0, z1) {
    r = 3;
    hull() for (y = [-clamp_half_y + r, clamp_half_y - r], z = [z0 + r, z1 - r])
        translate([0, y, z]) rotate([0, 90, 0]) cylinder(r = r, h = clamp_w, center = true, $fn = 32);
}

module bar_bore() { rotate([0, 90, 0]) cylinder(d = bar_bore_d, h = clamp_w + 2, center = true); }

module clamp_lower() {
    difference() {
        clamp_block(-clamp_half_z, -clamp_split_gap / 2);
        bar_bore();
        for (s = [-1, 1]) translate([0, s * clamp_bolt_offset, 0]) {
            translate([0, 0, -clamp_half_z - 1]) cylinder(d = clamp_bolt_d, h = clamp_half_z + 2, $fn = 32);
            translate([0, 0, -clamp_half_z - 1]) cylinder(d = clamp_bolt_head_d, h = clamp_bolt_head_h + 1, $fn = 40);
        }
    }
}

module clamp_upper() {
    cup_r_in = receiver_od / 2 + cup_clear;
    difference() {
        union() {
            clamp_block(clamp_split_gap / 2, clamp_half_z);
            // Tower: from the top of the clamp to the underside of the cup
            hull() {
                translate([-clamp_w / 2, -clamp_half_y + 3, clamp_half_z - 1]) cube([clamp_w, 2 * clamp_half_y - 6, 1]);
                // hull target sits inside the cup solid so no faces coincide
                cup_frame() translate([0, 0, -cup_floor_t + 0.5]) cylinder(d = cup_wall_od - 1.0, h = cup_floor_t - 1.0);
            }
            // Cup floor + wall as one solid (avoids coincident faces)
            cup_frame() translate([0, 0, -cup_floor_t]) cylinder(d = cup_wall_od, h = cup_floor_t + cup_depth);
        }
        bar_bore();
        // Bolt holes + nyloc nut pockets with side-entry slots
        for (s = [-1, 1]) translate([0, s * clamp_bolt_offset, 0]) {
            translate([0, 0, 0]) cylinder(d = clamp_bolt_d, h = clamp_nut_z0 + clamp_nut_h + 4, $fn = 32);
            translate([0, 0, clamp_nut_z0]) rotate([0, 0, 30]) hex_prism(clamp_nut_af + 0.3, clamp_nut_h);
            translate([-(clamp_nut_af + 0.3) / 2, s > 0 ? 0 : -20, clamp_nut_z0])
                cube([clamp_nut_af + 0.3, 20, clamp_nut_h]);
        }
        // Cup bore
        cup_frame() cylinder(r = cup_r_in, h = cup_depth + 30);
        cup_frame() {
            // Radial screw clearance holes (pan heads seat on the curved wall)
            for (a = receiver_mount_screw_angles)
                rotate([0, 0, a]) translate([0, 0, receiver_mount_screw_z]) rotate([0, 90, 0])
                    rotate([0, 0, 7.5]) cylinder(d = cup_screw_clear_d, h = cup_wall_od, $fn = 24); // half-facet twist avoids coincident vertices
            // Drain slot at the lowest point of the cup floor
            radial_block(receiver_drain_angle, cup_r_in - 3, cup_wall_od, 3.0, -0.2, 1.5);
        }
    }
    // Anti-rotation key rib inside the cup
    cup_frame() radial_block(receiver_key_angle, cup_r_in - key_rib_depth, cup_r_in + 0.2,
                             key_rib_w, 0, receiver_base_t - 0.5);
}

// =============================================================================
// Part B — Rear service cover
//
//  * Closes the housing rear with a flat 1.0 mm gasket in a 0.7 mm pocket
//    (30 % compression). The outer rim lands hard on the housing as a
//    compression stop.
//  * Holds the battery in a bay behind the board retainer, with 1 mm of room to
//    swell. The cell is never clamped.
//  * Carries the male bayonet (spigot + 3 lugs) and the detent dimple.
//  * Three M2 x 8 socket-cap screws into heat-set inserts in the housing. Their
//    heads sit flush in counterbores and are hidden by the receiver when mounted.
//    Uneven spacing means the cover only fits one way.
//
// Print: FRONT (GASKET) FACE DOWN. The battery-bay end wall bridges 21 mm. The
// lugs' load faces overhang 2.4 mm, which prints fine without support.
// =============================================================================
include <parameters.scad>
use <lib.scad>
use <bayonet_lugs.scad>

module cover_body_solid() {
    R = cover_od / 2;
    hull() {
        translate([0, 0, z_cover_rear + cover_rear_edge_r])
            rotate_extrude() translate([R - cover_rear_edge_r, 0]) circle(r = cover_rear_edge_r);
        translate([0, 0, z_cover_rear + cover_rear_edge_r]) cylinder(r = R, h = -z_cover_rear - cover_rear_edge_r);
    }
}

module rear_cover() {
    difference() {
        union() {
            cover_body_solid();
            spigot_with_lugs();
        }
        // Battery bay (open toward the board)
        translate([0, 0, z_bay_floor])
            linear_extrude(-z_bay_floor + 1)
                rounded_rect([battery_l + 2 * battery_side_clear, battery_w + 2 * battery_side_clear], 1.5);
        // Gasket pocket
        translate([0, 0, -gasket_pocket_depth]) ring(gasket_pocket_od, gasket_pocket_id, gasket_pocket_depth + 1);
        // Screw clearance + counterbores from the rear face
        for (a = cover_screw_angles) at_polar(a, cover_screw_r) {
            translate([0, 0, z_cover_rear - 1]) cylinder(d = cover_screw_clear_d, h = -z_cover_rear + 2);
            translate([0, 0, z_cover_rear - 1]) cylinder(d = cover_screw_head_d, h = cover_screw_head_h + 1);
        }
        detent_dimple();
    }
}

// Flat gasket (cut from 1 mm silicone/EPDM sheet, or print in TPU 85A-95A)
module cover_gasket_2d() {
    difference() {
        circle(d = gasket_od);
        circle(d = gasket_id);
        for (a = cover_screw_angles) rotate(a) translate([cover_screw_r, 0]) circle(d = cover_screw_clear_d + 0.2);
    }
}
module cover_gasket() { translate([0, 0, -gasket_pocket_depth]) linear_extrude(gasket_t) cover_gasket_2d(); }

// Quick-print male test piece: cover rear face disc + spigot + lugs + dimple.
// Print this and the receiver first to tune entry_clear / track_clear.
module bayonet_test_male() {
    difference() {
        union() {
            translate([0, 0, z_cover_rear]) cylinder(d = receiver_od + 4, h = 2.0);
            spigot_with_lugs();
        }
        detent_dimple();
    }
}

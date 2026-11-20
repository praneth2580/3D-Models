// =============================================================================
// Part A — Main housing
//
// One-piece front + side wall. The board, with its display, slides in from the
// rear and is pushed forward onto the front ledge by the retainer plate. No
// screws are visible from the front. Three M2 heat-set inserts in the rear face
// take the rear-cover screws.
//
// Print: REAR FACE DOWN (flat gasket face on the bed, rounded front edge on top).
// =============================================================================
include <parameters.scad>
use <lib.scad>
use <front_bezel.scad>

module housing() {
    difference() {
        housing_outer_solid();

        board_bore_cut();
        front_window_cuts();

        // USB tab pocket: lets the tab and its mid-mount USB-C slide in from the rear
        translate([-(board_tab_w / 2 + tab_pocket_clear), -(board_tab_edge_r + 0.05), -1])
            cube([board_tab_w + 2 * tab_pocket_clear, board_tab_edge_r + 0.05 - 14, z_pcb_front + 0.3 + 1]);

        // Extra room for the display FPC folding round the tab edge (the side away from the USB)
        fpc_x0 = usb_offset_x + usb_w / 2 + 0.5;
        translate([fpc_x0, -(board_tab_edge_r + fpc_fold_clear), z_pcb_rear - 0.5])
            cube([board_tab_w / 2 + tab_pocket_clear - fpc_x0, fpc_fold_clear + 1,
                  z_ledge_rear - (z_pcb_rear - 0.5)]);

        // USB-C: window through the thin front wall, then a recess for the plug over-mould
        y_wall_in  = board_tab_edge_r + 0.05;
        y_wall_out = y_wall_in + usb_front_wall;
        translate([usb_offset_x - (usb_w + 0.6) / 2, -(y_wall_out + 0.1), z_usb - (usb_h + 0.6) / 2])
            cube([usb_w + 0.6, usb_front_wall + 0.2, usb_h + 0.6]);
        translate([usb_offset_x - usb_plug_w / 2, -(housing_rear_od / 2 + 2), z_usb - usb_plug_h / 2])
            cube([usb_plug_w, housing_rear_od / 2 + 2 - y_wall_out, usb_plug_h]);

        // Slide-switch actuator clearance (runs from the rear so the board slides in)
        radial_block(switch_angle, bore_d / 2 - 0.5, board_d / 2 + switch_nub_out + 0.4, 6.0,
                     -1, z_switch + 1.2);
        // Optional access slot to operate the power switch with a pen tip
        if (switch_access)
            radial_block(switch_angle, bore_d / 2 - 0.5, housing_rear_od / 2 + 2, switch_slot_w,
                         z_switch - switch_slot_h / 2, z_switch + switch_slot_h / 2);

        // M2 heat-set insert holes in the rear face (with entry chamfer)
        for (a = cover_screw_angles) at_polar(a, cover_screw_r) {
            translate([0, 0, -1]) cylinder(d = insert_hole_d, h = insert_hole_depth + 1);
            translate([0, 0, -1]) cylinder(d1 = insert_hole_d + 2.4, d2 = insert_hole_d, h = 1.0 + 0.6);
        }
    }
}

// TPU plug for the USB-C recess (print in TPU 95A). Nub seals the receptacle mouth.
module usb_plug() {
    body_w = usb_plug_w - 0.1;
    body_h = usb_plug_h - 0.1;
    body_d = 3.0;
    // Flange (outside), body (in the recess), nub (into the USB-C receptacle)
    translate([0, 0, 0]) linear_extrude(1.0) rounded_rect([body_w + 2.0, body_h + 2.0], 1.5);
    translate([0, 0, 1.0 - eps]) linear_extrude(body_d) rounded_rect([body_w, body_h], 1.0);
    translate([0, 0, 1.0 + body_d - eps]) linear_extrude(2.5) rounded_rect([usb_w - 0.7, usb_h - 0.9], 1.0);
    // Pull tab
    translate([body_w / 2 + 0.5, -2, 0]) cube([5, 4, 1.0]);
}

// =============================================================================
// Round display pod v4 — part selector, assembly and clearance checks
//
//   openscad -D 'part="housing"' -o ../exports/housing.stl main.scad
//
// Parts are emitted in their recommended PRINT orientation.
// "assembly" shows everything on the handlebar with the pod locked.
// "check_*" parts render the overlap between two parts. A passing check
// produces EMPTY geometry (tools/check.sh runs them all).
// =============================================================================
include <parameters.scad>
use <lib.scad>
use <front_bezel.scad>
use <display_housing.scad>
use <pcb_mounts.scad>
use <rear_cover.scad>
use <bayonet_lugs.scad>
use <bayonet_receiver.scad>
use <handlebar_mount.scad>

part = "assembly";
explode = 0;          // mm, for the assembly view

echo(str("REPORT housing_depth=", housing_depth,
         " pod_visible_depth=", pod_visible_depth,
         " front_od=", housing_front_od, " rear_od=", housing_rear_od,
         " visible_front_ring=", (housing_front_od - lens_recess_d) / 2,
         " aperture=", aperture_d, " lens_d=", lens_d,
         " receiver_h=", receiver_h, " plunger_stroke_min=", plunger_stroke_min));
echo(str("REPORT z: pcb_rear=", z_pcb_rear, " pcb_front=", z_pcb_front, " glass_front=", z_glass_front,
         " usb=", z_usb, " bay_floor=", z_bay_floor, " cover_rear=", z_cover_rear, " spigot_tip=", z_spigot_tip));
echo("PROVISIONAL (verify before final print): pcb_t, display_glass_d, rear_component_h, usb_offset_x, usb plug size, switch position, battery size, detent ball, bar_d, clamp_w, display_tilt, cup position");

// ---- Assembly helpers ---------------------------------------------------------
// Pod frame -> receiver frame when locked
module pod_locked() { translate([0, 0, lock_gap - z_cover_rear]) children(); }

module pod_parts() {
    color("DimGray")      translate([0, 0, explode * 2]) housing();
    color("LightBlue", 0.5) translate([0, 0, explode * 3]) lens();
    color("Orange", 0.6)  translate([0, 0, explode * 1]) board_envelope();
    color("Silver")       translate([0, 0, explode * 0.5]) board_retainer();
    color("Gold", 0.7)    battery_envelope();
    color("Black")        translate([0, 0, -explode * 0.5]) cover_gasket();
    color("DarkSlateGray") translate([0, 0, -explode]) rear_cover();
}

module assembly() {
    color("SlateGray") clamp_lower();
    color("SlateGray") clamp_upper();
    color("DarkGray", 0.8) cup_frame() translate([0, 0, receiver_h]) receiver();
    cup_frame() translate([0, 0, receiver_h + explode * 2]) pod_locked() pod_parts();
}

// Single lug (pod frame) for sweep checks
module one_lug(i, z_tip) {
    radial_block(lug_angles[i], lug_r_in, lug_r_out, lug_widths[i], z_tip, z_tip + lug_h);
}

// ---- Part selector --------------------------------------------------------------
if (part == "assembly") assembly();
else if (part == "pod") pod_parts();

// Printable parts, in print orientation
else if (part == "housing")           housing();
else if (part == "rear_cover")        rotate([180, 0, 0]) rear_cover();
else if (part == "board_retainer")    translate([0, 0, z_ret_front]) rotate([180, 0, 0]) board_retainer();
else if (part == "receiver")          rotate([180, 0, 0]) receiver();
else if (part == "clamp_upper")       translate([0, 0, -clamp_split_gap / 2]) clamp_upper();
else if (part == "clamp_lower")       translate([0, 0, -clamp_split_gap / 2]) rotate([180, 0, 0]) clamp_lower();
else if (part == "usb_plug")          usb_plug();
else if (part == "cover_gasket")      linear_extrude(gasket_t) cover_gasket_2d();
else if (part == "bayonet_test_male") translate([0, 0, z_cover_rear + 2]) rotate([180, 0, 0]) bayonet_test_male();

// 2D templates (export as DXF/SVG)
else if (part == "lens_2d")            lens_2d();
else if (part == "display_gasket_2d")  display_gasket_2d();
else if (part == "cover_gasket_2d")    cover_gasket_2d();
else if (part == "retainer_foam_2d")   retainer_foam_2d();

// Section view for visual inspection
else if (part == "section") difference() { pod_parts(); translate([0, -50, -30]) cube([60, 100, 80]); }

// ---- Clearance checks (empty result = pass) --------------------------------------
else if (part == "check_board_housing")    intersection() { housing(); board_envelope(); }
else if (part == "check_board_retainer")   intersection() { board_retainer(); board_envelope(); }
else if (part == "check_retainer_housing") intersection() { board_retainer(); housing(); }
else if (part == "check_cover_housing")    intersection() { translate([0, 0, -0.02]) rear_cover(); housing(); }
else if (part == "check_battery")
    intersection() { battery_envelope(); union() { housing(); rear_cover(); translate([0, 0, 0.02]) board_retainer(); } }
else if (part == "check_bayonet_locked")
    intersection() { receiver(); translate([0, 0, -0.02]) pod_locked() rear_cover(); }
else if (part == "check_bayonet_insert")   // straight push-in at the entry angle
    intersection() {
        receiver();
        rotate([0, 0, lock_rotation]) for (i = [0 : lug_count - 1]) hull() {
            one_lug(i, -spigot_len + 0.02);
            one_lug(i, 10);
        }
    }
else if (part == "check_bayonet_rotate")   // 30° twist with the cover resting on the land
    intersection() {
        receiver();
        for (i = [0 : lug_count - 1])
            arc_sweep(lug_angles[i], lug_angles[i] + lock_rotation, lug_r_in, lug_r_out, lug_widths[i],
                      -spigot_len + 0.02, -spigot_len + 0.02 + lug_h, 1);
    }
else if (part == "check_bayonet_pullout")  // locked lugs lifted 0.5 mm must hit the ceiling
    intersection() { receiver(); translate([0, 0, 0.5]) pod_locked() lugs(); }
else if (part == "check_wrong_orientation") // wide lug in a narrow slot must collide
    intersection() { receiver(); rotate([0, 0, lock_rotation + 120]) for (i = [0 : lug_count - 1]) one_lug(i, -2); }
else if (part == "check_pod_mount")
    intersection() {
        union() { clamp_upper(); clamp_lower(); }
        cup_frame() translate([0, 0, receiver_h + 0.02]) pod_locked() union() { housing(); rear_cover(); }
    }
else if (part == "check_receiver_mount")
    intersection() { union() { clamp_upper(); clamp_lower(); } cup_frame() translate([0, 0, receiver_h + 0.02]) receiver(); }

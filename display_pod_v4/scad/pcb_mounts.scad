// =============================================================================
// Board retention (the board has no mounting holes — vendor says "adhesive")
//
// Board retainer plate: a printed disc behind the board. A 1.5 mm foam pad on its
// front face presses on the tops of the rear components and pushes the display
// forward onto the front ledge, so the board is clamped front-to-back. The plate
// also separates the battery from the electronics and the backlight.
//   - Four legs stand on the rear cover; tightening the cover sets the clamp.
//   - A key tab in the USB pocket fixes its rotation so the button holes line up.
//   - Holes over RST/BOOT stop the foam pressing the buttons.
//   - An edge notch passes the battery lead to the JST socket.
//
// Also: a simplified board envelope, used only for clearance checks.
// =============================================================================
include <parameters.scad>
use <lib.scad>

retainer_d = bore_d - 2 * retainer_clear;

module retainer_2d_outline() {
    difference() {
        union() {
            circle(d = retainer_d);
            // Key tab into the USB tab pocket
            translate([-(board_tab_w - 0.6) / 2, -(board_tab_edge_r - 0.2)])
                square([board_tab_w - 0.6, board_tab_edge_r - 0.2 - 14]);
        }
        // Button reliefs
        for (b = [[rst_angle, rst_r], [boot_angle, boot_r]])
            rotate(b[0]) translate([b[1], 0]) circle(d = button_relief_d);
        // Battery lead notch at the edge near the JST socket
        rotate(bat_conn_angle) translate([bat_conn_r - 0.5, -3]) square([20, 6]);
    }
}

// In pod frame
module board_retainer() {
    translate([0, 0, z_ret_rear]) linear_extrude(retainer_t) retainer_2d_outline();
    // Legs from the plate down to the rear-cover front face (z = 0)
    for (a = push_post_angles) at_polar(a, push_post_r)
        translate([-push_post_size / 2, -push_post_size / 2, 0])
            cube([push_post_size, push_post_size, z_ret_rear + eps]);
}

// Foam pad template (cut from 1.5 mm EVA / PORON)
module retainer_foam_2d() {
    difference() {
        circle(d = retainer_d - 1.0);
        for (b = [[rst_angle, rst_r], [boot_angle, boot_r]])
            rotate(b[0]) translate([b[1], 0]) circle(d = button_relief_d);
        rotate(bat_conn_angle) translate([bat_conn_r - 3, -4]) square([20, 8]);
    }
}

// ---- Simplified board envelope (pod frame) for interference checks -------------
module board_envelope() {
    // PCB + tab
    translate([0, 0, z_pcb_rear]) linear_extrude(pcb_t) union() {
        circle(d = board_d);
        translate([-board_tab_w / 2, -board_tab_edge_r]) square([board_tab_w, board_tab_edge_r - 14]);
    }
    // Display stack (glass, LCD, backlight, foam) — modelled solid
    translate([0, 0, z_pcb_front]) cylinder(d = display_glass_d, h = glass_to_pcb);
    // Rear components zone (kept just inside the edge)
    translate([0, 0, z_comp_rear]) cylinder(d = board_d - 1.0, h = rear_component_h);
    // USB-C receptacle (7.35 mm long, face flush with the tab edge)
    translate([usb_offset_x - usb_w / 2, -board_tab_edge_r, z_usb - usb_h / 2])
        cube([usb_w, 7.35, usb_h]);
    // Slide-switch actuator
    radial_block(switch_angle, board_d / 2 - 1, board_d / 2 + switch_nub_out, 1.5,
                 z_switch - 0.6, z_switch + 0.6);
    // Display FPC fold round the tab edge
    translate([usb_offset_x + usb_w / 2 + 0.6, -(board_tab_edge_r + 0.5), z_pcb_rear])
        cube([board_tab_w / 2 - (usb_offset_x + usb_w / 2 + 0.6), 0.5, z_glass_front - z_pcb_rear]);
}

// Battery envelope (pod frame), centred in the bay, long side along X
module battery_envelope() {
    translate([-battery_l / 2, -battery_w / 2, z_bay_floor]) cube([battery_l, battery_w, battery_t]);
}

/*
  Modular handlebar navigation dock (landscape phone)
  Version: 0.4 concept prototype (0.2 and 0.3 are archived in archive/)
  Units: millimetres

  MODULE STACK (each joint is a fixed, documented interface so any module can be swapped later)

    handlebar
      | 2 x bar clamps, either side of the bar centre (shims for 22.2 / 25.4 / 28.6 mm bars).
      |   Rotating both clamps on the bar sets the screen tilt.
      |   Interface A: each clamp pad = 2 x M5 on a 36 mm fore-aft pitch.
      v
    base plate (swap later for a "smart base": Arduino, speakers, ...)
      | Slots give 110-210 mm clamp spacing.
      |   Interface B: AMPS pattern (4 x M5, 30 x 38 mm) through rubber grommets,
      |   plus a 14 mm central cable hole.
      v
    receiver (dock): dovetail channels, spring-pin contacts, USB-C socket, key lock
      |   Interface C: dovetail shoe + bottom-edge contacts + lock slot.
      v
    phone case (landscape, phone-specific) + rear shoe

  COORDINATE FRAMES
  Case frame:  X = case long axis (landscape), Y = up the screen, Z = out of the screen.
               Origin at cavity centre; z = 0 is the outside back face of the case.
  Dock frame:  same axes, origin at the shoe centre (case back plane). Shoe + receiver live here.
  Plate frame: X along the handlebar, Y forward (toward the screen top), Z = plate normal.
               Origin at the centre of the base plate's top face.
  Clamp/bike frame: X along the handlebar, origin on the bar axis at the bike's centre line,
               Y forward, Z up (before tilt).

  Placeholders are marked MEASURE or SELECT. Do not print final parts until they are replaced.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "case", "bezel", "window_template", "shoe", "receiver", "ledge_lid",
// "base_plate", "base_plate_2d" (DXF, metal option), "clamp_body", "clamp_cap",
// "bar_shim", "pad_spacer", "cam_template"
PART = "assembly";
SHOW_PHONE = true;
SHOW_WINDOW = true;
SHOW_BAR = true;            // ghost handlebar in the assembly view
EXPLODE = 0;

$fn = 64;

// ------------------------- PHONE PROFILE ----------------------------
// MEASURE: example values only (phone held in portrait: w = short side, l = long side).
phone_w = 75.0;
phone_l = 160.0;
phone_t = 9.0;
phone_corner_r = 9.0;
usb_side = 1;               // landscape: +1 = USB-C port on the right, -1 = on the left

side_clearance = 0.60;
end_clearance = 0.60;
front_gap = 0.80;
back_pad = 2.00;

// Camera island, measured in portrait: camera_x across the width, camera_y from the
// phone centre toward the phone's top edge.
camera_relief_enable = true;
camera_x = 0;
camera_y = 62;
camera_w = 34;              // across the phone width
camera_h = 36;              // along the phone length
camera_protrusion = 3.0;
camera_relief_clearance = 0.5;
min_rear_skin = 1.8;

usb_bay_h = 12.0;           // room beyond the USB-C edge for a right-angle plug

// Cable raceway in the back wall, under the phone (phone stands on 4 pads).
cable_channel_w = 5.0;
cable_channel_depth = 1.6;

// ------------------------- ENCLOSURE --------------------------------
back_wall = 5.5;
case_corner_r = 13;
flange = 12.0;

window_t = 2.0;             // laser-cut polycarbonate, NOT printed
window_edge_margin = 2.0;
screen_mask_margin = 2.8;
bezel_t = 2.8;
bezel_corner_r = 13;
gasket_width = 2.4;
gasket_depth = 1.5;
seal_offset = 2.4;

bezel_insert_d = 4.2;       // M3 heat-set insert hole: SELECT from insert datasheet
bezel_insert_depth = 5.5;
bezel_screw_clearance = 3.3;
bezel_screw_inset = 5.0;
bezel_positions = [          // corners + two along each long edge
  [-1,-1], [1,-1], [-1,1], [1,1],
  [-0.33,-1], [0.33,-1], [-0.33,1], [0.33,1]
];

m5_insert_d = 6.4;          // M5 heat-set insert hole: SELECT
shoe_insert_d = 5.6;        // M4 heat-set insert hole: SELECT
shoe_insert_depth = 6.0;
shoe_inner_boss_d = 10.0;
shoe_mount_x = 11;
shoe_mount_y = 22;
shoe_screw_clear_d = 4.5;
shoe_csk_d = 8.6;

// ------------------------- CONTACT INTERFACE ------------------------
// Pin order, left to right looking at the ledge: DET, VBUS, D+, D-, GND (see WIRING.md).
pad_z = 7.5;
pad_port_w = 22;
pad_port_h = 5;
pad_port_depth = 3.0;
wire_hole_w = 10;
pin_block_w = 22;
pin_block_h = 5;
pin_block_depth = 9.0;

// ------------------------- DOCK INTERFACE (common to every case) ----
shoe_from_bottom = 48;      // case bottom face to shoe centre
dock_plate_w = 76;
dock_plate_h = 76;
dock_plate_t = 4.0;
dock_corner_r = 8;
dock_rail_spacing = 56;     // wide enough to leave the AMPS inserts between the channels
dock_rail_len = 56;
dock_rail_root_w = 8.0;
dock_rail_tip_w = 13.0;
dock_rail_depth = 5.5;
rail_side_clearance = 0.25;
rail_floor_clearance = 0.5;

ledge_gap = 0.8;
ledge_min_gap = 0.3;
ledge_w = 64;
ledge_t = 20;
ledge_top_z = 15.5;
ledge_wall = 2.5;
dock_gasket_w = 2.0;
dock_gasket_depth = 1.2;
dock_gasket_offset = 1.5;

usbc_panel_hole_d = 12.5;   // SELECT: waterproof panel-mount USB-C socket
usbc_x = -14;
usbc_z = -2;

receiver_w = 90;
receiver_top_y = 50;
receiver_back_t = 4.5;
receiver_edge_r = 8;
lid_insert_d = 4.2;
lid_t = 3.0;

// ------------------------- KEY LOCK ---------------------------------
// SELECT: 19 mm (3/4") tubular quarter-turn cam lock, key removable only when locked.
// Lock axis runs fore-aft; the key goes in from the rider-facing bottom of the dock.
// Locked, the steel cam swings up into a slot in the case's bottom flange.
lock_bore_d = 19.0;
lock_bore_flat = 17.5;
lock_panel_t = 3.0;
lock_body_len = 20.0;       // panel inner face to cam
lock_nut_clear_d = 27;
lock_key_recess_d = 24;
lock_x = 46;                // lock axis, dock frame
lock_z = -12;
cam_w = 8.0;
cam_t = 2.0;
cam_arm = 18.0;             // axis to tip; cut the supplied cam to this
lock_lip = 4.0;             // case material under the cam (takes the pull-out load)
lock_slot_clear = 1.5;

// ------------------------- BASE PLATE (Interface A + B) -------------
base_t = 8;
base_depth = 64;
slot_in = 55;               // clamp spacing range = 2*slot_in ... 2*slot_out
slot_out = 105;
plate_bolt_y = 18;          // Interface A: 2 x M5 per clamp at +/-18 mm fore-aft
slot_cbore_d = 10.5;
slot_cbore_depth = 3.5;
amps_x = 15;                // Interface B: AMPS 30 x 38 mm, M5
amps_y = 19;
grommet_hole_d = 9.5;       // SELECT: rubber grommet with steel sleeve, for M5, 3 mm panel
grommet_web_t = 3.0;
grommet_cbore_d = 17;
grommet_float = 2.0;        // upper grommet flange between plate and receiver
cable_hole_d = 14;
rib_h = 8;
rib_t = 4;

// ------------------------- HANDLEBAR CLAMPS -------------------------
bar_d = 22.2;               // MEASURE: 22.2 (7/8"), 25.4 (1") or 28.6 (1-1/8")
clamp_bore_d = 29.6;        // fits 28.6 mm bars with 0.5 mm rubber tape; shims for smaller bars
clamp_w = 24;
clamp_wall = 5.5;
clamp_split_gap = 1.0;
clamp_ear_w = 11;
clamp_ear_h = 12;
clamp_spacing = 160;        // MEASURE: centre-to-centre on a straight part of the bar
arm_up = 38;                // bar axis to pad top: must clear the riser clamps/cluster
arm_back = 0;               // pad centre behind (+) / ahead (-) of the bar axis
pad_l = 50;
pad_t = 10;
spacer_h = 0;               // optional riser spacer between clamp pad and base plate
tilt = 40;                  // screen tilt toward the rider (rotate both clamps on the bar)

// ------------------------- DERIVED DIMENSIONS -----------------------
cavity_w = phone_l + 2*end_clearance + usb_bay_h;
cavity_h = phone_w + 2*side_clearance;
phone_x_offset = -usb_side*usb_bay_h/2;
phone_y_offset = 0;
body_w = cavity_w + 2*flange;
body_h = cavity_h + 2*flange;
case_depth = back_wall + back_pad + phone_t + front_gap;

bezel_aperture_w = phone_l - 2*screen_mask_margin;
bezel_aperture_h = phone_w - 2*screen_mask_margin;
window_w = body_w - 2*window_edge_margin;
window_h = body_h - 2*window_edge_margin;

seal_outer_w = cavity_w + 2*(seal_offset + gasket_width/2);
seal_outer_h = cavity_h + 2*(seal_offset + gasket_width/2);

cam_case_x = phone_x_offset - usb_side*camera_y;   // camera island in case frame
cam_case_y = usb_side*camera_x;

shoe_y_case = -body_h/2 + shoe_from_bottom;

rx_front_z = -dock_plate_t;
rx_depth = dock_rail_depth + rail_floor_clearance + receiver_back_t;
rx_back_z = rx_front_z - rx_depth;
ledge_y = -shoe_from_bottom - ledge_gap;
rx_bottom_y = ledge_y - ledge_t;
rail_stop_y = -dock_rail_len/2 - (ledge_gap - ledge_min_gap);
cav_y0 = rx_bottom_y + ledge_wall;
cav_y1 = ledge_y - pin_block_depth;
cav_w = ledge_w - 16;
cav_top_z = 12;

cam_y0 = -shoe_from_bottom + lock_lip;              // cam plane (dock frame), docked
lock_panel_inner_y = cam_y0 - lock_body_len;
lock_panel_y = lock_panel_inner_y - lock_panel_t;
housing_bot = lock_z - lock_nut_clear_d/2 - 2.5;
housing_x0 = lock_x - 15;
housing_x1 = lock_x + cam_arm + 3;

base_len = 2*(slot_out + 9);
rib_len = 2*(slot_in - clamp_w/2 - 2);
ring_ro = clamp_bore_d/2 + clamp_wall;
clamp_ear_y = clamp_bore_d/2 + 6.5;

// ------------------------- VALIDATION --------------------------------
assert(phone_w > 40 && phone_l > 80 && phone_t > 5, "Phone dimensions look invalid.");
assert(abs(usb_side) == 1, "usb_side must be +1 or -1.");
assert(back_wall - (camera_protrusion + camera_relief_clearance) >= min_rear_skin || !camera_relief_enable,
       "Camera recess leaves too little rear skin.");
assert(seal_outer_h < body_h - 2*(bezel_screw_inset + bezel_insert_d/2),
       "Gasket groove runs into the bezel inserts. Increase flange.");
assert(shoe_insert_depth + 1.0 <= back_wall + back_pad - 0.5, "Shoe insert skin < 1 mm.");
assert(shoe_from_bottom - dock_plate_h/2 >= 5 && shoe_from_bottom + dock_plate_h/2 <= body_h - 3,
       "Shoe plate does not fit on the case back.");
assert(pad_z - pad_port_h/2 - dock_gasket_offset - dock_gasket_w >= 0.5 &&
       pad_z + pad_port_h/2 + dock_gasket_offset + dock_gasket_w <= case_depth - 0.5,
       "Dock seal ring does not fit on the case bottom face.");
assert(ledge_top_z <= case_depth, "Ledge is taller than the case.");
assert(lock_panel_y >= rx_bottom_y, "Lock is longer than the ledge: increase ledge_t or lock_lip.");
assert(lock_z + lock_bore_d/2 <= -1.5, "Lock body touches the case back.");
assert(lock_z + cam_w/2 <= -0.5, "Unlocked cam would hit the case.");
assert(lock_z + cam_arm + 1 < flange + back_wall, "Cam slot reaches into the phone cavity zone.");
assert(lock_lip + cam_t + lock_slot_clear < flange - 1, "Cam slot breaks into the phone cavity.");
assert(lock_x - lock_bore_d/2 > dock_rail_spacing/2 + dock_rail_tip_w/2 + 1, "Lock hits the rail channel.");
assert(amps_x + m5_insert_d/2 + 1 < dock_rail_spacing/2 - dock_rail_tip_w/2 - rail_side_clearance,
       "AMPS inserts run into the dovetail channels.");
assert(base_depth/2 < -ledge_y - 5, "Base plate would reach under the lock/ledge zone.");
assert(clamp_spacing/2 >= slot_in && clamp_spacing/2 <= slot_out, "clamp_spacing outside the slot range.");
assert(bar_d <= clamp_bore_d - 0.9, "Bar is too big for the clamp bore.");
assert(arm_up - 9 > 0.5 + 1, "Pad inserts run into the clamp split.");

// ------------------------- GEOMETRY HELPERS --------------------------
module rounded_prism(w, h, d, r) {
  rr = min(r, min(w,h)/2 - 0.01);
  linear_extrude(height=d)
    offset(r=rr)
      square([w-2*rr, h-2*rr], center=true);
}

module ring_groove(w, h, radius, groove_w, depth, z0) {
  translate([0,0,z0])
    difference() {
      rounded_prism(w, h, depth, radius);
      translate([0,0,-0.05])
        rounded_prism(w-2*groove_w, h-2*groove_w, depth+0.1, max(1, radius-groove_w));
    }
}

// Rounded rectangle in the X-Z plane, cut from face y=y0 into -Y (dir=-1) or +Y (dir=+1).
module xz_pocket(w, h, depth, r, y0, zc, dir=-1) {
  translate([0, y0 - dir*0.01, zc])
    rotate([dir < 0 ? 90 : -90, 0, 0])
      rounded_prism(w, h, depth + 0.01, r);
}

function bezel_xy(pos) =
  (abs(pos[0]) > 0.5 && abs(pos[1]) > 0.5)
    ? [pos[0] * (body_w/2 - 8.0), pos[1] * (body_h/2 - 8.0)]
    : [pos[0] * (body_w/2 - bezel_screw_inset),
       pos[1] * (body_h/2 - bezel_screw_inset)];

module bezel_holes(z0, h, d) {
  for (p = bezel_positions) {
    xy = bezel_xy(p);
    translate([xy[0],xy[1],z0]) cylinder(d=d,h=h);
  }
}

module xz_profile_along_y(points, y_min, y_max) {
  translate([0,y_max,0])
    rotate([90,0,0])
      linear_extrude(height=y_max-y_min)
        polygon(points=points);
}

// Channel along a polyline of [x,y] points, cut down from z_top.
module raceway(points, w, depth, z_top) {
  for (i=[0:len(points)-2]) hull() {
    translate([points[i][0], points[i][1], z_top-depth]) cylinder(d=w, h=depth+0.05);
    translate([points[i+1][0], points[i+1][1], z_top-depth]) cylinder(d=w, h=depth+0.05);
  }
}

// ------------------------- PHONE ENCLOSURE (case frame) --------------
module shoe_inner_bosses() {
  for (sx=[-1,1], sy=[-1,1])
    translate([sx*shoe_mount_x, shoe_y_case + sy*shoe_mount_y, back_wall - 0.01])
      cylinder(d=shoe_inner_boss_d, h=back_pad - 0.5 + 0.01);
}

module phone_support_pads() {
  pad = 8.0;
  for (sx=[-1,1], sy=[-1,1])
    translate([phone_x_offset + sx*(phone_l/2-pad/2), phone_y_offset + sy*(phone_w/2-pad/2), back_wall])
      rounded_prism(pad, pad, back_pad, 1.5);
}

// USB bay -> under the phone -> down to the contact pocket at the bottom centre.
function raceway_points() = let(
  y_edge = -cavity_h/2 + 3.5,
  y_mid  = -cavity_h/2 + 12.5,
  x_turn = phone_x_offset + usb_side*(phone_l/2 - 14),
  x_bay  = usb_side*(cavity_w/2 - usb_bay_h/2)
) [[0, -cavity_h/2 - 1], [0, y_edge], [x_turn, y_edge], [x_turn, y_mid], [x_bay, y_mid]];

module case_body() {
  difference() {
    rounded_prism(body_w, body_h, case_depth, case_corner_r);

    // Phone cavity; support pads and shoe bosses are left standing.
    difference() {
      translate([0,0,back_wall])
        rounded_prism(cavity_w, cavity_h, case_depth-back_wall+0.05, max(4, phone_corner_r+side_clearance));
      phone_support_pads();
      shoe_inner_bosses();
    }

    ring_groove(seal_outer_w, seal_outer_h, phone_corner_r+seal_offset,
                gasket_width, gasket_depth, case_depth-gasket_depth);

    bezel_holes(case_depth-bezel_insert_depth, bezel_insert_depth+0.03, bezel_insert_d);

    // Shoe insert bores, blind from the outside back face.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, shoe_y_case + sy*shoe_mount_y, -0.05])
        cylinder(d=shoe_insert_d, h=shoe_insert_depth+0.05);

    if (camera_relief_enable && camera_protrusion > 0)
      translate([cam_case_x, cam_case_y, back_wall-camera_protrusion-camera_relief_clearance])
        rounded_prism(camera_h+2*camera_relief_clearance, camera_w+2*camera_relief_clearance,
                      camera_protrusion+camera_relief_clearance+0.05, 5);

    // Cable raceway (does not run over the support pads).
    raceway(raceway_points(), cable_channel_w, cable_channel_depth, back_wall);

    // Contact target pocket in the bottom face + potted wire passage into the cavity.
    xz_pocket(pad_port_w, pad_port_h, pad_port_depth, 1, -body_h/2, pad_z, dir=+1);
    translate([-wire_hole_w/2, -body_h/2 + pad_port_depth - 0.05, back_wall - cable_channel_depth])
      cube([wire_hole_w, flange - pad_port_depth + 0.1 + end_clearance,
            pad_z + pad_port_h/2 - back_wall + cable_channel_depth]);

    // Lock slot in the bottom flange, open only toward the back face. The cam swings
    // up into it; the lip below the slot is what stops the case being pulled out.
    translate([lock_x - cam_w/2 - 1, -body_h/2 + lock_lip, -0.05])
      cube([cam_w/2 + 1 + cam_arm + 1, cam_t + lock_slot_clear, lock_z + cam_arm + 1 + 0.05]);
  }
}

module front_bezel() {
  difference() {
    rounded_prism(body_w, body_h, bezel_t, bezel_corner_r);
    translate([phone_x_offset, phone_y_offset, -0.05])
      rounded_prism(bezel_aperture_w, bezel_aperture_h, bezel_t+0.1, max(4, phone_corner_r-screen_mask_margin));
    bezel_holes(-0.05, bezel_t+0.1, bezel_screw_clearance);
  }
}

module window_template() {
  difference() {
    rounded_prism(window_w, window_h, window_t, case_corner_r-window_edge_margin);
    bezel_holes(-0.05, window_t+0.1, bezel_screw_clearance + 0.2);
  }
}

// ------------------------- REAR SHOE (dock frame) ---------------------
module dock_shoe() {
  difference() {
    union() {
      translate([0,0,-dock_plate_t])
        rounded_prism(dock_plate_w, dock_plate_h, dock_plate_t, dock_corner_r);
      for (sx=[-1,1]) {
        xc = sx*dock_rail_spacing/2;
        xz_profile_along_y([
          [xc-dock_rail_root_w/2, -dock_plate_t+0.01],
          [xc+dock_rail_root_w/2, -dock_plate_t+0.01],
          [xc+dock_rail_tip_w/2, -dock_plate_t-dock_rail_depth],
          [xc-dock_rail_tip_w/2, -dock_plate_t-dock_rail_depth]
        ], -dock_rail_len/2, dock_rail_len/2);
      }
    }
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, sy*shoe_mount_y, -dock_plate_t-0.05]) {
        cylinder(d=shoe_screw_clear_d, h=dock_plate_t+0.1);
        cylinder(d1=shoe_csk_d+0.1, d2=shoe_screw_clear_d, h=(shoe_csk_d-shoe_screw_clear_d)/2+0.05);
      }
  }
}

// ------------------------- RECEIVER / DOCK (dock frame) ---------------
function lid_screw_xy() = [
  for (sx=[-1,1], yy=[rx_bottom_y + 3.5, ledge_y - 3.0]) [sx*(ledge_w/2 - 4), yy]
];

module dock_receiver() {
  difference() {
    union() {
      translate([0, (rx_bottom_y+receiver_top_y)/2, rx_back_z])
        rounded_prism(receiver_w, receiver_top_y-rx_bottom_y, rx_depth, receiver_edge_r);
      // Ledge: carries the case, the spring pins and the electronics cavity.
      translate([0, (rx_bottom_y+ledge_y)/2, rx_back_z])
        rounded_prism(ledge_w, ledge_t, ledge_top_z-rx_back_z, 4);
      // Lock housing: tall part beside the case bottom, low part under the case.
      translate([housing_x0, rx_bottom_y, housing_bot])
        cube([housing_x1-housing_x0, ledge_y-rx_bottom_y, lock_z + lock_nut_clear_d/2 + 2 - housing_bot]);
      translate([housing_x0, ledge_y - 0.01, housing_bot])
        cube([housing_x1-housing_x0, cam_y0 + cam_t + 3 - ledge_y, rx_front_z - housing_bot]);
    }

    // Dovetail channels: same flank slope as the rails, closed at the bottom (end stop).
    for (sx=[-1,1]) {
      xc = sx*dock_rail_spacing/2;
      r0 = dock_rail_root_w/2 + rail_side_clearance;
      r1 = dock_rail_tip_w/2 + rail_side_clearance;
      zt = rx_front_z - dock_rail_depth;
      zf = zt - rail_floor_clearance;
      xz_profile_along_y([
        [xc-r0, rx_front_z+0.1], [xc+r0, rx_front_z+0.1],
        [xc+r0, rx_front_z], [xc+r1, zt], [xc+r1, zf],
        [xc-r1, zf], [xc-r1, zt], [xc-r0, rx_front_z]
      ], rail_stop_y, receiver_top_y+1);
    }

    // Lock: nut zone, body zone, cam swing pocket, D-shaped panel bore, key recess.
    translate([lock_x - lock_nut_clear_d/2, lock_panel_inner_y, housing_bot - 0.1])
      cube([lock_nut_clear_d, 6, lock_z + lock_nut_clear_d/2 - housing_bot + 0.1]);
    translate([lock_x - lock_bore_d/2 - 1, lock_panel_inner_y, housing_bot - 0.1])
      cube([lock_bore_d + 2, cam_y0 - 0.6 - lock_panel_inner_y, lock_z + lock_bore_d/2 + 1 - housing_bot + 0.1]);
    translate([lock_x - cam_arm - 1.5, cam_y0 - 0.6, lock_z - cam_arm - 1.5])
      cube([2*cam_arm + 3, cam_t + 1.2, rx_front_z - (lock_z - cam_arm - 1.5) + 0.1]);
    translate([lock_x, lock_panel_y - 0.05, lock_z]) rotate([-90,0,0])
      intersection() {
        cylinder(d=lock_bore_d, h=lock_panel_t + 0.1);
        translate([-lock_bore_d/2, -lock_bore_flat/2, -0.1]) cube([lock_bore_d, lock_bore_flat, lock_panel_t + 0.3]);
      }
    translate([lock_x, rx_bottom_y - 0.05, lock_z]) rotate([-90,0,0])
      cylinder(d=lock_key_recess_d, h=lock_panel_y - rx_bottom_y + 0.05);

    // Spring-pin block pocket + seal groove in the ledge face.
    xz_pocket(pin_block_w, pin_block_h, pin_block_depth + 0.1, 1, ledge_y, pad_z, dir=-1);
    translate([0, ledge_y + 0.01, pad_z]) rotate([90,0,0])
      ring_groove(pin_block_w + 2*(dock_gasket_offset+dock_gasket_w),
                  pin_block_h + 2*(dock_gasket_offset+dock_gasket_w),
                  2 + dock_gasket_offset + dock_gasket_w,
                  dock_gasket_w, dock_gasket_depth + 0.01, 0);

    // Electronics cavity, panel USB-C socket hole, lid inserts.
    translate([-cav_w/2, cav_y0, rx_back_z - 0.05])
      cube([cav_w, cav_y1 - cav_y0 + 0.05, cav_top_z - rx_back_z + 0.05]);
    translate([usbc_x, rx_bottom_y - 0.05, usbc_z]) rotate([-90,0,0])
      cylinder(d=usbc_panel_hole_d, h=ledge_wall + 0.1);
    for (p = lid_screw_xy())
      translate([p[0], p[1], rx_back_z - 0.05]) cylinder(d=lid_insert_d, h=6);

    // Interface B: AMPS M5 inserts in the back face.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*amps_x, sy*amps_y, rx_back_z - 0.05]) cylinder(d=m5_insert_d, h=7);
  }
}

module ledge_lid() {
  difference() {
    translate([0, (rx_bottom_y+ledge_y)/2, rx_back_z - lid_t])
      rounded_prism(ledge_w - 1, ledge_t - 1, lid_t, 4);
    for (p = lid_screw_xy())
      translate([p[0], p[1], rx_back_z - lid_t - 0.05]) cylinder(d=3.4, h=lid_t + 0.1);
  }
}

// ------------------------- BASE PLATE (plate frame) -------------------
module base_plate_holes_2d() {
  for (sx=[-1,1], sy=[-1,1]) {
    hull() for (x=[slot_in, slot_out]) translate([sx*x, sy*plate_bolt_y]) circle(d=5.5);
    translate([sx*amps_x, sy*amps_y]) circle(d=grommet_hole_d);
  }
  circle(d=cable_hole_d);
}

module base_plate() {
  difference() {
    union() {
      translate([0,0,-base_t]) rounded_prism(base_len, base_depth, base_t, 8);
      for (sy=[-1,1])
        translate([-rib_len/2, sy*(base_depth/2 - rib_t/2) - rib_t/2, -base_t - rib_h])
          cube([rib_len, rib_t, rib_h + 0.05]);
    }
    translate([0,0,-base_t-0.05]) linear_extrude(base_t+0.1) base_plate_holes_2d();
    // Counterbored clamp slots (button heads flush with the top).
    for (sx=[-1,1], sy=[-1,1])
      hull() for (x=[slot_in, slot_out])
        translate([sx*x, sy*plate_bolt_y, -slot_cbore_depth]) cylinder(d=slot_cbore_d, h=slot_cbore_depth+0.05);
    // Grommet counterbores from below (leaves a 3 mm web for the grommets).
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*amps_x, sy*amps_y, -base_t-0.05]) cylinder(d=grommet_cbore_d, h=base_t-grommet_web_t+0.05);
  }
}

// Flat profile for a metal (5-6 mm aluminium) version of the base plate.
module base_plate_2d() {
  difference() {
    offset(r=8) square([base_len-16, base_depth-16], center=true);
    base_plate_holes_2d();
  }
}

// ------------------------- HANDLEBAR CLAMPS (clamp frame) -------------
// Bar axis = X through the origin. Body = upper half + arm + pad; cap = lower half.
module clamp_body() {
  difference() {
    union() {
      hull() {
        intersection() {
          rotate([0,90,0]) cylinder(r=ring_ro, h=clamp_w, center=true);
          translate([-clamp_w/2-1, -ring_ro-1, clamp_split_gap/2]) cube([clamp_w+2, 2*ring_ro+2, ring_ro+1]);
        }
        translate([-clamp_w/2, -arm_back - pad_l/2, arm_up - pad_t]) cube([clamp_w, pad_l, pad_t]);
      }
      for (sy=[-1,1])
        translate([-clamp_w/2, sy*clamp_ear_y - clamp_ear_w/2, clamp_split_gap/2])
          cube([clamp_w, clamp_ear_w, clamp_ear_h]);
    }
    rotate([0,90,0]) cylinder(d=clamp_bore_d, h=clamp_w+2, center=true);
    for (sy=[-1,1]) {
      translate([0, sy*clamp_ear_y, clamp_split_gap/2 - 0.05]) cylinder(d=m5_insert_d, h=9);
      translate([0, -arm_back + sy*plate_bolt_y, arm_up - 9]) cylinder(d=m5_insert_d, h=9.05);
    }
  }
}

module clamp_cap() {
  difference() {
    union() {
      intersection() {
        rotate([0,90,0]) cylinder(r=ring_ro, h=clamp_w, center=true);
        translate([-clamp_w/2-1, -ring_ro-1, -ring_ro-1]) cube([clamp_w+2, 2*ring_ro+2, ring_ro+1-clamp_split_gap/2]);
      }
      for (sy=[-1,1])
        translate([-clamp_w/2, sy*clamp_ear_y - clamp_ear_w/2, -clamp_split_gap/2 - clamp_ear_h])
          cube([clamp_w, clamp_ear_w, clamp_ear_h]);
    }
    rotate([0,90,0]) cylinder(d=clamp_bore_d, h=clamp_w+2, center=true);
    for (sy=[-1,1]) translate([0, sy*clamp_ear_y, -clamp_split_gap/2 - clamp_ear_h - 0.05]) {
      cylinder(d=5.5, h=clamp_ear_h+0.1);
      cylinder(d=10, h=4);
    }
  }
}

// TPU shim half-shells (print 2 per clamp) to fit smaller bars.
module bar_shim() {
  wall = (clamp_bore_d - bar_d)/2;
  if (wall < 1.0) echo("bar_d fits the clamp with 0.5 mm rubber tape; no shim needed.");
  else for (i=[0,1]) translate([i*(clamp_bore_d + 4), 0, 0])
    difference() {
      intersection() {
        cylinder(d=clamp_bore_d - 0.2, h=clamp_w);
        translate([-clamp_bore_d, 0.3, -1]) cube([2*clamp_bore_d, clamp_bore_d, clamp_w + 2]);
      }
      translate([0,0,-1]) cylinder(d=bar_d, h=clamp_w + 2);
    }
}

// Riser spacer between a clamp pad and the base plate (use longer M5 bolts).
module pad_spacer(h = (spacer_h > 0 ? spacer_h : 10)) {
  difference() {
    translate([-clamp_w/2, -pad_l/2, 0]) cube([clamp_w, pad_l, h]);
    for (sy=[-1,1]) translate([0, sy*plate_bolt_y, -0.05]) cylinder(d=5.5, h=h+0.1);
  }
}

// Template for cutting the lock's steel cam (2 mm steel).
module cam_template() {
  difference() {
    hull() {
      cylinder(d=cam_w + 4, h=cam_t);
      translate([0, cam_arm - cam_w/2, 0]) cylinder(d=cam_w, h=cam_t);
    }
    translate([0,0,-0.05]) linear_extrude(cam_t + 0.1) square(4.1, center=true); // SELECT: lock spindle
  }
}

// ------------------------- PREVIEW HELPERS ---------------------------
module demo_phone() {
  color([0.15,0.15,0.17,0.55])
    translate([phone_x_offset, phone_y_offset, back_wall+back_pad])
      rounded_prism(phone_l, phone_w, phone_t, phone_corner_r);
}

module demo_window() {
  color([0.35,0.75,0.95,0.35])
    translate([0,0,case_depth+EXPLODE*0.45]) window_template();
}

// Cam in dock frame: locked = arm pointing +Z into the case slot; unlocked = arm along +X.
module cam_placed(locked=true) {
  translate([lock_x, cam_y0 + cam_t, lock_z]) rotate([0, locked ? 0 : 90, 0]) rotate([90,0,0]) cam_template();
}

module dock_stack() {
  translate([0, -shoe_y_case, EXPLODE]) {
    color([0.22,0.25,0.28]) case_body();
    if (SHOW_PHONE) demo_phone();
    if (SHOW_WINDOW) demo_window();
    color([0.12,0.13,0.15]) translate([0,0,case_depth+window_t+EXPLODE]) front_bezel();
  }
  color([0.25,0.28,0.32]) translate([0,0,EXPLODE*0.4]) dock_shoe();
  color([0.38,0.42,0.46]) dock_receiver();
  color([0.30,0.30,0.30]) translate([0,0,-EXPLODE*0.5]) ledge_lid();
  color([0.75,0.75,0.78]) cam_placed(true);
}

// Plate frame -> clamp/bike frame.
module on_plate() {
  rotate([tilt,0,0]) translate([0, -arm_back, arm_up + spacer_h + base_t + EXPLODE*0.5]) children();
}

module assembly() {
  for (sx=[-1,1]) translate([sx*clamp_spacing/2, 0, 0]) rotate([tilt,0,0]) {
    color([0.30,0.33,0.36]) clamp_body();
    color([0.30,0.33,0.36]) translate([0,0,-EXPLODE*0.3]) clamp_cap();
    if (spacer_h > 0) color([0.4,0.4,0.4]) translate([0,-arm_back,arm_up]) pad_spacer();
  }
  on_plate() {
    color([0.20,0.45,0.70]) base_plate();
    translate([0,0,grommet_float - rx_back_z + EXPLODE]) dock_stack();
  }
  if (SHOW_BAR) % rotate([0,90,0]) cylinder(d=bar_d, h=700, center=true);
}

// ------------------------- PART SELECTOR -----------------------------
if (PART == "assembly") assembly();
else if (PART == "case") case_body();
else if (PART == "bezel") front_bezel();
else if (PART == "window_template") window_template();
else if (PART == "shoe") dock_shoe();
else if (PART == "receiver") dock_receiver();
else if (PART == "ledge_lid") ledge_lid();
else if (PART == "base_plate") base_plate();
else if (PART == "base_plate_2d") base_plate_2d();
else if (PART == "clamp_body") clamp_body();
else if (PART == "clamp_cap") clamp_cap();
else if (PART == "bar_shim") bar_shim();
else if (PART == "pad_spacer") pad_spacer();
else if (PART == "cam_template") cam_template();
else if (PART != "none") echo("Unknown PART.");

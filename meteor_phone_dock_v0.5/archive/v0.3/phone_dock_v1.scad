/*
  Meteor 350 centre-mount navigation phone dock
  Version: 0.3 concept prototype (replaces the 0.2 draw-in-cam design, archived in archive/v0.2)

  Units: millimetres

  WHAT THIS IS
  - A sealed, phone-specific case that holds an old phone permanently as a navigation screen.
  - A common rear "shoe" with dovetail rails, bolted to the case.
  - A handlebar-side "receiver" (dock) the case slides down into. A tubular cam lock
    (unique key) blocks the case from sliding back out.
  - Power + USB 2.0 data pass through a 5-contact spring-pin connector on the receiver's
    bottom ledge. The case's flat contact pads press onto the pins as it slides home,
    so there is no cable to plug in when docking.
  - The dock's own waterproof USB-C socket takes the lead from the bike.
  - An adjustable toothed pivot sets the tilt toward the rider. Four rubber grommets
    under the pivot base isolate vibration.
  - A METAL plate mounts the whole thing under the rear handlebar-clamp bolts, behind
    the instrument cluster, toward the tank.

  COORDINATE FRAMES
  Case frame:  X = phone width, Y = phone length (+Y = phone top), Z = depth (screen faces +Z),
               origin at cavity centre, z = 0 is the outside back face of the case.
  Dock frame:  same axes, origin moved to the shoe centre (case back plane, z = 0).
               The shoe, receiver and pivot ear are modelled in this frame.
  Bike frame:  X = lateral, Y = forward (toward instrument cluster), Z = up.
               Origin = top face of the handlebar clamp, midway between the two clamp bolts used.

  IMPORTANT
  - Placeholders are marked MEASURE or SELECT. Do not print final parts until they are replaced.
  - Never put printed plastic under the handlebar clamp bolts. The bar plate must be metal.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "case", "bezel", "window_template", "shoe", "receiver", "ledge_lid",
// "mount_base", "bar_plate", "bar_plate_2d" (DXF for laser/water-jet), "cam_template"
PART = "assembly";
SHOW_PHONE = true;
SHOW_WINDOW = true;
SHOW_BIKE_REFERENCE = true;   // ghost handlebar + clamp bolts in the assembly view
EXPLODE = 0;                  // 10-25 for an exploded preview

$fn = 64;

// ------------------------- PHONE PROFILE ----------------------------
// MEASURE: example values only. Replace with the real phone's dimensions (no soft case).
phone_w = 75.0;
phone_l = 160.0;
phone_t = 9.0;             // body thickness excluding camera bump
phone_corner_r = 9.0;

side_clearance = 0.60;
end_clearance = 0.60;
front_gap = 0.80;          // screen-to-window air gap; test touch through the window
back_pad = 2.00;           // silicone/EVA pad allowance behind phone

camera_relief_enable = true;
camera_x = 0;
camera_y = 62;
camera_w = 34;
camera_h = 36;
camera_protrusion = 3.0;
camera_relief_clearance = 0.5;
min_rear_skin = 1.8;

// Space beyond the phone's USB-C edge for a right-angle USB-C plug + short cable.
usb_bay_h = 12.0;

// ------------------------- ENCLOSURE --------------------------------
wall = 3.2;
back_wall = 5.5;
case_corner_r = 13;
flange = 12.0;              // was 11.0: gives 2.9 mm of plastic outside each bezel insert
body_extra_margin = 0.0;

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
bezel_screw_inset = 5.0;    // was 4.0
bezel_positions = [
  [-1,-1], [1,-1], [-1,1], [1,1],
  [-1,-0.33], [1,-0.33], [-1,0.33], [1,0.33]
];

// Shoe fastening: 4 x M4 countersunk screws from the shoe into blind heat-set inserts.
// The inserts sit in small bosses on the INSIDE of the back wall, so nothing
// protrudes from the case back and no hole goes through it.
shoe_insert_d = 5.6;        // M4 heat-set insert hole: SELECT from insert datasheet
shoe_insert_depth = 6.0;
shoe_inner_boss_d = 10.0;
shoe_mount_x = 11;
shoe_mount_y = 22;
shoe_screw_clear_d = 4.5;
shoe_csk_d = 8.6;           // M4 countersunk head

// ------------------------- CONTACT INTERFACE ------------------------
// Case side: a flat 5-pad target connector set flush in the case bottom face (below the USB-C bay).
// Dock side: a matching 5-pin spring-loaded (pogo) block in the receiver ledge.
// Pin order (left to right, looking at the ledge): DET, VBUS, D+, D-, GND (see WIRING.md).
// SELECT a matched pogo/target pair, then edit these pockets to its drawing.
pad_z = 7.5;                // contact row height above the case back face (common interface)
pad_port_w = 22;            // pocket for the target pad board, X
pad_port_h = 5;             // Z
pad_port_depth = 3.0;       // into the bottom flange, Y
wire_hole_w = 10;           // pocket -> USB bay, potted after wiring
pin_block_w = 22;
pin_block_h = 5;
pin_block_depth = 9.0;

// ------------------------- DOCK INTERFACE (common to every phone case) ----
shoe_from_bottom = 48;      // case bottom face to shoe centre
dock_plate_w = 58;
dock_plate_h = 76;
dock_plate_t = 4.0;
dock_corner_r = 8;
dock_rail_spacing = 44;
dock_rail_len = 56;
dock_rail_root_w = 8.0;     // narrow at the shoe plate
dock_rail_tip_w = 13.0;     // wide at the rail tip (dovetail)
dock_rail_depth = 5.5;
rail_side_clearance = 0.25; // same clearance all the way down the flank (matched slope)
rail_floor_clearance = 0.5;

ledge_gap = 0.8;            // docked gap between case bottom and ledge face (set by the cam)
ledge_min_gap = 0.3;        // rail end-stop: protects the pins from over-compression
ledge_w = 64;
ledge_t = 20;               // ledge thickness along Y (holds pins + electronics cavity)
ledge_top_z = 15.5;         // ledge reaches this high up the case bottom face
ledge_wall = 2.5;           // outer wall of the electronics cavity (USB socket panel)
dock_gasket_w = 2.0;        // foam/silicone seal around the pins, compresses on the case bottom
dock_gasket_depth = 1.2;
dock_gasket_offset = 1.5;   // pin pocket edge to inner edge of the seal groove

usbc_panel_hole_d = 12.5;   // SELECT: waterproof panel-mount USB-C socket cut-out
usbc_x = -14;
usbc_z = -2;

receiver_w = 104;
receiver_top_y = 50;
receiver_back_t = 4.5;
receiver_edge_r = 8;
lid_insert_d = 4.2;         // M3 heat-set inserts for the electronics lid
lid_t = 3.0;

// ------------------------- KEY LOCK ---------------------------------
// SELECT: 19 mm (3/4") tubular quarter-turn cam lock. Prefer "key removable in locked
// position only" so you cannot ride with it unlocked. Edit to the lock's datasheet.
lock_bore_d = 19.0;
lock_bore_flat = 17.5;      // D-flat across, anti-rotation
lock_panel_t = 3.0;         // lock's allowed panel thickness
lock_body_len = 20.0;       // panel inner face to cam
lock_nut_clear_d = 27;
lock_outer_x = 66;          // key face (right-hand side of the dock)
lock_y = -6;                // lock axis in dock frame
lock_z = -18.5;
cam_w = 8.0;
cam_t = 2.0;
cam_arm = 14.0;             // axis to cam tip; cut the supplied steel cam to this
striker_w = 8.0;
striker_t = 3.0;

// ------------------------- PIVOT + DAMPING --------------------------
tilt = 40;                  // screen tilt from horizontal toward the rider; multiple of 360/rosette_teeth
rosette_teeth = 36;         // 10 degree adjustment steps
rosette_r_in = 7.0;
rosette_r_out = 14;
rosette_h = 1.0;
rosette_clear = 0.15;        // tooth tip to opposite face when meshed
fork_phase = 180/rosette_teeth; // fork teeth offset so they sit in the ear's valleys
pivot_bolt_d = 6.4;         // M6 bolt + nyloc nut
ear_t = 8.0;                // centre ear (on receiver)
fork_ear_t = 6.0;
ear_r = 15;
pivot_y = -10;              // pivot axis in dock frame
ear_drop = 20;              // receiver back face to pivot axis
pivot_h = 40;               // bar plate top to pivot axis (with grommets)

base_w = 76;
base_d = 52;
base_t = 6;
grommet_x = 30;
grommet_y = 18;
grommet_hole_d = 9.5;       // SELECT: rubber grommet with steel sleeve, for M5
grommet_web_t = 3.0;        // panel thickness the grommet is made for
grommet_cbore_d = 17;
grommet_lift = 2.0;         // lower grommet flange under the base

// ------------------------- BIKE INTERFACE ---------------------------
// MEASURE on the bike: these are placeholders, not Meteor 350 data.
bar_bolt_spacing = 60;      // centre distance between the two rear handlebar-clamp bolts
bar_bolt_clear_d = 8.5;     // M8 assumed: check the actual bolts
bar_bolt_slot = 4;          // slot length (fore-aft) for tolerance
plate_reach = 45;           // rearward distance from clamp bolts to pivot base centre
plate_t = 5;                // 6061 aluminium (or 3 mm steel)
bar_ref_d = 22;             // reference only, for the ghost handlebar
bar_ref_y = 18;

// ------------------------- DERIVED DIMENSIONS -----------------------
cavity_w = phone_w + 2*side_clearance;
cavity_h = phone_l + 2*end_clearance + usb_bay_h;
phone_x_offset = 0;
phone_y_offset = usb_bay_h/2;
body_w = cavity_w + 2*flange + body_extra_margin;
body_h = cavity_h + 2*flange + body_extra_margin;
case_depth = back_wall + back_pad + phone_t + front_gap;

bezel_aperture_w = phone_w - 2*screen_mask_margin;
bezel_aperture_h = phone_l - 2*screen_mask_margin;
window_w = body_w - 2*window_edge_margin;
window_h = body_h - 2*window_edge_margin;

seal_outer_w = cavity_w + 2*(seal_offset + gasket_width/2);
seal_outer_h = cavity_h + 2*(seal_offset + gasket_width/2);

shoe_y_case = -body_h/2 + shoe_from_bottom;   // shoe centre in case frame

rx_front_z = -dock_plate_t;
rx_depth = dock_rail_depth + rail_floor_clearance + receiver_back_t;
rx_back_z = rx_front_z - rx_depth;
ledge_y = -shoe_from_bottom - ledge_gap;                // ledge face (dock frame)
rx_bottom_y = ledge_y - ledge_t;
rail_stop_y = -dock_rail_len/2 - (ledge_gap - ledge_min_gap);
cav_y0 = rx_bottom_y + ledge_wall;
cav_y1 = ledge_y - pin_block_depth;
cav_w = ledge_w - 16;
cav_top_z = 12;

cam_x = lock_outer_x - lock_panel_t - lock_body_len - cam_t/2;
striker_z = rx_front_z - dock_rail_depth/2;
striker_y = lock_y - cam_w/2 - striker_w/2;              // seated against the cam
rail_half_at_striker = dock_rail_root_w/2 +
  (dock_rail_tip_w - dock_rail_root_w)/2 * ((rx_front_z - striker_z)/dock_rail_depth);
striker_x0 = dock_rail_spacing/2 + rail_half_at_striker - 0.6;
striker_x1 = cam_x + cam_t/2 + 1.5;

pivot_z = rx_back_z - ear_drop;
rosette_pitch = 360/rosette_teeth;

// ------------------------- VALIDATION --------------------------------
assert(phone_w > 40 && phone_l > 80 && phone_t > 5, "Phone dimensions look invalid.");
assert(back_wall - (camera_protrusion + camera_relief_clearance) >= min_rear_skin || !camera_relief_enable,
       "Camera recess leaves too little rear skin.");
assert(seal_outer_w < body_w - 2*(bezel_screw_inset + bezel_insert_d/2),
       "Gasket groove runs into the bezel inserts. Increase flange.");
assert(bezel_aperture_w > 20 && bezel_aperture_h > 40, "Bezel aperture is too small.");
assert(dock_rail_tip_w > dock_rail_root_w, "Dovetail rail tip must be wider than its root.");
assert(shoe_insert_depth + 1.0 <= back_wall + back_pad - 0.5,
       "Shoe insert bores leave less than 1 mm of skin under the inner bosses.");
assert(pad_z - pad_port_h/2 - dock_gasket_offset - dock_gasket_w >= 0.5 &&
       pad_z + pad_port_h/2 + dock_gasket_offset + dock_gasket_w <= case_depth - 0.5,
       "Dock seal ring does not fit on the case bottom face.");
assert(ledge_top_z <= case_depth, "Ledge is taller than the case.");
assert(shoe_from_bottom - dock_plate_h/2 >= 5, "Shoe plate overhangs the ledge zone.");
assert(lock_z + cam_arm >= striker_z + striker_t/2 + 0.5 && lock_z + cam_arm <= rx_front_z - 0.3,
       "Cam tip must pass the striker but stay below the shoe plate.");
assert(lock_z + lock_bore_d/2 <= striker_z - striker_t/2 - 0.5, "Lock body hits the striker path.");
assert(lock_z + lock_nut_clear_d/2 <= rx_front_z - 0.5, "Lock nut cavity breaks the receiver front.");
assert((tilt % rosette_pitch) == 0, "tilt must be a multiple of the rosette tooth pitch.");
assert((180 % rosette_pitch) == 0, "rosette_teeth must divide 180 degrees evenly.");

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

// Extrude a polygon defined in X/Z along the Y axis.
module xz_profile_along_y(points, y_min, y_max) {
  translate([0,y_max,0])
    rotate([90,0,0])
      linear_extrude(height=y_max-y_min)
        polygon(points=points);
}

// Radial face teeth on a disc in the local XY plane, pointing +Z.
module rosette_teeth(phase=0) {
  a = rosette_pitch;
  e = a/2;       // teeth bases are sunk 0.05 mm into the face for a clean union
  for (i=[0:rosette_teeth-1]) rotate([0,0,i*a+phase]) hull() {
    for (p=[[rosette_r_in*cos(-e), rosette_r_in*sin(-e), -0.05],
            [rosette_r_in*cos( e), rosette_r_in*sin( e), -0.05],
            [rosette_r_out*cos(-e), rosette_r_out*sin(-e), -0.05],
            [rosette_r_out*cos( e), rosette_r_out*sin( e), -0.05],
            [rosette_r_in, 0, rosette_h], [rosette_r_out, 0, rosette_h]])
      translate(p) cube(0.01, center=true);
  }
}

// ------------------------- PHONE ENCLOSURE ---------------------------
module shoe_inner_bosses() {
  for (sx=[-1,1], sy=[-1,1])
    translate([sx*shoe_mount_x, shoe_y_case + sy*shoe_mount_y, back_wall - 0.01])
      cylinder(d=shoe_inner_boss_d, h=back_pad - 0.5 + 0.01);
}

module phone_support_pads() {
  pad_w = 8.0;
  pad_h = 8.0;
  for (sx=[-1,1], sy=[-1,1]) {
    translate([phone_x_offset + sx*(phone_w/2-pad_w/2),
               phone_y_offset + sy*(phone_l/2-pad_h/2), back_wall])
      rounded_prism(pad_w,pad_h,back_pad,1.5);
  }
}

module case_body() {
  difference() {
    union() {
      rounded_prism(body_w,body_h,case_depth,case_corner_r);
      phone_support_pads();
      shoe_inner_bosses();
    }

    // Phone cavity, open at the front. Pads and bosses are re-added below by not cutting them.
    difference() {
      translate([0,0,back_wall])
        rounded_prism(cavity_w,cavity_h,case_depth-back_wall+0.05,
                      max(4,phone_corner_r+side_clearance));
      phone_support_pads();
      shoe_inner_bosses();
    }

    // Continuous gasket groove on the front flange.
    ring_groove(seal_outer_w,seal_outer_h,phone_corner_r+seal_offset,
                gasket_width,gasket_depth,case_depth-gasket_depth);

    // Bezel insert holes, blind from the front face.
    bezel_holes(case_depth-bezel_insert_depth,bezel_insert_depth+0.03,bezel_insert_d);

    // Shoe insert bores, blind from the outside back face into the inner bosses.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, shoe_y_case + sy*shoe_mount_y, -0.05])
        cylinder(d=shoe_insert_d, h=shoe_insert_depth+0.05);

    // Camera island relief, cut from the cavity side into the rear wall, not through it.
    if (camera_relief_enable && camera_protrusion > 0) {
      translate([phone_x_offset+camera_x,phone_y_offset+camera_y,
                 back_wall-camera_protrusion-camera_relief_clearance])
        rounded_prism(camera_w+2*camera_relief_clearance,
                      camera_h+2*camera_relief_clearance,
                      camera_protrusion+camera_relief_clearance+0.05,5);
    }

    // Contact target pocket in the bottom face (flush pad board, potted/sealed in place).
    xz_pocket(pad_port_w, pad_port_h, pad_port_depth, 1, -body_h/2, pad_z, dir=+1);

    // Wire passage from the pad pocket up into the USB bay. Pot with epoxy after soldering.
    translate([-wire_hole_w/2, -body_h/2 + pad_port_depth - 0.05, back_wall])
      cube([wire_hole_w, flange - pad_port_depth + 0.1 + end_clearance,
            pad_z + pad_port_h/2 - back_wall]);
  }
}

module front_bezel() {
  difference() {
    rounded_prism(body_w,body_h,bezel_t,bezel_corner_r);
    translate([phone_x_offset,phone_y_offset,-0.05])
      rounded_prism(bezel_aperture_w,bezel_aperture_h,bezel_t+0.1,
                    max(4,phone_corner_r-screen_mask_margin));
    bezel_holes(-0.05,bezel_t+0.1,bezel_screw_clearance);
  }
}

// Cutting/drilling template for the 2 mm polycarbonate window. The bezel screws pass
// through the window, so it carries the same eight clearance holes as the bezel.
module window_template() {
  difference() {
    rounded_prism(window_w,window_h,window_t,case_corner_r-window_edge_margin);
    bezel_holes(-0.05,window_t+0.1,bezel_screw_clearance + 0.2);
  }
}

// ------------------------- REAR SHOE (dock frame) ---------------------
module dock_shoe() {
  difference() {
    union() {
      translate([0,0,-dock_plate_t])
        rounded_prism(dock_plate_w,dock_plate_h,dock_plate_t,dock_corner_r);

      // Dovetail tongues: narrow at the plate, wide at the tip.
      for (sx=[-1,1]) {
        xc = sx*dock_rail_spacing/2;
        xz_profile_along_y([
          [xc-dock_rail_root_w/2,-dock_plate_t+0.01],
          [xc+dock_rail_root_w/2,-dock_plate_t+0.01],
          [xc+dock_rail_tip_w/2,-dock_plate_t-dock_rail_depth],
          [xc-dock_rail_tip_w/2,-dock_plate_t-dock_rail_depth]
        ], -dock_rail_len/2, dock_rail_len/2);
      }

      // Lock striker. When docked, the spring pins push the case up (+Y) and this bar
      // rests against the underside of the locked cam. Final part: bolt-on stainless strip.
      translate([striker_x0, striker_y - striker_w/2, striker_z - striker_t/2])
        cube([striker_x1 - striker_x0, striker_w, striker_t]);
    }

    // Four countersunk M4 holes into the case inserts (heads flush with the shoe's rear face).
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, sy*shoe_mount_y, 0]) {
        translate([0,0,-dock_plate_t-0.05]) cylinder(d=shoe_screw_clear_d, h=dock_plate_t+0.1);
        translate([0,0,-dock_plate_t-0.05])
          cylinder(d1=shoe_csk_d+0.1, d2=shoe_screw_clear_d, h=(shoe_csk_d-shoe_screw_clear_d)/2+0.05);
      }
  }
}

// ------------------------- RECEIVER / DOCK (dock frame) ---------------
module receiver_ear() {
  // Centre ear with face teeth both sides; rotates on the M6 pivot bolt.
  hull() {
    translate([0,pivot_y,pivot_z]) rotate([0,90,0]) cylinder(r=ear_r, h=ear_t, center=true);
    translate([-ear_t/2, pivot_y-26, rx_back_z-0.5]) cube([ear_t, 52, 0.6]);
  }
  for (m=[0,1]) mirror([m,0,0])
    translate([ear_t/2, pivot_y, pivot_z]) rotate([0,90,0]) rosette_teeth(0);
}

module dock_receiver() {
  difference() {
    union() {
      // Main plate.
      translate([0,(rx_bottom_y+receiver_top_y)/2,rx_back_z])
        rounded_prism(receiver_w, receiver_top_y-rx_bottom_y, rx_depth, receiver_edge_r);

      // Bottom ledge: carries the case's weight, the spring pins and the electronics cavity.
      translate([0, (rx_bottom_y+ledge_y)/2, rx_back_z])
        rounded_prism(ledge_w, ledge_t, ledge_top_z-rx_back_z, 4);

      // Lock tower on the right-hand side.
      translate([38, lock_y-18, lock_z-lock_nut_clear_d/2-2])
        cube([lock_outer_x-38, 36, rx_front_z-(lock_z-lock_nut_clear_d/2-2)]);

      receiver_ear();
    }

    // Dovetail channels with the SAME flank slope as the rails, then a straight floor
    // clearance. Closed at the bottom (end stop), open at the top for insertion.
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

    // Striker slot: open at the top, ends below the seated striker position.
    translate([striker_x0-1.0, striker_y - striker_w/2 - (ledge_gap-ledge_min_gap) - 0.6,
               striker_z - striker_t/2 - 0.6])
      cube([striker_x1-striker_x0+1.6, receiver_top_y + 2 - (striker_y - striker_w/2 - 1.1),
            striker_t + 0.6 + 10]);

    // Cam swing pocket (cam turns 90 degrees in the Y-Z plane).
    translate([cam_x - cam_t/2 - 0.8, lock_y - cam_arm - 1.5, lock_z - cam_arm - 1.5])
      cube([cam_t + 1.6, 2*cam_arm + 3, rx_front_z - (lock_z - cam_arm - 1.5) + 0.1]);

    // Lock body + nut cavity, open at the back for fitting the lock.
    translate([cam_x + cam_t/2 + 0.8, lock_y - lock_nut_clear_d/2, lock_z - lock_nut_clear_d/2 - 2.1])
      cube([lock_outer_x - lock_panel_t - (cam_x + cam_t/2 + 0.8), lock_nut_clear_d,
            lock_nut_clear_d + 2.1]);

    // D-shaped lock bore through the side panel.
    translate([lock_outer_x - lock_panel_t - 0.05, lock_y, lock_z])
      rotate([0,90,0])
        intersection() {
          cylinder(d=lock_bore_d, h=lock_panel_t+0.1);
          translate([-lock_bore_d/2, -lock_bore_flat/2, -0.1])
            cube([lock_bore_d, lock_bore_flat, lock_panel_t+0.3]);
        }

    // Spring-pin block pocket in the ledge face.
    xz_pocket(pin_block_w, pin_block_h, pin_block_depth + 0.1, 1, ledge_y, pad_z, dir=-1);

    // Seal groove around the pins (foam or silicone cord), compresses on the case bottom face.
    translate([0, ledge_y + 0.01, pad_z]) rotate([90,0,0])
      ring_groove(pin_block_w + 2*(dock_gasket_offset+dock_gasket_w),
                  pin_block_h + 2*(dock_gasket_offset+dock_gasket_w),
                  2 + dock_gasket_offset + dock_gasket_w,
                  dock_gasket_w, dock_gasket_depth + 0.01, 0);

    // Electronics cavity (USB-C socket, Rd resistors, VBUS switch), open at the back for the lid.
    translate([-cav_w/2, cav_y0, rx_back_z - 0.05])
      cube([cav_w, cav_y1 - cav_y0 + 0.05, cav_top_z - rx_back_z + 0.05]);

    // Waterproof panel-mount USB-C socket through the bottom (rider-facing) wall.
    translate([usbc_x, rx_bottom_y - 0.05, usbc_z]) rotate([-90,0,0])
      cylinder(d=usbc_panel_hole_d, h=ledge_wall + 0.1);

    // Lid insert holes.
    for (p = lid_screw_xy())
      translate([p[0], p[1], rx_back_z - 0.05]) cylinder(d=lid_insert_d, h=6);

    // Pivot bolt.
    translate([0, pivot_y, pivot_z]) rotate([0,90,0])
      cylinder(d=pivot_bolt_d, h=ear_t + 2*rosette_h + 1, center=true);
  }
}

function lid_screw_xy() = [
  for (sx=[-1,1], yy=[rx_bottom_y + 3.5, ledge_y - 3.0]) [sx*(ledge_w/2 - 4), yy]
];

module ledge_lid() {
  // Back cover for the electronics cavity. Seal with a 1 mm closed-cell foam gasket.
  difference() {
    translate([0, (rx_bottom_y+ledge_y)/2, rx_back_z - lid_t])
      rounded_prism(ledge_w - 1, ledge_t - 1, lid_t, 4);
    for (p = lid_screw_xy())
      translate([p[0], p[1], rx_back_z - lid_t - 0.05]) cylinder(d=3.4, h=lid_t + 0.1);
  }
}

// ------------------------- PIVOT BASE (pivot-axis frame) ---------------
// Origin on the pivot axis; X is the axis. The base flange sits on four rubber grommets.
module mount_base() {
  inner = ear_t/2 + rosette_h + rosette_clear;
  difference() {
    union() {
      for (sx=[-1,1]) hull() {
        translate([sx*(inner + fork_ear_t/2), 0, 0])
          rotate([0,90,0]) cylinder(r=ear_r, h=fork_ear_t, center=true);
        translate([sx*(inner + fork_ear_t/2) - fork_ear_t/2, -ear_r, -pivot_h + grommet_lift + base_t - 0.1])
          cube([fork_ear_t, 2*ear_r, 0.1]);
      }
      // Fork teeth on the inner faces, offset half a tooth so they mesh with the ear.
      for (m=[0,1]) mirror([m,0,0])
        translate([inner, 0, 0]) rotate([0,-90,0]) rosette_teeth(fork_phase);
      translate([0,0,-pivot_h + grommet_lift])
        rounded_prism(base_w, base_d, base_t, 6);
    }
    translate([0,0,0]) rotate([0,90,0])
      cylinder(d=pivot_bolt_d, h=2*(inner+fork_ear_t)+1, center=true);
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*grommet_x, sy*grommet_y, -pivot_h + grommet_lift]) {
        translate([0,0,-0.05]) cylinder(d=grommet_hole_d, h=base_t+0.1);
        translate([0,0,grommet_web_t]) cylinder(d=grommet_cbore_d, h=base_t);
      }
  }
}

// ------------------------- METAL BAR PLATE (bike frame) ----------------
module bar_plate_2d() {
  difference() {
    hull() {
      for (sx=[-1,1]) translate([sx*bar_bolt_spacing/2, 0]) circle(r=bar_bolt_clear_d/2 + 7);
      translate([0,-plate_reach]) offset(r=6) square([base_w-12, base_d-12], center=true);
    }
    for (sx=[-1,1]) hull() for (dy=[-bar_bolt_slot/2, bar_bolt_slot/2])
      translate([sx*bar_bolt_spacing/2, dy]) circle(d=bar_bolt_clear_d);
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*grommet_x, -plate_reach + sy*grommet_y]) circle(d=4.2); // tap M5 or 5.3 for nyloc
  }
}

module bar_plate() {
  translate([0,0,-plate_t]) linear_extrude(height=plate_t) bar_plate_2d();
}

// Template for cutting the lock's supplied steel cam to length (2 mm steel).
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
    translate([phone_x_offset,phone_y_offset,back_wall+back_pad])
      rounded_prism(phone_w,phone_l,phone_t,phone_corner_r);
}

module demo_window() {
  color([0.35,0.75,0.95,0.35])
    translate([0,0,case_depth+EXPLODE*0.45]) window_template();
}

module demo_cam_locked() {
  color([0.75,0.75,0.78])
    translate([cam_x - cam_t/2, lock_y, lock_z]) rotate([0,90,0]) rotate([0,0,90])
      translate([0,0,0]) cam_template();
}

// Case + shoe + receiver, in dock frame.
module dock_stack() {
  translate([0, -shoe_y_case, EXPLODE]) {
    color([0.22,0.25,0.28]) case_body();
    if (SHOW_PHONE) demo_phone();
    if (SHOW_WINDOW) demo_window();
    color([0.12,0.13,0.15])
      translate([0,0,case_depth+window_t+EXPLODE]) front_bezel();
  }
  color([0.25,0.28,0.32]) translate([0,0,EXPLODE*0.4]) dock_shoe();
  color([0.38,0.42,0.46]) dock_receiver();
  color([0.30,0.30,0.30]) translate([0,0,-EXPLODE*0.5]) ledge_lid();
  demo_cam_locked();
}

module assembly() {
  // Metal bar plate under the rear handlebar-clamp bolts.
  color([0.70,0.72,0.75]) bar_plate();

  translate([0, -plate_reach, pivot_h]) {
    color([0.30,0.33,0.36]) mount_base();
    rotate([tilt,0,0]) translate([0, -pivot_y, -pivot_z]) dock_stack();
  }

  if (SHOW_BIKE_REFERENCE) {
    % translate([-300, bar_ref_y, -bar_ref_d/2 - 8]) rotate([0,90,0]) cylinder(d=bar_ref_d, h=600);
    % for (sx=[-1,1]) translate([sx*bar_bolt_spacing/2, 0, 0]) cylinder(d=13, h=6);
  }
}

// ------------------------- PART SELECTOR -----------------------------
if (PART == "assembly") {
  assembly();
} else if (PART == "case") {
  case_body();
} else if (PART == "bezel") {
  front_bezel();
} else if (PART == "window_template") {
  window_template();
} else if (PART == "shoe") {
  dock_shoe();
} else if (PART == "receiver") {
  dock_receiver();
} else if (PART == "ledge_lid") {
  ledge_lid();
} else if (PART == "mount_base") {
  mount_base();
} else if (PART == "bar_plate") {
  bar_plate();
} else if (PART == "bar_plate_2d") {
  bar_plate_2d();
} else if (PART == "cam_template") {
  cam_template();
} else {
  echo("Unknown PART.");
}

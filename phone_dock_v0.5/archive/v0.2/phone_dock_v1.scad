/*
  Parametric motorcycle phone enclosure + quick-release dock
  Version: 0.2 concept prototype

  Units: millimetres
  Coordinate system:
    X = phone width
    Y = phone length (top is +Y, USB edge assumed -Y)
    Z = depth (phone screen faces +Z)

  IMPORTANT:
  - This is a dimensioned starting architecture, not a validated waterproof product.
  - Printed parts are concept/prototype parts. Use metal hardware for the handlebar clamp,
    keyed draw-cam, striker, and any load-bearing retention features for road use.
  - Measure the actual phone and chosen connector before printing final parts.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "case", "bezel", "window_template", "shoe", "receiver"
PART = "assembly";
SHOW_PHONE = true;
SHOW_WINDOW = true;
EXPLODE = 0; // set to 10-25 for exploded preview spacing

$fn = 64;

// ------------------------- PHONE PROFILE ----------------------------
// Example values only. Replace with measured phone dimensions.
phone_w = 75.0;
phone_l = 160.0;
phone_t = 9.0;             // phone body thickness, excluding camera bump
phone_corner_r = 9.0;

// Internal clearances and retention
side_clearance = 0.60;    // per side; include liner allowance in final measurement
end_clearance = 0.60;
front_gap = 0.80;          // screen-to-window air gap; validate touchscreen operation
back_pad = 2.00;           // silicone/EVA pad allowance behind phone

// Rear camera bump relief, measured from phone rear face
camera_relief_enable = true;
camera_x = 0;              // camera bump centre X relative to phone centre
camera_y = 62;             // camera bump centre Y; top camera island is usually +Y
camera_w = 34;
camera_h = 36;
camera_protrusion = 3.0;
camera_relief_clearance = 0.5;
min_rear_skin = 1.8;       // remaining plastic below camera relief; do not reduce casually

// Cable-routing space: phone is offset away from a side lane and a bottom plug bay.
usb_bay_h = 12.0;          // free space beyond the phone's USB edge
cable_lane_w = 0.0;        // no side gutter in V1; cable runs in a shallow rear raceway
cable_channel_w = 5.0;
cable_channel_depth = 1.6;

// ------------------------- ENCLOSURE --------------------------------
wall = 3.2;
back_wall = 5.5;
case_corner_r = 13;
flange = 11.0;               // material outside phone cavity for gasket + screws
body_extra_margin = 0.0;    // optional extra outside dimension

// Front window and seal
window_t = 2.0;             // laser-cut polycarbonate, not printed
window_edge_margin = 2.0;   // window sheet margin from outer case edge
screen_mask_margin = 2.8;   // bezel overlap onto screen edge; check active display area
bezel_t = 2.8;
bezel_corner_r = 13;
gasket_width = 2.4;         // round/square silicone cord width
 gasket_depth = 1.5;        // compression channel depth; cord must be slightly proud
seal_offset = 2.4;          // from cavity edge to gasket channel centre

// Front bezel fastening (use heat-set brass inserts in shell)
bezel_insert_d = 4.2;       // set to insert manufacturer's recommended hole size
bezel_insert_depth = 5.5;
bezel_screw_clearance = 3.3;
bezel_screw_inset = 4.0;    // from outer edge to screw centre
bezel_positions = [
  [-1,-1], [1,-1], [-1,1], [1,1],
  [-1,-0.33], [1,-0.33], [-1,0.33], [1,0.33]
];

// Rear shoe fastening (blind inserts; must not break through inner back wall)
shoe_boss_d = 10.0;
shoe_boss_h = 4.2;
shoe_insert_d = 4.2;
shoe_insert_depth = 6.0;
shoe_mount_x = 20;
shoe_mount_y = 32;

// USB cable path: sealed gland through rear wall, then short protected pigtail to dock cartridge
cable_gland_hole_d = 8.5;  // replace with the gland's required panel hole
cable_gland_y = -26;       // relative to phone centre; adjust to dock cartridge location

// ------------------------- COMMON DOCK INTERFACE --------------------
// This interface remains identical across phone-specific shells.
dock_plate_w = 58;
dock_plate_h = 76;
dock_plate_t = 4.0;
dock_corner_r = 8;
dock_rail_spacing = 40;
dock_rail_len = 56;
dock_rail_root_w = 8.0;       // narrow at plate face
dock_rail_tip_w = 13.0;       // wider at far end, captured by receiver
dock_rail_depth = 5.5;
dock_preseat_gap = 2.0;       // gap between shoe and receiver before key is turned
// Receiver channel depth leaves room for the 2 mm keyed draw-in stroke.
dock_rail_side_clearance = 0.35;  // lateral running clearance per side
dock_rail_depth_clearance = 2.2;  // axial room for the keyed draw-in stroke
dock_rail_root_clearance = 0.35;

// Electrical cartridge pocket. These are placeholders: edit to the selected connector's drawing.
contact_pocket_w = 24;
contact_pocket_h = 15;
contact_pocket_depth = 2.5;
contact_pocket_y = -26;
contact_through_w = 14;
contact_through_h = 8;
contact_through_depth = dock_plate_t + 0.5;

// Key-lock catch. Use a purchased metal cam lock + metal cam/tongue; printed cam is not recommended.
key_lock_bore_d = 19.0;       // use exact lock datasheet panel cut-out
key_lock_boss_d = 26.0;
key_lock_boss_len = 5.0;
key_lock_y = -dock_plate_h/2 + 15;
key_lock_z = -dock_plate_t - dock_rail_depth/2;
cam_slot_w = 5.0;
cam_slot_h = 2.0;
cam_slot_depth = 4.0;
striker_y_w = 8.0;
striker_z_t = 3.0;
striker_x_start = dock_rail_spacing/2 + (dock_rail_root_w+dock_rail_tip_w)/4 - 0.2;

// Receiver attaches to a metal handlebar clamp / bracket using these holes.
receiver_w = 120;
striker_x_end = receiver_w/2 - 0.2;
receiver_h = 94;
receiver_back_t = 4.5;
receiver_mount_hole_d = 6.5; // for M6 hardware, verify clamp bracket
receiver_mount_x = 48;
receiver_mount_y = 34;
receiver_edge_r = 9;

// ------------------------- MATERIAL / PRINT NOTES -------------------
// Main shell: ASA or PA12; window: 2 mm hard-coated polycarbonate.
// Seal: continuous silicone cord / die-cut gasket. Do not rely on printed TPU alone.
// Bezel fasteners: stainless M3 into heat-set inserts.
// Rear shoe: PA12 / ASA prototype; final rails and cam catch should be metal-reinforced.

// ------------------------- DERIVED DIMENSIONS -----------------------
cavity_w = phone_w + 2*side_clearance;
cavity_h = phone_l + 2*end_clearance + usb_bay_h;
phone_x_offset = 0;
phone_y_offset = usb_bay_h/2;
cable_channel_y0 = phone_y_offset - phone_l/2 - 3.0;
body_w = cavity_w + 2*flange + body_extra_margin;
body_h = cavity_h + 2*flange + body_extra_margin;
case_depth = back_wall + back_pad + phone_t + front_gap;

bezel_aperture_w = phone_w - 2*screen_mask_margin;
bezel_aperture_h = phone_l - 2*screen_mask_margin;
window_w = body_w - 2*window_edge_margin;
window_h = body_h - 2*window_edge_margin;

seal_outer_w = cavity_w + 2*(seal_offset + gasket_width/2);
seal_outer_h = cavity_h + 2*(seal_offset + gasket_width/2);
seal_inner_w = seal_outer_w - 2*gasket_width;
seal_inner_h = seal_outer_h - 2*gasket_width;

// ------------------------- VALIDATION --------------------------------
assert(phone_w > 40 && phone_l > 80 && phone_t > 5, "Phone dimensions look invalid.");
assert(back_wall - (camera_protrusion + camera_relief_clearance) >= min_rear_skin || !camera_relief_enable,
       "Camera recess leaves too little rear skin. Increase back_wall or reduce camera protrusion.");
assert(seal_outer_w < body_w && seal_outer_h < body_h,
       "Gasket channel does not fit inside the front flange. Increase flange or reduce seal offset.");
assert(bezel_aperture_w > 20 && bezel_aperture_h > 40, "Bezel aperture is too small.");
assert(dock_rail_tip_w > dock_rail_root_w, "Dovetail rail tip must be wider than its root.");
assert(dock_rail_depth_clearance >= dock_preseat_gap + 0.1,
       "Receiver rail channel needs at least the full key draw-in travel.");

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
        rounded_prism(w-2*groove_w, h-2*groove_w, depth+0.1,
                      max(1, radius-groove_w));
    }
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

module shoe_bosses() {
  for (sx=[-1,1], sy=[-1,1]) {
    translate([sx*shoe_mount_x, sy*shoe_mount_y,-shoe_boss_h])
      cylinder(d=shoe_boss_d,h=shoe_boss_h+0.02);
  }
}

module rear_insert_bores() {
  for (sx=[-1,1], sy=[-1,1]) {
    translate([sx*shoe_mount_x, sy*shoe_mount_y,
               -shoe_boss_h-0.02])
      cylinder(d=shoe_insert_d,h=shoe_insert_depth+0.02);
  }
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

// Extrude a polygon defined in X/Z along the Y axis.
module xz_profile_along_y(points, y_min, y_max) {
  translate([0,y_max,0])
    rotate([90,0,0])
      linear_extrude(height=y_max-y_min)
        polygon(points=points);
}

// ------------------------- PHONE ENCLOSURE ---------------------------
module case_body() {
  union() {
    difference() {
      union() {
        rounded_prism(body_w,body_h,case_depth,case_corner_r);
        shoe_bosses();
      }

      // Phone cavity, open at the front.
      translate([0,0,back_wall])
        rounded_prism(cavity_w,cavity_h,case_depth-back_wall+0.05,
                      max(4,phone_corner_r+side_clearance));

      // Continuous gasket groove on the front flange.
      ring_groove(seal_outer_w,seal_outer_h,phone_corner_r+seal_offset,
                  gasket_width,gasket_depth,case_depth-gasket_depth);

      // Front bezel insert holes, blind from the front face.
      bezel_holes(case_depth-bezel_insert_depth,bezel_insert_depth+0.03,bezel_insert_d);

      // Rear shoe insert bores, blind from the outside rear; leave a sealing skin.
      rear_insert_bores();

      // Camera island relief, cut from the cavity side into the rear wall, not through it.
      if (camera_relief_enable && camera_protrusion > 0) {
        translate([phone_x_offset+camera_x,phone_y_offset+camera_y,
                   back_wall-camera_protrusion-camera_relief_clearance])
          rounded_prism(camera_w+2*camera_relief_clearance,
                        camera_h+2*camera_relief_clearance,
                        camera_protrusion+camera_relief_clearance+0.05,5);
      }

      // Central shallow cable raceway runs from the bottom USB bay to the rear gland.
      // The phone stands on four raised pads, leaving a protected low-profile cable path underneath.
      translate([-cable_channel_w/2, cable_channel_y0,
                 back_wall-cable_channel_depth])
        cube([cable_channel_w, cable_gland_y-cable_channel_y0,
              cable_channel_depth+0.05]);

      // Cable-gland pass-through. Use an actual sealed gland and strain relief.
      translate([0,cable_gland_y,-0.05])
        cylinder(d=cable_gland_hole_d,h=back_wall+0.1);
    }

    // Four raised support pads maintain the phone-to-rear-wall stand-off for the cable route.
    // Cover these with thin silicone/foam pads to prevent point loading or scratches.
    phone_support_pads();
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

// Flat solid represents a cutting template only. Use real polycarbonate for the window.
module window_template() {
  rounded_prism(window_w,window_h,window_t,case_corner_r-window_edge_margin);
}

// ------------------------- REAR QUICK-RELEASE SHOE -------------------
module dock_shoe() {
  difference() {
    union() {
      // Plate sits against the rear of the case. Rear shoe screws are blind into case inserts.
      translate([0,0,-dock_plate_t])
        rounded_prism(dock_plate_w,dock_plate_h,dock_plate_t,dock_corner_r);

      // Two dovetail tongues. Narrow at shoe, wider at receiver depth.
      for (sx=[-1,1]) {
        xc = sx*dock_rail_spacing/2;
        xz_profile_along_y([
          [xc-dock_rail_root_w/2,-dock_plate_t],
          [xc+dock_rail_root_w/2,-dock_plate_t],
          [xc+dock_rail_tip_w/2,-dock_plate_t-dock_rail_depth],
          [xc-dock_rail_tip_w/2,-dock_plate_t-dock_rail_depth]
        ], -dock_rail_len/2, dock_rail_len/2);
      }

      // Long side striker bar. Prototype may be printed; final should be a bolted stainless strip.
      translate([striker_x_start,key_lock_y-striker_y_w/2,
                 key_lock_z-striker_z_t/2])
        cube([striker_x_end-striker_x_start,striker_y_w,striker_z_t]);
    }

    // Four mounting clearances through shoe plate.
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*shoe_mount_x, sy*shoe_mount_y,
                 -dock_plate_t-0.05])
        cylinder(d=4.4,h=dock_plate_t+0.1);
    }

    // Replaceable connector cartridge pocket on rear face of shoe plate.
    translate([-contact_pocket_w/2,contact_pocket_y-contact_pocket_h/2,
               -dock_plate_t-0.05])
      cube([contact_pocket_w,contact_pocket_h,contact_pocket_depth+0.05]);
    translate([-contact_through_w/2,contact_pocket_y-contact_through_h/2,
               -dock_plate_t-0.05])
      cube([contact_through_w,contact_through_h,dock_plate_t+0.1]);

    // Key-cam notch in the outer end of the striker bar. Final notch must match the metal cam.
    translate([striker_x_end-cam_slot_depth,
               key_lock_y-cam_slot_w/2,
               key_lock_z-cam_slot_h/2])
      cube([cam_slot_depth+0.05,cam_slot_w,cam_slot_h]);
  }
}

// ------------------------- HANDLEBAR-SIDE RECEIVER -------------------
module dock_receiver() {
  receiver_depth = dock_rail_depth + receiver_back_t + dock_rail_depth_clearance;
  // The receiver is set 2 mm behind the shoe. Rails guide the case in first;
  // the keyed draw-cam then pulls it inward to mate the recessed connector halves.
  front_z = -dock_plate_t - dock_preseat_gap;
  rail_mouth_z = -dock_plate_t;
  back_z = front_z - receiver_depth;

  difference() {
    union() {
      translate([0,0,back_z])
        rounded_prism(receiver_w,receiver_h,receiver_depth,receiver_edge_r);

      // Reinforced lock boss is outside the typical phone-case envelope for side key access. Verify with your phone profile.
      translate([receiver_w/2, key_lock_y, key_lock_z])
        rotate([0,90,0]) cylinder(d=key_lock_boss_d,h=key_lock_boss_len,center=false);
    }

    // Matching dovetail channels. Mouth is narrow; inside widens to capture each tongue.
    for (sx=[-1,1]) {
      xc = sx*dock_rail_spacing/2;
      xz_profile_along_y([
        [xc-(dock_rail_root_w/2+dock_rail_root_clearance),rail_mouth_z+0.05],
        [xc+(dock_rail_root_w/2+dock_rail_root_clearance),rail_mouth_z+0.05],
        [xc+(dock_rail_tip_w/2+dock_rail_side_clearance),rail_mouth_z-dock_rail_depth-dock_rail_depth_clearance],
        [xc-(dock_rail_tip_w/2+dock_rail_side_clearance),rail_mouth_z-dock_rail_depth-dock_rail_depth_clearance]
      ], -dock_rail_len/2-0.35, receiver_h/2+1);
    }

    // Matching receiver-side contact cassette recess. Keep this connector recessed during
    // rail insertion; a 2 mm keyed draw-cam stroke mates it axially after seating.
    translate([-contact_pocket_w/2,contact_pocket_y-contact_pocket_h/2,
               front_z-contact_pocket_depth])
      cube([contact_pocket_w,contact_pocket_h,contact_pocket_depth+0.05]);

    // Clearance tunnel for the striker bar. It allows the full 2 mm inward draw stroke.
    // The final keyed metal cam must pull the striker into its locked position.
    translate([striker_x_start-0.2,-dock_rail_len/2-0.35,
               key_lock_z-dock_preseat_gap-striker_z_t/2-0.65])
      cube([striker_x_end-striker_x_start+1.0,
            receiver_h/2+1+ dock_rail_len/2+0.35,
            striker_z_t+dock_preseat_gap+1.3]);

    // Four M6 mounting holes to a metal handlebar clamp / bracket.
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*receiver_mount_x,sy*receiver_mount_y,back_z-0.05])
        cylinder(d=receiver_mount_hole_d,h=receiver_depth+0.1);
    }

    // Key lock panel bore through the side boss and receiver wall.
    translate([receiver_w/2-0.05,key_lock_y,key_lock_z])
      rotate([0,90,0]) cylinder(d=key_lock_bore_d,h=key_lock_boss_len+0.1);
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

module assembly() {
  color([0.22,0.25,0.28]) case_body();
  if (SHOW_PHONE) demo_phone();
  if (SHOW_WINDOW) demo_window();
  color([0.12,0.13,0.15])
    translate([0,0,case_depth+window_t+EXPLODE]) front_bezel();

  color([0.25,0.28,0.32])
    translate([0,0,-EXPLODE*0.6]) dock_shoe();

  color([0.38,0.42,0.46,0.85])
    translate([0,0,-EXPLODE*1.6]) dock_receiver();
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
} else {
  echo("Unknown PART. Use assembly, case, bezel, window_template, shoe, receiver.");
}

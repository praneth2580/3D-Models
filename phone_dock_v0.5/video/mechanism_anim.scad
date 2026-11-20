/*
  Animation scene for the mechanism video (v0.5). Uses the real parts from phone_dock_v0.5.scad.
  Every A_* value is set per frame by make_video.py (-D A_xxx=...).
  Extras drawn here are VISUAL ONLY: spring pins, pads, O-ring, screws, grommets, key,
  lock body, phone screen, smart base, and the wiring (leads, plugs, dock board, wires, potting).
  The crank, yoke, flat bolt and steel keeper are the real lock parts.
*/
include <../phone_dock_v0.5.scad>
PART = "none";
$fn = 40;

A_explode    = 0;    // module separation, mm
A_tilt       = 40;   // clamp rotation on the bar
A_case_dy    = 0;    // case + shoe position along the rails (0 = docked)
A_lock       = 0;    // 0 = unlocked (bolt down), 1 = locked (bolt up in the strike)
A_key_in     = 0;    // 0 = key out, 1 = key fully inserted
A_show_key   = 0;
A_wobble     = 0;    // dock rocking on the grommets, degrees
A_wobble_z   = 0;    // dock bounce on the grommets, mm
A_dock_lift  = 0;    // lift the whole dock off the base (module swap)
A_plate_x    = 0;    // slide the plain base plate out sideways
A_smart_x    = 400;  // slide the smart base in (0 = in place)
A_highlight  = "";   // "clamps", "case", "pins", "lock", "grommets", "oring"
A_section    = "";   // "x": keep x < A_cut (whole scene); "y": keep dock-frame y > A_cut (dock only)
A_cut        = 0;
A_show_bar   = 1;
A_show_mount = 1;    // clamps + base plate (hidden in the lock cutaway, where they would sit in front of the cut)
A_case_only  = 0;    // case-construction scene: only the case, in its own frame
A_phone_z    = 0;    // phone offset (case scene), mm
A_cover_z    = 0;    // back cover + screws offset (case scene), mm
A_wiring     = 0;    // wiring scene: parts go see-through and the cables are drawn
A_wire       = 0;    // 0..1: how far the power highlight has travelled from the bike lead to the phone
A_wire_seg   = -1;   // >= 0 overrides A_wire: highlight up to this power_path() point (fractions run along the next segment)
A_det        = 0;    // 1 = glow on the DET line (case docked, DET pad grounding the DET pin)
A_bike_power = 1;    // amber PWR LED lit
A_head       = 1;    // draw the bright head on the power highlight (off while it waits at the switch)
A_hot        = 0;    // 1 = phone too hot: the case's thermostat is open, charging is off, red OFF LED lit

GOLD = [0.95,0.75,0.25];
STEEL = [0.62,0.62,0.66];
KEEPER_HL = [1.0,0.3,0.05];  // bearing block (or keeper) in the lock scenes: orange-red, so it reads apart from the yellow bolt
RUBBER = [0.08,0.08,0.08];
HL = (A_highlight == "lock") ? [1.0,0.85,0.1] : (A_highlight == "pins") ? [1.0,0.8,0.0] : [1.0,0.55,0.1];
function hl(name, base) = (A_highlight == name) ? [HL[0],HL[1],HL[2], len(base) > 3 ? base[3] : 1] : base;
function keeper_col() = (A_highlight == "lock") ? KEEPER_HL : STEEL;

// Contacts 0-5: DET, VBUS, D+, D-, GND, PRESENT. Full: one row on a 2.8 mm pitch (Mill-Max).
// Budget: 10 P75 pins on 2.54 mm in 2 rows; row 2 (6-9) = VBUS2, GND2 (bridged to VBUS, GND), SPARE1, SPARE2.
PAD_X = [-6.35, -3.81, -1.27, 1.27, 3.81, 6.35, -3.81, 3.81, -1.27, 1.27];
function pin_z(i) = i < 6 ? pad_z + 1.27 : pad_z - 1.27;
TUNNEL_IDX = [0, 1, 2, 3, 4, 5, 8, 9];   // wires to the board (VBUS2/GND2 are bridged on the strip)
BRIDGES = [[1, 6], [4, 7]];
I_GND = 4;
I_PRES = 5;
CABLE_IDX = [1, 2, 3, 4];     // pads whose wires go up the case cable
// X-ray in the wiring scene: every printed part becomes see-through.
function xr(c, a=0.16) = A_wiring ? [c[0], c[1], c[2], a] : c;

// ---------- visual extras ----------
module phone_visual() {
  translate([phone_x_offset, 0, phone_back_z]) {
    color(xr([0.15,0.15,0.17], 0.10)) rounded_prism(phone_l, phone_w, phone_t, phone_corner_r);
    if (!A_wiring || A_wire >= 1) translate([0,0,phone_t - 0.01]) {
      color([0.12,0.45,0.35]) rounded_prism(phone_l-6, phone_w-6, 0.3, 6);
      color([0.2,0.6,1.0]) translate([0,0,0.3])
        linear_extrude(0.2) polygon([[-60,-20],[-20,-18],[0,5],[30,8],[60,25],[60,28],[29,11],[-2,8],[-22,-15],[-60,-17]]);
      color([1,0.3,0.2]) translate([-60,-18.5,0.3]) cylinder(d=6, h=0.3);
    }
  }
}

module oring_visual() {
  color(xr(hl("oring", RUBBER))) translate([0,0,cover_t + tongue_h/2 - 0.75]) difference() {
    rounded_prism(tongue_ow + 0.5, tongue_oh + 0.5, 1.5, tongue_r + 0.25);
    translate([0,0,-0.1]) rounded_prism(tongue_ow - 2*oring_groove_depth + 0.1, tongue_oh - 2*oring_groove_depth + 0.1, 1.7, tongue_r - oring_groove_depth);
  }
}

module corner_screws_visual() {
  for (sx=[-1,1], sy=[-1,1]) {
    p = corner_screw_xy(sx, sy);
    color(xr([0.75,0.75,0.78])) translate([p[0], p[1], -0.2]) {
      cylinder(d1=corner_csk_d - 0.2, d2=2.9, h=1.6);
      cylinder(d=2.9, h=cover_t + corner_insert_depth - 1);
    }
  }
}

// Case + shoe in dock frame (moves with A_case_dy).
module case_assembly_visual() {
  color(xr(hl("case", [0.22,0.25,0.28]), 0.10)) case_shell();
  translate([0,0,A_cover_z]) {
    color(xr([0.30,0.33,0.36])) case_back();
    if (thermal_cutoff) thermostat_visual();
    oring_visual();
    corner_screws_visual();
  }
  if (SHOW_PHONE) translate([0,0,A_phone_z]) phone_visual();
  if (!A_case_only) {
    color(xr([0.25,0.28,0.32])) dock_shoe();
    if (A_section == "" || (A_section == "x" && A_highlight != "lock")) color(xr(keeper_col())) keeper_part();
    if (A_section != "x") pads_visual(99);
  }
}

// KSD9700-type thermostat in its pocket (+ thermal pad); glows red when it has opened (phone too hot).
module thermostat_visual() {
  color(A_hot ? [1.0,0.2,0.1] : [0.85,0.85,0.8]) translate([therm_x - therm_l/2, therm_y - therm_w/2, therm_floor_z]) cube([therm_l, therm_w, therm_t]);
  color([0.7,0.7,0.7,0.25]) translate([therm_x - therm_l/2 + 1, therm_y - therm_w/2 + 1, therm_floor_z + therm_t]) cube([therm_l - 2, therm_w - 2, therm_pad_t]);
}

// Contact target board + pads in the bottom face of the nose (xmax limits which pads are drawn).
module pads_visual(xmax) {
  color([0.1,0.45,0.2]) intersection() {
    translate([-pad_pocket_w/2, nose_y0 + 0.2, pad_z - pad_pocket_h/2]) cube([pad_pocket_w, pad_pocket_depth - 0.2, pad_pocket_h]);
    translate([-100 + xmax, -500, -500]) cube([100, 1000, 1000]);
  }
  for (i=[0:len(PAD_X) - 1]) if (PAD_X[i] <= xmax) color(GOLD) translate([PAD_X[i] - 1.0, nose_y0 + 0.05, pin_z(i) - 0.9]) cube([2.0, 0.3, 1.8]);
}

module spring_pins(case_dy, xmax=99) {
  face = nose_y0 + case_dy;
  tip = min(pin_face_y + pin_free, face);
  for (i=[0:len(PAD_X) - 1]) if (PAD_X[i] <= xmax) {
    x = PAD_X[i]; z = pin_z(i);
    color([0.55,0.45,0.2]) translate([x, pin_face_y - pin_block_depth + 0.5, z]) rotate([-90,0,0]) cylinder(d=1.4, h=pin_block_depth - 1);
    color(hl("pins", GOLD)) translate([x, pin_face_y - 2, z]) rotate([-90,0,0]) cylinder(d=1.3, h=tip - (pin_face_y - 2));
    color(hl("pins", GOLD)) translate([x, tip, z]) sphere(d=1.3);
  }
}

// Real lock parts (crank, yoke, steel bolt), highlighted together.
module mech_visual(turn) {
  color(xr(hl("lock", [0.80,0.80,0.84]))) crank_placed(turn);
  color(xr(hl("lock", [0.55,0.58,0.62]))) lock_yoke(turn);
  color(xr(hl("lock", [0.85,0.85,0.90]))) translate([bolt_x - bolt_w/2, bolt_y - bolt_t/2, yoke_bottom_locked + yoke_dz(turn)]) cube([bolt_w, bolt_t, bolt_len]);
}

module lock_body_visual() {
  color(xr([0.6,0.6,0.62])) translate([crank_x1 + 0.2, lock_y, lock_z]) rotate([0,90,0]) cylinder(d=lock_bore_d-0.4, h=lock_panel_inner_x - crank_x1);
  color(xr([0.72,0.72,0.74])) translate([lock_face_x, lock_y, lock_z]) rotate([0,90,0]) difference() {
    cylinder(d=22, h=1.2);
    translate([0,0,0.6]) difference() { cylinder(d=8, h=1); cylinder(d=4.5, h=1); }
  }
}

// Tubular key on the lock axis (x); it slides in along -x and turns about x.
module key_visual(key_in, turn) {
  out = 35*(1-key_in);
  translate([lock_face_x + 1.2 + out, lock_y, lock_z]) rotate([90*turn, 0, 0]) color([0.85,0.75,0.35]) {
    translate([-12,0,0]) rotate([0,90,0]) cylinder(d=7, h=12);
    rotate([0,90,0]) cylinder(d=10, h=4);
    translate([4,-2,-12]) cube([20, 4, 24]);
  }
}

module grommets_visual() {
  for (sx=[-1,1], sy=[-1,1]) translate([sx*amps_x, sy*amps_y, 0]) color(hl("grommets", RUBBER)) {
    cylinder(d=14, h=grommet_float);
    translate([0,0,-base_t+grommet_web_t-2]) cylinder(d=14, h=2);
    translate([0,0,-base_t]) cylinder(d=9.3, h=base_t);
  }
}

module smart_base_visual() {
  color([0.85,0.45,0.12]) difference() {
    union() {
      translate([0,0,-base_t]) rounded_prism(base_len, base_depth, base_t, 8);
      translate([0,0,-base_t-18]) rounded_prism(2*(slot_in - clamp_w/2 - 3), base_depth-6, 18.05, 6);
    }
    for (sx=[-1,1], sy=[-1,1]) hull() for (x=[slot_in, slot_out]) translate([sx*x, sy*plate_bolt_y, -base_t-1]) cylinder(d=5.5, h=base_t+2);
  }
  for (sx=[-1,1]) translate([sx*(slot_out - 2), 0, 0]) {
    color([0.85,0.45,0.12]) rounded_prism(26, 46, 16, 6);
    color([0.1,0.1,0.1]) translate([0, -23.2, 8]) rotate([90,0,0]) cylinder(d=18, h=0.8);
    for (r=[3,6,9]) color([0.3,0.3,0.3]) translate([0, -23.9, 8]) rotate([90,0,0]) difference() { cylinder(r=r, h=0.3); translate([0,0,-0.1]) cylinder(r=r-0.8, h=0.5); }
  }
  for (i=[-3:3]) color(i%2==0 ? [0.2,1,0.3] : [0.2,0.6,1]) translate([i*6, -base_depth/2 + 6.2, -base_t - 9]) cube([3, 0.5, 2]);
}

// ---------- wiring (visual only; dock frame, case docked) ----------
// Bike lead -> sealed USB-C socket -> dock board (VBUS switch) -> 5 wires -> spring pins -> pads ->
// cable potted through the nose and back cover -> edge channel -> 90-degree plug -> phone.
WIRE_COL = [[1.0,0.85,0.1], [0.9,0.12,0.1], [0.1,0.7,0.25], [0.95,0.95,0.95], [0.1,0.1,0.1], [0.15,0.35,0.95],   // DET VBUS D+ D- GND PRESENT
            [0.9,0.12,0.1], [0.1,0.1,0.1], [1.0,0.5,0.0], [0.6,0.3,0.85]];                                            // VBUS2 GND2 SPARE1 SPARE2
FLOW = [1.0,0.45,0.0];
port_z = phone_back_z + phone_t/2;
phone_end_x = phone_x_offset + usb_side*phone_l/2;
bay_xc = usb_side*(cav_w/2 - usb_bay_h/2);
edge_y = -cav_h/2 + 3.5;
cable_z = cover_t - cable_channel_depth + 1.5;
// Full: the bike lead's USB-C plug goes into the sealed socket. Budget: the cut lead goes straight in through a potted hole.
lead_pts = [[cable_x, receiver_bottom_y - 50, cable_z - 12], [cable_x, receiver_bottom_y - 28, cable_z - 3], [cable_x, pcb_y0 + 1.5, cable_z]];
board_top = pcb_z0 + 1.6;    // 1.6 mm dock board (perfboard or PCB) on the pocket floor
// Full: U1 = TPS2552, U2 = USBLC6 ESD. Budget: U1 = Q2 (AO3401A P-MOSFET switch), U2 = F1 (1.5 A resettable fuse).
u1_c = [-22.5, -40.0, board_top];    // Q2 AO3401A P-MOSFET switch
u2_c = [-26.0, -44.0, board_top];    // F1 1.5 A resettable fuse
q1_c = [-17.6, -39.6, board_top];    // Q1 2N7002: shorts the red LED while charging is on
esd_c = [-31.5, -38.5, board_top];   // U3 USBLC6-2SC6 USB ESD
r_cluster = [[-33.5, -42.5], [-28.0, -41.5], [-27.0, -36.5], [-23.0, -36.5], [-19.0, -36.5], [-16.0, -36.5]];
r_vert = [[led_x_dock, -43.2], [led_x_off, -43.2]];   // R7 (DOCK), R8 (OFF), behind their LEDs
chip_c = u1_c + [0, 0, 0.8];

module tube(p, d) for (i=[0:len(p)-2]) hull() { translate(p[i]) sphere(d=d, $fn=12); translate(p[i+1]) sphere(d=d, $fn=12); }
function seg_len(p, i) = norm(p[i+1] - p[i]);
function cum_len(p, i) = i <= 0 ? 0 : cum_len(p, i-1) + seg_len(p, i-1);
function path_len(p) = cum_len(p, len(p)-1);
function point_at(p, s, i=0) = (i >= len(p) - 2 || cum_len(p, i+1) >= s)
  ? p[i] + (p[i+1] - p[i])*max(0, min(1, (s - cum_len(p, i))/seg_len(p, i))) : point_at(p, s, i+1);
module tube_upto(p, s, d) for (i=[0:len(p)-2]) if (s > cum_len(p, i))
  hull() { translate(p[i]) sphere(d=d, $fn=12); translate(point_at(p, min(s, cum_len(p, i+1)), i)) sphere(d=d, $fn=12); }

// The power path the highlight follows (VBUS, pin 2).
function power_path() = concat([lead_pts[1], lead_pts[2]], [   // starts on the visible end of the lead
  u2_c + [0, 0, 1.0],                                  // F1 fuse
  chip_c,                                              // VBUS switch on the dock board
  [pcb_x1 - 0.5, -40.4, -5],
  [PAD_X[1], -40.4, -5],                               // wire channel to the pin block
  [PAD_X[1], pin_face_y - pin_block_depth + 0.5, pin_z(1)],
  [PAD_X[1], nose_y0 + 0.1, pin_z(1)],                 // spring pin -> pad
  [PAD_X[1], wire_y, pad_z + pad_pocket_h/2 - 0.5],
  [0, wire_y, pad_z + pad_pocket_h/2 + 0.5],
  [0, wire_y, cable_z],                                // up the potted pass-through
  [0, edge_y, cable_z],
  [bay_xc, edge_y, cable_z],                           // along the edge channel
  [bay_xc, usb_port_y, cable_z],
  [bay_xc, usb_port_y, port_z - 1],                    // up into the 90-degree plug
  [phone_end_x - usb_side*5, usb_port_y, port_z]       // into the phone
]);

module wiring_visual() {
  // The power highlight travelling along the path, with a bright head. Drawn first so the
  // translucent plugs below blend over it. A_wire 0..0.5 covers the dock side (lead -> pad,
  // point 7), 0.5..1 the case side, so each half gets equal screen time.
  L = path_len(power_path());
  L_pad = cum_len(power_path(), 7);
  seg = floor(A_wire_seg);
  d = A_wire_seg >= 0 ? cum_len(power_path(), seg) + (A_wire_seg - seg)*(seg < len(power_path()) - 1 ? seg_len(power_path(), seg) : 0)
    : A_wire <= 0.5 ? 2*A_wire*L_pad : L_pad + (2*A_wire - 1)*(L - L_pad);
  if (d > 0) color(FLOW) {
    tube_upto(power_path(), d, A_wire <= 0.5 ? 2.2 : 3.4);
    tube_upto([power_path()[0], power_path()[1]], d, 4.8);     // fatter than the bike lead, so it shows on it
  }
  if (A_head && d > 0 && d < L) color([1.0,0.95,0.4]) translate(point_at(power_path(), d)) sphere(d=A_wire <= 0.5 ? 4 : 6, $fn=20);
  color([0.1,0.1,0.1]) tube(lead_pts, 4);
  // The cut bike lead, potted in its hole; its 4 wires go to F1 (red), GND (black) and the ESD chip (green, white).
  color([0.85,0.6,0.15,0.5]) translate([cable_x, receiver_bottom_y - 0.05, cable_z]) rotate([-90,0,0]) cylinder(d=cable_d + 0.1, h=pcb_y0 - receiver_bottom_y + 0.1, $fn=24);
  color(WIRE_COL[1]) tube([lead_pts[2], u2_c + [0, 0, 1.0]], 0.8);
  color(WIRE_COL[4]) tube([lead_pts[2] + [-1, 0, 0], [-31.0, -46.5, board_top + 0.4]], 0.8);
  for (k=[0, 1]) color(WIRE_COL[2 + k]) tube([lead_pts[2] + [-1.5 + 0.8*k, 0, 0.5], [esd_c[0] - 0.6 + 1.2*k, esd_c[1] - 1.6, board_top + 0.8]], 0.6);   // D+, D- to the ESD chip
  // Dock board (shown as perfboard; an ordered PCB of the same size works the same way).
  color([0.78,0.62,0.35]) difference() {
    translate([pcb_x0 + 0.3, pcb_y0 + 0.3, board_top - 1.6]) cube([pcb_x1 - pcb_x0 - 0.6, pcb_y1 - pcb_y0 - 0.6, 1.6]);
    for (gx=[pcb_x0 + 1.5:2.54:pcb_x1 - 1], gy=[pcb_y0 + 1.5:2.54:pcb_y1 - 1])   // perfboard holes
      translate([gx, gy, board_top - 1.7]) cylinder(d=0.9, h=1.8, $fn=8);
  }
  color([0.1,0.1,0.1]) translate(u1_c - [1.45, 0.65, 0]) cube([2.9, 1.3, 1.0]);                         // Q2
  color([0.85,0.55,0.15]) translate(u2_c - [1.6, 1.25, 0]) cube([3.2, 2.5, 1.0]);                       // F1
  color([0.1,0.1,0.1]) translate(esd_c - [1.45, 1.4, 0]) cube([2.9, 2.8, 1.1]);                         // U3 ESD
  color([0.1,0.1,0.1]) translate(q1_c - [1.45, 0.65, 0]) cube([2.9, 1.3, 1.0]);
  for (r=r_cluster) color([0.15,0.15,0.15]) translate([r[0] - 0.8, r[1] - 0.4, board_top]) cube([1.6, 0.8, 0.5]);
  for (r=r_vert) color([0.15,0.15,0.15]) translate([r[0] - 0.4, r[1] - 0.8, board_top]) cube([0.8, 1.6, 0.5]);
  for (l=[[led_x_pwr, [1.0,0.65,0.1]], [led_x_dock, [0.2,0.85,0.3]], [led_x_off, [0.95,0.2,0.15]]]) {
    x = l[0];
    // 3 mm through-hole LED standing up into its light pipe
    color([l[1][0], l[1][1], l[1][2], 0.7]) translate([x, led_y, board_top]) {
      cylinder(d=3.8, h=1.0, $fn=20); cylinder(d=3.0, h=rx_front_z - board_top - 1.6, $fn=20);
      translate([0, 0, rx_front_z - board_top - 1.6]) sphere(d=3.0, $fn=20);
    }
  }
  // DET glow: board -> DET wire -> DET pin (case docked).
  if (A_det) color([1.0,0.95,0.2]) {
    tube([u1_c + [0, 0, 1], [pcb_x1 - 0.5, -41.7, -5], [PAD_X[0], -41.7, -5], [PAD_X[0], pin_face_y - pin_block_depth + 0.5, pin_z(0)], [PAD_X[0], nose_y0 + 0.1, pin_z(0)]], 1.6);
    translate([PAD_X[0], nose_y0 + 0.1, pin_z(0)]) sphere(d=3.2, $fn=16);
  }
  // 8 wires through the channel to the pin tails.
  for (k=[0:len(TUNNEL_IDX) - 1]) let(i = TUNNEL_IDX[k], wy = -41.7 + k*0.5) color(WIRE_COL[i])
    tube([[pcb_x1 - 2.0, wy, board_top + 0.3], [pcb_x1 - 0.5, wy, -5], [PAD_X[i], wy, -5], [PAD_X[i], pin_face_y - pin_block_depth + 0.5, pin_z(i)]], 0.6);
  // Second-row VBUS2 / GND2 bridged to VBUS / GND on the pin strip.
  for (b=BRIDGES) color(WIRE_COL[b[0]]) tube([[PAD_X[b[0]], pin_face_y - pin_block_depth + 0.7, pin_z(b[0])], [PAD_X[b[1]], pin_face_y - pin_block_depth + 0.7, pin_z(b[1])]], 0.7);
  // Case side: pad board wires -> cable potted through the nose and the back cover -> edge channel -> plug.
  translate([0, A_case_dy, 0]) {
    for (i=CABLE_IDX) color(WIRE_COL[i]) tube([[PAD_X[i], nose_y0 + 2.3, pin_z(i) + 0.3], [0, wire_y, pad_z + pad_pocket_h/2 + 0.6]], 0.6);
    color(WIRE_COL[I_PRES]) tube([[PAD_X[I_PRES], nose_y0 + 2.3, pin_z(I_PRES) + 0.3], [PAD_X[I_GND], nose_y0 + 2.3, pin_z(I_GND) + 0.3]], 0.6);   // PRESENT pad tied to GND
    for (b=BRIDGES) color(WIRE_COL[b[0]]) tube([[PAD_X[b[0]], nose_y0 + 2.3, pin_z(b[0])], [PAD_X[b[1]], nose_y0 + 2.3, pin_z(b[1])]], 0.6);   // VBUS2/GND2 pads bridged
    // Thermostat loop: DET pad -> thermostat -> GND pad, through the pass-through and the groove.
    if (thermal_cutoff) for (k=[0, 1]) color(k == 0 ? WIRE_COL[0] : WIRE_COL[I_GND])
      tube([[PAD_X[k == 0 ? 0 : I_GND], nose_y0 + 2.3, pin_z(k == 0 ? 0 : I_GND) + 0.3], [0.6*(k*2 - 1), wire_y, pad_z + pad_pocket_h/2 + 0.6], [0.6*(k*2 - 1), wire_y, cover_t - 0.6],
            [6 + 0.5*(k*2 - 1), wire_y, cover_t - 0.6], [6 + 0.5*(k*2 - 1), therm_y + 0.5*(k*2 - 1), cover_t - 0.6], [therm_x - therm_l/2, therm_y + 0.5*(k*2 - 1), therm_floor_z + therm_t/2]], 0.6);
    // Potted pass-through, 4-core cable along the edge channel, 90-degree plug.
    color([0.85,0.6,0.15,0.55]) translate([0, wire_y, pad_z + pad_pocket_h/2]) cylinder(d=wire_pass_d - 0.1, h=cover_t - pad_z - pad_pocket_h/2, $fn=24);
    color([0.18,0.18,0.18]) tube([[0, wire_y, pad_z + pad_pocket_h/2 + 0.5], [0, wire_y, cable_z], [0, edge_y, cable_z], [bay_xc, edge_y, cable_z],
                                  [bay_xc, usb_port_y, cable_z], [bay_xc, usb_port_y, port_z - 5]], 3);
    hx = [phone_end_x + usb_side*0.2, phone_end_x + usb_side*(usb_bay_h - 0.8)];
    color([0.12,0.12,0.12,0.5]) translate([min(hx), usb_port_y - 5.5, port_z - 6]) cube([abs(hx[1] - hx[0]), 11, 9.5]);
    color(STEEL) translate([min(phone_end_x, phone_end_x - usb_side*6.5), usb_port_y - 4.2, port_z - 1.3]) cube([6.5, 8.4, 2.6]);
  }
  // The power highlight travelling along the path, with a bright head.
}

// Status LEDs on the dock's front strip (every scene): amber PWR = bike power, green DOCK = case seated.
module status_leds() {
  docked = A_case_dy <= 0.5 && A_explode < 0.5;
  for (l=[[led_x_pwr, A_bike_power ? [1.0,0.6,0.05] : [0.3,0.27,0.22]], [led_x_dock, docked && !A_hot ? [0.15,1.0,0.3] : [0.22,0.3,0.24]],
          [led_x_off, docked && A_hot ? [1.0,0.1,0.08] : [0.32,0.22,0.22]]]) {
    color(l[1]) translate([l[0], led_y, rx_front_z - 0.4]) scale([1,1,0.45]) sphere(d=led_d + 0.3, $fn=24);
    lit = max(l[1]) > 0.6;
    if (A_wiring && lit) color([l[1][0], l[1][1], l[1][2], 0.35]) translate([l[0], led_y, rx_front_z]) sphere(d=5.5, $fn=24);   // glow, x-ray scenes only
  }
}

// ---------- section cuts (cut faces show in pale blue-grey) ----------
module cut_y() {
  if (A_section == "y") intersection() { union() children(); color([0.78,0.84,0.92]) translate([-1000, A_cut, -1000]) cube(2000); }
  else children();
}
module cut_x() {
  if (A_section == "x") intersection() { union() children(); color([0.78,0.84,0.92]) translate([A_cut-2000, -1000, -1000]) cube(2000); }
  else children();
}

// ---------- scene ----------
module plate_tf() { rotate([A_tilt,0,0]) translate([0, -arm_back, arm_up + spacer_h + base_t + A_explode*0.6]) children(); }
module dock_tf() {
  translate([0, -amps_offset_y, grommet_float - rx_back_z + A_dock_lift + A_explode*1.2 + A_wobble_z])
    rotate([A_wobble, 0, 0]) children();
}

module dock_in_plate_frame() {
  dock_tf() {
    if (A_wiring) wiring_visual();      // drawn first, so the see-through parts blend over it
    cut_y() {
      status_leds();
      color(xr([0.38,0.42,0.46])) dock_receiver();
      color(xr([0.30,0.30,0.30])) dock_lid();
      color(xr([0.30,0.30,0.30])) lock_cover();
      lock_body_visual();
      if (A_section != "x") spring_pins(A_case_dy);
      translate([0, A_case_dy, A_explode*1.4]) case_assembly_visual();
    }
    // The keeper is cut on its own so its cut face keeps the keeper colour.
    if (A_section == "y") translate([0, A_case_dy, A_explode*1.4]) intersection() { keeper_part(); color(keeper_col()) translate([-1000, A_cut - 0.1, -1000]) cube(2000); }   // 0.1 mm proud of the main cut so the two faces do not z-fight
    mech_visual(A_lock);
    if (A_show_key) key_visual(A_key_in, A_lock);
  }
}

module scene() {
  cut_x() {
  if (A_show_mount) for (sx=[-1,1]) translate([sx*clamp_spacing/2, 0, 0]) rotate([A_tilt,0,0]) {
    color(hl("clamps", [0.30,0.33,0.36])) clamp_body();
    color(hl("clamps", [0.30,0.33,0.36])) translate([0,0,-A_explode*0.4]) clamp_cap();
    color([0.15,0.15,0.15]) rotate([0,90,0]) difference() {
      cylinder(d=clamp_bore_d-0.2, h=clamp_w, center=true);
      cylinder(d=bar_d, h=clamp_w+1, center=true);
    }
  }
  plate_tf() {
    if (A_show_mount && A_plate_x < 390) translate([A_plate_x,0,0]) color([0.20,0.45,0.70]) base_plate();
    if (A_smart_x < 390) translate([A_smart_x,0,0]) smart_base_visual();
    if (A_show_mount && (A_plate_x == 0 || A_smart_x == 0)) grommets_visual();
    dock_in_plate_frame();
  }
  if (A_show_bar) color([0.75,0.75,0.75]) rotate([0,90,0]) cylinder(d=bar_d, h=640, center=true);
  }
  // Lock side-cutaway: the bearing block and the bolt are cut on their own, 0.1 mm proud, so their cut faces keep their colours.
  if (A_section == "x" && A_highlight == "lock") plate_tf() dock_tf() {
    translate([0, A_case_dy, A_explode*1.4]) intersection() { color(KEEPER_HL) keeper_part(); color(KEEPER_HL) translate([A_cut + 0.1 - 2000, -1000, -1000]) cube(2000); }
    intersection() { lock_bolt(A_lock); color(HL) translate([A_cut + 0.2 - 2000, -1000, -1000]) cube(2000); }   // not coplanar with the block cut
  }
  // In the x-cutaway, draw the contacts on the cut side whole, so they stay gold.
  if (A_section == "x") plate_tf() dock_tf() {
    spring_pins(A_case_dy, A_cut);
    translate([0, A_case_dy, 0]) pads_visual(A_cut);
  }
}

if (A_case_only) case_assembly_visual();
else scene();

// Label anchors for make_video.py (dock frame): socket, PWR LED, DOCK LED, U1, U2, resistors, pins,
// then the case side: pad board, potted pass-through, edge-channel cable, 90-degree plug.
echo(label_points=[[cable_x, receiver_bottom_y, cable_z], [led_x_pwr, led_y, rx_front_z], [led_x_dock, led_y, rx_front_z],
                   u1_c + [0, 0, 1.1], u2_c + [0, 0, 1.1], [-27.0, -36.5, board_top + 0.5],
                   [PAD_X[4], pin_face_y - 4, pin_z(4)],
                   [PAD_X[1], nose_y0 + 1.2, pad_z + 1], [0, wire_y, cover_t], [40, edge_y, cable_z],
                   [phone_end_x + usb_side*usb_bay_h/2, usb_port_y, port_z + 3],
                   [therm_x, therm_y, therm_floor_z + therm_t], [led_x_off, led_y, rx_front_z], esd_c + [0, 0, 1.1]]);

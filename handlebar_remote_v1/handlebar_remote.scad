/*
  HANDLEBAR REMOTE v1: a thumb controller on the left handlebar, for the dash and for a phone (or any display that
  takes a Bluetooth keyboard or remote). OpenSCAD 2021.01. PART selects what to show or export (list below).

  Owner's choices (2026-11-24): "a left-side handlebar mount to control any digital displays"; a 5-way joystick and
  2 buttons (glove-friendly, by the thumb, without looking); wired to the dash (one of its expansion slots: power and
  the dash bus) AND Bluetooth (a phone sees it as a Bluetooth keyboard / media remote); on its own slim clamp on the
  bar, just inside the bike's left switch cube, the head reaching over the cube to the thumb.

  Built around (COMPONENTS.md; MEASURE yours: these boards have no published drawings):
    - a "5-way navigation button module" (5D rocker joystick module, about 41 x 26 mm, the joystick's stem 12 mm above
      the board). Its own SET and RST push buttons are the 2 buttons, under big caps;
    - an ESP32-C3 Super Mini (22.52 x 18 mm: Bluetooth LE, and one CAN controller for the dash bus);
    - an SN65HVD230 CAN transceiver module (as in the dash).

  How it goes together:
    1. HEAD: a rounded box. Its face has the joystick's hole and the 2 buttons' holes. Under the face, a TPU KEYPAD
       (one printed sheet: the 2 button domes come up through their holes, the joystick's stem pierces it) is glued
       round its edge to the face's underside: it seals the holes, like a phone's rubber keypad.
    2. The joystick module sits under the keypad, pressed between the face's posts and the back lid's posts.
    3. BACK LID: closes the head (a TPU gasket, 2 M2.5 screws in ears at the ends). The ESP32-C3 and the transceiver
       stick to it (foam tape, stacked); the cable comes in through an M8 cable gland in it.
    4. MOUNT: a slim bar clamp (M4 bolts up from below into inserts) with an arm up to the back lid (2 M3 screws into
       inserts in the lid's boss). The cap (the clamp's lower half) and a rubber strip inside.
    5. CAPS: a mushroom cap on the joystick's stem, over the keypad.

  Frames: the BIKE frame has the bar along x through the origin (x to the rider's right: the left bar is at -x),
  y forward, z up. The HEAD frame has its origin at the centre of the face's outer surface, x to the rider's right,
  y up the face, z out of the face (toward the thumb); the head is placed by head_pos and face_tilt.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "exploded", "head" (the housing), "back_lid", "keypad" (TPU), "lid_gasket" (TPU), "joy_cap",
// "arm_clamp", "clamp_cap"; checks "check_*" (see the end).
PART = "assembly";

// ------------------------- THE BOARDS (MEASURE: no published drawings) ----
nav_pcb = [41, 26, 1.6];    // MEASURE: the 5-way module's board (about 41 x 25-26 mm: Robu / ElectronicsComp listings)
nav_sw = [-9.5, 0];         // MEASURE: the joystick's centre on the board, from the board's centre (x along its length)
nav_body = [10, 10, 5.5];   // MEASURE: the joystick switch's body above the board
nav_top = 12;               // MEASURE: the top of its stem above the board's underside (listings: 12 mm overall)
nav_stem_d = 3.5;           // MEASURE: the stem (the cap pushes on and grips it)
set_sw = [8, 5.5];          // MEASURE: the SET button's centre (button 1), from the board's centre
rst_sw = [8, -5.5];         // MEASURE: the RST button's centre (button 2)
tact = [6, 6, 3.5];         // the 2 small tactile switches' bodies
tact_top = 6.6;             // MEASURE: their actuators' tops above the board's underside
header_x = 18.5;            // MEASURE: the header pins' row along the board's end (x), pins pointing back
mcu = [22.52, 18, 1.0];     // ESP32-C3 Super Mini (22.52 x 18: nologo.tech); MEASURE its thickness
mcu_h = 4.5;                // MEASURE: with its USB-C socket and parts
can_pcb = [26, 16, 1.6];    // MEASURE: the SN65HVD230 module
can_h = 6;                  // MEASURE: with its screw terminal / header

// ------------------------- HEAD ----------------------------------------
gap = 1.5;                  // round the joystick module's board
wall = 2.2;                 // the head's walls
face_t = 2.5;               // its face
corner_r = 6;               // the head's rounded corners (seen from the front)
edge_r = 2.0;               // the face's rounded edge
skin = 0.8;                 // the TPU keypad's sheet
stem_up = 1.0;              // the joystick's stem stands up to this far above the face (lower if the switches would reach the keypad)
below = 13.5;               // room under the module's board: header pins, wires, the 2 boards stacked
lid_t = 2.5;                // the back lid
gland_d = 8.3;              // M8 cable gland (for a 4-6 mm cable)
gland_nut = 13;             // its nut across the corners, inside the lid
ear = [8, 10];              // the lid's 2 ears (at the head's ends): length, width
ear_screw = 2.7;            // M2.5 screws (into 2 M2.5 heat-set inserts in the head's ears, 3.6 mm holes)
ear_insert_d = 3.6;
dome = [11, 10];            // the 2 button domes (TPU, through the face): width, height
dome_up = 1.6;              // they stand this far above the face
cap_d = 17;                 // the joystick's mushroom cap
cap_h = 6;
cap_travel = 14;            // the joystick tilts up to this (degrees): the face's hole leaves room

// ------------------------- MOUNT ----------------------------------------
bar_d = 22.2;               // MEASURE: the handlebar (22.2 = 7/8")
clamp_w = 12;               // the clamp's width along the bar
clamp_t = 4.5;              // its wall round the bar
clamp_rubber = 1.0;         // rubber strip inside
cube = [55, 45, 30, 22];    // MEASURE: your bike's left switch cube: width along the bar, depth (front to back),
                            //   top above the bar's centre, bottom below it (only for the fit check)
cube_gap = 2;               // the clamp sits this far inside the cube
head_pos = [-18, -32, 63];  // the face's centre in the bike frame (x: outward is -, over the cube; y: behind the bar
                            //   is -; z: above the bar's centre). SELECT: where your thumb falls
face_tilt = 50;             // the face tilts back from vertical, toward the rider's thumb (degrees)
arm_w = 10;                 // the arm's thickness (along the bar)
lid_screw = 3.2;            // the arm's 2 M3 screws into the lid's boss (M3 heat-set inserts, 4.2 mm holes)
lid_insert_d = 4.2;
lid_insert_l = 5.7;
boss_t = 7;                 // the lid's boss (takes the 2 M3 inserts)
lid_bolts = [[16, 5], [16, -5]];   // the arm's 2 screws in the lid (head-frame x, y): at the inboard end

// ------------------------- DERIVED --------------------------------------
$fn = 64;
inner = [nav_pcb[0] + 2*gap, nav_pcb[1] + 2*gap];
outer = [inner[0] + 2*wall, inner[1] + 2*wall];
// The module board's underside (head frame): the stem stem_up above the face, or lower so the joystick's body and the
// 2 buttons stay under the keypad.
z_pcb = min(stem_up - nav_top, -face_t - skin - 0.4 - nav_pcb[2] - nav_body[2], -face_t - skin - 0.3 - tact_top);
stem_top = z_pcb + nav_top;
z_pcb_top = z_pcb + nav_pcb[2];
z_skin = -face_t - skin;                    // the keypad's underside
z_back = z_pcb - below;                     // the back lid's inner face
depth = -z_back;                            // the head's housing, face to the lid's inner face
cl_r = bar_d/2 + clamp_rubber + clamp_t;
sw_hole_d = 2*(max(stem_top, 0) + face_t)*tan(cap_travel) + nav_stem_d + 6;   // the joystick's hole
echo(head = [outer[0], outer[1], depth + lid_t], z_pcb = z_pcb, joystick_hole = sw_hole_d);

// ------------------------- CHECKS ------------------------------------
assert(stem_top >= -0.5, "The joystick's stem is too short to reach its cap: check nav_top and nav_body.");

assert(below >= board_lift + can_h + 0.6 + mcu_h + 0.3, "Not enough room under the module for the two boards stacked.");
assert(max(can_pcb[1], mcu[1]) + gland_nut + 8 <= inner[0] && max(can_pcb[0], mcu[0]) <= inner[1], "The boards and the cable gland don't fit side by side on the lid.");
assert(sw_hole_d < cap_d - 3, "The joystick's cap must cover its hole.");

// ------------------------- HELPERS ------------------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center=true);
// The head's frame in the bike's frame.
HX = [1, 0, 0]; HZ = [0, -cos(face_tilt), sin(face_tilt)]; HY = [0, sin(face_tilt), cos(face_tilt)];
HEAD_M = [[HX[0], HY[0], HZ[0], head_pos[0]], [HX[1], HY[1], HZ[1], head_pos[1]], [HX[2], HY[2], HZ[2], head_pos[2]], [0, 0, 0, 1]];
module head_frame() multmatrix(HEAD_M) children();
module at_sw(p) translate([p[0], p[1], 0]) children();

// ------------------------- THE BOARDS (view only, and for the fit checks) ----
module nav_module(stem=true) {
  color([0.1, 0.25, 0.6]) translate([0, 0, z_pcb]) linear_extrude(nav_pcb[2]) square([nav_pcb[0], nav_pcb[1]], center=true);
  color([0.2, 0.2, 0.22]) translate([nav_sw[0], nav_sw[1], z_pcb_top]) linear_extrude(nav_body[2]) square([nav_body[0], nav_body[1]], center=true);
  if (stem) color([0.7, 0.7, 0.72]) translate([nav_sw[0], nav_sw[1], z_pcb_top]) cylinder(d=nav_stem_d, h=nav_top - nav_pcb[2], $fn=24);
  for (s = [set_sw, rst_sw]) {
    color([0.2, 0.2, 0.22]) translate([s[0], s[1], z_pcb_top]) linear_extrude(tact[2]) square([tact[0], tact[1]], center=true);
    color([0.15, 0.15, 0.15]) translate([s[0], s[1], z_pcb_top]) cylinder(d=3.5, h=tact_top - nav_pcb[2], $fn=20);
  }
  color([0.8, 0.65, 0.2]) translate([header_x - 1.3, -10, z_pcb - 6]) cube([2.6, 20, 6]);   // header pins (envelope)
}
// The two boards, stacked on the lid (the transceiver under the ESP32-C3, both turned across the head), between the
// cable gland (outboard end) and the module's header pins (inboard end).
gland_x = -inner[0]/2 + 1.5 + gland_nut/2;
boards_x = 4.5;
board_lift = 1.8;           // on foam tape, clear of the lid's sealing lip
module lid_boards() translate([boards_x, 0, z_back + board_lift]) rotate(90) {
  color([0.1, 0.3, 0.6]) linear_extrude(can_h) square([can_pcb[0], can_pcb[1]], center=true);
  color([0.15, 0.15, 0.17]) translate([0, 0, can_h + 0.6]) linear_extrude(mcu_h) square([mcu[0], mcu[1]], center=true);
}
back_posts = [[-(nav_pcb[0]/2 - 1.6), nav_pcb[1]/2 - 1.6], [-(nav_pcb[0]/2 - 1.6), -(nav_pcb[1]/2 - 1.6)], [15.5, 12], [15.5, -12]];

// ------------------------- HEAD ---------------------------------------
// Posts: from the face down to the module board's top (its 4 corners), and from the lid up to its underside.
post_xy = [for (sx = [-1, 1], sy = [-1, 1]) [sx*(nav_pcb[0]/2 - 1.6), sy*(nav_pcb[1]/2 - 1.6)]];
module head() difference() {
  union() {
    hull() {                                                  // the box, its face's edge rounded
      translate([0, 0, -edge_r]) linear_extrude(edge_r) offset(-edge_r + 0.01) rrect(outer, corner_r);
      for (z = [-edge_r]) translate([0, 0, z]) rotate_extrude_rrect();
      translate([0, 0, z_back]) linear_extrude(0.01) rrect(outer, corner_r);
    }
    for (sx = [-1, 1]) translate([sx*(outer[0]/2 + ear[0]/2 - 1), 0, z_back]) linear_extrude(6) rrect([ear[0] + 2, ear[1]], 3);   // the ears
  }
  // the inside
  translate([0, 0, z_back - 1]) linear_extrude(-z_back + 1 - face_t) rrect(inner, max(0.5, corner_r - wall));
  // the face's holes: the joystick (round, room to tilt), the 2 buttons' domes
  at_sw(nav_sw) translate([0, 0, -face_t - 1]) cylinder(d=sw_hole_d, h=face_t + 2);
  for (s = [set_sw, rst_sw]) at_sw(s) translate([0, 0, -face_t - 1]) linear_extrude(face_t + 2) rrect(dome + [0.6, 0.6], 2.5);
  // the ears' M2.5 inserts
  for (sx = [-1, 1]) translate([sx*(outer[0]/2 + ear[0]/2), 0, z_back - 1]) cylinder(d=ear_insert_d, h=6, $fn=24);
}
// the face's rounded edge: a rounded-rectangle "torus" (hulled with the rest)
module rotate_extrude_rrect() minkowski() { linear_extrude(0.01) offset(-edge_r) rrect(outer, corner_r); sphere(edge_r, $fn=16); }
// the face's posts onto the module's corners (inside the head)
module face_posts() for (p = post_xy) translate([p[0], p[1], z_pcb_top]) linear_extrude(-face_t - z_pcb_top + 0.01) square(3.2, center=true);
module head_full() { head(); intersection() { face_posts(); translate([0, 0, z_back]) linear_extrude(-z_back) rrect(inner, 1); } }

// ------------------------- KEYPAD (TPU) -------------------------------
// A sheet under the face, notched round the posts, with the 2 button domes (and a nub under each onto its switch);
// the joystick's stem pierces it (its hole is smaller than the stem: the TPU grips it).
module keypad() {
  difference() {
    union() {
      translate([0, 0, z_skin]) linear_extrude(skin) rrect([inner[0] - 1, inner[1] - 1], max(0.5, corner_r - wall));
      for (s = [set_sw, rst_sw]) at_sw(s) translate([0, 0, -face_t - 0.01]) linear_extrude(face_t + dome_up) offset(-0.4) rrect(dome, 2.2);   // the domes
    }
    for (p = post_xy) translate([p[0], p[1], z_skin - 1]) linear_extrude(skin + 2) square(3.8, center=true);
    at_sw(nav_sw) translate([0, 0, z_skin - 1]) cylinder(d=nav_stem_d - 0.6, h=skin + 2, $fn=24);
    for (s = [set_sw, rst_sw]) at_sw(s) translate([0, 0, z_skin - 0.01]) linear_extrude(dome_up - 1 - z_skin) offset(-1.6) rrect(dome, 1.5);   // hollow from below, 1 mm roof
  }
  for (s = [set_sw, rst_sw]) at_sw(s) translate([0, 0, z_pcb + tact_top + 0.1]) cylinder(d=3, h=dome_up - 1 - (z_pcb + tact_top + 0.1) + 0.01, $fn=20);   // a nub from the roof onto the switch
}

// ------------------------- JOYSTICK CAP -------------------------------
module joy_cap() at_sw(nav_sw) difference() {
  union() {
    intersection() {                                                                       // a low dome, its top flat (prints top down)
      translate([0, 0, 0.6]) hull() { cylinder(d=cap_d, h=1.5); translate([0, 0, cap_h - 2]) scale([1, 1, 0.35]) sphere(d=cap_d - 3, $fn=48); }
      translate([0, 0, -10]) cylinder(d=cap_d + 1, h=10 + cap_h + 0.6 - 0.6);
    }
    translate([0, 0, -face_t + 0.4]) cylinder(d=nav_stem_d + 3, h=face_t + 0.6);           // its sleeve, down through the face
  }
  translate([0, 0, -face_t]) cylinder(d=nav_stem_d - 0.15, h=face_t + stem_top - 0.3, $fn=24);   // pushes onto the stem
  for (a = [0:45:315]) rotate(a) translate([cap_d/2 - 3, 0, 1.2]) rotate([0, 90, 0]) cylinder(d=1.2, h=4, $fn=8);   // grip grooves round its rim
}

// ------------------------- BACK LID -----------------------------------
gasket_w = 1.6;
module back_lid() difference() {
  union() {
    translate([0, 0, z_back - lid_t]) linear_extrude(lid_t) rrect(outer, corner_r);
    for (sx = [-1, 1]) translate([sx*(outer[0]/2 + ear[0]/2 - 1), 0, z_back - lid_t]) linear_extrude(lid_t) rrect([ear[0] + 2, ear[1]], 3);
    translate([0, 0, z_back - 0.01]) linear_extrude(1.6) difference() { rrect(inner - [0.4, 0.4], max(0.5, corner_r - wall)); rrect(inner - [0.4 + 2*gasket_w, 0.4 + 2*gasket_w], 1); }   // the plug lip
    for (p = back_posts) translate([p[0], p[1], z_back]) linear_extrude(z_pcb - z_back) square(3.2, center=true);   // posts up to the board
    hull() for (b = lid_bolts) translate([b[0], b[1], z_back - lid_t - boss_t + 0.01]) cylinder(d=10, h=boss_t);   // the arm's boss
  }
  for (sx = [-1, 1]) translate([sx*(outer[0]/2 + ear[0]/2), 0, z_back - lid_t - 1]) cylinder(d=ear_screw, h=lid_t + 2, $fn=20);
  translate([gland_x, 0, z_back - lid_t - 1]) cylinder(d=gland_d, h=lid_t + 3);
  translate([0, 0, z_back - gasket_seat]) linear_extrude(gasket_seat + 0.01) gasket_2d(0.2);   // the gasket's groove
  for (b = lid_bolts) translate([b[0], b[1], z_back - lid_t - boss_t - 0.01]) cylinder(d=lid_insert_d, h=lid_insert_l + 0.01, $fn=24);
}
// TPU gasket ring in a groove in the lid's top, under the head's back edge: 0.8 thick in a 0.6 groove, so the 2
// screws squeeze it 0.2 mm.
gasket_seat = 0.6;
module gasket_2d(c=0) difference() { rrect(outer - [0.6 - 2*c, 0.6 - 2*c], corner_r); rrect(inner + [0.6 - 2*c, 0.6 - 2*c], max(0.5, corner_r - wall)); }
module lid_gasket() translate([0, 0, z_back - gasket_seat]) linear_extrude(0.8) gasket_2d();

// ------------------------- MOUNT --------------------------------------
// The clamp at the bar (bike frame), the arm up to the lid's boss.
module clamp_ring(upper) intersection() {
  rotate([0, 90, 0]) difference() { cylinder(r=cl_r, h=clamp_w, center=true); cylinder(d=bar_d + 2*clamp_rubber, h=clamp_w + 2, center=true); }
  translate([-clamp_w, -50, upper ? 0.4 : -50.4]) cube([2*clamp_w, 100, 50]);
}
cl_bolt_y = cl_r + 2.5;
module arm_clamp() difference() {
  union() {
    clamp_ring(true);
    translate([-clamp_w/2, -cl_r - 6, 0.4]) cube([clamp_w, 2*cl_r + 12, 8]);               // the ears (M4 inserts from below)
    hull() {                                                                                // the arm, to the lid's boss
      translate([-arm_w/2, -cl_r + 2, cl_r - 6]) cube([arm_w, 2*cl_r - 4, 6]);
      head_frame() for (b = lid_bolts) translate([b[0], b[1], z_back - lid_t - boss_t - 4]) cylinder(d=10, h=4);
    }
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=clamp_w + 2, center=true);
  for (s = [-1, 1]) translate([0, s*cl_bolt_y, -1]) cylinder(d=5.6, h=8.5, $fn=24);       // M4 inserts (8 mm), from below
  head_frame() for (b = lid_bolts) translate([b[0], b[1], z_back - lid_t - boss_t - 30]) {
    cylinder(d=lid_screw, h=40, $fn=20);                                                    // the 2 M3 screws
    cylinder(d=6, h=30 - 4 + 0.01, $fn=24);                                                // their heads' holes, from behind
  }
  head_frame() translate([0, 0, z_back - lid_t - boss_t + 0.01]) linear_extrude(60) rrect(outer + [2, 2], corner_r);   // clear of the head
}
module clamp_cap() difference() {
  union() {
    clamp_ring(false);
    translate([-clamp_w/2, -cl_r - 6, -6.4]) cube([clamp_w, 2*cl_r + 12, 6]);
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=clamp_w + 2, center=true);
  for (s = [-1, 1]) translate([0, s*cl_bolt_y, -20]) cylinder(d=4.5, h=40, $fn=24);
}
// The bike's own switch cube (for the fit check and the pictures).
cube_x = -clamp_w/2 - cube_gap;                     // the cube's inboard face (the clamp's centre is the origin)
module cube_dummy() translate([cube_x - cube[0], -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]);
module bar_dummy() rotate([0, 90, 0]) cylinder(d=bar_d, h=300, center=true);

// ------------------------- ASSEMBLY -----------------------------------
module head_parts(e=0) {
  color([0.16, 0.17, 0.19]) head_full();
  color([0.12, 0.12, 0.13]) translate([0, 0, e*0.3]) keypad();
  color([0.85, 0.45, 0.1]) translate([0, 0, e*0.8]) joy_cap();
  nav_module();
  translate([0, 0, -e]) { lid_boards(); color([0.22, 0.23, 0.26]) back_lid(); color([0.1, 0.1, 0.1]) lid_gasket(); }
}
module all_parts(e=0) {
  head_frame() head_parts(e);
  color([0.25, 0.26, 0.28]) { arm_clamp(); translate([0, 0, -e*0.6]) clamp_cap(); }
  color([0.75, 0.75, 0.75, 0.6]) bar_dummy();
  color([0.55, 0.56, 0.58, 0.45]) cube_dummy();
  color([0.08, 0.08, 0.08]) translate([cube_x - cube[0] - 130, 0, 0]) rotate([0, 90, 0]) cylinder(d=32, h=130);   // the grip
}

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") all_parts(0);
else if (PART == "exploded") all_parts(22);
else if (PART == "head") rotate([180, 0, 0]) head_full();                    // face down
else if (PART == "back_lid") translate([0, 0, -(z_back - lid_t - boss_t)]) back_lid();   // the boss down
else if (PART == "keypad") rotate([180, 0, 0]) keypad();                     // TPU, domes down
else if (PART == "lid_gasket") translate([0, 0, -(z_back - gasket_seat)]) lid_gasket();
else if (PART == "joy_cap") translate([0, 0, cap_h]) rotate([180, 0, 0]) translate([-nav_sw[0], -nav_sw[1], 0]) joy_cap();   // flat top down
else if (PART == "arm_clamp") translate([0, 0, -0.4]) arm_clamp();         // the split face on the bed
else if (PART == "clamp_cap") rotate([180, 0, 0]) clamp_cap();
// Checks: must be empty (or only touch).
else if (PART == "check_boards") {                     // the boards vs the head, the lid, the keypad, the cap (empty or touch;
  intersection() { union() { nav_module(false); lid_boards(); } union() { head_full(); back_lid(); keypad(); joy_cap(); } }
}                                                       //   the stem is a press fit in the keypad and the cap: check_stem)
else if (PART == "check_stem") intersection() { nav_module(); union() { keypad(); joy_cap(); } }   // must collide (a light grip)
else if (PART == "check_parts") {
  intersection() { head_full(); back_lid(); }
  intersection() { head_full(); keypad(); }
  intersection() { head_full(); joy_cap(); }
  intersection() { keypad(); joy_cap(); }
  intersection() { back_lid(); lid_gasket(); }
}
else if (PART == "check_gasket") intersection() { head_full(); lid_gasket(); }   // must collide: the squeeze
else if (PART == "check_clamp") intersection() { arm_clamp(); clamp_cap(); }
// The head, the arm and the clamp vs the bar, the bike's switch cube and the grip: must be empty (the clamp only
// touches the bar through its rubber).
else if (PART == "check_mount") intersection() {
  union() { head_frame() union() { head_full(); back_lid(); joy_cap(); } arm_clamp(); clamp_cap(); }
  union() { cube_dummy(); translate([cube_x - cube[0] - 130, 0, 0]) rotate([0, 90, 0]) cylinder(d=32, h=130); }
}
else if (PART == "check_arm") intersection() { arm_clamp(); head_frame() union() { head_full(); back_lid(); } }   // touches the boss only
else if (PART == "none") { }

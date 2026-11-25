/*
  HANDLEBAR REMOTE v1: a slim thumb controller on the left handlebar, between the grip and the bike's switch cube,
  for the dash and for a phone (or any display that takes a Bluetooth keyboard or remote). OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices (2026-11-24): "a left-side handlebar mount to control any digital displays": a 5-way joystick and
  2 buttons (glove-friendly, by the thumb, without looking); wired to the dash (one of its expansion slots: power and
  the dash bus) AND Bluetooth (a phone sees it as a Bluetooth keyboard / media remote). Then (2026-11-25): "I want it
  between the grips and the control panel, a slim control unit". So:
    - the CONTROL COLLAR: a slim ring round the bar (collar_w, 19 mm) in the gap between the grip and the switch cube
      (slide the switch cube inboard to make the gap: gap_w, MEASURE), with a low pod on its upper rear quarter, under
      the thumb, holding only the switches: a 5-way joystick in the middle, a button either side of it round the bar;
    - the ELECTRONICS BOX: a small sealed box with the ESP32-C3 and the CAN transceiver, anywhere near (zip-tied to the
      bar inside the switch cube, or to the frame). An 8-core cable joins them.

  Built around (COMPONENTS.md; MEASURE yours: none has a published drawing):
    - a 5-way navigation switch, 10 x 10 mm, about 7 mm tall (the one on the "5-way navigation button module": buy the
      module and take its switch off, or buy the switch), on a small piece of perfboard;
    - 2 low tactile switches, 6 x 6 x 3.5 mm;
    - an ESP32-C3 Super Mini (22.52 x 18 mm: Bluetooth LE, and one CAN controller for the dash bus);
    - an SN65HVD230 CAN transceiver module (as in the dash).

  How the collar goes together:
    1. COLLAR TOP: the upper half of the ring and the pod, open on its face. The switch board sits on its ledges.
    2. KEYPAD (TPU): one printed sheet on the pod's rim, under the face plate: it's the gasket, its 2 hollow domes
       are the buttons (a nub under each presses its switch), and it hugs the joystick cap's sleeve.
    3. FACE PLATE: screws down on the keypad (4 M2 into heat-set inserts in the pod's corners), squeezing it 0.2 mm.
    4. JOYSTICK CAP: pushes onto the switch's stem through the plate.
    5. COLLAR BOTTOM: the lower half of the ring: 2 M3 screws up into inserts in the top's ears, a 1 mm rubber strip
       inside. The cable leaves the pod's inboard side, along the bar under the switch cube's own wires.

  Frames: the BIKE frame has the bar along x through the collar's centre (x to the rider's right: the grip is at -x,
  the switch cube at +x), y forward, z up. The POD frame has its origin at the centre of the face plate's top, x along
  the bar, y round the bar (toward the top and front), z out of the face; the pod faces pod_a round the bar.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "exploded", "collar_top", "collar_bottom", "face_plate", "keypad" (TPU), "joy_cap", "box", "box_lid",
// "box_gasket" (TPU); checks "check_*" (see the end).
PART = "assembly";

// ------------------------- YOUR BIKE (MEASURE) ------------------------
bar_d = 22.2;               // MEASURE: the handlebar (22.2 = 7/8")
gap_w = 20;                 // MEASURE: the room on the bar between the grip and the switch cube (slide the cube inboard)
cube = [55, 45, 30, 22];    // MEASURE: the switch cube: width along the bar, depth, top above and bottom below the bar's
                            //   centre (only for the fit check and the pictures)
grip_d = 32;                // MEASURE: the grip's diameter (the fit check)
pod_a = 125;                // SELECT: where the pod faces, round the bar from straight forward (90 = straight up,
                            //   125 = up and back toward the thumb)

// ------------------------- THE SWITCHES (MEASURE) ----------------------
nav_sw = [10, 10, 4.0];     // MEASURE: the 5-way switch's body (width, length, height above its board)
nav_top = 7.0;              // MEASURE: its stem's top above the board's top
nav_stem_d = 3.5;           // MEASURE: the stem (the cap pushes on and grips it)
tact = [6, 6, 3.5];         // MEASURE: the 2 low tactile switches, actuator included
sw_len = 30;                // the switch board (perfboard): its length round the bar (its width follows the collar)
btn_y = 11;                 // the 2 buttons, either side of the joystick round the bar (pod-frame y)

// ------------------------- COLLAR --------------------------------------
collar_w = gap_w - 1;       // the collar's width along the bar (0.5 mm either side)
rubber = 1.0;               // rubber strip inside the ring
ring_t = 3.0;               // the ring's wall
pod_l = 41;                 // the pod's length round the bar (the corner pillars sit beyond the buttons)
pod_wall = 2.0;             // its walls
pillar = 4.2;               // its 4 corner pillars (an M2 insert in each)
plate_t = 2.0;              // the face plate
skin = 0.8;                 // the keypad's sheet (it's also the gasket)
squeeze = 0.2;              // how much the face plate squeezes it
pod_r = 3.5;                // the pod's rounded corners (seen from the face)
dome = [8, 8];              // the 2 button domes
dome_up = 1.4;              // they stand this far above the plate
cap_d = 13;                 // the joystick's cap
cap_h = 4.5;
sleeve_d = 6.5;             // its sleeve, down through the plate and the keypad onto the stem
cap_travel = 14;            // the joystick tilts up to this (degrees)
wires = 2.5;                // room under the switch board for the wires
m2_insert_d = 3.2;          // M2 heat-set inserts (4) in the pod's corners: the face plate's screws
m3_insert_d = 4.2;          // M3 heat-set inserts (2) in the collar top's ears: the collar's 2 screws
cable_d = 4.8;              // the 8-core cable (7 switches + common), out of the pod's inboard side

// ------------------------- ELECTRONICS BOX -----------------------------
mcu = [22.52, 18, 4.5];     // ESP32-C3 Super Mini (22.52 x 18: nologo.tech); MEASURE its height with its parts
can_pcb = [26, 16, 6];      // MEASURE: the SN65HVD230 module (with its header)
box_in = [44, 34, 13];      // the box's inside
box_wall = 2.0;
box_cable_d = 4.8;          // its 2 cable holes (the collar's 8-core, the dash's 4-core), sealed with silicone

// ------------------------- DERIVED --------------------------------------
$fn = 64;
ring_r = bar_d/2 + rubber + ring_t;          // the ring's outside
bore_r = bar_d/2 + rubber;
inner = [collar_w - 2*pod_wall, pod_l - 2*pod_wall];
sw_board = [min(14, inner[0] - 0.6), sw_len, 1.6];   // its corners notched for the pod's corner pillars
z_seat = -plate_t - skin + squeeze;          // the pod's rim (the keypad's seat), pod frame
z_btop = z_seat - 0.3 - nav_sw[2];           // the switch board's top: the joystick's body stays under the keypad
z_bbot = z_btop - sw_board[2];
z_floor = z_bbot - wires;                    // the pod's floor (inside)
stem_top = z_btop + nav_top;
pod_R = bore_r + 1.2 - z_floor;              // the face's distance from the bar's axis (the floor clears the rubber by 1.2)
sw_hole_d = sleeve_d + 2*(plate_t + max(stem_top, 0))*tan(cap_travel) + 0.8;
D = [0, cos(pod_a), sin(pod_a)];             // the pod's direction (bike frame)
YP = [0, sin(pod_a), -cos(pod_a)];
POD_M = [[1, 0, D[0]*0, 0], [0, YP[1], D[1], pod_R*D[1]], [0, YP[2], D[2], pod_R*D[2]], [0, 0, 0, 1]];
dome_top = z_seat + skin + plate_t - squeeze + dome_up;   // the domes' tops (pod frame)
echo(pod_height_above_ring = pod_R - ring_r, pod_R = pod_R, stem_top = stem_top, collar_w = collar_w);

// ------------------------- CHECKS ------------------------------------
assert(collar_w >= 18, "The gap is too narrow for the collar: make gap_w at least 19 mm (slide the switch cube inboard).");
// The board's corner notches (round the pillars) must stay clear of the buttons' switches and their pins (+-3.25 x +-2.25).
notch_in = [inner[0]/2 - pillar - 0.3, inner[1]/2 - pillar - 0.3];
assert(notch_in[0] >= 3.25 + 0.3 || notch_in[1] >= btn_y + 2.25 + 0.3, "The pod's corner pillars hit the buttons' switches: a wider gap, or a longer pod (pod_l).");
assert(sw_board[0] <= inner[0] - 0.4 && sw_board[1] <= inner[1] - 0.4, "The switch board doesn't fit the pod.");
assert(z_btop + tact[2] <= z_seat - 0.3, "The tactile switches are too tall for the joystick: lower ones (tact).");
assert(stem_top - 0.3 - (z_seat + 0.1) >= 2, "The joystick's stem is too short for its cap to grip it (nav_top).");
assert(btn_y + dome[1]/2 + 0.8 <= pod_l/2 - pod_wall && btn_y - dome[1]/2 - 0.6 >= sw_hole_d/2, "The buttons don't fit either side of the joystick.");
assert(cap_d < collar_w - 1, "The joystick's cap is wider than the collar.");
assert(mcu[0] + can_pcb[1] + 4 <= box_in[0] && max(mcu[1], can_pcb[0]) <= box_in[1] && max(mcu[2], can_pcb[2]) + 2 <= box_in[2], "The boards don't fit the box.");

// ------------------------- HELPERS ------------------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center=true);
module pod_frame() multmatrix(POD_M) children();
module bar_x(d, l) rotate([0, 90, 0]) cylinder(d=d, h=l, center=true);
// The half-space on the pod's side of the bar (its boundary is the plane through the axis, square to the pod).
module pod_half(s=1) multmatrix([[1, 0, 0, 0], [0, YP[1], D[1], 0], [0, YP[2], D[2], 0], [0, 0, 0, 1]])
  translate([-100, -100, s > 0 ? 0 : -200]) cube([200, 200, 200]);

// ------------------------- THE SWITCHES (view only, and for the checks) ----
module switches(stem=true) pod_frame() {
  color([0.1, 0.45, 0.2]) translate([0, 0, z_bbot]) linear_extrude(sw_board[2]) board_2d();
  color([0.2, 0.2, 0.22]) translate([0, 0, z_btop]) linear_extrude(nav_sw[2]) square([nav_sw[0], nav_sw[1]], center=true);
  if (stem) color([0.7, 0.7, 0.72]) translate([0, 0, z_btop]) cylinder(d=nav_stem_d, h=nav_top, $fn=24);
  for (s = [-1, 1]) color([0.15, 0.15, 0.16]) translate([0, s*btn_y, z_btop]) linear_extrude(tact[2]) square([tact[0], tact[1]], center=true);
}
module board_2d() difference() {
  square([sw_board[0], sw_board[1]], center=true);
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx*inner[0]/2, sy*inner[1]/2]) square(2*(pillar + 0.3), center=true);
}

// ------------------------- COLLAR -------------------------------------
pillar_xy = [for (sx = [-1, 1], sy = [-1, 1]) [sx*(inner[0]/2 - pillar/2 + 0.6), sy*(inner[1]/2 - pillar/2 + 0.6)]];
ear = [collar_w, 7, 6];      // the ring's 2 ears, at the split: along the bar, out from the ring, across the split
module ring() difference() { bar_x(2*ring_r, collar_w); bar_x(2*bore_r, collar_w + 2); }
module ears(s) multmatrix([[1, 0, 0, 0], [0, YP[1], D[1], 0], [0, YP[2], D[2], 0], [0, 0, 0, 1]])
  for (sy = [-1, 1]) translate([-ear[0]/2, sy > 0 ? ring_r - 1 : -ring_r + 1 - ear[1], s > 0 ? 0 : -ear[2]]) cube([ear[0], ear[1], ear[2]]);
ear_y = ring_r - 1 + ear[1]/2;   // the screws' distance from the axis (pod-frame y), through the ears, square to the split
// The pod's fairing: a hull from the face's rim down onto the ring, 45 degrees either side of the pod's direction.
module fairing() hull() {
  pod_frame() translate([0, 0, z_seat - 0.01]) linear_extrude(0.01) rrect([collar_w, pod_l], pod_r);
  for (s = [-1, 1]) let(f = pod_a + s*45) translate([0, (ring_r - 0.6)*cos(f), (ring_r - 0.6)*sin(f)]) bar_x(1.2, collar_w - 2);
}
module collar_top() {
  difference() {
    union() { intersection() { ring(); pod_half(1); } ears(1); fairing(); }
    bar_x(2*bore_r, collar_w + 2);
    pod_half(-1);
    pod_frame() {
      // the inside, open at the face, its 4 corner pillars left standing (an M2 insert in each)
      difference() {
        translate([0, 0, z_floor]) linear_extrude(-z_floor + 1) rrect(inner, max(0.5, pod_r - pod_wall));
        for (p = pillar_xy) translate([p[0], p[1], z_floor - 1]) linear_extrude(-z_floor + 2) square(pillar, center=true);
      }
      for (p = pillar_xy) translate([p[0], p[1], z_seat - 5]) cylinder(d=m2_insert_d, h=5.1, $fn=20);
      // the cable's hole, out of the inboard side (+x), low
      translate([inner[0]/2 - 1, 0, z_floor + cable_d/2 + 0.2]) rotate([0, 90, 0]) cylinder(d=cable_d, h=pod_wall + 2, $fn=24);
    }
    // the ears' M3 inserts (square to the split), from the split face
    multmatrix([[1, 0, 0, 0], [0, YP[1], D[1], 0], [0, YP[2], D[2], 0], [0, 0, 0, 1]])
      for (sy = [-1, 1]) translate([0, sy*ear_y, -0.01]) cylinder(d=m3_insert_d, h=ear[2] - 1, $fn=24);
  }
  // steps at the pillars' feet: the switch board's corners rest on them
  pod_frame() intersection() {
    for (p = pillar_xy) translate([p[0], p[1], z_floor - 0.01]) linear_extrude(z_bbot - z_floor + 0.01) square(pillar + 2.4, center=true);
    translate([0, 0, z_floor - 1]) linear_extrude(-z_floor) rrect(inner, max(0.5, pod_r - pod_wall));
  }
}
module collar_bottom() difference() {
  union() { intersection() { ring(); pod_half(-1); } ears(-1); }
  bar_x(2*bore_r, collar_w + 2);
  multmatrix([[1, 0, 0, 0], [0, YP[1], D[1], 0], [0, YP[2], D[2], 0], [0, 0, 0, 1]])
    for (sy = [-1, 1]) translate([0, sy*ear_y, -ear[2] - 1]) { cylinder(d=3.4, h=ear[2] + 2, $fn=20); cylinder(d=6, h=3, $fn=24); }   // M3, heads countersunk-ish
}

// ------------------------- FACE PLATE, KEYPAD, CAP --------------------
module face_plate() pod_frame() difference() {
  translate([0, 0, -plate_t]) hull() {
    linear_extrude(plate_t - 0.8) rrect([collar_w, pod_l], pod_r);
    linear_extrude(plate_t) offset(-0.8) rrect([collar_w, pod_l], pod_r);                    // a softened top edge
  }
  translate([0, 0, -plate_t - 1]) cylinder(d=sw_hole_d, h=plate_t + 2);
  for (s = [-1, 1]) translate([0, s*btn_y, -plate_t - 1]) linear_extrude(plate_t + 2) rrect(dome + [0.6, 0.6], 2);
  for (p = pillar_xy) translate([p[0], p[1], -plate_t - 1]) { cylinder(d=2.3, h=plate_t + 2, $fn=16); translate([0, 0, plate_t + 1 - 1.2]) cylinder(d1=2.3, d2=4.2, h=1.21, $fn=16); }
}
module keypad() pod_frame() {
  difference() {
    union() {
      translate([0, 0, z_seat]) linear_extrude(skin) rrect([collar_w - 0.6, pod_l - 0.6], pod_r);
      for (s = [-1, 1]) translate([0, s*btn_y, z_seat]) linear_extrude(skin + plate_t - squeeze + dome_up) offset(-0.3) rrect(dome, 1.8);   // the domes
    }
    for (p = pillar_xy) translate([p[0], p[1], z_seat - 1]) cylinder(d=2.4, h=skin + 2, $fn=16);
    translate([0, 0, z_seat - 1]) cylinder(d=sleeve_d - 0.6, h=skin + 2, $fn=32);              // hugs the cap's sleeve
    for (s = [-1, 1]) translate([0, s*btn_y, z_seat - 0.01]) linear_extrude(skin + plate_t - squeeze + dome_up - 0.8) offset(-1.3) rrect(dome, 1.2);   // hollow domes
  }
  for (s = [-1, 1]) translate([0, s*btn_y, z_btop + tact[2] + 0.1]) cylinder(d=2.6, h=(z_seat + skin + plate_t - squeeze + dome_up - 0.8) - (z_btop + tact[2] + 0.1) + 0.01, $fn=16);   // a nub onto each switch
}
module joy_cap() pod_frame() difference() {
  union() {
    translate([0, 0, 0.4]) intersection() {
      hull() { cylinder(d=cap_d, h=1.2); translate([0, 0, cap_h - 1.6]) scale([1, 1, 0.35]) sphere(d=cap_d - 2.5, $fn=48); }
      cylinder(d=cap_d + 1, h=cap_h);
    }
    translate([0, 0, z_seat + 0.1]) cylinder(d=sleeve_d, h=0.4 - z_seat - 0.1 + 0.01);
  }
  translate([0, 0, z_seat]) cylinder(d=nav_stem_d - 0.15, h=stem_top - 0.3 - z_seat, $fn=24);        // pushes onto the stem
  for (a = [0:45:315]) rotate(a) translate([cap_d/2 - 2.4, 0, 0.4 + 1.0]) rotate([0, 90, 0]) cylinder(d=1.0, h=4, $fn=8);   // grip grooves
}

// ------------------------- ELECTRONICS BOX ----------------------------
// In its own frame: the base's underside on z = 0. The 2 boards side by side; the 2 cables in at one end; 2 slots
// under the base for zip ties (to the bar inside the switch cube, or to the frame).
box_out = [box_in[0] + 2*box_wall, box_in[1] + 2*box_wall];
box_base = 3.0;              // with the zip-tie slots
module box() difference() {
  translate([0, 0, 0]) linear_extrude(box_base + box_in[2]) rrect(box_out, 4);
  translate([0, 0, box_base]) linear_extrude(box_in[2] + 1) rrect(box_in, 2);
  for (x = [-12, 12]) translate([x, 0, 1.2]) cube([5, box_out[1] + 2, 1.6], center=true);                    // zip-tie slots
  for (y = [-6, 6]) translate([-box_out[0]/2 - 1, y, box_base + box_in[2]/2]) rotate([0, 90, 0]) cylinder(d=box_cable_d, h=box_wall + 2, $fn=24);
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1), box_base + box_in[2] - 6]) cylinder(d=m2_insert_d, h=6.1, $fn=20);
}
module box_corners() for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1), box_base]) cylinder(d=6, h=box_in[2], $fn=24);
module box_full() difference() { union() { box(); intersection() { box_corners(); linear_extrude(50) rrect(box_in, 2); } }
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1), box_base + box_in[2] - 6]) cylinder(d=m2_insert_d, h=6.1, $fn=20); }
module box_lid() translate([0, 0, box_base + box_in[2] + 0.6]) difference() {
  linear_extrude(2.0) rrect(box_out, 4);
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1), -1]) cylinder(d=2.3, h=4, $fn=16);
}
// The lid's gasket: the walls' top and the 4 corner bosses (so it seals round the screws too), squeezed by the lid.
module box_gasket() translate([0, 0, box_base + box_in[2] - 0.01]) linear_extrude(0.8) difference() {
  rrect(box_out - [0.6, 0.6], 4);
  difference() { rrect(box_in + [0.6, 0.6], 2); for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1)]) circle(d=6.6, $fn=24); }
  for (sx = [-1, 1], sy = [-1, 1]) translate([sx*(box_in[0]/2 - 1), sy*(box_in[1]/2 - 1)]) circle(d=2.4, $fn=16);
}
module box_boards() {
  color([0.15, 0.15, 0.17]) translate([-box_in[0]/2 + 1 + mcu[0]/2, 0, box_base + 0.8]) linear_extrude(mcu[2]) square([mcu[0], mcu[1]], center=true);
  color([0.1, 0.3, 0.6]) translate([box_in[0]/2 - 3 - can_pcb[1]/2, 0, box_base + 0.8]) linear_extrude(can_pcb[2]) square([can_pcb[1], can_pcb[0]], center=true);
}

// ------------------------- ASSEMBLY -----------------------------------
grip_x = -collar_w/2 - (gap_w - collar_w)/2;  // the grip's inner end
cube_x = collar_w/2 + (gap_w - collar_w)/2;   // the switch cube's outboard face
module bike() {
  color([0.75, 0.75, 0.75, 0.6]) translate([-200, 0, 0]) bar_x(bar_d, 500);
  color([0.08, 0.08, 0.08]) translate([grip_x - 65, 0, 0]) bar_x(grip_d, 130);
  color([0.55, 0.56, 0.58, 0.45]) translate([cube_x, -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]);
}
module collar_parts(e=0) {
  color([0.16, 0.17, 0.19]) collar_top();
  color([0.16, 0.17, 0.19]) translate(-e*D) collar_bottom();
  switches();
  translate(e*0.4*D) color([0.1, 0.1, 0.11]) keypad();
  translate(e*0.8*D) color([0.2, 0.21, 0.23]) face_plate();
  translate(e*1.3*D) color([0.85, 0.45, 0.1]) joy_cap();
}
box_at = [cube_x + cube[0] + 25, 4, -bar_d/2 - 0.5];   // for the pictures: zip-tied under the bar, inside the switch cube
module box_parts(e=0) translate(box_at) rotate([180, 0, 0]) {
  color([0.2, 0.21, 0.23]) box_full();
  box_boards();
  translate([0, 0, e]) { color([0.1, 0.1, 0.1]) box_gasket(); color([0.22, 0.23, 0.26]) box_lid(); }
}

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") { bike(); collar_parts(0); box_parts(0); }
else if (PART == "exploded") { bike(); collar_parts(9); box_parts(10); }
else if (PART == "collar_top") rotate([0, -90, 0]) translate([collar_w/2, 0, 0]) collar_top();   // on its side: the ring prints round
else if (PART == "collar_bottom") rotate([0, -90, 0]) translate([collar_w/2, 0, 0]) collar_bottom();   // on its side
else if (PART == "face_plate") rotate([180, 0, 0]) multmatrix(invert_pod()) face_plate();   // its top on the bed
else if (PART == "keypad") translate([0, 0, dome_top]) rotate([180, 0, 0]) multmatrix(invert_pod()) keypad();   // TPU, domes down
else if (PART == "joy_cap") rotate([180, 0, 0]) translate([0, 0, -0.4 - cap_h]) multmatrix(invert_pod()) joy_cap();   // flat top down
else if (PART == "box") box_full();
else if (PART == "box_lid") translate([0, 0, -(box_base + box_in[2] + 0.6)]) box_lid();
else if (PART == "box_gasket") translate([0, 0, -(box_base + box_in[2])]) box_gasket();
// Checks: must be empty (or only touch), unless marked "must collide".
else if (PART == "check_switches") intersection() { switches(false); union() { collar_top(); keypad(); face_plate(); joy_cap(); } }
else if (PART == "check_stem") intersection() { switches(); joy_cap(); }                       // must collide: the cap's grip
else if (PART == "check_squeeze") intersection() { keypad(); face_plate(); }                  // must collide: the keypad's seal
else if (PART == "check_parts") {
  intersection() { collar_top(); collar_bottom(); }
  intersection() { collar_top(); face_plate(); }
  intersection() { collar_top(); keypad(); }
  intersection() { collar_top(); joy_cap(); }
  intersection() { face_plate(); joy_cap(); }
}
else if (PART == "check_keypad_cap") intersection() { keypad(); joy_cap(); }                 // must collide lightly: the keypad hugs the sleeve
else if (PART == "check_bike") intersection() { union() { collar_top(); collar_bottom(); face_plate(); joy_cap(); }
  union() { translate([grip_x - 65, 0, 0]) bar_x(grip_d, 130); translate([cube_x, -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]); } }
else if (PART == "check_box") intersection() { box_boards(); union() { box_full(); box_lid(); } }
else if (PART == "none") { }

// The pod frame's inverse (to lay the pod's parts flat for printing: the face plate's top on z = 0, facing up).
function invert_pod() = [[1, 0, 0, 0], [0, YP[1], YP[2], 0], [0, D[1], D[2], -pod_R], [0, 0, 0, 1]];

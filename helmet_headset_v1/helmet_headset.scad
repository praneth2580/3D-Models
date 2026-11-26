/*
  HELMET HEADSET v1: a cheap Bluetooth neckband taken apart and rebuilt as a helmet headset. OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices (2026-11-26): "using a cheap neckband and then dismantle this and use this as a helmet headset";
  designed first for a MODULAR (flip-up) helmet; the neckband is picked for the owner (boAt Rockerz 255 Pro+, the
  commonest in India; any neckband fits once its parts are measured); the board, battery and buttons go in a slim
  POD stuck to the OUTSIDE of the shell on the LEFT with VHB tape (no holes in the helmet).

  What goes where:
    - POD (outside, left, behind the chin bar's pivot): the neckband's own board (Bluetooth, amplifier, charging,
      its USB-C socket at the pod's rear end), its battery (or a flat 602030 LiPo), and a small perfboard with 3
      tactile switches wired in parallel with the board's own buttons (multi-function, volume +, volume -). A TPU
      keypad (also the seam's gasket) under a screwed lid gives a round multi-function button and a dedicated VOLUME
      ROCKER across the pod (owner, 2026-11-26: "have a dedicated volumen button", chose a rocker): press its top for
      louder, its bottom for quieter; it rocks on a small printed post glued to the switch board. Its underside is
      curved to the shell (shell_rl, shell_rw: MEASURE) and stuck on with 1.1 mm VHB tape. A TPU plug seals the USB-C.
    - SIZE: the neckband settings default to room for MOST cheap neckbands, not all (owner, 2026-11-26: "make the 3d
      pod fit most of the headsets", then "its too big ... it fine if some neckbands dont fit ... a lot smaller"):
      a board up to 50 x 12 and a battery up to 35 x 20 x 6 (300 mAh class), or a long thin one up to about 12 x 50,
      packed with foam. The board is STACKED on the battery (owner chose "stacked: short"): the pod is short (about
      60 x 37 mm) and 23 mm proud. A bigger neckband: enter its sizes and the pod grows.
    - SPEAKERS (inside): the neckband's OWN speakers (owner, 2026-11-26: "why can i use its own speaker and mic ??
      that the reason i am using it on the first place"): each earbud's 10 mm driver (boAt's spec) taken out of its
      shell and set in a printed puck that fills the liner's ear pocket. Optional upgrade: 40 mm 32 ohm helmet
      speakers fit the same puck (spk_d = 40, spk_t = 5.5): louder at speed.
    - MIC (inside): the neckband's OWN mic, on longer wires, on a bendable boom held by a thin plate between the
      shell and the liner on the left, BEHIND the chin bar, so the chin bar flips up over it and no wire crosses
      the hinge.
    - Wires from the pod: no hole in the helmet (owner, 2026-11-26: "the wires ... will be routed not using some
      hole in the helmet instead from below the helmet so have some grooves to route those wires"). They leave the
      pod through 2 notches in its bottom wall at shell level, straight into the grooves of a flexible TPU CABLE
      CHANNEL stuck to the shell from the pod down to the shell's lower edge (run_l, MEASURE), then go in under the
      edge trim.
      Then (owner, 2026-11-26: "how about the cable go on the back part and have groves too will help in water proofing
      too", choosing "out of the pod's back end"): the notches were in the pod's BACK END wall, under the USB-C, facing
      away from rain and the wind; the channel left backward and curved round and down to the edge.
      Then (owner, 2026-11-26: "as the mounting will be on the side with the long side laying horizontally on the
      helmet i feel the holes groves should open on the long side which means it will exit on the bottom side"): the
      notches are in the pod's BOTTOM long side (-y), under the neckband's board, facing DOWN (water drains away from
      them); the channel runs straight down from there to the shell's lower edge, no turn.

  Frames: the POD frame has its origin on the pod's underside at its centre, x along the pod toward the helmet's
  BACK, y up, z out of the shell. The HELMET frame (the stand-in, for pictures only) has x forward, y to the
  rider's left, z up, origin at the centre of the stand-in's shell.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// Views: "assembly" (the stand-in helmet with the pod), "pod" (the pod assembled), "exploded", "inside" (the
// stand-in cut open: speakers, boom, mic). Parts: "pod_body", "pod_lid", "keypad" (TPU), "usb_plug" (TPU),
// "rocker_post" (the volume rocker's pivot), "speaker_puck" (x2), "mic_cup", "boom_mount", "headset_assembled" (view only). Checks: "check_*" (see the end).
PART = "assembly";

// ------------------------- YOUR HELMET (MEASURE) -------------------------
// The shell's curvature where the pod goes (behind the chin bar's pivot, lower left). Measure it with a straight
// ruler: lay a length L across the shell, measure the gap h at its middle: radius = L*L/(8*h) + h/2.
shell_rl = 175;     // MEASURE: radius of the shell along the pod (front to back, level)
shell_rw = 160;     // MEASURE: radius of the shell across the pod (up and down)
vhb_t = 1.1;        // SELECT: VHB tape thickness (3M 4910 / 5952 are about 1.1 mm)
ear_d = 52;         // MEASURE: the liner's ear pocket: diameter
ear_depth = 10;     // MEASURE: ... and depth
ear_pocket = [ear_d, ear_depth];

// ------------------------- THE NECKBAND'S PARTS -------------------------
// The defaults are room for MOST cheap neckbands (estimates from common neckband and LiPo pouch sizes: no neckband
// publishes its insides); the biggest won't fit. Smaller parts are packed with foam. If yours is bigger, or to make
// the pod as small as it can be, open your neckband and enter its own sizes (MEASURE). The board lies on the battery.
nb_len = 50;             // MEASURE: the main board: length (along the USB-C); default room: 50 (the battery sets the pod's length)
nb_w = 12;               // MEASURE: ... width; default 12
nb_t = 1.0;              // MEASURE: ... PCB thickness; default 1.0
nb_pcb = [nb_len, nb_w, nb_t];
nb_under = 1.5;          // MEASURE: the tallest part under the board (it rests on the battery on a foam pad this thick)
nb_over = 2.5;           // MEASURE: the tallest part on top of the board, besides the USB-C socket
usb = [8.94, 3.26];      // the USB-C socket's shell: width, height (standard; top-mounted on the board)
usb_out = 0.5;           // MEASURE: how far the socket sticks out past the board's end
batt_l = 35;             // MEASURE: the neckband's own battery: length; default room: 35 (fits a 401230, 402030, 502030, 602030 ...)
batt_w = 20;             // MEASURE: ... width; default 20 (a cell up to 12 wide passes between the lid's posts: up to about 50 long)
batt_t = 6;              // MEASURE: ... thickness; default 6 (300 mAh cells such as 602030)
batt = [batt_l, batt_w, batt_t];

// ------------------------- CONTROLS -------------------------
tact_h = 7;              // SELECT: tactile switch height, 6 x 6 mm (7 mm: the actuator reaches up into the dome)
tact_body = 3.5;         // the switch's body height
key_x = [-9, 9];         // along the pod (front to back): the multi-function button, the volume rocker
main_d = 12;             // the multi-function button: a round dome (play/pause, calls, voice assistant, power)
rock_w = 10;             // the VOLUME ROCKER: a long key across the pod (up and down): width ...
rock_l = 20;             // ... and length. Press its top end for louder, its bottom end for quieter
rock_s = 6;              // its 2 switches sit this far above and below its middle; a post under its middle is the pivot
proud = [1.8, 1.4];      // how far each key stands above the lid (at least: taller switches raise them)
post = 3;                // the rocker's pivot post (printed, glued to the switch board): square

// ------------------------- SPEAKERS AND MIC -------------------------
spk_d = 10;              // MEASURE: the earbud's own driver: diameter (10 mm per boAt; a 40 mm helmet speaker: 40)
spk_t = 4;               // MEASURE: ... thickness (a 40 mm helmet speaker: 5.5)
spk = [spk_d, spk_t];
mic = [6, 2.7];          // MEASURE: the neckband's own mic: diameter, length (a 6 x 2.7 mm electret capsule is typical)
boom_d = 5;              // MEASURE: the boom: 2 mm aluminium wire + the mic cable in heat-shrink
cable_d = [4.2, 3.4];    // MEASURE: the 2 cables out of the pod: speakers (4-core), mic (shielded 2-core)
run_l = 90;              // MEASURE: the cable channel: from the pod's bottom (long) side to the shell's lower edge, along the shell

// ------------------------- FIXED SIZES -------------------------
wall = 2.2;      // pod wall at the seam (thicker lower down: the sides curve in toward the top)
side_in = 1.2;   // how far the sides curve in from the bottom to the seam
fl = 1.6;        // floor (at the middle; thicker toward the ends, where the shell curves away)
rc = 16;         // the pod's corner radius in plan (outside, at the bottom): nearly round ends
rr = 3.5;        // the lid's rolled edge, sideways (its height is the lid's)
kp_t = 1.0;      // keypad sheet
squeeze = 0.2;   // the keypad squeezed at the rim
lid_t = 2.2;
dome_w = 1.0;    // dome wall
hinge = 1.2;     // free sheet round each dome (the lid's hole is this much bigger all round)
pil_d = 6;       // lid screw pillars (M2 heat-set inserts, 3.2 mm hole)
usb_gap = 0.5;   // from the USB-C socket's face to the inside of the back wall
$fn = 40;

// ------------------------- DERIVED -------------------------
wall0 = wall + side_in;                       // the wall at the bottom
rc_in = rc - wall0;                           // the cavity's corner radius
pil_o = rc_in - (rc_in - 2.8) / sqrt(2);      // the pillars sit in the cavity's rounded corners
Wi = max(batt[1] + 2 * (max(cable_d) + 0.4),                          // inside width: the battery with the cables' room beside it,
         nb_pcb[1] + 2 * (pil_o + pil_d/2 + 0.35),                         // the board between the pillars,
         usb[0] + 2 * (rc_in - sqrt(pow(rc_in - 0.15, 2) - pow(rc_in - usb_gap, 2))) + 0.1,   // the USB-C socket clear of the rounded back end,
         2 * (rock_l/2 + hinge + 1 + rr + side_in + 0.1) - 2 * wall0);      // and the volume rocker on the lid's flat top
room_end = pil_o + pil_d/2 + 0.3;             // at each end: a wide battery stays between the pillars
batt_narrow = batt[1]/2 + 0.3 <= Wi/2 - pil_o - pil_d/2;   // a narrow battery passes between them: only the rounded ends limit it
batt_dy = max(0, batt[1]/2 - (Wi/2 - rc_in));
batt_end = batt_narrow ? rc_in - sqrt(pow(rc_in - 0.3, 2) - pow(batt_dy, 2)) + 0.05 : room_end;
Li = max(usb_gap + usb_out + nb_pcb[0] + 1.5, batt[0] + 2 * batt_end,   // inside length: the board (from the back wall), the battery,
         2 * (max([for (x = key_x) abs(x)]) + 3 + 0.4 + max(room_end, rc_in)));   // and the switch board under the keys
sw_l = 2 * min(Li/2 - room_end, Li/2 - rc_in) - 0.4;   // the switch perfboard's length: between the pillars, on the straight sides
L = Li + 2 * wall0;
W = Wi + 2 * wall0;
pcb_x1 = Li/2 - usb_gap - usb_out;               // the board's rear end (the USB-C end)
pcb_x0 = pcb_x1 - nb_pcb[0];
bat_x0 = -batt[0]/2;                          // the battery in the middle, on the floor
bat_x1 = batt[0]/2;
z_pcb0 = fl + batt[2] + 0.3 + nb_under;       // the board lies on the battery (on a foam pad)
z_pcb1 = z_pcb0 + nb_pcb[2];
usb_zc = z_pcb1 + usb[1]/2;
z_board = max(z_pcb1 + nb_over, z_pcb1 + usb[1]);
z_sw = z_board + 0.4;                         // the switch perfboard's underside (on ledges)
z_sw1 = z_sw + 1.6;
z_seam = z_sw1 + tact_body + 0.6;            // the body's rim = the keypad's underside
z_lid0 = z_seam + kp_t - squeeze;
z_top = z_lid0 + lid_t;
act_top = z_sw1 + tact_h;
roof_in = act_top + 0.3;                      // the domes' hollow (0.3 over the actuator)
function dome_top(i) = max(z_top + proud[i], roof_in + 0.8 + (proud[i] - min(proud)));   // taller switches: taller domes
KEY = [[key_x[0], main_d, main_d], [key_x[1], rock_w, rock_l]];   // the keys: x, size along the pod, size across it
SW = [[key_x[0], 0], [key_x[1], rock_s], [key_x[1], -rock_s]];    // the switches: multi-function, volume +, volume -
SW_KEY = [0, 1, 1];
pocket_d = [main_d - 2*dome_w, rock_w - 2*dome_w - 2];          // the hollows over the switches (the rocker's are smaller: a solid middle)
z_low = -(pow(L/2, 2)/(2*shell_rl) + pow(W/2, 2)/(2*shell_rw)) - 1;
pil = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (Li/2 - pil_o), sy * (Wi/2 - pil_o)]];
function side_d(z) = side_in * pow(max(0, z - z_low) / (z_seam - z_low), 2);   // the sides' inward curve
usb_hole = [12.6, 6.6];                       // room for a USB-C plug's moulding
cab_s = max(7, (cable_d[0] + cable_d[1])/2 + 0.4 + 2.4);   // the 2 cables' spacing
rib_n = cab_s/2 + (max(cable_d) + 0.4)/2 + 1.0;             // the ribs either side of the cable notches
rib_x = [-max(batt[0]/2 - 3, rib_n + 3), -rib_n, rib_n, max(batt[0]/2 - 3, rib_n + 3)] + [1, 1, 1, 1] * 0.137;   // the battery sits on these (off the shell's facet corners)
cab_xc = 0;                                                  // the cables leave the BOTTOM long side at its middle, beside the battery
cab_x = [cab_xc - cab_s/2, cab_xc + cab_s/2];                // speakers (toward the front), mic
usb_tab = 5;                                                 // the plug's pull tab points up
plug_x = L/2 - side_d(usb_zc - usb_hole[1]/2 - 1.2) + 0.2;   // the plug's flange: clear of the wall at its lowest point
function zb_at(x, y) = -(x*x/(2*shell_rl) + y*y/(2*shell_rw)); // the shell under the pod (near enough: a parabola)

puck_t = spk[1] + 1.5 + 1.2;                  // speaker + room for its solder tabs + back
puck_d = max(spk[0] + 4, 40);

echo(str("POD: ", L, " x ", W, " mm, ", z_top, " mm above the tape at its middle; ",
         "lid screws 4 x M2 x 6 countersunk; speaker pucks ", puck_d, " x ", puck_t, " mm"));

// ------------------------- CHECKS ON THE SETTINGS -------------------------
for (i = [0:1]) {
  assert(dome_top(i) - roof_in >= 0.8, str("key ", i + 1, ": its roof is too thin; use taller tactile switches (tact_h)"));
  assert(abs(KEY[i][0]) + KEY[i][1]/2 + hinge < L/2 - side_in - rr - 1, "the keys don't fit on the lid");
  assert(KEY[i][2]/2 + hinge < W/2 - side_in - rr - 1, "a key is too long for the lid's flat top");
}
assert(key_x[1] - key_x[0] - (main_d + rock_w)/2 - 2*hinge >= 1.6, "the keys are too close for the ridge between them");
assert(rock_s + pocket_d[1]/2 <= rock_l/2 - dome_w, "the rocker's switches are too far apart for its length");
assert(rock_s - 3 >= post/2 + 0.5, "the rocker's switches hit its pivot post");
assert(rock_s - pocket_d[1]/2 >= post/2, "the rocker's pivot post is under a switch's hollow: no solid middle to rock on");
assert(rock_s + 3 <= (Wi - 0.6)/2 - 0.5, "the rocker's switches are off the switch board");
assert(sw_l/2 < Li/2 - pil_o - pil_d/2 - 0.3, "the switch board hits the lid's pillars");
assert(sw_l/2 <= Li/2 - rc_in, "the switch board's corners are in the cavity's rounded ends");
assert(Wi/2 - pil_o - pil_d/2 >= nb_pcb[1]/2 + 0.3, "the lid's pillars hit the neckband's board");
assert(max([for (p = SW) abs(p[0])]) + 3 < sw_l/2, "a switch is off the end of the switch board");
assert(z_sw1 + tact_body < z_seam, "the switches' bodies hit the keypad");
assert(act_top >= z_seam + 0.8, "the tactile switches are too short to reach up into the domes (tact_h)");
assert(batt_narrow || bat_x1 <= Li/2 - room_end + 0.01, "the battery runs into the pillars");
assert(norm([max(0, bat_x1 - (Li/2 - rc_in)), max(0, batt[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the battery's corners hit the pod's rounded ends");
assert(norm([max(0, -pcb_x0 - (Li/2 - rc_in)), max(0, nb_pcb[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the board's corners hit the pod's rounded front end");
assert(norm([max(0, pcb_x1 + usb_out - (Li/2 - rc_in)), max(0, usb[0]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.15, "the USB-C socket's corners hit the pod's rounded back end");
assert(norm([max(0, pcb_x1 - (Li/2 - rc_in)), max(0, nb_pcb[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the board's corners hit the pod's rounded back end");
assert(puck_t <= ear_pocket[1] + 0.01, str("the speaker puck (", puck_t, " mm) is deeper than the ear pocket"));
assert(puck_d <= ear_pocket[0], "the speaker puck is wider than the ear pocket");
assert(shell_rl >= 90 && shell_rw >= 90, "shell radius too small for this pod: measure again");

// ------------------------- HELPERS -------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center = true);
module pod_2d(d = 0) offset(r = -d) rrect([L, W], rc);      // the pod's outline, d inward
module slab(z, d) translate([0, 0, z]) linear_extrude(0.01) pod_2d(d);
module shell_cut(up = 0)                     // the shell (grown by the tape): the pod's underside follows it
  translate([0, 0, up - shell_rw]) scale([sqrt(shell_rl * shell_rw), shell_rw, shell_rw]) sphere(1, $fn = 240);

// ------------------------- THE POD -------------------------
module body_outer() hull() for (i = [0:6]) let(z = z_low + (z_seam - z_low) * i/6) slab(z - (i == 6 ? 0.01 : 0), side_d(z));

module ledges()                               // the switch board rests on these (chamfered under, so they print)
  for (s = [-1, 1]) hull() {
    translate([-sw_l/2 - 2, s > 0 ? Wi/2 - 1.6 : -Wi/2 - 0.5, z_sw - 0.01]) cube([sw_l + 4, 2.1, 0.01]);
    translate([-sw_l/2 - 2, s > 0 ? Wi/2 : -Wi/2 - 0.5, z_sw - 1.6]) cube([sw_l + 4, 0.5, 0.01]);
  }

module pod_body() difference() {
  union() {
    difference() {
      body_outer();
      translate([0, 0, fl]) linear_extrude(z_seam) pod_2d(wall0);
      difference() {                                         // below that, the floor follows the shell (fl - 0.25 thick)
        translate([0, 0, z_low - 1]) linear_extrude(fl - z_low + 1.01) pod_2d(wall0);
        shell_cut(fl - 0.25);                                // (not fl: tangent to the flat floor, non-manifold)
      }
    }
    intersection() {
      union() {
        for (p = pil) translate([p[0], p[1], z_low - 1]) cylinder(d = pil_d, h = z_seam - z_low + 1);
        ledges();
        for (x = rib_x) translate([x - 0.6, -Wi/2 - 1, z_low - 1]) cube([1.2, Wi + 2, fl - z_low + 1]);   // the battery and board sit on these
      }
      body_outer();
    }
  }
  shell_cut();
  for (p = pil) translate([p[0], p[1], z_seam - 4.5]) cylinder(d = 3.2, h = 5);    // M2 inserts
  translate([Li/2 - 0.5, 0, usb_zc]) rotate([0, 90, 0]) linear_extrude(wall0 + 2)    // USB-C plug
    rotate(90) rrect(usb_hole, 2.5);
  for (i = [0:1]) let(c = cable_d[i] + 0.4, zb = zb_at(cab_x[i], W/2))
    hull() for (z = [zb - 3, zb + c/2])                       // cables: notches at shell level in the bottom side, facing down, into the channel
      translate([cab_x[i], -Wi/2 + 2.5, z]) rotate([90, 0, 0]) cylinder(d = c, h = wall0 + 4);   // (from 2.5 inside: through the curved floor)
}

module pod_lid() difference() {
  union() {
    hull() for (i = [0:8]) let(a = 90 * i/8)                 // a quarter-ellipse roll from the seam to the top
      slab(z_lid0 + lid_t * sin(a) - (i == 8 ? 0.01 : 0), side_in + rr * (1 - cos(a)));
    hull() for (s = [-1, 1])                                  // a ridge between the keys (to find them with gloves)
      translate([(key_x[0] + main_d/2 + key_x[1] - rock_w/2)/2, s * 6, z_top - 0.2]) sphere(r = 0.9, $fn = 16);
  }
  translate([0, 0, z_lid0 - 0.01]) linear_extrude(squeeze + 0.1) pod_2d(wall0 + 0.6);  // squeeze only at the rim
  for (i = [0:1]) translate([KEY[i][0], 0, z_lid0 - 1]) linear_extrude(lid_t + 3) offset(r = hinge) key_2d(i);
  for (p = pil) translate([p[0], p[1], z_lid0 - 1]) {
    cylinder(d = 2.3, h = lid_t + 3);
    translate([0, 0, 1 + lid_t - 1.1]) cylinder(d1 = 1.9, d2 = 4.1, h = 1.11);       // M2 countersunk
  }
}

function key_ends(i) = let(d = KEY[i][1], e = (KEY[i][2] - d)/2) [[0, -e], [0, e]];   // a round key: both ends at the middle
module key_2d(i) hull() for (p = key_ends(i)) translate(p) circle(d = KEY[i][1], $fn = 48);
module dome(i) hull() {                                       // a key: round (the multi-function) or a long pill (the rocker)
  linear_extrude(dome_top(i) - z_seam - 1) key_2d(i);
  for (p = key_ends(i)) translate([p[0], p[1], dome_top(i) - z_seam - 1])
    rotate_extrude($fn = 48) translate([KEY[i][1]/2 - 1, 0]) circle(1, $fn = 16);
}
module rocker_marks()                                         // raised + (top end) and - (bottom end), to feel with gloves
  translate([key_x[1], 0, dome_top(1) - 0.01]) linear_extrude(0.6) {
    translate([0, rock_s]) { square([5, 1.2], center = true); square([1.2, 5], center = true); }
    translate([0, -rock_s]) square([5, 1.2], center = true);
  }

module keypad() difference() {                               // TPU: the keys and the seam's gasket
  union() {
    translate([0, 0, z_seam]) linear_extrude(kp_t) pod_2d(side_in + 0.4);
    for (i = [0:1]) translate([KEY[i][0], 0, z_seam]) dome(i);
    rocker_marks();
  }
  for (j = [0:2]) translate([SW[j][0], SW[j][1], z_seam - 0.01])           // the hollows: an actuator reaches up into each
    cylinder(d = pocket_d[SW_KEY[j]], h = roof_in - z_seam + 0.01, $fn = 40);
  for (i = [0:1]) translate([KEY[i][0], 0, z_seam - 0.01]) linear_extrude(0.42) difference() {   // thin hinge round each key
    offset(r = hinge) key_2d(i); key_2d(i);
  }
  for (p = pil) translate([p[0], p[1], z_seam - 1]) cylinder(d = 2.6, h = 3);
}

module post_shape() linear_extrude(tact_body + 0.6) rrect([post, post], 0.8);   // = z_seam - z_sw1
module rocker_post() translate([key_x[1], 0, z_sw1]) post_shape();   // PETG: glued to the switch board under the rocker's
                                                                     // solid middle (its top touches the rocker: the pivot)

module usb_plug() {                                          // TPU: seals the USB-C socket
  xo = plug_x;
  translate([0, 0, usb_zc]) {
    translate([Li/2 - usb_gap - 3, 0, 0]) rotate([0, 90, 0]) linear_extrude(3.01) rotate(90) rrect([8.2, 2.3], 1.1);
    translate([Li/2 - usb_gap, 0, 0]) rotate([0, 90, 0]) linear_extrude(xo - Li/2 + usb_gap) rotate(90) rrect(usb_hole - [0.3, 0.3], 2.35);
    translate([xo, 0, 0]) rotate([0, 90, 0]) linear_extrude(1.2) rotate(90) rrect([usb_hole[0] + 3, usb_hole[1] + 2.4], 3.5);
    translate([xo, 0, 0]) hull() for (dz = [0, usb_tab]) translate([0, 0, dz + usb_hole[1]/2 + 1.2]) rotate([0, 90, 0]) cylinder(d = 3, h = 1.2);
  }
}

// The neckband's parts and the switch board (for the views and the checks)
module board() {
  color("#1f6f3a") translate([pcb_x0, -nb_pcb[1]/2, z_pcb0]) cube(nb_pcb);
  color("#2a2a2a") translate([pcb_x0 + 2, -nb_pcb[1]/2 + 1, z_pcb1]) cube([nb_pcb[0] - 14, nb_pcb[1] - 2, nb_over]);
  color("#2a2a2a") translate([pcb_x0 + 3, -nb_pcb[1]/2 + 1.5, z_pcb0 - nb_under]) cube([nb_pcb[0] - 16, nb_pcb[1] - 3, nb_under]);
  color("#c8c8c8") translate([pcb_x1 + usb_out - 7.4, 0, usb_zc]) rotate([0, 90, 0]) linear_extrude(7.4) rotate(90) rrect(usb, usb[1]/2 - 0.01);
}
module battery() color("#3d5f9e") translate([bat_x0, -batt[1]/2, fl]) cube(batt);
module switches(pressed = 0) {
  color("#c9a36b") translate([-sw_l/2, -(Wi - 0.6)/2, z_sw]) cube([sw_l, Wi - 0.6, 1.6]);
  for (p = SW) translate([p[0], p[1], z_sw1]) {
    color("#222") translate([-3, -3, 0]) cube([6, 6, tact_body]);
    color("#444") cylinder(d = 3.5, h = tact_h + pressed);
  }
}
module insides() { board(); battery(); switches(); color("#5a6068") rocker_post(); }

// ------------------------- CABLE CHANNEL (TPU) -------------------------
// Its cross-section: u across it, w out of the shell. Its 2 grooves are open toward the shell: the cables lie in them,
// held against the shell. Modelled flat in the POD frame (as printed): straight down (-y) from the pod's bottom side
// for run_l. Flexible TPU, so it bends to follow the shell.
ch_u = [-cab_s/2, cab_s/2];                                   // the grooves line up with the pod's notches (x = cab_xc + u)
ch_c = [for (d = cable_d) d + 0.4];
ch_u0 = ch_u[0] - ch_c[0]/2 - 1.2;
ch_u1 = ch_u[1] + ch_c[1]/2 - (-1.2);
ch_h = max(ch_c) + 1.0;
ch_wing = 4;                                                  // thin flanges either side, for the tape
ch_taper = 8;                                                 // the lower end slopes down to the flanges
ch_in = 3;                                                    // starts this far inside the pod's side (cut to its outline)
assert(ch_u[1] - ch_c[1]/2 - (ch_u[0] + ch_c[0]/2) >= 1.2, "the cables are too thick for the pod's notches' spacing");
assert(cab_xc + ch_u1 + ch_wing <= Li/2 - rc_in && cab_xc + ch_u0 - ch_wing >= -(Li/2 - rc_in), "the cable channel is wider than the pod's straight side");
assert(Wi/2 - 2.5 >= batt[1]/2, "the cable notches run into the battery's place");
assert(run_l > ch_taper + 2, "the cable channel is too short");
module run_dome_2d() hull() {
  translate([ch_u0, 0]) square([ch_u1 - ch_u0, 0.01]);
  for (u = [ch_u0 + 2.5, ch_u1 - 2.5]) translate([u, ch_h - 2.5]) circle(2.5, $fn = 24);
}
module run_wing_2d() translate([ch_u0 - ch_wing, 0]) square([ch_u1 - ch_u0 + 2*ch_wing, 0.8]);
module run_grooves_2d() for (i = [0:1]) hull() {
  translate([ch_u[i] - ch_c[i]/2, -0.01]) square([ch_c[i], 0.01]);
  translate([ch_u[i], ch_c[i]/2]) circle(d = ch_c[i], $fn = 24);
}
module run_2d() difference() { union() { run_dome_2d(); run_wing_2d(); } run_grooves_2d(); }
M_A = [[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]];                         // (u, w, e) -> (e, u, w): along +x
M_C = [[1, 0, 0, cab_xc], [0, 0, -1, -W/2 + ch_in], [0, 1, 0, 0], [0, 0, 0, 1]];       // (u, w, e) -> down (-y) from the pod's side
module cable_channel() difference() {                         // flat, in the pod frame, as printed (flanges on the bed)
  multmatrix(M_C) intersection() {
    linear_extrude(ch_in + run_l) run_2d();
    hull() {                                                  // the lower end slopes down to the flanges
      translate([ch_u0 - ch_wing - 1, -1, -1]) cube([ch_u1 - ch_u0 + 2*ch_wing + 2, ch_h + 2, ch_in + run_l - ch_taper + 1]);
      translate([ch_u0 - ch_wing - 1, -1, ch_in + run_l]) cube([ch_u1 - ch_u0 + 2*ch_wing + 2, 2.2, 0.01]);   // (not 1.8: coplanar with the flanges)
    }
  }
  translate([0, 0, -1]) linear_extrude(ch_h + 2) offset(r = 0.3) pod_2d(0);   // its top end fits against the pod's side
}

module half_x() render() intersection() { children(); translate([key_x[1], -60, -30]) cube([200, 120, 80]); }
C_POD = "#454a52"; C_TPU = "#1a1a1a"; C_HELMET = "#e9e9e6"; C_EPS = "#bdbdb5";
module pod_assembled(ex = 0) {
  color(C_POD) pod_body();
  color(C_TPU) translate([0, 0, 2.4*ex]) keypad();
  color(C_POD) translate([0, 0, 5*ex]) pod_lid();
  color(C_TPU) translate([1.5*ex, 0, 0]) usb_plug();
}

// ------------------------- SPEAKER PUCK, MIC, BOOM MOUNT -------------------------
module speaker_puck() difference() {                         // the speaker drops in from the front (printed front down)
  rotate_extrude($fn = 96) hull() {
    square([0.01, puck_t]);
    translate([puck_d/2 - 1.2, 1.2]) circle(1.2, $fn = 20);
    translate([puck_d/2 - 0.8, puck_t - 0.8]) circle(0.8, $fn = 20);
  }
  translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0] + 0.3, h = spk[1] + 1, $fn = 96);
  translate([0, 0, 1.2]) cylinder(d = max(spk[0] - 4, 8), h = puck_t, $fn = 96);     // behind the speaker: its tabs
  translate([0, 0, 1.2 + 0.75]) rotate([0, 90, 0]) cylinder(d = 2.4, h = puck_d);    // the wires out
  if (puck_d - spk[0] > 12)                                   // a small speaker: hollow the back round it (the rim and the hub take the Velcro)
    translate([0, 0, -0.01]) difference() {
      cylinder(d = puck_d - 3.2, h = puck_t - 1.2 + 0.01, $fn = 96);
      cylinder(d = spk[0] + 4, h = puck_t, $fn = 64);
    }
}

module mic_cup() difference() {                              // back on the bed: the boom in the back, the capsule in the front
  h = 3.5 + 1 + mic[1] + 0.3;
  hull() {
    translate([0, 0, 1]) cylinder(d = max(boom_d, mic[0]) + 3, h = h - 2);
    cylinder(d = max(boom_d, mic[0]) + 1, h = h);
  }
  translate([0, 0, -0.01]) cylinder(d = boom_d + 0.2, h = 3.5);
  cylinder(d = 2, h = h);
  translate([0, 0, h - mic[1] - 0.3]) cylinder(d = mic[0] + 0.15, h = mic[1] + 1);
}

bm_plate = [30, 34, 1.6];                                     // between the shell and the liner: x forward, y up
module boom_mount() difference() {
  union() {
    translate([-bm_plate[0]/2, -bm_plate[1]/2, 0]) linear_extrude(bm_plate[2]) rrect2([bm_plate[0], bm_plate[1]], 4);
    hull() {                                                  // the boom's socket, on the plate's inner side
      translate([bm_plate[0]/2 - 14, -6, 0]) cube([14, 12, 0.01]);
      translate([bm_plate[0]/2 - 12, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = boom_d + 4, h = 12);
    }
  }
  translate([bm_plate[0]/2 - 11, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = boom_d, h = 20);   // a tight push fit
  translate([bm_plate[0]/2 - 20, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = 3, h = 20);       // the mic cable comes in behind
}
module rrect2(s, r) translate([r, r]) offset(r) square([s[0] - 2*r, s[1] - 2*r]);

// ------------------------- THE STAND-IN HELMET (pictures only) -------------------------
H = [150, 125, 140];         // its shell's dome: semi-axes, x forward, y left, z up
CHIN = [[40, 0, -55], [110, 100, 62]];   // the chin bar's bulge: centre, semi-axes
function h_low(x) = -92 - 0.12 * x;      // its lower edge (lower at the chin)
pod_at = [-52, -8];          // the pod's centre on it: x, z (behind the chin bar's pivot)
pivot = [28, -22];
function unit(v) = v / norm(v);
function on_shell(x, z, a = H) = [x, a[1] * sqrt(1 - pow(x/a[0], 2) - pow(z/a[2], 2)), z];
function normal_at(p, a = H) = unit([p[0]/(a[0]*a[0]), p[1]/(a[1]*a[1]), p[2]/(a[2]*a[2])]);
function frame(p, n, fwd) = let(xa = unit(fwd - (fwd * n) * n), ya = cross(n, xa))
  [[xa[0], ya[0], n[0], p[0]], [xa[1], ya[1], n[1], p[1]], [xa[2], ya[2], n[2], p[2]], [0, 0, 0, 1]];
POD_P = on_shell(pod_at[0], pod_at[1]);
POD_N = normal_at(POD_P);
POD_M = frame(POD_P + vhb_t * POD_N, POD_N, [-1, 0, 0]);      // pod x toward the helmet's back

EPS_t = 25; SH_t = 4;
EAR = [0, 0, -22];
EAR_P = on_shell(EAR[0], EAR[2], H - [SH_t + EPS_t, SH_t + EPS_t, SH_t + EPS_t]);
BM_P = on_shell(18, -78, H - [SH_t, SH_t, SH_t]);              // the boom mount, inside the shell's lower left edge
BM_M = frame(BM_P, -normal_at(BM_P, H - [SH_t, SH_t, SH_t]), [1, 0, 0]);
MIC_P = [104, 14, -76];                                       // in front of the mouth, inside the chin bar

module ellipsoid(a) scale(a) sphere(1, $fn = 160);
// The channel on the stand-in: its centre line (pod frame), each point pushed out radially onto the stand-in's shell.
CH_2D = [for (d = [-2:6:200]) [cab_xc, -W/2 - d]];
function to_shell(p) = let(q = POD_M * [p[0], p[1], 0, 1], k = sqrt(pow(q[0]/H[0], 2) + pow(q[1]/H[1], 2) + pow(q[2]/H[2], 2)))
  [q[0], q[1], q[2]] / k;
CH_ALL = [for (p = CH_2D) to_shell(p)];
CH_P = [for (q = CH_ALL) if (q[2] > h_low(q[0]) + 1.5) q];
module run_slab(i, part) let(t = CH_P[min(i + 1, len(CH_P) - 1)] - CH_P[max(i - 1, 0)])
  multmatrix(frame(CH_P[i], normal_at(CH_P[i]), t)) multmatrix(M_A) linear_extrude(0.01, center = true)
    if (part == 0) run_dome_2d(); else run_wing_2d();
module channel_on_helmet() color(C_TPU) for (i = [0:len(CH_P) - 2], part = [0, 1]) hull() { run_slab(i, part); run_slab(i + 1, part); }
module helmet_solid(t = 0) hull() {
  ellipsoid(H - [t, t, t]);
  translate(CHIN[0]) ellipsoid(CHIN[1] - [t, t, t]);
}
module helmet_shell(cutaway = false) color(C_HELMET) difference() {
  helmet_solid();
  helmet_solid(SH_t);
  translate([0, 0, h_low(0)]) rotate([0, -atan(0.12), 0]) translate([-400, -400, -800]) cube(800);
  translate([60, 0, -8]) rotate([0, 90, 0]) linear_extrude(200) scale([1, 1.25]) rrect([56, 120], 22);   // eye port
  if (cutaway) translate([-300, -600, -300]) cube(600);
}
module helmet_details() {
  color("#2b3440", 0.85) intersection() {                     // visor
    difference() { ellipsoid(H + [2, 2, 2]); ellipsoid(H - [2, 2, 2]); }
    translate([60, 0, -8]) rotate([0, 90, 0]) linear_extrude(200) scale([1, 1.25]) rrect([62, 126], 25);
  }
  for (s = [-1, 1]) let(p = on_shell(pivot[0], pivot[1]), n = normal_at(p))   // the chin bar's pivots
    color("#9a9a9a") multmatrix(frame(p, s > 0 ? n : [n[0], -n[1], n[2]], [1, 0, 0]))
      translate([0, 0, -1]) cylinder(d = 30, h = 4, $fn = 48);
}
module liner(cutaway = false) color(C_EPS) difference() {
  ellipsoid(H - [SH_t, SH_t, SH_t] - [0.5, 0.5, 0.5]);
  ellipsoid(H - [SH_t + EPS_t, SH_t + EPS_t, SH_t + EPS_t]);
  translate([-300, -300, -60 - 600]) cube(600);
  translate([40, -300, -300]) cube(600);
  if (cutaway) translate([-300, -600, -300]) cube(600);
  for (s = [-1, 1]) ear_pocket_at(s);
}
module ear_pocket_at(s) let(p = [EAR_P[0], s * EAR_P[1], EAR_P[2]])
  translate(p) rotate([-s * 90, 0, 0]) translate([0, 0, -1]) cylinder(d = ear_pocket[0], h = ear_pocket[1] + 1, $fn = 64);
module speakers(both = true) for (s = both ? [-1, 1] : [1]) let(p = [EAR_P[0], s * EAR_P[1], EAR_P[2]])
  translate(p) rotate([s * 90, 0, 0]) translate([0, 0, -puck_t]) {
    color("#30343a") speaker_puck();
    color("#8a8f96") translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0], h = spk[1] - 0.3, $fn = 64);
  }
BOOM0 = BM_M * [bm_plate[0]/2, 0, bm_plate[2] + boom_d/2 + 1.5, 1];
BOOM = [[BOOM0[0], BOOM0[1], BOOM0[2]], [BOOM0[0] + 30, BOOM0[1] - 6, BOOM0[2] + 1], [72, 64, -79], [94, 32, -76], MIC_P];
module boom_mic() {
  color("#30343a") multmatrix(BM_M) boom_mount();
  color("#222") for (i = [0:len(BOOM) - 2]) hull() { translate(BOOM[i]) sphere(d = boom_d, $fn = 16); translate(BOOM[i+1]) sphere(d = boom_d, $fn = 16); }
  let(d = unit(MIC_P - BOOM[len(BOOM) - 2]))
    translate(MIC_P) rotate([0, 0, atan2(d[1], d[0])]) rotate([0, 90 - asin(d[2]), 0]) {
      color("#30343a") translate([0, 0, -2]) mic_cup();
      color("#555") translate([0, 0, 6]) sphere(d = 13, $fn = 24);       // foam windscreen
    }
}

// ------------------------- OUTPUT -------------------------
if (PART == "assembly") { helmet_shell(); helmet_details(); multmatrix(POD_M) pod_assembled(); channel_on_helmet(); }
else if (PART == "channel_part") color("#5a6068") rotate([0, 180, 0]) translate([-cab_xc, W/2, 0]) render() cable_channel();   // view: the channel turned over, its grooves up
else if (PART == "pod") pod_assembled();
else if (PART == "rocker_section") {                                                 // view: cut through the volume rocker
  color(C_POD) half_x() pod_body(); color(C_TPU) half_x() keypad(); color(C_POD) half_x() pod_lid();
  color("#c9a36b") half_x() translate([-sw_l/2, -(Wi - 0.6)/2, z_sw]) cube([sw_l, Wi - 0.6, 1.6]);
  color("#222") half_x() for (p = SW) translate([p[0] - 3, p[1] - 3, z_sw1]) cube([6, 6, tact_body]);
  color("#999") half_x() for (p = SW) translate([p[0], p[1], z_sw1]) cylinder(d = 3.5, h = tact_h);
  color("#5a8fd0") half_x() rocker_post(); color("#1f6f3a") half_x() board(); color("#3d5f9e") half_x() battery();
}
else if (PART == "pod_cables") { pod_assembled(); color(C_TPU) translate([0, -12, 0]) render() cable_channel(); }   // view: the bottom side, the channel pulled away
else if (PART == "exploded") { pod_assembled(5); translate([0, 0, 6]) insides(); }
else if (PART == "inside") { helmet_shell(true); liner(true); speakers(false); boom_mic(); multmatrix(POD_M) pod_assembled(); }
else if (PART == "headset_assembled") { pod_body(); translate([0, 0, -0.02]) keypad(); pod_lid(); usb_plug(); }   // view only (merged)
else if (PART == "small_parts") {                                                     // view: the parts inside the helmet
  color("#30343a") speaker_puck();
  color("#8a8f96") translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0], h = spk[1] - 0.3, $fn = 64);
  color("#30343a") translate([45, 0, 0]) boom_mount();
  color("#30343a") translate([45, 30, 0]) mic_cup();
}
else if (PART == "pod_body") rotate([180, 0, 0]) translate([0, 0, -z_seam]) pod_body();     // open side down
else if (PART == "pod_lid") translate([0, 0, -z_lid0]) pod_lid();
else if (PART == "keypad") translate([0, 0, -z_seam]) keypad();
else if (PART == "rocker_post") post_shape();
else if (PART == "usb_plug") rotate([0, -90, 0]) translate([-plug_x - 1.2, 0, -usb_zc]) usb_plug();                        // flange down
else if (PART == "speaker_puck") translate([0, 0, puck_t]) rotate([180, 0, 0]) speaker_puck();   // front down
else if (PART == "mic_cup") mic_cup();
else if (PART == "boom_mount") boom_mount();
else if (PART == "cable_channel") translate([-cab_xc, W/2, 0]) cable_channel();                     // TPU, flanges down
// checks
else if (PART == "check_insides") intersection() { insides(); union() { pod_body(); pod_lid(); keypad(); } }   // touch only (the switch board on its ledges)
else if (PART == "check_parts") intersection() { pod_body(); pod_lid(); }                    // empty
else if (PART == "check_plug") intersection() { usb_plug(); pod_body(); }                  // empty
else if (PART == "check_squeeze") intersection() { keypad(); pod_lid(); }                   // must collide: the seal
else if (PART == "check_press") intersection() { switches(0.5); keypad(); }                 // must collide: a press reaches the switch
else if (PART == "check_pivot") intersection() { translate([0, 0, 0.05]) rocker_post(); keypad(); }   // must collide: the post touches the rocker
else if (PART == "check_rest") intersection() { switches(0); keypad(); }                    // empty: the switches aren't held down
else if (PART == "check_shell") intersection() { pod_body(); shell_cut(-vhb_t); }           // empty: the tape's room
else if (PART == "check_notches") intersection() {                                          // empty: the cables pass the pod's notches
  for (i = [0:1]) let(zb = zb_at(cab_x[i], W/2))
    translate([cab_x[i], -Wi/2 + 2, zb + cable_d[i]/2 + 0.2]) rotate([90, 0, 0]) cylinder(d = cable_d[i], h = wall0 + 4);
  pod_body();
}
else if (PART == "none") { }

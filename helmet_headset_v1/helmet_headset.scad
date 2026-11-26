/*
  HELMET HEADSET v1: a cheap Bluetooth neckband taken apart and rebuilt as a helmet headset. OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices (2026-11-26): "using a cheap neckband and then dismantle this and use this as a helmet headset";
  designed first for a MODULAR (flip-up) helmet; the neckband is picked for the owner (boAt Rockerz 255 Pro+, the
  commonest in India; any neckband fits once its parts are measured); the board, battery and buttons go in a slim
  POD stuck to the OUTSIDE of the shell on the LEFT with VHB tape (no holes in the helmet).

  What goes where:
    - POD (outside, left, behind the chin bar's pivot): the neckband's own board (Bluetooth, amplifier, charging,
      its USB-C socket at the pod's rear end), its battery (or a flat 502540 LiPo), and a small perfboard with 3 big
      tactile switches wired in parallel with the board's own buttons (volume +, multi-function, volume -). A TPU
      keypad (also the seam's gasket) under a screwed lid gives 3 glove-friendly domes. Its underside is curved to
      the shell (shell_rl, shell_rw: MEASURE) and stuck on with 1.1 mm VHB tape. A TPU plug seals the USB-C.
    - SPEAKERS (inside): the neckband's OWN speakers (owner, 2026-11-26: "why can i use its own speaker and mic ??
      that the reason i am using it on the first place"): each earbud's 10 mm driver (boAt's spec) taken out of its
      shell and set in a printed puck that fills the liner's ear pocket. Optional upgrade: 40 mm 32 ohm helmet
      speakers fit the same puck (spk_d = 40, spk_t = 5.5): louder at speed.
    - MIC (inside): the neckband's OWN mic, on longer wires, on a bendable boom held by a thin plate between the
      shell and the liner on the left, BEHIND the chin bar, so the chin bar flips up over it and no wire crosses
      the hinge.
    - Wires from the pod run down outside the shell and in under the shell's edge trim.

  Frames: the POD frame has its origin on the pod's underside at its centre, x along the pod toward the helmet's
  BACK, y up, z out of the shell. The HELMET frame (the stand-in, for pictures only) has x forward, y to the
  rider's left, z up, origin at the centre of the stand-in's shell.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// Views: "assembly" (the stand-in helmet with the pod), "pod" (the pod assembled), "exploded", "inside" (the
// stand-in cut open: speakers, boom, mic). Parts: "pod_body", "pod_lid", "keypad" (TPU), "usb_plug" (TPU),
// "speaker_puck" (x2), "mic_cup", "boom_mount", "headset_assembled" (view only). Checks: "check_*" (see the end).
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

// ------------------------- THE NECKBAND'S PARTS (MEASURE after opening it) -------------------------
nb_len = 42;             // MEASURE: the main board: length (along the USB-C)
nb_w = 11;               // MEASURE: ... width
nb_t = 1.0;              // MEASURE: ... PCB thickness
nb_pcb = [nb_len, nb_w, nb_t];
nb_under = 1.5;          // MEASURE: the tallest part under the board
nb_over = 2.5;           // MEASURE: the tallest part on top of the board, besides the USB-C socket
usb = [8.94, 3.26];      // the USB-C socket's shell: width, height (standard; top-mounted on the board)
usb_out = 0.6;           // MEASURE: how far the socket sticks out past the board's end
batt_l = 40;             // MEASURE: the neckband's own battery: length (if it doesn't fit, a 502540 LiPo: 40 x 25 x 5)
batt_w = 25;             // MEASURE: ... width
batt_t = 5.2;            // MEASURE: ... thickness
batt = [batt_l, batt_w, batt_t];

// ------------------------- CONTROLS -------------------------
tact_h = 7;              // SELECT: tactile switch height, 6 x 6 mm (7 mm: the actuator reaches up into the dome)
tact_body = 3.5;         // the switch's body height
btn_x = [-16, 0, 16];    // the 3 buttons along the pod (front to back: volume +, multi-function, volume -)
btn_d = [10, 12.5, 10];  // the domes' diameters (the middle one is bigger, to find it with gloves on)
proud = [1.2, 1.8, 1.2]; // how far each dome stands above the lid (at least: taller switches raise them)

// ------------------------- SPEAKERS AND MIC -------------------------
spk_d = 10;              // MEASURE: the earbud's own driver: diameter (10 mm per boAt; a 40 mm helmet speaker: 40)
spk_t = 4;               // MEASURE: ... thickness (a 40 mm helmet speaker: 5.5)
spk = [spk_d, spk_t];
mic = [6, 2.7];          // MEASURE: the neckband's own mic: diameter, length (a 6 x 2.7 mm electret capsule is typical)
boom_d = 5;              // MEASURE: the boom: 2 mm aluminium wire + the mic cable in heat-shrink
cable_d = [4.2, 3.4];    // MEASURE: the 2 cables out of the pod: speakers (4-core), mic (shielded 2-core)

// ------------------------- FIXED SIZES -------------------------
wall = 2.4;      // pod wall at the seam (thicker lower down: the sides curve in toward the top)
side_in = 1.8;   // how far the sides curve in from the bottom to the seam
fl = 1.6;        // floor (at the middle; thicker toward the ends, where the shell curves away)
rc = 16;         // the pod's corner radius in plan (outside, at the bottom): nearly round ends
rr = 4.0;        // the lid's rolled edge, sideways (its height is the lid's)
kp_t = 1.0;      // keypad sheet
squeeze = 0.2;   // the keypad squeezed at the rim
lid_t = 2.2;
dome_w = 1.0;    // dome wall
hinge = 1.2;     // free sheet round each dome (the lid's hole is this much bigger all round)
pil_d = 6;       // lid screw pillars (M2 heat-set inserts, 3.2 mm hole)
sw_l = 50;       // switch perfboard length
usb_gap = 0.5;   // from the USB-C socket's face to the inside of the back wall
$fn = 40;

// ------------------------- DERIVED -------------------------
wall0 = wall + side_in;                       // the wall at the bottom
rc_in = rc - wall0;                           // the cavity's corner radius
pil_o = rc_in - (rc_in - 2.8) / sqrt(2);      // the pillars sit in the cavity's rounded corners
Wi = max(batt[1] + 2 * 1.8, nb_pcb[1] + 2 * (pil_o + pil_d/2 + 0.35));   // inside width (the board passes between the back pillars)
Li = usb_gap + usb_out + nb_pcb[0] + 1.5 + batt[0] + pil_o + pil_d/2 + 0.3;   // inside length (front: room for the pillars)
L = Li + 2 * wall0;
W = Wi + 2 * wall0;
pcb_x1 = Li/2 - usb_gap - usb_out;               // the board's rear end (the USB-C end)
pcb_x0 = pcb_x1 - nb_pcb[0];
bat_x1 = pcb_x0 - 1.5;
bat_x0 = bat_x1 - batt[0];
z_pcb0 = fl + nb_under;
z_pcb1 = z_pcb0 + nb_pcb[2];
usb_zc = z_pcb1 + usb[1]/2;
z_board = max(z_pcb1 + nb_over, z_pcb1 + usb[1]);
z_sw = max(z_board, fl + batt[2]) + 0.4;      // the switch perfboard's underside (on ledges)
z_sw1 = z_sw + 1.6;
z_seam = z_sw1 + tact_body + 0.6;            // the body's rim = the keypad's underside
z_lid0 = z_seam + kp_t - squeeze;
z_top = z_lid0 + lid_t;
act_top = z_sw1 + tact_h;
roof_in = act_top + 0.3;                      // the domes' hollow (0.3 over the actuator)
function dome_top(i) = max(z_top + proud[i], roof_in + 0.8 + (proud[i] - proud[0]));   // taller switches: taller domes
z_low = -(pow(L/2, 2)/(2*shell_rl) + pow(W/2, 2)/(2*shell_rw)) - 1;
pil = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (Li/2 - pil_o), sy * (Wi/2 - pil_o)]];
function side_d(z) = side_in * pow(max(0, z - z_low) / (z_seam - z_low), 2);   // the sides' inward curve
usb_hole = [12.6, 6.6];                       // room for a USB-C plug's moulding
cab_x = [pcb_x0 + 18, pcb_x0 + 25];
rib_x = [bat_x0 + 3, (bat_x0 + bat_x1)/2, bat_x1 - 2, pcb_x0 + 3, (pcb_x0 + pcb_x1)/2] + [1, 1, 1, 1, 1] * 0.137;   // (off the shell's facet corners)
usb_tab = 7;
plug_x = L/2 - side_d(usb_zc - usb_hole[1]/2 - 2.7 - usb_tab) + 0.2;      // the plug's flange: clear of the wall all down the tab

puck_t = spk[1] + 1.5 + 1.2;                  // speaker + room for its solder tabs + back
puck_d = max(spk[0] + 4, 40);

echo(str("POD: ", L, " x ", W, " mm, ", z_top, " mm above the tape at its middle; ",
         "lid screws 4 x M2 x 6 countersunk; speaker pucks ", puck_d, " x ", puck_t, " mm"));

// ------------------------- CHECKS ON THE SETTINGS -------------------------
for (i = [0:2]) {
  assert(dome_top(i) - roof_in >= 0.8, str("button ", i + 1, ": the dome's roof is too thin; use taller tactile switches (tact_h)"));
  assert(abs(btn_x[i]) + btn_d[i]/2 + hinge < L/2 - side_in - rr - 1, "the buttons don't fit on the lid");
  assert(btn_d[i]/2 + hinge < W/2 - side_in - rr - 1, "a button is too wide for the lid's flat top");
}
assert(btn_x[1] - btn_x[0] - (btn_d[0] + btn_d[1])/2 - 2*hinge >= 1.6, "buttons too close for the ridges between them");
assert(sw_l/2 < Li/2 - pil_o - pil_d/2 - 0.3, "the switch board hits the lid's pillars");
assert(sw_l/2 <= Li/2 - rc_in, "the switch board's corners are in the cavity's rounded ends");
assert(Wi/2 - pil_o - pil_d/2 >= nb_pcb[1]/2 + 0.3, "the lid's pillars hit the neckband's board");
assert(max([for (i = [0:2]) abs(btn_x[i])]) + 3 < sw_l/2, "a switch is off the end of the switch board");
assert(z_sw1 + tact_body < z_seam, "the switches' bodies hit the keypad");
assert(act_top >= z_seam + 0.8, "the tactile switches are too short to reach up into the domes (tact_h)");
assert(bat_x0 >= -Li/2 + pil_o + pil_d/2 + 0.2, "the battery runs into the front pillars");
assert(norm([max(0, -Li/2 + rc_in - bat_x0), max(0, batt[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the battery's corners hit the pod's rounded front end");
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
  for (i = [0:1]) translate([cab_x[i], -Wi/2 + 0.5, fl + 2.6]) rotate([90, 0, 0])  // cables, down side
    cylinder(d = cable_d[i], h = wall0 + 2);
}

module pod_lid() difference() {
  union() {
    hull() for (i = [0:8]) let(a = 90 * i/8)                 // a quarter-ellipse roll from the seam to the top
      slab(z_lid0 + lid_t * sin(a) - (i == 8 ? 0.01 : 0), side_in + rr * (1 - cos(a)));
    for (i = [0:1]) hull() for (s = [-1, 1])               // ridges between the buttons
      translate([(btn_x[i] + btn_x[i+1])/2, s * 5.5, z_top - 0.2]) sphere(r = 0.9, $fn = 16);
  }
  translate([0, 0, z_lid0 - 0.01]) linear_extrude(squeeze + 0.1) pod_2d(wall0 + 0.6);  // squeeze only at the rim
  for (i = [0:2]) translate([btn_x[i], 0, z_lid0 - 1]) cylinder(d = btn_d[i] + 2*hinge, h = lid_t + 3);
  for (p = pil) translate([p[0], p[1], z_lid0 - 1]) {
    cylinder(d = 2.3, h = lid_t + 3);
    translate([0, 0, 1 + lid_t - 1.1]) cylinder(d1 = 1.9, d2 = 4.1, h = 1.11);       // M2 countersunk
  }
}

module dome(i) hull() {
  cylinder(d = btn_d[i], h = dome_top(i) - z_seam - 1);
  translate([0, 0, dome_top(i) - z_seam - 1]) rotate_extrude() translate([btn_d[i]/2 - 1, 0]) circle(1, $fn = 16);
}

module keypad() difference() {                               // TPU: the buttons and the seam's gasket
  union() {
    translate([0, 0, z_seam]) linear_extrude(kp_t) pod_2d(side_in + 0.4);
    for (i = [0:2]) translate([btn_x[i], 0, z_seam]) dome(i);
  }
  for (i = [0:2]) translate([btn_x[i], 0, z_seam - 0.01]) {
    cylinder(d = btn_d[i] - 2*dome_w, h = roof_in - z_seam + 0.01);
    difference() { cylinder(d = btn_d[i] + 2*hinge, h = 0.41); cylinder(d = btn_d[i], h = 1); }   // thin hinge
  }
  for (p = pil) translate([p[0], p[1], z_seam - 1]) cylinder(d = 2.6, h = 3);
}

module usb_plug() {                                          // TPU: seals the USB-C socket
  xo = plug_x;
  translate([0, 0, usb_zc]) {
    translate([Li/2 - usb_gap - 3, 0, 0]) rotate([0, 90, 0]) linear_extrude(3.01) rotate(90) rrect([8.2, 2.3], 1.1);
    translate([Li/2 - usb_gap, 0, 0]) rotate([0, 90, 0]) linear_extrude(xo - Li/2 + usb_gap) rotate(90) rrect(usb_hole - [0.3, 0.3], 2.35);
    translate([xo, 0, 0]) rotate([0, 90, 0]) linear_extrude(1.2) rotate(90) rrect([usb_hole[0] + 3, usb_hole[1] + 2.4], 3.5);
    translate([xo, 0, 0]) hull() for (dy = [0, -usb_tab]) translate([0, 0, dy - usb_hole[1]/2 - 1.2]) rotate([0, 90, 0]) cylinder(d = 3, h = 1.2);
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
  for (x = btn_x) translate([x, 0, z_sw1]) {
    color("#222") translate([-3, -3, 0]) cube([6, 6, tact_body]);
    color("#444") cylinder(d = 3.5, h = tact_h + pressed);
  }
}
module insides() { board(); battery(); switches(); }

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
if (PART == "assembly") { helmet_shell(); helmet_details(); multmatrix(POD_M) pod_assembled(); }
else if (PART == "pod") pod_assembled();
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
else if (PART == "usb_plug") rotate([0, -90, 0]) translate([-plug_x - 1.2, 0, -usb_zc]) usb_plug();                        // flange down
else if (PART == "speaker_puck") translate([0, 0, puck_t]) rotate([180, 0, 0]) speaker_puck();   // front down
else if (PART == "mic_cup") mic_cup();
else if (PART == "boom_mount") boom_mount();
// checks
else if (PART == "check_insides") intersection() { insides(); union() { pod_body(); pod_lid(); keypad(); } }   // touch only (the switch board on its ledges)
else if (PART == "check_parts") intersection() { pod_body(); pod_lid(); }                    // empty
else if (PART == "check_plug") intersection() { usb_plug(); pod_body(); }                  // empty
else if (PART == "check_squeeze") intersection() { keypad(); pod_lid(); }                   // must collide: the seal
else if (PART == "check_press") intersection() { switches(0.5); keypad(); }                 // must collide: a press reaches the switch
else if (PART == "check_rest") intersection() { switches(0); keypad(); }                    // empty: the switches aren't held down
else if (PART == "check_shell") intersection() { pod_body(); shell_cut(-vhb_t); }           // empty: the tape's room
else if (PART == "none") { }

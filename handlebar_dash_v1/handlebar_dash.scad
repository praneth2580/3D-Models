/*
  HANDLEBAR DASH v1: the display head (round housing, carrier, back cover, sun hood) and its handlebar clamp.
  OpenSCAD 2021.01. PART selects what to show or export (list below). The interface box comes next.

  Built around these parts (see COMPONENTS.md; buy exactly these, or the parts won't fit):
    - Waveshare ESP32-S3 2.8" round display board (ESP32-S3-Touch-LCD-2.8C or ESP32-S3-LCD-2.8C). Its sizes here are
      from Waveshare's published outline drawing and its official 3D model (STEP, 2024-12-26): cover glass 95.86 mm
      across and 1.26 mm thick, visible screen 70.13 mm across, 4 M2 brass standoffs (4 mm across) whose ends are
      9.71 mm behind the glass front, total thickness 9.73 mm.
    - u-blox NEO-M8N GPS with a 25 x 25 mm ceramic patch antenna on a cable (the antenna sits in the sun hood).
    - SN65HVD230 CAN transceiver board (dash bus), GX12 4-pin panel socket (the cable to the interface box).

  How it goes together (front = the screen side, facing the rider):
    1. SHELL: a round tube with a thin front lip. The glass sits behind the lip on a foam ring (0.8 mm).
    2. CARRIER: a cup. The display screws onto its front with 4 x M2 x 6 into the display's own standoffs; the GPS
       module and the CAN board go on its back. The display and the carrier slide into the shell from the back;
       a key on the carrier fits a groove in the shell, so the screen can't be fitted rotated.
    3. COVER: a plug that closes the back. Its front edge presses the carrier forward, so the glass seats on the foam
       ring. 4 x M3 x 8 countersunk screws through the side wall into heat-set inserts in the cover hold it all.
       The top two also hold the SUN HOOD, which carries the GPS antenna (the plastic doesn't block GPS).
    4. MOUNT: a GoPro-style 3-prong joint on the cover: it fits the printed bar clamp here, or any GoPro handlebar
       mount. One M5 bolt sets the tilt.

  Frame: the head's axis is z, pointing from the screen into the housing (backwards). Origin: the centre of the front
  lip's back face (where the foam ring sits). y is up; x is to the right as seen from BEHIND (to the left as seen from
  the front), as in Waveshare's 3D model and back-view drawing.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly" (head on its clamp), "exploded", "front", "head_shell", "head_carrier", "head_cover", "head_hood",
// "lip_gasket" (TPU, or cut it from 0.8 mm foam), "clamp_upper", "clamp_lower", "display_dummy" (view only);
// checks "check_*" (see the end of the file).
PART = "assembly";
SHOW_DISPLAY = true;         // the display board, in the assembly pictures

// ------------------------- THE DISPLAY BOARD (published dimensions) ----
glass_d = 95.86;            // cover glass (Waveshare drawing: 95.86 +/- 0.15)
glass_t = 1.26;             // (3D model)
active_d = 70.13;           // visible screen (drawing)
disp_t = 9.73;              // glass front to the tallest part on the back (3D model)
standoff_z = 9.71;          // glass front to the ends of the 4 M2 standoffs (3D model)
standoff_d = 4.0;
standoffs = [[-18.0, -25.56], [18.0, -25.56], [-29.5, 15.14], [29.5, 15.14]];   // from the glass centre
pcb = [66.0, 65.37, 1.6];   // board: width, height, thickness (3D model)
pcb_y = [-29.86, 35.51];    // board's bottom and top edge, from the glass centre
pcb_z = 4.11;               // glass front to the board's front face
panel_d = 73.0;             // LCD panel behind the glass (3D model: 73.0 wide)
panel_y = 1.87;             // its centre, above the glass centre
panel_z = [1.36, 6.21];
fpc = [32, 9.0, 7.6];       // the panel's flat cable at the bottom: width, height below the panel, depth (envelope)
usb_xy = [-23.4, -20.7];    // native USB-C port (bottom left, seen from behind), its centre; it faces outward at 45 deg

// ------------------------- HEAD SETTINGS ------------------------------
fit = 0.3;                  // radial clearance around the glass
wall_t = 3.0;               // shell wall
lip_over = 2.2;             // how far the front lip overlaps the glass edge (the glass's black border is 12.9 mm wide)
lip_t = 1.8;                // front lip thickness
edge_r = 2.0;               // rounded front edge
gasket_t = 0.8;             // foam ring under the lip (closed-cell, self-adhesive)
gasket_squeeze = 0.2;       // how much the cover squeezes it
carrier_t = 2.5;            // the carrier's front plate
carrier_skirt = 1.6;        // its tube wall
bay = 14;                   // room behind the carrier for the GPS module, the CAN board and the wires
cover_plug = 8;             // how far the cover plugs into the shell
cover_back = 3.0;           // the cover's back plate
key_w = 6;                  // the anti-rotation key (at the top) and its groove
key_d = 1.2;
screw_ang = [60, 120, 240, 300];   // the 4 radial cover screws (degrees from +x; 60 and 120 also hold the hood)
insert_d = 4.2;             // M3 heat-set inserts in the cover's ring (SELECT: check your inserts)
insert_l = 5.7;
csk_d = 6.0;                // M3 countersunk head
cover_ring = 7;             // the cover plug's ring (radial width): carries the inserts
hood_len = 28;              // how far the sun hood reaches forward of the lip
hood_ang = 150;             // its width, in degrees around the top
hood_gap = 7.5;             // room between the shell and the hood for the GPS antenna (25 x 25 x ~4 mm)
hood_t = 2.0;
gps_patch = [25.5, 25.5, 4.5];   // antenna pocket in the hood (SELECT: check yours)
gx12_d = 12.2;              // GX12 panel socket hole (12 mm thread)

// ------------------------- MOUNT AND CLAMP ----------------------------
bar_d = 22.2;               // MEASURE: handlebar diameter at the clamp: 22.2 (7/8"), 25.4 (1") or 28.6 (1-1/8")
clamp_w = 24;               // clamp width along the bar
clamp_t = 5;                // clamp wall around the bar
clamp_rubber = 1.0;         // rubber strip inside the clamp
clamp_bolt = 4.5;           // 2 x M4 clamp bolts (holes)
clamp_nut = 7.0;            // M4 nut across the flats
riser = 30;                 // MEASURE: height of the joint above the bar's centre (clear the bike's own bar clamp)
tilt = 25;                  // MEASURE: screen tilt back from vertical, for the pictures (set on the bike with the joint)
gp_finger_t = 3.0;          // GoPro-style joint (PROVISIONAL: check against a GoPro mount): finger thickness,
gp_gap = 3.2;               //   gap between fingers,
gp_r = 7.5;                 //   finger end radius,
gp_hole = 5.3;              //   bolt hole (M5)
gp_reach = 16;              //   joint centre behind the cover's back face
gp_drop = 30;               // the joint sits this far below the head's centre, so the head sits above the clamp

// ------------------------- DERIVED --------------------------------------
$fn = 120;
bore_r = glass_d/2 + fit;
shell_r = bore_r + wall_t;
glass_z = gasket_t - gasket_squeeze;                 // the glass's front face, squeezed onto the foam
z_carrier = glass_z + standoff_z;                    // the carrier's front face = the standoffs' ends
z_cov = z_carrier + carrier_t + bay;                 // the cover's front edge = the carrier skirt's back end
shell_len = z_cov + cover_plug;                      // shell, from the lip's back face to its back rim
z_screw = z_cov + cover_plug/2;                      // the radial screws' plane
head_len = lip_t + shell_len + cover_back;           // overall depth (lip front to cover back)
gp_fingers3 = [-(gp_finger_t + gp_gap), 0, gp_finger_t + gp_gap];   // pod side: 3 fingers
gp_fingers2 = [-(gp_finger_t + gp_gap)/2, (gp_finger_t + gp_gap)/2]; // clamp side: 2 fingers

// ------------------------- CHECKS ------------------------------------
assert(glass_d/2 - lip_over > active_d/2 + 3, "The front lip would cover the screen.");
assert(insert_l + 0.8 <= cover_ring, "Insert too long for the cover's ring.");
assert(gp_gap >= gp_finger_t + 0.15, "GoPro fingers won't mesh.");
assert(z_screw - csk_d/2 > z_cov + 0.5 && z_screw + csk_d/2 < shell_len - 0.5, "Cover screws too close to the shell's rim.");
assert(glass_d/2 > active_d/2, "glass smaller than the screen?");
assert(gp_drop + gp_r + 3 <= shell_r, "The joint must stay on the cover.");
echo(head = [2*shell_r, head_len], glass_z = glass_z, z_carrier = z_carrier, z_cov = z_cov, shell_len = shell_len);

// ------------------------- HELPERS ------------------------------------
module ring(r0, r1, h) difference() { cylinder(r=r1, h=h); translate([0, 0, -0.1]) cylinder(r=r0, h=h + 0.2); }
module at_ang(a, r) rotate(a) translate([r, 0, 0]) children();
module radial_hole(a, z, d, l=20) rotate(a) translate([0, 0, z]) rotate([0, 90, 0]) cylinder(d=d, h=l, $fn=32);

// ------------------------- THE DISPLAY (simplified envelope, view only and for fit checks) ----
module display_dummy() {
  translate([0, 0, glass_z]) {
    color([0.05, 0.05, 0.06]) cylinder(d=glass_d, h=glass_t);
    color([0.12, 0.2, 0.32]) translate([0, 0, -0.08]) cylinder(d=active_d, h=0.05);    // the screen (drawn just in front of the glass)
    color([0.2, 0.2, 0.22]) {
      translate([0, panel_y, panel_z[0]]) cylinder(d=panel_d, h=panel_z[1] - panel_z[0]);
      translate([-fpc[0]/2, panel_y - panel_d/2 - fpc[1] + 2, panel_z[0]]) cube([fpc[0], fpc[1], fpc[2]]);
    }
    color([0.1, 0.3, 0.6]) intersection() {      // the board's corners are trimmed to the glass's circle (3D model)
      translate([-pcb[0]/2, pcb_y[0], pcb_z]) cube([pcb[0], pcb_y[1] - pcb_y[0], pcb[2]]);
      translate([0, 0, pcb_z - 1]) cylinder(d=glass_d - 0.2, h=20);
    }
    color([0.3, 0.3, 0.3]) intersection() {      // components on the board's back, up to the tallest
      translate([-pcb[0]/2 + 1, pcb_y[0] + 1, pcb_z + pcb[2]]) cube([pcb[0] - 2, pcb_y[1] - pcb_y[0] - 2, disp_t - pcb_z - pcb[2] - 0.6]);
      translate([0, 0, pcb_z]) union() { for (s = standoffs) translate(s) cylinder(d=11, h=50); translate([-pcb[0]/2, pcb_y[0], 0]) cube([pcb[0], 12, 50]); translate([-15, 0, 0]) cube([30, 30, 50]); }
    }
    color([0.8, 0.65, 0.2]) for (s = standoffs) translate([s[0], s[1], pcb_z - 0.4]) difference() {
      cylinder(d=standoff_d, h=standoff_z - pcb_z + 0.4, $fn=24); cylinder(d=1.8, h=20, $fn=16); }
  }
}

// ------------------------- SHELL ---------------------------------------
module head_shell() difference() {
  union() {
    // tube, from the lip's front face to the back rim, its front edge rounded
    translate([0, 0, -lip_t]) hull() {
      translate([0, 0, edge_r]) cylinder(r=shell_r, h=lip_t + shell_len - edge_r);
      cylinder(r=shell_r - edge_r, h=lip_t + shell_len);
    }
  }
  // the lip's window
  translate([0, 0, -lip_t - 1]) cylinder(r=glass_d/2 - lip_over, h=lip_t + 2);
  translate([0, 0, -lip_t - 0.01]) cylinder(r1=glass_d/2 - lip_over + 0.9, r2=glass_d/2 - lip_over, h=0.9);   // chamfer
  // the bore, behind the lip
  translate([0, 0, 0]) cylinder(r=bore_r, h=shell_len + 1);
  // the key's groove (top), from the back rim to the carrier
  translate([-key_w/2 - 0.2, bore_r - 0.5, z_carrier - 0.2]) cube([key_w + 0.4, key_d + 0.7, shell_len]);
  // the 4 cover screws: countersunk holes through the wall
  for (a = screw_ang) {
    radial_hole(a, z_screw, 3.4);
    rotate(a) translate([shell_r - 1.7, 0, z_screw]) rotate([0, 90, 0]) cylinder(d1=3.4, d2=csk_d + 0.2, h=1.75, $fn=32);
  }
  // the GPS antenna's cable, under the hood (top, near the back)
  radial_hole(90, z_carrier + carrier_t + 3, 4.5);
}

// ------------------------- CARRIER ------------------------------------
module head_carrier() difference() {
  union() {
    translate([0, 0, z_carrier]) cylinder(r=bore_r - 0.25, h=carrier_t);
    translate([0, 0, z_carrier]) ring(bore_r - 0.25 - carrier_skirt, bore_r - 0.25, z_cov - z_carrier);
    translate([-key_w/2, bore_r - 0.5, z_carrier]) cube([key_w, key_d + 0.3, z_cov - z_carrier]);   // key
  }
  // the display's 4 M2 screws (M2 x 6), countersunk from the back
  for (s = standoffs) translate([s[0], s[1], z_carrier - 1]) {
    cylinder(d=2.4, h=carrier_t + 2, $fn=24);
    translate([0, 0, 1 + carrier_t - 1.2]) cylinder(d1=2.4, d2=4.4, h=1.21, $fn=24);
  }
  // a 0.6 mm relief over the board's back (its tallest parts are level with the standoffs' ends)
  translate([0, 0, z_carrier - 0.1]) intersection() {
    translate([-pcb[0]/2 + 1, pcb_y[0] + 1, 0]) cube([pcb[0] - 2, pcb_y[1] - pcb_y[0] - 2, 0.7]);
    difference() { cylinder(r=bore_r, h=1); for (st = standoffs) translate(st) cylinder(d=standoff_d + 2.5, h=2, $fn=24); }
  }
  // wiring window to the display's headers (I2C / UART on the right, 12-pin at the top left): a big centre hole
  translate([0, 0, z_carrier - 1]) linear_extrude(carrier_t + 2) offset(r=3) square([36, 26], center=true);
  // the skirt: cable notch at the bottom, for the GX12 socket's wires
  translate([-8, -bore_r - 1, z_cov - 6]) cube([16, 6, 7]);
}
// The GPS module and the CAN board are fixed to the carrier's back with double-sided foam tape (no holes: their
// boards vary). The patch antenna goes in the hood.

// ------------------------- COVER --------------------------------------
module head_cover() difference() {
  union() {
    translate([0, 0, z_cov]) cylinder(r=bore_r - 0.15, h=cover_plug);            // the plug
    translate([0, 0, shell_len]) cylinder(r=shell_r, h=cover_back);               // the back plate
    translate([-key_w/2, bore_r - 0.6, z_cov]) cube([key_w, key_d + 0.3, cover_plug]);   // key
    // GoPro-style 3 fingers
    for (x = gp_fingers3) translate([x - gp_finger_t/2, -gp_drop, shell_len + cover_back]) rotate([0, 90, 0])
      hull() { translate([-gp_reach, 0, 0]) cylinder(r=gp_r, h=gp_finger_t, $fn=48); translate([0, -gp_r - 2, 0]) cube([0.01, 2*gp_r + 4, gp_finger_t]); }
  }
  // hollow inside the plug (a ring, 7 mm wide, carries the inserts)
  translate([0, 0, z_cov - 1]) cylinder(r=bore_r - 0.15 - cover_ring, h=cover_plug + 1);
  // heat-set inserts for the 4 radial screws
  for (a = screw_ang) rotate(a) translate([bore_r - 0.15 - insert_l, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=insert_d, h=insert_l + 1, $fn=32);
  // joint bolt (M5)
  translate([-20, -gp_drop, shell_len + cover_back + gp_reach]) rotate([0, 90, 0]) cylinder(d=gp_hole, h=40, $fn=32);
  // GX12 4-pin socket (bottom of the back plate)
  translate([0, -(bore_r - 0.15 - cover_ring - 9), shell_len - 1]) cylinder(d=gx12_d, h=cover_back + 2, $fn=48);   // its nut (15 mm) inside the ring
}

// ------------------------- SUN HOOD (with the GPS antenna) -------------
hood_r0 = shell_r + 0.2;                    // it rests on the shell at its two screw tabs
hood_r1 = shell_r + hood_gap + hood_t;
// Profile [r, z] polygons swept around the top (hood_ang degrees).
module hood_sweep(pts) rotate(90 - hood_ang/2) rotate_extrude(angle=hood_ang, $fn=180) polygon(pts);
band_z0 = z_screw - 6;                       // the band that sits on the shell, around the 2 top screws
hood_tab = 3;                                // what the screw heads bear on
module head_hood() difference() {
  union() {
    hood_sweep([[hood_r1 - hood_t, -lip_t - hood_len], [hood_r1, -lip_t - hood_len], [hood_r1, z_screw + 6], [hood_r1 - hood_t, z_screw + 6]]);   // the visor
    // the band, with a 45-degree underside so it prints without support
    hood_sweep([[hood_r0, band_z0], [hood_r1 - hood_t + 0.01, band_z0 - (hood_r1 - hood_t - hood_r0)], [hood_r1 - hood_t + 0.01, z_screw + 6], [hood_r0, z_screw + 6]]);
  }
  for (a = [60, 120]) {
    radial_hole(a, z_screw, 3.4, 60);
    rotate(a) translate([hood_r0 + hood_tab, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=6.5, h=hood_gap + hood_t + 1, $fn=32);   // head and screwdriver
  }
}
gps_z1 = band_z0 - (hood_r1 - hood_t - hood_r0)*0.5 - 1;   // the antenna ends before the band's slope
module gps_patch() color([0.85, 0.8, 0.55]) translate([-gps_patch[0]/2, shell_r + 0.3, gps_z1 - gps_patch[1]]) cube([gps_patch[0], gps_patch[2], gps_patch[1]]);

// ------------------------- FOAM RING ----------------------------------
module lip_gasket() ring(glass_d/2 - lip_over + 0.3, glass_d/2 - 0.3, gasket_t);   // hidden under the lip

// ------------------------- BAR CLAMP ----------------------------------
// In its own frame: the bar along x through the origin; the joint above it at +z.
cl_r = bar_d/2 + clamp_rubber + clamp_t;
module clamp_body(upper) difference() {
  union() {
    if (upper) {
      intersection() { rotate([0, 90, 0]) cylinder(r=cl_r, h=clamp_w, center=true); translate([-clamp_w, -50, 0]) cube([2*clamp_w, 100, 50]); }
      translate([-clamp_w/2, -cl_r - 6, 0]) cube([clamp_w, 2*cl_r + 12, 6]);                // bolt ears
      // the riser and the 2 fingers
      for (x = gp_fingers2) translate([x - gp_finger_t/2, 0, 0]) rotate([0, 90, 0])
        hull() { translate([-riser, 0, 0]) cylinder(r=gp_r, h=gp_finger_t, $fn=48); translate([-cl_r + 2, -10, 0]) cube([0.01, 20, gp_finger_t]); }
      hull() for (x = gp_fingers2) translate([x - gp_finger_t/2, -10, cl_r - 2]) cube([gp_finger_t, 20, 0.01]);
      translate([-gp_finger_t - gp_gap/2, -10, 0]) cube([2*gp_finger_t + gp_gap, 20, cl_r]);
    } else {
      intersection() { rotate([0, 90, 0]) cylinder(r=cl_r, h=clamp_w, center=true); translate([-clamp_w, -50, -50]) cube([2*clamp_w, 100, 50]); }
      translate([-clamp_w/2, -cl_r - 6, -6]) cube([clamp_w, 2*cl_r + 12, 6]);
    }
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=clamp_w + 2, center=true);
  translate([-clamp_w, -50, -0.4]) cube([2*clamp_w, 100, 0.8]);                    // gap between the halves
  for (s = [-1, 1]) translate([0, s*(cl_r + 1.5), -20]) {
    cylinder(d=clamp_bolt, h=40, $fn=24);
    if (!upper) translate([0, 0, 20 - 6 - 0.01]) cylinder(d=clamp_nut/cos(30), h=3.5, $fn=6);   // nut trap below
  }
  // the gap between the 2 fingers (for the cover's middle finger), and the bolt
  if (upper) {
    translate([-gp_gap/2, -20, cl_r - 2]) cube([gp_gap, 40, riser + 20]);
    translate([-20, 0, riser]) rotate([0, 90, 0]) cylinder(d=gp_hole, h=40, $fn=32);
  }
}
module clamp_upper() clamp_body(true);
module clamp_lower() clamp_body(false);

// ------------------------- ASSEMBLY -----------------------------------
// The head in its frame, then turned onto the clamp: the joint's axis is along the bar (x); tilt turns about it.
module head_parts(e=0) {
  color([0.16, 0.17, 0.19]) head_shell();
  color([0.95, 0.5, 0.15]) translate([0, 0, gasket_t > 0 ? -0.001 : 0]) lip_gasket();
  if (SHOW_DISPLAY) display_dummy();
  color([0.45, 0.47, 0.5]) translate([0, 0, e]) head_carrier();
  color([0.22, 0.23, 0.26]) translate([0, 0, 2*e]) head_cover();
  color([0.2, 0.21, 0.23]) translate([0, e, 0]) head_hood();
  translate([0, e*0.6, 0]) gps_patch();
}
joint_z = shell_len + cover_back + gp_reach;
module head_on_clamp(e=0) {
  // joint at the clamp's joint; the head's axis horizontal and pointing back at the rider when tilt = 0
  translate([0, 0, riser]) rotate([-tilt, 0, 0]) multmatrix([[-1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
    translate([0, gp_drop, -joint_z]) head_parts(e);
  color([0.25, 0.26, 0.28]) clamp_upper();
  color([0.25, 0.26, 0.28]) clamp_lower();
  color([0.75, 0.75, 0.75, 0.6]) rotate([0, 90, 0]) cylinder(d=bar_d, h=160, center=true);
}
module head_placed() translate([0, 0, riser]) rotate([-tilt, 0, 0]) multmatrix([[-1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]])
  translate([0, gp_drop, -joint_z]) children();

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") head_on_clamp(0);
else if (PART == "exploded") head_on_clamp(25);
else if (PART == "front") head_parts(0);
else if (PART == "display_dummy") display_dummy();
else if (PART == "head_shell") translate([0, 0, lip_t]) head_shell();                 // lip on the bed
else if (PART == "head_carrier") translate([0, 0, -z_carrier]) head_carrier();         // plate on the bed
else if (PART == "head_cover") translate([0, 0, -z_cov]) head_cover();              // plug's front edge on the bed, fingers up
else if (PART == "head_hood") translate([0, 0, lip_t + hood_len]) head_hood();      // standing on its front edge
else if (PART == "lip_gasket") lip_gasket();
else if (PART == "clamp_upper") clamp_upper();
else if (PART == "clamp_lower") rotate([180, 0, 0]) clamp_lower();
// Checks: must be empty (or only touch).
else if (PART == "check_display") intersection() { display_dummy(); union() { head_shell(); head_carrier(); head_cover(); head_hood(); } }
else if (PART == "check_gasket") intersection() { display_dummy(); lip_gasket(); }   // must collide: the squeeze
else if (PART == "check_parts") {
  intersection() { head_shell(); head_carrier(); }
  intersection() { head_shell(); head_cover(); }
  intersection() { head_carrier(); head_cover(); }
  intersection() { head_shell(); head_hood(); }
  intersection() { head_cover(); head_hood(); }
  intersection() { head_shell(); lip_gasket(); }
}
else if (PART == "check_clamp") intersection() { clamp_upper(); clamp_lower(); }
// The head (every part) vs the clamp and the bar, at this tilt: must be empty.
else if (PART == "check_mount") intersection() {
  head_placed() union() { head_shell(); head_cover(); head_hood(); }
  union() { clamp_upper(); clamp_lower(); rotate([0, 90, 0]) cylinder(d=bar_d, h=160, center=true); }
}
else if (PART == "none") { }

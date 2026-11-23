/*
  NOT A MODEL ON ITS OWN: phone_dock_v0.5.scad includes this file (it uses the dock's lock bay, bolt and cover).
  To look at this lock or export its parts, open ../tubular_lock.scad in OpenSCAD. Set the key code here.

  TUBULAR LOCK (optional, printable): a pin-tumbler lock with a round, hollow key, in its own lock cartridge.
  Included by phone_dock_v0.5.scad (uses its lock bay, crank geometry, yoke, bolt, arm pocket and cover).
  lock_type = "tubular" picks it. See TUBULAR_LOCK.md.

  How it works:
    - KEY: a printed tube (13.5 mm across, 3 mm wall) with 6 notches in its end, each 0, 1 or 2 mm deep (tl_code),
      and a small TAB on its side.
    - PLUG: turns in the HOUSING. It has 6 holes on a circle, one per notch. In each sits a KEY PIN (printed,
      stepped: a thin tip pokes forward out of the plug's pin face). Behind the plug, in the housing, each hole
      continues as a chamber with a DRIVER pin and a spring.
    - The tips are all the same length; the code is in the length of each key pin's thicker body, inside the plug.
      So with no key every tip stands at the same height in the keyhole: looking in, or measuring the tips, gives
      nothing away (Update 27: the tips used to stand at the code's heights, readable through the keyhole).
    - No key: the springs push the drivers into the plug's holes, so the plug can't turn. How far each one goes in
      depends on its pin's digit (1.2 to 3.2 mm), so the drivers have a thin stem at the back that runs inside the
      spring: whatever the digit, a driver's head or stem bridges the gap between plug and housing.
    - The right key: pushed in until its end sits on the pin face, each notch pushes its key pin back by just the
      right amount: every key pin's back end, and every driver's front end, meet exactly at the gap between the
      plug and the housing (the shear line). Now the plug turns.
    - A quarter turn (anticlockwise, seen from the keyhole) turns the CRANK on the back of the plug, whose steel pin
      drives the store lock's own YOKE (the same lock_yoke part) and pulls the steel bolt down. Unlocked.
    - The key comes out only when locked: its tab passes the keyhole's notch only at that angle. Turned, the tab is
      behind the cartridge's face, so the key is held in.
    - Locked, the crank pin is at top dead centre (as with the store lock), so pushing the bolt down can't turn it.
    - Stops on the plug (a lug in a 90-degree pocket in the housing) take the key's twist at both ends of the turn,
      so the crank's shaft never takes a hard twist.

  Why a tube suits printing: a twisted tube is the strongest shape against twisting (the push-key lock avoided
  turning because a flat printed blade snaps when twisted). The key prints standing on its bow with the cut end at
  the top, so the cut depths are exact layer heights. All the round parts (housing, plug, key, pins) print standing
  on end, so their circles are round.

  Frame: dock frame. Everything follows the lock bay, so it fits both mounts. Rotating parts are drawn locked
  (turn = 1) and turned by tl_rot(turn): turn 0 = unlocked = 90 degrees about +x.
  Profiles are drawn in 2D (u, v) = (y - lock_y, z - lock_z) and pushed along x by tl_ax(); angles a are measured
  from +y towards +z, which is anticlockwise as seen from the keyhole.
*/

// ------------------------- SETTINGS ---------------------------------
tl_code = [1, 0, 2, 2, 0, 1];   // CHANGE THIS before printing: one digit 0-2 per pin, pin 1 first (see TUBULAR_LOCK.md)
tl_step = 1.0;              // notch depth step (1 mm: forgiving to print; one step wrong still blocks by 1 mm)
tl_depths = 3;              // digits 0..2. 3 depths x 6 pins = 729 codes
tl_rp = 5.25;               // pin circle radius
tl_pin_d = 3.0;             // key pins' body and drivers
tl_tip_d = 2.0;             // key pins' thin tip
tl_hole = 3.4;              // their holes (printed standing; drill 3.5 if tight)
tl_tip_hole = 2.4;
tl_w = 0.8;                 // key pin body length for a 0 digit (each digit step adds tl_step; the tips are all alike)
tl_T = 1.2;                 // how far the drivers cross into the plug with no key, at least (pins with the top digit)
tl_drv = 1.4;               // driver's head length (the spring pushes on its back)
tl_stem = [2.0, 2.7];       // driver's stem, inside the spring: diameter, length
tl_spr = 4.9;               // spring length with the right key in; a 2-step-wrong key squeezes it 2 mm more (2.9)
tl_spr_free = 10;           // the springs' free length (bought: 3 mm OD, 0.3 mm wire, about 10 mm long)
tl_floor = 0.8;             // housing's back wall behind the chambers
tl_frame = 1.2;             // cartridge wall behind the face plate (joins the face plate to the cartridge)
tl_play = 0.2;              // plug's end play: springs push it forward, the key pushes it back onto the housing
tl_sleeve = 2.0;            // plug's front sleeve (around the key's end; the key's tab turns in it)
tl_nar = 1.2;               // plug's pin face: length of the thin part of each hole (the key pins' stop)
tl_key_ro = 6.75;           // key tube: outer radius
tl_key_ri = 3.75;           //   inner radius
tl_plug_r = 8.4;
tl_bore_r = 8.6;
tl_house_r = 9.9;           // housing's round top; below the axis it is square (anti-rotation)
tl_notch_w = 2.8;           // key notch width (tip 2.0 + 0.8)
tl_tab = [2.4, 7.9, 1.8];   // key tabs: width, outer radius, length from the key's end
tl_tab_a = 270;             // first tab's angle when locked (bottom of the keyhole); the second is one pin gap before it
tl_lug_a = 235;             // plug's stop lug, locked (unlocked = + 90)
tl_lug_w = 20;              // its width (degrees)
tl_lug_r = 9.1;
tl_recess_r = 9.35;         // the housing's pocket for the lug
tl_crank_t = 3.0;           // printed crank
tl_cpin_l = 8;              // steel dowel pin 4 x 8 (crank_pin_d), pressed into the crank
tl_dd = [5.0, 4.0];         // crank shaft: diameter, across the flats of its end (fits the plug's socket)
tl_fillet = 3.0;            // key: fillet where the tube meets the bow
tl_bow = [26, 16, 6];       // key bow: width, height, thickness

// ------------------------- DERIVED (dock frame) ---------------------
tl_n = len(tl_code);
tl_vbot = cart_z0 - lock_z;                                    // cartridge (and housing) bottom, in v
function tl_pa(i) = tl_tab_a + 180/tl_n + i*360/tl_n;          // pin i's angle (locked); pin 0 = "pin 1"
// Key tabs [angle, width]: two, so the key's twist is shared. Both stay in the keyhole's lower half at every angle
// of the turn (its top is pointed for printing, so a tab there could slip out), and being one pin gap apart they
// match the keyhole's notches only the right way round.
tl_tabs = [[tl_tab_a, tl_tab[0]], [tl_tab_a - 360/tl_n, tl_tab[0]]];
tl_xf = lock_panel_inner_x - tl_frame;                         // back of the frame (x 83.8)
tl_hx1 = tl_xf - 0.1;                                          // housing front
tl_px1 = tl_hx1 - tl_play;                                     // plug front, key in (pushed back)
tl_xpf = tl_px1 - tl_sleeve;                                   // plug's pin face = where the key's end stops
tl_xstep = tl_xpf - tl_nar;                                    // the key pins' shoulders stop here (no key)
tl_range = (tl_depths - 1)*tl_step;                            // deepest cut (2 mm)
tl_xs = tl_xstep - tl_w - tl_T - tl_range;                     // shear line = plug's back face, key in
tl_tip_l = tl_nar + tl_T + tl_range;                           // every key pin's tip (shoulder to end)
tl_xfl = tl_xs - tl_drv - tl_spr;                              // chamber floor
tl_hx0 = tl_xfl - tl_floor;                                    // housing back
tl_cx1 = tl_hx0 - tl_play;                                     // crank front (key in)
tl_cx0 = tl_cx1 - tl_crank_t;
tl_sock = 2.3;                                                 // plug's socket for the crank shaft (depth)
tl_kbx = lock_face_x + tl_fillet + 0.3;                        // key bow's inner face
tl_drain = [plk_drain_x, plk_yc - lock_y];                     // over the lock cover's front drain
// Boss for the lock cover's screw into the cartridge (cart_screw): the housing has a notch for it.
tl_boss_u = cart_screw[1] - lock_y + 1.25 + 1.25;              // inner edge of the boss (u)
tl_boss_v = cart_z0 + cart_screw_l + 1.0 - lock_z;             // top of the boss (v)
tl_boss_x = [cart_screw[0] - 2.4, cart_screw[0] + 2.4];

// ------------------------- CHECKS ------------------------------------
assert(tl_n >= 4 && tl_n <= 6, "tl_code: 4 to 6 pins.");
assert(min(tl_code) >= 0 && max(tl_code) <= tl_depths - 1, "tl_code digits must be 0 to tl_depths - 1.");
assert(tl_spr - tl_range >= 2.9, "Spring would close solid under a wrong key.");
assert(tl_spr + tl_T + tl_range + tl_play <= tl_spr_free - 1.0, "Springs too short: with no key, a pin with a 0 digit gets too little push.");
assert(tl_stem[0] <= 2*1.35 - 0.3 - 0.3, "Driver's stem too thick for the spring.");
assert(tl_drv + tl_stem[1] + tl_range <= tl_spr + tl_drv - 0.2 + 1e-6, "Driver's stem would hit the chamber floor under a wrong key.");
assert(tl_drv + tl_stem[1] - (tl_T + tl_range + tl_play) >= 0.6, "With no key, a driver must still bridge the shear line.");
assert(tl_w >= 0.8, "Key pin body too short.");
assert(tl_cx0 - yoke_x1 >= 0.5 - 1e-6, "Crank hits the yoke.");
assert(tl_cx1 - tl_cpin_l >= bay_x0 + 0.2 && tl_cx1 - tl_cpin_l <= yoke_x0 + 1.0, "Crank pin: must reach through the yoke, short of the bay's back wall.");
assert(tl_house_r + 0.2 + 1.0 <= (bay_y1 - bay_y0)/2 - cart_clear, "Housing pocket breaks the cartridge's side walls.");
assert(tl_key_ro + 0.3 + 1.2 <= notch_hw - cart_clear, "Keyhole too close to the face plate's edge.");
assert(tl_rp - tl_hole/2 - (tl_dd[0] + 0.4)/2 >= 0.6, "Chambers break into the shaft hole.");
assert(2*tl_rp*sin(180/tl_n) - tl_hole >= 1.2, "Pin holes too close together.");
assert(2*tl_key_ri*sin(180/tl_n) - tl_notch_w >= 0.8, "Key notches too close together.");
assert(tl_key_ro*2*PI*(180/tl_n)/360 >= tl_tab[0]/2 + tl_notch_w/2 + 0.8, "Key tab runs into a notch.");
assert(tl_xpf + tl_tab[2] <= tl_xf - 0.4, "Key tab not behind the frame when the key is in.");
assert(tl_tab_a - 360/tl_n >= 180 && tl_tab_a + 90 <= 360, "A key tab passes through the keyhole's pointed top during the turn.");
assert(abs(((tl_lug_a - (tl_tab_a - 360/tl_n) + 180) % 360) - 180) >= tl_lug_w/2 + asin((tl_tab[0]/2 + 0.6)/tl_plug_r) + 2, "Plug's stop lug runs into a tab slot.");
assert(tl_bore_r < tl_recess_r && tl_recess_r < tl_house_r - 0.5, "Lug pocket too thin.");
assert(tl_boss_x[1] + 0.2 <= tl_xpf + 0.6 - 1.5 && tl_boss_x[0] - 0.2 >= tl_hx0 + 2, "Cover screw boss too close to the lug pocket or the housing's back.");

// ------------------------- HELPERS -----------------------------------
// Push a 2D (u, v) profile along +x from x0 to x1.
module tl_ax(x0, x1) multmatrix([[0, 0, 1, x0], [1, 0, 0, lock_y], [0, 1, 0, lock_z], [0, 0, 0, 1]]) linear_extrude(x1 - x0) children();
// Turn about the lock's axis: turn 1 = locked (as drawn), 0 = unlocked.
module tl_rot(turn) translate([0, lock_y, lock_z]) rotate([90*(1 - turn), 0, 0]) translate([0, -lock_y, -lock_z]) children();
// Place a part drawn along local +z at (x, angle a, radius r), pointing along +x.
module tl_at(x, a, r=tl_rp) translate([x, lock_y + r*cos(a), lock_z + r*sin(a)]) rotate([0, 90, 0]) children();
// Lay a part with its back (x = x0) on the bed, axis up.
module tl_to_print(x0) multmatrix([[0, 1, 0, -lock_y], [0, 0, 1, -lock_z], [1, 0, 0, -x0], [0, 0, 0, 1]]) children();

module tl_D(r, ext=0) { circle(r, $fn=96); translate([-r, tl_vbot - ext]) square([2*r, ext - tl_vbot]); }
// Round hole with a 45-degree pointed top cut flat at vtop (prints with the axis lying down, without sagging).
module tl_tear(r, vtop) intersection() {
  hull() { circle(r, $fn=96); translate([-0.01, r*sqrt(2) - 0.01]) square(0.02); }
  translate([-50, -50]) square([100, 50 + vtop]);
}
module tl_sector(r0, r1, a0, a1) intersection() {
  difference() { circle(r1, $fn=96); circle(r0, $fn=96); }
  polygon(concat([[0, 0]], [for (a = [a0:(a1 - a0)/12:a1]) 2*r1*[cos(a), sin(a)]]));
}
module tl_ray(a, w, r1) rotate(a) translate([0, -w/2]) square([r1, w]);    // strip from the axis outward at angle a

// ------------------------- PARTS (dock frame, locked, key in) ---------
// Housing: a square-bottomed block with the plug's bore, the 6 driver chambers and the shaft hole. Drops into the
// cartridge from below; its back corners sit on the cartridge, the lock cover holds it up.
module tl_housing() difference() {
  tl_ax(tl_hx0, tl_hx1) tl_D(tl_house_r);
  tl_ax(tl_xs, tl_hx1 + 1) circle(tl_bore_r, $fn=96);
  tl_ax(tl_xpf + 0.6, tl_hx1 + 1) tl_sector(0, tl_recess_r, tl_lug_a - tl_lug_w/2 - 2, tl_lug_a + 90 + tl_lug_w/2 + 2);
  for (i = [0:tl_n - 1]) {
    tl_at(tl_xfl, tl_pa(i)) cylinder(d=tl_hole, h=tl_xs - tl_xfl + 0.1, $fn=32);
    tl_at(tl_xs - 0.3, tl_pa(i)) cylinder(d1=tl_hole, d2=tl_hole + 0.8, h=0.31, $fn=32);   // lead-in chamfer
  }
  tl_ax(tl_hx0 - 1, tl_xs + 0.1) circle(d=tl_dd[0] + 0.4, $fn=48);
  // Drain: from the bottom of the bore to the lock cover's front drain.
  translate([tl_drain[0], lock_y + tl_drain[1], cart_z0 - 1]) cylinder(d=2.5, h=lock_z - tl_bore_r + 1.5 - cart_z0 + 1, $fn=24);
  // Notch for the cartridge's screw boss.
  translate([tl_boss_x[0] - 0.2, lock_y - 20, cart_z0 - 1]) cube([tl_boss_x[1] - tl_boss_x[0] + 0.4, 20 + tl_boss_u + 0.2, tl_boss_v + 0.2 + lock_z - cart_z0 + 1]);
}

// Plug: turns in the housing. back = how far it sits forward of its pushed-back place (0 = key in, tl_play = no key).
module tl_plug(turn=1, back=0) tl_rot(turn) translate([back, 0, 0]) difference() {
  union() {
    tl_ax(tl_xs, tl_px1) circle(tl_plug_r, $fn=96);
    tl_ax(tl_xpf + 0.8, tl_px1) tl_sector(tl_plug_r - 0.1, tl_lug_r, tl_lug_a - tl_lug_w/2, tl_lug_a + tl_lug_w/2);
  }
  tl_ax(tl_xpf, tl_px1 + 1) circle(tl_key_ro + 0.25, $fn=96);                                    // sleeve
  for (tb = tl_tabs) tl_ax(tl_xpf, tl_px1 + 1) intersection() { tl_ray(tb[0], tb[1] + 0.4, 20); circle(tl_plug_r + 1); }   // tab slots
  for (i = [0:tl_n - 1]) {
    tl_at(tl_xs - 0.1, tl_pa(i)) cylinder(d=tl_hole, h=tl_xstep - tl_xs + 0.1, $fn=32);
    tl_at(tl_xstep - 0.01, tl_pa(i)) cylinder(d=tl_tip_hole, h=tl_nar + 0.1, $fn=24);
    tl_at(tl_xs - 0.01, tl_pa(i)) cylinder(d1=tl_hole + 0.6, d2=tl_hole, h=0.3, $fn=32);           // lead-in chamfer
  }
  // Socket for the crank's shaft, the M3 countersunk screw's hole and its seat in the pin face.
  tl_ax(tl_xs - 0.1, tl_xs + tl_sock) intersection() { circle(d=tl_dd[0] + 0.4, $fn=48); square([tl_dd[1] + 0.3, 20], center=true); }
  tl_ax(tl_xs, tl_xpf + 0.1) circle(d=3.4, $fn=32);
  tl_at(tl_xpf - 1.5, 0, 0) cylinder(d1=3.1, d2=6.1, h=1.51, $fn=48);
}

// Key: tube, tab, bow. code = its cuts; turn as the plug; out = pulled out by this much (0 = fully in).
module tl_key_2d_bow() hull() for (s = [-1, 1]) translate([s*(tl_bow[0] - tl_bow[1])/2, 0]) circle(d=tl_bow[1], $fn=64);
module tl_key(code=tl_code, turn=1, out=0) tl_rot(turn) translate([out, 0, 0]) difference() {
  union() {
    tl_ax(tl_xpf, tl_kbx + 1) difference() { circle(tl_key_ro, $fn=96); circle(tl_key_ri, $fn=96); }
    // Tab. Its underside is a 1.15 mm overhang (it prints at the top of the key): small enough to print without
    // support. A 45-degree chamfer under it would reach into the frame when the key is turned.
    for (tb = tl_tabs) tl_ax(tl_xpf, tl_xpf + tl_tab[2]) intersection() { tl_ray(tb[0], tb[1], tl_tab[1]); circle(tl_tab[1], $fn=96); difference() { circle(20); circle(tl_key_ro - 0.4, $fn=96); } }
    // Fillet where the tube meets the bow.
    translate([tl_kbx, lock_y, lock_z]) rotate([0, -90, 0]) rotate_extrude($fn=96) difference() {
      translate([tl_key_ro - 0.1, 0]) square([tl_fillet + 0.1, tl_fillet]);
      translate([tl_key_ro + tl_fillet, tl_fillet]) circle(tl_fillet, $fn=48);
    }
    // Bow, with chamfered edges.
    hull() {
      tl_ax(tl_kbx, tl_kbx + tl_bow[2]) offset(r=-0.8) tl_key_2d_bow();
      tl_ax(tl_kbx + 0.8, tl_kbx + tl_bow[2] - 0.8) tl_key_2d_bow();
    }
  }
  for (i = [0:tl_n - 1]) if (code[i] > 0) tl_ax(tl_xpf - 1, tl_xpf + code[i]*tl_step) tl_ray(tl_pa(i), tl_notch_w, tl_key_ro + 1);
  // Lead-in chamfer at the tube's end, and the key-ring hole.
  translate([tl_xpf - 0.01, lock_y, lock_z]) rotate([0, 90, 0]) difference() { cylinder(r=tl_key_ro + 1, h=0.5, $fn=96); cylinder(r1=tl_key_ro - 0.5, r2=tl_key_ro, h=0.51, $fn=96); }
  tl_ax(tl_kbx - 1, tl_kbx + tl_bow[2] + 1) translate([(tl_bow[0] - tl_bow[1])/2 + 1, 0]) circle(d=5, $fn=32);
}

// Key pin i (local z axis, back at z = 0), driver, spring.
// Key pin i: body tl_w + digit steps long (the code), then the tip, the same for every pin.
function tl_body(i) = tl_w + tl_code[i]*tl_step;
module tl_keypin(i) {
  cylinder(d1=tl_pin_d - 0.6, d2=tl_pin_d, h=0.3, $fn=32);
  translate([0, 0, 0.3]) cylinder(d=tl_pin_d, h=tl_body(i) - 0.3, $fn=32);
  translate([0, 0, tl_body(i) - 0.01]) cylinder(d=tl_tip_d, h=tl_tip_l - 0.2 + 0.01, $fn=24);
  translate([0, 0, tl_body(i) + tl_tip_l - 0.2]) cylinder(d1=tl_tip_d, d2=tl_tip_d - 0.4, h=0.2, $fn=24);
}
// Driver (local z, pointing +x when placed): head from z = 0 to tl_drv (its back face at z = 0 takes the spring),
// stem behind it (z < 0), inside the spring.
module tl_driver() {
  translate([0, 0, -tl_stem[1]]) {
    cylinder(d1=tl_stem[0] - 0.4, d2=tl_stem[0], h=0.2, $fn=24);
    translate([0, 0, 0.2]) cylinder(d=tl_stem[0], h=tl_stem[1] - 0.19, $fn=24);
  }
  cylinder(d=tl_pin_d, h=tl_drv - 0.3, $fn=32);
  translate([0, 0, tl_drv - 0.3]) cylinder(d1=tl_pin_d, d2=tl_pin_d - 0.6, h=0.3, $fn=32);
}
module tl_spring(l) linear_extrude(l, twist=-360*6, slices=72) translate([1.35, 0]) circle(0.15, $fn=8);

// Crank: plate + pin boss, with the shaft (flats at its end) that goes through the housing into the plug.
module tl_crank(turn=1) tl_rot(turn) difference() {
  union() {
    tl_ax(tl_cx0, tl_cx1) hull() { circle(d=crank_hub_d, $fn=64); translate([0, crank_r]) circle(d=crank_pin_d + 3, $fn=48); }
    tl_ax(tl_cx1 - 0.01, tl_xs) circle(d=tl_dd[0], $fn=48);
    tl_ax(tl_xs - 0.01, tl_xs + tl_sock) intersection() { circle(d=tl_dd[0], $fn=48); square([tl_dd[1], 20], center=true); }
  }
  tl_ax(tl_cx0 - 0.1, tl_cx1 + 0.1) translate([0, crank_r]) circle(d=crank_pin_d - 0.1, $fn=32);   // steel pin, pressed in
  tl_ax(tl_xs + tl_sock - 6.2, tl_xs + tl_sock + 0.1) circle(d=2.5, $fn=24);                       // M3 x 8 pilot
}
module tl_steel_pin(turn=1) tl_rot(turn) tl_ax(tl_cx1 - tl_cpin_l, tl_cx1) translate([0, crank_r]) circle(d=crank_pin_d, $fn=32);
module tl_screw(turn=1) tl_rot(turn) {        // M3 x 8 countersunk, picture and checks only
  tl_at(tl_xpf - 1.5, 0, 0) cylinder(d1=3, d2=6, h=1.5, $fn=32);
  tl_ax(tl_xpf - 8, tl_xpf - 1.4) circle(d=2.4, $fn=24);
}

// Where the pins sit. key = code of the key in it (undef: no key). Key pin back end, driver front end (x):
// No key: each key pin's shoulder rests on the pin face's step (the plug pushed forward by tl_play), so its back end
// is further forward the smaller its digit, while every tip ends at the same place.
function tl_kp_rest(i) = tl_xs + tl_T + tl_range - tl_code[i]*tl_step + tl_play;
function tl_kp_x(i, key) = is_undef(key) ? tl_kp_rest(i) : min(tl_kp_rest(i), tl_xs + (key[i] - tl_code[i])*tl_step);
module tl_pins(turn=1, key=tl_code) {
  for (i = [0:tl_n - 1]) {
    x = tl_kp_x(i, key);
    tl_rot(turn) tl_at(x, tl_pa(i)) tl_keypin(i);
    tl_at(x - tl_drv, tl_pa(i)) tl_driver();
  }
}
module tl_springs(key=tl_code) for (i = [0:tl_n - 1]) let(x = tl_kp_x(i, key) - tl_drv) tl_at(tl_xfl, tl_pa(i)) tl_spring(x - tl_xfl);

// Cartridge cuts: keyhole through the face plate and frame, the housing's pocket (open below, round top cut
// flat so it prints), the crank's space (open below, so the housing and crank go in together) and the yoke's.
module tl_cuts() {
  tl_ax(tl_xf - 0.05, lock_face_x + 0.1) {
    tl_tear(tl_key_ro + 0.3, notch_hw - cart_clear - 1.5);
    for (tb = tl_tabs) intersection() { tl_ray(tb[0], tb[1] + 0.6, tl_tab[1] + 0.3); circle(20); }
  }
  difference() {
    tl_ax(tl_hx0, tl_xf) union() { tl_D(tl_house_r + 0.2, 2); tl_tear(tl_house_r + 0.2, bay_top_z - cart_clear - lock_z - 1.2); }
    translate([tl_boss_x[0], lock_y - 20, cart_z0 - 2]) cube([tl_boss_x[1] - tl_boss_x[0], 20 + tl_boss_u, tl_boss_v + lock_z - cart_z0 + 2]);
  }
  tl_ax(yoke_x1, tl_hx0 + 0.01) union() { circle(crank_sweep_r, $fn=96); translate([-(crank_hub_d/2 + 0.4), tl_vbot - 2]) square([crank_hub_d + 0.8, 2 - tl_vbot]); }
  translate([yoke_x0 - 0.3, yoke_y0 - 0.3, pod_bottom_z - 1])
    cube([yoke_x1 - yoke_x0 + 0.6, yoke_y1 - yoke_y0 + 0.6, yoke_top_locked + 0.5 - pod_bottom_z + 1]);
}

// Everything in place. key: shown in the lock (turn as the plug).
module tl_placed(turn=1, key=true) {
  color([0.55, 0.36, 0.20]) tl_housing();
  color([0.85, 0.55, 0.15]) tl_plug(turn);
  color([0.95, 0.85, 0.30]) tl_pins(turn);
  color([0.70, 0.70, 0.74]) tl_springs();
  color([0.45, 0.45, 0.50]) tl_crank(turn);
  color([0.75, 0.75, 0.78]) { tl_steel_pin(turn); tl_screw(turn); }
  color([0.55, 0.58, 0.62]) lock_yoke(turn);
  if (key) color([0.25, 0.50, 0.85]) tl_key(tl_code, turn);
}

// ------------------------- PART SELECTOR (PART = "tl_...") -----------
TL_PARTS = ["tl_housing", "tl_plug", "tl_crank", "tl_key", "tl_pins", "tl_check_cart", "tl_check_dock", "tl_check_cover",
            "tl_check_parts", "tl_check_case", "tl_check_rightkey", "tl_check_nokey", "tl_check_wrongkey", "tl_check_keyout",
            "tl_check_stops", "tl_check_backdrive", "tl_check_keyangle", "tl_exploded", "tl_cutaway", "tl_cutaway_nokey"];
tl_wrong_i = -1;           // tl_check_wrongkey: which pin's cut is one step off (-1 = all of them)
tl_turns = [1, 0.75, 0.5, 0.25, 0];
function tl_is_part(p) = len([for (n = TL_PARTS) if (n == p) 1]) > 0;
function tl_wrong_key() = [for (i = [0:tl_n - 1]) (tl_wrong_i < 0 || tl_wrong_i == i) ? (tl_code[i] < tl_depths - 1 ? tl_code[i] + 1 : tl_code[i] - 1) : tl_code[i]];
module tl_dock() { if (mount == "merged") dock_base(); else dock_receiver(); }
module tl_moving(turn) { tl_plug(turn); tl_pins(turn); tl_crank(turn); tl_steel_pin(turn); tl_screw(turn); lock_yoke(turn); tl_key(tl_code, turn); }
module tl_turning(turn, key) { tl_plug(turn, is_undef(key) ? tl_play : 0); for (i = [0:tl_n - 1]) tl_rot(turn) tl_at(tl_kp_x(i, key), tl_pa(i)) tl_keypin(i); }
module tl_fixed(key) { tl_housing(); for (i = [0:tl_n - 1]) tl_at(tl_kp_x(i, key) - tl_drv, tl_pa(i)) tl_driver(); }

module tl_half() render() intersection() { children(); translate([40, 0, -60]) cube([80, 80, 60 + lock_z]); }
module tl_part(p) {
  if (p == "tl_housing") tl_to_print(tl_hx0) tl_housing();                        // standing on its back face
  else if (p == "tl_plug") tl_to_print(tl_xs) tl_plug(1);                         // standing on its back face
  else if (p == "tl_crank") tl_to_print(tl_cx0) tl_crank(1);                      // flat, shaft up
  else if (p == "tl_key")                                                          // bow on the bed, cut end up
    multmatrix([[0, 1, 0, -lock_y], [0, 0, -1, lock_z], [-1, 0, 0, tl_kbx + tl_bow[2]], [0, 0, 0, 1]]) tl_key(tl_code, 1);
  else if (p == "tl_pins") {                                                       // key pins 1-6 in a row (standing on their backs), drivers below
    for (i = [0:tl_n - 1]) translate([i*6, 0, 0]) tl_keypin(i);
    for (i = [0:tl_n - 1]) translate([i*6, -6, tl_drv]) rotate([180, 0, 0]) tl_driver();   // on the head's front, stem up
  }
  // Checks: these must be empty or only touch.
  else if (p == "tl_check_cart")  for (t = tl_turns) intersection() { lock_cartridge(); union() { tl_housing(); tl_moving(t); } }
  else if (p == "tl_check_dock")  for (t = tl_turns) intersection() { tl_dock(); union() { tl_housing(); tl_moving(t); lock_bolt(t); } }
  else if (p == "tl_check_cover") for (t = tl_turns) intersection() { lock_cover(); union() { tl_housing(); tl_moving(t); } }
  else if (p == "tl_check_parts") for (t = tl_turns) {
      intersection() { tl_housing(); union() { tl_plug(t); tl_pins(t); tl_crank(t); tl_steel_pin(t); tl_screw(t); tl_key(tl_code, t); } }
      intersection() { tl_plug(t); union() { tl_pins(t); tl_crank(t); tl_steel_pin(t); tl_key(tl_code, t); } }
      intersection() { tl_crank(t); union() { tl_key(tl_code, t); lock_yoke(t); } }
      intersection() { tl_key(tl_code, t); tl_pins(t); }
    }
  else if (p == "tl_check_case") for (t = [1, 0]) intersection() { union() { case_shell(); case_back(); dock_shoe(); } tl_key(tl_code, t); }
  else if (p == "tl_check_rightkey") for (t = [1 - 3/90, 0.5]) intersection() { tl_fixed(tl_code); tl_turning(t, tl_code); }
  // These must collide: no key, or a key with a wrong cut, and the plug turned 3 degrees; the key pulled out while
  // unlocked; the plug turned 3 degrees past either end; the bolt pushed down while locked.
  else if (p == "tl_check_nokey")    intersection() { tl_fixed(undef); tl_turning(1 - 3/90, undef); }
  else if (p == "tl_check_wrongkey") intersection() { tl_fixed(tl_wrong_key()); tl_turning(1 - 3/90, tl_wrong_key()); }
  else if (p == "tl_check_keyout")   intersection() { lock_cartridge(); tl_key(tl_code, 0, 1.0); }
  else if (p == "tl_check_stops")    for (t = [1 + 3/90, -3/90]) intersection() { tl_housing(); tl_plug(t); }
  else if (p == "tl_check_keyangle")  for (a = [60:60:300]) intersection() { lock_cartridge(); tl_key(tl_code, 1 - a/90, 2.5); }   // half in, turned 60-300 deg
  else if (p == "tl_check_backdrive") intersection() { tl_steel_pin(1); translate([0, 0, -0.5]) lock_yoke(1); }
  else if (p == "tl_exploded") {        // picture: the lock's parts pulled apart along its axis (back on the left)
    color([0.55, 0.58, 0.62]) translate([-34, 0, 0]) { lock_yoke(1); lock_bolt(1); }
    color([0.75, 0.75, 0.78]) translate([-22, 0, 0]) tl_steel_pin(1);
    color([0.45, 0.45, 0.50]) translate([-12, 0, 0]) tl_crank(1);
    color([0.55, 0.36, 0.20]) tl_housing();
    color([0.70, 0.70, 0.74]) translate([10, 0, 0]) tl_springs();
    color([0.95, 0.85, 0.30]) translate([16, 0, 0]) for (i = [0:tl_n - 1]) tl_at(tl_xs + tl_T + tl_play - tl_drv + 3, tl_pa(i)) tl_driver();
    color([0.95, 0.85, 0.30]) translate([24, 0, 0]) for (i = [0:tl_n - 1]) tl_at(tl_xs, tl_pa(i)) tl_keypin(i);
    color([0.85, 0.55, 0.15]) translate([33, 0, 0]) tl_plug(1);
    color([0.75, 0.75, 0.78]) translate([44, 0, 0]) tl_screw(1);
    color([0.25, 0.50, 0.85]) translate([62, 0, 0]) tl_key(tl_code, 1);
  }
  else if (p == "tl_cutaway") {         // picture: cut on the axis's horizontal plane (seen from above), key in, locked
    color([0.34, 0.34, 0.37]) tl_half() lock_cartridge();
    color([0.55, 0.36, 0.20]) tl_half() tl_housing();
    color([0.85, 0.55, 0.15]) tl_half() tl_plug(1);
    color([0.95, 0.85, 0.30]) tl_half() tl_pins(1);
    color([0.20, 0.20, 0.22]) tl_half() tl_springs();
    color([0.45, 0.45, 0.50]) tl_half() tl_crank(1);
    color([0.75, 0.75, 0.78]) tl_half() { tl_steel_pin(1); tl_screw(1); }
    color([0.55, 0.58, 0.62]) tl_half() lock_yoke(1);
    color([0.25, 0.50, 0.85]) tl_half() tl_key(tl_code, 1);
  }
  else if (p == "tl_cutaway_nokey") {   // picture: the same cut with no key: every tip at the same height
    color([0.34, 0.34, 0.37]) tl_half() lock_cartridge();
    color([0.55, 0.36, 0.20]) tl_half() tl_housing();
    color([0.85, 0.55, 0.15]) tl_half() tl_plug(1, tl_play);
    color([0.95, 0.85, 0.30]) tl_half() tl_pins(1, undef);
    color([0.20, 0.20, 0.22]) tl_half() tl_springs(undef);
    color([0.45, 0.45, 0.50]) tl_half() tl_crank(1);
    color([0.75, 0.75, 0.78]) tl_half() { tl_steel_pin(1); tl_screw(1); }
    color([0.55, 0.58, 0.62]) tl_half() lock_yoke(1);
  }
}

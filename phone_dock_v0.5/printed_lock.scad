/*
  PRINTED LOCK (optional): a fully 3D-printable alternative to the store-bought 16 mm cam lock.
  Included by phone_dock_v0.5.scad (uses its lock_* variables). See PRINTED_LOCK.md.

  Type: WAFER lock, the same mechanism most store-bought cam locks use, chosen because every part that
  sets the key code is FLAT (the wafers and the key are printed flat, where FDM is most accurate):
    - a printed body (the D-shaped 16 mm envelope of a store cam lock, so the dock is unchanged),
      held in the lock pod's panel by a printed C-clip that snaps into a groove behind the panel
      (pushed up into the pod's nut cavity from underneath, like a store cam lock's retaining clip);
    - a printed plug (the part the key turns) carrying 4 flat wafers;
    - 4 flat wafers, each pushed by 2 small metal springs (2 mm OD; printed springs are too weak);
    - a flat printed key with one bitted edge: lock_code sets its cuts and each wafer's window;
    - a printed crank on the plug's square boss, same outline and 7 mm pin radius as the steel crank,
      with an M3 heat-set insert for the crank pin, held on by an M3 grub screw.

  How it locks: with no key, the springs push every wafer 0.9 mm out of the plug into a channel in the
  body, so the plug can't turn. The right key holds each wafer exactly flush, and the plug turns.
  A wrong cut leaves that wafer 0.5 mm or more proud on one side or the other, which still blocks it.
  The channels exist only at the LOCKED position, so the key comes out only when locked.

  Frames: L = lock frame, z along the lock axis INTO the dock (z = 0 at the panel's outer face).
  P = plug frame = L turned by plk_theta(turn) about z: the wafers slide along P x (spring pushes -x,
  the tab end is +x), the crank pin points along P +y. Locked (turn = 1): P = L.
  L to dock frame: xL -> -y, yL -> +z, zL -> -x, origin at the keyhole (lock_face_x, lock_y, lock_z).
*/

// ------------------------- SETTINGS ---------------------------------
lock_type = "store";        // "store" = bought 16 mm cam lock + drilled cam; "printed" = this lock (assembly view)
lock_code = [2, 0, 1, 2];   // CHANGE THIS before printing: your key code, one digit 0-2 per wafer, front to back.
                            // Digit = cut depth in steps of plk_step. Avoid all-equal codes like [1,1,1,1].
plk_step = 0.5;             // depth step between digits (0, 0.5, 1.0 mm). Bigger = more forgiving, fewer codes
plk_layer = 0.15;           // print every lock part at this layer height, with elephant's-foot compensation on

// Envelope: the store lock's, so the printed lock fits the same lock pod.
plk_d = lock_bore_d - 0.2;          // body outside diameter (D-shaped), 15.8
plk_flat = lock_bore_flat - 0.2;    // across the body's flats, 14.4
plk_flange_d = 20;                  // outside the pod, around the keyhole
plk_flange_t = 2.5;
plk_rear_z = lock_panel_t + lock_body_len - 0.2;   // body's rear face (the crank sits 0.2 behind it)

// Plug, wafers, key.
plk_plug_d = 11.2;
plk_clear = 0.2;                    // radial clearance, plug in body (and head, lug)
plk_head_d = 13;                    // plug head, in a counterbore in the flange
plk_head_t = 2.0;
plk_lug_w = 3.0;                    // rotation-stop lug on the head (quarter turn)
plk_lug_r = 8.3;
plk_wafer_t = 1.3;                  // about 9 layers at 0.15 mm
plk_slot_w = 1.6;                   // slot in the plug for each wafer
plk_pitch = 2.7;
plk_first_z = 8.0;                  // first wafer's centre (behind the clip groove)
plk_n = len(lock_code);
plk_tab_hw = 2.0;                   // wafer tab half-width (the end that pokes out when lifted)
plk_wafer_hw = 4.6;                 // wafer body half-width (its shoulders carry the springs)
plk_win_hw = 1.15;                  // key window half-width (key 2.0 thick)
plk_win_bot = -3.6;                 // key window's bottom edge (wafer flush)
plk_key_t = 2.0;
plk_key_top = 2.2;                  // uncut key: x from -2.2 to +2.2 in the plug
plk_drop = 0.9;                     // how far the springs push a wafer out with no key
plk_wbody_r = plk_plug_d/2 - plk_drop - 0.2;   // the wide body never leaves the plug; only the tab (both ends) pokes out
plk_lift = 2*plk_step;              // most a wafer is lifted while the key slides in or out
plk_wclear = 0.15;                  // wafer in its slot
plk_ch_r = plk_plug_d/2 + plk_lift + 0.15;   // body channel radius
plk_keyway_end = 18.5;
// Springs: 2 per wafer, 2.0 mm OD, 0.2-0.3 mm wire, about 5 mm free length (mini compression-spring kit).
// Working length 2.0-3.9 mm: with 0.3 mm wire, a spring of 6 coils or fewer (snip one off if it binds).
plk_spring_od = 2.0;
plk_pocket_d = 2.2;
plk_spring_y = 3.0;
plk_pocket_top = 3.0;               // spring seat in the plug (P x)
// Retaining C-clip in a groove right behind the panel (in the pod's nut cavity).
plk_groove_z = [lock_panel_t, lock_panel_t + 3.5];
plk_groove_r = 7.0;
plk_clip_t = 3.4;
plk_clip_od = 20;
plk_clip_mouth = 2*plk_groove_r - 0.8;   // narrower than the groove: the clip snaps on
// Crank (replaces the drilled steel cam): same outline and pin radius as crank_template.
plk_boss = 7.0;                     // square drive on the plug's rear
plk_insert_d = 4.0;                 // M3 heat-set insert (3 mm long) for the crank pin
plk_grub_d = 2.5;                   // M3 grub screw, tapped into the printed hub

function plk_slot_z(i) = plk_first_z + i*plk_pitch;
function plk_cut(i) = lock_code[i]*plk_step;
function plk_theta(turn) = 90*(turn - 1);          // locked = 0, unlocked = -90

// ------------------------- CHECKS -----------------------------------
assert(min(lock_code) >= 0 && max(lock_code) <= 2, "lock_code digits must be 0, 1 or 2.");
assert(plk_first_z - plk_slot_w/2 >= plk_groove_z[1] + 0.1, "First wafer runs into the clip groove.");
assert(plk_groove_r - (plk_plug_d/2 + plk_clear) >= 1.0, "Body wall under the clip groove is under 1 mm.");
assert(plk_slot_z(plk_n - 1) + plk_slot_w/2 + 0.8 <= plk_keyway_end, "Last wafer is too close to the keyway's end.");
assert(plk_keyway_end <= plk_rear_z, "Keyway runs into the crank boss.");
assert(plk_d/2 - plk_ch_r >= 1.0, "Body wall behind the wafer channels is under 1 mm.");
assert(plk_flat/2 - (plk_plug_d/2 + plk_clear) >= 1.2, "Body wall at the flats is under 1.2 mm.");
assert(plk_win_hw - plk_key_t/2 >= 0.1, "Key window too tight for the key.");
assert(plk_win_bot + plk_lift <= -plk_key_top - 0.25, "Key window bottom hits the key when a wafer is lifted.");
assert(plk_key_top - 2*plk_step - plk_drop >= 0.2, "Key tip can't get under a dropped wafer.");
assert(plk_pitch - plk_pocket_d >= 0.45, "Spring pockets of neighbouring wafers break into each other.");
assert(norm([plk_pocket_top, plk_spring_y + plk_pocket_d/2]) <= plk_plug_d/2 - 0.5, "Spring pocket wall under 0.5 mm.");
assert(plk_wbody_r >= plk_spring_y + plk_spring_od/2 + 0.1, "Wafer shoulders too narrow for the springs.");
assert(plk_pocket_top - plk_lift >= 1.9, "Springs would be squashed solid (under 1.9 mm) at full lift.");
assert(plk_clip_od/2 <= lock_nut_clear_d/2 - 0.4 && plk_clip_t <= lock_nut_len - 0.6, "Clip doesn't fit the pod's nut cavity.");
echo(printed_lock_code = lock_code, spring_length_range = [plk_pocket_top - plk_lift, plk_pocket_top + plk_drop]);

// ------------------------- 2D PROFILES (P frame) --------------------
module plk_d_2d(d=plk_d, flat=plk_flat) intersection() { circle(d=d); square([d + 1, flat], center=true); }

// One wafer (flush position). cut = this wafer's key cut depth.
module plk_wafer_2d(cut) {
  r = plk_plug_d/2 - 0.05;
  difference() {
    union() {
      intersection() { circle(r=r); translate([-r - 1, -plk_tab_hw]) square([2*r + 2, 2*plk_tab_hw]); }            // tab, end to end
      intersection() { circle(r=plk_wbody_r); translate([-r - 1, -plk_wafer_hw]) square([r + 1, 2*plk_wafer_hw]); }  // body, shoulders at x = 0
    }
    translate([plk_win_bot, -plk_win_hw]) square([plk_key_top - cut - plk_win_bot, 2*plk_win_hw]);
  }
}
// Where a wafer can move in the plug (+ clearance).
module plk_slot_2d() {
  r = plk_plug_d/2 + 1;
  translate([-r, -plk_tab_hw - plk_wclear]) square([2*r, 2*(plk_tab_hw + plk_wclear)]);
  translate([-r, -plk_wafer_hw - plk_wclear]) square([r + plk_lift + plk_wclear, 2*(plk_wafer_hw + plk_wclear)]);
}
// Channels in the body that a wafer pokes into (L frame, at the locked position only).
module plk_channel_2d() intersection() {
  circle(r=plk_ch_r);
  square([2*plk_ch_r + 2, 2*(plk_tab_hw + 0.3)], center=true);
}
// Key blade side view: x (bitting up) against z (into the lock).
module plk_key_blade_2d() {
  e = [for (i = [0:plk_n - 1]) plk_key_top - plk_cut(i)];
  zc = [for (i = [0:plk_n - 1]) plk_slot_z(i)];
  half = plk_wafer_t/2 + 0.1;
  tip_low = -0.3;
  z_tip = zc[plk_n - 1] + half + (e[plk_n - 1] - tip_low)/tan(60);
  top = concat([[-plk_flange_t, plk_key_top], [zc[0] - half - plk_cut(0), plk_key_top]],
               [for (i = [0:plk_n - 1]) each [[zc[i] - half, e[i]], [zc[i] + half, e[i]]]],
               [[z_tip, tip_low]]);
  pts = concat(top, [[z_tip, -1.4], [z_tip - 0.8, -plk_key_top], [-plk_flange_t, -plk_key_top]]);
  polygon([for (p = pts) [p[1], p[0]]]);       // (x, z)
}

// ------------------------- PARTS (L / P frames) ---------------------
// Body (L frame): flange outside, D-shaped through the panel and behind it, with the clip groove.
module plk_body() {
  difference() {
    union() {
      translate([0, 0, -plk_flange_t]) cylinder(d=plk_flange_d, h=plk_flange_t, $fn=96);
      linear_extrude(plk_groove_z[0]) plk_d_2d();
      translate([0, 0, plk_groove_z[0]]) linear_extrude(plk_groove_z[1] - plk_groove_z[0]) intersection() { plk_d_2d(); circle(r=plk_groove_r, $fn=96); }
      translate([0, 0, plk_groove_z[1]]) linear_extrude(plk_rear_z - plk_groove_z[1]) plk_d_2d();
    }
    translate([0, 0, -plk_flange_t - 0.1]) cylinder(d=plk_plug_d + 2*plk_clear, h=plk_rear_z + plk_flange_t + 0.2, $fn=96);
    // Head counterbore + the quarter-turn sector for the stop lug (lug sits at 180 + theta, theta -90..0).
    translate([0, 0, -plk_flange_t - 0.1]) cylinder(d=plk_head_d + 2*plk_clear, h=plk_head_t + plk_clear + 0.1, $fn=96);
    half_ang = asin((plk_lug_w/2 + plk_clear)/(plk_head_d/2 + plk_clear)) + 1.0;
    translate([0, 0, -plk_flange_t - 0.1]) rotate([0, 0, 90 - half_ang])
      rotate_extrude(angle=90 + 2*half_ang, $fn=96) square([plk_lug_r + plk_clear, plk_head_t + plk_clear + 0.1]);
    // Wafer channels (locked position only).
    for (i = [0:plk_n - 1]) translate([0, 0, plk_slot_z(i) - plk_slot_w/2 - 0.05]) linear_extrude(plk_slot_w + 0.1) plk_channel_2d();
  }
}

// C-clip (L frame, in the groove): opens toward +y (up in the dock), so it pushes up onto the groove from below.
module plk_clip_2d() difference() {
  union() {
    circle(d=plk_clip_od, $fn=96);
    translate([-3, -plk_clip_od/2 - 2.5]) square([6, 3]);                  // pull tab (down), to remove it
  }
  circle(r=plk_groove_r + 0.1, $fn=96);
  translate([-plk_clip_mouth/2, 0]) square([plk_clip_mouth, plk_clip_od]);   // mouth
}
module plk_clip() translate([0, 0, plk_groove_z[0] + 0.05]) linear_extrude(plk_clip_t) plk_clip_2d();

// Plug (P frame). Printed lying on the flat at y = -(plug_d/2 - 0.4).
plk_print_flat_y = -(plk_plug_d/2 - 0.4);
module plk_plug() {
  difference() {
    union() {
      translate([0, 0, -plk_flange_t]) cylinder(d=plk_head_d, h=plk_head_t, $fn=96);
      translate([-plk_lug_r, -plk_lug_w/2, -plk_flange_t]) cube([plk_lug_r, plk_lug_w, plk_head_t]);   // lug at P 180 deg
      translate([0, 0, -plk_flange_t + plk_head_t - 0.01]) cylinder(d=plk_plug_d, h=plk_rear_z + 0.2 + plk_flange_t - plk_head_t + 0.01, $fn=96);
      translate([-plk_boss/2, -plk_boss/2, plk_rear_z + 0.2 - 0.01]) cube([plk_boss, plk_boss, crank_t - 0.2 + 0.01]);
    }
    // Keyway.
    translate([-plk_key_top - 0.15, -plk_key_t/2 - 0.15, -plk_flange_t - 0.1]) cube([2*plk_key_top + 0.3, plk_key_t + 0.3, plk_keyway_end + plk_flange_t + 0.1]);
    // Wafer slots and spring pockets.
    for (i = [0:plk_n - 1]) {
      translate([0, 0, plk_slot_z(i) - plk_slot_w/2]) linear_extrude(plk_slot_w) plk_slot_2d();
      for (sy = [-1, 1]) translate([-plk_drop - 0.4, sy*plk_spring_y, plk_slot_z(i)]) rotate([0, 90, 0])
        cylinder(d=plk_pocket_d, h=plk_pocket_top + plk_drop + 0.4, $fn=24);
    }
    // Dimple for the crank's grub screw, and the printing flat.
    translate([0, -plk_boss/2 - 0.05, plk_rear_z + 0.2 + (crank_t - 0.2)/2]) rotate([-90, 0, 0]) cylinder(d=2.0, h=0.85, $fn=16);
    translate([-10, plk_print_flat_y - 10, -5]) cube([20, 10, 40]);
  }
}

// Wafer i (3D, P frame), at shift s along x (0 = flush, -plk_drop = sprung out, + = lifted).
module plk_wafer(i, s=0) translate([s, 0, plk_slot_z(i) - plk_wafer_t/2]) linear_extrude(plk_wafer_t) plk_wafer_2d(plk_cut(i));

// Key (P frame): blade 2 mm thick, bow 3 mm (sharing the blade's bottom face, so it prints flat).
module plk_key() {
  rotate([90, 0, 0]) translate([0, 0, -plk_key_t/2]) linear_extrude(plk_key_t) plk_key_blade_2d();   // blade: y from -1 to +1
  difference() {
    translate([0, plk_key_t/2, 0]) rotate([90, 0, 0]) linear_extrude(3.0)
      offset(r=2, $fn=24) offset(delta=-2) translate([-9, -plk_flange_t - 15]) square([18, 15]);
    translate([0, 0, -plk_flange_t - 11]) rotate([90, 0, 0]) cylinder(d=4.5, h=10, center=true, $fn=24);   // key-ring hole
  }
}

// Crank (P frame, on the boss): crank_template's outline, M3 insert for the pin, grub screw from -y.
module plk_crank() {
  translate([0, 0, plk_rear_z + 0.2]) difference() {
    hull() {
      cylinder(d=crank_hub_d, h=crank_t, $fn=64);
      translate([0, crank_r, 0]) cylinder(d=crank_pin_d + 3.5, h=crank_t, $fn=48);
    }
    translate([0, 0, -0.05]) linear_extrude(crank_t + 0.1) square(plk_boss + 0.15, center=true);
    translate([0, crank_r, -0.05]) cylinder(d=plk_insert_d, h=crank_t + 0.1, $fn=24);
    translate([0, -crank_hub_d/2 - 0.1, crank_t/2]) rotate([-90, 0, 0]) cylinder(d=plk_grub_d, h=crank_hub_d/2 - plk_boss/2 + 0.2, $fn=16);
  }
}

// Picture helper: keep the part in front of wafer 2's middle.
module plk_half() intersection() { children(); translate([-20, -20, -20]) cube([40, 40, 20 + plk_slot_z(1) - 0.2]); }
// Picture helper: one part's outline where a cut across wafer 2 meets it, coloured, at height h.
module plk_slice(c, h) color(c) translate([0, 0, h]) linear_extrude(0.05) projection(cut=true) translate([0, 0, -plk_slot_z(1)]) children();
// Picture-only coil spring (along +z, length len).
module plk_spring(len) for (k = [0:5]) translate([0, 0, k*len/6 + len/12]) rotate_extrude($fn=16) translate([plk_spring_od/2 - 0.12, 0]) circle(d=0.24, $fn=8);

// ------------------------- PLACEMENT --------------------------------
module plk_to_dock() multmatrix([[0, 0, -1, lock_face_x], [-1, 0, 0, lock_y], [0, 1, 0, lock_z], [0, 0, 0, 1]]) children();

// Whole printed lock in the dock frame. key: show the key. drop: wafer shift (0 with the right key in).
module plk_placed(turn=1, key=true) {
  th = plk_theta(turn);
  plk_to_dock() {
    color([0.25, 0.27, 0.3]) plk_body();
    color([0.35, 0.37, 0.4]) plk_clip();
    rotate([0, 0, th]) {
      color([0.85, 0.55, 0.15]) plk_plug();
      color([0.95, 0.8, 0.3]) for (i = [0:plk_n - 1]) plk_wafer(i, key ? 0 : -plk_drop);
      if (key) color([0.2, 0.45, 0.85]) plk_key();
      color([0.75, 0.75, 0.78]) plk_crank();
      color([0.75, 0.75, 0.78]) translate([0, crank_r, plk_rear_z + 0.2]) cylinder(d=crank_pin_d, h=crank_t + 0.5 + yoke_t, $fn=24);   // M3 pin + 4 mm spacer
    }
  }
}

// ------------------------- EXPORTS (print orientation) --------------
PLK_PARTS = ["plock_body", "plock_plug", "plock_wafer", "plock_wafers", "plock_key", "plock_clip", "plock_crank",
             "plock_check_pod", "plock_check_crank", "plock_check_turn", "plock_check_nokey", "plock_check_wrongkey",
             "plock_check_wafers", "plock_check_key", "plock_section", "plock_exploded", "plock_cutaway", "plock_in_pod"];
function plk_is_part(p) = len([for (n = PLK_PARTS) if (n == p) 1]) > 0;
plock_index = 0;                // for PART = "plock_wafer": which wafer (0 = front)
CHECK_TURN = 0.5;               // plock_check_turn: key turn to test (0 = unlocked, 1 = locked)

module plk_part(p) {
  if (p == "plock_body") translate([0, 0, plk_flange_t]) plk_body();                         // flange down
  else if (p == "plock_plug") translate([0, 0, -plk_print_flat_y]) rotate([90, 0, 0]) plk_plug();   // on its flat
  else if (p == "plock_wafer") translate([0, 0, -plk_slot_z(plock_index) + plk_wafer_t/2]) plk_wafer(plock_index);
  else if (p == "plock_wafers") for (i = [0:plk_n - 1]) translate([i*13, 0, -plk_slot_z(i) + plk_wafer_t/2]) plk_wafer(i);
  else if (p == "plock_key") translate([0, 0, plk_key_t/2]) rotate([-90, 0, 0]) plk_key();    // flat, bow's flush face down
  else if (p == "plock_clip") linear_extrude(plk_clip_t) plk_clip_2d();
  else if (p == "plock_crank") translate([0, 0, -plk_rear_z - 0.2]) plk_crank();
  // Pictures: exploded along the axis, and a cut through the wafers (key in, springs shown as coils).
  else if (p == "plock_exploded") rotate([0, 90, 0]) {
    color([0.2, 0.45, 0.85]) translate([0, 0, -22]) plk_key();
    color([0.25, 0.27, 0.3]) plk_body();
    color([0.85, 0.55, 0.15]) translate([0, 0, 30]) plk_plug();
    color([0.95, 0.8, 0.3]) for (i = [0:plk_n - 1]) translate([16, 0, 30 + 4*i]) plk_wafer(i, 0);
    color([0.6, 0.6, 0.62]) for (i = [0:plk_n - 1], sy = [-1, 1]) translate([16 + 1.2, sy*plk_spring_y, 30 + 4*i + plk_slot_z(i)]) rotate([0, 90, 0]) plk_spring(2.6);
    color([0.35, 0.37, 0.4]) translate([0, 0, 62]) plk_clip();
    color([0.75, 0.75, 0.78]) translate([0, 0, 70]) plk_crank();
  }
  else if (p == "plock_cutaway") {                  // slice across wafer 2, key in: each part's outline at the cut
    plk_slice([0.25, 0.27, 0.3], 0) plk_body();
    plk_slice([0.85, 0.55, 0.15], 0.1) plk_plug();
    plk_slice([1.0, 0.82, 0.15], 0.2) plk_wafer(1, 0);
    plk_slice([0.2, 0.45, 0.85], 0.3) plk_key();
    for (sy = [-1, 1]) color([0.55, 0.55, 0.6]) translate([0, sy*plk_spring_y, 0.4]) linear_extrude(0.05)
      for (k = [0:5]) translate([k*plk_pocket_top/6, 0]) rotate(15) square([0.25, plk_spring_od], center=true);
  }
  else if (p == "plock_in_pod") {                   // the lock pod, see-through, with the printed lock, yoke and bolt
    color([0.35, 0.55, 0.85, 0.22]) dock_receiver();
    color([0.55, 0.58, 0.62]) lock_yoke(1);
    lock_bolt(1);
    plk_placed(1);
  }
  // Section through the wafers, for checking the fit.
  else if (p == "plock_section") difference() { plk_placed(1, true); translate([0, lock_y, -50]) cube([200, 50, 100]); }
  // Interference checks: "must be empty" ones print nothing if OK.
  // (They test whichever dock the mount option uses: receiver, or the one-piece dock_base.)
  else if (p == "plock_check_pod")      intersection() { plk_dock(); plk_to_dock() { plk_body(); plk_clip(); } }
  else if (p == "plock_check_crank")    for (t = [0, 0.5, 1]) intersection() {
      union() { plk_dock(); lock_yoke(t); }
      plk_to_dock() rotate([0, 0, plk_theta(t)]) { plk_crank(); translate([0, crank_r, plk_rear_z + 0.2]) cylinder(d=crank_pin_d, h=crank_t, $fn=24); }
    }
  else if (p == "plock_check_turn")     intersection() {          // right key, any turn: plug + wafers clear the body
      plk_body();
      rotate([0, 0, plk_theta(CHECK_TURN)]) { plk_plug(); for (i = [0:plk_n - 1]) plk_wafer(i, 0); }
    }
  else if (p == "plock_check_nokey")    intersection() {          // MUST collide: no key, try to turn 8 deg
      plk_body(); rotate([0, 0, -8]) for (i = [0:plk_n - 1]) plk_wafer(i, -plk_drop);
    }
  else if (p == "plock_check_wrongkey") intersection() {          // MUST collide: each wafer one step off, turned 8 deg
      plk_body(); rotate([0, 0, -8]) for (i = [0:plk_n - 1]) plk_wafer(i, (i % 2 == 0 ? 1 : -1)*plk_step);
    }
  else if (p == "plock_check_wafers")   for (s = [-plk_drop, 0, plk_lift]) intersection() { plk_plug(); for (i = [0:plk_n - 1]) plk_wafer(i, s); }
  else if (p == "plock_check_key")      intersection() { plk_plug(); plk_key(); }
}

module plk_dock() { if (mount == "merged") dock_base(); else dock_receiver(); }

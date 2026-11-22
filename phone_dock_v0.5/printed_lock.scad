/*
  PRINTED LOCK (optional): a push-key lock designed for 3D printing, instead of the store-bought cam lock.
  Included by phone_dock_v0.5.scad (uses its lock pod, bolt and cover variables). See PRINTED_LOCK.md.

  It is not a copy of a store lock. Everything that matters prints flat or upright, in sizes an FDM printer
  holds well: a 3.5 mm card key, 2.4 mm wafers, 1 mm code steps, 0.25 mm clearances. Bought parts: 4 small
  springs. The steel bolt and the strike are unchanged (they carry the load).

  How it works:
    - SHUTTLE: a printed block in a channel in the lock pod, behind a slot (the keyhole) in the side wall.
      Pushing the key in pushes the shuttle 7 mm into the pod; pulling the key back brings it out again.
    - WAFERS: 4 flat wafers ride in the shuttle, each pushed down by a spring onto the key's top edge, so the
      key's cut sets each wafer's height. Each wafer has a tab on its side that runs in a groove in the pod
      wall. The groove only lets a tab through at exactly the right height. With the right key all 4 tabs
      line up and the shuttle moves; with no key (the springs drop the wafers) or a wrong key, a tab hits
      the groove's shoulder and the shuttle can't move.
    - LIFTER: the part that carries the steel bolt (it replaces the yoke). A pin on it runs in a slanted
      track on the shuttle's side: shuttle in = bolt down (unlocked), shuttle out = bolt up (locked).
      Locked, the pin sits on a flat part of the track, so pushing the bolt can't push the shuttle.
    - The key comes out only when locked: at the locked position each tab has a pocket to move into as the
      key's cuts slide past; anywhere else the groove holds the wafers, so the key is held in.

  Frames: S = shuttle frame: x into the pod from the shuttle's front face, z up (dock z), y toward the
  lifter (dock -y). S to dock: a 180-degree turn about z: x -> lock_panel_inner_x - shift - x,
  y -> plk_yc - y, z -> plk_zc + z. Locked: shift = 0 (front face on the panel). Unlocked: shift = plk_S.
*/

// ------------------------- SETTINGS ---------------------------------
lock_type = "store";        // "store" = bought 16 mm cam lock (default); "printed" = this lock. The lock pod's
                            // inside differs, so the receiver / dock_base must be exported for the lock you use.
lock_code = [2, 0, 1, 2];   // CHANGE THIS before printing: one digit 0-2 per wafer, front (keyhole end) to back.
                            // Digit = cut depth in plk_step steps. Avoid all-equal codes like [1,1,1,1].
plk_step = 1.0;             // depth step between digits. 1 mm: forgiving to print, a wrong cut still blocks by 0.75 mm

// Travel: the shuttle moves plk_S; the bolt drops by the same 7 mm as with the store lock.
plk_S = 7.0;
plk_rise = crank_r;                                 // bolt travel (7)
plk_dwell = 1.2;                                    // flat at each end of the track (locked one: no back-drive)
plk_L = lock_panel_inner_x - (pod_high_x0 + 1.2) - plk_S;   // shuttle length: fills the channel less the travel

// Key and wafers (S frame).
plk_key_t = 3.5;                    // card key thickness (prints flat)
plk_kt = 3.5;                       // uncut top edge (cuts go down from here)
plk_kb = -3.5;                      // bottom edge
plk_shoulder = 2.0;                 // the key's shoulder (below the blade) pushes the shuttle's front face
plk_tip_low = -0.2;                 // key tip height: under the dropped wafers' windows
plk_wt = 2.4;                       // wafer thickness (prints flat)
plk_wslot = plk_wt + 0.3;           // its slot in the shuttle
plk_pitch = 4.0;
plk_front = 1.5;                    // shuttle front wall
plk_n = len(lock_code);
plk_drop = 1.3;                     // how far a spring drops a wafer with no key
plk_lift = 2*plk_step;              // most the key lifts a wafer above its level (uncut key over a 2-cut wafer)
plk_win_hw = plk_key_t/2 + 0.25;    // key window half-width
plk_win_bot = plk_kb - plk_lift - 0.3;
plk_wz0 = plk_win_bot - 1.5;        // wafer bottom (flush)
plk_wz1 = plk_kt + 1.5;             // wafer top (flush)
plk_wy_tab = -4.8;                  // wafer edge on the tab side (S frame: -y = dock +y, away from the lifter)
plk_wy_pin = 3.5;                   // wafer edge on the lifter side
plk_tab_h = 2.0;                    // tab height; the pod groove is this + 2 x plk_gclear
plk_tab_p = 1.4;                    // how far the tab sticks out of the shuttle
plk_gclear = 0.25;                  // tab in the pod groove, per side
plk_spring_len = 5.5;               // spring length with the wafer level (3 mm OD springs, see PRINTED_LOCK.md)
plk_spring_od = 3.0;
plk_pocket_d = 3.3;
plk_sy_tab = -5.0;                  // shuttle's tab-side face
plk_sy_pin = 7.65;                  // shuttle's lifter-side face (its track is cut into this 4.15 mm wall)
plk_sz0 = plk_wz0 - plk_drop - 1.5; // shuttle bottom (sits on the lock cover)
plk_slot_z0 = plk_wz0 - plk_drop;   // wafer slot floor = the drop stop
plk_slot_z1 = plk_wz1 + plk_lift + 0.2;
plk_pocket_top = plk_wz1 + plk_spring_len;
plk_sz1 = plk_pocket_top + 0.8;     // shuttle top
// Lifter pin and its track.
plk_pin_d = 3.5;
plk_track_r = plk_pin_d/2 + 0.2;
plk_track_depth = 2.2;
plk_pin_z = -14;                    // dock frame, locked
plk_a = plk_L - 3.2;                // pin's place along the shuttle when locked (S x)
plk_lifter_y = [pod_y0 + 2.0, pod_y0 + 6.0];       // lifter plate (dock y), beside the shuttle

// Placement (dock frame).
plk_zc = pod_bottom_z + lock_cover_t - 0.1 - plk_sz0;   // shuttle sits on the lock cover (printed 0.1 thinner than its recess)
plk_yc = plk_lifter_y[1] + 0.5 + plk_sy_pin;        // 0.5 mm between lifter plate and shuttle
plk_pin_x = lock_panel_inner_x - plk_a;
plk_zr = plk_pin_z - plk_zc;                        // pin height in the S frame when locked
plk_plate_x0 = pod_high_x0 + 1.5;
plk_plate_top = plk_pin_z + plk_pin_d/2 + 2;
plk_drain_x = lock_panel_inner_x - 4;               // the lock cover's drain under the shuttle

function plk_wx(i) = plk_front + plk_wslot/2 + i*plk_pitch;   // wafer i centre (S x)
function plk_cut(i) = lock_code[i]*plk_step;
function plk_shift(turn) = plk_S*(1 - turn);                  // turn: 1 = locked, 0 = unlocked
function plk_dz_s(s) = s <= plk_dwell ? 0 : s >= plk_S - plk_dwell ? -plk_rise
                     : -plk_rise*(s - plk_dwell)/(plk_S - 2*plk_dwell);
function plk_dz(turn) = plk_dz_s(plk_shift(turn));

// ------------------------- CHECKS -----------------------------------
assert(min(lock_code) >= 0 && max(lock_code) <= 2, "lock_code digits must be 0, 1 or 2.");
assert(plk_wx(plk_n - 1) + plk_wslot/2 + 1.5 <= plk_L, "Wafers don't fit the shuttle: fewer wafers or a smaller pitch.");
assert(plk_pitch - plk_pocket_d >= 0.6, "Spring pockets of neighbouring wafers break into each other.");
assert(plk_kt - 2*plk_step - plk_drop - plk_tip_low >= 0.3, "Key tip can't get under a dropped wafer.");
assert(plk_win_hw - plk_key_t/2 >= 0.2, "Key window too tight.");
assert(plk_step - plk_gclear >= 0.6, "A one-step wrong cut would not block: raise plk_step or tighten plk_gclear.");
assert(plk_drop - plk_gclear >= 0.6, "A dropped wafer (no key) would not block.");
assert(plk_pocket_top - (plk_wz1 + plk_lift) >= 3.2, "Springs squashed under 3.2 mm at full lift (9-coil 0.3 mm wire springs are 2.7 mm solid).");
assert(plk_sy_pin - plk_track_depth - (plk_wy_pin + 0.15) >= 1.5, "Track breaks into the wafer slots.");
assert(plk_a + 0.3 + plk_track_r <= plk_L - 0.4 && plk_a - plk_S - 0.3 - plk_track_r >= 0.4, "Track runs off the shuttle.");
assert(plk_zr + plk_track_r <= plk_sz1 - 0.5 && plk_zr - plk_rise - plk_track_r >= plk_sz0 + 0.5, "Track runs off the shuttle's height.");
assert(plk_S >= plk_wt + 2*plk_gclear + 0.5, "Unlocked, the innermost wafer would still be in its pocket: the key could come out.");   // no pocket lies further in
assert(plk_zc + plk_sz1 + 0.2 <= pod_top_z - 1.2, "Shuttle channel breaks the top of the pod.");
assert(plk_yc - plk_sy_tab + plk_tab_p + 0.3 + plk_gclear <= pod_y1 - 1.2, "Tab groove breaks the pod's side wall.");
assert(plk_lifter_y[0] - 0.3 >= pod_y0 + 1.2, "Lifter pocket breaks the pod's side wall.");
assert(plk_lifter_y[0] >= bolt_y - arm_wy/2 && plk_lifter_y[1] <= bolt_y + arm_wy/2, "Lifter plate must join the bolt arm.");
assert(plk_plate_top + 0.5 <= pod_top_z - 1.2, "Lifter pocket breaks the top of the pod.");
assert(yoke_bottom_locked - plk_rise >= pod_bottom_z + lock_cover_t + 0.3, "Unlocked lifter hits the lock cover.");
assert(abs(lock_panel_inner_x - plk_S - plk_L - (pod_high_x0 + 1.2)) < 0.01, "Fully pushed, the shuttle should just reach the channel's end (its stop).");
assert(plk_zc + plk_kb - plk_shoulder - 0.25 >= pod_bottom_z + lock_cover_t + 0.5, "Keyhole runs into the lock cover.");
echo(printed_lock_code = lock_code, shuttle_len = plk_L, spring_length_range = [plk_pocket_top - plk_wz1 - plk_lift, plk_pocket_top - plk_wz1 + plk_drop]);

// ------------------------- PARTS (S frame) --------------------------
// One wafer (flush), as a 2D profile in (y, z).
module plk_wafer_2d(cut) difference() {
  union() {
    translate([plk_wy_tab, plk_wz0]) square([plk_wy_pin - plk_wy_tab, plk_wz1 - plk_wz0]);
    translate([plk_wy_tab - plk_tab_p - (-plk_sy_tab + plk_wy_tab), -plk_tab_h/2]) square([plk_tab_p - plk_sy_tab + plk_wy_tab + 0.01, plk_tab_h]);
  }
  translate([-plk_win_hw, plk_win_bot]) square([2*plk_win_hw, plk_kt - cut - plk_win_bot]);
  // Chamfer the top corners so the wafer slides in under its spring.
  for (sy = [0, 1]) translate([sy == 0 ? plk_wy_tab : plk_wy_pin, plk_wz1]) rotate(45) square(1.0, center=true);
}
// Wafer i at height s (0 = level, -plk_drop = dropped, + = lifted).
module plk_wafer(i, s=0) translate([plk_wx(i) - plk_wt/2, 0, s]) rotate([90, 0, 90]) linear_extrude(plk_wt) plk_wafer_2d(plk_cut(i));

// The pin's path along the shuttle's side (x, z in the S frame) as the shuttle moves 0 -> plk_S.
function plk_track_pts() = [[plk_a + 0.3, plk_zr], [plk_a - plk_dwell, plk_zr],
                            [plk_a - plk_S + plk_dwell, plk_zr - plk_rise], [plk_a - plk_S - 0.3, plk_zr - plk_rise]];

module plk_shuttle() {
  difference() {
    translate([0, plk_sy_tab, plk_sz0]) cube([plk_L, plk_sy_pin - plk_sy_tab, plk_sz1 - plk_sz0]);
    // Keyway, through.
    translate([-0.1, -plk_key_t/2 - 0.2, plk_kb - 0.2]) cube([plk_L + 0.2, plk_key_t + 0.4, plk_kt - plk_kb + 0.4]);
    for (i = [0:plk_n - 1]) {
      // Wafer slot: open on the tab side, so the wafer slides in from the side.
      translate([plk_wx(i) - plk_wslot/2, plk_sy_tab - 1, plk_slot_z0]) cube([plk_wslot, plk_wy_pin + 0.15 - plk_sy_tab + 1, plk_slot_z1 - plk_slot_z0]);
      // Spring pocket above the wafer.
      translate([plk_wx(i), 0, plk_slot_z1 - 0.05]) cylinder(d=plk_pocket_d, h=plk_pocket_top - plk_slot_z1 + 0.05, $fn=24);
    }
    // Slanted track for the lifter's pin, and its entry from the top (the lifter's arm stops it climbing out).
    p = plk_track_pts();
    translate([0, plk_sy_pin + 0.01, 0]) rotate([90, 0, 0]) linear_extrude(plk_track_depth + 0.01) {
      for (k = [0:len(p) - 2]) hull() { translate(p[k]) circle(r=plk_track_r, $fn=32); translate(p[k + 1]) circle(r=plk_track_r, $fn=32); }
      translate([plk_a - plk_track_r, plk_zr]) square([2*plk_track_r, plk_sz1 - plk_zr + 1]);
    }
  }
}

// Key: card, cut on its top edge (x, z profile; y = thickness).
module plk_key_2d() {
  e = [for (i = [0:plk_n - 1]) plk_kt - plk_cut(i)];
  half = plk_wt/2 + 0.15;
  x_last = plk_wx(plk_n - 1) + half;
  x_tip = min(plk_L - 0.2, x_last + (e[plk_n - 1] - plk_tip_low)/tan(60));
  bow_x = -(lock_panel_t + plk_S + 1);
  top = concat([[bow_x, plk_kt], [plk_wx(0) - half - 0.6, plk_kt]],
               [for (i = [0:plk_n - 1]) each [[plk_wx(i) - half, e[i]], [plk_wx(i) + half, e[i]]]],
               [[x_tip, plk_tip_low]]);
  union() {
    polygon(concat(top, [[x_tip, plk_kb + 0.8], [x_tip - 0.8, plk_kb], [0, plk_kb], [0, plk_kb - plk_shoulder], [bow_x, plk_kb - plk_shoulder]]));
    // Bow, outside the side wall.
    difference() {
      translate([bow_x - 20, plk_kb - plk_shoulder - 8]) offset(r=4, $fn=32) offset(delta=-4) square([20.01, plk_kt - plk_kb + plk_shoulder + 14]);
      translate([bow_x - 13, (plk_kt + plk_kb - plk_shoulder)/2]) circle(d=5, $fn=32);   // key-ring hole
    }
  }
}
module plk_key() rotate([90, 0, 0]) translate([0, 0, -plk_key_t/2]) linear_extrude(plk_key_t) plk_key_2d();

// ------------------------- PARTS (dock frame) -----------------------
// Lifter: carries the steel bolt (replaces the yoke). turn: 1 = locked, 0 = unlocked.
module plk_lifter(turn=1) {
  translate([0, 0, plk_dz(turn)]) difference() {
    union() {
      translate([bolt_x - arm_wx/2, bolt_y - arm_wy/2, yoke_bottom_locked]) cube([pod_high_x0 + 0.9 - bolt_x + arm_wx/2, arm_wy, arm_h]);   // arm
      translate([pod_high_x0 - 1.6, plk_lifter_y[0], yoke_bottom_locked]) cube([plk_plate_x0 + 1 - pod_high_x0 + 1.6, plk_lifter_y[1] - plk_lifter_y[0], arm_h]);   // link, under the roof
      translate([plk_plate_x0, plk_lifter_y[0], yoke_bottom_locked]) cube([plk_pin_x + 3.5 - plk_plate_x0, plk_lifter_y[1] - plk_lifter_y[0], plk_plate_top - yoke_bottom_locked]);  // plate
      translate([plk_pin_x, plk_lifter_y[1] - 0.01, plk_pin_z]) rotate([-90, 0, 0]) cylinder(d=plk_pin_d, h=0.5 + plk_track_depth - 0.2 + 0.01, $fn=32);   // pin
    }
    // Bolt press-fit pocket (rectangular, for the key-steel bolt).
    translate([bolt_x - (bolt_w - 0.1)/2, bolt_y - (bolt_t - 0.1)/2, yoke_bottom_locked - 0.05]) cube([bolt_w - 0.1, bolt_t - 0.1, arm_h + 0.1]);
  }
}

module plk_to_dock(s=0) translate([lock_panel_inner_x - s, plk_yc, plk_zc]) rotate([0, 0, 180]) children();

// Cuts in the lock pod for this lock (called from lock_pod_cuts in the main file).
module plk_pod_cuts() {
  x_ch0 = pod_high_x0 + 1.2;
  // Shuttle channel, open underneath (closed by the lock cover).
  translate([x_ch0, plk_yc - plk_sy_pin - 0.2, pod_bottom_z - 1]) cube([lock_panel_inner_x + 0.05 - x_ch0, plk_sy_pin - plk_sy_tab + 0.4, plk_zc + plk_sz1 + 0.2 - pod_bottom_z + 1]);
  // Lifter plate pocket (full travel), open underneath.
  translate([x_ch0, plk_lifter_y[0] - 0.3, pod_bottom_z - 1]) cube([plk_pin_x + 3.8 - x_ch0, plk_lifter_y[1] - plk_lifter_y[0] + 0.6, plk_plate_top + 0.5 - pod_bottom_z + 1]);
  // Tab groove in the channel's side wall: the tabs can only pass at the right height...
  y_g0 = plk_yc - plk_sy_tab + 0.1;
  y_g1 = plk_yc - plk_sy_tab + plk_tab_p + 0.3;
  gx0 = lock_panel_inner_x - plk_wx(plk_n - 1) - plk_wt/2 - plk_gclear - plk_S - 0.3;
  translate([gx0, y_g0, plk_zc - plk_tab_h/2 - plk_gclear]) cube([lock_panel_inner_x - plk_wx(0) + plk_wt/2 + plk_gclear - gx0, y_g1 - y_g0, plk_tab_h + 2*plk_gclear]);
  // ...except in a pocket at each wafer's locked position (the key goes in and out there). Each pocket runs
  // down to the pod's underside, so the shuttle goes in from below with the tabs in place.
  for (i = [0:plk_n - 1]) translate([lock_panel_inner_x - plk_wx(i) - plk_wt/2 - plk_gclear, y_g0, pod_bottom_z - 1])
    cube([plk_wt + 2*plk_gclear, y_g1 - y_g0, plk_zc + plk_tab_h/2 + plk_lift + 0.3 - pod_bottom_z + 1]);
  // Keyhole: a slot through the side wall.
  translate([lock_panel_inner_x - 0.05, plk_yc - plk_key_t/2 - 0.25, plk_zc + plk_kb - plk_shoulder - 0.25])
    cube([lock_face_x - lock_panel_inner_x + 0.2, plk_key_t + 0.5, plk_kt - plk_kb + plk_shoulder + 0.5]);
}

// Whole printed lock in the dock frame (turn 1 = locked, 0 = unlocked; the key is in).
module plk_placed(turn=1, key=true) {
  s = plk_shift(turn);
  plk_to_dock(s) {
    color([0.85, 0.55, 0.15]) plk_shuttle();
    color([0.95, 0.8, 0.3]) for (i = [0:plk_n - 1]) plk_wafer(i, key ? 0 : -plk_drop);
    if (key) color([0.2, 0.45, 0.85]) plk_key();
  }
  color([0.55, 0.58, 0.62]) plk_lifter(turn);
}

// Picture helper: one part's outline where the plane x = xc cuts it, drawn flat as (dock y, dock z) at height h.
module plk_xslice(c, h, xc) color(c) translate([0, 0, h]) linear_extrude(0.05)
  multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0]]) projection(cut=true) rotate([0, 90, 0]) translate([-xc, 0, 0]) children();

module plk_dock() { if (mount == "merged") dock_base(); else dock_receiver(); }

// ------------------------- EXPORTS (print orientation) --------------
PLK_PARTS = ["plock_shuttle", "plock_wafer", "plock_wafers", "plock_key", "plock_lifter", "plock_cover", "plock_dock",
             "plock_check_pod", "plock_check_cover", "plock_check_parts", "plock_check_pin", "plock_check_nokey",
             "plock_check_wrongkey", "plock_check_keyout", "plock_check_backdrive", "plock_exploded", "plock_cutaway"];
function plk_is_part(p) = len([for (n = PLK_PARTS) if (n == p) 1]) > 0;
plock_index = 0;                // for PART = "plock_wafer": which wafer (0 = front)

module plk_moving(turn) { plk_placed(turn); }

module plk_part(p) {
  if (p == "plock_shuttle") translate([0, 0, -plk_sz0]) plk_shuttle();                           // bottom down
  else if (p == "plock_wafer") rotate([0, -90, 0]) translate([-plk_wx(plock_index) + plk_wt/2, 0, 0]) plk_wafer(plock_index);   // flat
  else if (p == "plock_wafers") for (i = [0:plk_n - 1]) translate([0, i*16, 0]) rotate([0, -90, 0]) translate([-plk_wx(i) + plk_wt/2, 0, 0]) plk_wafer(i);
  else if (p == "plock_key") translate([0, 0, plk_key_t/2]) rotate([-90, 0, 0]) plk_key();       // flat
  else if (p == "plock_lifter") translate([0, 0, -yoke_bottom_locked]) plk_lifter(1);           // bottom down
  else if (p == "plock_cover") translate([0, 0, -pod_bottom_z]) lock_cover();
  else if (p == "plock_dock") plk_dock();                                                       // the dock with this lock's pod
  // Interference checks. "Must be empty" ones print nothing if OK; "must collide" ones must give a solid.
  else if (p == "plock_check_pod")      for (t = [0, 0.25, 0.5, 0.75, 1]) intersection() { plk_dock(); plk_moving(t); }   // empty / touch
  else if (p == "plock_check_cover")    for (t = [0, 1]) intersection() { lock_cover(); plk_moving(t); }                    // touch (it sits on the cover)
  else if (p == "plock_check_parts")    {                                                                                  // empty / touch
      for (s = [-plk_drop, 0, plk_lift]) intersection() { plk_shuttle(); for (i = [0:plk_n - 1]) plk_wafer(i, s); }
      intersection() { plk_shuttle(); plk_key(); }
      intersection() { plk_key(); for (i = [0:plk_n - 1]) plk_wafer(i, 0); }
    }
  else if (p == "plock_check_pin")      for (t = [0, 0.2, 0.4, 0.6, 0.8, 1]) intersection() { plk_to_dock(plk_shift(t)) plk_shuttle(); plk_lifter(t); }   // empty
  else if (p == "plock_check_nokey")    intersection() { plk_dock(); plk_to_dock(0.5) for (i = [0:plk_n - 1]) plk_wafer(i, -plk_drop); }        // MUST collide
  else if (p == "plock_check_wrongkey") intersection() { plk_dock(); plk_to_dock(0.5) for (i = [0:plk_n - 1]) plk_wafer(i, (i % 2 == 0 ? 1 : -1)*plk_step); }   // MUST collide
  else if (p == "plock_check_keyout")   intersection() { plk_dock(); plk_to_dock(plk_S) for (i = [0:plk_n - 1]) plk_wafer(i, plk_step); }       // MUST collide
  else if (p == "plock_check_backdrive") intersection() { plk_to_dock(0) plk_shuttle(); translate([0, 0, -0.5]) plk_lifter(1); }           // MUST collide
  // Pictures.
  else if (p == "plock_exploded") {
    color([0.2, 0.45, 0.85]) translate([0, 0, 0]) plk_key();
    color([0.85, 0.55, 0.15]) translate([45, 0, 0]) plk_shuttle();
    color([0.95, 0.8, 0.3]) for (i = [0:plk_n - 1]) translate([45, -14, 0]) plk_wafer(i, 0);
    color([0.6, 0.6, 0.62]) for (i = [0:plk_n - 1]) translate([45 + plk_wx(i), 0, plk_pocket_top + 8])
      for (k = [0:7]) translate([0, 0, k*0.7]) rotate_extrude($fn=16) translate([plk_spring_od/2 - 0.15, 0]) circle(d=0.3, $fn=8);
  }
  else if (p == "plock_cutaway") {                  // slices through wafer 2 (key in, locked), seen from the keyhole side
    xc = lock_panel_inner_x - plk_wx(1);
    plk_xslice([0.62, 0.7, 0.82], 0, xc) plk_dock();
    plk_xslice([0.85, 0.55, 0.15], 0.1, xc) plk_to_dock(0) plk_shuttle();
    plk_xslice([1.0, 0.82, 0.15], 0.2, xc) plk_to_dock(0) plk_wafer(1, 0);
    plk_xslice([0.2, 0.45, 0.85], 0.3, xc) plk_to_dock(0) plk_key();
    color([0.6, 0.6, 0.62]) translate([plk_yc, plk_zc + plk_wz1 + plk_spring_len/2, 0.5]) square([plk_spring_od, plk_spring_len], center=true);
  }
}

/*
  KEYPAD LOCK (DEMO): an electronic dial lock in its own lock cartridge, instead of the store or printed lock.
  Included by phone_dock_v0.5.scad (uses its lock bay, bolt, arm pocket and cover). See KEYPAD_LOCK.md.
  lock_type = "keypad" picks it. A demo / concept: not weatherproofed, and it needs the bike's 5 V to open.

  How it works:
    - KNOB: a rotary encoder (EC11, with a push switch) behind the cartridge's face plate, with a printed knob.
      Dial the code like a safe: turn right to the 1st number, left to the 2nd, right to the 3rd. A small
      ATtiny85 board reads it (keypad_lock/keypad_lock.ino) and, if it is right, turns the servo: unlocked.
      PRESS the knob to lock.
    - SERVO: a 3.7 g class micro servo, lying on the lock cover with its shaft pointing back (-x). Its horn is
      the crank: a pin at 7 mm radius in a horizontal slot in the lifter (a scotch yoke, as with the store lock).
      Pin pointing up = bolt up (locked), at top dead centre: pushing the bolt down can't turn the servo.
    - LIFTER: carries the same steel bolt on the same arm as the store lock's yoke.

  Frame: dock frame. Everything follows the lock bay (pod_y0, lock_y, cart_z0), so it fits both mounts.
*/

// ------------------------- SETTINGS ---------------------------------
// SELECT: micro servo, 3.7 g class (e.g. "3.7g micro servo"). Cut off its mounting tabs: the cartridge holds it.
kp_srv_l = 20.0;            // SELECT: body length (lies along dock y); the shaft is near one end
kp_srv_w = 8.5;             // SELECT: body thickness (dock z)
kp_srv_h = 17.5;            // SELECT: body height, shaft face to bottom (dock x)
kp_srv_shaft_off = 5.0;     // SELECT: shaft axis from the body's near end
kp_srv_spline = 3.0;        // SELECT: body's shaft face to the horn's back face (gear tower + spline)
kp_horn_t = 1.5;            // horn: printed, or the servo's own single-arm horn cut to 7 mm
kp_pin_d = 2.0;             // crank pin: an M2 screw through the horn
// SELECT: EC11 rotary encoder with push switch, 20 detents, 6 mm D shaft, M7 bushing.
kp_enc_wy = 12.4;           // body width
kp_enc_hz = 13.4;           // body height
kp_enc_body = 6.8;          // body depth behind the panel
kp_enc_pins = 4.0;          // pins behind the body
kp_enc_bush_d = 7.0;        // threaded bushing (M7)
kp_enc_shaft_d = 6.0;
kp_knob_d = 14;             // printed knob
kp_knob_h = 9;
kp_knob_gap = 2.5;          // face of the side wall to the knob (the encoder's nut sits here)
kp_board = [8.5, 16, 13.8]; // ATtiny85 board with its socket and parts (x depth, y, z); sits on the servo

// ------------------------- DERIVED (dock frame) ---------------------
kp_r = crank_r;                                   // crank radius = bolt travel (7)
kp_plate_x0 = yoke_x0;                            // lifter plate, where the store lock's yoke is
kp_plate_x1 = kp_plate_x0 + 2.5;
kp_horn_x0 = kp_plate_x1 + 0.3;
kp_horn_x1 = kp_horn_x0 + kp_horn_t;
kp_srv_x0 = kp_horn_x1 + kp_srv_spline;          // servo's shaft face
kp_srv_x1 = kp_srv_x0 + kp_srv_h;
kp_srv_y0 = bay_y0 + cart_clear + 0.2;           // servo body, near end
kp_ys = kp_srv_y0 + kp_srv_shaft_off;            // shaft axis
kp_zs = cart_z0 + kp_srv_w/2;                    // servo lies on the lock cover
kp_slot_z = kp_zs + kp_r;                        // slot centre, locked (pin straight up)
kp_plate_top = kp_slot_z + kp_pin_d/2 + 0.2 + 2;
kp_plate_y = [kp_ys - 3, kp_ys + kp_r + 3];
kp_enc_y = lock_y;
kp_enc_z = kp_zs + kp_srv_w/2 + 0.6 + kp_enc_hz/2;   // just above the servo
kp_board_x0 = kp_horn_x1 + 0.6;
kp_cable = [kp_board_x0 + 1.2, kp_ys + kp_r + 6];   // cable channel down to the lock cover's hole (2-core, 5 V)

// ------------------------- CHECKS -----------------------------------
assert(kp_srv_x1 <= lock_panel_inner_x - 0.05, "Servo too long for the bay: choose a shorter servo (kp_srv_h).");
assert(kp_srv_y0 + kp_srv_l <= bay_y1 - cart_clear - 0.5, "Servo too long across the bay (kp_srv_l).");
assert(kp_plate_y[0] >= bolt_y - arm_wy/2 && kp_plate_y[1] <= bolt_y + arm_wy/2, "Lifter plate must join the bolt arm.");
assert(kp_plate_top + 0.5 <= bay_top_z - cart_clear - 1.0, "Lifter breaks the top of the cartridge.");
assert(yoke_bottom_locked - kp_r >= pod_bottom_z + lock_cover_t + 0.3, "Unlocked lifter hits the lock cover.");
assert(kp_zs - 3.2 >= cart_z0, "Horn hub hits the lock cover.");
assert(kp_enc_z + kp_enc_hz/2 <= bay_top_z - cart_clear - 1.0, "Encoder breaks the top of the cartridge.");
assert(abs(kp_enc_y - lock_y) + kp_enc_bush_d/2 + 1.2 <= notch_hw - cart_clear && kp_enc_z + kp_enc_bush_d/2 + 1.2 <= notch_top_z - cart_clear,
       "Encoder bushing breaks out of the face plate.");
assert(lock_panel_inner_x - kp_enc_body - kp_enc_pins >= kp_board_x0 + kp_board[0] + 0.3, "Encoder pins run into the board.");
assert(kp_board_x0 + kp_board[0] <= kp_srv_x1 && kp_enc_z - kp_enc_hz/2 >= kp_zs + kp_srv_w/2 + 0.5, "Encoder sits on the servo.");
assert(kp_board[2] + 0.2 <= kp_enc_z + kp_enc_hz/2 + 0.2 - (kp_zs + kp_srv_w/2), "Board taller than its cavity.");
echo(keypad_servo_x = [kp_srv_x0, kp_srv_x1], keypad_shaft = [kp_ys, kp_zs]);

// ------------------------- CUTS (in the cartridge) ------------------
module kp_cuts() {
  // Lifter pocket (full travel), open underneath, where the store lock's yoke pocket is.
  translate([bay_x0 - 0.05, kp_plate_y[0] - 0.3, pod_bottom_z - 1])
    cube([kp_plate_x1 + 0.3 - bay_x0 + 0.05, kp_plate_y[1] - kp_plate_y[0] + 0.6, kp_plate_top + 0.5 - pod_bottom_z + 1]);
  // Horn sweep (a quarter turn, pin from +y to up) and the gear tower, open underneath for assembly.
  translate([kp_horn_x0 - 0.3, 0, 0]) hull() {
    translate([0, kp_ys, kp_zs]) rotate([0, 90, 0]) cylinder(r=kp_r + 2.6, h=kp_srv_x0 - kp_horn_x0 + 0.5);
    translate([0, kp_ys - kp_r - 2.6, pod_bottom_z - 1]) cube([kp_srv_x0 - kp_horn_x0 + 0.5, 2*(kp_r + 2.6), 1]);
  }
  // Servo pocket, open underneath (the cover holds the servo up).
  translate([kp_srv_x0 - 0.2, kp_srv_y0 - 0.2, pod_bottom_z - 1]) cube([lock_panel_inner_x + 0.05 - kp_srv_x0 + 0.2, kp_srv_l + 0.4, kp_zs + kp_srv_w/2 + 0.2 - pod_bottom_z + 1]);
  // Encoder (body and pins) and the board above the servo: one cavity, open down into the servo pocket.
  translate([kp_board_x0, kp_enc_y - kp_board[1]/2 - 0.2, kp_zs + kp_srv_w/2]) cube([lock_panel_inner_x + 0.05 - kp_board_x0, kp_board[1] + 0.4, kp_enc_z + kp_enc_hz/2 + 0.2 - kp_zs - kp_srv_w/2]);
  // Bushing hole through the face plate, and the encoder's anti-rotation lug.
  translate([lock_panel_inner_x - 0.1, kp_enc_y, kp_enc_z]) rotate([0, 90, 0]) cylinder(d=kp_enc_bush_d + 0.3, h=lock_panel_t + 0.3, $fn=32);
  translate([lock_panel_inner_x - 0.1, kp_enc_y - 0.7, kp_enc_z + 5.6]) cube([1.6, 1.4, 1.9]);
  // Cable channel down to the lock cover's cable hole.
  translate([kp_cable[0], kp_cable[1], pod_bottom_z - 1]) cylinder(d=2.6, h=kp_enc_z - pod_bottom_z + 1, $fn=16);
}

// ------------------------- PARTS ------------------------------------
// Lifter: carries the steel bolt on the yoke's arm; a horizontal slot for the horn's pin. turn: 1 = locked.
module kp_lifter(turn=1) {
  translate([0, 0, yoke_dz(turn)]) difference() {
    union() {
      translate([bolt_x - arm_wx/2, bolt_y - arm_wy/2, yoke_bottom_locked]) cube([kp_plate_x0 + 0.5 - bolt_x + arm_wx/2, arm_wy, arm_h]);   // arm
      translate([kp_plate_x0, kp_plate_y[0], yoke_bottom_locked]) cube([kp_plate_x1 - kp_plate_x0, kp_plate_y[1] - kp_plate_y[0], kp_plate_top - yoke_bottom_locked]);
    }
    translate([kp_plate_x0 - 0.1, kp_ys - kp_pin_d/2 - 0.3, kp_slot_z - kp_pin_d/2 - 0.2]) cube([kp_plate_x1 - kp_plate_x0 + 0.2, kp_r + kp_pin_d + 0.6, kp_pin_d + 0.4]);
    translate([bolt_x - (bolt_w - 0.1)/2, bolt_y - (bolt_t - 0.1)/2, yoke_bottom_locked - 0.05]) cube([bolt_w - 0.1, bolt_t - 0.1, arm_h + 0.1]);
  }
}

// Horn + pin, on the servo shaft. turn: 1 = locked (pin up), 0 = unlocked (pin toward +y).
module kp_horn(turn=1) {
  a = 90*turn;
  translate([kp_horn_x0, kp_ys, kp_zs]) rotate([a, 0, 0]) {
    rotate([0, 90, 0]) linear_extrude(kp_horn_t) hull() { circle(d=6, $fn=24); translate([0, kp_r]) circle(d=4, $fn=24); }
    translate([0, kp_r, 0]) rotate([0, -90, 0]) cylinder(d=kp_pin_d, h=kp_horn_x0 - kp_plate_x0 - 0.2, $fn=16);
  }
}
// Printed horn, flat (for PART = "kp_horn"); the M2 pin screw is bought.
module kp_horn_print() difference() {
  linear_extrude(kp_horn_t) hull() { circle(d=6, $fn=24); translate([kp_r, 0]) circle(d=4, $fn=24); }
  translate([0, 0, -0.1]) cylinder(d=2.2, h=kp_horn_t + 0.2, $fn=16);                    // horn screw
  translate([kp_r, 0, -0.1]) cylinder(d=kp_pin_d - 0.3, h=kp_horn_t + 0.2, $fn=16);      // M2 pin, self-tapping
}

// Printed knob for the encoder's 6 mm D shaft (flat at 4.5 mm), with a pointer.
module kp_knob() difference() {
  union() {
    cylinder(d=kp_knob_d, h=kp_knob_h, $fn=48);
    for (k = [0:17]) rotate(20*k + 10) translate([kp_knob_d/2 - 0.2, 0, 0]) cylinder(d=1.2, h=kp_knob_h, $fn=8);   // grip
  }
  translate([0, 0, -0.1]) intersection() { cylinder(d=kp_enc_shaft_d + 0.2, h=7.1, $fn=32); translate([-4, -2.25 - 0.1, 0]) cube([8, 4.5 + 0.2 + 3, 7.2]); }
  translate([0, kp_knob_d/2 - 2.2, kp_knob_h - 0.6]) cylinder(d=1.4, h=1, $fn=12);   // pointer dot
}

// Visual only: servo, encoder, knob, board.
module kp_visuals() {
  color([0.15, 0.3, 0.75]) translate([kp_srv_x0, kp_srv_y0, kp_zs - kp_srv_w/2]) cube([kp_srv_h, kp_srv_l, kp_srv_w]);
  color([0.9, 0.9, 0.9]) translate([kp_srv_x0 - kp_srv_spline, kp_ys, kp_zs]) rotate([0, 90, 0]) cylinder(d=4.5, h=kp_srv_spline, $fn=24);
  color([0.25, 0.25, 0.27]) translate([lock_panel_inner_x - kp_enc_body, kp_enc_y - kp_enc_wy/2, kp_enc_z - kp_enc_hz/2]) cube([kp_enc_body, kp_enc_wy, kp_enc_hz]);
  color([0.75, 0.75, 0.78]) translate([lock_panel_inner_x, kp_enc_y, kp_enc_z]) rotate([0, 90, 0]) {
    cylinder(d=kp_enc_bush_d, h=lock_panel_t + kp_knob_gap, $fn=24);
    cylinder(d=kp_enc_shaft_d, h=lock_panel_t + kp_knob_gap + 7, $fn=24);
  }
  color([0.18, 0.18, 0.2]) translate([lock_face_x + kp_knob_gap, kp_enc_y, kp_enc_z]) rotate([0, 90, 0]) kp_knob();
  color([0.2, 0.5, 0.25]) translate([kp_board_x0 + 0.3, kp_enc_y - kp_board[1]/2, kp_zs + kp_srv_w/2 + 0.1]) cube([1.6, kp_board[1], kp_board[2]]);
  color([0.12, 0.12, 0.12]) translate([kp_board_x0 + 1.9, kp_enc_y - 4, kp_zs + kp_srv_w/2 + 2]) cube([4.5, 8, 9.5]);   // ATtiny85 in its socket
}

module kp_placed(turn=1) {
  color([0.55, 0.58, 0.62]) kp_lifter(turn);
  color([0.9, 0.9, 0.92]) kp_horn(turn);
  kp_visuals();
}

// ------------------------- EXPORTS ----------------------------------
KP_PARTS = ["kp_lifter", "kp_horn", "kp_knob", "kp_check_cart", "kp_check_dock", "kp_check_pin", "kp_check_cover", "kp_exploded"];
function kp_is_part(p) = len([for (n = KP_PARTS) if (n == p) 1]) > 0;
module kp_dock() { if (mount == "merged") dock_base(); else dock_receiver(); }
module kp_moving(t) { kp_lifter(t); kp_horn(t); }
module kp_part(p) {
  if (p == "kp_lifter") translate([0, 0, -yoke_bottom_locked]) kp_lifter(1);       // bottom down
  else if (p == "kp_horn") kp_horn_print();
  else if (p == "kp_knob") translate([0, 0, kp_knob_h]) rotate([180, 0, 0]) kp_knob();   // top down
  // Interference checks: all must be empty or touch.
  else if (p == "kp_check_cart")  for (t = [0, 0.5, 1]) intersection() { lock_cartridge(); union() { kp_moving(t); kp_visuals(); } }
  else if (p == "kp_check_dock")  for (t = [0, 0.5, 1]) intersection() { kp_dock(); union() { kp_moving(t); kp_visuals(); lock_bolt(t); } }
  else if (p == "kp_check_pin")   for (t = [0, 0.25, 0.5, 0.75, 1]) intersection() { kp_lifter(t); kp_horn(t); }
  else if (p == "kp_check_cover") for (t = [0, 1]) intersection() { lock_cover(); union() { kp_moving(t); kp_visuals(); } }
  else if (p == "kp_exploded") {   // picture: the dock, the keypad cartridge lowered out of the bay with its parts
    color([0.38, 0.42, 0.46]) kp_dock();
    translate([0, 0, -55]) { color([0.34, 0.34, 0.37]) lock_cartridge(); kp_placed(1); lock_bolt(1); }
    color([0.30, 0.30, 0.30]) translate([0, 0, -95]) lock_cover();
  }
}

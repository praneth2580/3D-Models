/*
  Lock video scene: how the three locks move the steel bolt. Uses the real parts from phone_dock_v0.5.scad
  (lock_type is set per frame). The dock, cartridge, cover and shoe are drawn see-through; the moving lock
  parts and the bolt solid. Set per frame by make_lock_video.py (-D L_xxx=...).
  Visual only: the store lock's body and key, the keypad lock's servo and knob.
*/
include <../phone_dock_v0.5.scad>
PART = "none";
$fn = 40;

L_turn     = 1;     // store / keypad: 1 = locked, 0 = unlocked
L_key_out  = 0;     // store key / printed key: how far out of the lock, mm (0 = fully in)
L_key_rot  = 0;     // store key: turned, degrees
L_shift    = 0;     // printed lock: shuttle pushed in, mm (0 = locked, plk_S = unlocked)
L_wafer    = 0;     // printed lock: wafer height (−plk_drop = dropped, 0 = level)
L_show_key = 1;
L_ghost    = 0.16;  // see-through alpha of the dock, cartridge, cover and shoe
L_case_dy  = 0;     // the case (shoe) slid up the rails, mm

GHOST = [0.55, 0.62, 0.72, L_ghost];
BOLT = [1.0, 0.82, 0.1];
KEEPER = [1.0, 0.3, 0.05];

// Only the lock pod's surroundings: the rest of the dock would just cloud the view.
module pod_crop() intersection() { children(); translate([pod_low_x0 - 6, pod_y0 - 14, -60]) cube([lock_face_x - pod_low_x0 + 20, pod_y1 - pod_y0 + 22, 80]); }
module ghosts() {
  color(GHOST) pod_crop() if (merged) dock_base(); else dock_receiver();
  color(GHOST) lock_cartridge();
  color(GHOST) lock_cover();
  translate([0, L_case_dy, 0]) color([0.3, 0.33, 0.36, L_ghost + 0.1]) pod_crop() dock_shoe();
  if (lock_type == "store") {                // the store lock's body, see-through so the crank shows behind it
    color([0.62, 0.62, 0.66, 0.35]) translate([0, lock_y, lock_z]) rotate([0, 90, 0]) translate([0, 0, crank_x1 + 0.3]) cylinder(d=lock_bore_d - 0.2, h=lock_face_x - crank_x1 - 0.3);
    color([0.72, 0.72, 0.74, 0.5]) translate([lock_face_x, lock_y, lock_z]) rotate([0, 90, 0]) cylinder(d=20, h=1.2);
  }
}

module store_key() {                       // tubular key on the lock axis, turning about x
  translate([lock_face_x + 1.2 + L_key_out, lock_y, lock_z]) rotate([-L_key_rot, 0, 0]) color([0.85, 0.75, 0.35]) {
    translate([-10, 0, 0]) rotate([0, 90, 0]) cylinder(d=7, h=10);
    rotate([0, 90, 0]) cylinder(d=10, h=4);
    translate([4, -2, -12]) cube([20, 4, 24]);
  }
}

module bolt_at(dz) color(BOLT) translate([bolt_x - bolt_w/2, bolt_y - bolt_t/2, yoke_bottom_locked + dz]) cube([bolt_w, bolt_t, bolt_len]);

module scene() {
  translate([0, L_case_dy, 0]) color(KEEPER) keeper_part();
  if (lock_type == "store") {
    color([0.8, 0.8, 0.84]) crank_placed(L_turn);
    color([0.45, 0.75, 0.95]) lock_yoke(L_turn);
    if (L_show_key) store_key();
    bolt_at(yoke_dz(L_turn));
  } else if (lock_type == "printed") {
    t = 1 - L_shift/plk_S;
    plk_to_dock(L_shift) {
      color([0.85, 0.55, 0.15]) intersection() {        // the half nearer the camera cut away, so the wafers show
        plk_shuttle(); translate([-1, -50, -50]) cube([plk_L + 2, 50, 100]); }
      color([0.95, 0.8, 0.3]) for (i = [0:plk_n - 1]) plk_wafer(i, L_wafer);
      if (L_show_key) color([0.2, 0.45, 0.85]) translate([-L_key_out, 0, 0]) plk_key();
    }
    color([0.45, 0.75, 0.95]) plk_lifter(t);
    bolt_at(plk_dz_s(L_shift));
  } else {
    color([0.45, 0.75, 0.95]) kp_lifter(L_turn);
    color([0.9, 0.9, 0.92]) kp_horn(L_turn);
    bolt_at(yoke_dz(L_turn));
    // The servo (see-through, so the horn shows behind it), the encoder's shaft and the knob.
    color([0.15, 0.3, 0.75, 0.45]) translate([kp_srv_x0, kp_srv_y0, kp_zs - kp_srv_w/2]) cube([kp_srv_h, kp_srv_l, kp_srv_w]);
    color([0.75, 0.75, 0.78]) translate([lock_panel_inner_x - 3, kp_enc_y, kp_enc_z]) rotate([0, 90, 0]) cylinder(d=kp_enc_shaft_d, h=lock_panel_t + kp_knob_gap + 10, $fn=24);
    color([0.18, 0.18, 0.2]) translate([lock_face_x + kp_knob_gap - kp_knob_press, kp_enc_y, kp_enc_z]) rotate([kp_knob_a, 0, 0]) rotate([0, 90, 0]) kp_knob();
  }
  ghosts();                                 // last, so the see-through parts blend over the solid ones
}
scene();

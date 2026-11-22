/*
  DIAL LOCK (DEMO): a mechanical combination lock with ONE dial, like a safe, in its own lock cartridge.
  Included by phone_dock_v0.5.scad (uses its lock bay, bolt, arm pocket and cover). See DIAL_LOCK.md.
  lock_type = "dial" picks it. No key, no power. The code is 4 to 6 digits (dial_code), on a dial numbered 0-9.
  UNLOCK: dial the code. LOCK: press the button (that's all: it also clears the code).

  How it works:
    - DIAL and WHEELS: the dial turns a spindle with a drive cam at its rear. On a fixed tube around the spindle
      sits one wheel per digit. Pins (flies) let each part pick up the next after nearly a turn, so dialling
      right, left, right... leaves each wheel at its own digit, as in a safe. Each wheel has a notch (gate) in
      its rim; where the notch sits on the wheel sets that wheel's digit.
    - FENCE: a bar under the wheels, pushed up by a small spring. With every notch at the bottom, it rises into
      them and lifts its LATCH (a springy printed arm with a tooth) out of the notch in the button's bar: the
      button's spring pushes it out, and the lifter's spring drops the bolt. Unlocked.
    - BUTTON: pushed in, its ramp lifts the lifter's pin 7 mm (the bolt goes up into the case), and at the end
      the latch's tooth (its arm bent down while it rode on the bar) snaps into its notch: locked.
    - RESET: on the way in (and out), a hump in a groove in the button's bar lifts the HAMMER for a moment. It
      presses a heart-shaped cam on the front wheel, which turns it to "home" (like a stopwatch's reset), with
      its notch away from the fence. To bring the front wheel back to the code, the dial has to pick it up
      through every other wheel, so the whole code has to be dialled again.
    - The lifter carries the same steel bolt on the same arm as the store lock's yoke. Locked, its pin sits on
      the button bar's flat top, so pushing the bolt down can't push the button out.

  Frame: dock frame. Everything follows the lock bay, so it fits both mounts.
*/

// ------------------------- SETTINGS ---------------------------------
dial_code = [3, 7, 1, 9];   // CHANGE THIS before printing: 4 to 6 digits, 0-9 (one wheel per digit; first = front)
dl_R = 7.5;                 // wheel radius
dl_wt = 2.0;                // wheel thickness (the front wheel: 1 mm notched rim + 1 mm heart cam)
dl_wgap = 0.6;              // between wheels (the flies overlap here)
dl_bore = 5.0;              // wheel bore, on the fixed tube
dl_tube = [4.6, 3.4];       // tube: outside, bore (the spindle turns inside it)
dl_spindle_d = 3.0;
dl_cam = [6.0, 2.5];        // drive cam: radius, thickness
dl_fly = [1.4, 0.35, 5.0];  // flies (pins on the wheel faces): diameter, length, radius
dl_gate = [3.0, 1.4, 1.7];  // notch in the rim: width at the rim, at the bottom, depth
dl_rise = 1.5;              // how far the fence rises into the notches
dl_heart_r = [3.6, 7.5];    // front wheel's heart cam: low, high radius
dl_zd = -12.8;              // dial axis height (dock z)
dl_knob = [15, 6];          // dial: diameter, thickness
dl_stroke = 11.2;           // button travel
dl_ramp = 40;               // button ramp angle
dl_lift = crank_r;          // bolt travel (7)
dl_pin_d = 3.0;             // lifter's follower pin
dl_hammer_pin = 1.2;        // hammer's pin in the button's groove
dl_hump_ang = 60;           // the groove's hump: slope

// ------------------------- DERIVED (dock frame) ---------------------
dl_n = len(dial_code);
dl_y = lock_y;                                                    // dial axis (y)
dl_x0f = lock_panel_inner_x - 0.6;                                // front wheel's front face
function dl_wx(i) = dl_x0f - dl_wt - i*(dl_wt + dl_wgap);         // wheel i's rear face (0 = front)
dl_cam_x = [dl_wx(dl_n - 1) - dl_wgap - dl_cam[1], dl_wx(dl_n - 1) - dl_wgap];
// Button bar: ramp and flat at the back, a lower stem under the wheels to the front.
dl_py = [lock_y - 9.2, lock_y - 5.0];
dl_ptop = cart_z0 + dl_lift + 0.1;                                // flat top (the pin's locked seat)
dl_rear = bay_x0 + 0.2;
dl_run = (dl_ptop - cart_z0)/tan(dl_ramp);
dl_pin_x = dl_rear + dl_run + 0.6;
dl_pin_z = dl_ptop + dl_pin_d/2;
dl_step_x = dl_pin_x + dl_pin_d/2 + 0.1;                          // the flat ends here (pushed)...
dl_step_run = 0.3;                                                // ...and drops to the stem over this
dl_stem_top = cart_z0 + 4.1;
dl_notch_d = 1.5;
dl_tab = [dl_rear + 9.1, 1.6];                                    // button spring's tab: x (pushed), width
dl_spr_ch = [lock_y + 4.8, lock_y + 9.6];                         // button spring channel (y)
dl_spr_x0 = dl_rear + 5.6;
// Lifter.
dl_plate_x = [yoke_x0, yoke_x0 + 5];
dl_plate_top = yoke_bottom_locked + 7.8;
dl_beam_y = [lock_y - 10.2, lock_y - 9.4];
dl_spring_xy = [yoke_x0 + 2.5, lock_y - 5];
// Fence (down = locked position); its spring sits under its rear end, behind the button spring's tab.
dl_ftop = dl_zd - dl_R - 0.2;
dl_fence_y = [dl_y - 0.6, dl_y + 0.6];
dl_fence_x0 = dl_plate_x[1] + 0.8;
dl_fspring_x = dl_fence_x0 + 1.6;
// Latch: a springy arm on the fence, beside the button's bar, with the tooth at its front end (under the front
// wheel's rim). While the button is out and the fence down, the arm bends 1.5 mm (the tooth rides on the bar).
dl_tooth_x = [dl_wx(0) + 0.1, dl_wx(0) + 0.9];
dl_tooth_y = [dl_py[1] - 1.4, dl_py[1] + 1.0];
dl_arm_z = dl_ftop - 3.3;                                         // latch arm's bottom, latched
dl_arm_y = [dl_py[1] + 0.2, dl_py[1] + 1.0];
dl_arm_x0 = dl_tooth_x[0] - 10;                                   // the arm's root (a bracket off the fence)
// Hammer (under the front wheel's heart half) and the hump in the button's groove that lifts it.
dl_hx = dl_wx(0) + dl_wt*3/4;                                     // hammer's centre (x): the heart half
dl_h_top = dl_zd - dl_R - 0.3;                                    // hammer's top, at rest
dl_h_lift = (dl_zd - dl_heart_r[0] - 0.5) - dl_h_top;             // raised: 0.5 mm short of the heart's low point
dl_hz0 = cart_z0 + 3.2;                                           // hammer pin's centre, at rest
dl_h_rr = dl_h_lift/tan(dl_hump_ang);                             // hump: one slope's length
dl_hump_s = [5.98, 5.98 - dl_h_rr, 5.98 - dl_h_rr - 0.3, 5.98 - 2*dl_h_rr - 0.3];   // button positions: start, top, top, end
dl_rib_r = dl_hammer_pin/2 + 0.15 + 0.3;                          // the groove's rib: its half-width around the pin's path
dl_h_bar = dl_hz0 + dl_rib_r/cos(dl_hump_ang) + 0.4*tan(dl_hump_ang) + 0.15;   // crossbar bottom: clear of the rib on the slopes
// Each wheel's notch angle on the wheel. Dialling turns the dial to rot = -36*digit; the last wheel picked up
// trails the dial by its place in the chain times the flies' contact angle (dl_delta), in the direction turned
// (right = negative rot for the 1st digit, then alternating). So the notch for digit i sits at:
dl_delta = 2*asin((dl_fly[0]/2)/dl_fly[2]);                       // flies touching side by side
function dl_dir(i) = i % 2 == 0 ? -1 : 1;                          // 1st digit right, 2nd left, ...
function dl_gate_a(i) = ((36*dial_code[i] - dl_dir(i)*(dl_n - i)*dl_delta) % 360 + 360) % 360;
dl_home_rot = -(dl_gate_a(0) + 180);                              // front wheel at home: heart's low point (opposite its notch) down
// ...and the dial's index mark (9 o'clock, -y side).
dl_index = [dl_y - (dl_knob[0]/2 + 0.65), dl_zd];

// ------------------------- CHECKS -----------------------------------
assert(dl_n >= 4 && dl_n <= 6, "dial_code: 4 to 6 digits.");
assert(min(dial_code) >= 0 && max(dial_code) <= 9, "dial_code: digits 0-9.");
assert(dl_cam_x[0] >= dl_plate_x[1] + 0.6, "Too many wheels for the bay: the drive cam runs into the lifter.");
assert(dl_zd + dl_R + 0.6 <= bay_top_z - cart_clear - 1.0, "Wheels break the top of the cartridge.");
assert(abs(dl_index[0] - lock_y) + 0.6 <= notch_hw - cart_clear - 0.3, "No room for the index mark on the face plate.");
assert(dl_zd + dl_knob[0]/2 <= notch_top_z + 1.5, "Dial stands too high above the face plate.");
assert(dl_arm_z >= dl_stem_top + 0.5, "Latch arm runs into the button's stem.");
assert(dl_rise + 0.2 <= dl_gate[2] && dl_rise >= dl_notch_d, "The fence must rise far enough to free the latch, and fit the notches.");
assert(dl_tab[0] + dl_stroke + dl_tab[1] <= dl_tooth_x[0] - 0.4, "Spring tab runs into the latch.");
assert(dl_step_x + dl_step_run + dl_stroke <= dl_tooth_x[0] - 0.3, "Out, the button's flat runs into the latch.");
assert(dl_fspring_x - 1.5 >= dl_plate_x[1] + 0.3 && dl_tab[0] >= dl_fspring_x + 1.6, "Fence spring runs into the lifter or the tab.");
assert(abs(dl_pin_z - dl_lift - (cart_z0 + dl_pin_d/2)) < 0.15, "Unlocked, the pin should rest just above the cover.");
assert(dl_pin_x + dl_pin_d/2 + 0.4 <= dl_rear + dl_stroke, "Out, the button's rear must clear the pin.");
assert(dl_wx(dl_n - 1) - 0.3 >= dl_pin_x + dl_pin_d/2
       || dl_zd - sqrt(dl_R*dl_R - pow(dl_py[1] - 0.4 - dl_y, 2)) >= dl_pin_z + dl_pin_d/2 + 0.3, "Wheels run into the lifter's pin.");
assert(dl_gate[2] + dl_fly[2] + dl_fly[0]/2 <= dl_R - 0.1, "A notch would cut a fly.");
assert(dl_hump_s[3] >= 0.3, "The hammer must be back down before the button is fully in (else the front wheel stays clamped).");
assert(dl_h_lift >= 3, "Hammer travel too short to reset the front wheel.");
assert(dl_arm_x0 >= dl_pin_x + dl_pin_d/2 + 0.5 && dl_arm_x0 >= dl_fspring_x + 2, "Latch arm's root runs into the lifter's pin or the fence spring.");
assert(3*0.8*dl_notch_d/(2*pow(dl_tooth_x[0] - dl_arm_x0, 2)) <= 0.02, "Latch arm bends too sharply (over 2 % strain).");
echo(dial_lock = dial_code, wheels = dl_n, cam_x = dl_cam_x, wheel_axis = [dl_y, dl_zd], hammer_lift = dl_h_lift, hump = dl_hump_s);
echo(dl_anim = [dl_n, dl_delta, [for (i = [0:dl_n - 1]) dl_gate_a(i)], dial_code, dl_home_rot, dl_hump_s, dl_h_lift, dl_stroke]);

// ------------------------- PARTS ------------------------------------
module dl_digit(d, size=3.2) linear_extrude(0.6) text(str(d), size=size, font="Liberation Sans:style=Bold", halign="center", valign="center");
// Fly on a wheel face, at the wheel's top (local -x). s = +1 front face, -1 rear face. Wheel frame: axis z, front = +z.
module dl_fly_pin(s) translate([-dl_fly[2], 0, s > 0 ? dl_wt/2 - 0.01 : -dl_wt/2 - dl_fly[1] + 0.01]) cylinder(d=dl_fly[0], h=dl_fly[1], $fn=16);
module dl_gate_cut(i) rotate(dl_gate_a(i)) translate([dl_R + 0.01, 0, -dl_wt]) linear_extrude(2*dl_wt)
  polygon([[0, -dl_gate[0]/2], [-dl_gate[2], -dl_gate[1]/2], [-dl_gate[2], dl_gate[1]/2], [0, dl_gate[0]/2], [1, dl_gate[0]/2 + 1], [1, -dl_gate[0]/2 - 1]]);
// Heart cam (2D): radius grows evenly from the low point both ways, so a flat push turns it to the low point.
module dl_heart_2d(a_low) polygon([for (f = [-180:6:174]) let(r = dl_heart_r[0] + (dl_heart_r[1] - dl_heart_r[0])*abs(f)/180)
                                       [r*cos(a_low + f), r*sin(a_low + f)]]);
// One wheel (its local +x points down when not turned). The front wheel: rim half (rear) + heart half (front).
module dl_wheel(i) difference() {
  union() {
    if (i == 0) {
      translate([0, 0, -dl_wt/2]) cylinder(r=dl_R, h=dl_wt/2 + 0.01, $fn=72);
      linear_extrude(dl_wt/2) dl_heart_2d(dl_gate_a(0) + 180);       // low point opposite the notch
    } else {
      cylinder(r=dl_R, h=dl_wt, center=true, $fn=72);
      dl_fly_pin(1);
    }
    dl_fly_pin(-1);
  }
  cylinder(d=dl_bore, h=dl_wt + 1, center=true, $fn=32);
  // The notch: V-sided (the sides push the fence down when the wheel turns), at this wheel's digit.
  if (i == 0) intersection() { dl_gate_cut(i); translate([-20, -20, -dl_wt]) cube([40, 40, dl_wt]); }   // rim half only
  else dl_gate_cut(i);
}
// Wheel i in the dock, turned rot degrees (0 = as printed: its local +x at the bottom).
module dl_wheel_placed(i, rot) translate([dl_wx(i) + dl_wt/2, dl_y, dl_zd]) rotate([rot, 0, 0]) rotate([0, 90, 0]) dl_wheel(i);
function dl_open_rot(i) = -dl_gate_a(i);                          // notch at the bottom
function dl_scrambled_rot(i) = i == 0 ? dl_home_rot : -dl_gate_a(i) + 90 + 47*i;

// Spindle + drive cam (one part; the dial is pressed on its front end). rot: dial turned, degrees.
module dl_spindle(rot=0) translate([0, dl_y, dl_zd]) rotate([rot, 0, 0]) translate([dl_cam_x[0], 0, 0]) rotate([0, 90, 0]) {
  difference() {
    cylinder(d=dl_spindle_d, h=lock_face_x + 0.6 + dl_knob[1] - 1 - dl_cam_x[0], $fn=24);
    translate([dl_spindle_d/2 - 0.5, -2, lock_face_x - dl_cam_x[0]]) cube([1, 4, 20]);   // flat for the dial
  }
  cylinder(r=dl_cam[0], h=dl_cam[1], $fn=48);
  translate([-dl_fly[2], 0, dl_cam[1] - 0.01]) cylinder(d=dl_fly[0], h=dl_fly[1], $fn=16);   // drive pin, at the top
}
// Dial: digits 0-9 on its face.
module dl_dial() difference() {
  union() {
    cylinder(d=dl_knob[0], h=dl_knob[1], $fn=60);
    for (k = [0:23]) rotate(k*15 + 7.5) translate([dl_knob[0]/2 - 0.25, 0, 0]) cylinder(d=1.0, h=dl_knob[1], $fn=8);   // grip
  }
  translate([0, 0, -0.1]) difference() { cylinder(d=dl_spindle_d + 0.2, h=dl_knob[1] - 1, $fn=24); translate([dl_spindle_d/2 - 0.4, -2, 0]) cube([1, 4, 10]); }
  for (d = [0:9]) rotate(90 + d*36) translate([dl_knob[0]/2 - 2.6, 0, dl_knob[1] - 0.5]) rotate(-90) dl_digit(d, 2.6);
}
module dl_dial_placed(rot=0) translate([lock_face_x + 0.6, dl_y, dl_zd]) rotate([rot, 0, 0]) rotate([0, 90, 0]) rotate(180) dl_dial();

// Fence + latch (one part). f: fence raised, mm (0 = down). l: tooth raised (0 = in the button's notch; the
// arm bends when l > f, while the tooth rides on the bar).
module dl_fence(f=0, l=undef) {
  lt = l == undef ? f : l;
  translate([0, 0, f]) {
    translate([dl_fence_x0, dl_fence_y[0], dl_ftop - 2.4]) cube([dl_tooth_x[1] - dl_fence_x0, dl_fence_y[1] - dl_fence_y[0], 2.4]);
    translate([dl_arm_x0, dl_arm_y[0], dl_arm_z]) cube([1.0, dl_fence_y[0] - dl_arm_y[0] + 0.01, dl_ftop - 2.4 - dl_arm_z + 0.01]);   // bracket
  }
  hull() {                                                        // the arm (bent, drawn as a straight line)
    translate([dl_arm_x0, dl_arm_y[0], dl_arm_z + f]) cube([1.0, dl_arm_y[1] - dl_arm_y[0], 0.8]);
    translate([dl_tooth_x[0], dl_arm_y[0], dl_arm_z + lt]) cube([dl_tooth_x[1] - dl_tooth_x[0], dl_arm_y[1] - dl_arm_y[0], 0.8]);
  }
  translate([dl_tooth_x[0], dl_tooth_y[0], dl_stem_top - dl_notch_d + lt])                       // the tooth
    cube([dl_tooth_x[1] - dl_tooth_x[0], dl_tooth_y[1] - dl_tooth_y[0], dl_arm_z + 0.8 - (dl_stem_top - dl_notch_d)]);
}
// Hammer: a post under the front wheel's heart, a crossbar over the button's bar, a foot with the pin in the
// button's groove (one part). h: raised, mm.
module dl_hammer(h=0) translate([dl_hx - 0.4, 0, h]) {
  translate([0, dl_y - 1.5, dl_h_bar + 0.99]) cube([0.8, 3.0, dl_h_top - dl_h_bar - 0.99]);              // post
  translate([0, dl_py[0] - 1.1, dl_h_bar]) cube([0.8, dl_y + 1.5 - dl_py[0] + 1.1, 1.0]);                  // crossbar
  translate([0, dl_py[0] - 1.1, dl_hz0 - 1.0]) cube([0.8, 1.0, dl_h_bar - dl_hz0 + 1.0 + 0.01]);           // foot
  translate([0, dl_py[0] - 0.11, dl_hz0 - dl_hammer_pin/2]) cube([0.8, 0.9, dl_hammer_pin]);              // peg (square: prints flat)
}
function dl_hammer_at(s) = s >= dl_hump_s[0] || s <= dl_hump_s[3] ? 0
                         : s >= dl_hump_s[1] ? dl_h_lift*(dl_hump_s[0] - s)/dl_h_rr
                         : s >= dl_hump_s[2] ? dl_h_lift
                         : dl_h_lift*(s - dl_hump_s[3])/dl_h_rr;

// Button bar (s = 0 pushed in, locked; s = dl_stroke out). The hammer pin's path along the bar (bar frame):
function dl_groove_pts() = [[dl_hx - dl_stroke - 0.6, dl_hz0], [dl_hx - dl_hump_s[0], dl_hz0], [dl_hx - dl_hump_s[1], dl_hz0 + dl_h_lift],
                            [dl_hx - dl_hump_s[2], dl_hz0 + dl_h_lift], [dl_hx - dl_hump_s[3], dl_hz0], [dl_hx + 0.6, dl_hz0]];
module dl_path_2d(r) { p = dl_groove_pts(); for (k = [0:len(p) - 2]) hull() { translate(p[k]) circle(r=r, $fn=20); translate(p[k + 1]) circle(r=r, $fn=20); } }
module dl_plunger(s=0) translate([s, 0, 0]) difference() {
  union() {
    translate([0, dl_py[0], 0]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(dl_py[1] - dl_py[0])
      polygon([[dl_rear, cart_z0], [dl_rear + dl_run, dl_ptop], [dl_step_x, dl_ptop], [dl_step_x + dl_step_run, dl_stem_top],
               [lock_face_x + 0.5, dl_stem_top], [lock_face_x + 0.5, cart_z0]]);
    // Rib along the -y side that carries the hammer's groove (its hump stands up from the bar).
    translate([0, dl_py[0], 0]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(1.4)
      intersection() { dl_path_2d(dl_rib_r); translate([dl_rear, cart_z0]) square([lock_face_x + 0.5 - dl_rear, 30]); }
    translate([dl_tab[0], dl_py[1] - 0.3, cart_z0 + 0.3]) cube([dl_tab[1], dl_spr_ch[1] - 0.4 - dl_py[1] + 0.3, 3.4]);   // spring tab
    translate([lock_face_x + 0.3, dl_py[0] - 0.6, cart_z0 + 0.3]) cube([2.2, dl_py[1] - dl_py[0] + 1.2, dl_stem_top - cart_z0 - 0.3]);   // cap
  }
  translate([dl_tooth_x[0] - 0.2, dl_tooth_y[0] - 0.2, dl_stem_top - dl_notch_d - 0.1]) cube([dl_tooth_x[1] - dl_tooth_x[0] + 0.4, dl_py[1] - dl_tooth_y[0] + 0.5, dl_notch_d + 0.5]);   // latch notch
  translate([0, dl_py[0] - 0.1, 0]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(0.9) dl_path_2d(dl_hammer_pin/2 + 0.15);   // groove
}

// Lifter: the yoke's arm + a plate + a beam forward to the follower pin.
function dl_lift_at(s) =
  let(u = dl_pin_x - s, zc = cart_z0 + (u - dl_rear)*tan(dl_ramp) + (dl_pin_d/2)/cos(dl_ramp))
  min(dl_lift, max(0, zc - (dl_pin_z - dl_lift)));
module dl_lifter(s=0) translate([0, 0, dl_lift_at(s) - dl_lift]) difference() {
  union() {
    translate([bolt_x - arm_wx/2, bolt_y - arm_wy/2, yoke_bottom_locked]) cube([dl_plate_x[0] + 0.5 - bolt_x + arm_wx/2, arm_wy, arm_h]);   // arm
    translate([dl_plate_x[0], bolt_y - arm_wy/2, yoke_bottom_locked]) cube([dl_plate_x[1] - dl_plate_x[0], arm_wy, dl_plate_top - yoke_bottom_locked]);
    translate([dl_plate_x[0], dl_beam_y[0], dl_pin_z - dl_pin_d/2 + 0.1]) cube([dl_pin_x + 2 - dl_plate_x[0], dl_beam_y[1] - dl_beam_y[0], 5]);   // beam
    translate([dl_pin_x, dl_beam_y[1] - 0.01, dl_pin_z]) rotate([-90, 0, 0]) cylinder(d=dl_pin_d, h=dl_py[1] - 0.4 - dl_beam_y[1], $fn=24);  // pin
  }
  translate([bolt_x - (bolt_w - 0.1)/2, bolt_y - (bolt_t - 0.1)/2, yoke_bottom_locked - 0.05]) cube([bolt_w - 0.1, bolt_t - 0.1, arm_h + 0.1]);
  translate([dl_spring_xy[0], dl_spring_xy[1], dl_plate_top - 1.5]) cylinder(d=5.4, h=2, $fn=24);   // spring seat
}

// ------------------------- CARTRIDGE --------------------------------
module dl_cuts() {
  // Lifter: plate pocket, beam slot (full travel), open underneath; its spring.
  translate([bay_x0 - 0.05, bolt_y - arm_wy/2 - 0.3, pod_bottom_z - 1]) cube([dl_plate_x[1] + 0.3 - bay_x0, arm_wy + 0.6, dl_plate_top + 0.5 - pod_bottom_z + 1]);
  translate([bay_x0 - 0.05, dl_beam_y[0] - 0.3, pod_bottom_z - 1]) cube([dl_pin_x + 2.4 - bay_x0, dl_py[1] + 0.2 - dl_beam_y[0] + 0.3, dl_pin_z + 5 + 0.5 - pod_bottom_z + 1]);
  translate([dl_spring_xy[0], dl_spring_xy[1], pod_bottom_z]) cylinder(d=5.6, h=bay_top_z - cart_clear - 1.0 - pod_bottom_z, $fn=24);
  // Button channel; the rib's strip as tall as the groove's hump; through the face plate only as tall as needed.
  translate([bay_x0 - 0.05, dl_py[0] - 0.2, pod_bottom_z - 1]) cube([lock_panel_inner_x + 0.05 - bay_x0, dl_py[1] - dl_py[0] + 0.4, dl_ptop + 0.2 - pod_bottom_z + 1]);
  translate([bay_x0 - 0.05, dl_py[0] - 0.2, pod_bottom_z - 1]) cube([lock_face_x + 1 - bay_x0, 1.8, dl_h_bar + 1.0 + dl_h_lift + 0.3 - pod_bottom_z + 1]);
  translate([lock_panel_inner_x - 0.1, dl_py[0] - 0.2, pod_bottom_z - 1]) cube([lock_panel_t + 0.3, dl_py[1] - dl_py[0] + 0.4, dl_stem_top + 0.2 - pod_bottom_z + 1]);
  // Button spring channel, with the tab's path (under the fence).
  translate([dl_spr_x0, dl_py[1], pod_bottom_z - 1]) cube([dl_tab[0] + dl_stroke + dl_tab[1] + 0.4 - dl_spr_x0, dl_spr_ch[1] - dl_py[1], cart_z0 + 4.0 - pod_bottom_z + 1]);
  // Wheel pack, drive cam, fence and hammer post: one cavity, open underneath (they go in from below). It
  // stops 0.3 mm short of the face plate (that end wall carries the latch spring's seat).
  translate([dl_fence_x0 - 0.4, dl_y, dl_zd]) rotate([0, 90, 0]) cylinder(r=dl_R + 0.6, h=lock_panel_inner_x - 0.3 - dl_fence_x0 + 0.4, $fn=72);
  translate([dl_fence_x0 - 0.4, dl_y - dl_R - 0.6, pod_bottom_z - 1]) cube([lock_panel_inner_x - 0.3 - dl_fence_x0 + 0.4, 2*(dl_R + 0.6), dl_zd + 0.3 - pod_bottom_z + 1]);
  // Latch's slot (it rises and falls), beside the wheels; and the hammer's foot slot.
  translate([dl_arm_x0 - 0.3, dl_tooth_y[0] - 0.3, pod_bottom_z - 1]) cube([dl_tooth_x[1] - dl_arm_x0 + 0.6, dl_fence_y[1] - dl_tooth_y[0] + 0.6, dl_arm_z + 0.8 + dl_rise + 0.3 - pod_bottom_z + 1]);
  translate([dl_hx - 0.6, dl_py[0] - 1.4, pod_bottom_z - 1]) cube([1.2, 1.6, dl_h_bar + 1.0 + dl_h_lift + 0.3 - pod_bottom_z + 1]);
  // Spindle bore through the face plate, and the index mark (a small engraved triangle pointing at the dial).
  translate([lock_panel_inner_x - 0.6, dl_y, dl_zd]) rotate([0, 90, 0]) cylinder(d=dl_tube[1] + 0.2, h=lock_panel_t + 0.8, $fn=28);
  translate([lock_face_x - 0.4, dl_index[0], dl_index[1]]) rotate([0, 90, 0]) linear_extrude(0.5) polygon([[-0.9, -0.5], [0.9, -0.5], [0, 0.6]]);
}
// Added back after the cuts: the fixed tube the wheels turn on.
module dl_tube_part() translate([dl_wx(dl_n - 1) - 0.3, dl_y, dl_zd]) rotate([0, 90, 0]) difference() {
  cylinder(d=dl_tube[0], h=lock_panel_inner_x + 1.0 - dl_wx(dl_n - 1) + 0.3, $fn=32);
  translate([0, 0, -0.1]) cylinder(d=dl_tube[1], h=30, $fn=24);
}
module dl_fingers() dl_tube_part();

// ------------------------- PLACED + EXPORTS -------------------------
function dl_rots(open) = [for (i = [0:dl_n - 1]) open ? dl_open_rot(i) : dl_scrambled_rot(i)];
function dl_rots_reset() = [for (i = [0:dl_n - 1]) i == 0 ? dl_home_rot : dl_open_rot(i)];   // just after a reset
// turn: 1 = locked (button in, front wheel at home), 0 = unlocked (button out).
module dl_placed(turn=1) {
  open = turn < 1;
  color([0.85, 0.55, 0.15]) dl_plunger(open ? dl_stroke : 0);
  color([0.55, 0.58, 0.62]) dl_lifter(open ? dl_stroke : 0);
  color([0.75, 0.75, 0.78]) dl_fence(0, open ? dl_rise : 0);
  color([0.5, 0.5, 0.55]) dl_hammer(0);
  color([0.95, 0.8, 0.3]) for (i = [0:dl_n - 1]) dl_wheel_placed(i, open ? dl_rots_reset()[i] : dl_rots(false)[i]);
  color([0.8, 0.8, 0.84]) dl_spindle(0);
  color([0.15, 0.15, 0.17]) dl_dial_placed(0);
}
DL_PARTS = ["dl_wheel", "dl_wheels", "dl_spindle", "dl_dial", "dl_fence", "dl_hammer", "dl_plunger", "dl_lifter",
            "dl_check_cart", "dl_check_dock", "dl_check_parts", "dl_check_cover", "dl_check_scrambled", "dl_check_held",
            "dl_check_backdrive", "dl_check_reset", "dl_exploded"];
dl_index_n = 0;
function dl_is_part(p) = len([for (n = DL_PARTS) if (n == p) 1]) > 0;
module dl_dock() { if (mount == "merged") dock_base(); else dock_receiver(); }
// [button out, fence raised, tooth raised, hammer raised, wheel rotations]: locked; code set (fence and tooth
// up); on the way out: going up the hump, at its top; out; on the way in, on the ramp.
function dl_states() = [[0, 0, 0, 0, dl_rots(false)], [0, dl_rise, dl_rise, 0, dl_rots(true)],
                        [(dl_hump_s[0] + dl_hump_s[1])/2, 0, dl_rise, dl_h_lift/2, dl_rots_reset()],
                        [dl_hump_s[1], 0, dl_rise, dl_h_lift, dl_rots_reset()], [dl_stroke, 0, dl_rise, 0, dl_rots_reset()],
                        [dl_stroke - 4, 0, dl_rise, 0, dl_rots_reset()]];
module dl_moving(st) { dl_plunger(st[0]); dl_lifter(st[0]); dl_fence(st[1], st[2]); dl_hammer(st[3]); dl_spindle(0);
                       for (i = [0:dl_n - 1]) dl_wheel_placed(i, st[4][i]); }
module dl_part(p) {
  if (p == "dl_wheel") translate([0, 0, dl_wt/2 + dl_fly[1]]) dl_wheel(dl_index_n);
  else if (p == "dl_wheels") for (i = [0:dl_n - 1]) translate([i*18, 0, dl_wt/2 + dl_fly[1]]) dl_wheel(i);
  else if (p == "dl_spindle") translate([-dl_cam_x[0], -dl_y, -dl_zd + dl_cam[0]]) dl_spindle(0);   // lying on its side
  else if (p == "dl_dial") translate([0, 0, dl_knob[1]]) rotate([180, 0, 0]) dl_dial();                            // face down
  else if (p == "dl_fence") translate([0, 0, -(dl_stem_top - dl_notch_d)]) dl_fence(0);
  else if (p == "dl_hammer") rotate([0, 90, 0]) translate([-(dl_hx + 0.4), 0, 0]) dl_hammer(0);                  // flat, on its side
  else if (p == "dl_plunger") translate([0, 0, -cart_z0]) dl_plunger(0);
  else if (p == "dl_lifter") translate([0, 0, -(dl_pin_z - dl_pin_d/2)]) dl_lifter(0);
  // Checks: these must be empty or touch.
  else if (p == "dl_check_cart")  for (st = dl_states()) intersection() { lock_cartridge(); dl_moving(st); }
  else if (p == "dl_check_dock")  for (st = dl_states()) intersection() { dl_dock(); union() { dl_moving(st); dl_dial_placed(0); translate([0, 0, dl_lift_at(st[0]) - dl_lift]) lock_bolt(1); } }
  else if (p == "dl_check_cover") for (st = dl_states()) intersection() { lock_cover(); dl_moving(st); }
  else if (p == "dl_check_parts") for (st = dl_states()) {
      intersection() { dl_plunger(st[0]); union() { dl_lifter(st[0]); dl_fence(st[1], st[2]); dl_hammer(st[3]); } }
      intersection() { dl_fence(st[1], st[2]); union() { dl_lifter(st[0]); dl_hammer(st[3]); dl_spindle(0); for (i = [0:dl_n - 1]) dl_wheel_placed(i, st[4][i]); } }
      intersection() { dl_hammer(st[3]); union() { dl_spindle(0); for (i = [0:dl_n - 1]) dl_wheel_placed(i, st[4][i]); } }
      intersection() { dl_spindle(0); for (i = [0:dl_n - 1]) dl_wheel_placed(i, st[4][i]); }
    }
  // These must collide: wheels off the code stop the fence rising; the latch holds the button in; the pin on
  // the flat stops the bolt being pushed down; the raised hammer pushes a front wheel that isn't at home.
  else if (p == "dl_check_scrambled") intersection() { dl_fence(0.5); for (i = [0:dl_n - 1]) dl_wheel_placed(i, dl_scrambled_rot(i)); }
  else if (p == "dl_check_held")      intersection() { dl_fence(0, 0); dl_plunger(0.5); }
  else if (p == "dl_check_backdrive") intersection() { dl_plunger(0); translate([0, 0, -0.5]) dl_lifter(0); }
  else if (p == "dl_check_reset")     intersection() { dl_hammer(dl_h_lift); dl_wheel_placed(0, dl_open_rot(0)); }
  else if (p == "dl_exploded") {
    color([0.38, 0.42, 0.46]) dl_dock();
    translate([0, 0, -55]) { color([0.34, 0.34, 0.37]) lock_cartridge(); dl_placed(1); lock_bolt(1); }
    color([0.30, 0.30, 0.30]) translate([0, 0, -95]) lock_cover();
  }
}

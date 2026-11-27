/*
  One frame of the Handlebar Remote's video (made by make_remote_video.py, which sets the state below with -D).
  The parts come from STLs in their places on the bar (frames_remote/view/, exported by make_remote_video.py from
  ../handlebar_remote.scad), so a frame takes about a second.
*/
include <../handlebar_remote.scad>       // (run with -D 'PART="none"')

VIEW = "frames_remote/view/";
EXPL = 0;               // taken apart: 0 (assembled) .. 1
JOY = [0, 0];           // the joystick's cap tilted [angle, toward (degrees round its axis)]
PRESS = -1;             // the button being pressed (0-3), -1 none
BACK_PRESS = 0;         // the back button pressed (1)
LEDS = [1, 0];          // the power and status LEDs lit (1)
STATUS = [0.2, 0.45, 1.0];   // the status LED's colour

body_c = [0.16, 0.17, 0.19];
rubber_c = [0.1, 0.1, 0.11];
glow_c = [1.0, 0.55, 0.12];
module part(name, c) color(c) import(str(VIEW, name, ".stl"), convexity=6);
mid = nrm((a_f + a_b)/2);
e = 9*EXPL;

bike();
translate(e*3.4*mid) {
  part("collar_top", body_c);
  if (PRESS >= 0 && PRESS < btn_n) btn_frame(PRESS) translate([0, 0, proud + 0.2])   // the pressed button lights up round its dome
    color(glow_c) linear_extrude(0.4) difference() { btn_2d(PRESS, 1.4); btn_2d(PRESS, 0.4); }
}
translate(e*2.2*mid) part("keypad", rubber_c);
translate(e*4.4*mid) multmatrix(JM) translate(pivot) rotate(a=JOY[0], v=[cos(JOY[1]), sin(JOY[1]), 0]) translate(-pivot)
  multmatrix(invert(JM)) part("joy_cap", [0.85, 0.45, 0.1]);
for (g = [0, 1]) translate(e*0.9*nrm(g_a[g])) {
  part(str("carrier_", g), [0.35, 0.37, 0.4]);
  part(str("switches_", g), [0.22, 0.22, 0.24]);
}
rot_Q(e*4) {
  part("collar_bottom", body_c);
  part("boards", [0.12, 0.3, 0.55]);
  translate(e*1.2*E) part("bay_plug", rubber_c);
  translate(-e*0.6*YB) part("usb_plug", rubber_c);
  translate(e*0.6*YB) {
    part("back_pad", rubber_c);
    if (BACK_PRESS == 1) bay_frame() translate([0, y_bi + bay_wall + btn_proud + 0.2, z_btn]) rotate([-90, 0, 0])
      color(glow_c) linear_extrude(0.4) difference() { circle(d=btn_hole + 2.4, $fn=40); circle(d=btn_hole - 1.2, $fn=40); }
  }
  for (k = [0, 1]) bay_frame() translate([(2*k - 1)*(led_d/2 + 0.8), y_bi + bay_wall - 0.6, z_led]) {   // the LEDs, seen in their holes
    color(LEDS[k] == 1 ? (k == 0 ? [0.3, 1.0, 0.35] : STATUS) : [0.12, 0.16, 0.13]) sphere(d=led_d + 0.1, $fn=24);
    if (LEDS[k] == 1) color(concat(k == 0 ? [0.4, 1.0, 0.45] : STATUS, [0.35])) sphere(d=led_d + 2.2, $fn=24);   // (a glow)
  }
}

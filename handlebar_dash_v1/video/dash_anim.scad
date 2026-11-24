/*
  The dash on the bike, for the video (make_dash_video.py sets the variables below per frame).
  The bike is a SIMPLE STAND-IN, painted a sunset orange, for the reference bike's front end (a 350 cruiser: round headlamp, 41 mm fork, 19"
  front wheel, wide pulled-back 22.2 mm bar, teardrop tank). Its sizes are estimates for the pictures, not
  measurements, and it carries no maker's badges.
  Frame: the dash file's bike frame: the bar's centre at the origin, x along the bar, y forward, z up.
*/
include <../handlebar_dash.scad>
PART = "none";            // the included file draws nothing

// ---- per-frame state (set with -D) ----
LIT = [];                 // the tell-tales that are lit, by name
SCREEN = "off";           // "off", "boot" or "ride"
SPEED = 0;                // km/h
GEAR = "N";
CLOCK = "10:42";
STEER = 0;                // degrees, about the steering axis (pictures only)

// ---- the stand-in bike (estimates) ----
yoke = [0, 60, -80];      // the top yoke's centre on the steering axis
rake = 27;
fork_x = 100;             // the fork tubes, either side
axis_d = [0, sin(rake), -cos(rake)];
function on_axis(t) = yoke + t*axis_d;
tank_col = [0.86, 0.34, 0.07];   // a sunset orange (the owner's colour choice; no maker's livery or badges)
black = [0.07, 0.07, 0.08];
chrome = [0.78, 0.8, 0.83];
alu = [0.6, 0.61, 0.63];

module along(p0, p1, d) hull() { translate(p0) sphere(d=d, $fn=24); translate(p1) sphere(d=d, $fn=24); }
module axis_frame(t) translate(on_axis(t)) rotate([rake, 0, 0]) children();   // z along the steering axis (up)

module front_end() {
  // the top yoke, the headstock and the bottom yoke
  color(alu) axis_frame(0) hull() for (x = [-fork_x, fork_x]) translate([x, 0, -10]) cylinder(d=62, h=20, $fn=40);
  color(alu) axis_frame(170) hull() for (x = [-fork_x, fork_x]) translate([x, 0, -12]) cylinder(d=66, h=24, $fn=40);
  color(black) axis_frame(180) cylinder(d=58, h=190, $fn=40);
  // the fork: chrome tubes, black sliders, the axle
  for (sx = [-1, 1]) {
    color(chrome) axis_frame(420) translate([sx*fork_x, 0, 0]) cylinder(d=41, h=445, $fn=40);
    color(black) axis_frame(700) translate([sx*fork_x, 0, 0]) cylinder(d=54, h=300, $fn=40);
    color(black) axis_frame(-15) translate([sx*fork_x, 0, 0]) cylinder(d=30, h=16, $fn=30);   // top caps
  }
  // the front wheel (19"): tyre, rim, spokes, hub, disc
  translate(on_axis(700)) rotate([0, 90, 0]) {
    color([0.05, 0.05, 0.05]) rotate_extrude($fn=96) translate([285, 0]) scale([1, 1.05]) circle(r=47, $fn=32);
    color(chrome) rotate_extrude($fn=96) translate([243, 0]) square([8, 50], center=true);
    color(alu) cylinder(d=90, h=150, center=true, $fn=40);
    color(chrome) for (i = [0:17]) rotate(i*20) hull() { translate([0, 0, (i % 2 ? 1 : -1)*35]) sphere(d=3, $fn=8); translate([241, 0, (i % 2 ? 1 : -1)*12]) sphere(d=3, $fn=8); }
    color([0.5, 0.5, 0.52]) translate([0, 0, 58]) difference() { cylinder(d=300, h=5, $fn=72); translate([0, 0, -1]) cylinder(d=110, h=8, $fn=40); }
    color([0.15, 0.15, 0.16]) rotate(200) translate([125, 0, 64]) cube([60, 40, 30], center=true);   // the caliper
  }
  // the front mudguard
  color(tank_col) translate(on_axis(700)) rotate([0, 90, 0]) rotate(-35) rotate_extrude(angle=150, $fn=96) translate([336, 0]) difference() { scale([0.45, 1]) circle(r=66, $fn=40); translate([-12, 0]) scale([0.45, 1]) circle(r=62, $fn=40); }
  // the headlamp: a chrome bucket on ears from the fork, a 7" lamp
  hc0 = [0, 190, -210];
  color(chrome) translate(hc0) rotate([-98, 0, 0]) {
    hull() { cylinder(d=184, h=10, $fn=72); translate([0, 0, -95]) scale([1, 1, 0.55]) sphere(d=160, $fn=48); }
    translate([0, 0, 8]) rotate_extrude($fn=72) translate([90, 0]) circle(r=6, $fn=16);
  }
  color([0.93, 0.93, 0.88]) translate(hc0) rotate([-98, 0, 0]) translate([0, 0, 10]) scale([1, 1, 0.12]) sphere(d=172, $fn=72);
  for (sx = [-1, 1]) {
    color(black) hull() { translate(hc0 + [sx*80, -60, 0]) sphere(d=26, $fn=20); translate([sx*fork_x, 0, 0] + on_axis(255)) sphere(d=30, $fn=20); }
    // the front indicators, on the ears
    color(black) along(hc0 + [sx*110, -40, 10], hc0 + [sx*175, -30, 10], 12);
    color([1, 0.55, 0.05]) translate(hc0 + [sx*185, -30, 10]) scale([1, 1.3, 1]) sphere(d=34, $fn=24);
  }
}

// The handlebar: risers and the bike's own clamp, a wide pulled-back bar, grips, levers, switches and mirrors.
bar_pts = [[0, 0, 0], [170, 0, 0], [300, -110, 40], [400, -175, 55]];
module handlebar() {
  for (sx = [-1, 1]) {
    color(chrome) for (i = [0:len(bar_pts) - 2]) along([sx*bar_pts[i][0], bar_pts[i][1], bar_pts[i][2]], [sx*bar_pts[i + 1][0], bar_pts[i + 1][1], bar_pts[i + 1][2]], bar_d);
    g0 = [sx*bar_pts[2][0], bar_pts[2][1], bar_pts[2][2]]; g1 = [sx*bar_pts[3][0], bar_pts[3][1], bar_pts[3][2]];
    gu = (g1 - g0)/norm(g1 - g0);
    color(black) along(g1 - 125*gu, g1 + 5*gu, 33);                                          // the grip
    color([0.12, 0.12, 0.13]) translate(g1 - 155*gu) hull() { sphere(d=44, $fn=24); translate(-25*gu) sphere(d=44, $fn=24); }   // the switch cube
    color(alu) along(g1 - 185*gu + [0, 25, 5], g1 - 15*gu + [0, 75, -10], 12);                // the lever
    color(alu) translate(g1 - 200*gu) sphere(d=34, $fn=24);                                   // the lever's perch
    color(black) along(g1 - 200*gu, g1 - 200*gu + [sx*45, 25, 140], 11);                      // the mirror's stem
    color(black) translate(g1 - 200*gu + [sx*55, 28, 165]) rotate([80, 0, 0]) scale([1.3, 1, 0.3]) sphere(d=78, $fn=40);
    color(black) translate([sx*30, 0, 0]) hull() { translate([0, 0, -25]) cylinder(d=34, h=1, $fn=32); translate([0, 35, -78]) cylinder(d=34, h=1, $fn=32); }   // risers
  }
  color([0.22, 0.22, 0.24]) hull() for (x = [-1, 1], y = [-1, 1]) translate([x*(bike_clamp[0]/2 - 10), y*(bike_clamp[1]/2 - 10), -bar_d/2 - 4]) cylinder(r=10, h=bar_d/2 + 4 + bike_clamp[2], $fn=24);   // the bike's top clamp (estimate)
}
// The tank and the frame behind the headstock.
module tank_frame() {
  color(tank_col) hull() {
    translate([0, -160, -150]) scale([1, 1.2, 0.72]) sphere(d=230, $fn=64);
    translate([0, -470, -200]) scale([0.95, 1.1, 0.6]) sphere(d=250, $fn=64);
  }
  color(chrome) translate([0, -230, -60]) cylinder(d=60, h=14, $fn=40);                        // the filler cap
  color([0.6, 0.6, 0.62]) translate([0, -232, -63]) cylinder(d=70, h=4, $fn=40);
  color(black) along(on_axis(60) + [0, -20, 0], [0, -540, -255], 60);                           // the backbone
}

// The dash on its 2 bar clamps (mount = "bar"), with the tell-tales lit as LIT says and the screen showing SCREEN.
// The parts come from ../parts/ (turned back from their print poses).
module dash() {
  rotate([-tilt, 0, 0]) {
    color([0.2, 0.21, 0.23]) {
      rotate([0, 90, 0]) translate([0, 0, cradle_span/2 - cradle_clamp_w/2]) import("../parts/bar_mount_right.stl", convexity=4);
      rotate([0, -90, 0]) translate([0, 0, cradle_span/2 - cradle_clamp_w/2]) import("../parts/bar_mount_left.stl", convexity=4);
      for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) rotate([0, -90, 0]) translate([0, 0, -cradle_clamp_w/2]) import("../parts/cradle_cap.stl", convexity=4);
    }
    color([0.08, 0.08, 0.08]) for (sx = [-1, 1]) mount_pad(sx);
  }
  head_placed() {
    color([0.16, 0.17, 0.19]) translate([0, 0, -lip_t]) import("../parts/head_shell.stl", convexity=6);
    color([0.22, 0.23, 0.26]) translate([0, 0, z_cov]) import("../parts/head_cover.stl", convexity=4);
    color([0.78, 0.79, 0.82]) translate([0, 0, z_front]) import("../parts/trim_ring.stl", convexity=4);
    display_dummy();
    logo_fill();
    for (i = [0:len(icons) - 1]) {
      on = len([for (n = LIT) if (n == icons[i]) 1]) > 0;
      color(on ? icon_colour(icons[i]) : [0.3, 0.3, 0.32]) translate([0, 0, z_front - 0.03]) linear_extrude(face_skin) at_icon(i) offset(-0.05) icon2d(icons[i]);
    }
    screen();
  }
}

// ---- the screen (2D, upright as the rider sees it, mirrored into the head frame) ----
module arc2d(r0, r1, a0, a1) if (a1 > a0 + 0.1) polygon(concat([for (a = [a0:(a1 - a0)/60:a1]) r1*[cos(a), sin(a)]], [for (a = [a1:-(a1 - a0)/60:a0]) r0*[cos(a), sin(a)]]));
module txt(s, size, y, x=0, style="Bold") translate([x, y]) text(s, size=size, font=str("Liberation Sans:style=", style), halign="center", valign="center");
module screen() translate([0, 0, glass_z - 0.15]) mirror([1, 0, 0]) {
  if (SCREEN == "off") color([0.02, 0.02, 0.025]) translate([0, 0, -0.05]) cylinder(d=active_d - 0.2, h=0.06);
  else {
    color([0.03, 0.05, 0.08]) translate([0, 0, 0.02]) cylinder(d=active_d - 0.2, h=0.02);
    if (SCREEN == "boot") {
      color([0.85, 0.87, 0.9]) linear_extrude(0.02) txt("DASH", 8, 1);
      color([0.2, 0.75, 0.95]) linear_extrude(0.02) arc2d(29, 30.5, -45, 225);
    } else {
      sweep = 270*min(SPEED, 160)/160;
      color([0.18, 0.2, 0.24]) linear_extrude(0.02) arc2d(30, 33, -45, 225);
      color([0.2, 0.75, 0.95]) translate([0, 0, -0.01]) linear_extrude(0.02) arc2d(30, 33, 225 - sweep, 225);
      color([0.6, 0.62, 0.66]) translate([0, 0, -0.01]) linear_extrude(0.02) for (v = [0:20:160]) rotate(225 - 270*v/160) translate([27.2, 0]) square([1.6, 0.5], center=true);
      color([0.95, 0.96, 0.98]) translate([0, 0, -0.02]) linear_extrude(0.02) {
        txt(str(SPEED), 17, 3);
        txt(CLOCK, 3.4, 21, style="Regular");
      }
      color([0.6, 0.62, 0.66]) translate([0, 0, -0.02]) linear_extrude(0.02) {
        txt("km/h", 3.2, -9, style="Regular");
        txt("TRIP 124.6", 2.5, -24, -9, style="Regular");
        txt("12.8 V", 2.5, -24, 10, style="Regular");
      }
      color(GEAR == "N" ? [0.1, 0.9, 0.2] : [0.95, 0.96, 0.98]) translate([0, 0, -0.02]) linear_extrude(0.02) txt(GEAR, 6, -17);
    }
  }
}

front_end();
handlebar();
tank_frame();
dash();

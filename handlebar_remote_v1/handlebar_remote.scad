/*
  HANDLEBAR REMOTE v1: a slim thumb controller on the left handlebar, between the grip and the bike's switch cube,
  for the dash and for a phone (or any display that takes a Bluetooth keyboard or remote). OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices:
    - 2026-11-24: "a left-side handlebar mount to control any digital displays": a 5-way joystick and 2 buttons
      (glove-friendly, by the thumb, without looking); wired to the dash (one of its expansion slots: power and the
      dash bus) AND Bluetooth (a phone sees it as a Bluetooth keyboard / media remote).
    - 2026-11-25: "between the grips and the control panel, a slim control unit": ONE slim collar (collar_w, 19 mm)
      round the bar in the gap between the grip and the switch cube (slide the cube inboard: gap_w, MEASURE), the
      electronics in a slim bay underneath ("the electronic box is too big ... attached to the buttons"), the controls
      tilted toward the grip (pod_tilt), one smooth organic body, 4 buttons ("could we add more buttons"), each
      button in its own cup with ridges ("not a control unit").
    - 2026-11-27: "the buttons ... obstruct the bike's instrument cluster: move the joystick below to the last and the
      buttons on the top, but in a way that it doesn't obstruct the original instrument cluster", choosing "curve
      round the bar". The straight face stood 42.7 mm above the bar's centre (the switch cube's top is at 30). Now
      the face CURVES ROUND THE BAR: the joystick at the back under the thumb (joy_a 195: a little below the bar's
      centre, where a horn button sits), the buttons above it, up and over the top. Nothing stands higher than the
      switch cube's top (an assert, top_room).

  Built around (COMPONENTS.md; MEASURE yours: none has a published drawing):
    - a 5-way navigation switch, 10 x 10 mm, about 7 mm tall, through-hole;
    - 2 or 4 tactile switches, 6 x 6 mm, through-hole (6 mm tall: the model picks the height);
    - an ESP32-C3 Super Mini (22.52 x 18 mm: Bluetooth LE, and one CAN controller for the dash bus);
    - an SN65HVD230 CAN transceiver module (as in the dash).

  How it goes together:
    1. COLLAR TOP: the ring's upper half and the curved face (the controls' holes in it, a cup round each button),
       hollow inside, open toward the bar. It wraps 205 degrees of the bar.
    2. KEYPAD (TPU): a liner pushed into the face from the bar's side: the sheet under the face (its hollow domes
       are the buttons, it hugs the joystick cap's sleeve) and a skirt round its edge.
    3. SWITCH CARRIERS (2): printed blocks that hold the switches (their legs through the carrier, soldered to the
       wires in a pocket underneath). Each goes up into the collar top from the bar's side (the joystick's carrier
       first, then the buttons'), pressing the keypad's skirt 0.2 mm against the face: that is the seal. The rubber
       strip in the bore holds them in. (A curved face can't take one flat switch board.)
    4. JOYSTICK CAP: pushes onto the switch's stem through the face.
    5. COLLAR BOTTOM: the ring's lower half and the bay, HINGED to the top at the back (a 2 mm pin) and closed by
       one M2.5 screw at the front (its head from underneath).
    6. BAY CAP and its TPU GASKET: close the bay (2 M2 screws); the dash's 4-core cable comes in through the cap.

  Frames: the BIKE frame has the bar along x through the collar's centre (x to the rider's right: the grip is at -x,
  the switch cube at +x), y forward, z up; angles round the bar are measured from straight forward toward up (90 =
  straight up, 180 = toward the rider, 270 = straight down). Each CONTROL frame (ctl_M(a)) has its origin on the face
  at angle a round the bar, x across the face (along the bar, tilted), y round the bar toward the top (the next
  button up), z out of the face. The face is a cone round the bar (a cylinder tilted toward the grip by pod_tilt).
  The BAY frame has its origin on the bar's axis, z pointing down the bay (bay_a).
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "exploded", "collar_top", "collar_bottom", "carrier_joy", "carrier_btn", "keypad" (TPU), "joy_cap",
// "bay_cap", "bay_gasket" (TPU); views "bay_view", "section"; checks "check_*" (see the end).
PART = "assembly";

// ------------------------- YOUR BIKE (MEASURE) ------------------------
bar_d = 22.2;               // MEASURE: the handlebar (22.2 = 7/8")
gap_w = 20;                 // MEASURE: the room on the bar between the grip and the switch cube (slide the cube inboard)
cube = [55, 45, 30, 22];    // MEASURE: the switch cube: width along the bar, depth, top above and bottom below the bar's
                            //   centre (the fit check, the pictures, and the height limit: top_room)
grip_d = 32;                // MEASURE: the grip's diameter (the fit check)
joy_a = 195;                // SELECT (185-200): where the joystick sits round the bar (180 = straight back, level with the bar's
                            //   centre; 195 = a little below it); the buttons follow it up and over the top
pod_tilt = 20;              // SELECT (0-25): the face tilted toward the grip (degrees), so the thumb reaches it from the grip
bay_a = 300;                // SELECT: where the electronics bay hangs (270 = straight down; 300 = a little forward, clear of the hinge)
top_room = 0.5;             // nothing stands higher than this below the switch cube's top (cube[2])

// ------------------------- THE SWITCHES (MEASURE) ----------------------
nav_sw = [10, 10, 4.0];     // MEASURE: the 5-way switch's body (width, length, height above the carrier)
nav_top = 7.0;              // MEASURE: its stem's top above the carrier
nav_stem_d = 3.5;           // MEASURE: the stem (the cap pushes on and grips it)
nav_legs = [9, 4.0];        // MEASURE: its legs come down in 2 rows this long, this far either side of its middle
tact = [6, 6];              // MEASURE: the tactile switches (the buttons), 6 x 6 mm (pins at +-3.25 x +-2.25)
tact_heights = [4.3, 5, 6, 7, 8, 9, 9.5, 10, 11, 12, 13];   // their heights sold (actuator top above the board): the model
                            //   picks the tallest that suits the domes (see the echo)
tact_body = 3.5;            //   their body's height; the round actuator (3.5 mm) rises into the keypad's hollow dome
buttons = 4;                // SELECT: 2 or 4 buttons, in one column above the joystick, up and over the bar
btn_y = 13;                 // along the face: the joystick to button 1
btn_gap = 13;               //   button 1 to button 2 (the two switch carriers meet between them)
btn_pitch = 10.5;           //   button 2 to 3, 3 to 4

// ------------------------- THE BOARDS IN THE BAY (MEASURE) -------------
mcu = [22.52, 18, 4.5];     // ESP32-C3 Super Mini: length, width (nologo.tech), thickness with its parts (MEASURE)
can_pcb = [26, 16, 6];      // MEASURE: the SN65HVD230 module: length, width, thickness with its header

// ------------------------- COLLAR --------------------------------------
collar_w = gap_w - 1;       // the collar's width along the bar (0.5 mm either side)
rubber = 1.0;               // rubber strip inside the ring (self-adhesive: in the top half it also holds the carriers in)
ring_t = 3.0;               // the ring's wall
pod_wall = 2.0;             // the face's side walls
end_wall = 2.5;             // its end walls (at the face)
wall_min = 1.2;             // the thinnest wall beside the carriers (on the switch cube's side)
plate_t = 2.0;              // the face's thickness
skin = 0.8;                 // the keypad's sheet and skirt (TPU)
kp_c = 0.1;                 // the keypad's clearance in the face
squeeze = 0.2;              // how much the carriers squeeze the keypad's skirt against the face (the seal)
pad_t = 1.6;                // the carrier under each switch (its legs come through it)
wires = 2.5;                // the wire pocket under each switch (legs soldered to the wires there)
side_r = 4.5;               // the face's sides rounded (across the bar)
end_r = 5;                  // its ends rolled over
proud = 0.7;                // each button's top stands this far above the face
cup = [0.8, 1.3];           // each button's cup: its depth at the button, and how far it reaches round it at the face
rib_d = 1.8;                // the ridge between buttons 2 and 3 (to count them with gloves)
cap_lift = 2.4;             // the joystick's cap floats this far above the face (room to tilt)
dome_in = [8, 8];           // buttons 1 and 2: round
dome_out = [10, 7];         // buttons 3 and 4: pills, wider across the bar (so they feel different)
cap_d = 13;                 // the joystick's cap
cap_h = 4.5;
sleeve_d = 6.5;             // its sleeve, down through the face and the keypad onto the stem
cap_travel = 14;            // the joystick tilts up to this (degrees)
groove = [4.5, 1.0];        // the wires' groove in the bore, round the back to the bay: width, depth
m2_insert_d = 3.2;          // M2 heat-set inserts: the bay cap's 2
m25_insert_d = 3.6;         // M2.5 heat-set insert (4 mm long): the front screw's, in the top half
screw_lens = [6, 8, 10, 12, 14, 16, 18, 20, 25, 30];   // the M2.5 lengths to choose from (the model picks; see the echo)
// Where the halves meet (degrees round the bar): the front screw and the hinge at the back.
a_f = 35;                   // the front: an M2.5 from underneath into an insert in the top half
a_b = 240;                  // the back: the hinge
ear_f = 19.6;               // the front screw crosses the split this far from the bar's axis
front_seat = 4;             // the bottom half under its head
front_dir = 160;            // the screw's direction, head to tip (degrees round the bar: its head comes in from the front, clear of the bay)
knuckle_r = 3.0;            // the hinge's knuckles
pin_d = 2.0;                // the hinge pin (a 2 mm steel pin, 19 mm long; or an M2 x 20 screw)

// ------------------------- BAY -----------------------------------------
bay_wall = 1.6;
bay_gap = 1.5;              // between the two boards
bay_cr = 2;                 // the bay's inside corners rounded
cap_t = 3.0;                // the bay's cap (a rounded dish)
cable_d = 4.8;              // the 4-core cable to the dash, through the cap (sealed with silicone)

// ------------------------- DERIVED --------------------------------------
$fn = 64;
ring_r = bar_d/2 + rubber + ring_t;          // the ring's outside
bore_r = bar_d/2 + rubber;
tilt_ = max(pod_tilt, 0.01);
st = sin(tilt_);
ct = cos(tilt_);
inner0 = collar_w - 2*pod_wall;              // the inside's width across the face
z_seat = -plate_t - skin;                    // the keypad's sheet, under the face (control frame)
// The switches' bases (the carriers' pockets): the joystick's flat body stays under the keypad's sheet, which curves down
// round the bar toward the body's ends (r_s: the sheet's smallest radius, a little under the real one).
r_s = bore_r + wires + pad_t + nav_sw[2];
sheet_sag = r_s - sqrt(r_s*r_s - nav_sw[1]*nav_sw[1]/4);
z_btop = z_seat - 0.3 - nav_sw[2] - sheet_sag;
w_ct = z_btop + squeeze;                     // the carriers' top (into the keypad's skirt: the squeeze)
w0 = z_btop - 0.4;                           // the keypad's room goes down to here
stem_top = z_btop + nav_top;
z_sl = z_btop + nav_sw[2] + 0.9;              // the joystick cap's sleeve reaches down to here (clear of the switch's body when tilted)
sw_hole_d = sleeve_d + 2*(-(z_btop + nav_sw[2]))*tan(cap_travel) + 0.8;   // the joystick's hole: its sleeve tilts about the switch's top
// The face's radius (at its middle line): deep enough for the joystick, its carrier and the wires under it.
R_f = ceil(10*(bore_r + wires + (pad_t - z_btop)*ct + (nav_sw[0]/2 + 0.5)*st))/10;
// Across the face: a point (u across, w out of the face) of a control's section, in the ring's (r, x) plane.
function X(u, w) = u*ct - w*st;              // (relative to x_c)
car_u = inner0/2 - 0.15;                     // the carriers' top corners
cav_x1 = max(X(inner0/2, w0), X(car_u, w_ct) + 0.15);
x_c = collar_w/2 - wall_min - cav_x1;        // the face's middle line along the bar: the inside stays wall_min inside the collar on the cube's side
car_x = [x_c + X(-car_u, w_ct), x_c + X(car_u, w_ct)];   // the carriers' sides (straight down: they don't lean with the face)
cav_x = [car_x[0] - 0.15, x_c + cav_x1];
function L(u, w) = [R_f + u*st + w*ct, x_c + X(u, w)];   // -> (r, x)
function to_rx(pts) = [for (p = pts) L(p[0], p[1])];
// Round the bar: s along the face (at its middle line) from the joystick toward the top.
function th(s) = joy_a - s/R_f*180/PI;
btn_s = buttons == 4 ? [btn_y, btn_y + btn_gap, btn_y + btn_gap + btn_pitch, btn_y + btn_gap + 2*btn_pitch] : [btn_y, btn_y + btn_gap];
btn_n = len(btn_s);
btn_a = [for (s = btn_s) th(s)];
function btn_dome(i) = (buttons == 4 && i >= 2) ? dome_out : dome_in;
// The inside's ends (radial): clear of the end switches' bodies where they're lowest (the grip side), and of the keypad's
// skirt there.
function r_base(u) = R_f + u*st + z_btop*ct;
// (plus the sideways creep of the end switches on their carrier's slanted way in, until they're under the keypad)
creep = [(nav_sw[2] + 0.3)*tan(abs(joy_a - (joy_a + btn_a[0])/2))/(ct*ct) + 0.2, (tact_body + 0.3)*tan(abs(btn_a[btn_n - 1] - (btn_a[1] + btn_a[btn_n - 1])/2))/(ct*ct) + 0.2];
a_bot_in = joy_a + atan((nav_sw[1]/2 + 0.3 + skin + 0.1 + creep[0])/r_base(-nav_sw[0]/2));
a_top_in = btn_a[btn_n - 1] - max(atan((tact[1]/2 + 0.3 + skin + 0.1 + creep[1])/r_base(-tact[0]/2)),
                                  (btn_dome(btn_n - 1)[1]/2 + 0.3 + cup[1] + skin)/(R_f - plate_t)*180/PI);
a_face_bot = a_bot_in + end_wall/R_f*180/PI;
a_face_top = a_top_in - end_wall/R_f*180/PI;
// The tactile switches: the shortest whose actuator reaches up through the keypad's sheet into its dome (not deeper:
// the carriers go in at an angle, so the actuators mustn't reach far into the domes), the dome's roof at least 0.8.
tact_h = min([for (h = tact_heights) if (z_btop + h >= z_seat + skin && z_btop + h + 0.3 <= proud - 0.8) h]);
btn_roof = z_btop + tact_h + 0.3;            // the hollow dome's roof (underside)
joy_z0 = cap_lift;                           // the joystick cap's underside (control frame)
// The joystick sits this far toward the switch cube: its carrier goes in square to the bar, so with the face tilted the
// switch drifts toward the grip (tan(tilt) per mm) while it drops under the keypad's skirt.
// (it sinks below the skirt's foot at cos^2(tilt) per mm of travel, drifting sin(tilt) per mm meanwhile)
joy_u = max(0, tan(tilt_)*(nav_sw[2] + 0.3)/ct + 0.15 - (inner0/2 - kp_c - skin - nav_sw[0]/2));
pivot = [0, 0, z_btop + nav_sw[2]];          // MEASURE: where the 5-way switch's stem pivots (taken at its body's top)
rib_s = (btn_s[1] + btn_dome(1)[1]/2 + btn_s[min(2, btn_n - 1)] - btn_dome(min(2, btn_n - 1))[1]/2)/2;
// The 2 switch carriers: [the joystick + button 1], [buttons 2 ...]. Each goes in from the bar's side straight along
// its own middle direction (n_g); they meet at P, between buttons 1 and 2, where each is trimmed by the other's path.
g_a = [(joy_a + btn_a[0])/2, (btn_a[1] + btn_a[btn_n - 1])/2];
s_P = (btn_s[0] + btn_s[1])/2;
a_P = th(s_P);
r_P = R_f + (z_btop + 0.3)*ct;
P = [0, r_P*cos(a_P), r_P*sin(a_P)];
function tg(a) = [0, sin(a), -cos(a)];       // round the bar toward the top, at a
function nrm(a) = [0, cos(a), sin(a)];       // out from the bar, at a
yP = [P*tg(g_a[0]), P*tg(g_a[1])];
sweep = 12;                                  // the straight part of each carrier's way in (then it's in the free bore)
// The highest point: the face's section at its highest, and the buttons' tops.
face_top_r = R_f + max([for (a = [0:5:90]) (collar_w/2 - side_r + side_r*cos(a))*st + (-side_r + side_r*sin(a))*ct]);
top_z = max(concat([(a_face_top <= 90 && a_face_bot >= 90) ? face_top_r : face_top_r*max(sin(a_face_top), sin(a_face_bot))],
                   [for (i = [0:btn_n - 1]) (R_f + proud*ct + btn_dome(i)[0]/2*st)*sin(btn_a[i])]));
// The bay: down bay_a, as wide as the collar, the 2 boards on edge side by side.
E = [0, cos(bay_a), sin(bay_a)];
YB = [0, sin(bay_a), -cos(bay_a)];
BAY_M = [[1, 0, 0, 0], [0, YB[1], E[1], 0], [0, YB[2], E[2], 0], [0, 0, 0, 1]];
bay_in = [collar_w - 2*bay_wall, max(mcu[1], can_pcb[0]) + 1, max(mcu[0], can_pcb[1]) + 1.5];   // across, round, down
bay_r0 = bore_r + 1.0;                       // the bay's inside starts here (below the bore)
bay_r1 = bay_r0 + bay_in[2];                 // its bottom (the cap's seat)
bay_boss_y = bay_in[1]/2 + 3.3;              // the cap's 2 screws, in lobes at the bay's ends
function ang_of(p) = let(a = atan2(p[2], p[1])) a < 0 ? a + 360 : a;   // round the bar (0 = forward, 90 = up)
bay_back_a = ang_of(BAY_M*[0, bay_in[1]/2 + bay_wall, bay_r0, 1]);     // the bay's back wall, at its top
bay_front_a = ang_of(BAY_M*[0, -bay_in[1]/2 - bay_wall, bay_r0, 1]);
slot_x = (car_x[0] + car_x[1])/2;            // the wires' groove, along the bar (under the carriers)
// The front screw: square to the split at a_f, its head in the bottom half, into an insert in the top half.
F_A = ear_f*nrm(a_f);
F_u = nrm(front_dir);                        // toward the top half
front_len = front_seat + 4;
// The hinge pin, at the back, a knuckle's radius inside the body's surface (so the bottom half swings open clear of the
// top: what lies outside the pin is within the knuckles' room): where the hull's outline (seen along the bar) crosses a_b, between the face's rolled
// bottom end and the bay's back.
function cross2(p, q) = p[1]*q[2] - p[2]*q[1];
function ray_hit(p, q, a) = cross2(p, q)/cross2(nrm(a), q - p);           // where segment p-q meets the ray at a (its radius)
face_end_pts = [for (k = [0:3]) let(d = 0.9*end_r*k/3, sh = k == 0 ? 0 : end_r - sqrt(end_r*end_r - d*d)) (face_top_r - sh)*nrm(a_face_bot + d/R_f*180/PI)];
bay_back_pts = [for (z = [bay_r0 - 1, bay_r1], y = [bay_in[1]/2 + bay_wall, bay_boss_y + 3.3]) let(p = BAY_M*[0, y, z, 1]) [0, p[1], p[2]]];
hinge_r = max(concat([ring_r + 1], [for (f = face_end_pts, b = bay_back_pts) if (ang_of(f) < a_b && ang_of(b) > a_b) ray_hit(f, b, a_b)])) + 0.8 - knuckle_r;   // (the knuckles' room clears what's within knuckle_r of the pin)
Q = hinge_r*nrm(a_b);
echo(face_r = R_f, joystick_at = joy_a, buttons_at = btn_a, top_above_bar = top_z, switch_cube_top = cube[2],
     tactile_switches = str("6 x 6 x ", tact_h), front_screw = str("M2.5 x ", front_len, " socket cap"),
     face_from = a_face_top, face_to = a_face_bot, hinge_r = hinge_r, x_c = x_c, carriers_at = g_a, bay_below_axis = bay_r1 + 0.6 + cap_t);

// ------------------------- CHECKS ------------------------------------
assert(collar_w >= 18, "The gap is too narrow for the collar: make gap_w at least 19 mm (slide the switch cube inboard).");
assert(buttons == 2 || buttons == 4, "buttons: 2 or 4.");
assert(top_z <= cube[2] - top_room, str("The controls stand ", top_z, " mm above the bar's centre: higher than the switch cube's top (", cube[2], ") less top_room. Turn them back (joy_a up) or use 2 buttons."));
assert(z_btop + tact_body <= z_seat - 0.3, "The tactile switches' bodies are too tall for the keypad.");
assert(tact_h != undef && z_btop + tact_h >= z_seat + skin, "No tactile switch height in tact_heights suits the domes (proud).");
assert(nav_sw[0]/2 + joy_u + 0.15 <= inner0/2 - kp_c - skin + 0.001, "The joystick's switch doesn't fit inside the keypad's skirt.");
assert(stem_top - 0.3 - z_sl >= 1.8, "The joystick's stem is too short for its cap to grip it (nav_top).");
assert(btn_y - dome_in[1]/2 - 0.6 >= sw_hole_d/2, "Button 1 is too close to the joystick (btn_y).");
assert(max(dome_in[0], dome_out[0])/2 + 0.3 <= inner0/2 - skin, "The buttons are too wide for the keypad's skirt.");
assert(buttons == 2 || btn_pitch - (dome_in[1] + dome_out[1])/2 - 0.6 >= 2.0, "Buttons 2 and 3 are too close for the ridge between them (btn_pitch).");
// the switches' bodies don't meet where they sit (lowest, on the grip side): the joystick and button 1, then button 1
// and 2 with the carriers' join between them, then the rest
function base_pt(a, y) = r_base(-tact[0]/2)*nrm(a) + y*tg(a);       // a switch's base corner (on the grip side, where it's lowest)
function base_gap(a1, h1, a2, h2) = norm(base_pt(a1, h1) - base_pt(a2, -h2));
assert(base_gap(joy_a, nav_sw[1]/2, btn_a[0], tact[1]/2) >= 1.0, "The joystick's and button 1's switches meet under the face (btn_y).");
assert(base_gap(btn_a[0], tact[1]/2, btn_a[1], tact[1]/2) >= 1.6, "Buttons 1 and 2 are too close where the two carriers meet (btn_gap).");
assert(buttons == 2 || base_gap(btn_a[1], tact[1]/2, btn_a[2], tact[1]/2) >= 1.0, "The buttons' switches meet under the face (btn_pitch).");
assert(car_x[0] - 0.15 >= -collar_w/2 + 1.0, "The carriers come too close to the grip's side of the collar.");
assert(a_face_top >= a_f + 15, "The face's top end comes too close to the front screw: turn the controls back (joy_a up).");
assert(a_face_bot <= a_b - 9, "The face's bottom end comes too close to the hinge: turn the controls forward (joy_a down).");
assert(a_b - a_f <= 210, "The top half wraps too far round the bar to go on (a_b - a_f up to 210 degrees).");
assert(bay_back_a >= a_b + 3 && bay_front_a <= a_f + 360 - 15, "The bay comes too close to the hinge or the front screw (bay_a).");
assert(abs(slot_x) + groove[0]/2 <= collar_w/2 - 1, "The wires' groove runs off the collar: less pod_tilt.");
assert(pod_tilt >= 0 && pod_tilt <= 25, "pod_tilt: 0 to 25 degrees (steeper, the joystick's switch can't pass the keypad's skirt on its way in).");
assert(len([for (l = screw_lens) if (l == front_len) 1]) > 0, "No front screw length in screw_lens suits (front_seat).");

// ------------------------- HELPERS ------------------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center=true);
function ctl_M(a) = let(XP = [ct, st*cos(a), st*sin(a)], YP = tg(a), ZP = [-st, ct*cos(a), ct*sin(a)], O = [x_c, R_f*cos(a), R_f*sin(a)])
  [[XP[0], YP[0], ZP[0], O[0]], [XP[1], YP[1], ZP[1], O[1]], [XP[2], YP[2], ZP[2], O[2]], [0, 0, 0, 1]];
module ctl(a) multmatrix(ctl_M(a)) children();
module btn_frame(i) ctl(btn_a[i]) children();
module joy_frame() ctl(joy_a) translate([joy_u, 0, 0]) children();
module bay_frame() multmatrix(BAY_M) children();
module bar_x(d, l) rotate([0, 90, 0]) cylinder(d=d, h=l, center=true);
module slab(w) translate([-w/2, -100, -100]) cube([w, 200, 200]);   // |x| <= w/2
// A 2D shape in the ring's (r, x) plane, turned round the bar from angle a0 to a1.
module arc(a0, a1, fn=96) rotate([0, 90, 0]) rotate([0, 0, a0 + 90]) rotate_extrude(angle=a1 - a0, $fn=fn) children();
module wedge(a0, a1) arc(a0, a1) translate([0, -100]) square([100, 200]);   // the angles a0..a1 round the bar
// The half-space on one side of a plane through P, square to tg(a): side -1 toward the joystick, +1 toward the top.
module side_of(a, v, s) multmatrix([[1, 0, 0, 0], [0, sin(a), cos(a), 0], [0, -cos(a), sin(a), 0], [0, 0, 0, 1]])
  translate([-100, s > 0 ? v : v - 200, -100]) cube([200, 200, 200]);
function invert(M) = let(R = [[M[0][0], M[1][0], M[2][0]], [M[0][1], M[1][1], M[2][1]], [M[0][2], M[1][2], M[2][2]]], t = -R*[M[0][3], M[1][3], M[2][3]])
  [[R[0][0], R[0][1], R[0][2], t[0]], [R[1][0], R[1][1], R[1][2], t[1]], [R[2][0], R[2][1], R[2][2], t[2]], [0, 0, 0, 1]];
function unit(v) = v/norm(v);
function axis_m(p, u) = let(x0 = unit([1, 0, 0] - u[0]*u), y0 = cross(u, x0))
  [[x0[0], y0[0], u[0], p[0]], [x0[1], y0[1], u[1], p[1]], [x0[2], y0[2], u[2], p[2]], [0, 0, 0, 1]];   // z along u, at p

// ------------------------- THE SWITCHES (view only, and for the checks) ----
module joy_switch(stem=true) joy_frame() {
  color([0.2, 0.2, 0.22]) translate([0, 0, z_btop]) linear_extrude(nav_sw[2]) square([nav_sw[0], nav_sw[1]], center=true);
  if (stem) color([0.7, 0.7, 0.72]) translate([0, 0, z_btop]) cylinder(d=nav_stem_d, h=nav_top, $fn=24);
}
module btn_switch(i) btn_frame(i) translate([0, 0, z_btop]) {
  color([0.15, 0.15, 0.16]) linear_extrude(tact_body) square([tact[0], tact[1]], center=true);
  color([0.3, 0.3, 0.32]) cylinder(d=3.5, h=tact_h, $fn=24);                   // the actuator
}
module switches(stem=true) { joy_switch(stem); for (i = [0:btn_n - 1]) btn_switch(i); }
module group_switches(g, stem=true) {
  if (g == 0) { joy_switch(stem); btn_switch(0); }
  else for (i = [1:btn_n - 1]) btn_switch(i);
}
// In the bay (bay frame): the ESP32-C3 on edge against the outboard wall, its USB-C at the bottom; the transceiver beside it.
mcu_x = -bay_in[0]/2 + 0.3;
can_x = mcu_x + mcu[2] + bay_gap;
module bay_boards() bay_frame() {
  color([0.15, 0.15, 0.17]) translate([mcu_x, -mcu[1]/2, bay_r0 + 0.5]) cube([mcu[2], mcu[1], mcu[0]]);
  color([0.1, 0.3, 0.6]) translate([can_x, -can_pcb[0]/2, bay_r0 + 0.5]) cube([can_pcb[2], can_pcb[0], can_pcb[1]]);
}

// ------------------------- THE BODY ------------------------------------
// ONE smooth convex hull (owner, 2026-11-25: "make it an organic shape") over the ring (its edges rounded), the curved
// face (its ends rolled), the bay's top and floor, and the front screw's boss. The halves, the insides and the holes
// are all cut from it.
ring_round = 2.5;
module ring_solid() rotate([0, 90, 0]) rotate_extrude($fn=96)
  offset(r=ring_round) offset(delta=-ring_round) translate([0, -collar_w/2]) square([ring_r, collar_w]);
// The face's section (control frame u, w): its top rounded at the sides, down into the ring.
function face_sec(g=0) = let(w = collar_w + 2*g, sr = side_r, zl = -12)
  concat([[-w/2, zl]], [for (a = [180:-15:90]) [-w/2 + sr + sr*cos(a), g - sr + sr*sin(a)]],
         [for (a = [90:-15:0]) [w/2 - sr + sr*cos(a), g - sr + sr*sin(a)]], [[w/2, zl]]);
module face_2d(g=0) polygon(to_rx(face_sec(g)));
module face_arc() {
  arc(a_face_top, a_face_bot, 128) face_2d();
  for (k = [1:3], e = [[a_face_top, -1], [a_face_bot, 1]]) let(d = 0.9*end_r*k/3, sh = end_r - sqrt(end_r*end_r - d*d), a = e[0] + e[1]*d/R_f*180/PI)
    arc(a - 0.01, a + 0.01, 4) offset(delta=-sh) face_2d();                 // the ends rolled over
}
module shell() hull() {
  ring_solid();
  face_arc();
  bay_frame() {
    translate([0, 0, bay_r0 - 1]) linear_extrude(0.01) hull() bay_outline();
    translate([0, 0, bay_r1 - 1.5]) linear_extrude(1.5) hull() bay_outline();                      // the floor (flat: the cap's seat)
  }
  multmatrix(axis_m(F_A, F_u)) translate([0, 0, -front_seat - 2]) cylinder(d=9, h=front_seat + 8, $fn=32);   // the front screw's boss
}
module body() shell();

// ------------------------- THE INSIDE ----------------------------------
// The keypad's room under the face (a cone round the bar), and each carrier's room with the way it goes in.
module kz_2d() polygon(to_rx([[-inner0/2, w0], [inner0/2, w0], [inner0/2, -plate_t], [-inner0/2, -plate_t]]));
module car_2d(cl=0) let(u = car_u + cl, wt = w_ct + (cl > 0 ? 0.3 : 0))
  polygon([[R_f - u*st + wt*ct, car_x[0] - cl], [R_f + u*st + wt*ct, car_x[1] + cl], [0, car_x[1] + cl], [0, car_x[0] - cl]]);
function g_range(g) = g == 0 ? [a_P - 25, a_bot_in] : [a_top_in, a_P + 25];
// the carriers stop short of the keypad's end walls (they'd catch them on the way in)
kp_end = (kp_c + skin + 0.3)/r_base(-inner0/2)*180/PI;
function c_range(g) = g == 0 ? [a_P - 25, a_bot_in - kp_end] : [a_top_in + kp_end, a_P + 25];
module g_side(g, c=0) if (g == 0) side_of(g_a[0], yP[0] - c, -1); else side_of(g_a[1], yP[1] + c, 1);
module kz() arc(a_top_in, a_bot_in, 128) kz_2d();
// A group's switches (bodies, actuators or stem) grown by cl, and swept along their carrier's way in.
module sw_env(g, cl=0.3) {
  for (c = g_ctls(g)) ctl(c[0]) translate([c[0] == joy_a ? joy_u : 0, 0, 0]) {
    translate([0, 0, z_btop - 0.5]) linear_extrude(c[1][2] + 0.5 + cl) square([c[1][0] + 2*cl, c[1][1] + 2*cl], center=true);
    translate([0, 0, z_btop - 0.5]) cylinder(d=(c[0] == joy_a ? nav_stem_d : 3.5) + 2*cl, h=(c[0] == joy_a ? nav_top : tact_h) + 0.5 + cl, $fn=24);
  }
}
module sw_sweep(g, cl=0.3) for (c = g_ctls(g)) hull() for (k = [0, sweep]) translate(-k*nrm(g_a[g])) intersection() {
  sw_env(g, cl);
  ctl(c[0]) translate([-20, -10, -20]) cube([40, 20, 40]);                       // (one switch at a time)
}
module car_room(g) intersection() {
  union() {
    hull() for (k = [0, sweep]) translate(-k*nrm(g_a[g])) arc(g_range(g)[0], g_range(g)[1]) car_2d(0.15);
    sw_sweep(g);                                                                   // the switches on their way in
  }
  g_side(g);
}
function g_ctls(g) = g == 0 ? [[joy_a, nav_sw], [btn_a[0], [tact[0], tact[1], tact_body]]] : [for (i = [1:btn_n - 1]) [btn_a[i], [tact[0], tact[1], tact_body]]];
module inside() { kz(); car_room(0); car_room(1); }

// ------------------------- SWITCH CARRIERS ----------------------------
// Each: the carrier's section round the bar, trimmed where it meets the other (both ways in stay clear), its bottom on
// the bore; under each switch a flat pocket for its base, holes for its legs, and a wire pocket below; the wires'
// groove along its underside.
module sw_pocket(a, s, legs, nav=false, u=0) ctl(a) translate([u, 0, 0]) {
  translate([0, 0, z_btop]) linear_extrude(5) square([s[0] + 0.4, s[1] + 0.4], center=true);          // the switch's base
  if (nav) for (y = [-1, 1]) translate([0, y*legs[1], z_btop - pad_t - 1]) linear_extrude(pad_t + 1.1) square([legs[0], 1.2], center=true);
  else for (x = [-3.25, 3.25], y = [-2.25, 2.25]) translate([x, y, z_btop - pad_t - 1]) cylinder(d=1.3, h=pad_t + 1.1, $fn=12);
}
// The wires' channel: under all of a carrier's switches, pad_t below their bases (the cone round the bar), 0.8 in from
// its sides, stopping 1.5 mm short of the carrier's ends.
module wire_channel(g) let(r0 = c_range(g)[0] + 1.5/(R_f - 8)*180/PI, r1 = c_range(g)[1] - 1.5/(R_f - 8)*180/PI,
                           x0 = car_x[0] + 0.8, x1 = car_x[1] - 0.8, w = z_btop - pad_t, u0 = (x0 - x_c + w*st)/ct, u1 = (x1 - x_c + w*st)/ct)
  arc(r0, r1) polygon([[bore_r - 1, x0], [L(u0, w)[0], x0], [L(u1, w)[0], x1], [bore_r - 1, x1]]);
module carrier(g) difference() {
  intersection() {
    arc(c_range(g)[0], c_range(g)[1]) car_2d(0);
    g_side(g, 0.15);                                                          // its own side of the join ...
    if (g == 0) side_of(g_a[1], yP[1] - 0.15, -1); else side_of(g_a[0], yP[0] + 0.15, 1);   // ... and out of the other's way in
  }
  bar_x(2*bore_r, 200);
  wire_path();
  if (g == 0) sw_sweep(1, 0.2);                                               // (button 2's switch passes its corner on the way in)
  wire_channel(g);
  if (g == 0) { sw_pocket(joy_a, nav_sw, nav_legs, true, joy_u); sw_pocket(btn_a[0], tact, 0); }
  else for (i = [1:btn_n - 1]) sw_pocket(btn_a[i], tact, 0);
}
module carrier_joy() carrier(0);
module carrier_btn() carrier(1);

// ------------------------- COLLAR -------------------------------------
// The wires: a groove in the bore from the top of the face round the back to the bay, and a slot up into it.
module wire_path() {
  arc(a_top_in + 2, bay_a, 96) translate([bore_r - 0.5, slot_x - groove[0]/2]) square([groove[1] + 0.5, groove[0]]);
  bay_frame() translate([slot_x, 0, bore_r - 0.5]) cylinder(d=groove[0], h=bay_r0 - bore_r + 1, $fn=20);
}
// The front screw: an M2.5 socket cap from underneath, its head in a counterbore in the bottom half, into an insert
// in the top half (pressed into its split face).
F_M = axis_m(F_A, F_u);
front_tunnel = 30;          // the head's way in from below
module front_clear(cb=true) multmatrix(F_M) {
  translate([0, 0, -front_seat]) cylinder(d=2.9, h=front_seat + 0.01, $fn=20);
  if (cb) translate([0, 0, -front_seat - front_tunnel]) cylinder(d=5, h=front_tunnel, $fn=24);
}
module front_insert() multmatrix(F_M) translate([0, 0, -0.01]) cylinder(d=m25_insert_d, h=4.6, $fn=20);
// The hinge at the back: knuckles round a pin along the bar at Q: the top half's at both ends, the bottom half's in
// the middle; each knuckle joins its own half on its own side of the split.
k_mid = 3.0;                // the middle knuckle: |x| <= this (minus 0.2 either side)
module at_Q() translate(Q) rotate([0, 90, 0]) children();
module knuckle_x(top) if (top) for (s = [-1, 1]) translate([s*(collar_w/2 + k_mid)/2, 0, 0]) slab(collar_w/2 - k_mid); else slab(2*k_mid - 0.4);
module knuckles(top) intersection() {
  knuckle_x(top);
  union() {
    at_Q() cylinder(r=knuckle_r, h=40, center=true, $fn=32);
    difference() {                                                                // the web to its own half
      hull() { at_Q() cylinder(r=knuckle_r, h=40, center=true, $fn=32); translate(Q - 6*nrm(a_b) + (top ? -1 : 1)*3*tg(a_b + 180)) bar_x(2*knuckle_r, 40); }
      if (top) wedge(a_b, a_b + 120); else wedge(a_b - 120, a_b);
    }
  }
}
module knuckle_room(top) intersection() {                                       // the other half's knuckle swings here (and the gaps between them)
  if (top) difference() { slab(60); slab(2*k_mid - 0.4); } else slab(2*k_mid);
  at_Q() cylinder(r=knuckle_r + 0.3, h=40, center=true, $fn=32);
}
module pin() at_Q() cylinder(d=pin_d + 0.15, h=collar_w + 2, center=true, $fn=16);
module grip_room() translate([grip_x - 100, 0, 0]) bar_x(grip_d + 2, 200);   // 1 mm clear of the grip
module collar_top() difference() {
  union() {
    intersection() { shell(); wedge(a_f, a_b); }
    knuckles(true);
  }
  translate([collar_w/2, -100, -100]) cube(200);                                  // off the switch cube's side
  grip_room();
  bar_x(2*bore_r, 200);
  inside();
  wire_path();
  front_insert();
  knuckle_room(false); pin();
  joy_frame() translate([0, 0, -plate_t - 1]) cylinder(d=sw_hole_d, h=plate_t + 12);   // the joystick's sleeve
  for (i = [0:btn_n - 1]) {
    btn_frame(i) translate([0, 0, -plate_t - 1]) linear_extrude(plate_t + 12) btn_2d(i, 0.3);   // the domes
    cup_cut(i);
  }
}
module collar_bottom() difference() {
  union() {
    intersection() { shell(); wedge(a_b, a_f + 360); }
    knuckles(false);
  }
  translate([collar_w/2, -100, -100]) cube(200);
  grip_room();
  bar_x(2*bore_r, 200);
  bay_frame() {
    translate([0, 0, bay_r0]) linear_extrude(bay_in[2] + 1) rrect([bay_in[0], bay_in[1]], bay_cr);   // open at the bottom, corners rounded
    for (s = [-1, 1]) translate([0, s*bay_boss_y, bay_r1 - 5]) cylinder(d=m2_insert_d, h=5.1, $fn=20);   // M2 inserts
  }
  wire_path();
  front_clear();
  knuckle_room(true); pin();
}
// The buttons' cups and the ridge (in the face).
module btn_2d(i, o=0) let(d = btn_dome(i)) offset(o) rrect(d, min(d)/2 - 0.01);
module cup_cut(i) btn_frame(i) hull() {                                   // a shallow cup round the button
  translate([0, 0, -cup[0]]) linear_extrude(0.01) btn_2d(i, 0.6);                 // (wider than the dome's hole)
  translate([0, 0, 2.4]) linear_extrude(0.01) btn_2d(i, 0.6 + cup[1]*(2.4 + cup[0])/cup[0]);
}
module ribs() if (buttons == 4) ctl(th(rib_s)) hull() for (x = [-1, 1]) translate([x*4, 0, 0.1]) sphere(d=rib_d, $fn=16);

// ------------------------- KEYPAD, CAP --------------------------------
// The keypad (TPU): the sheet under the face and a skirt round its edge (its foot on the carriers), the domes.
module keypad() {
  da = kp_c/(R_f - plate_t)*180/PI;
  dw = skin/(r_base(-inner0/2))*180/PI;                                         // the skirt's ends (radial)
  difference() {
    union() {
      let(o = inner0/2 - kp_c, i = o - skin, t = z_seat + skin - 0.02)            // the sheet and the skirt's sides: one section
        arc(a_top_in + da, a_bot_in - da, 128) polygon(to_rx([[-o, z_btop], [-o, t], [o, t], [o, z_btop], [i, z_btop], [i, z_seat], [-i, z_seat], [-i, z_btop]]));
      for (e = [[a_top_in + da, a_top_in + da + dw], [a_bot_in - da - dw, a_bot_in - da]]) arc(e[0], e[1], 8)   // its ends
        polygon(to_rx([[-inner0/2 + kp_c + skin/2, z_btop + 0.05], [inner0/2 - kp_c - skin/2, z_btop + 0.05], [inner0/2 - kp_c - skin/2, z_seat + skin/2], [-inner0/2 + kp_c + skin/2, z_seat + skin/2]]));
      for (i = [0:btn_n - 1]) btn_frame(i) hull() {                              // the domes
        translate([0, 0, z_seat + skin/2]) linear_extrude(0.01) btn_2d(i, -0.3);     // (its base inside the sheet)
        translate([0, 0, proud - 1.0]) linear_extrude(0.01) btn_2d(i, -0.3);
        translate([0, 0, proud - 0.01]) linear_extrude(0.01) btn_2d(i, -1.1);
      }
    }
    joy_frame() translate([0, 0, z_seat - 1]) cylinder(d=sleeve_d - 0.6, h=skin + 2, $fn=32);   // hugs the cap's sleeve
    for (i = [0:btn_n - 1]) btn_frame(i) translate([0, 0, z_seat - 1]) linear_extrude(btn_roof - z_seat + 1) btn_2d(i, btn_dome(i)[1] < 8 ? -1.0 : -1.3);   // hollow
  }
}
// The joystick's cap (control frame): k = 0 all, 1 the head only, 2 the sleeve only (for the tilt check).
module joy_cap_local(k=0) difference() {
  union() {
    if (k != 2) translate([0, 0, joy_z0]) intersection() {
      hull() { cylinder(d=cap_d, h=1.2); translate([0, 0, cap_h - 1.6]) scale([1, 1, 0.35]) sphere(d=cap_d - 2.5, $fn=48); }
      cylinder(d=cap_d + 1, h=cap_h);
    }
    if (k != 1) translate([0, 0, z_sl]) cylinder(d=sleeve_d, h=joy_z0 - z_sl + 0.01);
  }
  translate([0, 0, z_sl - 0.1]) cylinder(d=nav_stem_d - 0.15, h=stem_top - 0.3 - z_sl + 0.1, $fn=24);        // pushes onto the stem
  for (a = [0:45:315]) rotate(a) translate([cap_d/2 - 2.4, 0, joy_z0 + 1.0]) rotate([0, 90, 0]) cylinder(d=1.0, h=4, $fn=8);   // grip grooves
}
module joy_cap() joy_frame() joy_cap_local();

// ------------------------- BAY CAP AND GASKET -------------------------
module bay_outline() union() {
  rrect([collar_w, bay_in[1] + 2*bay_wall], 4);
  for (s = [-1, 1]) translate([0, s*bay_boss_y]) circle(d=6.6, $fn=32);
}
cap_rr = 2.0;               // the bay cap's rounded edge
module half_sphere(r, up) intersection() { sphere(r, $fn=20); translate([-r, -r, up > 0 ? 0 : -r]) cube(2*r); }
cap_z0 = bay_r1 + 0.6;      // the cap: on the gasket (squeezed 0.2) ...
cap_z1 = cap_z0 + cap_t;    // ... to its outside
module bay_gasket() bay_frame() translate([0, 0, bay_r1]) linear_extrude(0.8) difference() {
  offset(-0.3) bay_outline();
  difference() { rrect([bay_in[0] + 0.6, bay_in[1] + 0.6], bay_cr + 0.3); for (s = [-1, 1]) translate([0, s*bay_boss_y]) circle(d=7, $fn=32); }
  for (s = [-1, 1]) translate([0, s*bay_boss_y]) circle(d=2.4, $fn=16);
}
module bay_cap() bay_frame() difference() {
  hull() {                                                                                  // a rounded dish
    translate([0, 0, cap_z0]) linear_extrude(0.01) hull() bay_outline();
    translate([0, 0, cap_z1 - cap_rr]) minkowski() { linear_extrude(0.01) offset(-cap_rr) hull() bay_outline(); half_sphere(cap_rr, 1); }
  }
  for (s = [-1, 1]) translate([0, s*bay_boss_y, cap_z0 - 1]) { cylinder(d=2.3, h=cap_t + 2, $fn=16); translate([0, 0, 1 + cap_t - 1.2]) cylinder(d1=2.3, d2=4.2, h=1.21, $fn=16); }
  translate([can_x + can_pcb[2]/2, 0, cap_z0 - 1]) cylinder(d=cable_d, h=cap_t + 2, $fn=24);   // the cable to the dash
}

// ------------------------- ASSEMBLY -----------------------------------
grip_x = -gap_w/2;          // the grip's inner end
cube_x = gap_w/2;           // the switch cube's outboard face
module bike() {
  color([0.75, 0.75, 0.75, 0.6]) translate([-200, 0, 0]) bar_x(bar_d, 500);
  color([0.08, 0.08, 0.08]) translate([grip_x - 65, 0, 0]) bar_x(grip_d, 130);
  color([0.55, 0.56, 0.58, 0.45]) translate([cube_x, -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]);
}
module rot_Q(a) translate(Q) rotate([-a, 0, 0]) translate(-Q) children();   // about the hinge (+ opens the bottom half)
module remote_parts(e=0, eb=0) {   // e: taken apart; eb: only the bay's cap and gasket pulled off
  color([0.16, 0.17, 0.19]) translate(e*3.4*nrm((a_f + a_b)/2)) render(convexity=6) union() { collar_top(); ribs(); }
  color([0.16, 0.17, 0.19]) rot_Q(e*4) render(convexity=6) collar_bottom();
  translate(e*0.9*nrm(g_a[0])) { switches_g(0); color([0.35, 0.37, 0.4]) render(convexity=4) carrier_joy(); }
  translate(e*0.9*nrm(g_a[1])) { switches_g(1); color([0.35, 0.37, 0.4]) render(convexity=4) carrier_btn(); }
  rot_Q(e*4) bay_boards();
  translate(e*2.2*nrm((a_f + a_b)/2)) color([0.1, 0.1, 0.11]) render(convexity=4) keypad();
  translate(e*4.4*nrm((a_f + a_b)/2)) color([0.85, 0.45, 0.1]) joy_cap();
  rot_Q(e*4) translate((e*0.8 + eb)*E) color([0.1, 0.1, 0.1]) bay_gasket();
  rot_Q(e*4) translate((e*1.4 + 2*eb)*E) color([0.2, 0.21, 0.23]) bay_cap();
}
module switches_g(g) group_switches(g);
// For the print poses: each carrier on its flat switch-cube side.
module carrier_print(g) translate([0, 0, car_x[1]]) rotate([0, 90, 0]) carrier(g);

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") { bike(); remote_parts(0); }
else if (PART == "exploded") { bike(); remote_parts(9); }
else if (PART == "bay_view") { color([0.75, 0.75, 0.75, 0.6]) translate([-60, 0, 0]) bar_x(bar_d, 200); remote_parts(0, 12); }
else if (PART == "collar_top") translate([0, 0, collar_w/2]) rotate([0, 90, 0]) union() { collar_top(); ribs(); }   // its flat inboard side on the bed
else if (PART == "collar_bottom") translate([0, 0, collar_w/2]) rotate([0, 90, 0]) collar_bottom();
else if (PART == "carrier_joy") carrier_print(0);
else if (PART == "carrier_btn") carrier_print(1);
else if (PART == "keypad") translate([0, 0, -r_base(-inner0/2)*cos((a_bot_in - a_top_in)/2) + 0.6]) rotate([90 - (a_top_in + a_bot_in)/2, 0, 0]) keypad();   // TPU: an arch, its sheet on top (print with supports)
else if (PART == "joy_cap") rotate([180, 0, 0]) translate([0, 0, -joy_z0 - cap_h]) multmatrix(invert(ctl_M(joy_a))) joy_cap();   // flat top down
else if (PART == "bay_cap") translate([0, 0, cap_z1]) rotate([180, 0, 0]) multmatrix(invert(BAY_M)) bay_cap();   // its outside down
else if (PART == "bay_gasket") translate([0, 0, -bay_r1]) multmatrix(invert(BAY_M)) bay_gasket();
else if (PART == "section") { color([0.75, 0.75, 0.75]) intersection() { bar_x(bar_d, 60); translate([slot_x - 100, -100, -100]) cube([100, 200, 200]); } intersection() { remote_parts(0); translate([slot_x - 100, -100, -100]) cube([100, 200, 200]); } }
// Checks: must be empty (or only touch), unless marked "must collide".
else if (PART == "check_switches") intersection() { switches(false); union() { collar_top(); keypad(); joy_cap(); carrier_joy(); carrier_btn(); } }
else if (PART == "check_carriers") {                       // touch only: the switches on their carriers
  intersection() { group_switches(0, false); carrier_joy(); }
  intersection() { group_switches(1, false); carrier_btn(); }
}
else if (PART == "check_bay") intersection() { bay_boards(); union() { collar_bottom(); bay_cap(); bay_gasket(); } }
else if (PART == "check_stem") intersection() { switches(); joy_cap(); }                       // must collide: the cap's grip
else if (PART == "check_squeeze") intersection() { keypad(); union() { carrier_joy(); carrier_btn(); } }   // must collide: the seal
else if (PART == "check_bay_squeeze") intersection() { bay_gasket(); bay_cap(); }            // must collide: the bay's seal
else if (PART == "check_keypad_cap") intersection() { keypad(); joy_cap(); }                 // must collide lightly: the keypad hugs the sleeve
else if (PART == "check_parts") {
  intersection() { collar_top(); collar_bottom(); }
  intersection() { collar_top(); keypad(); }
  intersection() { collar_top(); joy_cap(); }
  intersection() { collar_top(); carrier_joy(); }
  intersection() { collar_top(); carrier_btn(); }
  intersection() { carrier_joy(); carrier_btn(); }
  intersection() { collar_bottom(); union() { carrier_joy(); carrier_btn(); } }
  intersection() { collar_bottom(); bay_cap(); }
  intersection() { collar_bottom(); bay_gasket(); }
}
// The carriers' way in (must be empty): each with its switches, moved back along its way in, against the collar top
// and the keypad (and the other carrier, already in: the joystick's goes first).
else if (PART == "check_insert") for (g = [0, 1], k = [0.6, 1.5, 3, 6, sweep]) intersection() {
  translate(-k*nrm(g_a[g])) union() { carrier(g); group_switches(g, true); }
  union() { collar_top(); keypad(); if (g == 1) carrier_joy(); }
}
else if (PART == "check_hinge") for (a = [3, 15, 40, 70]) intersection() { rot_Q(a) collar_bottom(); collar_top(); }   // must be empty: it opens
else if (PART == "check_screws") intersection() {          // the screw, its head's way in and the pin vs the insides: must be empty
  union() { front_clear(); front_insert(); pin(); }
  union() { inside(); bay_frame() translate([0, 0, bay_r0]) linear_extrude(bay_in[2]) rrect([bay_in[0], bay_in[1]], bay_cr); wire_path(); bar_x(2*bore_r, 100); }
}
else if (PART == "check_screws_in") difference() { union() { front_clear(false); front_insert(); } body(); }   // must be empty
else if (PART == "check_bike") intersection() { union() { collar_top(); collar_bottom(); joy_cap(); bay_cap(); }
  union() { translate([grip_x - 65, 0, 0]) bar_x(grip_d, 130); translate([cube_x, -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]); } }
else if (PART == "check_height") intersection() {           // must be empty: nothing above the switch cube's top (less top_room)
  union() { collar_top(); keypad(); joy_cap(); }
  translate([-100, -100, cube[2] - top_room]) cube(200);
}
// the joystick's cap tilted cap_travel each way about its pivot: its head clear of the face and the keypad's domes,
// its sleeve clear of the face (must be empty)
else if (PART == "check_tilt") for (a = [0:90:270]) intersection() {
  joy_frame() translate(pivot) rotate(a=cap_travel, v=[cos(a), sin(a), 0]) translate(-pivot) joy_cap_local(1);
  union() { collar_top(); keypad(); }
}
else if (PART == "check_tilt_sleeve") for (a = [0:90:270]) intersection() {
  joy_frame() translate(pivot) rotate(a=cap_travel, v=[cos(a), sin(a), 0]) translate(-pivot) joy_cap_local(2);
  collar_top();
}
else if (PART == "check_front_access") intersection() {      // must be empty: the head's way in doesn't pass through the bay
  multmatrix(F_M) translate([0, 0, -front_seat - front_tunnel]) cylinder(d=5, h=front_tunnel, $fn=24);
  bay_frame() translate([0, 0, bay_r0 - 1]) linear_extrude(bay_r1 - bay_r0 + 1 + 0.6 + cap_t) offset(0.5) hull() bay_outline();
}
else if (PART == "none") { }

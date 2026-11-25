/*
  HANDLEBAR REMOTE v1: a slim thumb controller on the left handlebar, between the grip and the bike's switch cube,
  for the dash and for a phone (or any display that takes a Bluetooth keyboard or remote). OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices:
    - 2026-11-24: "a left-side handlebar mount to control any digital displays": a 5-way joystick and 2 buttons
      (glove-friendly, by the thumb, without looking); wired to the dash (one of its expansion slots: power and the
      dash bus) AND Bluetooth (a phone sees it as a Bluetooth keyboard / media remote).
    - 2026-11-25: "between the grips and the control panel, a slim control unit".
    - 2026-11-25: "the electronic box is too big, make it more compact and attached to the buttons; make the buttons
      more ergonomic, tilt it to the grip side". So it's ONE slim collar (collar_w, 19 mm) round the bar in the gap
      between the grip and the switch cube (slide the cube inboard: gap_w, MEASURE):
        - on top, a low POD facing up and back to the thumb (pod_a) and tilted toward the grip (pod_tilt): the 5-way
          joystick in the middle, a button either side of it round the bar;
        - underneath, a slim BAY (as wide as the collar) with the ESP32-C3 and the CAN transceiver standing on edge,
          side by side, closed by a cap from below; the cable to the dash comes out of the cap.
      The switches' wires (10 with 4 buttons) run from the pod to the bay in a groove inside the ring, against the bar.
    - 2026-11-25: "could we add more buttons": 4 buttons (buttons, SELECT: 2 or 4), all in one row round the bar with
      the joystick in the middle (the collar is too narrow for two rows); the pod grows from 45 to 66 mm long.
    - 2026-11-25: "it still not ergonomic ... the buttons are just like a box, not a control unit": a THUMB CRADLE
      (sweep_r: curved along the thumb's sweep), each button in a cup tilted with the curve, ridges between them, round
      inner and pill outer buttons, the joystick standing up in the middle; tactile heights picked per button.

  Built around (COMPONENTS.md; MEASURE yours: none has a published drawing):
    - a 5-way navigation switch, 10 x 10 mm, about 7 mm tall (the one on the "5-way navigation button module": buy the
      module and take its switch off, or buy the switch), on a small piece of perfboard;
    - 2 or 4 tactile switches, 6 x 6 x 7 mm (the actuator reaches up into the keypad's dome);
    - an ESP32-C3 Super Mini (22.52 x 18 mm: Bluetooth LE, and one CAN controller for the dash bus);
    - an SN65HVD230 CAN transceiver module (as in the dash).

  How it goes together (owner, 2026-11-25: "make the button faceplate more rounded and organic rather than a box,
  and have the door on the back side, on the handle side: it will help it be more airtight"):
    1. COLLAR TOP: the ring's upper half and the pod's lower part, open at the SEAM (low on the pod's sides, at the
       switch board's top). The switch board rests on 4 corner steps inside.
    2. KEYPAD (TPU): a liner inside the cover: the sheet under the face (its hollow domes are the buttons, it hugs the
       joystick cap's sleeve), a skirt down the cover's inside, and a flange that is the seam's gasket. The skirt's foot
       holds the switch board down.
    3. POD COVER: the face and the pod's upper sides in ONE smooth domed part (no plate, no screws on the face). It's
       held by 2 screws (the front one also joins the collar's halves):
         - FRONT: an M2.5 socket screw from UNDERNEATH (its head hidden in the bottom half's front boss), up through
           both halves into an insert in the cover's front end;
         - BACK: an M2.5 countersunk screw at the cover's BACK end, into an insert in the top half;
       and a third M2.5 from inside the pod (under the switch board) joins the halves behind the bar.
       So the only seam on the controls is low down, round the pod's sides, sealed by the keypad's flange.
    4. JOYSTICK CAP: pushes onto the switch's stem through the cover.
    5. COLLAR BOTTOM: the ring's lower half and the bay, a 1 mm rubber strip inside the ring. The boards slide into the
       bay from below.
    6. BAY CAP and its TPU GASKET: close the bay (2 M2 screws); the dash's 4-core cable comes in through the cap.

  Frames: the BIKE frame has the bar along x through the collar's centre (x to the rider's right: the grip is at -x,
  the switch cube at +x), y forward, z up; angles round the bar are measured from straight forward toward up (90 =
  straight up, 180 = toward the rider, 270 = straight down). The POD frame has its origin at the centre of the face
  plate's top, x across the face (along the bar, tilted), y round the bar, z out of the face. The BAY frame has its
  origin on the bar's axis, z pointing down the bay (bay_a).
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "exploded", "collar_top", "collar_bottom", "pod_cover", "keypad" (TPU), "joy_cap", "bay_cap",
// "bay_gasket" (TPU); checks "check_*" (see the end).
PART = "assembly";

// ------------------------- YOUR BIKE (MEASURE) ------------------------
bar_d = 22.2;               // MEASURE: the handlebar (22.2 = 7/8")
gap_w = 20;                 // MEASURE: the room on the bar between the grip and the switch cube (slide the cube inboard)
cube = [55, 45, 30, 22];    // MEASURE: the switch cube: width along the bar, depth, top above and bottom below the bar's
                            //   centre (only for the fit check and the pictures)
grip_d = 32;                // MEASURE: the grip's diameter (the fit check)
pod_a = 125;                // SELECT: where the controls face, round the bar (90 = straight up, 125 = up and back; 95-150, up to 135 with 4 buttons)
pod_tilt = 20;              // SELECT: the face tilted toward the grip (degrees), so the thumb reaches it from the grip
bay_a = 270;                // SELECT: where the electronics bay hangs (270 = straight down)

// ------------------------- THE SWITCHES (MEASURE) ----------------------
nav_sw = [10, 10, 4.0];     // MEASURE: the 5-way switch's body (width, length, height above its board)
nav_top = 7.0;              // MEASURE: its stem's top above the board's top
nav_stem_d = 3.5;           // MEASURE: the stem (the cap pushes on and grips it)
tact = [6, 6];              // MEASURE: the tactile switches (the buttons), 6 x 6 mm (pins at +-3.25 x +-2.25)
tact_heights = [5, 6, 7, 8, 9, 9.5, 10, 11, 12, 13];   // their heights sold (actuator top above the board): the model picks
                            //   one per button to suit the curved face (see the echo: 7 mm inside, 8 mm outside)
tact_body = 3.5;            //   their body's height; the round actuator (3.5 mm) rises into the keypad's hollow dome
buttons = 4;                // SELECT: 2 or 4 buttons, in one row round the bar with the joystick in the middle
btn_y = 12;                 // the inner 2, either side of the joystick (pod-frame y)
btn_pitch = 10.5;           // the outer 2 (with 4 buttons), this much further out

// ------------------------- THE BOARDS IN THE BAY (MEASURE) -------------
mcu = [22.52, 18, 4.5];     // ESP32-C3 Super Mini: length, width (nologo.tech), thickness with its parts (MEASURE)
can_pcb = [26, 16, 6];      // MEASURE: the SN65HVD230 module: length, width, thickness with its header

// ------------------------- COLLAR --------------------------------------
collar_w = gap_w - 1;       // the collar's width along the bar (0.5 mm either side)
rubber = 1.0;               // rubber strip inside the ring
ring_t = 3.0;               // the ring's wall
pod_wall = 2.0;             // the pod's side walls
pod_end = 5.5;              // its end walls (the 2 screws pass through them)
plate_t = 2.0;              // the cover's face
skin = 0.8;                 // the keypad's sheet, skirt and flange (TPU)
squeeze = 0.2;              // how much the cover squeezes the keypad's flange (the seam's seal)
pod_r = 5;                  // the pod's rounded corners (seen from the face)
// The face: a THUMB CRADLE (owner, 2026-11-25: "it still not ergonomic ... the buttons are just like a box, not a
// control unit"): curved along the thumb's sweep, each button in its own cup, ridges between them.
sweep_r = 110;              // SELECT: the face's concave curve along the thumb's sweep (smaller = a deeper cradle)
side_r = 4.5;               // its sides rounded (across the bar)
end_r = 5;                  // its ends rolled over
proud = 0.7;                // each button's top stands this far above the face round it
cup = [0.8, 1.3];           // each button's cup: its depth at the button, and how far it reaches round it at the face
rib_d = 1.8;                // the ridges between the inner and the outer buttons (to feel with gloves)
cap_lift = 2.4;             // the joystick's cap floats this far above the cradle's bottom (room to tilt over the face)
screw_lens = [6, 8, 10, 12, 14, 16, 18, 20, 25, 30, 35, 40, 45, 50];   // the M2.5 lengths to choose from (the model picks; see the echo)
dome_in = [8, 8];           // the inner 2 buttons: round
dome_out = [10, 7];         // the outer 2: pills, wider across the bar (so they feel different)
cap_d = 13;                 // the joystick's cap
cap_h = 4.5;
sleeve_d = 6.5;             // its sleeve, down through the plate and the keypad onto the stem
cap_travel = 14;            // the joystick tilts up to this (degrees)
wires = 2.5;                // room under the switch board for the wires
groove = [4.5, 1.0];        // the wires' groove inside the ring, pod to bay: width, depth
m2_insert_d = 3.2;          // M2 heat-set inserts: the bay cap's 2
m25_insert_d = 3.6;         // M2.5 heat-set inserts (4 mm long): one in the cover's front end, one in the bottom half

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
btn_ys = buttons == 4 ? [-btn_y - btn_pitch, -btn_y, btn_y, btn_y + btn_pitch] : [-btn_y, btn_y];   // the buttons (pod-frame y)
btn_out = max(btn_ys);
sw_len = max(30, 2*(btn_out + tact[1]/2 + 1));   // the switch board (perfboard): its length round the bar (its width follows the collar)
function btn_dome(y) = abs(y) > btn_y + 0.1 ? dome_out : dome_in;
// The pod's inside: long enough for the buttons, and for the switch board's square corners in its rounded corners.
inner0 = collar_w - 2*pod_wall;
cav_r = max(0.5, pod_r - pod_wall);
board_dx = max(0, min(14, inner0 - 0.6)/2 - (inner0/2 - cav_r));
inner = [inner0, ceil(max(sw_len + 2*(cav_r - sqrt(cav_r*cav_r - board_dx*board_dx)) + 0.3, 2*(btn_out + btn_dome(btn_out)[1]/2 + 1.6)))];
pod_l = inner[1] + 2*pod_end;                // its length round the bar
sw_board = [min(14, inner0 - 0.6), sw_len, 1.6];
z_seat = -plate_t - skin;                    // the keypad's sheet, under the cover's face (pod frame)
z_btop = z_seat - 0.3 - nav_sw[2];           // the switch board's top: the joystick's body stays under the keypad
z_bbot = z_btop - sw_board[2];
z_floor = z_bbot - wires;                    // the pod's floor (inside)
z_seam = z_btop;                             // the seam between the cover and the collar top (the keypad's flange on it)
z_c0 = z_seam + skin - squeeze;              // the cover's underside
stem_top = z_btop + nav_top;
sw_hole_d = sleeve_d + 2*(plate_t + max(stem_top, 0))*tan(cap_travel) + 0.8;
// The face's shape (pod frame z, along its middle): concave along the thumb's sweep, its ends rolled over.
function sag(y) = sweep_r - sqrt(sweep_r*sweep_r - y*y);
function slope(y) = y/sqrt(sweep_r*sweep_r - y*y);
function endroll(y) = let(d = 0.9*(abs(y) - (pod_l/2 - end_r))) d > 0 ? end_r - sqrt(max(0, end_r*end_r - d*d)) : 0;   // (stops short of vertical)
function surf(y) = sag(y) - endroll(y);
function plan_w(y) = let(d = abs(y) - (pod_l/2 - pod_r)) d > 0 ? collar_w - 2*(pod_r - sqrt(max(0, pod_r*pod_r - d*d))) : collar_w;
// The buttons: each dome's top follows the face (proud of it, tilted with its slope); the model picks each tactile
// switch's height so its actuator stops 0.3 under the dome's roof (roof at least 0.8 thick).
btn_n = len(btn_ys);
btn_top = [for (y = btn_ys) sag(y) + proud];
btn_low = [for (i = [0:btn_n - 1]) btn_top[i] - abs(slope(btn_ys[i]))*(btn_dome(btn_ys[i])[1]/2 - 1.3)];   // its top's lowest point over the hollow
tact_hs = [for (i = [0:btn_n - 1]) let(ok = [for (h = tact_heights) if (z_btop + h + 0.3 <= btn_low[i] - 0.8) h]) len(ok) > 0 ? max(ok) : undef];
btn_roof = [for (i = [0:btn_n - 1]) z_btop + tact_hs[i] + 0.3];   // the hollow dome's roof (underside)
joy_z0 = surf(0) + cap_lift;                 // the joystick cap's underside
pivot = [0, 0, z_btop + nav_sw[2]];          // MEASURE: where the 5-way switch's stem pivots (taken at its body's top)
rib_y = (btn_y + dome_in[1]/2 + btn_y + btn_pitch - dome_out[1]/2)/2;   // the ridges between the inner and outer buttons
// The pod: facing D round the bar, tilted toward the grip about its own y axis. Its distance from the axis keeps the
// lowest corner of its floor 1.2 above the rubber; its shift along the bar keeps its inside within the collar's width
// on the switch cube's side (its top may overhang the grip's end, well above the grip).
D = [0, cos(pod_a), sin(pod_a)];
YP = [0, sin(pod_a), -cos(pod_a)];
tilt_ = max(pod_tilt, 0.01);                 // (exactly 0 lines the cradle's cut up with the ring's faces: CGAL fails)
XP = [cos(tilt_), sin(tilt_)*D[1], sin(tilt_)*D[2]];
ZP = [-sin(tilt_), cos(tilt_)*D[1], cos(tilt_)*D[2]];
pod_R = bore_r + 1.2 + (inner[0]/2)*sin(tilt_) - z_floor*cos(tilt_);
pod_shift = collar_w/2 - 1.6 - (inner[0]/2)*cos(tilt_) + z_floor*sin(tilt_);
O = [pod_shift, pod_R*D[1], pod_R*D[2]];
POD_M = [[XP[0], YP[0], ZP[0], O[0]], [XP[1], YP[1], ZP[1], O[1]], [XP[2], YP[2], ZP[2], O[2]], [0, 0, 0, 1]];
slot_x = pod_shift - z_floor*sin(tilt_);  // where the wires leave the pod's floor, along the bar (they go straight down)
// The bay: down bay_a, as wide as the collar, the 2 boards on edge side by side.
E = [0, cos(bay_a), sin(bay_a)];
YB = [0, sin(bay_a), -cos(bay_a)];
BAY_M = [[1, 0, 0, 0], [0, YB[1], E[1], 0], [0, YB[2], E[2], 0], [0, 0, 0, 1]];
bay_in = [collar_w - 2*bay_wall, max(mcu[1], can_pcb[0]) + 1, max(mcu[0], can_pcb[1]) + 1.5];   // across, round, down
bay_r0 = bore_r + 1.0;                       // the bay's inside starts here (below the bore)
bay_r1 = bay_r0 + bay_in[2];                 // its bottom (the cap's seat)
bay_boss_y = bay_in[1]/2 + 3.3;              // the cap's 2 screws, in lobes at the bay's ends
// The split between the collar's halves: a plane through the axis, between the pod and the bay. Behind the bar it runs
// at split_a round the bar: halfway between where the pod and the bay face, or turned further down so the pod's back
// end (its steps, the cover's lower edge, the back screw's insert) stays 3 degrees above it (a long pod facing back).
function ang_of(p) = let(a = atan2(p[2], p[1])) a < 0 ? a + 360 : a;   // round the bar (0 = forward, 90 = up)
pod_back_a = max([for (sx = [-1, 1]) each [
  ang_of(pod_point(sx*(inner[0]/2 + 0.6), -(inner[1]/2 + 0.6), z_floor - 0.5)),          // the steps' bottoms
  ang_of(pod_point(sx*(collar_w/2 - pod_r), -pod_l/2, z_c0)),                            // the cover's lower edge
  ang_of(pod_point(sx*collar_w/2, -(pod_l/2 - pod_r), z_c0)),
  ang_of(pod_point(sx*m25_insert_d/2, -(inner[1]/2 + pod_end/2), z_seam - 6))]]);       // the back screw's insert
bay_back_a = ang_of(BAY_M*[0, bay_in[1]/2, bay_r0, 1]) ;                              // the bay's inside, top back edge
split_a = max(ang_of([0, D[1] - E[1], D[2] - E[2]]) + 90, pod_back_a + 3);
N = [0, sin(split_a), -cos(split_a)];
T = [0, N[2], -N[1]];
SPLIT_M = [[1, 0, 0, 0], [0, T[1], N[1], 0], [0, T[2], N[2], 0], [0, 0, 0, 1]];
echo(tactile_switches = [for (i = [0:btn_n - 1]) str("6 x 6 x ", tact_hs[i])], face_ends_rise = surf(pod_l/2 - end_r));
echo(front_screw = str("M2.5 x ", front_len, " socket cap"), back_screw = str("M2.5 x ", rear_len, " countersunk"), join_screw = str("M2.5 x ", join_len, " pan or socket"), join_sink = join_sink, buttons = buttons, pod_l = pod_l, pod_above_ring = pod_R - ring_r, pod_shift = pod_shift, bay_below_axis = bay_r1 + 0.6 + cap_t, split_a = split_a, collar_w = collar_w);

// ------------------------- CHECKS ------------------------------------
assert(collar_w >= 18, "The gap is too narrow for the collar: make gap_w at least 19 mm (slide the switch cube inboard).");
assert(sw_board[0] <= inner[0] - 0.4 && sw_board[1] <= inner[1] - 0.4, "The switch board doesn't fit the pod.");
assert(z_btop + tact_body <= z_seat - 0.3, "The tactile switches' bodies are too tall for the keypad.");
assert(len([for (h = tact_hs) if (h == undef || z_btop + h < z_seat + skin) 1]) == 0, "No tactile switch height in tact_heights suits a button's dome (proud, sweep_r).");
assert(nav_sw[0]/2 + 0.3 <= inner[0]/2 - skin - 0.1, "The joystick's switch doesn't fit inside the keypad's skirt.");
assert(stem_top - 0.3 - (z_seat + 0.1) >= 2, "The joystick's stem is too short for its cap to grip it (nav_top).");
assert(buttons == 2 || buttons == 4, "buttons: 2 or 4.");
assert(btn_out + btn_dome(btn_out)[1]/2 + 0.8 <= inner[1]/2 - skin && btn_y - dome_in[1]/2 - 0.6 >= sw_hole_d/2, "The buttons don't fit either side of the joystick.");
assert(max(dome_in[0], dome_out[0])/2 + 0.3 <= inner[0]/2 - skin, "The buttons are too wide for the keypad's skirt.");
assert(buttons == 2 || btn_pitch - (dome_in[1] + dome_out[1])/2 - 0.6 >= 2.0, "The buttons are too close together (btn_pitch): no room for the ridge between them.");
assert(btn_out + btn_dome(btn_out)[1]/2 + 0.3 + cup[1] <= pod_l/2 - end_r, "The outer buttons' cups run into the face's rolled ends.");
assert(cap_d < collar_w - 1, "The joystick's cap is wider than the collar.");
assert(front_seat >= 2.5 && rear_engage >= 4 && join_sink >= 1.5, "No screw length in screw_lens suits.");
assert(mcu[2] + bay_gap + can_pcb[2] + 0.6 <= bay_in[0], "The two boards don't fit side by side in the bay: a wider gap.");
assert(abs(slot_x) + groove[0]/2 <= collar_w/2 - 1, "The wires' groove runs off the collar: less pod_tilt.");
assert(pod_tilt >= 0 && pod_tilt <= 30, "pod_tilt: 0 to 30 degrees.");
assert(buttons == 2 || pod_a <= 135, "With 4 buttons the pod is long: pod_a up to 135 (further back, its back end and the joining screw run into the bay).");
assert(split_a <= bay_back_a - 3, "The pod's back end comes too close to the bay: less pod_a (or 2 buttons).");

// ------------------------- HELPERS ------------------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center=true);
module pod_frame() multmatrix(POD_M) children();
module bay_frame() multmatrix(BAY_M) children();
module bar_x(d, l) rotate([0, 90, 0]) cylinder(d=d, h=l, center=true);
module half(s=1) multmatrix(SPLIT_M) translate([-100, -100, s > 0 ? 0 : -200]) cube([200, 200, 200]);   // the top (+) or bottom (-) side
module slab(w) translate([-w/2, -100, -100]) cube([w, 200, 200]);   // |x| <= w/2
function invert(M) = let(R = [[M[0][0], M[1][0], M[2][0]], [M[0][1], M[1][1], M[2][1]], [M[0][2], M[1][2], M[2][2]]], t = -R*[M[0][3], M[1][3], M[2][3]])
  [[R[0][0], R[0][1], R[0][2], t[0]], [R[1][0], R[1][1], R[1][2], t[1]], [R[2][0], R[2][1], R[2][2], t[2]], [0, 0, 0, 1]];

// ------------------------- THE SWITCHES AND BOARDS (view only, and for the checks) ----
module switches(stem=true) pod_frame() {
  color([0.1, 0.45, 0.2]) translate([0, 0, z_bbot]) linear_extrude(sw_board[2]) board_2d();
  color([0.2, 0.2, 0.22]) translate([0, 0, z_btop]) linear_extrude(nav_sw[2]) square([nav_sw[0], nav_sw[1]], center=true);
  if (stem) color([0.7, 0.7, 0.72]) translate([0, 0, z_btop]) cylinder(d=nav_stem_d, h=nav_top, $fn=24);
  for (i = [0:btn_n - 1]) translate([0, btn_ys[i], z_btop]) {
    color([0.15, 0.15, 0.16]) linear_extrude(tact_body) square([tact[0], tact[1]], center=true);
    color([0.3, 0.3, 0.32]) cylinder(d=3.5, h=tact_hs[i], $fn=24);                   // the actuator
  }
}
module board_2d() square([sw_board[0], sw_board[1]], center=true);
// In the bay (bay frame): the ESP32-C3 on edge against the outboard wall, its USB-C at the bottom; the transceiver
// beside it.
mcu_x = -bay_in[0]/2 + 0.3;
can_x = mcu_x + mcu[2] + bay_gap;
module bay_boards() bay_frame() {
  color([0.15, 0.15, 0.17]) translate([mcu_x, -mcu[1]/2, bay_r0 + 0.5]) cube([mcu[2], mcu[1], mcu[0]]);
  color([0.1, 0.3, 0.6]) translate([can_x, -can_pcb[0]/2, bay_r0 + 0.5]) cube([can_pcb[2], can_pcb[0], can_pcb[1]]);
}

// ------------------------- COLLAR -------------------------------------
step_xy = [for (sx = [-1, 1], sy = [-1, 1]) [sx*(inner[0]/2 - 1.8), sy*(inner[1]/2 - 1.8)]];   // the board's 4 corner steps
function unit(v) = v/norm(v);
function pod_point(x, y, z) = O + x*XP + y*YP + z*ZP;
function pod_of(p) = [(p - O)*XP, (p - O)*YP, (p - O)*ZP];
function axis_m(p, u) = let(x0 = unit([1, 0, 0] - u[0]*u), y0 = cross(u, x0))
  [[x0[0], y0[0], u[0], p[0]], [x0[1], y0[1], u[1], p[1]], [x0[2], y0[2], u[2], p[2]], [0, 0, 0, 1]];   // z along u, at p
// The 2 screws that hold the cover AND join the collar's halves (owner: no screws on the face, the "door" toward the
// back and the bar). They pass through the pod's end walls, outside the keypad's seal.
screw_y = inner[1]/2 + pod_end/2;
// FRONT: M2.5 socket cap from underneath: its head in a counterbore in the bottom half's front boss, up through both
// halves (clear of the ring) into an insert in the cover's front end.
F_B = pod_point(0, screw_y, z_c0);              // where it enters the cover (its underside)
// It crosses the split this far in front of the axis: clear of the ring, and leaning at most about 2.8 mm toward the
// front end compared with square to the face (with a longer pod it would otherwise cut through the pod's inside).
ear_sq = let(t = (N*F_B)/(N*ZP)) (F_B - t*ZP)*T;   // where a screw square to the face would cross
ear_y = max(ring_r + 7.1, ear_sq - 2.8);   // (at least 7.1 in front of the ring: else, with a short pod facing up, the head's way in passes the bay)
F_A = ear_y*T;                                  // where it crosses the split
F_u = unit(F_B - F_A);
F_M = axis_m(F_A, F_u);
front_ab = norm(F_B - F_A);
function pick_len(l) = min([for (x = screw_lens) if (x >= l) x]);
front_len = pick_len(front_ab + 4 + 2.5);       // the shortest that leaves 2.5 mm under its head and 4 in the insert
front_seat = front_len - 4 - front_ab;          // its head's seat below the split
module front_clear(cb=true) multmatrix(F_M) {
  translate([0, 0, -front_seat]) cylinder(d=2.9, h=front_seat + front_ab + 0.01, $fn=20);
  if (cb) translate([0, 0, -front_seat - front_tunnel]) cylinder(d=5, h=front_tunnel, $fn=24);   // the head (4.5) goes in from below
}
front_tunnel = 40;          // the head's way in from below, out of the body (check_front_access: it must not pass the bay)
module front_insert() multmatrix(F_M) translate([0, 0, front_ab - 0.01]) cylinder(d=m25_insert_d, h=4.6, $fn=20);
// BACK: an M2.5 countersunk at the cover's back end, straight down through it into an insert in the top half's end
// wall, below the seam.
R_S = pod_point(0, -screw_y, min([for (d = [-2.5:0.5:2.5]) surf(screw_y + d)]) - 0.2);   // its head, at or below the curved face
R_u = -ZP;
R_M = axis_m(R_S, R_u);
rear_st = pod_of(R_S)[2] - z_seam;              // its depth to the seam
rear_len = pick_len(rear_st + 4);               // the shortest with 4 mm in the insert
rear_engage = rear_len - rear_st;
module rear_clear(cs=true) multmatrix(R_M) {
  translate([0, 0, cs ? -0.01 : 0.6]) cylinder(d=2.9, h=rear_st + 0.02 - (cs ? 0 : 0.6), $fn=20);
  if (cs) { translate([0, 0, -10]) cylinder(d=5.0, h=10, $fn=24); cylinder(d1=5.0, d2=2.9, h=1.05, $fn=24); }   // the countersunk head
}
module rear_insert() multmatrix(R_M) translate([0, 0, rear_st - 0.01]) cylinder(d=m25_insert_d, h=rear_engage + 1, $fn=20);
// JOINING THE HALVES AT THE BACK: behind the bar the split runs between the pod and the bay, so a screw there from
// outside would cross one of them: an M2.5 from INSIDE the pod (its head on the pod floor's rear end, under the switch
// board), down square to the split into an insert in the bottom half, behind the bay. Fitted before the switch board.
// No further back than 14.4 mm from the pod's centre: in a longer pod (4 buttons) the floor's far end comes too close
// to the split (at pod_a 150).
join_s0 = pod_point(0, -min(inner[1]/2 - 2.6, 14.4), z_floor);
join_len = max([for (x = screw_lens) if (x <= N*join_s0 + 4 - 1.5) x]);   // the longest with its head sunk 1.5+ into the floor
join_sink = N*join_s0 + 4 - join_len;           // how deep its head sits (below the floor): exactly 4 mm of thread in the insert
join_s = join_s0 - join_sink*N;                 // its head's seat
join_t = N*join_s;                              // its depth to the split

JOIN_M = [[1, 0, 0, join_s[0]], [0, -N[2], -N[1], join_s[1]], [0, N[1], -N[2], join_s[2]], [0, 0, 0, 1]];   // z down the screw (-N)
module join_clear() multmatrix(JOIN_M) translate([0, 0, -0.01]) cylinder(d=2.9, h=join_t + 0.02, $fn=20);
module join_insert() multmatrix(JOIN_M) translate([0, 0, join_t - 0.01]) cylinder(d=m25_insert_d, h=5, $fn=20);
module join_head() multmatrix(JOIN_M) translate([0, 0, -2]) cylinder(d=4.6, h=2, $fn=20);   // its head (view and check)
module join_cb() multmatrix(JOIN_M) translate([0, 0, -join_sink - 4]) cylinder(d=5.2, h=join_sink + 4.01, $fn=24);   // its seat in the floor
// where each screw crosses the seam (pod frame x, y): the keypad's flange has a hole there
function cross_seam(P0, u) = let(q = pod_of(P0), w = [u*XP, u*YP, u*ZP], t = (z_seam - q[2])/w[2]) [q[0] + t*w[0], q[1] + t*w[1]];
// The body: ONE smooth convex hull (owner, 2026-11-25: "why is it square, make it an organic shape") over the ring
// (its edges rounded), the pod's rim and floor, the bay's top and floor, and the 2 screws' bosses. The halves, the
// cavities and the holes are all cut from it.
ring_round = 2.5;
module ring_solid() rotate([0, 90, 0]) rotate_extrude($fn=96)
  offset(r=ring_round) offset(delta=-ring_round) translate([0, -collar_w/2]) square([ring_r, collar_w]);
// The pod's top (pod frame): the thumb cradle, swept along y: at each station a section rounded at its sides (side_r),
// its top on the face's curve (surf), its width following the pod's rounded corners (plan_w).
face_n = ceil(pod_l/1.5);
function face_prof(y, g=0) = let(w = plan_w(y) + 2*g, sr = min(side_r, w/2 - 0.05), t = surf(y) + g, zl = z_c0 - 0.5)
  concat([[-w/2, zl]], [for (a = [180:-15:90]) [-w/2 + sr + sr*cos(a), t - sr + sr*sin(a)]],
         [for (a = [90:-15:0]) [w/2 - sr + sr*cos(a), t - sr + sr*sin(a)]], [[w/2, zl]]);
face_m = len(face_prof(0));
module face_poly(g=0) polyhedron(           // g: grown this much (the hull's, so its surface never coincides with the cut)
  points = [for (i = [0:face_n]) let(y = -pod_l/2 + i*pod_l/face_n) for (p = face_prof(y, g)) [p[0], y*(pod_l/2 + g)/(pod_l/2), p[1]]],
  faces = concat(
    [for (i = [0:face_n - 1], j = [0:face_m - 1], t = [0, 1]) t == 0 ? [i*face_m + j, (i + 1)*face_m + j, (i + 1)*face_m + (j + 1)%face_m]
                                                                       : [i*face_m + j, (i + 1)*face_m + (j + 1)%face_m, i*face_m + (j + 1)%face_m]],   // (triangles: quads here aren't flat)
    [[for (j = [0:face_m - 1]) j]], [[for (j = [face_m - 1:-1:0]) face_n*face_m + j]]), convexity=4);
module shell() hull() {
  ring_solid();
  pod_frame() {
    face_poly(0.2);                                                                             // the top (its convex hull here)
    translate([0, 0, z_floor - 1.2]) linear_extrude(0.01) rrect([collar_w, pod_l], pod_r);        // the floor: the shell wraps the inside
  }
  bay_frame() {
    translate([0, 0, bay_r0 - 1]) linear_extrude(0.01) hull() bay_outline();
    translate([0, 0, bay_r1 - 1.5]) linear_extrude(1.5) hull() bay_outline();                      // the floor (flat: the cap's seat)
  }
  multmatrix(F_M) translate([0, 0, -front_seat - 2]) cylinder(d=9, h=front_seat + 8, $fn=32);   // the front screw's boss
}
// The body: the hull (which can't be concave) minus the AIR over the cradle: above the face and its rounded sides, and
// beside them a 45-degree flank down, so the hull beside the pod blends into the rounded sides.
function air_prof(y) = let(w = plan_w(y), sr = min(side_r, w/2 - 0.05), t = surf(y), e = 12)
  concat([[-w/2 - e, t + 20], [w/2 + e, t + 20], [w/2 + e, t - sr - e]], [for (a = [0:15:90]) [w/2 - sr + sr*cos(a), t - sr + sr*sin(a)]],
         [for (a = [90:15:180]) [-w/2 + sr + sr*cos(a), t - sr + sr*sin(a)]], [[-w/2 - e, t - sr - e]]);
air_m = len(air_prof(0));
module air_poly() polyhedron(
  points = [for (i = [-1:face_n + 1]) let(y = -pod_l/2 + min(max(i, 0), face_n)*pod_l/face_n, ye = y + (i < 0 ? -3 : i > face_n ? 3 : 0))
             for (p = air_prof(y)) [p[0], ye, p[1]]],                     // (on 3 mm past the ends, over the grown hull's ends)
  faces = concat(
    [for (i = [0:face_n + 1], j = [0:air_m - 1], t = [0, 1]) t == 0 ? [i*air_m + j, (i + 1)*air_m + j, (i + 1)*air_m + (j + 1)%air_m]
                                                                     : [i*air_m + j, (i + 1)*air_m + (j + 1)%air_m, i*air_m + (j + 1)%air_m]],
    [[for (j = [0:air_m - 1]) j]], [[for (j = [air_m - 1:-1:0]) (face_n + 2)*air_m + j]]), convexity=4);
module body() difference() { shell(); pod_frame() air_poly(); }
// The wires: a slot down from the pod's floor into the bore, a groove in the bore round to the bay, a slot up into it.
module wire_path() {
  pod_frame() translate([0, 0, z_floor - 6]) cylinder(d=groove[0], h=6.1, $fn=20);
  translate([slot_x, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, pod_a - 270]) rotate_extrude(angle=bay_a - pod_a, $fn=96)
    translate([bore_r - 0.5, -groove[0]/2]) square([groove[1] + 0.5, groove[0]]);
  bay_frame() translate([slot_x, 0, bore_r - 0.5]) cylinder(d=groove[0], h=bay_r0 - bore_r + 1, $fn=20);
}
module above_seam(z) pod_frame() translate([-50, -50, z]) cube([100, 100, 60]);   // the pod above the seam
module inside(z0, z1) pod_frame() translate([0, 0, z0]) linear_extrude(z1 - z0) rrect(inner, max(0.5, pod_r - pod_wall));
module collar_top() intersection() {
  union() {
    difference() {
      intersection() { shell(); half(1); }
      above_seam(z_seam);                                                     // that's the cover
      bar_x(2*bore_r, 200);
      inside(z_floor, z_seam + 1);                                            // the pod's inside, open at the seam
      wire_path();
      front_clear(); rear_insert(); join_clear(); join_cb();                  // the screws
      translate([grip_x - 100, 0, 0]) bar_x(grip_d + 2, 200);   // where the pod overhangs the grip's end, it stays 1 mm clear of the grip
    }
    // steps in the corners: the switch board's corners rest on them
    pod_frame() for (p = step_xy) translate([p[0] + sign(p[0])*0.4, p[1] + sign(p[1])*0.4, z_floor - 0.5])   // (into the walls)
      linear_extrude(z_bbot - z_floor + 0.5) square(4.4, center=true);
  }
  translate([-100, 0, 0]) slab(200 + collar_w);   // keeps it off the switch cube's side (x <= collar_w/2)
}
module collar_bottom() difference() {
  intersection() { shell(); half(-1); translate([-100, 0, 0]) slab(200 + collar_w); }   // off the switch cube's side
  translate([grip_x - 100, 0, 0]) bar_x(grip_d + 2, 200);                       // and 1 mm clear of the grip
  bar_x(2*bore_r, 200);
  bay_frame() {
    translate([0, 0, bay_r0]) linear_extrude(bay_in[2] + 1) rrect([bay_in[0], bay_in[1]], bay_cr);   // open at the bottom, corners rounded
    for (s = [-1, 1]) translate([0, s*bay_boss_y, bay_r1 - 5]) cylinder(d=m2_insert_d, h=5.1, $fn=20);   // M2 inserts
  }
  wire_path();
  front_clear(); join_insert();
}
// The pod's cover: the face and the pod's upper sides, one smooth part.
// Each button's local frame: origin at its dome's top centre, z sheared along the face's slope there.
module btn_frame(i) multmatrix([[1, 0, 0, 0], [0, 1, 0, btn_ys[i]], [0, slope(btn_ys[i]), 1, btn_top[i]], [0, 0, 0, 1]]) children();
module btn_2d(i, o=0) let(d = btn_dome(btn_ys[i])) offset(o) rrect(d, min(d)/2 - 0.01);
module cup_cut(i) btn_frame(i) translate([0, 0, -proud]) hull() {      // a shallow cup round the button, tilted with the face
  translate([0, 0, -cup[0]]) linear_extrude(0.01) btn_2d(i, 0.3);
  translate([0, 0, 2.4]) linear_extrude(0.01) btn_2d(i, 0.3 + cup[1]*(2.4 + cup[0])/cup[0]);
}
module ribs() pod_frame() for (s = [-1, 1]) if (buttons == 4)            // the ridges between the inner and outer buttons
  hull() for (x = [-1, 1]) translate([x*4, s*rib_y, sag(rib_y) + 0.3]) sphere(d=rib_d, $fn=16);
module pod_cover() difference() {
  union() {
    difference() {
      intersection() { body(); above_seam(z_c0); translate([-100, 0, 0]) slab(200 + collar_w); }
      pod_frame() for (i = [0:btn_n - 1]) cup_cut(i);
    }
    ribs();
  }
  translate([grip_x - 100, 0, 0]) bar_x(grip_d + 2, 200);
  inside(z_c0 - 1, -plate_t);                                                 // the inside, up to the face's underside
  pod_frame() {
    translate([0, 0, -plate_t - 1]) cylinder(d=sw_hole_d, h=plate_t + 12);   // the joystick's sleeve
    for (i = [0:btn_n - 1]) translate([0, btn_ys[i], -plate_t - 1]) linear_extrude(plate_t + 12) btn_2d(i, 0.3);   // the domes
  }
  front_insert(); rear_clear();
}

// ------------------------- KEYPAD, CAP --------------------------------
// The seam's outline (pod frame): where the cover sits on the collar top.
module seam_2d() projection(cut=true) translate([0, 0, -(z_seam + skin)]) multmatrix(invert(POD_M))
  difference() { intersection() { shell(); translate([-100, 0, 0]) slab(200 + collar_w); } translate([grip_x - 100, 0, 0]) bar_x(grip_d + 2, 200); }
kp_r = max(0.5, pod_r - pod_wall);
module keypad() difference() {
  pod_frame() union() {
    translate([0, 0, z_seat]) linear_extrude(skin) rrect(inner - [0.2, 0.2], kp_r);                  // the sheet, under the face
    translate([0, 0, z_seam]) linear_extrude(z_seat - z_seam + 0.01) difference() {                  // the skirt, down the cover's inside
      rrect(inner - [0.2, 0.2], kp_r); rrect(inner - [0.2 + 2*skin, 0.2 + 2*skin], max(0.5, kp_r - skin)); }
    translate([0, 0, z_seam]) linear_extrude(skin) difference() {                                   // the flange: the seam's gasket
      offset(-0.4) seam_2d(); rrect(inner - [0.2 + 2*skin, 0.2 + 2*skin], max(0.5, kp_r - skin)); }
    for (i = [0:btn_n - 1]) hull() {                                                                // the domes: tops follow the face
      translate([0, btn_ys[i], z_seat]) linear_extrude(0.01) btn_2d(i, -0.3);
      btn_frame(i) { translate([0, 0, -1.0]) linear_extrude(0.01) btn_2d(i, -0.3); linear_extrude(0.01) btn_2d(i, -1.1); }
    }
  }
  pod_frame() {
    translate([0, 0, z_seat - 1]) cylinder(d=sleeve_d - 0.6, h=skin + 2, $fn=32);                    // hugs the cap's sleeve
    for (i = [0:btn_n - 1]) translate([0, btn_ys[i], z_seat - 0.01]) linear_extrude(btn_roof[i] - z_seat + 0.01) btn_2d(i, -1.3);   // hollow
    for (c = [cross_seam(F_A, F_u), cross_seam(R_S, R_u)]) translate([c[0], c[1], z_seam - 1]) cylinder(d=3.4, h=skin + 2, $fn=20);   // the screws
  }
}
// The joystick's cap (pod frame): k = 0 all, 1 the head only, 2 the sleeve only (for the tilt check).
module joy_cap_local(k=0) difference() {
  union() {
    if (k != 2) translate([0, 0, joy_z0]) intersection() {
      hull() { cylinder(d=cap_d, h=1.2); translate([0, 0, cap_h - 1.6]) scale([1, 1, 0.35]) sphere(d=cap_d - 2.5, $fn=48); }
      cylinder(d=cap_d + 1, h=cap_h);
    }
    if (k != 1) translate([0, 0, z_seat + 0.1]) cylinder(d=sleeve_d, h=joy_z0 - z_seat - 0.1 + 0.01);
  }
  translate([0, 0, z_seat]) cylinder(d=nav_stem_d - 0.15, h=stem_top - 0.3 - z_seat, $fn=24);        // pushes onto the stem
  for (a = [0:45:315]) rotate(a) translate([cap_d/2 - 2.4, 0, joy_z0 + 1.0]) rotate([0, 90, 0]) cylinder(d=1.0, h=4, $fn=8);   // grip grooves
}
module joy_cap() pod_frame() joy_cap_local();

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
module remote_parts(e=0) {
  color([0.16, 0.17, 0.19]) render(convexity=6) collar_top();          // render(): the preview draws these nested cuts wrongly
  color([0.16, 0.17, 0.19]) translate(-e*N) render(convexity=6) collar_bottom();
  switches();
  translate(-e*N) bay_boards();
  translate(e*0.6*ZP) color([0.1, 0.1, 0.11]) keypad();
  translate(e*1.3*ZP) color([0.2, 0.21, 0.23]) render(convexity=6) pod_cover();
  translate(e*2.0*ZP) color([0.85, 0.45, 0.1]) joy_cap();
  translate(-e*N + e*0.8*E) color([0.1, 0.1, 0.1]) bay_gasket();
  translate(-e*N + e*1.4*E) color([0.2, 0.21, 0.23]) bay_cap();
}

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") { bike(); remote_parts(0); }
else if (PART == "exploded") { bike(); remote_parts(9); }
else if (PART == "collar_top") translate([0, 0, collar_w/2]) rotate([0, 90, 0]) collar_top();       // its flat inboard side on the bed
else if (PART == "collar_bottom") translate([0, 0, collar_w/2]) rotate([0, 90, 0]) collar_bottom();
else if (PART == "pod_cover") translate([0, 0, -z_c0]) multmatrix(invert(POD_M)) pod_cover();       // its flat underside on the bed
else if (PART == "keypad") translate([0, 0, -z_seam]) multmatrix(invert(POD_M)) keypad();          // TPU, its flange on the bed
else if (PART == "joy_cap") rotate([180, 0, 0]) translate([0, 0, -joy_z0 - cap_h]) multmatrix(invert(POD_M)) joy_cap();   // flat top down
else if (PART == "bay_cap") translate([0, 0, cap_z1]) rotate([180, 0, 0]) multmatrix(invert(BAY_M)) bay_cap();   // its outside down
else if (PART == "bay_gasket") translate([0, 0, -bay_r1]) multmatrix(invert(BAY_M)) bay_gasket();
// Checks: must be empty (or only touch), unless marked "must collide".
else if (PART == "check_switches") intersection() { switches(false); union() { collar_top(); keypad(); pod_cover(); joy_cap(); join_head(); } }
else if (PART == "check_bay") intersection() { bay_boards(); union() { collar_bottom(); bay_cap(); bay_gasket(); } }
else if (PART == "check_stem") intersection() { switches(); joy_cap(); }                       // must collide: the cap's grip
else if (PART == "check_squeeze") intersection() { keypad(); pod_cover(); }                   // must collide: the seam's seal
else if (PART == "check_bay_squeeze") intersection() { bay_gasket(); bay_cap(); }            // must collide: the bay's seal
else if (PART == "check_keypad_cap") intersection() { keypad(); joy_cap(); }                 // must collide lightly: the keypad hugs the sleeve
else if (PART == "check_parts") {
  intersection() { collar_top(); collar_bottom(); }
  intersection() { collar_top(); pod_cover(); }
  intersection() { collar_top(); keypad(); }
  intersection() { collar_top(); joy_cap(); }
  intersection() { pod_cover(); joy_cap(); }
  intersection() { collar_bottom(); bay_cap(); }
  intersection() { collar_bottom(); bay_gasket(); }
}
else if (PART == "check_screws") intersection() {            // the halves' screws and counterbores vs the insides: must be empty
  union() { front_clear(); front_insert(); rear_clear(); rear_insert(); join_insert();
            difference() { union() { join_clear(); join_cb(); } inside(z_floor - 0.01, -plate_t); } }   // (the joining screw's head is in the pod)
  union() { inside(z_floor, -plate_t);
            bay_frame() translate([0, 0, bay_r0]) linear_extrude(bay_in[2]) rrect([bay_in[0], bay_in[1]], bay_cr); wire_path(); bar_x(2*bore_r, 100); }
}
else if (PART == "check_screws_in") difference() { union() { front_clear(false); front_insert(); rear_clear(false); rear_insert(); join_clear(); join_insert(); } body(); }   // must be empty
else if (PART == "check_bike") intersection() { union() { collar_top(); collar_bottom(); pod_cover(); joy_cap(); bay_cap(); }
  union() { translate([grip_x - 65, 0, 0]) bar_x(grip_d, 130); translate([cube_x, -cube[1]/2, -cube[3]]) cube([cube[0], cube[1], cube[2] + cube[3]]); } }
// the joystick's cap tilted cap_travel each way about its pivot: its head clear of the cover and the keypad's domes,
// its sleeve clear of the cover (must be empty)
else if (PART == "check_tilt") for (a = [0:90:270]) intersection() {
  pod_frame() translate(pivot) rotate(a=cap_travel, v=[cos(a), sin(a), 0]) translate(-pivot) joy_cap_local(1);
  union() { pod_cover(); keypad(); }
}
else if (PART == "check_tilt_sleeve") for (a = [0:90:270]) intersection() {
  pod_frame() translate(pivot) rotate(a=cap_travel, v=[cos(a), sin(a), 0]) translate(-pivot) joy_cap_local(2);
  pod_cover();
}
else if (PART == "check_front_access") intersection() {      // must be empty: the head's way in doesn't pass through the bay
  multmatrix(F_M) translate([0, 0, -front_seat - front_tunnel]) cylinder(d=5, h=front_tunnel, $fn=24);
  bay_frame() translate([0, 0, bay_r0 - 1]) linear_extrude(bay_r1 - bay_r0 + 1 + 0.6 + cap_t) offset(0.5) hull() bay_outline();
}
else if (PART == "none") { }

/*
  Modular handlebar navigation dock (landscape phone)
  Version: 0.5 concept prototype: slim case + compact dock (0.2-0.4 are archived in archive/)
  Units: millimetres

  MODULE STACK (each joint is a fixed, documented interface so any module can be swapped later)

    handlebar
      | 2 x bar clamps (shims for 22.2 / 25.4 / 28.6 mm bars); rotating them sets the tilt.
      |   Interface A: each clamp pad = 2 x M5 on a 36 mm fore-aft pitch.
      v
    base plate (swap later for a "smart base")
      |   Interface B: AMPS (4 x M5, 30 x 38 mm) through rubber grommets + 14 mm cable hole.
      v
    receiver (dock): dovetail channels, 10 spring pins, dock board (bike lead wired in), side lock pod (upper right)
      |   Interface C: shoe with dovetail rails, a central "nose" carrying the contact
      |   pads (bottom face), and a strike block (upper right) that the flat lock bolt enters, bearing on a steel block.
      v
    phone case: rear-loading. Front shell with a bonded window and a thin lip,
    back cover with an O-ring tongue, 4 hidden corner screws. The shoe bolts to the back cover.

  COORDINATE FRAMES
  Case frame:  X = long axis (landscape), Y = up the screen, Z = out of the screen.
               Origin at the cavity centre; z = 0 is the outside back face of the back cover.
  Dock frame:  identical to the case frame (the shoe is centred on the case back).
  Plate frame: base plate top face centre; the dock frame sits amps_offset_y behind it.
  Clamp/bike frame: X along the bar, origin on the bar axis, Y forward, Z up (before tilt).

  Placeholders are marked MEASURE or SELECT. Do not print final parts until they are replaced.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly", "case_shell", "case_back", "window_template", "shoe", "receiver", "dock_lid",
// "base_plate", "base_plate_2d" (DXF), "clamp_body", "clamp_cap", "bar_shim", "pad_spacer",
// "lock_yoke", "crank_template" (drilling guide for the lock's own cam), "lock_cover",
// "strike_keeper", "strike_keeper_2d" (DXF; only with steel_keeper = true).
// Optional printed lock (printed_lock.scad, PRINTED_LOCK.md): "plock_body", "plock_plug", "plock_wafer"
// (with plock_index = 0..3), "plock_wafers", "plock_key", "plock_nut", "plock_crank".
PART = "assembly";
SHOW_PHONE = true;
SHOW_BAR = true;
EXPLODE = 0;

$fn = 64;

// ------------------------- PHONE PROFILE ----------------------------
// MEASURE: example values only (phone held in portrait: w = short side, l = long side).
phone_w = 75.0;
phone_l = 160.0;
phone_t = 9.0;
phone_corner_r = 9.0;
usb_side = 1;               // landscape: +1 = the phone's charging port on the right, -1 = on the left
phone_port = "usbc";        // MEASURE: the phone's charging port, "usbc" or "microusb"
usb_port_y = 0;             // MEASURE: port centre along the case's short side (case frame y, + = toward the
                            // top of the screen). Most phones: 0 (centred).

side_clearance = 0.60;
front_gap = 0.80;           // screen to window
back_pad = 2.00;            // phone stands on 4 pads; the cable runs underneath

camera_relief_enable = true;
camera_x = 0;               // portrait: across the width
camera_y = 62;              // portrait: from centre toward the phone top
camera_w = 34;
camera_h = 36;
camera_protrusion = 3.0;
camera_relief_clearance = 0.5;
min_rear_skin = 1.8;

// SELECT a low-profile 90-degree plug whose cable leaves toward the phone's BACK (it runs down into the
// channel in the back cover). Bay = plug head, measured from the phone's edge to the far side, + 1 mm.
// USB-C is reversible, so any 90-degree plug can be turned to suit; micro-USB is not, so buy the angle
// variant ("up" or "down" sellers' naming varies) that points toward the phone's back when plugged in.
usb_bay_h = (phone_port == "microusb") ? 9.0 : 8.0;
cable_channel_w = 5.0;
cable_channel_depth = 1.6;

// ------------------------- SLIM CASE --------------------------------
shell_wall = 2.4;           // front shell side wall
lip_t = 1.6;                // front lip over the window
screen_mask = 2.0;          // lip overlap onto the phone's front edge
window_t = 2.0;             // 2 mm polycarbonate, bonded to the lip from inside
case_corner_r = 4;          // small outer corner radius leaves room for the corner screws
cover_t = 3.5;              // back cover plate
tongue_t = 2.0;             // back-cover tongue that enters the shell
tongue_h = 7.0;
tongue_clear = 0.15;        // per side
oring_groove_w = 1.8;       // 1.5 mm silicone O-ring cord, radial (piston) seal
oring_groove_depth = 1.1;

corner_insert_d = 4.2;      // M3 heat-set insert hole (SELECT)
corner_insert_depth = 6;
corner_screw_clear = 3.4;
corner_csk_d = 6.4;
corner_screw_diag = 14.5;   // from each cavity corner centre, along the diagonal

shoe_insert_d = 4.2;        // M3 heat-set inserts in the back cover for the shoe
shoe_insert_depth = 4.0;
shoe_boss_d = 8.0;
shoe_mount_x = 14;
shoe_mount_y = 22;
shoe_screw_clear = 3.4;
shoe_csk_d = 6.4;
// Thermal cut-off (SELECT): a normally-closed bimetal thermostat (KSD9700 type, 45 C NC, resets at about 30 C,
// about 20 x 10 x 4 mm; sizes vary by seller, so measure yours) sits in a pocket in the back cover, pressed
// onto the phone's back through a 0.5 mm thermal pad. It is wired in series with the case's DET tie, so when
// the phone gets too hot the dock switches charging off; it closes again, and charging resumes, once cool.
thermal_cutoff = true;
therm_l = 20;
therm_w = 10;
therm_t = 4.0;
therm_pad_t = 0.5;
therm_x = 25;               // pocket centre (case frame): behind the phone's middle, clear of the shoe and strike screws
therm_y = 0;
therm_wire_w = 2.2;         // groove for its two leads, to the pass-through
wire_pass_d = thermal_cutoff ? 5.5 : 4.5;   // potted pass-through, back cover -> shoe nose (4-core cable + 2 thermostat leads)

// ------------------------- SHOE + NOSE (Interface C) ----------------
shoe_w = 76;
shoe_h = 70;
shoe_t = 3.0;
shoe_corner_r = 6;
rail_spacing = 56;
rail_len = 60;
rail_root_w = 8.0;
rail_tip_w = 12.0;
rail_depth = 5.0;
rail_side_clearance = 0.25;
rail_floor_clearance = 0.5;
nose_w = 19;
nose_h = 14;                // nose runs from the shoe's bottom edge upward
pad_pocket_w = 17;          // 2-row pad strip (perfboard or PCB), 2.54 mm pitch, matching the pogo pins
pad_pocket_h = 5;
pad_pocket_depth = 2.5;
pad_z = -4.0;               // contact row height (dock frame)

// ------------------------- RECEIVER / DOCK --------------------------
receiver_w = 76;
receiver_back_t = 3.5;
receiver_bottom_y = -53;    // long enough for the 15.85 mm P75 pogo pins and the dock-board pocket
receiver_edge_r = 6;
pin_gap = 0.8;              // docked gap: pad face to pin-block face
pin_free = 1.5;             // pin protrusion when uncompressed
pin_block_w = 17.2;
pin_block_h = 6.0;          // 10 x P75 pogo pins in 2 rows, 2.54 mm apart (row 1: DET VBUS D+ D- GND PRESENT;
                            // row 2: VBUS2 GND2 SPARE1 SPARE2), soldered through a perfboard (or PCB) strip
tunnel_w = 4.5;             // wire tunnel from the board pocket to the pin pocket (8 wires)
tunnel_h = 2.5;
pin_block_depth = 15.6;     // the P75 pins are 15.85 mm long
stop_top_z = -0.3;
rail_stop_extra = 0.5;      // rail end-stop allows 0.5 mm over-travel only

// Dock board pocket: the dock board (hand-wired perfboard OR a small ordered PCB, same circuit, WIRING.md),
// 1.6 mm thick on the pocket floor. It can't grow toward +y (the lower AMPS inserts and the rail channels are
// there), so it runs from the receiver's edge to 1.5 mm short of the pin stop block.
pcb_x0 = -36;
pcb_x1 = -13.5;
pcb_y0 = -49.5;
pcb_y1 = -34.2;             // stops 1 mm short of the lower AMPS inserts
pcb_z0 = -10;
pcb_z1 = -4;
lid_t = 2.0;
// The bike's USB lead is wired straight into the dock (no connector) through a hole in its lower edge, then potted.
cable_x = -26;
cable_z = -7;
cable_d = 4.2;              // most USB leads are 3.5-4 mm thick
// Status LEDs: 3 mm through-hole LEDs standing on the dock board, poking up into light pipes in the strip of dock
// that shows below the case's lower edge. Yellow PWR = bike power in; green DOCK = charging; red OFF = docked but
// not charging (too hot, fault or bad contact).
led_d = 3.2;                // light pipe; filled by the clear potting
led_y = -46.0;
led_x_pwr = -34.0;
led_x_dock = -19.8;
led_x_off = -15.5;

// Detent: two 3D-printed spring arms (flexures) in the nose-channel walls; their bumps snap into V-notches in the
// nose when the case is fully down, holding it on the spring pins (which push it back up the rails) even unlocked.
detent = true;
flex_t = 1.6;               // arm thickness (bends sideways, within the print layers: print the receiver back-face down)
flex_l = 15;                // arm length (fixed at its upper end)
flex_gap = 0.9;             // relief slot behind the arm
flex_under = 0.5;           // gap under the arm, so it is only attached at its root
flex_bump = 0.9;            // bump height from the channel wall (0.6 mm into the nose's side)
flex_y = -22.5;             // bump / notch position (dock frame, case docked)
flex_hold_ang = 60;         // bump flank that resists pulling the case off (steep)
flex_entry_ang = 30;        // bump flank the nose rides over when docking (shallow)
flex_groove = 0.5;          // notch depth in the nose (0.1 mm less than the bump reaches: a light preload, no play)
nose_lead_in = 0.6;         // chamfer on the nose's leading side edges, so the bumps ride on smoothly

// Drains at the low end of the nose and rail channels (rain runs down them to the pins).
drain_d = 3.0;

// Key lock: SELECT a 16 mm (5/8") tubular quarter-turn cam lock, key removable only when
// locked. It sits behind the case's upper-RIGHT corner, the end of the dock farthest from the
// fuel tank, with its axis ACROSS the bike (x), so the key always goes in horizontally from the
// side, at any tilt or mounting height.
// Its cam is replaced by a steel crank (crank_template) whose pin drives a slotted yoke
// (scotch yoke). The yoke lifts a FLAT steel bolt (key steel) into a window in the printed strike
// block on the shoe. The window's load side is a block cut from the same key steel, so the case's
// pull lands on the bolt's wide face flat against steel (a 14 x 6 mm patch), not on a line along a
// round pin. No custom steel parts: the crank is the lock's own cam with one hole drilled in it.
// Pulling the case pushes the bolt sideways (shear), never along its travel, so a tug cannot
// turn the lock; locked, the crank pin is at top dead centre, so pushing the bolt down cannot either.
lock_bore_d = 16.0;         // SELECT
lock_bore_flat = 14.6;      // SELECT: across the flats of the lock thread
lock_panel_t = 3.0;
lock_body_len = 16.0;       // SELECT: panel inner face to the cam seat
lock_nut_clear_d = 22;      // SELECT: lock nut across corners + clearance
lock_nut_len = 4.5;
lock_face_x = 88;           // keyhole face, just inside the case's right edge
lock_z = -14;
crank_t = 3.0;              // SELECT: thickness of the lock's own steel cam, used as the crank (drill it with crank_template)
crank_r = 7.0;              // crank pin radius = bolt travel
crank_pin_d = 4.0;          // M3 shoulder screw with a 4 mm shoulder, threaded into the crank
crank_hub_d = 12;
yoke_t = 5.4;
bolt_w = 14.0;              // SELECT: DIN 6885 parallel-key steel 14 x 9 (h9), 15 mm long. bolt_w runs across the
bolt_t = 9.0;               //   bike (the bearing face), bolt_t along the rails. Pressed + retaining compound into the yoke.
keeper_clear = 0.3;         // window = bolt + this (the pin springs push the case onto the bolt, so play is taken up)
// Strike: by default fully 3D-printed, with a 10 mm offcut of the bolt's key steel (14 x 9, the same bar) glued
// into a pocket on the window's load side as the bearing block. steel_keeper = true restores the laser-cut
// 6 mm steel keeper plate instead (strike_keeper_2d.dxf).
steel_keeper = false;
bearing_block = true;       // printed strike: steel bearing block on the load side (false = plain printed window)
bearing_l = 10;             // block length along the rails (its 14 x 9 section is the key steel's)
keeper_t = 6.0;             // steel_keeper only: 6 mm plate
keeper_csk_d = 6.4;         // steel_keeper only: M3 x 16 countersunk screws through the plate
strike_cbore_d = 6.2;       // printed strike: M3 socket-head counterbores from below
strike_cbore_h = 3.5;
bolt_top_locked = -5.8;
arm_h = 4.3;

// Strike block on the shoe (upper right), held to the back cover by 2 x M3.
strike_x0 = 38.5;
strike_bottom_z = -12;
strike_screw_x = [43, 52];

// Lock pod (part of the receiver): low under the strike's path, tall beside it.
pod_x0 = 28;
pod_low_top_z = -13;
pod_top_z = -1;
pod_bottom_z = -30.5;
roof_t = 3;
lock_cover_t = 2;

amps_offset_y = -10;        // AMPS centre sits this far above the shoe centre (negative = below: the plate sits
                            // low on the case so the lock pod fits above it)

// ------------------------- BASE PLATE (Interface A + B) -------------
base_t = 8;
base_depth = 64;
slot_in = 55;
slot_out = 77;              // plate ends 3 mm inside the case outline; raise (and set hide_plate=false) for wider clamp spacing
hide_plate = true;          // check that the plate and clamps stay hidden behind the case
plate_bolt_y = 18;
slot_cbore_d = 10.5;
slot_cbore_depth = 3.5;
amps_x = 15;
amps_y = 19;
m5_insert_d = 6.4;
grommet_hole_d = 9.5;
grommet_web_t = 3.0;
grommet_cbore_d = 17;
grommet_float = 2.0;
cable_hole_d = 14;
plate_ribs = false;         // the old 8 mm ribs under the plate were its lowest point; off to lower the stack
rib_h = 8;
rib_t = 4;

// ------------------------- HANDLEBAR CLAMPS -------------------------
bar_d = 22.2;               // MEASURE: 22.2 (7/8"), 25.4 (1") or 28.6 (1-1/8")
clamp_bore_d = 29.6;
clamp_w = 24;
clamp_wall = 5.5;
clamp_split_gap = 1.0;
clamp_ear_w = 11;
clamp_ear_h = 12;
clamp_spacing = 150;        // MEASURE: 110-154 with the default plate
// The bike's own handlebar clamp (riser caps + bolt heads) sits under the plate. When the clamps are
// rotated for tilt, the plate swings round the bar, so the rear bolt heads set the limit.
riser_h = 10;               // MEASURE: top of the highest clamp bolt head, above the TOP of the bar (placeholder)
riser_d = 22;               // MEASURE: from the bar centre, fore or aft, to the far edge of that bolt head (placeholder)
riser_reach = sqrt(pow(bar_d/2 + riser_h, 2) + pow(riser_d, 2));   // farthest the bike's clamp reaches from the bar axis
riser_clear = 3;            // gap kept to the underside of the base plate, at any tilt
arm_up_min = 22;            // lowest the clamp itself allows (pad inserts above the clamp-bolt inserts, 6 mm over the bore)
arm_up = max(arm_up_min, riser_reach + riser_clear);   // set automatically: as low as is safe
arm_back = 0;
pad_l = 50;
pad_t = 10;
spacer_h = 0;
tilt = 40;

// ------------------------- DERIVED DIMENSIONS -----------------------
cav_w = phone_l + 2*side_clearance + usb_bay_h;     // phone pocket inside the tongue
cav_h = phone_w + 2*side_clearance;
cav_r = phone_corner_r + side_clearance;
tongue_ow = cav_w + 2*tongue_t;
tongue_oh = cav_h + 2*tongue_t;
tongue_r = cav_r + tongue_t;
shell_iw = tongue_ow + 2*tongue_clear;
shell_ih = tongue_oh + 2*tongue_clear;
shell_ir = tongue_r + tongue_clear;
body_w = shell_iw + 2*shell_wall;
body_h = shell_ih + 2*shell_wall;

phone_x_offset = -usb_side*usb_bay_h/2;
phone_back_z = cover_t + back_pad;
window_z0 = phone_back_z + phone_t + front_gap;
lip_z0 = window_z0 + window_t;
case_depth = lip_z0 + lip_t;

cam_case_x = phone_x_offset - usb_side*camera_y;
cam_case_y = usb_side*camera_x;

nose_y0 = -shoe_h/2;                                 // nose bottom face (pads)
wire_y = nose_y0 + pad_pocket_depth/2;
nose_z0 = -shoe_t - rail_depth;

rx_front_z = -shoe_t;
rx_depth = rail_depth + rail_floor_clearance + receiver_back_t;
rx_back_z = rx_front_z - rx_depth;
rx_top_y = shoe_h/2 + 2;
channel_floor_z = rx_front_z - rail_depth - rail_floor_clearance;
pin_face_y = nose_y0 - pin_gap;
rail_stop_y = -rail_len/2 - rail_stop_extra;
lock_panel_inner_x = lock_face_x - lock_panel_t;
crank_x1 = lock_panel_inner_x - lock_body_len;       // crank sits on the lock's cam seat
crank_x0 = crank_x1 - crank_t;
yoke_x1 = crank_x0 - 0.5;
yoke_x0 = yoke_x1 - yoke_t;
crank_sweep_r = crank_r + (crank_pin_d + 3)/2 + 1;   // 1 mm clear of the crank's outline
pin_lock_z = lock_z + crank_r;                       // pin height when locked (top dead centre)
roof_bottom_z = pod_low_top_z - roof_t;
arm_top_locked = roof_bottom_z - 0.5;
yoke_top_locked = pin_lock_z + crank_pin_d/2 + 1.7;
pod_high_x0 = yoke_x0 - 1.5;                         // tall part of the pod starts just before the yoke
strike_x1 = pod_high_x0 - 0.8;
plate_top_dock_z = rx_back_z - grommet_float;        // base plate top face, in the dock frame
dock_z = arm_up + spacer_h + base_t + grommet_float - rx_back_z;   // dock frame origin above the bar axis (plate frame)
bar_dock_y = amps_offset_y + arm_back;               // bar axis, dock frame (at z = -dock_z)

// Lock y-layout (upper right). The pod starts just above the base plate and the clamp pads,
// which both run under it at the same depth; everything else follows from there.
keeper_win_w = bolt_w + keeper_clear;
keeper_win_t = bolt_t + keeper_clear;
arm_wx = bolt_w + 6;                                 // yoke arm that carries the bolt
arm_wy = bolt_t + 6;
lock_dy_down = max(lock_nut_clear_d/2, crank_r + crank_pin_d/2 + 1.8 + 0.3, crank_sweep_r) + 1.2;  // lock axis to the pod's lower wall
lock_dy_up = max(lock_nut_clear_d/2, crank_sweep_r) + 1.0;                                         // lock axis to the pod's upper wall
pod_y0 = amps_offset_y + max(base_depth, pad_l)/2 + 1.5;
lock_y = pod_y0 + lock_dy_down;                      // lock axis
pod_y1 = lock_y + lock_dy_up;
yoke_y0 = lock_y - crank_r - crank_pin_d/2 - 1.8;    // unlocked, the crank pin points down the rails (-y)
yoke_y1 = lock_y + crank_pin_d/2 + 1.8;
bolt_x = (strike_x0 + strike_x1)/2;
bolt_y = pod_y0 + 1.5 + arm_wy/2 + 0.5;
strike_y1 = body_h/2 - 0.3;
strike_head_d = steel_keeper ? keeper_csk_d : strike_cbore_d;
strike_load_face_y = bolt_y - keeper_win_t/2;        // the window's load side (the case is pulled +y)
strike_screw_y = steel_keeper ? strike_load_face_y - 2 - keeper_csk_d/2
               : strike_load_face_y - (bearing_block ? bearing_l : 4) - 1.5 - strike_cbore_d/2;
strike_y0 = strike_screw_y - strike_head_d/2 - 1.5;
yoke_bottom_locked = arm_top_locked - arm_h;
bolt_len = bolt_top_locked - yoke_bottom_locked;

base_len = 2*(slot_out + 9);
rib_len = 2*(slot_in - clamp_w/2 - 2);
ring_ro = clamp_bore_d/2 + clamp_wall;
clamp_ear_y = clamp_bore_d/2 + 6.5;

function cav_corner(sx, sy) = [sx*(cav_w/2 - cav_r), sy*(cav_h/2 - cav_r)];
function corner_screw_xy(sx, sy) = cav_corner(sx, sy) + corner_screw_diag/sqrt(2)*[sx, sy];

// ------------------------- VALIDATION --------------------------------
assert(phone_w > 40 && phone_l > 80 && phone_t > 5, "Phone dimensions look invalid.");
assert(abs(usb_side) == 1, "usb_side must be +1 or -1.");
assert(phone_port == "usbc" || phone_port == "microusb", "phone_port must be \"usbc\" or \"microusb\".");
assert(abs(usb_port_y) + cable_channel_w/2 + 1 <= cav_h/2 - cav_r, "usb_port_y puts the cable channel into the cavity's rounded corner.");
assert(phone_back_z - camera_protrusion - camera_relief_clearance >= min_rear_skin || !camera_relief_enable,
       "Camera recess leaves too little skin in the back cover.");
assert(corner_screw_diag - corner_insert_d/2 >= shell_ir + 0.3, "Corner insert breaks into the shell interior.");
assert(corner_screw_diag + corner_insert_d/2 + 1.0 <= (cav_r + tongue_t + tongue_clear + shell_wall - case_corner_r)*sqrt(2) + case_corner_r,
       "Corner insert breaks out of the outer corner: reduce case_corner_r.");
assert(cover_t + tongue_h < window_z0 - 1, "Tongue reaches the window.");
assert(shoe_insert_depth + 1.0 <= cover_t + back_pad - 0.5, "Shoe insert skin < 1 mm.");
assert(shoe_h <= body_h - 6 && shoe_w <= body_w - 6, "Shoe does not fit on the case back.");
assert(-wire_y + wire_pass_d/2 + 1 < cav_h/2, "Cable pass-through is outside the sealed cavity.");
assert(phone_w/2 - pad_inset + 4 + 1 < cav_h/2 - 3.5 - cable_channel_w/2, "Raceway runs under the support pads.");
assert(nose_w/2 + 0.3 + 1.5 < amps_x - m5_insert_d/2, "AMPS inserts run into the nose channel.");
assert(amps_x + m5_insert_d/2 + 1 < rail_spacing/2 - rail_tip_w/2 - rail_side_clearance, "AMPS inserts run into the rail channels.");
assert(shoe_mount_x - shoe_csk_d/2 > nose_w/2 + 0.5, "Shoe screws hit the nose.");
assert(strike_bottom_z >= plate_top_dock_z + 1.5, "Strike block would hit the base plate while the case slides in.");
assert(pod_low_top_z <= strike_bottom_z - 0.8, "Strike block would hit the lock pod while the case slides in.");
assert(strike_x1 + 0.8 <= pod_high_x0 && strike_x0 >= receiver_w/2 + 0.4, "Strike block must run between the receiver and the tall part of the pod.");
assert(strike_y1 <= body_h/2 - 0.1, "Strike block sticks out above the case.");
assert(!steel_keeper || min(bolt_top_locked, strike_bottom_z + keeper_t) - strike_bottom_z >= 5.5, "Bolt engages the steel keeper by less than 5.5 mm.");
assert(bolt_top_locked - strike_bottom_z >= 5.5, "Bolt engages the strike by less than 5.5 mm.");
assert(bolt_top_locked - crank_r <= strike_bottom_z - 0.8, "Unlocked bolt still blocks the strike.");
assert(!steel_keeper || (strike_bottom_z + keeper_t + 1.5 <= -shoe_t - 0.5 && bolt_top_locked <= strike_bottom_z + keeper_t + 1.5 - 0.5), "Keeper + bolt-tip pocket do not fit under the shoe plate, or the bolt bottoms out.");
assert(steel_keeper || bolt_top_locked <= -shoe_t - 0.5, "Bolt reaches the shoe plate.");
assert(steel_keeper || !bearing_block || abs(-shoe_t - strike_bottom_z - bolt_t) <= 0.5, "Bearing block (key steel on its side) does not match the strike height.");
assert(bolt_x - keeper_win_w/2 - 2 >= strike_x0 && bolt_x + keeper_win_w/2 + 2 <= strike_x1 && bolt_y + keeper_win_t/2 + 2 <= strike_y1,
       "Bolt window leaves less than 2 mm of wall around it.");
for (x=strike_screw_x) assert(x - strike_head_d/2 >= strike_x0 + 1 && x + strike_head_d/2 <= strike_x1 - 1 && strike_screw_y - strike_head_d/2 >= strike_y0 + 1
                              && strike_load_face_y - (steel_keeper ? 0 : bearing_block ? bearing_l : 0) - (strike_screw_y + strike_head_d/2) >= 1.5,
                              "Strike screw too close to the bolt window, the bearing block or the block edge.");
assert(arm_top_locked - arm_h - crank_r >= pod_bottom_z + lock_cover_t + 0.3, "Unlocked yoke hits the lock cover.");
assert(yoke_top_locked + 0.5 <= pod_top_z - 1.2, "Yoke pocket breaks the top of the pod.");
assert(lock_z + lock_bore_d/2 + 0.3 <= pod_top_z - 1.0 && lock_z + lock_nut_clear_d/2 <= pod_top_z - 1.0, "Lock body or nut breaks the top of the pod.");
assert(lock_y - lock_nut_clear_d/2 >= pod_y0 + 1.0 && lock_y + lock_nut_clear_d/2 <= pod_y1 - 1.0, "Lock nut cavity breaks the pod walls.");
assert(lock_y - crank_sweep_r >= pod_y0 + 1.0 && lock_y + crank_sweep_r <= pod_y1 - 1.0 && lock_z - crank_sweep_r >= pod_bottom_z + lock_cover_t, "Crank sweep breaks out of the pod.");
assert(yoke_y0 >= pod_y0 + 1.0 && yoke_y1 <= pod_y1 - 1.0, "Yoke pocket breaks the pod walls.");
assert(bolt_y - arm_wy/2 - 0.3 >= pod_y0 + 1.0 && bolt_y + arm_wy/2 + 0.3 <= pod_y1 - 1.0, "Bolt-arm pocket breaks the pod walls.");
assert(yoke_x0 - 0.3 >= pod_high_x0 + 1.2, "Yoke pocket breaks into the low part of the pod.");
assert(lock_face_x + 1.2 <= body_w/2 + 0.6, "Lock face sticks out past the case side.");
assert(pod_y0 >= amps_offset_y + base_depth/2 + 1.5, "Lock pod would hit the base plate.");
assert(pod_y0 >= amps_offset_y + pad_l/2 + 1.5, "Lock pod would hit the clamp pads.");
assert(pod_y1 <= body_h/2 + 7, "Lock pod sticks up more than 7 mm above the case.");
assert(-shoe_h/2 > -body_h/2, "Shoe nose must sit inside the case outline.");
assert(clamp_spacing/2 >= slot_in && clamp_spacing/2 <= slot_out, "clamp_spacing outside the slot range.");
assert(!hide_plate || base_len <= body_w - 4, "Base plate sticks out past the case: reduce slot_out or set hide_plate=false.");
assert(!hide_plate || amps_offset_y - base_depth/2 >= -body_h/2, "Base plate sticks out below the case: raise amps_offset_y or set hide_plate=false.");
function ranges_clear(a0, a1, b0, b1, gap) = a1 + gap <= b0 || b1 + gap <= a0;
// Dock board: socket envelope and LEDs inside the pocket; LEDs clear of the socket and visible below the case.
for (x=[led_x_pwr, led_x_dock, led_x_off]) assert(x - led_d/2 >= pcb_x0 + 0.3 && x + led_d/2 <= pcb_x1 - 0.3 && led_y - led_d/2 >= pcb_y0 + 0.3
                                        && abs(x - cable_x) >= cable_d/2 + led_d/2 + 0.4, "LED light pipe outside the board pocket or on the bike lead's hole.");
assert(led_y + led_d/2 <= -body_h/2 - 0.8, "LED light pipes are hidden behind the case: move led_y down.");
assert(pcb_x1 + 1.5 <= -12, "Dock board pocket runs into the pin stop block.");
assert(abs(led_x_off - led_x_dock) >= led_d + 0.5 && abs(led_x_dock - led_x_pwr) >= led_d + 0.5, "LED light pipes too close together.");
assert(pin_face_y - pin_block_depth >= receiver_bottom_y + 1.0, "Pin pocket breaks out of the dock's lower edge.");
assert(pad_z + pin_block_h/2 <= stop_top_z - 0.6 && pad_z - pin_block_h/2 >= rx_back_z + 2, "Pin pocket breaks out of the stop block.");
assert(-42 + tunnel_w <= pcb_y1 - 0.5 && pad_z - tunnel_h >= pcb_z0, "Wire tunnel runs outside the board pocket.");
// Flexure detent: arms + slots clear of the AMPS inserts and rail channels; notch on the nose; strain within PETG/ASA's
// fatigue range (< 1 %).
flex_w0 = nose_w/2 + 0.3;                            // nose-channel wall
flex_dl = flex_bump/tan(flex_hold_ang);              // bump flanks along the rails
flex_du = flex_bump/tan(flex_entry_ang);
flex_strain = 3*flex_t*(flex_bump - 0.3)/(2*flex_l*flex_l);
assert(!detent || (flex_y - 2 >= amps_offset_y - amps_y + m5_insert_d/2 + 0.4 && flex_y + flex_l + 0.8 <= amps_offset_y + amps_y - m5_insert_d/2),
       "Flexure arm runs into an AMPS insert.");
assert(!detent || flex_w0 + flex_t + flex_gap <= rail_spacing/2 - rail_tip_w/2 - rail_side_clearance - 1, "Flexure arm runs into a rail channel.");
assert(!detent || (flex_y - flex_groove/tan(flex_hold_ang) >= nose_y0 + 2 && flex_y + flex_groove/tan(flex_entry_ang) + 0.2 <= nose_y0 + nose_h - 0.3),
       "Flexure notch is off the nose.");
assert(!detent || flex_strain <= 0.01, "Flexure arm strain over 1 %: make it longer or thinner.");
echo(flexure_strain_percent = 100*flex_strain);
// Drains: clear of the board pocket, the AMPS inserts and the lid.
for (p = drain_points()) assert(ranges_clear(p[1] - drain_d/2, p[1] + drain_d/2, pcb_y0 - 0.8, pcb_y1 + 0.8, 1) || ranges_clear(p[0] - drain_d/2, p[0] + drain_d/2, pcb_x0 - 1, pcb_x1 + 1, 1), "Drain hole runs into the dock board pocket.");
for (p = drain_points(), sx=[-1,1], sy=[-1,1]) assert(norm([p[0] - sx*amps_x, p[1] - (amps_offset_y + sy*amps_y)]) >= drain_d/2 + m5_insert_d/2 + 1, "Drain hole runs into an AMPS insert.");
// Thermostat: 1 mm skin under it, clear of the shoe/strike inserts, inside the cavity.
assert(!thermal_cutoff || therm_floor_z >= 1.0, "Thermostat pocket leaves less than 1 mm under it: use a thinner thermostat or pad.");
assert(!thermal_cutoff || (abs(therm_y) + therm_w/2 + 0.2 + 1 <= cav_h/2 && therm_x + therm_l/2 + 0.2 <= cav_w/2 - usb_bay_h - 1), "Thermostat pocket is outside the phone area.");
for (p = concat([for (sx=[-1,1], sy=[-1,1]) [sx*shoe_mount_x, sy*shoe_mount_y]], [for (x=strike_screw_x) [x, strike_screw_y]]))
  assert(!thermal_cutoff || !(abs(p[0] - therm_x) < therm_l/2 + shoe_boss_d/2 + 0.5 && abs(p[1] - therm_y) < therm_w/2 + shoe_boss_d/2 + 0.5), "Thermostat pocket runs into a shoe or strike screw.");
for (sx=[-1,1], sy=[-1,1]) let(ix = sx*amps_x, iy = amps_offset_y + sy*amps_y)
  assert(ranges_clear(iy - m5_insert_d/2, iy + m5_insert_d/2, pcb_y0 - 0.8, pcb_y1 + 0.8, 1)
         || ranges_clear(ix - m5_insert_d/2, ix + m5_insert_d/2, pcb_x0 - 1, pcb_x1 + 1, 1), "AMPS insert runs into the dock board pocket.");
assert(!hide_plate || clamp_spacing/2 + clamp_w/2 <= body_w/2, "Clamps stick out past the case: reduce clamp_spacing or set hide_plate=false.");
assert(bar_d <= clamp_bore_d - 0.9, "Bar is too big for the clamp bore.");
plate_under_z = arm_up + spacer_h - (plate_ribs ? rib_h : 0);   // lowest point of the plate, above the bar axis
assert(plate_under_z >= riser_reach + riser_clear, "Base plate would hit the bike's handlebar clamp: raise arm_up or spacer_h.");
echo(arm_up=arm_up, riser_reach=riser_reach, dock_z=dock_z, amps_offset_y=amps_offset_y);
echo(lock_focus=[lock_face_x, lock_y, lock_z], bolt_focus=[(bolt_x + yoke_x1)/2, bolt_y, (strike_bottom_z + yoke_bottom_locked)/2]);
echo(bolt_section=[bolt_x, strike_load_face_y]);
assert(plate_under_z >= clamp_bore_d/2 + 4, "Base plate too close to the bar.");
assert(arm_up - 9 >= clamp_split_gap/2 + 9 + 1.5, "Plate-bolt inserts run into the clamp-bolt inserts.");
assert(arm_up - pad_t >= 0 && arm_up - clamp_bore_d/2 >= 6, "Too little clamp material above the bar.");
// Lock pod vs the bike's handlebar clamp envelope and the bar (dock frame; bar axis at y = bar_dock_y, z = -dock_z).
// The pod is wholly above and beside the bar axis, so its nearest point is its lower inner corner.
assert(pod_y0 > bar_dock_y && pod_bottom_z > -dock_z
       && norm([pod_y0 - bar_dock_y, dock_z + pod_bottom_z]) >= max(riser_reach, clamp_bore_d/2) + riser_clear,
       "Lock pod would hit the bar or the bike's handlebar clamp.");

// ------------------------- GEOMETRY HELPERS --------------------------
module rounded_prism(w, h, d, r) {
  rr = min(r, min(w,h)/2 - 0.01);
  linear_extrude(height=d)
    offset(r=rr)
      square([w-2*rr, h-2*rr], center=true);
}

module xz_profile_along_y(points, y_min, y_max) {
  translate([0,y_max,0])
    rotate([90,0,0])
      linear_extrude(height=y_max-y_min)
        polygon(points=points);
}

module raceway(points, w, depth, z_top) {
  for (i=[0:len(points)-2]) hull() {
    translate([points[i][0], points[i][1], z_top-depth]) cylinder(d=w, h=depth+0.05);
    translate([points[i+1][0], points[i+1][1], z_top-depth]) cylinder(d=w, h=depth+0.05);
  }
}

// ------------------------- SLIM CASE (case frame) ---------------------
// Pads sit 11 mm in from the phone edges so they stay inside its rounded corners.
pad_inset = 11;
module phone_support_pads() {
  pad = 8.0;
  for (sx=[-1,1], sy=[-1,1])
    translate([phone_x_offset + sx*(phone_l/2-pad_inset), sy*(phone_w/2-pad_inset), cover_t - 0.01])
      rounded_prism(pad, pad, back_pad + 0.01, 1.5);
}

module shoe_bosses() {
  for (sx=[-1,1], sy=[-1,1])
    translate([sx*shoe_mount_x, sy*shoe_mount_y, cover_t - 0.01])
      cylinder(d=shoe_boss_d, h=back_pad - 0.5 + 0.01);
  for (x=strike_screw_x)
    translate([x, strike_screw_y, cover_t - 0.01]) cylinder(d=shoe_boss_d, h=back_pad - 0.5 + 0.01);
}

// Pass-through -> along the bottom edge (outside the pads) -> up into the USB bay, ending under the port.
function raceway_points() = let(
  y_edge = -cav_h/2 + 3.5,
  x_bay  = usb_side*(cav_w/2 - usb_bay_h/2)
) [[0, wire_y], [0, y_edge], [x_bay, y_edge], [x_bay, usb_port_y]];

therm_floor_z = phone_back_z - therm_pad_t - therm_t;   // thermostat pocket floor (case frame)
function therm_groove_points() = [[therm_x - therm_l/2, therm_y], [6, therm_y], [6, wire_y], [0, wire_y]];

// Front shell: side walls + thin front lip. The window is bonded to the lip from inside.
module case_shell() {
  difference() {
    translate([0,0,cover_t]) rounded_prism(body_w, body_h, case_depth - cover_t, case_corner_r);
    translate([0,0,cover_t - 0.05]) rounded_prism(shell_iw, shell_ih, lip_z0 - cover_t + 0.05, shell_ir);
    translate([phone_x_offset, 0, lip_z0 - 0.05])
      rounded_prism(phone_l - 2*screen_mask, phone_w - 2*screen_mask, lip_t + 0.1, max(2, phone_corner_r - screen_mask));
    for (sx=[-1,1], sy=[-1,1]) {
      p = corner_screw_xy(sx, sy);
      translate([p[0], p[1], cover_t - 0.05]) cylinder(d=corner_insert_d, h=corner_insert_depth + 0.05);
    }
  }
}

// Back cover: plate + tongue with a radial O-ring groove, pads, shoe bosses, raceway.
module case_back() {
  difference() {
    union() {
      rounded_prism(body_w, body_h, cover_t, case_corner_r);
      translate([0,0,cover_t - 0.01]) difference() {
        rounded_prism(tongue_ow, tongue_oh, tongue_h + 0.01, tongue_r);
        translate([0,0,-0.05]) rounded_prism(cav_w, cav_h, tongue_h + 0.2, cav_r);
      }
      phone_support_pads();
      shoe_bosses();
    }
    // Radial O-ring groove around the tongue.
    translate([0,0,cover_t + tongue_h/2 - oring_groove_w/2]) difference() {
      rounded_prism(tongue_ow + 1, tongue_oh + 1, oring_groove_w, tongue_r + 0.5);
      translate([0,0,-0.05])
        rounded_prism(tongue_ow - 2*oring_groove_depth, tongue_oh - 2*oring_groove_depth,
                      oring_groove_w + 0.1, tongue_r - oring_groove_depth);
    }
    // Corner screws (countersunk from the back) into the shell's inserts.
    for (sx=[-1,1], sy=[-1,1]) {
      p = corner_screw_xy(sx, sy);
      translate([p[0], p[1], -0.05]) {
        cylinder(d=corner_screw_clear, h=cover_t + 0.1);
        cylinder(d1=corner_csk_d + 0.1, d2=corner_screw_clear, h=(corner_csk_d - corner_screw_clear)/2 + 0.05);
      }
    }
    // Shoe and strike inserts, blind from the outside back face.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, sy*shoe_mount_y, -0.05]) cylinder(d=shoe_insert_d, h=shoe_insert_depth + 0.05);
    for (x=strike_screw_x)
      translate([x, strike_screw_y, -0.05]) cylinder(d=shoe_insert_d, h=shoe_insert_depth + 0.05);
    // Camera relief.
    if (camera_relief_enable && camera_protrusion > 0)
      translate([cam_case_x, cam_case_y, phone_back_z - camera_protrusion - camera_relief_clearance])
        rounded_prism(camera_h + 2*camera_relief_clearance, camera_w + 2*camera_relief_clearance,
                      camera_protrusion + camera_relief_clearance + back_pad, 5);
    // Cable raceway on the inside face, and the potted pass-through into the shoe nose.
    raceway(raceway_points(), cable_channel_w, cable_channel_depth, cover_t);
    translate([0, wire_y, -0.05]) cylinder(d=wire_pass_d, h=cover_t + 0.1);
    // Thermostat pocket (it sits on a 1 mm skin; its top + thermal pad meets the phone's back) and its lead groove.
    if (thermal_cutoff) {
      translate([therm_x - therm_l/2 - 0.2, therm_y - therm_w/2 - 0.2, therm_floor_z]) cube([therm_l + 0.4, therm_w + 0.4, cover_t + back_pad]);
      raceway(therm_groove_points(), therm_wire_w, 1.2, cover_t);
    }
  }
}

// Template for the 2 mm polycarbonate window (bonded to the inside of the lip).
module window_template() {
  rounded_prism(shell_iw - 0.3, shell_ih - 0.3, window_t, shell_ir - 0.15);
}

// ------------------------- SHOE (dock frame) --------------------------
module dock_shoe() {
  difference() {
    union() {
      translate([0,0,-shoe_t]) rounded_prism(shoe_w, shoe_h, shoe_t, shoe_corner_r);
      for (sx=[-1,1]) {
        xc = sx*rail_spacing/2;
        xz_profile_along_y([
          [xc-rail_root_w/2, -shoe_t+0.01], [xc+rail_root_w/2, -shoe_t+0.01],
          [xc+rail_tip_w/2, nose_z0], [xc-rail_tip_w/2, nose_z0]
        ], -rail_len/2, rail_len/2);
      }
      // Nose: carries the contact pads (bottom face).
      translate([-nose_w/2, nose_y0, nose_z0]) cube([nose_w, nose_h, -nose_z0 - 0.01]);
      // Strike block (upper right) + the plate that ties it into the shoe. With steel_keeper, the
      // laser-cut keeper plate (strike_keeper) is its bottom keeper_t mm, screwed on underneath.
      strike_z0 = steel_keeper ? strike_bottom_z + keeper_t : strike_bottom_z;
      translate([shoe_w/2 - 10, strike_y0, -shoe_t]) cube([strike_x1 - shoe_w/2 + 10, strike_y1 - strike_y0, shoe_t]);
      translate([strike_x0, strike_y0, strike_z0]) cube([strike_x1 - strike_x0, strike_y1 - strike_y0, -shoe_t - strike_z0 + 0.01]);
    }
    if (steel_keeper) {
      // Blind pocket for the bolt tip above the keeper window (3 mm shoe plate above it).
      translate([bolt_x - keeper_win_w/2 - 0.15, bolt_y - keeper_win_t/2 - 0.15, strike_bottom_z + keeper_t - 0.05])
        cube([keeper_win_w + 0.3, keeper_win_t + 0.3, 1.5 + 0.05]);
      // Strike screws (through the keeper) into inserts in the back cover.
      for (x=strike_screw_x) translate([x, strike_screw_y, strike_bottom_z + keeper_t - 0.05]) cylinder(d=3.4, h=-strike_bottom_z - keeper_t + 0.1);
    } else {
      // Bolt window, blind under the shoe plate.
      translate([bolt_x - keeper_win_w/2, bolt_y - keeper_win_t/2, strike_bottom_z - 0.05]) cube([keeper_win_w, keeper_win_t, -shoe_t - strike_bottom_z + 0.05]);
      // Pocket for the key-steel bearing block on the load side (glued in from below; the load pushes it into the plastic).
      if (bearing_block) translate([bolt_x - bolt_w/2 - 0.1, strike_load_face_y - bearing_l - 0.1, strike_bottom_z - 0.05])
        cube([bolt_w + 0.2, bearing_l + 0.1 + 0.05, -shoe_t - strike_bottom_z + 0.05]);
      // Strike screws: M3 socket head, counterbored from below, into inserts in the back cover.
      for (x=strike_screw_x) translate([x, strike_screw_y, strike_bottom_z - 0.05]) {
        cylinder(d=3.4, h=-strike_bottom_z + 0.1);
        cylinder(d=strike_cbore_d, h=strike_cbore_h + 0.05);
      }
    }
    // Detent dimples in both sides of the nose, and lead-in chamfers on its leading side edges.
    for (sx=[-1,1]) {
      // Flexure V-notch, same flank angles as the bump.
      if (detent) translate([0, 0, nose_z0 - 0.05]) linear_extrude(-nose_z0 - shoe_t + 0.05)
        polygon([[sx*(nose_w/2 + 0.1), flex_y - (flex_groove + 0.1)/tan(flex_hold_ang)], [sx*(nose_w/2 - flex_groove), flex_y],
                 [sx*(nose_w/2 + 0.1), flex_y + (flex_groove + 0.1)/tan(flex_entry_ang)]]);
      translate([0, 0, nose_z0 - 0.05]) linear_extrude(-nose_z0 - shoe_t + 0.05)
        polygon([[sx*(nose_w/2 + 0.1), nose_y0 - 0.1], [sx*(nose_w/2 - nose_lead_in), nose_y0 - 0.1], [sx*(nose_w/2 + 0.1), nose_y0 + nose_lead_in + 0.1]]);
    }
    // Pad board pocket in the nose's bottom face.
    translate([-pad_pocket_w/2, nose_y0 - 0.05, pad_z - pad_pocket_h/2])
      cube([pad_pocket_w, pad_pocket_depth + 0.05, pad_pocket_h]);
    // Cable hole from the pad pocket up to the back cover's pass-through (pot both).
    translate([0, wire_y, pad_z + pad_pocket_h/2 - 0.05]) cylinder(d=wire_pass_d - 0.5, h=-pad_z + 1);
    // Countersunk M3 screws into the back cover.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*shoe_mount_x, sy*shoe_mount_y, -shoe_t - 0.05]) {
        cylinder(d=shoe_screw_clear, h=shoe_t + 0.1);
        cylinder(d1=shoe_csk_d + 0.1, d2=shoe_screw_clear, h=(shoe_csk_d - shoe_screw_clear)/2 + 0.05);
      }
  }
}

// ------------------------- RECEIVER / DOCK (dock frame) ---------------
module dock_receiver() {
  difference() {
    union() {
      translate([0, (receiver_bottom_y + rx_top_y)/2, rx_back_z])
        rounded_prism(receiver_w, rx_top_y - receiver_bottom_y, rx_depth, receiver_edge_r);
      // Stop block that carries the spring pins, rising up beside the nose.
      translate([-12, receiver_bottom_y, rx_back_z]) cube([24, pin_face_y - receiver_bottom_y, stop_top_z - rx_back_z]);
      lock_pod_solid();
    }
    // Dovetail channels (same flank slope as the rails), closed at the bottom.
    for (sx=[-1,1]) {
      xc = sx*rail_spacing/2;
      r0 = rail_root_w/2 + rail_side_clearance;
      r1 = rail_tip_w/2 + rail_side_clearance;
      xz_profile_along_y([
        [xc-r0, rx_front_z+0.1], [xc+r0, rx_front_z+0.1],
        [xc+r0, rx_front_z], [xc+r1, nose_z0], [xc+r1, channel_floor_z],
        [xc-r1, channel_floor_z], [xc-r1, nose_z0], [xc-r0, rx_front_z]
      ], rail_stop_y, rx_top_y + 1);
    }
    // Nose channel down to the pin block.
    translate([-nose_w/2 - 0.3, pin_face_y, channel_floor_z])
      cube([nose_w + 0.6, rx_top_y + 1 - pin_face_y, rx_front_z - channel_floor_z + 0.1]);
    // Spring-pin pocket: 10 P75 pogo pins in 2 rows, pointing +Y.
    translate([-pin_block_w/2, pin_face_y - pin_block_depth, pad_z - pin_block_h/2])
      cube([pin_block_w, pin_block_depth + 0.05, pin_block_h]);
    lock_pod_cuts();
    // Dock board pocket + lid recess + bike-lead hole + wire channel to the pins.
    translate([pcb_x0, pcb_y0, pcb_z0]) cube([pcb_x1 - pcb_x0, pcb_y1 - pcb_y0, pcb_z1 - pcb_z0]);
    translate([pcb_x0 - 1, pcb_y0 - 0.8, rx_back_z - 0.05]) cube([pcb_x1 - pcb_x0 + 2, pcb_y1 - pcb_y0 + 1.6, pcb_z0 - rx_back_z + 0.1]);
    translate([cable_x, receiver_bottom_y - 0.05, cable_z]) rotate([-90,0,0])
      cylinder(d=cable_d, h=pcb_y0 - receiver_bottom_y + 0.1, $fn=24);   // bike lead, wired straight in and potted
    translate([pcb_x1 - 0.05, -42, pad_z - tunnel_h]) cube([-pin_block_w/2 - pcb_x1 + 0.1, tunnel_w, tunnel_h]);   // 8 wires
    // LED light pipes through the 1 mm roof of the board pocket.
    for (x=[led_x_pwr, led_x_dock, led_x_off]) translate([x, led_y, pcb_z1 - 0.05]) cylinder(d=led_d, h=rx_front_z - pcb_z1 + 0.1, $fn=24);
    // Detent (flexure): free each arm from the body on its back, underneath and at its lower end; it stays attached at its top.
    if (detent) for (sx=[-1,1]) {
      xa = sx > 0 ? flex_w0 - 0.05 : -(flex_w0 + flex_t + flex_gap);
      zb = channel_floor_z - flex_under;
      translate([sx > 0 ? flex_w0 + flex_t : -(flex_w0 + flex_t + flex_gap), flex_y - 2, zb]) cube([flex_gap, flex_l + 2, rx_front_z - zb + 0.1]);   // back
      translate([xa, flex_y - 2, zb]) cube([flex_t + flex_gap + 0.05, flex_l + 2, flex_under]);                                                     // under
      translate([xa, flex_y - 2, zb]) cube([flex_t + flex_gap + 0.05, 1, rx_front_z - zb + 0.1]);                                                   // lower end
    }
    // Drains: from the low end of the nose channel and of each rail channel, out through the back.
    for (p = drain_points()) translate([p[0], p[1], rx_back_z - 0.05]) cylinder(d=drain_d, h=channel_floor_z - rx_back_z + 0.1, $fn=24);
    // Interface B: AMPS M5 inserts.
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*amps_x, amps_offset_y + sy*amps_y, rx_back_z - 0.05]) cylinder(d=m5_insert_d, h=5.05);
  }
  // Flexure bumps on the arms' channel faces: shallow ramp on top (the nose rides over it when docking),
  // steep face below (resists the pins' push and pulling the case off).
  if (detent) for (sx=[-1,1])
    translate([0, 0, channel_floor_z + 0.5]) linear_extrude(rx_front_z - 0.5 - channel_floor_z - 0.5)
      polygon([[sx*(flex_w0 + 0.3), flex_y - flex_dl - 0.2], [sx*(flex_w0 - flex_bump), flex_y], [sx*(flex_w0 + 0.3), flex_y + flex_du + 0.5]]);
}

function drain_points() = [[0, pin_face_y + drain_d/2 + 0.6], [-rail_spacing/2, rail_stop_y + drain_d/2 + 0.6], [rail_spacing/2, rail_stop_y + drain_d/2 + 0.6]];

// Lock pod (dock frame), upper right, just above the base plate. Low part (z <= pod_low_top_z) runs
// under the strike's path and is fused under the receiver; the tall part beside it holds the lock,
// crank and yoke.
pod_low_x0 = bolt_x - arm_wx/2 - 4;
pod_web_y1 = min(pod_y1, rx_top_y - receiver_edge_r);   // part of the pod that sits under the receiver
module lock_pod_solid() {
  // Tapers from a thin web under the receiver to full depth at the bolt.
  hull() {
    translate([pod_x0, pod_y0, pod_low_top_z - 6]) cube([1, pod_web_y1 - pod_y0, 6]);
    translate([pod_low_x0, pod_y0, pod_bottom_z]) cube([pod_high_x0 + 1 - pod_low_x0, pod_y1 - pod_y0, pod_low_top_z - pod_bottom_z]);
  }
  // Fuse into the underside of the receiver (inside its outline, clear of the strike's path).
  translate([pod_x0 + 0.5, pod_y0 + 0.5, pod_low_top_z - 0.5])
    cube([receiver_w/2 - 1 - pod_x0, pod_web_y1 - 0.5 - pod_y0 - 0.5, rx_back_z - pod_low_top_z + 1]);
  translate([pod_high_x0, (pod_y0 + pod_y1)/2, pod_bottom_z])
    translate([(lock_face_x - pod_high_x0)/2, 0, 0]) rounded_prism(lock_face_x - pod_high_x0, pod_y1 - pod_y0, pod_top_z - pod_bottom_z, 3);
}

module lock_pod_cuts() {
  // Lock body bore, D-shaped panel bore, nut cavity (reached from below, under the cover).
  translate([crank_x1 - 0.05, lock_y, lock_z]) rotate([0,90,0]) cylinder(d=lock_bore_d + 0.6, h=lock_panel_inner_x - crank_x1 + 0.1);
  translate([lock_panel_inner_x - 0.05, lock_y, lock_z]) rotate([0,90,0])
    intersection() {
      cylinder(d=lock_bore_d, h=lock_panel_t + 0.2);
      translate([-lock_bore_flat/2, -lock_bore_d/2, -0.1]) cube([lock_bore_flat, lock_bore_d, lock_panel_t + 0.4]);
    }
  translate([lock_panel_inner_x - lock_nut_len, lock_y - lock_nut_clear_d/2, pod_bottom_z - 1])
    cube([lock_nut_len, lock_nut_clear_d, lock_z + lock_nut_clear_d/2 - pod_bottom_z + 1]);
  // Crank sweep.
  translate([crank_x0 - 0.4, lock_y, lock_z]) rotate([0,90,0]) cylinder(r=crank_sweep_r, h=crank_x1 - crank_x0 + 0.5);
  // Yoke pocket (full travel), open underneath for assembly.
  translate([yoke_x0 - 0.3, yoke_y0 - 0.3, pod_bottom_z - 1])
    cube([yoke_x1 - yoke_x0 + 0.6, yoke_y1 - yoke_y0 + 0.6, yoke_top_locked + 0.5 - pod_bottom_z + 1]);
  // Arm pocket under the roof, open underneath.
  translate([bolt_x - arm_wx/2 - 0.3, bolt_y - arm_wy/2 - 0.3, pod_bottom_z - 1])
    cube([yoke_x0 + 1 - bolt_x + arm_wx/2 + 0.3, arm_wy + 0.6, roof_bottom_z - pod_bottom_z + 1]);
  // Bolt guide through the roof (rectangular, for the flat bolt).
  translate([bolt_x - keeper_win_w/2, bolt_y - keeper_win_t/2, roof_bottom_z - 0.05]) cube([keeper_win_w, keeper_win_t, roof_t + 0.1]);
  // Cover recess + 2 x M3 inserts.
  translate([pod_low_x0 + 1, pod_y0 + 1.5, pod_bottom_z - 0.05])
    cube([lock_panel_inner_x - (pod_low_x0 + 1), pod_y1 - pod_y0 - 3, lock_cover_t + 0.05]);
  for (p = lock_cover_screws()) translate([p[0], p[1], pod_bottom_z + lock_cover_t - 0.05]) cylinder(d=4.2, h=5.05);
}

// On the pod's upper side, clear of the arm pocket, the lock bore and the nut.
function lock_cover_screws() = [[bolt_x - 2, pod_y1 - 4], [lock_panel_inner_x - lock_nut_len - 5, pod_y1 - 4]];

module lock_cover() {
  difference() {
    translate([pod_low_x0 + 1.2, pod_y0 + 1.7, pod_bottom_z])
      cube([lock_panel_inner_x - (pod_low_x0 + 1) - 0.4, pod_y1 - pod_y0 - 3.4, lock_cover_t - 0.1]);
    for (p = lock_cover_screws()) translate([p[0], p[1], pod_bottom_z - 0.05]) {
      cylinder(d=3.4, h=lock_cover_t + 0.1);
      cylinder(d1=6.4, d2=3.4, h=1.5);
    }
    // Drain slot under the bolt (water that gets past the strike runs out).
    translate([bolt_x - 1.5, bolt_y - 3, pod_bottom_z - 0.05]) cube([3, 6, lock_cover_t + 0.1]);
  }
}

// Yoke + arm, printed in PA12 (or machined aluminium). turn: 0 = unlocked, 1 = locked.
function yoke_dz(turn) = crank_r*(sin(90*turn) - 1);
module lock_yoke(turn=1) {
  translate([0, 0, yoke_dz(turn)]) difference() {
    union() {
      translate([yoke_x0, yoke_y0, yoke_bottom_locked]) cube([yoke_t, yoke_y1 - yoke_y0, yoke_top_locked - yoke_bottom_locked]);
      translate([bolt_x - arm_wx/2, bolt_y - arm_wy/2, yoke_bottom_locked]) cube([yoke_x0 - bolt_x + arm_wx/2 + 0.5, arm_wy, arm_h]);
    }
    // Horizontal slot for the crank pin (lets the case's pull pass by without turning the crank).
    translate([yoke_x0 - 0.1, lock_y - crank_r - crank_pin_d/2 - 0.3, pin_lock_z - crank_pin_d/2 - 0.2])
      cube([yoke_t + 0.2, crank_r + crank_pin_d + 0.6, crank_pin_d + 0.4]);
    // Bolt press-fit pocket (rectangular, for the key-steel bolt).
    translate([bolt_x - (bolt_w - 0.1)/2, bolt_y - (bolt_t - 0.1)/2, yoke_bottom_locked - 0.05]) cube([bolt_w - 0.1, bolt_t - 0.1, arm_h + 0.1]);
  }
}

// Steel keeper: the bottom of the strike block (dock frame). The flat bolt rises into its window;
// the case's pull presses the window's lower edge flat against the bolt's 14 mm face.
module strike_keeper_2d() {
  difference() {
    translate([strike_x0, strike_y0]) square([strike_x1 - strike_x0, strike_y1 - strike_y0]);
    translate([bolt_x - keeper_win_w/2, bolt_y - keeper_win_t/2]) square([keeper_win_w, keeper_win_t]);
    for (x=strike_screw_x) translate([x, strike_screw_y]) circle(d=3.4);
  }
}

module strike_keeper() {
  difference() {
    translate([0, 0, strike_bottom_z]) linear_extrude(keeper_t) strike_keeper_2d();
    for (x=strike_screw_x) translate([x, strike_screw_y, strike_bottom_z - 0.05])          // countersinks, from below
      cylinder(d1=keeper_csk_d + 0.1, d2=3.4, h=(keeper_csk_d - 3.4)/2 + 0.05);
  }
}

// Key-steel bearing block (printed strike): 14 x 9 key steel lying on its side, 10 mm long.
module strike_bearing_block() {
  translate([bolt_x - bolt_w/2, strike_load_face_y - bearing_l, strike_bottom_z]) cube([bolt_w, bearing_l, bolt_t]);
}
// Whichever steel part the strike uses.
module keeper_part() { if (steel_keeper) strike_keeper(); else if (bearing_block) strike_bearing_block(); }

module lock_bolt(turn=1) {
  color([0.7,0.7,0.74]) translate([bolt_x - bolt_w/2, bolt_y - bolt_t/2, yoke_bottom_locked + yoke_dz(turn)]) cube([bolt_w, bolt_t, bolt_len]);
}

// Crank = the lock's own steel cam. Print crank_template as a drilling guide: put it on the cam's square,
// clamp, and drill the 2.5 mm hole (then tap M3) for the shoulder-screw crank pin.
module crank_template() {
  difference() {
    hull() {
      cylinder(d=crank_hub_d, h=crank_t);
      translate([0, crank_r, 0]) cylinder(d=crank_pin_d + 3, h=crank_t);
    }
    translate([0,0,-0.05]) linear_extrude(crank_t + 0.1) square(4.1, center=true); // SELECT: lock spindle
    translate([0, crank_r, -0.05]) cylinder(d=2.5, h=crank_t + 0.1);           // drill guide: 2.5 mm, then tap M3 for the shoulder screw
  }
}

// Crank + pin in the dock frame. Unlocked: pin toward -y (rider edge); locked: pin straight up.
module crank_placed(turn=1) {
  translate([crank_x0, lock_y, lock_z]) rotate([180 - 90*turn, 0, 0]) rotate([0,90,0]) {
    crank_template();
    translate([0, crank_r, -(crank_x0 - yoke_x0 - 0.3)]) cylinder(d=crank_pin_d, h=crank_x0 - yoke_x0 - 0.3 + 0.01);
  }
}

module lock_mechanism(turn=1) {
  if (lock_type == "printed") plk_placed(turn);
  else color([0.75,0.75,0.78]) crank_placed(turn);
  color([0.55,0.58,0.62]) lock_yoke(turn);
  lock_bolt(turn);
}

module dock_lid() {
  translate([pcb_x0 - 0.9, pcb_y0 - 0.7, rx_back_z])
    cube([pcb_x1 - pcb_x0 + 1.8, pcb_y1 - pcb_y0 + 1.4, pcb_z0 - rx_back_z - 0.1]);
}

// ------------------------- BASE PLATE (plate frame) -------------------
module base_plate_holes_2d() {
  for (sx=[-1,1], sy=[-1,1]) {
    hull() for (x=[slot_in, slot_out]) translate([sx*x, sy*plate_bolt_y]) circle(d=5.5);
    translate([sx*amps_x, sy*amps_y]) circle(d=grommet_hole_d);
  }
  circle(d=cable_hole_d);
}

module base_plate() {
  difference() {
    union() {
      translate([0,0,-base_t]) rounded_prism(base_len, base_depth, base_t, 8);
      if (plate_ribs) for (sy=[-1,1])
        translate([-rib_len/2, sy*(base_depth/2 - rib_t/2) - rib_t/2, -base_t - rib_h])
          cube([rib_len, rib_t, rib_h + 0.05]);
    }
    translate([0,0,-base_t-0.05]) linear_extrude(base_t+0.1) base_plate_holes_2d();
    for (sx=[-1,1], sy=[-1,1])
      hull() for (x=[slot_in, slot_out])
        translate([sx*x, sy*plate_bolt_y, -slot_cbore_depth]) cylinder(d=slot_cbore_d, h=slot_cbore_depth+0.05);
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*amps_x, sy*amps_y, -base_t-0.05]) cylinder(d=grommet_cbore_d, h=base_t-grommet_web_t+0.05);
  }
}

module base_plate_2d() {
  difference() {
    offset(r=8) square([base_len-16, base_depth-16], center=true);
    base_plate_holes_2d();
  }
}

// ------------------------- HANDLEBAR CLAMPS (clamp frame) -------------
module clamp_body() {
  difference() {
    union() {
      hull() {
        intersection() {
          rotate([0,90,0]) cylinder(r=ring_ro, h=clamp_w, center=true);
          translate([-clamp_w/2-1, -ring_ro-1, clamp_split_gap/2]) cube([clamp_w+2, 2*ring_ro+2, ring_ro+1]);
        }
        translate([-clamp_w/2, -arm_back - pad_l/2, arm_up - pad_t]) cube([clamp_w, pad_l, pad_t]);
      }
      for (sy=[-1,1])
        translate([-clamp_w/2, sy*clamp_ear_y - clamp_ear_w/2, clamp_split_gap/2])
          cube([clamp_w, clamp_ear_w, clamp_ear_h]);
    }
    rotate([0,90,0]) cylinder(d=clamp_bore_d, h=clamp_w+2, center=true);
    for (sy=[-1,1]) {
      translate([0, sy*clamp_ear_y, clamp_split_gap/2 - 0.05]) cylinder(d=m5_insert_d, h=9);
      translate([0, -arm_back + sy*plate_bolt_y, arm_up - 9]) cylinder(d=m5_insert_d, h=9.05);
    }
  }
}

module clamp_cap() {
  difference() {
    union() {
      intersection() {
        rotate([0,90,0]) cylinder(r=ring_ro, h=clamp_w, center=true);
        translate([-clamp_w/2-1, -ring_ro-1, -ring_ro-1]) cube([clamp_w+2, 2*ring_ro+2, ring_ro+1-clamp_split_gap/2]);
      }
      for (sy=[-1,1])
        translate([-clamp_w/2, sy*clamp_ear_y - clamp_ear_w/2, -clamp_split_gap/2 - clamp_ear_h])
          cube([clamp_w, clamp_ear_w, clamp_ear_h]);
    }
    rotate([0,90,0]) cylinder(d=clamp_bore_d, h=clamp_w+2, center=true);
    for (sy=[-1,1]) translate([0, sy*clamp_ear_y, -clamp_split_gap/2 - clamp_ear_h - 0.05]) {
      cylinder(d=5.5, h=clamp_ear_h+0.1);
      cylinder(d=10, h=4);
    }
  }
}

module bar_shim() {
  wall = (clamp_bore_d - bar_d)/2;
  if (wall < 1.0) echo("bar_d fits the clamp with 0.5 mm rubber tape; no shim needed.");
  else for (i=[0,1]) translate([i*(clamp_bore_d + 4), 0, 0])
    difference() {
      intersection() {
        cylinder(d=clamp_bore_d - 0.2, h=clamp_w);
        translate([-clamp_bore_d, 0.3, -1]) cube([2*clamp_bore_d, clamp_bore_d, clamp_w + 2]);
      }
      translate([0,0,-1]) cylinder(d=bar_d, h=clamp_w + 2);
    }
}

module pad_spacer(h = (spacer_h > 0 ? spacer_h : 10)) {
  difference() {
    translate([-clamp_w/2, -pad_l/2, 0]) cube([clamp_w, pad_l, h]);
    for (sy=[-1,1]) translate([0, sy*plate_bolt_y, -0.05]) cylinder(d=5.5, h=h+0.1);
  }
}


// ------------------------- PREVIEW HELPERS ---------------------------
module demo_phone() {
  color([0.15,0.15,0.17,0.6])
    translate([phone_x_offset, 0, phone_back_z]) rounded_prism(phone_l, phone_w, phone_t, phone_corner_r);
}


module dock_stack() {
  translate([0,0,EXPLODE]) {
    color([0.22,0.25,0.28]) translate([0,0,EXPLODE*0.6]) case_shell();
    color([0.30,0.33,0.36]) case_back();
    if (SHOW_PHONE) translate([0,0,EXPLODE*0.3]) demo_phone();
    color([0.35,0.75,0.95,0.35]) translate([0,0,window_z0 + EXPLODE*0.9]) window_template();
  }
  translate([0,0,EXPLODE*0.4]) { color([0.25,0.28,0.32]) dock_shoe(); color([0.62,0.62,0.66]) keeper_part(); }
  color([0.38,0.42,0.46]) dock_receiver();
  color([0.30,0.30,0.30]) translate([0,0,-EXPLODE*0.5]) dock_lid();
  lock_mechanism(1);
  color([0.30,0.30,0.30]) translate([0,0,-EXPLODE*0.5]) lock_cover();
}

module on_plate() {
  rotate([tilt,0,0]) translate([0, -arm_back, arm_up + spacer_h + base_t + EXPLODE*0.5]) children();
}

module assembly() {
  for (sx=[-1,1]) translate([sx*clamp_spacing/2, 0, 0]) rotate([tilt,0,0]) {
    color([0.30,0.33,0.36]) clamp_body();
    color([0.30,0.33,0.36]) translate([0,0,-EXPLODE*0.3]) clamp_cap();
    if (spacer_h > 0) color([0.4,0.4,0.4]) translate([0,-arm_back,arm_up]) pad_spacer();
  }
  on_plate() {
    color([0.20,0.45,0.70]) base_plate();
    translate([0, -amps_offset_y, grommet_float - rx_back_z + EXPLODE]) dock_stack();
  }
  if (SHOW_BAR) % rotate([0,90,0]) cylinder(d=bar_d, h=700, center=true);
}

include <printed_lock.scad>

// ------------------------- PART SELECTOR -----------------------------
if (PART == "assembly") assembly();
else if (PART == "case_shell") case_shell();
else if (PART == "case_back") case_back();
else if (PART == "window_template") window_template();
else if (PART == "shoe") dock_shoe();
else if (PART == "receiver") dock_receiver();
else if (PART == "dock_lid") dock_lid();
else if (PART == "base_plate") base_plate();
else if (PART == "base_plate_2d") base_plate_2d();
else if (PART == "clamp_body") clamp_body();
else if (PART == "clamp_cap") clamp_cap();
else if (PART == "bar_shim") bar_shim();
else if (PART == "pad_spacer") pad_spacer();
else if (PART == "lock_yoke") lock_yoke(1);
else if (PART == "crank_template") crank_template();
else if (PART == "lock_cover") lock_cover();
else if (PART == "strike_keeper") strike_keeper();
else if (PART == "strike_keeper_2d") translate([-strike_x0, -strike_y0]) strike_keeper_2d();   // laser template, corner at the origin
else if (plk_is_part(PART)) plk_part(PART);
else if (PART != "none") echo("Unknown PART.");

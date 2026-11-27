/*
  HELMET HEADSET v1: a cheap Bluetooth neckband taken apart and rebuilt as a helmet headset. OpenSCAD 2021.01.
  PART selects what to show or export (list below).

  Owner's choices (2026-11-26): "using a cheap neckband and then dismantle this and use this as a helmet headset";
  designed first for a MODULAR (flip-up) helmet; the neckband is picked for the owner (boAt Rockerz 255 Pro+, the
  commonest in India; any neckband fits once its parts are measured); the board, battery and buttons go in a slim
  POD stuck to the OUTSIDE of the shell on the LEFT with VHB tape (no holes in the helmet).

  What goes where:
    - POD (outside, left, behind the chin bar's pivot): the neckband's own board (Bluetooth, amplifier, charging,
      its USB-C socket at the pod's rear end), its battery (or a flat 602030 LiPo), and a small perfboard with 3
      tactile switches wired in parallel with the board's own buttons (multi-function, volume +, volume -). A TPU
      keypad (also the seam's gasket) under a screwed lid gives a round multi-function button and a dedicated VOLUME
      ROCKER across the pod (owner, 2026-11-26: "have a dedicated volumen button", chose a rocker): press its top for
      louder, its bottom for quieter; it rocks on a small printed post glued to the switch board. It clips onto a
      CRADLE stuck to the shell (see DETACHABLE below). A TPU plug seals the USB-C.
    - SIZE: the neckband settings default to room for MOST cheap neckbands, not all (owner, 2026-11-26: "make the 3d
      pod fit most of the headsets", then "its too big ... it fine if some neckbands dont fit ... a lot smaller"):
      a board up to 50 x 12 and a battery up to 35 x 20 x 6 (300 mAh class), or a long thin one up to about 12 x 50,
      packed with foam. The board is STACKED on the battery (owner chose "stacked: short"): the pod is short (about
      60 x 37 mm) and 23 mm proud. A bigger neckband: enter its sizes and the pod grows.
    - SPEAKERS (inside): the neckband's OWN speakers (owner, 2026-11-26: "why can i use its own speaker and mic ??
      that the reason i am using it on the first place"): each earbud's 10 mm driver (boAt's spec) taken out of its
      shell and set in a printed puck that fills the liner's ear pocket. Optional upgrade: 40 mm 32 ohm helmet
      speakers fit the same puck (spk_d = 40, spk_t = 5.5): louder at speed.
    - MIC (inside): the neckband's OWN mic, on longer wires, on a bendable boom held by a thin plate between the
      shell and the liner on the left, BEHIND the chin bar, so the chin bar flips up over it and no wire crosses
      the hinge.
    - Wires from the pod: no hole in the helmet (owner, 2026-11-26: "the wires ... will be routed not using some
      hole in the helmet instead from below the helmet so have some grooves to route those wires"). They leave the
      pod through 2 notches in its bottom wall at shell level, straight into the grooves of a flexible TPU CABLE
      CHANNEL stuck to the shell from the pod down to the shell's lower edge (run_l, MEASURE), then go in under the
      edge trim.
      Then (owner, 2026-11-26: "how about the cable go on the back part and have groves too will help in water proofing
      too", choosing "out of the pod's back end"): the notches were in the pod's BACK END wall, under the USB-C, facing
      away from rain and the wind; the channel left backward and curved round and down to the edge.
      Then (owner, 2026-11-26: "as the mounting will be on the side with the long side laying horizontally on the
      helmet i feel the holes groves should open on the long side which means it will exit on the bottom side"): the
      notches are in the pod's BOTTOM long side (-y), under the neckband's board, facing DOWN (water drains away from
      them); the channel runs straight down from there to the shell's lower edge, no turn.
      Then (owner, 2026-11-27: "cable channel from the side is not need but is need for the back", choosing "pod at the
      lower edge"): the pod sits along the shell's lower edge (pod_edge above it, its long side parallel to the edge),
      so the cables leave its bottom notches and tuck straight in under the edge trim: no side channel. The back box
      keeps its channel.

    - BATTERY ON THE BACK (owner, 2026-11-27: "build a version where the battery is in a different compartment maybe
      on the back of the helmet to reduce the bulk on the sides"): batt_at = "back" (the default) puts the neckband's
      battery in its own slim BACK BOX stuck on the back of the helmet (a PETG base curved to the shell, a TPU cover
      that snaps over it, no screws); the side pod keeps the board and the keys and gets about 6 mm thinner. The
      battery's 2-core lead runs down a short grooved channel under the back's lower edge, inside along the edge to the
      left, and out under the edge straight into the pod's third notch. batt_at = "pod" keeps it in the pod.

    - DETACHABLE (owner, 2026-11-27: "i need detachable mounting for the battery as well as the control unit as i
      would need to detach them while cleaning the helmet, so the mounting hardware will be permanently stuck to the
      helmet and the hardware will be clipped on to it, and the electrical connection too will be in the mount
      itself"): each unit (the pod, the back box) sits on its own PETG CRADLE, stuck to the shell with the VHB tape
      (its underside curved to the shell: shell_rl, shell_rw, shell_bk: MEASURE) and never taken off. The unit drops
      onto it `slide` mm high (2 dovetail tongues under it into windows in the cradle's grooves), slides down (the
      tongues under the grooves' lips) and a springy tooth clicks up behind it; press the tooth and slide it up to
      take it off. The contacts are 5-pin magnetic pogo connectors (2 for the pod, 1 for the back box): the males in
      the units' bottom walls, the females potted in a ledge along each cradle's bottom side, all the helmet's wiring
      (speakers, mic, the battery's lead) soldered to the females and leaving the ledge facing down.

  Frames: the POD frame has its origin on the pod's underside (= its cradle's top) at its centre, x along the pod toward the helmet's
  BACK, y up, z out of the shell. The HELMET frame (the stand-in, for pictures only) has x forward, y to the
  rider's left, z up, origin at the centre of the stand-in's shell.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// Views: "assembly" (the stand-in helmet with the pod), "pod" (the pod assembled), "exploded", "inside" (the
// stand-in cut open: speakers, boom, mic), "back_view", "back_exploded". Parts: "pod_body", "pod_lid", "keypad" (TPU), "usb_plug" (TPU),
// "bb_base", "bb_cover" (TPU), "bb_channel" (TPU) (the back box, batt_at = "back"),
// "rocker_post" (the volume rocker's pivot), "speaker_puck" (x2), "mic_cup", "boom_mount", "headset_assembled" (view only). Checks: "check_*" (see the end).
PART = "assembly";

// ------------------------- YOUR HELMET (MEASURE) -------------------------
// The shell's curvature where the pod goes (behind the chin bar's pivot, lower left). Measure it with a straight
// ruler: lay a length L across the shell, measure the gap h at its middle: radius = L*L/(8*h) + h/2.
shell_rl = 175;     // MEASURE: radius of the shell along the pod (front to back, level)
shell_rw = 160;     // MEASURE: radius of the shell across the pod (up and down)
vhb_t = 1.1;        // SELECT: VHB tape thickness (3M 4910 / 5952 are about 1.1 mm)
ear_d = 52;         // MEASURE: the liner's ear pocket: diameter
ear_depth = 10;     // MEASURE: ... and depth
ear_pocket = [ear_d, ear_depth];

// ------------------------- THE NECKBAND'S PARTS -------------------------
// The defaults are room for MOST cheap neckbands (estimates from common neckband and LiPo pouch sizes: no neckband
// publishes its insides); the biggest won't fit. Smaller parts are packed with foam. If yours is bigger, or to make
// the pod as small as it can be, open your neckband and enter its own sizes (MEASURE). The board lies on the battery.
nb_len = 50;             // MEASURE: the main board: length (along the USB-C); default room: 50 (the battery sets the pod's length)
nb_w = 12;               // MEASURE: ... width; default 12
nb_t = 1.0;              // MEASURE: ... PCB thickness; default 1.0
nb_pcb = [nb_len, nb_w, nb_t];
nb_under = 1.5;          // MEASURE: the tallest part under the board (it rests on the battery on a foam pad this thick)
nb_over = 2.5;           // MEASURE: the tallest part on top of the board, besides the USB-C socket
usb = [8.94, 3.26];      // the USB-C socket's shell: width, height (standard; top-mounted on the board)
usb_out = 0.5;           // MEASURE: how far the socket sticks out past the board's end
batt_l = 35;             // MEASURE: the neckband's own battery: length; default room: 35 (fits a 401230, 402030, 502030, 602030 ...)
batt_w = 20;             // MEASURE: ... width; default 20 (a cell up to 12 wide passes between the lid's posts: up to about 50 long)
batt_t = 6;              // MEASURE: ... thickness; default 6 (300 mAh cells such as 602030)
batt = [batt_l, batt_w, batt_t];

// ------------------------- CONTROLS -------------------------
tact_h = 7;              // SELECT: tactile switch height, 6 x 6 mm (7 mm: the actuator reaches up into the dome)
tact_body = 3.5;         // the switch's body height
key_x = [-9, 9];         // along the pod (front to back): the multi-function button, the volume rocker
main_d = 12;             // the multi-function button: a round dome (play/pause, calls, voice assistant, power)
rock_w = 10;             // the VOLUME ROCKER: a long key across the pod (up and down): width ...
rock_l = 20;             // ... and length. Press its top end for louder, its bottom end for quieter
rock_s = 6;              // its 2 switches sit this far above and below its middle; a post under its middle is the pivot
proud = [1.8, 1.4];      // how far each key stands above the lid (at least: taller switches raise them)
post = 3;                // the rocker's pivot post (printed, glued to the switch board): square

// ------------------------- SPEAKERS AND MIC -------------------------
spk_d = 10;              // MEASURE: the earbud's own driver: diameter (10 mm per boAt; a 40 mm helmet speaker: 40)
spk_t = 4;               // MEASURE: ... thickness (a 40 mm helmet speaker: 5.5)
spk = [spk_d, spk_t];
mic = [6, 2.7];          // MEASURE: the neckband's own mic: diameter, length (a 6 x 2.7 mm electret capsule is typical)
boom_d = 5;              // MEASURE: the boom: 2 mm aluminium wire + the mic cable in heat-shrink
cable_d = [4.2, 3.4];    // MEASURE: the 2 cables out of the pod: speakers (4-core), mic (shielded 2-core)

// ------------------------- WHERE THE BATTERY GOES -------------------------
batt_at = "back";        // SELECT: "back": in its own slim box on the back of the helmet (the side pod about 6 mm thinner);
                         //   "pod": in the side pod, under the board
bat_cable = 3.0;         // MEASURE: the battery's lead to the pod (a thin 2-core cable, or a twisted pair in heat-shrink)
shell_bk = [120, 140];   // MEASURE: the shell's radii where the back box goes: across (side to side), up and down
bk_at = -38;             // where on the back (the stand-in: height of the box's middle, mm from the shell's centre)
run_b = 60;              // MEASURE: the back box's channel: from its bottom side straight down to the shell's lower edge
pod_edge = 3;            // SELECT: the pod's cradle sits this far above the shell's lower edge (its cables tuck straight in under the edge trim)

// ------------------------- DETACHABLE: CRADLES AND CONNECTORS -------------------------
// (owner, 2026-11-27: "i need detachable mounting for the battery as well as the control unit as i would need to
// detach them while cleaning the helmet, so the mounting hardware will be permanently stuck to the helmet and the
// hardware will be clipped on to it, and the electrical connection too will be in the mount itself")
// Each unit (the pod, the back box) sits on its own CRADLE (PETG), which stays stuck to the helmet with the VHB tape.
// The unit's underside and the cradle's top are the same cylinder (curved along the unit like the shell, straight up
// and down), so the unit can slide down it. Two short DOVETAIL TONGUES under the unit drop into WINDOWS in the
// cradle's 2 grooves, then the unit slides down `slide` mm: the tongues go under the grooves' lips (it can't come
// away from the helmet), and a springy TOOTH in the cradle clicks up behind the unit's top side (it can't slide back
// up). To take it off: press the tooth, slide the unit up, lift it off. The contacts are off-the-shelf 5-pin MAGNETIC
// POGO CONNECTORS (2.54 mm): the male (spring pins) in the unit's bottom wall, the female (flat contacts) in a ledge
// along the cradle's bottom side, facing up; sliding down brings their faces together (the magnets pull it home).
// All the wiring stays on the helmet with the cradles; the units come off clean.
mag_l = 18;              // MEASURE: the 5-pin magnetic pogo connector's face: length (along its row of pins)
mag_h = 5;               // MEASURE: ... height
mag = [mag_l, mag_h];
mag_m = 6;               // MEASURE: the male's body depth behind its face (its spring pins stand out of the face)
mag_f = 4.5;             // MEASURE: the female's body depth
mag_tail = 3.0;          // MEASURE: the solder tails behind each
cr_t = 2.4;              // the cradle at its middle (thicker toward its top and bottom, where the shell curves away)
slide = 6;               // the unit drops in this far above home, then slides down this far
dt_w = 5;                // the dovetail tongues: width at the root ...
dt_d = 1.2;              // ... depth (they flare 35 degrees each side) ...
dt_s = 5;                // ... and each segment's length (2 segments per tongue)
rcl = 0.2;               // the clearance round the tongues
latch_l = 14;            // the latch: a springy arm in the cradle above the unit's top side, this long ...
arm_w = 3.5;             // ... and wide ...
arm_t = 1.4;             // ... and thick, with a tooth at its tip
tooth = 1.0;             // the tooth's height (the arm bends down this far under the unit)

// ------------------------- FIXED SIZES -------------------------
wall = 2.2;      // pod wall at the seam (thicker lower down: the sides curve in toward the top)
side_in = 1.2;   // how far the sides curve in from the bottom to the seam
fl = 1.6;        // floor (at the middle; thicker toward the ends, where the shell curves away)
rc = 9;          // the pod's corner radius in plan (outside, at the bottom): its ends straight in the middle, for the cradle's rails
rr = 3.5;        // the lid's rolled edge, sideways (its height is the lid's)
kp_t = 1.0;      // keypad sheet
squeeze = 0.2;   // the keypad squeezed at the rim
lid_t = 2.2;
dome_w = 1.0;    // dome wall
hinge = 1.2;     // free sheet round each dome (the lid's hole is this much bigger all round)
pil_d = 6;       // lid screw pillars (M2 heat-set inserts, 3.2 mm hole)
usb_gap = 0.5;   // from the USB-C socket's face to the inside of the back wall
$fn = 40;

// ------------------------- DERIVED -------------------------
wall0 = wall + side_in;                       // the wall at the bottom
rc_in = rc - wall0;                           // the cavity's corner radius
pil_o = rc_in - (rc_in - 2.8) / sqrt(2);      // the pillars sit in the cavity's rounded corners
in_pod = batt_at == "pod";
cabs = in_pod ? cable_d : concat(cable_d, [bat_cable]);   // the cables out of the pod's bottom side: speakers, mic (, the battery's lead)
mag_in = mag_m - 0.3 + mag_tail - wall0 + 0.3;      // the male connectors reach this far into the pod past its bottom wall
pc_x = [-(mag[0]/2 + 0.6), mag[0]/2 + 0.6];          // the pod's 2 connectors, side by side in its bottom wall
pc_z = 1.0;                                          // the connectors' bottom edge, above the units' underside (and the cradles' ledge)
Wi = max((in_pod ? batt[1] : nb_pcb[1]) + 2 * (0.3 + mag_in),     // inside width: the battery (or the board) clear of the connectors,
         nb_pcb[1] + 2 * (pil_o + pil_d/2 + 0.35),                         // the board between the pillars,
         usb[0] + 2 * (rc_in - sqrt(pow(rc_in - 0.15, 2) - pow(rc_in - usb_gap, 2))) + 0.1,   // the USB-C socket clear of the rounded back end,
         2 * (rock_l/2 + hinge + 1 + rr + side_in + 0.1) - 2 * wall0);      // and the volume rocker on the lid's flat top
room_end = pil_o + pil_d/2 + 0.3;             // at each end: a wide battery stays between the pillars
batt_narrow = batt[1]/2 + 0.3 <= Wi/2 - pil_o - pil_d/2;   // a narrow battery passes between them: only the rounded ends limit it
batt_dy = max(0, batt[1]/2 - (Wi/2 - rc_in));
batt_end = batt_narrow ? rc_in - sqrt(pow(rc_in - 0.3, 2) - pow(batt_dy, 2)) + 0.05 : room_end;
Li = max(usb_gap + usb_out + nb_pcb[0] + 1.5, in_pod ? batt[0] + 2 * batt_end : 0,   // inside length: the board (from the back wall), the battery,
         2 * (pc_x[1] + mag[0]/2 + 0.1 + 0.3 + pil_d/2 + pil_o),            // the connectors between the pillars,
         2 * (max([for (x = key_x) abs(x)]) + 3 + 0.4 + max(room_end, rc_in)));   // and the switch board under the keys
sw_l = 2 * min(Li/2 - room_end, Li/2 - rc_in) - 0.4;   // the switch perfboard's length: between the pillars, on the straight sides
L = Li + 2 * wall0;
W = Wi + 2 * wall0;
pcb_x1 = Li/2 - usb_gap - usb_out;               // the board's rear end (the USB-C end)
pcb_x0 = pcb_x1 - nb_pcb[0];
bat_x0 = -batt[0]/2;                          // the battery in the middle, on the floor
bat_x1 = batt[0]/2;
z_pcb0 = fl + (in_pod ? batt[2] + 0.3 : 0.3) + nb_under;   // the board lies on the battery (on a foam pad), or on the floor's ribs
z_pcb1 = z_pcb0 + nb_pcb[2];
usb_zc = z_pcb1 + usb[1]/2;
z_board = max(z_pcb1 + nb_over, z_pcb1 + usb[1]);
z_sw = max(z_board + 0.4, pc_z + mag[1] + 1.8);   // the switch perfboard's underside (on ledges; over the connectors too)
z_sw1 = z_sw + 1.6;
z_seam = z_sw1 + tact_body + 0.6;            // the body's rim = the keypad's underside
z_lid0 = z_seam + kp_t - squeeze;
z_top = z_lid0 + lid_t;
act_top = z_sw1 + tact_h;
roof_in = act_top + 0.3;                      // the domes' hollow (0.3 over the actuator)
function dome_top(i) = max(z_top + proud[i], roof_in + 0.8 + (proud[i] - min(proud)));   // taller switches: taller domes
KEY = [[key_x[0], main_d, main_d], [key_x[1], rock_w, rock_l]];   // the keys: x, size along the pod, size across it
SW = [[key_x[0], 0], [key_x[1], rock_s], [key_x[1], -rock_s]];    // the switches: multi-function, volume +, volume -
SW_KEY = [0, 1, 1];
pocket_d = [main_d - 2*dome_w, rock_w - 2*dome_w - 2];          // the hollows over the switches (the rocker's are smaller: a solid middle)
function zs(x, R) = sqrt(R*R - x*x) - R;      // the units' underside = the cradles' top: a cylinder, radius R, along y
R_p = shell_rl + vhb_t + cr_t;                 // ... the pod's
z_low = zs(L/2 + 3, R_p) - 1;                  // below the pod's lowest point (it's cut by the cylinder)
pil = [for (sx = [-1, 1], sy = [-1, 1]) [sx * (Li/2 - pil_o), sy * (Wi/2 - pil_o)]];
function side_d(z) = side_in * pow(max(0, z - z_low) / (z_seam - z_low), 2);   // the sides' inward curve
usb_hole = [12.6, 6.6];                       // room for a USB-C plug's moulding
cab_gap = [for (i = [0:len(cabs) - 2]) max(6, (cabs[i] + cabs[i + 1])/2 + 0.4 + 2.4)];   // the cables' spacing (2.4 between their notches)
cab_off = [for (i = [0:len(cabs) - 1]) i == 0 ? 0 : sum_to(cab_gap, i)];
function sum_to(v, n) = n <= 0 ? 0 : v[n - 1] + sum_to(v, n - 1);
cab_s = cab_off[len(cabs) - 1];                              // from the first cable to the last
cab_xc = 0;                                                  // the cables leave the cradle's ledge at its middle, facing down
cab_mid = ((cab_off[0] - (cabs[0] + 0.4)/2) + (cab_off[len(cabs) - 1] + (cabs[len(cabs) - 1] + 0.4)/2))/2;   // (the channel centred, not the cables)
cab_x = [for (o = cab_off) cab_xc + o - cab_mid];           // speakers (toward the front), mic (, the battery)
usb_tab = 5;                                                 // the plug's pull tab points up
plug_x = L/2 - side_d(usb_zc - usb_hole[1]/2 - 1.2) + 0.2;   // the plug's flange: clear of the wall at its lowest point
function zb_at(x, y) = -(x*x/(2*shell_rl) + y*y/(2*shell_rw)); // the shell under the pod (near enough: a parabola)

puck_t = spk[1] + 1.5 + 1.2;                  // speaker + room for its solder tabs + back
puck_d = max(spk[0] + 4, 40);

echo(str("POD: ", L, " x ", W, " mm, ", z_top + cr_t, " mm above the tape at its middle (with its cradle); cradle ", L, " x ", y_top(W) - y_low(W), " mm; battery in the ", batt_at, "; ",
         "lid screws 4 x M2 x 6 countersunk; speaker pucks ", puck_d, " x ", puck_t, " mm"));

// ------------------------- CHECKS ON THE SETTINGS -------------------------
for (i = [0:1]) {
  assert(dome_top(i) - roof_in >= 0.8, str("key ", i + 1, ": its roof is too thin; use taller tactile switches (tact_h)"));
  assert(abs(KEY[i][0]) + KEY[i][1]/2 + hinge < L/2 - side_in - rr - 1, "the keys don't fit on the lid");
  assert(KEY[i][2]/2 + hinge < W/2 - side_in - rr - 1, "a key is too long for the lid's flat top");
}
assert(key_x[1] - key_x[0] - (main_d + rock_w)/2 - 2*hinge >= 1.6, "the keys are too close for the ridge between them");
assert(rock_s + pocket_d[1]/2 <= rock_l/2 - dome_w, "the rocker's switches are too far apart for its length");
assert(rock_s - 3 >= post/2 + 0.5, "the rocker's switches hit its pivot post");
assert(rock_s - pocket_d[1]/2 >= post/2, "the rocker's pivot post is under a switch's hollow: no solid middle to rock on");
assert(rock_s + 3 <= (Wi - 0.6)/2 - 0.5, "the rocker's switches are off the switch board");
assert(sw_l/2 < Li/2 - pil_o - pil_d/2 - 0.3, "the switch board hits the lid's pillars");
assert(sw_l/2 <= Li/2 - rc_in, "the switch board's corners are in the cavity's rounded ends");
assert(Wi/2 - pil_o - pil_d/2 >= nb_pcb[1]/2 + 0.3, "the lid's pillars hit the neckband's board");
assert(max([for (p = SW) abs(p[0])]) + 3 < sw_l/2, "a switch is off the end of the switch board");
assert(z_sw1 + tact_body < z_seam, "the switches' bodies hit the keypad");
assert(act_top >= z_seam + 0.8, "the tactile switches are too short to reach up into the domes (tact_h)");
assert(!in_pod || batt_narrow || bat_x1 <= Li/2 - room_end + 0.01, "the battery runs into the pillars");
assert(!in_pod || norm([max(0, bat_x1 - (Li/2 - rc_in)), max(0, batt[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the battery's corners hit the pod's rounded ends");
assert(batt_at == "pod" || batt_at == "back", "batt_at: \"pod\" or \"back\"");
assert(pc_x[1] + mag[0]/2 + 0.3 <= Li/2 - rc_in, "the pod's connectors run off its bottom wall's straight part");
assert(-Wi/2 + mag_in <= -nb_pcb[1]/2 - 0.3, "the pod's connectors run into the neckband's board");
assert(pc_z + mag[1] + 0.2 <= z_sw - 1.6, "the pod's connectors run into the switch board's ledges");
assert(norm([max(0, pc_x[1] + mag[0]/2 + 0.1 - (Li/2 - pil_o)), max(0, -Wi/2 + mag_in - (-(Wi/2 - pil_o)))]) >= pil_d/2 + 0.3 || pc_x[1] + mag[0]/2 + 0.1 <= Li/2 - pil_o - pil_d/2 - 0.3, "the pod's connectors hit the lid's pillars");
assert(norm([max(0, -pcb_x0 - (Li/2 - rc_in)), max(0, nb_pcb[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the board's corners hit the pod's rounded front end");
assert(norm([max(0, pcb_x1 + usb_out - (Li/2 - rc_in)), max(0, usb[0]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.15, "the USB-C socket's corners hit the pod's rounded back end");
assert(norm([max(0, pcb_x1 - (Li/2 - rc_in)), max(0, nb_pcb[1]/2 - (Wi/2 - rc_in))]) <= rc_in - 0.3, "the board's corners hit the pod's rounded back end");
assert(puck_t <= ear_pocket[1] + 0.01, str("the speaker puck (", puck_t, " mm) is deeper than the ear pocket"));
assert(puck_d <= ear_pocket[0], "the speaker puck is wider than the ear pocket");
assert(shell_rl >= 90 && shell_rw >= 90, "shell radius too small for this pod: measure again");

// ------------------------- HELPERS -------------------------
module rrect(s, r) offset(r) square([s[0] - 2*r, s[1] - 2*r], center = true);
module pod_2d(d = 0) offset(r = -d) rrect([L, W], rc);      // the pod's outline, d inward
module slab(z, d) translate([0, 0, z]) linear_extrude(0.01) pod_2d(d);
module shell_cut(up = 0)                     // the shell (grown by the tape): the pod's underside follows it
  translate([0, 0, up - shell_rw]) scale([sqrt(shell_rl * shell_rw), shell_rw, shell_rw]) sphere(1, $fn = 240);

// ------------------------- THE POD -------------------------
module body_outer() hull() for (i = [0:6]) let(z = z_low + (z_seam - z_low) * i/6) slab(z - (i == 6 ? 0.01 : 0), side_d(z));

module ledges()                               // the switch board rests on these (chamfered under, so they print)
  for (s = [-1, 1]) hull() {
    translate([-sw_l/2 - 2, s > 0 ? Wi/2 - 1.6 : -Wi/2 - 0.5, z_sw - 0.01]) cube([sw_l + 4, 2.1, 0.01]);
    translate([-sw_l/2 - 2, s > 0 ? Wi/2 : -Wi/2 - 0.5, z_sw - 1.6]) cube([sw_l + 4, 0.5, 0.01]);
  }

module pod_body() union() {
  difference() {
    union() {
      difference() {
        body_outer();
        translate([0, 0, fl]) linear_extrude(z_seam) pod_2d(wall0);
      }
      intersection() {
        union() {
          for (p = pil) translate([p[0], p[1], z_low]) cylinder(d = pil_d, h = z_seam - z_low);
          ledges();
        }
        body_outer();
      }
    }
    iface(R_p);                                               // its underside: the cradle's cylinder
    for (p = pil) translate([p[0], p[1], z_seam - 4.5]) cylinder(d = 3.2, h = 5);    // M2 inserts
    translate([Li/2 - 0.5, 0, usb_zc]) rotate([0, 90, 0]) linear_extrude(wall0 + 2)    // USB-C plug
      rotate(90) rrect(usb_hole, 2.5);
    male_holes(W, pc_x);                                      // the 2 connectors, in its bottom wall
  }
  tongues(R_p, dt_x(L));                                      // under it: they run in the cradle's grooves
}

module pod_lid() difference() {
  union() {
    hull() for (i = [0:8]) let(a = 90 * i/8)                 // a quarter-ellipse roll from the seam to the top
      slab(z_lid0 + lid_t * sin(a) - (i == 8 ? 0.01 : 0), side_in + rr * (1 - cos(a)));
    hull() for (s = [-1, 1])                                  // a ridge between the keys (to find them with gloves)
      translate([(key_x[0] + main_d/2 + key_x[1] - rock_w/2)/2, s * 6, z_top - 0.2]) sphere(r = 0.9, $fn = 16);
  }
  translate([0, 0, z_lid0 - 0.01]) linear_extrude(squeeze + 0.1) pod_2d(wall0 + 0.6);  // squeeze only at the rim
  for (i = [0:1]) translate([KEY[i][0], 0, z_lid0 - 1]) linear_extrude(lid_t + 3) offset(r = hinge) key_2d(i);
  for (p = pil) translate([p[0], p[1], z_lid0 - 1]) {
    cylinder(d = 2.3, h = lid_t + 3);
    translate([0, 0, 1 + lid_t - 1.1]) cylinder(d1 = 1.9, d2 = 4.1, h = 1.11);       // M2 countersunk
  }
}

function key_ends(i) = let(d = KEY[i][1], e = (KEY[i][2] - d)/2) [[0, -e], [0, e]];   // a round key: both ends at the middle
module key_2d(i) hull() for (p = key_ends(i)) translate(p) circle(d = KEY[i][1], $fn = 48);
module dome(i) hull() {                                       // a key: round (the multi-function) or a long pill (the rocker)
  linear_extrude(dome_top(i) - z_seam - 1) key_2d(i);
  for (p = key_ends(i)) translate([p[0], p[1], dome_top(i) - z_seam - 1])
    rotate_extrude($fn = 48) translate([KEY[i][1]/2 - 1, 0]) circle(1, $fn = 16);
}
module rocker_marks()                                         // raised + (top end) and - (bottom end), to feel with gloves
  translate([key_x[1], 0, dome_top(1) - 0.01]) linear_extrude(0.6) {
    translate([0, rock_s]) { square([5, 1.2], center = true); square([1.2, 5], center = true); }
    translate([0, -rock_s]) square([5, 1.2], center = true);
  }

module keypad() difference() {                               // TPU: the keys and the seam's gasket
  union() {
    translate([0, 0, z_seam]) linear_extrude(kp_t) pod_2d(side_in + 0.4);
    for (i = [0:1]) translate([KEY[i][0], 0, z_seam]) dome(i);
    rocker_marks();
  }
  for (j = [0:2]) translate([SW[j][0], SW[j][1], z_seam - 0.01])           // the hollows: an actuator reaches up into each
    cylinder(d = pocket_d[SW_KEY[j]], h = roof_in - z_seam + 0.01, $fn = 40);
  for (i = [0:1]) translate([KEY[i][0], 0, z_seam - 0.01]) linear_extrude(0.42) difference() {   // thin hinge round each key
    offset(r = hinge) key_2d(i); key_2d(i);
  }
  for (p = pil) translate([p[0], p[1], z_seam - 1]) cylinder(d = 2.6, h = 3);
}

module post_shape() linear_extrude(tact_body + 0.6) rrect([post, post], 0.8);   // = z_seam - z_sw1
module rocker_post() translate([key_x[1], 0, z_sw1]) post_shape();   // PETG: glued to the switch board under the rocker's
                                                                     // solid middle (its top touches the rocker: the pivot)

module usb_plug() {                                          // TPU: seals the USB-C socket
  xo = plug_x;
  translate([0, 0, usb_zc]) {
    translate([Li/2 - usb_gap - 3, 0, 0]) rotate([0, 90, 0]) linear_extrude(3.01) rotate(90) rrect([8.2, 2.3], 1.1);
    translate([Li/2 - usb_gap, 0, 0]) rotate([0, 90, 0]) linear_extrude(xo - Li/2 + usb_gap) rotate(90) rrect(usb_hole - [0.3, 0.3], 2.35);
    translate([xo, 0, 0]) rotate([0, 90, 0]) linear_extrude(1.2) rotate(90) rrect([usb_hole[0] + 3, usb_hole[1] + 2.4], 3.5);
    translate([xo, 0, 0]) hull() for (dz = [0, usb_tab]) translate([0, 0, dz + usb_hole[1]/2 + 1.2]) rotate([0, 90, 0]) cylinder(d = 3, h = 1.2);
  }
}

// The neckband's parts and the switch board (for the views and the checks)
module board() {
  color("#1f6f3a") translate([pcb_x0, -nb_pcb[1]/2, z_pcb0]) cube(nb_pcb);
  color("#2a2a2a") translate([pcb_x0 + 2, -nb_pcb[1]/2 + 1, z_pcb1]) cube([nb_pcb[0] - 14, nb_pcb[1] - 2, nb_over]);
  color("#2a2a2a") translate([pcb_x0 + 3, -nb_pcb[1]/2 + 1.5, z_pcb0 - nb_under]) cube([nb_pcb[0] - 16, nb_pcb[1] - 3, nb_under]);
  color("#c8c8c8") translate([pcb_x1 + usb_out - 7.4, 0, usb_zc]) rotate([0, 90, 0]) linear_extrude(7.4) rotate(90) rrect(usb, usb[1]/2 - 0.01);
}
module battery() if (in_pod) color("#3d5f9e") translate([bat_x0, -batt[1]/2, fl]) cube(batt);
module switches(pressed = 0) {
  color("#c9a36b") translate([-sw_l/2, -(Wi - 0.6)/2, z_sw]) cube([sw_l, Wi - 0.6, 1.6]);
  for (p = SW) translate([p[0], p[1], z_sw1]) {
    color("#222") translate([-3, -3, 0]) cube([6, 6, tact_body]);
    color("#444") cylinder(d = 3.5, h = tact_h + pressed);
  }
}
module insides() { board(); battery(); switches(); color("#5a6068") rocker_post(); }

// ------------------------- CRADLES AND CONNECTORS (both units) -------------------------
// A unit's frame: x along it, y up, z out of the shell; its underside is the cylinder zs(x, R); its outline Lu x Wu.
// Its cradle's cables leave the ledge's bottom wall at shell level, facing down (the pod's straight in under the edge
// trim, the back box's into its short channel).
ch_wing = 4;                                                  // the back box's channel: thin flanges either side, for the tape
ch_taper = 8;                                                 // its lower end slopes down to the flanges
ch_in = 3;                                                    // it starts this far inside its cradle's bottom side (cut to its outline)
dt_w1 = dt_w + 2 * dt_d * tan(35);                            // the tongues' width at their tips
function dt_x(Lu) = Lu/2 - 9;                                 // the tongues: this far either side of the middle
dt_y0 = -(dt_s + 2*slide)/2 - 2;                              // segment 0 starts here (segment 1 at + 2 slide); windows at + slide
function y_mate(Wu) = -Wu/2 - 0.3;                            // the connectors' faces meet here (the male stands 0.3 proud)
function y_low(Wu, dc = mag_f) = y_mate(Wu) - dc - mag_tail - 1.2;   // the cradle's bottom side (the ledge's; dc: its connector's depth)
function y_top(Wu) = Wu/2 + 0.3 + arm_w + 0.8 + 1.4;          // its top side (above the latch)
function zsh(sh, x, y) = sh == 0 ? zb_at(x, y) : zb_bk(x, y);  // the shell under a cradle (0: the side, 1: the back), below its tape
module iface(R) translate([0, 0, -R]) rotate([90, 0, 0]) cylinder(r = R, h = 400, center = true, $fn = 360);   // below the units
module at_x(x, R) translate([x, 0, zs(x, R)]) rotate([0, asin(x/R), 0]) children();   // on the cylinder, square to it
module dt_2d(d = 0) offset(delta = d) polygon([[-dt_w/2, 0.8], [dt_w/2, 0.8], [dt_w/2, 0], [dt_w1/2, -dt_d], [-dt_w1/2, -dt_d], [-dt_w/2, 0]]);
module along_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();
module tongues(R, dx) for (sx = [-1, 1], k = [0, 1]) at_x(sx * dx, R)
  along_y(dt_y0 + 2*slide*k, dt_y0 + 2*slide*k + dt_s) dt_2d();
module grooves(R, dx) for (sx = [-1, 1]) at_x(sx * dx, R) {
  along_y(dt_y0 - 0.5, dt_y0 + 3*slide + dt_s + 0.5) dt_2d(rcl);       // the groove (open at the top, by dt_2d's root)
  for (k = [0, 1]) along_y(dt_y0 + 2*slide*k + slide - 0.3, dt_y0 + 2*slide*k + slide + dt_s + 0.3)   // the windows
    translate([-dt_w1/2 - rcl - 0.211, -dt_d - rcl]) square([dt_w1 + 2*rcl + 0.422, dt_d + rcl + 2]);   // (0.211: off the cylinder's facet corners)
}
// The pod has the males (spring pins) and its cradle the females; the back box the other way round (owner's safety:
// a battery box off its cradle shows only flat, recessed contacts, no sprung pins to short on a key). du / dc: the
// unit's and the cradle's connector depths.
module male_block(Wu, cx, du = mag_m) for (c = cx) translate([c - mag[0]/2, y_mate(Wu), pc_z]) cube([mag[0], du, mag[1]]);   // the unit's
module female_block(Wu, cx, dc = mag_f) for (c = cx) translate([c - mag[0]/2, y_mate(Wu) - dc, pc_z]) cube([mag[0], dc, mag[1]]);   // the cradle's
module male_holes(Wu, cx, du = mag_m) for (c = cx)           // through the bottom wall: the body, its tails behind
  translate([c - mag[0]/2 - 0.1, y_mate(Wu) - 1, pc_z - 0.1]) cube([mag[0] + 0.2, du + mag_tail + 1.3, mag[1] + 0.2]);
function ledge_x(cx) = [cx[0] - mag[0]/2 - 1.6, cx[len(cx) - 1] + mag[0]/2 + 1.6];
module cradle_2d(Lu, Wu, rcu, cx, dc = mag_f) hull() {
  translate([0, (y_top(Wu) - Wu/2 - 1.3)/2]) rrect([Lu, y_top(Wu) + Wu/2 + 1.3], min(rcu, 6));
  let(lx = ledge_x(cx)) translate([(lx[0] + lx[1])/2, (y_low(Wu, dc) - Wu/2)/2]) rrect([lx[1] - lx[0], -Wu/2 - y_low(Wu, dc)], 2);
}
// The cradle: Lu, Wu, rcu = the unit's outline; R its cylinder; cx its connectors; cxs, cds its cables' x and widths;
// sh its shell (0 side, 1 back); pressed: the tooth pushed down (for the checks of putting the unit on)
function z_cav(Wu, sh, dc = mag_f) = -cr_t + zsh(sh, 0, y_mate(Wu) - dc) + 0.8;   // the tails' cavity's floor (0.8 over the shell)
module cradle(Lu, Wu, rcu, R, cx, cxs, cds, sh, pressed = false, dc = mag_f) {
  lx = ledge_x(cx); ya = Wu/2 + 0.3; xt = latch_l/2;
  difference() {
    union() {
      intersection() { translate([0, 0, -40]) linear_extrude(40) cradle_2d(Lu, Wu, rcu, cx, dc); iface(R); }
      translate([lx[0], y_low(Wu, dc), -40]) cube([lx[1] - lx[0], y_mate(Wu) - y_low(Wu, dc), 40 + pc_z + mag[1]]);   // the ledge
    }
    if (sh == 0) shell_cut(-cr_t); else bb_shell(-cr_t);    // its underside on the tape
    grooves(R, dt_x(Lu));
    for (c = cx) translate([c - mag[0]/2 - 0.1, y_mate(Wu) - dc - 0.1, pc_z - 0.1]) cube([mag[0] + 0.2, dc + 1, 20]);   // the connectors
    translate([cx[0] - mag[0]/2 - 0.1, y_mate(Wu) - dc - mag_tail, z_cav(Wu, sh, dc)])   // their tails, potted (open on top)
      cube([cx[len(cx) - 1] - cx[0] + mag[0] + 0.2, mag_tail + 0.2, 30]);
    for (i = [0:len(cxs) - 1]) translate([cxs[i], y_mate(Wu) - dc - mag_tail + 0.5, z_cav(Wu, sh, dc) + cds[i]/2])
      rotate([90, 0, 0]) cylinder(d = cds[i], h = 4);       // the cables out of the bottom wall, facing down
    translate([0, 0, -40]) linear_extrude(45) difference() {   // the latch: a slot round the arm ...
      translate([-xt - 0.01, ya - 0.8]) square([2*xt + 0.8, arm_w + 1.6]);
      translate([-xt - 1, ya]) square([2*xt + 1, arm_w]);
    }
    translate([-xt + 2, ya - 0.8, -40]) cube([2*xt - 1.2, arm_w + 1.6, 40 + zs(xt, R) - arm_t]);   // ... room under it to bend
  }
  if (!pressed) hull() {                                      // the tooth: a square face against the unit, a ramp behind
    translate([xt - 4, ya, -0.5]) cube([4, 0.8, tooth + 0.5]);
    translate([xt - 4, ya + arm_w - 0.01, -0.5]) cube([4, 0.01, 0.5]);
  }
}
for (i = [0:len(cabs) - 2]) assert(cab_x[i + 1] - (cabs[i + 1] + 0.4)/2 - (cab_x[i] + (cabs[i] + 0.4)/2) >= 1.2, "the cables are too thick for the cradle's holes' spacing");
assert(cab_x[len(cabs) - 1] + (cabs[len(cabs) - 1] + 0.4)/2 + 0.5 <= pc_x[1] + mag[0]/2 && cab_x[0] - (cabs[0] + 0.4)/2 - 0.5 >= pc_x[0] - mag[0]/2, "the cables don't fit the cradle's ledge");
assert(dt_y0 + 3*slide + dt_s + 0.5 <= W/2 - 1.5 && dt_y0 - 0.5 >= -W/2 + 1.5, "the dovetails don't fit under the pod");
assert(-cr_t + zb_at(0, W/2 + 0.3) <= zs(latch_l/2, R_p) - arm_t - tooth - 0.3, "the cradle is too thin for its latch to bend");
assert(cr_t - dt_d - rcl >= 0.8, "the cradle is too thin under its grooves");
assert(run_b > ch_taper + 2, "the back box's channel is too short");
// (any channel: U = its grooves' positions across it, C = their widths)
module run_dome_2d(U, C) let(u0 = U[0] - C[0]/2 - 1.2, u1 = U[len(U) - 1] + C[len(C) - 1]/2 + 1.2, h = max(C) + 1.0) hull() {
  translate([u0, 0]) square([u1 - u0, 0.01]);
  for (u = [u0 + 2.5, u1 - 2.5]) translate([u, h - 2.5]) circle(2.5, $fn = 24);
}
module run_wing_2d(U, C) let(u0 = U[0] - C[0]/2 - 1.2, u1 = U[len(U) - 1] + C[len(C) - 1]/2 + 1.2)
  translate([u0 - ch_wing, 0]) square([u1 - u0 + 2*ch_wing, 0.8]);
module run_grooves_2d(U, C) for (i = [0:len(U) - 1]) hull() {
  translate([U[i] - C[i]/2, -0.01]) square([C[i], 0.01]);
  translate([U[i], C[i]/2]) circle(d = C[i], $fn = 24);
}
module run_2d(U, C) difference() { union() { run_dome_2d(U, C); run_wing_2d(U, C); } run_grooves_2d(U, C); }
M_A = [[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]];                         // (u, w, e) -> (e, u, w): along +x
// ------------------------- THE BACK BOX (batt_at = "back") -------------------------
// The neckband's battery in its own slim box on the back of the helmet. Box frame: x across the back (toward the
// rider's right), y up, z out of the shell. A PETG BASE holds the battery on foam, its connector (the male) in its
// bottom wall; a TPU COVER snaps over its walls (a bead into a groove round them) and presses its rim (the seal). The
// base sits on its own cradle (the same as the pod's), whose single cable (the battery's lead) runs down a short TPU
// channel to the shell's lower edge.
bb_gap = 0.6;                                                 // round the battery (foam)
bb_wall = 1.6;
bb_fl = 1.4;                                                  // the floor at its middle
bb_cov = 1.0;                                                 // the cover's skirt
bb_top_t = 1.2;                                               // ... and its top
bb_skirt = 2.2;                                               // how far the skirt reaches down the base's walls
bb_mag_in = mag_f - 0.3 + mag_tail - bb_wall + 0.3;           // its connector (a female: flat contacts) reaches this far in past its bottom wall
bb_in = [max(batt[0], mag[0] + 1) + 2*bb_gap, max(batt[1] + 2*bb_gap + bb_mag_in, 2*(dt_y0 + 3*slide + dt_s + 2) - 2*bb_wall)];   // (tall enough for the dovetails)
bb_out = [bb_in[0] + 2*bb_wall, bb_in[1] + 2*bb_wall];
bb_r = 4;                                                     // the base's corners in plan
bb_bat_y = -bb_in[1]/2 + bb_mag_in + bb_gap;                  // the battery's lower side (above the connector)
function zb_bk(x, y) = -(x*x/(2*shell_bk[0]) + y*y/(2*shell_bk[1]));
R_b = shell_bk[0] + vhb_t + cr_t;                             // its cylinder (across the back)
bb_low = zs(bb_out[0]/2 + 2, R_b) - 1;
bb_z1 = max(bb_fl + batt[2] + 0.6, pc_z + mag[1] + 0.3 + bb_skirt);   // the base's rim (the cover's top presses it; its skirt clears the ledge)
bb_top = bb_z1 + bb_top_t;
bb_bead = bb_z1 - 1.3;                                        // the cover's bead, in a groove round the walls
BB_L = bb_out[0] + 2*bb_cov;
BB_W = bb_out[1] + 2*bb_cov;
bb_cx = [0];                                                  // its connector, in the middle of its bottom wall
echo(str("BACK BOX: ", BB_L, " x ", BB_W, " mm, ", bb_top + cr_t, " mm above the tape at its middle (with its cradle)"));
assert(dt_y0 + 3*slide + dt_s + 0.5 <= bb_out[1]/2 - 1.5 && dt_y0 - 0.5 >= -bb_out[1]/2 + 1.5, "the dovetails don't fit under the back box");
assert(-cr_t + zb_bk(0, bb_out[1]/2 + 0.3) <= zs(latch_l/2, R_b) - arm_t - tooth - 0.3, "the back cradle is too thin for its latch to bend");
module bb_2d(d = 0) offset(r = -d) rrect(bb_out, bb_r);
module bb_shell(up = 0) translate([0, 0, up - shell_bk[1]]) scale([sqrt(shell_bk[0]*shell_bk[1]), shell_bk[1], shell_bk[1]]) sphere(1, $fn = 240);
module bb_base() union() {
  difference() {
    translate([0, 0, bb_low]) linear_extrude(bb_z1 - bb_low) bb_2d();
    translate([0, 0, bb_fl]) linear_extrude(bb_z1) rrect(bb_in, 0.8);   // the battery's room (small corners: the cell's are square)
    translate([0, 0, bb_bead - 0.45]) linear_extrude(0.9) difference() { bb_2d(-1); bb_2d(0.5); }   // the groove for the cover's bead
    iface(R_b);                                               // its underside: the cradle's cylinder
    male_holes(bb_out[1], bb_cx, mag_f);
  }
  tongues(R_b, dt_x(bb_out[0]));
}
module bb_cover() difference() {                              // TPU: snaps over the base
  hull() {
    translate([0, 0, bb_z1 - bb_skirt]) linear_extrude(0.01) bb_2d(-bb_cov);
    translate([0, 0, bb_top - 1]) linear_extrude(0.01) bb_2d(-bb_cov);
    translate([0, 0, bb_top - 0.01]) linear_extrude(0.01) bb_2d(-bb_cov + 1);   // its top edge rounded off
  }
  translate([0, 0, bb_z1 - bb_skirt - 1]) linear_extrude(bb_skirt + 1 - 0.2) bb_2d(0);   // over the walls (the top presses the rim 0.2: the seal)
}
module bb_bead() translate([0, 0, bb_bead - 0.4]) linear_extrude(0.8) difference() { bb_2d(-0.1); bb_2d(0.4); }   // the cover's bead (part of it)
module bb_cover_all() union() { bb_cover(); bb_bead(); }
module bb_cradle(pressed = false) cradle(bb_out[0], bb_out[1], bb_r, R_b, bb_cx, [0], [bat_cable + 0.4], 1, pressed, mag_m);   // (the male on the cradle)
// Its channel: one groove, straight down from the cradle's bottom side to the shell's lower edge (run_b).
bk_u = [0]; bk_c = [bat_cable + 0.4];
M_BK = [[1, 0, 0, 0], [0, 0, -1, y_low(bb_out[1], mag_m) + ch_in], [0, 1, 0, -cr_t + zb_bk(0, y_low(bb_out[1], mag_m))], [0, 0, 0, 1]];
module bb_channel() difference() {
  multmatrix(M_BK) intersection() {
    linear_extrude(ch_in + run_b) run_2d(bk_u, bk_c);
    hull() {
      translate([-20, -1, -1]) cube([40, max(bk_c) + 3, ch_in + run_b - ch_taper + 1]);
      translate([-20, -1, ch_in + run_b]) cube([40, 2.2, 0.01]);
    }
  }
  translate([0, 0, -20]) linear_extrude(40) offset(r = 0.3) cradle_2d(bb_out[0], bb_out[1], bb_r, bb_cx, mag_m);
}
module bb_battery() color("#3d5f9e") translate([-batt[0]/2, bb_bat_y, bb_fl + 0.3]) cube(batt);
module back_box(ex = 0) {                                     // the box (it comes off its cradle)
  color(C_POD) render() bb_base();
  color(C_TPU) translate([0, 0, 4*ex]) bb_cover_all();
  translate([0, 0, 2*ex]) bb_battery();
  color(C_MAG) male_block(bb_out[1], bb_cx, mag_f);     // (its connector: the female, flat contacts)
}
module back_dock(off = [0, 0, 0]) {                          // the box on its cradle (off: the box moved, e.g. lifted off)
  color(C_CRADLE) render() bb_cradle(); color(C_MAG) female_block(bb_out[1], bb_cx, mag_m);
  translate(off) back_box();
}

module half_x() render() intersection() { children(); translate([key_x[1], -60, -30]) cube([200, 120, 80]); }
C_POD = "#454a52"; C_TPU = "#1a1a1a"; C_HELMET = "#e9e9e6"; C_EPS = "#bdbdb5"; C_CRADLE = "#6b717a"; C_MAG = "#c9a640";
module pod_assembled(ex = 0) {
  color(C_POD) render() pod_body();
  color(C_TPU) translate([0, 0, 2.4*ex]) keypad();
  color(C_POD) translate([0, 0, 5*ex]) pod_lid();
  color(C_TPU) translate([1.5*ex, 0, 0]) usb_plug();
  color(C_MAG) male_block(W, pc_x);
}
module pod_cradle(pressed = false) cradle(L, W, rc, R_p, pc_x, cab_x, [for (c = cabs) c + 0.4], 0, pressed);
module pod_dock(off = [0, 0, 0]) {                           // the pod on its cradle (off: the pod moved)
  color(C_CRADLE) render() pod_cradle(); color(C_MAG) female_block(W, pc_x);   // (render(): the preview drew its cuts wrongly)
  translate(off) pod_assembled();
}

// ------------------------- SPEAKER PUCK, MIC, BOOM MOUNT -------------------------
module speaker_puck() difference() {                         // the speaker drops in from the front (printed front down)
  rotate_extrude($fn = 96) hull() {
    square([0.01, puck_t]);
    translate([puck_d/2 - 1.2, 1.2]) circle(1.2, $fn = 20);
    translate([puck_d/2 - 0.8, puck_t - 0.8]) circle(0.8, $fn = 20);
  }
  translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0] + 0.3, h = spk[1] + 1, $fn = 96);
  translate([0, 0, 1.2]) cylinder(d = max(spk[0] - 4, 8), h = puck_t, $fn = 96);     // behind the speaker: its tabs
  translate([0, 0, 1.2 + 0.75]) rotate([0, 90, 0]) cylinder(d = 2.4, h = puck_d);    // the wires out
  if (puck_d - spk[0] > 12)                                   // a small speaker: hollow the back round it (the rim and the hub take the Velcro)
    translate([0, 0, -0.01]) difference() {
      cylinder(d = puck_d - 3.2, h = puck_t - 1.2 + 0.01, $fn = 96);
      cylinder(d = spk[0] + 4, h = puck_t, $fn = 64);
    }
}

module mic_cup() difference() {                              // back on the bed: the boom in the back, the capsule in the front
  h = 3.5 + 1 + mic[1] + 0.3;
  hull() {
    translate([0, 0, 1]) cylinder(d = max(boom_d, mic[0]) + 3, h = h - 2);
    cylinder(d = max(boom_d, mic[0]) + 1, h = h);
  }
  translate([0, 0, -0.01]) cylinder(d = boom_d + 0.2, h = 3.5);
  cylinder(d = 2, h = h);
  translate([0, 0, h - mic[1] - 0.3]) cylinder(d = mic[0] + 0.15, h = mic[1] + 1);
}

bm_plate = [30, 34, 1.6];                                     // between the shell and the liner: x forward, y up
module boom_mount() difference() {
  union() {
    translate([-bm_plate[0]/2, -bm_plate[1]/2, 0]) linear_extrude(bm_plate[2]) rrect2([bm_plate[0], bm_plate[1]], 4);
    hull() {                                                  // the boom's socket, on the plate's inner side
      translate([bm_plate[0]/2 - 14, -6, 0]) cube([14, 12, 0.01]);
      translate([bm_plate[0]/2 - 12, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = boom_d + 4, h = 12);
    }
  }
  translate([bm_plate[0]/2 - 11, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = boom_d, h = 20);   // a tight push fit
  translate([bm_plate[0]/2 - 20, 0, bm_plate[2] + boom_d/2 + 1.5]) rotate([0, 90, 0]) cylinder(d = 3, h = 20);       // the mic cable comes in behind
}
module rrect2(s, r) translate([r, r]) offset(r) square([s[0] - 2*r, s[1] - 2*r]);

// ------------------------- THE STAND-IN HELMET (pictures only) -------------------------
H = [150, 125, 140];         // its shell's dome: semi-axes, x forward, y left, z up
CHIN = [[40, 0, -55], [110, 100, 62]];   // the chin bar's bulge: centre, semi-axes
function h_low(x) = -92 - 0.12 * x;      // its lower edge (lower at the chin)
pod_x = -52;                 // the pod's centre along the stand-in (behind the chin bar's pivot); its height follows the edge
pivot = [28, -22];
function unit(v) = v / norm(v);
function on_shell(x, z, a = H) = [x, a[1] * sqrt(1 - pow(x/a[0], 2) - pow(z/a[2], 2)), z];
function normal_at(p, a = H) = unit([p[0]/(a[0]*a[0]), p[1]/(a[1]*a[1]), p[2]/(a[2]*a[2])]);
function frame(p, n, fwd) = let(xa = unit(fwd - (fwd * n) * n), ya = cross(n, xa))
  [[xa[0], ya[0], n[0], p[0]], [xa[1], ya[1], n[1], p[1]], [xa[2], ya[2], n[2], p[2]], [0, 0, 0, 1]];
// The pod along the lower edge (its x parallel to the edge, which rises toward the back), its cradle's bottom side
// pod_edge above it. (The frame's origin is on the cradle's top: the tape and the cradle under it.)
function pod_m(z) = let(p = on_shell(pod_x, z), n = normal_at(p)) frame(p + (vhb_t + cr_t) * n, n, [-1, 0, 0.12]);
function pod_low(z) = (pod_m(z) * [0, y_low(W), 0, 1])[2] - h_low((pod_m(z) * [0, y_low(W), 0, 1])[0]);
pod_zs = [for (z = [-85:0.25:-20]) if (pod_low(z) >= pod_edge) z];
POD_M = pod_m(min(pod_zs));                                   // pod x toward the helmet's back

EPS_t = 25; SH_t = 4;
EAR = [0, 0, -22];
EAR_P = on_shell(EAR[0], EAR[2], H - [SH_t + EPS_t, SH_t + EPS_t, SH_t + EPS_t]);
BM_P = on_shell(18, -78, H - [SH_t, SH_t, SH_t]);              // the boom mount, inside the shell's lower left edge
BM_M = frame(BM_P, -normal_at(BM_P, H - [SH_t, SH_t, SH_t]), [1, 0, 0]);
MIC_P = [104, 14, -76];                                       // in front of the mouth, inside the chin bar

module ellipsoid(a) scale(a) sphere(1, $fn = 160);
function on_back(y, z, a = H) = [-a[0] * sqrt(1 - pow(y/a[1], 2) - pow(z/a[2], 2)), y, z];
BK_P = on_back(0, bk_at);
BK_N = normal_at(BK_P);
BK_M = frame(BK_P + (vhb_t + cr_t) * BK_N, BK_N, [0, -1, 0]);         // box x toward the rider's right, y up
// The back box's channel on the stand-in: its centre line (box frame), each point pushed out radially onto the shell.
function to_shell(p, M = POD_M) = let(q = M * [p[0], p[1], 0, 1], k = sqrt(pow(q[0]/H[0], 2) + pow(q[1]/H[1], 2) + pow(q[2]/H[2], 2)))
  [q[0], q[1], q[2]] / k;
BK_ALL = [for (d = [-2:5:150]) to_shell([0, y_low(bb_out[1], mag_m) - d], BK_M)];
BK_CP = [for (q = BK_ALL) if (q[2] > h_low(q[0]) + 1.5) q];
module bk_slab(i, part) let(t = BK_CP[min(i + 1, len(BK_CP) - 1)] - BK_CP[max(i - 1, 0)])
  multmatrix(frame(BK_CP[i], normal_at(BK_CP[i]), t)) multmatrix(M_A) linear_extrude(0.01, center = true)
    if (part == 0) run_dome_2d(bk_u, bk_c); else run_wing_2d(bk_u, bk_c);
module bk_channel_on_helmet() color(C_TPU) for (i = [0:len(BK_CP) - 2], part = [0, 1]) hull() { bk_slab(i, part); bk_slab(i + 1, part); }
module back_on_helmet(off = [0, 0, 0]) if (!in_pod) { multmatrix(BK_M) back_dock(off); bk_channel_on_helmet(); }
module helmet_solid(t = 0) hull() {
  ellipsoid(H - [t, t, t]);
  translate(CHIN[0]) ellipsoid(CHIN[1] - [t, t, t]);
}
module helmet_shell(cutaway = false) color(C_HELMET) difference() {
  helmet_solid();
  helmet_solid(SH_t);
  translate([0, 0, h_low(0)]) rotate([0, -atan(0.12), 0]) translate([-400, -400, -800]) cube(800);
  translate([60, 0, -8]) rotate([0, 90, 0]) linear_extrude(200) scale([1, 1.25]) rrect([56, 120], 22);   // eye port
  if (cutaway) translate([-300, -300, -300]) cube([600, 300, 600]);   // (not too big: a camera inside it breaks the preview)
}
module helmet_details() {
  color("#2b3440", 0.85) intersection() {                     // visor
    difference() { ellipsoid(H + [2, 2, 2]); ellipsoid(H - [2, 2, 2]); }
    translate([60, 0, -8]) rotate([0, 90, 0]) linear_extrude(200) scale([1, 1.25]) rrect([62, 126], 25);
  }
  for (s = [-1, 1]) let(p = on_shell(pivot[0], pivot[1]), n = normal_at(p))   // the chin bar's pivots
    color("#9a9a9a") multmatrix(frame(p, s > 0 ? n : [n[0], -n[1], n[2]], [1, 0, 0]))
      translate([0, 0, -1]) cylinder(d = 30, h = 4, $fn = 48);
}
module liner(cutaway = false) color(C_EPS) difference() {
  ellipsoid(H - [SH_t, SH_t, SH_t] - [0.5, 0.5, 0.5]);
  ellipsoid(H - [SH_t + EPS_t, SH_t + EPS_t, SH_t + EPS_t]);
  translate([-300, -300, -60 - 600]) cube(600);
  translate([40, -300, -300]) cube(600);
  if (cutaway) translate([-300, -300, -300]) cube([600, 300, 600]);   // (not too big: a camera inside it breaks the preview)
  for (s = [-1, 1]) ear_pocket_at(s);
}
module ear_pocket_at(s) let(p = [EAR_P[0], s * EAR_P[1], EAR_P[2]])
  translate(p) rotate([-s * 90, 0, 0]) translate([0, 0, -1]) cylinder(d = ear_pocket[0], h = ear_pocket[1] + 1, $fn = 64);
module speakers(both = true) for (s = both ? [-1, 1] : [1]) let(p = [EAR_P[0], s * EAR_P[1], EAR_P[2]])
  translate(p) rotate([s * 90, 0, 0]) translate([0, 0, -puck_t]) {
    color("#30343a") speaker_puck();
    color("#8a8f96") translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0], h = spk[1] - 0.3, $fn = 64);
  }
BOOM0 = BM_M * [bm_plate[0]/2, 0, bm_plate[2] + boom_d/2 + 1.5, 1];
BOOM = [[BOOM0[0], BOOM0[1], BOOM0[2]], [BOOM0[0] + 30, BOOM0[1] - 6, BOOM0[2] + 1], [72, 64, -79], [94, 32, -76], MIC_P];
module boom_mic() {
  color("#30343a") multmatrix(BM_M) boom_mount();
  color("#222") for (i = [0:len(BOOM) - 2]) hull() { translate(BOOM[i]) sphere(d = boom_d, $fn = 16); translate(BOOM[i+1]) sphere(d = boom_d, $fn = 16); }
  let(d = unit(MIC_P - BOOM[len(BOOM) - 2]))
    translate(MIC_P) rotate([0, 0, atan2(d[1], d[0])]) rotate([0, 90 - asin(d[2]), 0]) {
      color("#30343a") translate([0, 0, -2]) mic_cup();
      color("#555") translate([0, 0, 6]) sphere(d = 13, $fn = 24);       // foam windscreen
    }
}

// ------------------------- OUTPUT -------------------------
if (PART == "assembly") { helmet_shell(); helmet_details(); multmatrix(POD_M) pod_dock(); back_on_helmet(); }
else if (PART == "detached") { helmet_shell(); helmet_details(); multmatrix(POD_M) pod_dock([0, 30, 24]); back_on_helmet([0, 30, 18]); }   // view: both units off their cradles
else if (PART == "dock_view") { pod_dock([0, slide, 16]); }        // view: the pod lifted off its cradle (at its drop-in place)
else if (PART == "cradle_view") { color(C_CRADLE) render() pod_cradle(); color(C_MAG) female_block(W, pc_x); }   // view: the pod's cradle alone
else if (PART == "back_view") { back_dock([0, slide, 12]); color(C_TPU) translate([0, -12, 0]) render() bb_channel(); }   // view: the back box lifted off its cradle, the channel pulled away
else if (PART == "back_exploded") back_box(3);
else if (PART == "bb_base") translate([0, 0, bb_z1]) rotate([180, 0, 0]) bb_base();                  // its rim down
else if (PART == "bb_cradle") translate([0, 0, -zs(bb_out[0]/2, R_b)]) bb_cradle();                    // top up (supports under it)
else if (PART == "pod_cradle") translate([0, 0, -zs(L/2, R_p)]) pod_cradle();                          // top up (supports under it)
else if (PART == "bb_cover") translate([0, 0, bb_top]) rotate([180, 0, 0]) bb_cover_all();             // TPU, its top down
else if (PART == "bb_channel") bb_channel();                                                            // TPU, flanges down
else if (PART == "check_bb_fit") intersection() { bb_battery(); union() { bb_base(); bb_cover_all(); } }   // empty
else if (PART == "check_bb_snap") intersection() { bb_cover_all(); bb_base(); }                         // must collide: the bead's snap and the rim's squeeze
else if (PART == "check_bb_shell") intersection() { bb_cradle(); bb_shell(-cr_t - vhb_t); }             // empty: the tape's room
else if (PART == "check_bb_dock") intersection() { bb_base(); bb_cradle(); }                            // touch only: on its cradle
else if (PART == "check_bb_mate") intersection() { male_block(bb_out[1], bb_cx, mag_f); female_block(bb_out[1], bb_cx, mag_m); }   // touch only: the faces meet
else if (PART == "check_bb_conn") intersection() { union() { male_block(bb_out[1], bb_cx, mag_f); bb_battery(); } union() { bb_base(); bb_cover_all(); } }   // empty
else if (PART == "check_bb_female") intersection() { female_block(bb_out[1], bb_cx, mag_m); bb_cradle(); }     // empty
else if (PART == "check_bb_hold") intersection() { translate([0, 0, 0.5]) bb_base(); bb_cradle(); }     // must collide: the dovetails hold it on
else if (PART == "check_bb_latch") intersection() { translate([0, 0.5, 0]) bb_base(); bb_cradle(); }   // must collide: the tooth stops it sliding up
else if (PART == "check_bb_drop") intersection() { translate([0, slide, 0]) bb_base(); bb_cradle(true); }   // touch only: it drops in
else if (PART == "check_bb_slide") intersection() { translate([0, slide/2, 0]) bb_base(); bb_cradle(true); }   // touch only: it slides home
else if (PART == "check_bb_cover") intersection() { bb_cover_all(); bb_cradle(); }                      // empty
else if (PART == "channel_part") color("#5a6068") rotate([0, 180, 0]) render() bb_channel();   // view: the channel turned over, its grooves up
else if (PART == "pod") pod_assembled();
else if (PART == "rocker_section") {                                                 // view: cut through the volume rocker
  color(C_POD) half_x() pod_body(); color(C_TPU) half_x() keypad(); color(C_POD) half_x() pod_lid();
  color("#c9a36b") half_x() translate([-sw_l/2, -(Wi - 0.6)/2, z_sw]) cube([sw_l, Wi - 0.6, 1.6]);
  color("#222") half_x() for (p = SW) translate([p[0] - 3, p[1] - 3, z_sw1]) cube([6, 6, tact_body]);
  color("#999") half_x() for (p = SW) translate([p[0], p[1], z_sw1]) cylinder(d = 3.5, h = tact_h);
  color("#5a8fd0") half_x() rocker_post(); color("#1f6f3a") half_x() board(); color("#3d5f9e") half_x() battery();
}
else if (PART == "pod_cables") pod_dock();   // view: the pod on its cradle from below: the cables out of the ledge
else if (PART == "exploded") { pod_assembled(5); translate([0, 0, 6]) insides(); }
else if (PART == "inside") { helmet_shell(true); liner(true); speakers(false); boom_mic(); multmatrix(POD_M) pod_dock(); back_on_helmet(); }
else if (PART == "headset_assembled") { pod_body(); translate([0, 0, -0.02]) keypad(); pod_lid(); usb_plug(); }   // view only (merged)
else if (PART == "small_parts") {                                                     // view: the parts inside the helmet
  color("#30343a") speaker_puck();
  color("#8a8f96") translate([0, 0, puck_t - spk[1]]) cylinder(d = spk[0], h = spk[1] - 0.3, $fn = 64);
  color("#30343a") translate([45, 0, 0]) boom_mount();
  color("#30343a") translate([45, 30, 0]) mic_cup();
}
else if (PART == "pod_body") rotate([180, 0, 0]) translate([0, 0, -z_seam]) pod_body();     // open side down
else if (PART == "pod_lid") translate([0, 0, -z_lid0]) pod_lid();
else if (PART == "keypad") translate([0, 0, -z_seam]) keypad();
else if (PART == "rocker_post") post_shape();
else if (PART == "usb_plug") rotate([0, -90, 0]) translate([-plug_x - 1.2, 0, -usb_zc]) usb_plug();                        // flange down
else if (PART == "speaker_puck") translate([0, 0, puck_t]) rotate([180, 0, 0]) speaker_puck();   // front down
else if (PART == "mic_cup") mic_cup();
else if (PART == "boom_mount") boom_mount();
// checks
else if (PART == "check_insides") intersection() { insides(); union() { pod_body(); pod_lid(); keypad(); } }   // touch only (the switch board on its ledges)
else if (PART == "check_parts") intersection() { pod_body(); pod_lid(); }                    // empty
else if (PART == "check_plug") intersection() { usb_plug(); pod_body(); }                  // empty
else if (PART == "check_squeeze") intersection() { keypad(); pod_lid(); }                   // must collide: the seal
else if (PART == "check_press") intersection() { switches(0.5); keypad(); }                 // must collide: a press reaches the switch
else if (PART == "check_pivot") intersection() { translate([0, 0, 0.05]) rocker_post(); keypad(); }   // must collide: the post touches the rocker
else if (PART == "check_rest") intersection() { switches(0); keypad(); }                    // empty: the switches aren't held down
else if (PART == "check_shell") intersection() { pod_cradle(); shell_cut(-cr_t - vhb_t); }   // empty: the tape's room
else if (PART == "check_dock") intersection() { pod_body(); pod_cradle(); }                 // touch only: on its cradle
else if (PART == "check_mate") intersection() { male_block(W, pc_x); female_block(W, pc_x); }   // touch only: the faces meet
else if (PART == "check_conn") intersection() { male_block(W, pc_x); union() { pod_body(); insides(); usb_plug(); } }   // empty
else if (PART == "check_female") intersection() { female_block(W, pc_x); pod_cradle(); }   // empty
else if (PART == "check_hold") intersection() { translate([0, 0, 0.5]) pod_body(); pod_cradle(); }   // must collide: the dovetails hold it on
else if (PART == "check_latch") intersection() { translate([0, 0.5, 0]) pod_body(); pod_cradle(); }   // must collide: the tooth stops it sliding up
else if (PART == "check_drop") intersection() { translate([0, slide, 0]) union() { pod_body(); usb_plug(); } pod_cradle(true); }   // touch only: it drops in
else if (PART == "check_slide") intersection() { translate([0, slide/2, 0]) union() { pod_body(); usb_plug(); } pod_cradle(true); }   // touch only: it slides home
else if (PART == "check_plug_dock") intersection() { usb_plug(); pod_cradle(); }           // empty
else if (PART == "check_cables") intersection() {                                          // empty: the cables pass the cradle's holes
  for (i = [0:len(cabs) - 1]) translate([cab_x[i], y_mate(W) - mag_f - mag_tail + 0.3, z_cav(W, 0) + cabs[i]/2 + 0.2]) rotate([90, 0, 0]) cylinder(d = cabs[i], h = 4);
  pod_cradle();
}
else if (PART == "none") { }

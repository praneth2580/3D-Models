/*
  HANDLEBAR DASH v1: the display head (a round gauge with its tell-tales in the face) and its handlebar mount.
  OpenSCAD 2021.01. PART selects what to show or export (list below). The interface box comes next.

  Built around these parts (see COMPONENTS.md; buy exactly these, or the parts won't fit):
    - Waveshare ESP32-S3 2.8" round display board (ESP32-S3-Touch-LCD-2.8C or ESP32-S3-LCD-2.8C). Its sizes here are
      from Waveshare's published outline drawing and its official 3D model (STEP, 2024-12-26): cover glass 95.86 mm
      across and 1.26 mm thick, visible screen 70.13 mm across, 4 M2 brass standoffs (4 mm across) whose ends are
      9.71 mm behind the glass front, total thickness 9.73 mm.
    - u-blox NEO-M8N GPS, with an 18 x 18 mm active patch antenna on an IPEX lead (at the top, inside the housing).
    - 8 x WS2812B 5050 addressable RGB LEDs on 10 mm round boards ("with heatsink", 10 x 3 mm): the tell-tales.
    - SN65HVD230 CAN transceiver board (dash bus), GX12 4-pin panel socket (the cable to the interface box).

  How it goes together (front = the screen side, facing the rider):
    1. SHELL: a round tube with a face ring in front. The glass sits behind the face ring on a foam ring (0.8 mm).
    2. CARRIER: a cup. The display screws onto its front with 4 x M2 x 6 into the display's own standoffs; the GPS
       module and the CAN board go on its back. The display and the carrier slide into the shell from the back;
       a key on the carrier fits a groove in the shell, so the screen can't be fitted rotated.
    3. COVER: a plug that closes the back. Its front edge presses the carrier forward, so the glass seats on the foam
       ring. 4 x M3 x 10 pan-head screws through the shoulder into heat-set inserts in the cover hold it all.
    TELL-TALES (owner: "options to show status indicators like high beam, abs"; "look like they are part of the model
       too, not an extra addon ... look are a great deal important"; then, 2026-11-24: "the display should be below
       with the logos stacked above it ... so overall bezel is reduced", and "the display should be in the centre of
       the model"): the screen is in the centre, and the face ring lies ON the display's own black glass border (12.9 mm
       wide), so the tell-tales and the LOGO sit on top of that border, not beside it: the housing adds only its wall.
       The logo is at the top, the tell-tales round the top either side of it, as in the gauge faces of the Indian
       Scout, KOSO and Daytona. Each icon is cut through the face's 0.8 mm skin into its own light chamber, with a 10 mm
       round WS2812B LED board in a pocket behind it, lying on the glass's border (one data line; the wires run in a
       channel in the face's back and leave past the glass's edge at wire_a). Fill the icons flush with translucent
       white UV resin. The logo: logo_text, or your own SVG/DXF (logo_file). icons: which and in what order;
       with telltales set to "none", no lamps (a thinner face ring).
    4. MOUNT (mount): "bar", 2 slim bar clamps bolted straight to the cover on rubber, hidden behind the gauge (the default); "cluster", an adapter
       bolted where the stock instrument cluster was; or "stalk", a GoPro-style 3-prong joint on the cover: it fits the printed bar clamp here, or any GoPro handlebar
       mount. One M5 bolt sets the tilt.

  Frame: the head's axis is z, pointing from the screen into the housing (backwards). Origin: the centre of the face
  ring's back face (where the foam ring sits). y is up; x is to the right as seen from BEHIND (to the left as seen from
  the front), as in Waveshare's 3D model and back-view drawing.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly" (head on its clamp), "exploded", "front", "head_shell", "head_carrier", "head_cover",
// "icons" (2D, the tell-tale icons),
// "lip_gasket" (TPU, or cut it from 0.8 mm foam), "bar_mount_right", "bar_mount_left", "cradle_cap", "mount_pad",
// "cluster_adapter", "clamp_upper", "clamp_lower",
// "display_dummy" (view only);
// checks "check_*" (see the end of the file).
PART = "assembly";
SHOW_DISPLAY = true;         // the display board, in the assembly pictures
telltales = "face";         // SELECT: "face" (LED tell-tales in the gauge's face) or "none" (a plain face: on the screen only)

// ------------------------- THE DISPLAY BOARD (published dimensions) ----
glass_d = 95.86;            // cover glass (Waveshare drawing: 95.86 +/- 0.15)
glass_t = 1.26;             // (3D model)
active_d = 70.13;           // visible screen (drawing)
disp_t = 9.73;              // glass front to the tallest part on the back (3D model)
standoff_z = 9.71;          // glass front to the ends of the 4 M2 standoffs (3D model)
standoff_d = 4.0;
standoffs = [[-18.0, -25.56], [18.0, -25.56], [-29.5, 15.14], [29.5, 15.14]];   // from the glass centre
pcb = [66.0, 65.37, 1.6];   // board: width, height, thickness (3D model)
pcb_y = [-29.86, 35.51];    // board's bottom and top edge, from the glass centre
pcb_z = 4.11;               // glass front to the board's front face
panel_d = 73.0;             // LCD panel behind the glass (3D model: 73.0 wide)
panel_y = 1.87;             // its centre, above the glass centre
panel_z = [1.36, 6.21];
fpc = [32, 9.0, 7.6];       // the panel's flat cable at the bottom: width, height below the panel, depth (envelope)
usb_xy = [-23.4, -20.7];    // native USB-C port (bottom left, seen from behind), its centre; it faces outward at 45 deg

// ------------------------- HEAD SETTINGS ------------------------------
fit = 0.3;                  // radial clearance around the glass
wall_t = 3.0;               // shell wall
gasket_t = 0.8;             // foam ring under the face ring, on the glass's black border (closed-cell, self-adhesive)
gasket_squeeze = 0.2;       // how much the cover squeezes it
carrier_t = 2.5;            // the carrier's front plate
carrier_skirt = 1.6;        // its tube wall
bay = 14;                   // room behind the carrier for the GPS module, the CAN board and the wires
cover_plug = 8;             // how far the cover plugs into the shell
cover_back = 3.0;           // the cover's back plate
key_w = 6;                  // the anti-rotation key and its groove
key_a = 315;                // its angle (degrees from +x): low on one side, clear of the wire notches
key_d = 1.2;
screw_ang = [60, 120, 240, 300];   // the 4 radial cover screws (degrees from +x)
insert_d = 4.2;             // M3 heat-set inserts in the cover's ring (SELECT: check your inserts)
insert_l = 5.7;
csk_d = 6.0;                // M3 countersunk head
cover_ring = 7;             // the cover plug's ring (radial width): carries the inserts
face_skin = 0.8;            // the face's front skin: the icons go through it
icons = ["left", "beam", "neutral", "abs", "engine", "fuel", "battery", "right"];   // rider's left to right, round the top
                            //   (with a logo: the first half on its left, the rest on its right)
icon_size = 5.5;            // icon height, mm (up to 6: it must fit its light chamber)
led_board_d = 10.0;         // MEASURE: the tell-tale LED boards (WS2812B 5050 on a 10 mm round board): diameter
led_board_t = 3.0;          // MEASURE: and thickness, LED included
light_gap = 0.6;            // between the LED's face and the skin (spreads the light over the icon)
wire_gap = 0.8;             // behind the LED boards, for the solder joints and wires
wire_a = 75;                // the LEDs' 3 wires leave the face here, past the glass's edge (degrees from +x; clear of the GPS antenna)
logo_text = "DASH";         // the logo at the top of the face, engraved: your own word ("" = none)
logo_file = "";             // or your own logo as an SVG or DXF file (it takes the place of the text), scaled to logo_size high.
                            //   Your own artwork goes in private/ (never committed or published), for example private/my_logo.svg
logo_size = 4.5;            // logo height, mm (the word or your file is scaled to it)
logo_w = 24;                // the room for the logo's width, mm: the gap between the tell-tales either side of it
logo_depth = 0.5;           // engraved this deep (fill it with paint, or leave it)
back_logo_text = "";        // a logo on the back cover (seen from in front of the bike): a word ("" = none)
back_logo_file = "";        // or your own SVG/DXF (in private/, like logo_file)
back_logo_size = [44, 0];   // its size, mm [width, height]: 0 = in proportion. It must fit the free area (asserted)
back_logo_y = 12;           // its centre, above the cover's centre: high, so the bike's handlebar clamp doesn't hide it (GX12 socket above)
back_logo_depth = 0.6;      // engraved this deep into the 3 mm back plate
round_r = 1.6;              // the face's outer edge rounded (not equal to the trim's width: tangent faces break the mesh)
trim = true;                // SELECT: a separate trim ring around the face's edge (print it in silver or a contrast colour)
trim_wh = [2.0, 1.4];       // its width and height (a rebate in the face's edge takes it)
gps_patch = [18.5, 18.5, 6.5];   // the GPS antenna: an 18 x 18 mm active patch (ceramic + its LNA board), at the top inside (SELECT: check yours)
gx12_d = 12.2;              // GX12 panel socket hole (12 mm thread)

// ------------------------- MOUNT ----------------------------------------
// "cluster" (owner, 2026-11-24: "could the mounting behind the gauge", then chose the stock cluster's mount): the dash
// replaces the stock instrument cluster, so it bolts where the cluster was, with nothing showing round the gauge. A
// printed adapter: its foot bolts to the stock cluster bracket's holes (through the bracket's own rubber grommets, M6
// bolts from below into nuts captive in the foot), its pad to the cover's 2 M4 inserts (the same as the cradle's).
// Fit the adapter to the gauge on the bench, then bolt it on from below. There are NO PUBLISHED SIZES for the bike's
// bracket (Royal Enfield part 1100515/B on the Meteor 350): the stock_* and cl_* values are placeholders. Measure yours.
// "bar" (the default): on the handlebar (owner: "on the handlebar not above it, something like the harleys", then,
// 2026-11-24: "it should be on the handlebar and should not be visible outside the dash", then "remove the arms ...
// connect the mount directly to the dash, have some rubber for damping only"): 2 slim bar clamps right against the
// bike's own handlebar clamp, each with a short block back to a foot that bolts straight to the cover (2 M4 into
// inserts), a rubber pad between foot and cover, a rubber strip in the clamp. Nothing joins the two sides. The
// gauge is placed (head_back, head_up: worked out, not set) where it hides the whole cradle from the rider's eye
// (rider_eye): the smallest setback that does, the gauge's centre on the line from the eye to the clamps. That works
// only if the bike's clamp is narrow enough (about 80 mm or less); an assert says so. Turning the cradle on the bar
// before tightening sets the tilt.
// "stalk": a GoPro-style joint on a clamp above the bar (or any GoPro handlebar mount).
mount = "bar";              // SELECT: "bar" (on the handlebar, hidden behind the gauge), "cluster" (on the stock cluster's bracket) or "stalk"
stock_holes = [[-20, 0], [20, 0]];   // MEASURE: the stock bracket's holes for the cluster, from their centre: [x along the bar, y forward]
stock_bolt = 6.5;           // MEASURE: their bolt holes in the adapter (M6: 6.5)
stock_nut = 10;             // the captive nuts across the flats (M6: 10)
stock_tilt = 0;             // MEASURE: the bracket's top face, rising toward the front of the bike by this (degrees)
stock_plate = [70, 30, 3];  // MEASURE: the bracket's flat round the holes (for the pictures and the fit check)
cl_x = 0;                   // the gauge's centre, sideways from the holes' centre (+ = toward the rider's right)
cl_back = 20;               // MEASURE: the gauge's back face, this far behind the holes' centre (toward the rider)
cl_up = 62;                 // MEASURE: the gauge's centre, this far above the bracket's top face
adapter_t = 5;              // the adapter's pad (on the cover)
cl_foot_t = 8;              // and its foot (on the bracket)
bike_clamp_w = 80;          // MEASURE: your bike's own handlebar clamp: its width along the bar. The cradle's clamps sit right
                            //   beside it, so this decides whether the gauge can hide them (about 80 or less). The Meteor 350's
                            //   is a one-piece die-cast clamp on 2 risers, with no published size: 80 is a placeholder
bike_clamp_d = 45;          // MEASURE: its depth (front to back)
bike_clamp_h = 28;          // MEASURE: its top, above the bar's centre
bike_clamp = [bike_clamp_w, bike_clamp_d, bike_clamp_h];
cradle_clamp_w = 10;        // the 2 slim bar clamps (each bolted straight to the cover)
clamp_gap = 1;              // between them and the bike's clamp
mount_t = 4;                // their wall round the bar (with its rubber strip)
mount_rubber = 2;           // a rubber pad between each clamp's foot and the cover (damping); a rubber washer under each bolt
foot_t = 8;                 // each clamp's foot, on the cover (2 M4 inserts in it, 6 mm long)
bar_bolts = [[34, -8], [34, -20]];   // each foot's 2 M4 x 14 bolts, from inside the cover into inserts in the foot: head-frame [x (mirrored per side), y]
rider_eye = [650, 450];     // the rider's eye, behind and above the bar's centre (an estimate: it only places the gauge)
cradle_bolt = [18, -30];    // the cradle's 2 M4 bolts on the cover's back: +-x, y (below the head's centre)
m4_insert_d = 5.6;          // M4 heat-set inserts (SELECT: check yours)
m4_insert_l = 8;

// ------------------------- BAR CLAMPS ----------------------------------
bar_d = 22.2;               // MEASURE: handlebar diameter at the clamp: 22.2 (7/8"), 25.4 (1") or 28.6 (1-1/8")
clamp_w = 24;               // clamp width along the bar
clamp_t = 5;                // clamp wall around the bar
clamp_rubber = 1.0;         // rubber strip inside the clamp
clamp_bolt = 4.5;           // 2 x M4 clamp bolts (holes)
clamp_nut = 7.0;            // M4 nut across the flats
riser = 30;                 // MEASURE: height of the joint above the bar's centre (clear the bike's own bar clamp)
tilt = 25;                  // MEASURE: screen tilt back from vertical, for the pictures (set on the bike with the joint)
gp_finger_t = 3.0;          // GoPro-style joint (PROVISIONAL: check against a GoPro mount): finger thickness,
gp_gap = 3.2;               //   gap between fingers,
gp_r = 7.5;                 //   finger end radius,
gp_hole = 5.3;              //   bolt hole (M5)
gp_reach = 16;              //   joint centre behind the cover's back face
gp_drop = 30;               // the joint sits this far below the head's centre, so the head sits above the clamp

// ------------------------- DERIVED --------------------------------------
$fn = 120;
bore_r = glass_d/2 + fit;
shell_r = bore_r + wall_t;                           // the shell, all the way back (the cover's back plate too)
face_r = shell_r;                                    // the face: concentric with the screen
with_icons = telltales == "face" && len(icons) > 0;
with_logo = logo_text != "" || logo_file != "";
// The face ring lies on the glass's black border (active_d/2 to glass_d/2): the window, then the icons' circle.
win_r = active_d/2 + 0.35;                           // the screen's window
icon_r = (win_r + glass_d/2)/2;                      // the icons' and the logo's centre line: the middle of the black border
pocket_d = led_board_d + 0.4;                       // each LED board's pocket
light_d = pocket_d - 1.6;                            // its light chamber, in front (the board rests on the step)
lip_t = with_icons ? face_skin + light_gap + led_board_t + wire_gap : 2.4;   // the face ring's thickness, in front of the glass
z_led = -(wire_gap + led_board_t);                  // the LED boards' front (the step)
logo_y = icon_r;
trim_in = trim ? trim_wh[0] + 0.3 : 0.6;             // keep clear of the face's edge (or the trim ring) by this
glass_z = gasket_t - gasket_squeeze;                 // the glass's front face, squeezed onto the foam
z_carrier = glass_z + standoff_z;                    // the carrier's front face = the standoffs' ends
z_cov = z_carrier + carrier_t + bay;                 // the cover's front edge = the carrier skirt's back end
shell_len = z_cov + cover_plug;                      // shell, from the face ring's back face to its back rim
z_screw = z_cov + cover_plug/2;                      // the radial screws' plane
head_len = lip_t + shell_len + cover_back;           // overall depth (face to cover back)
// The GPS antenna: lying flat at the top inside, behind the carrier, facing up through the shell's top wall.
gps_y1 = sqrt(pow(bore_r - 0.4, 2) - pow(gps_patch[0]/2, 2));
gps_y0 = gps_y1 - gps_patch[2];
gps_z0 = z_carrier + carrier_t + 0.3;
gps_z1 = gps_z0 + gps_patch[1];
gp_fingers3 = [-(gp_finger_t + gp_gap), 0, gp_finger_t + gp_gap];   // pod side: 3 fingers
gp_fingers2 = [-(gp_finger_t + gp_gap)/2, (gp_finger_t + gp_gap)/2]; // clamp side: 2 fingers

// ------------------------- CHECKS ------------------------------------
assert(win_r > active_d/2 && win_r < glass_d/2 - 8, "The face's window must clear the screen and sit on the glass's border.");
assert(insert_l + 0.8 <= cover_ring, "Insert too long for the cover's ring.");
assert(gp_gap >= gp_finger_t + 0.15, "GoPro fingers won't mesh.");
assert(z_screw - csk_d/2 > z_cov + 0.5 && z_screw + csk_d/2 < shell_len - 0.5, "Cover screws too close to the shell's rim.");
assert(glass_d/2 > active_d/2, "glass smaller than the screen?");
assert(gp_drop + gp_r + 3 <= shell_r, "The joint must stay on the cover.");
assert(!with_icons || (icon_r - pocket_d/2 >= win_r + 0.8 && icon_r + pocket_d/2 <= glass_d/2 - 0.3),
       "The LED boards don't fit on the glass's black border: smaller boards (led_board_d).");
assert(!with_icons || icon_size*5.2/8 <= light_d/2 - 0.2, str("The icons are too big for their light chambers: icon_size up to ", floor((light_d/2 - 0.2)*8/5.2*10)/10, "."));
assert(!with_logo || (icon_r - logo_size/2 >= win_r + 2 && norm([logo_w/2, icon_r + logo_size/2]) <= face_r - trim_in - 0.5),
       "The logo's box runs off the face: a smaller logo_w or logo_size.");
assert(gps_z1 <= shell_len - 3, "The GPS antenna is too long for the housing (it must clear the GX12 socket's nut).");
assert(gps_y0 >= bore_r - 0.15 - cover_ring - 1, "The GPS antenna is too thick for the top of the housing.");
assert(mount != "cluster" || (tilt >= 0 && cl_up - shell_r*cos(tilt) >= max(0, -(cl_back + shell_r*sin(tilt))*tan(stock_tilt)) + cl_foot_t + 1),
       "The gauge would sit on the cluster adapter's foot: raise cl_up.");
assert(mount != "bar" || len(hb_ok) > 0, str("The gauge can't hide its bar clamps with a ", bike_clamp_w, " mm wide handlebar clamp: check bike_clamp_w (up to about 85 mm hides at 25 degrees of tilt), or use the cluster mount."));
echo(head = [2*face_r, head_len], bezel = face_r - active_d/2, lip_t = lip_t, icon_angles = icon_angs, glass_z = glass_z, z_carrier = z_carrier, z_cov = z_cov, shell_len = shell_len);


// ------------------------- HELPERS ------------------------------------
module ring(r0, r1, h) difference() { cylinder(r=r1, h=h); translate([0, 0, -0.1]) cylinder(r=r0, h=h + 0.2); }
module at_ang(a, r) rotate(a) translate([r, 0, 0]) children();
module radial_hole(a, z, d, l=20) rotate(a) translate([0, 0, z]) rotate([0, 90, 0]) cylinder(d=d, h=l, $fn=32);

// ------------------------- THE DISPLAY (simplified envelope, view only and for fit checks) ----
module display_dummy() {
  translate([0, 0, glass_z]) {
    color([0.05, 0.05, 0.06]) cylinder(d=glass_d, h=glass_t);
    color([0.12, 0.2, 0.32]) translate([0, 0, -0.08]) cylinder(d=active_d, h=0.05);    // the screen (drawn just in front of the glass)
    color([0.2, 0.2, 0.22]) {
      translate([0, panel_y, panel_z[0]]) cylinder(d=panel_d, h=panel_z[1] - panel_z[0]);
      translate([-fpc[0]/2, panel_y - panel_d/2 - fpc[1] + 2, panel_z[0]]) cube([fpc[0], fpc[1], fpc[2]]);
    }
    color([0.1, 0.3, 0.6]) intersection() {      // the board's corners are trimmed to the glass's circle (3D model)
      translate([-pcb[0]/2, pcb_y[0], pcb_z]) cube([pcb[0], pcb_y[1] - pcb_y[0], pcb[2]]);
      translate([0, 0, pcb_z - 1]) cylinder(d=glass_d - 0.2, h=20);
    }
    color([0.3, 0.3, 0.3]) intersection() {      // components on the board's back, up to the tallest
      translate([-pcb[0]/2 + 1, pcb_y[0] + 1, pcb_z + pcb[2]]) cube([pcb[0] - 2, pcb_y[1] - pcb_y[0] - 2, disp_t - pcb_z - pcb[2] - 0.6]);
      translate([0, 0, pcb_z]) union() { for (s = standoffs) translate(s) cylinder(d=11, h=50); translate([-pcb[0]/2, pcb_y[0], 0]) cube([pcb[0], 12, 50]); translate([-15, 0, 0]) cube([30, 30, 50]); }
    }
    color([0.8, 0.65, 0.2]) for (s = standoffs) translate([s[0], s[1], pcb_z - 0.4]) difference() {
      cylinder(d=standoff_d, h=standoff_z - pcb_z + 0.4, $fn=24); cylinder(d=1.8, h=20, $fn=16); }
  }
}

// ------------------------- SHELL ---------------------------------------
// A round gauge: a tube, concentric with the screen, its front edge rounded. In front of the glass, the face ring lies
// on the glass's black border: the window, the logo at the top, the tell-tales round the top either side of it.
z_front = -lip_t;
module shell_body() hull() {
  translate([0, 0, z_front + round_r]) rotate_extrude($fn=240) translate([face_r - round_r, 0]) circle(round_r, $fn=16);
  translate([0, 0, z_front + round_r]) cylinder(r=face_r, h=shell_len - z_front - round_r, $fn=240);
}
// The tell-tales: on the icons' circle (icon_r), the logo's gap in the middle at the top.
icon_pitch = (pocket_d + 1.4)/icon_r*180/PI;
n_ic = len(icons);
n_l = with_logo ? floor(n_ic/2) : 0;                  // with a logo: this many on its left (the rider's left)
logo_half = atan2(logo_w/2, icon_r) + icon_pitch/2;   // from the top to the first icon either side of the logo
// Icon i's angle in the head frame (x is mirrored as seen from the front: the rider's left is +x, a smaller angle).
function icon_a(i) = !with_logo ? 90 - ((n_ic - 1)/2 - i)*icon_pitch
                   : i < n_l ? 90 - logo_half - (n_l - 1 - i)*icon_pitch : 90 + logo_half + (i - n_l)*icon_pitch;
icon_angs = with_icons ? [for (i = [0:n_ic - 1]) icon_a(i)] : [];
icon_col = [["left", [0.1, 0.9, 0.2]], ["right", [0.1, 0.9, 0.2]], ["neutral", [0.1, 0.9, 0.2]], ["beam", [0.15, 0.4, 1]],
            ["abs", [1, 0.6, 0]], ["engine", [1, 0.6, 0]], ["fuel", [1, 0.6, 0]], ["battery", [1, 0.1, 0.1]], ["oil", [1, 0.1, 0.1]]];
function icon_colour(n) = [for (c = icon_col) if (c[0] == n) c[1]][0];
// Check (a list, not a statement: no CSG nodes): the icons stay apart at the bottom.
icons_fit = [for (i = [0:max(0, n_ic - 1)]) if (with_icons)
  assert(abs(icon_a(i) - 90) + icon_pitch/2 <= 178 - icon_pitch/2,
    str("Icon ", i + 1, " (", icons[i], ") runs round into the others at the bottom: fewer icons or a narrower logo_w.")) i];
// The icons, drawn as the rider sees them, about icon_size tall, with no loose islands (stencil bridges in A and B).
module icon2d(n, s=icon_size) scale(s/8) {
  if (n == "left" || n == "right") mirror([n == "right" ? 1 : 0, 0]) polygon([[-4, 0], [-0.6, 3.2], [-0.6, 1.2], [4, 1.2], [4, -1.2], [-0.6, -1.2], [-0.6, -3.2]]);
  else if (n == "beam") {
    intersection() { translate([0.2, 0]) circle(r=3.2, $fn=40); translate([0.2, -4]) square(8); }
    translate([-0.3, -3.2]) square([0.6, 6.4]);
    for (y = [-2.6, -0.9, 0.9, 2.6]) translate([-3.9, y - 0.35]) square([3.0, 0.7]);
  }
  else if (n == "neutral") text("N", size=6.4, font="Liberation Sans:style=Bold", halign="center", valign="center");
  else if (n == "abs") difference() {
    for (c = [["A", -3.0], ["B", 0.05], ["S", 3.0]]) translate([c[1], 0]) text(c[0], size=3.5, font="Liberation Sans:style=Bold", halign="center", valign="center");
    translate([-3.0 - 0.3, -3]) square([0.6, 6]);           // bridge through A's counter
    translate([0.25 - 0.3, -3]) square([0.6, 6]);           // and B's two counters
  }
  else if (n == "engine") polygon([[-3.6, -2.0], [2.4, -2.0], [2.4, -0.8], [3.8, -0.8], [3.8, 1.0], [2.4, 1.0], [2.4, 2.0],
                                   [0.8, 2.0], [0.8, 3.0], [-1.6, 3.0], [-1.6, 2.0], [-2.6, 2.0], [-2.6, 0.9], [-3.6, 0.9]]);
  else if (n == "fuel") {
    translate([-3.0, -3.4]) square([4.0, 6.8]);
    translate([1.8, -2.4]) square([0.8, 3.6]);
    translate([1.0, 0.8]) square([1.6, 0.8]);
    translate([2.6, -2.4]) square([0.9, 0.8]);
  }
  else if (n == "battery") { translate([-3.8, -2.4]) square([7.6, 4.6]); for (x = [-2.6, 1.4]) translate([x, 2.2]) square([1.2, 0.9]); }
  else if (n == "oil") { polygon([[-3.8, -1.6], [2.0, -1.6], [3.6, 0.4], [1.0, 0.4], [-0.6, 1.6], [-3.0, 1.6], [-3.8, 0.4]]); translate([3.2, -2.6]) circle(r=0.6, $fn=16); }
}
// Place 2D children at icon i, upright (as the rider sees it), mirrored so it reads right from the front.
module at_icon(i) translate([icon_r*cos(icon_a(i)), icon_r*sin(icon_a(i))]) mirror([1, 0]) children();
// A box around radius r0..r1 and angle a, width w, from z0 to z1.
module ring_box(a, w, r0, r1, z0, z1) rotate(a) translate([r0, -w/2, z0]) cube([r1 - r0, w, z1 - z0]);
module logo2d() mirror([1, 0]) {
  if (logo_file != "") resize([0, logo_size], auto=true) import(logo_file, center=true);
  else if (logo_text != "") resize([0, logo_size], auto=true) text(logo_text, size=10, font="Liberation Sans:style=Bold", halign="center", valign="center", spacing=1.12);
}
module head_shell() difference() {
  shell_body();
  // the trim ring's rebate, round the face's edge
  if (trim) translate([0, 0, z_front - 1]) ring(face_r - trim_wh[0], face_r + 1, trim_wh[1] + 1);
  // the screen's window, with a 45-degree chamfer at the front
  translate([0, 0, z_front - 1]) cylinder(r=win_r, h=lip_t + 2);
  translate([0, 0, z_front - 0.01]) cylinder(r1=win_r + 1.2, r2=win_r, h=1.2);
  // the bore, behind the face ring
  cylinder(r=bore_r, h=shell_len + 1);
  // the key's groove, from the back rim to the carrier
  rotate(key_a - 90) translate([-key_w/2 - 0.2, bore_r - 0.5, z_carrier - 0.2]) cube([key_w + 0.4, key_d + 0.7, shell_len]);
  // the 4 cover screws: holes through the wall, flat seats for the pan heads
  for (a = screw_ang) {
    radial_hole(a, z_screw, 3.4, 80);
    rotate(a) translate([bore_r + 3.5, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=6.2, h=20, $fn=32);
  }
  if (with_icons) {
    for (i = [0:n_ic - 1]) {
      // the LED board's pocket (open to the glass), the light chamber in front of it, the icon through the skin
      rotate(icon_a(i)) translate([icon_r, 0, 0]) {
        translate([0, 0, z_led]) cylinder(d=pocket_d, h=-z_led + 0.01, $fn=48);
        translate([0, 0, z_front + face_skin]) cylinder(d=light_d, h=light_gap + 0.01, $fn=48);
      }
      translate([0, 0, z_front - 0.1]) linear_extrude(face_skin + 0.2) at_icon(i) icon2d(icons[i]);
    }
    // the wires: a channel in the face's back joining the pockets, out to wire_a, then a groove in the bore's wall,
    // past the glass's edge, back to the carrier
    a0 = min(concat(icon_angs, [wire_a])); a1 = max(concat(icon_angs, [wire_a]));
    rotate(a0) rotate_extrude(angle=a1 - a0, $fn=240) translate([icon_r - 1.2, -(wire_gap + 0.6)]) square([2.4, wire_gap + 0.61]);
    ring_box(wire_a, 2.4, icon_r, bore_r + 1.6, -(wire_gap + 0.6), 0.01);
    ring_box(wire_a, 3, bore_r - 1, bore_r + 1.6, -(wire_gap + 0.6), z_carrier + carrier_t + 2);
  }
  // the logo, engraved, centred at the top
  if (with_logo) translate([0, logo_y, z_front - 0.01]) linear_extrude(logo_depth + 0.01) logo2d();
}

// ------------------------- CARRIER ------------------------------------
module head_carrier() difference() {
  union() {
    translate([0, 0, z_carrier]) cylinder(r=bore_r - 0.25, h=carrier_t);
    translate([0, 0, z_carrier]) ring(bore_r - 0.25 - carrier_skirt, bore_r - 0.25, z_cov - z_carrier);
    rotate(key_a - 90) translate([-key_w/2, bore_r - 0.5, z_carrier]) cube([key_w, key_d + 0.3, z_cov - z_carrier]);   // key
  }
  // the display's 4 M2 screws (M2 x 6), countersunk from the back
  for (s = standoffs) translate([s[0], s[1], z_carrier - 1]) {
    cylinder(d=2.4, h=carrier_t + 2, $fn=24);
    translate([0, 0, 1 + carrier_t - 1.2]) cylinder(d1=2.4, d2=4.4, h=1.21, $fn=24);
  }
  // a 0.6 mm relief over the board's back (its tallest parts are level with the standoffs' ends)
  translate([0, 0, z_carrier - 0.1]) intersection() {
    translate([-pcb[0]/2 + 1, pcb_y[0] + 1, 0]) cube([pcb[0] - 2, pcb_y[1] - pcb_y[0] - 2, 0.7]);
    difference() { cylinder(r=bore_r, h=1); for (st = standoffs) translate(st) cylinder(d=standoff_d + 2.5, h=2, $fn=24); }
  }
  // wiring window to the display's headers (I2C / UART on the right, 12-pin at the top left): a big centre hole
  translate([0, 0, z_carrier - 1]) linear_extrude(carrier_t + 2) offset(r=3) square([36, 26], center=true);
  // the skirt: a wide notch at the top (the GPS antenna lies there, the LEDs' wires come in beside it), one at the bottom
  translate([-16, bore_r - 5, z_carrier + carrier_t]) cube([32, 6, z_cov - z_carrier]);
  translate([-9, -bore_r - 1, z_carrier + carrier_t + 1]) cube([18, 6, z_cov - z_carrier]);
}
// The GPS module and the CAN board are fixed to the carrier's back with double-sided foam tape (no holes: their
// boards vary; keep them below gps_y0, clear of the antenna). The patch antenna lies at the top, behind the carrier.

// ------------------------- COVER --------------------------------------
gx12_y = bore_r - 0.15 - cover_ring - 9;             // the GX12 socket, at the top of the cover (its plug clears the bike's clamp)
// The mount's bolts in the cover: the bar clamps' 4 (2 per foot, from inside), or the cluster adapter's 2 (inserts).
cover_bolts = mount == "bar" ? [for (sx = [-1, 1], b = bar_bolts) [sx*b[0], b[1]]] : [for (sx = [-1, 1]) [sx*cradle_bolt[0], cradle_bolt[1]]];
// The back logo's free area: below the GX12 socket, above the mount (the cradle's or the adapter's pad, or the joint).
back_top = gx12_y - gx12_d/2 - 2;
back_bot = mount == "stalk" ? -gp_drop + gp_r + 2 : cradle_bolt[1] + 9 + 2;
back_ok = back_logo_text == "" && back_logo_file == "" ? true :
  assert(back_logo_size[0] <= 2*(bore_r - 10) && back_logo_y + back_logo_size[1]/2 <= back_top && back_logo_y - back_logo_size[1]/2 >= back_bot
         && max(back_logo_size) > 0,
         str("The back logo doesn't fit: up to ", 2*(bore_r - 10), " mm wide, between y ", back_bot, " and ", back_top, ".")) true;
module back_logo2d() resize(back_logo_size, auto=true) {
  if (back_logo_file != "") import(back_logo_file, center=true);
  else text(back_logo_text, size=10, font="Liberation Sans:style=Bold", halign="center", valign="center", spacing=1.1);
}
module head_cover() difference() {
  union() {
    difference() {
      union() {
        translate([0, 0, z_cov]) cylinder(r=bore_r - 0.15, h=cover_plug);            // the plug
        translate([0, 0, shell_len]) cylinder(r=shell_r, h=cover_back);               // the back plate
        rotate(key_a - 90) translate([-key_w/2, bore_r - 0.6, z_cov]) cube([key_w, key_d + 0.3, cover_plug]);   // key
      }
      // hollow inside the plug (a ring, 7 mm wide, carries the inserts), and a notch at the top for the GPS antenna's end
      translate([0, 0, z_cov - 1]) cylinder(r=bore_r - 0.15 - cover_ring, h=cover_plug + 1);
      translate([-(gps_patch[0] + 1)/2, gps_y0 - 0.5, z_cov - 1]) cube([gps_patch[0] + 1, 20, gps_z1 + 0.5 - z_cov + 1]);
    }
    if (mount == "stalk")     // GoPro-style 3 fingers
      for (x = gp_fingers3) translate([x - gp_finger_t/2, -gp_drop, shell_len + cover_back]) rotate([0, 90, 0])
        hull() { translate([-gp_reach, 0, 0]) cylinder(r=gp_r, h=gp_finger_t, $fn=48); translate([0, -gp_r - 2, 0]) cube([0.01, 2*gp_r + 4, gp_finger_t]); }
    else                      // bosses inside: the cluster adapter's M4 inserts, or seats for the bar clamps' bolt heads
      for (b = cover_bolts) translate([b[0], b[1], shell_len - (mount == "bar" ? 4 : m4_insert_l + 1)]) cylinder(d=10, h=(mount == "bar" ? 4 : m4_insert_l + 1) + 0.01, $fn=40);
  }
  // heat-set inserts for the 4 radial screws
  for (a = screw_ang) rotate(a) translate([bore_r - 0.15 - insert_l, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=insert_d, h=insert_l + 1, $fn=32);
  if (mount == "stalk") translate([-20, -gp_drop, shell_len + cover_back + gp_reach]) rotate([0, 90, 0]) cylinder(d=gp_hole, h=40, $fn=32);
  else if (mount == "bar") for (b = cover_bolts) translate([b[0], b[1], shell_len - 6]) cylinder(d=4.5, h=cover_back + 7, $fn=24);   // M4 x 14 from inside
  else for (b = cover_bolts) translate([b[0], b[1], shell_len - m4_insert_l]) cylinder(d=m4_insert_d, h=m4_insert_l + cover_back + 1, $fn=32);
  // GX12 4-pin socket
  translate([0, gx12_y, shell_len - 1]) cylinder(d=gx12_d, h=cover_back + 2, $fn=48);   // its nut (15 mm) inside the ring
  // the back logo, engraved (seen from behind the head, so not mirrored)
  if (back_logo_text != "" || back_logo_file != "")
    translate([0, back_logo_y, shell_len + cover_back - back_logo_depth]) linear_extrude(back_logo_depth + 0.01) back_logo2d();
}

// The trim ring: glued into the face's rebate, its outer front edge rounded.
module trim_ring() rotate_extrude($fn=240) translate([face_r - trim_wh[0] + 0.15, z_front])
  offset(r=0.6, $fn=12) offset(delta=-0.6) square([trim_wh[0] - 0.15, trim_wh[1]]);
// The GPS antenna, lying flat at the top inside the housing, facing up.
module gps_patch() color([0.85, 0.8, 0.55]) translate([-gps_patch[0]/2, gps_y0, gps_z0]) cube([gps_patch[0], gps_patch[2], gps_patch[1]]);
// The lit icons, for the pictures: resin-filled icon windows.
module back_logo_fill() if (back_logo_text != "" || back_logo_file != "")
  color([0.8, 0.81, 0.84]) translate([0, back_logo_y, shell_len + cover_back - back_logo_depth + 0.02]) linear_extrude(back_logo_depth) offset(-0.03) back_logo2d();
module logo_fill() color([0.8, 0.81, 0.84]) translate([0, logo_y, z_front - 0.02]) linear_extrude(logo_depth) offset(-0.03) logo2d();   // painted silver (pictures)
module icons_lit() if (with_icons) for (i = [0:n_ic - 1]) color(icon_colour(icons[i])) translate([0, 0, z_front - 0.02]) linear_extrude(face_skin) at_icon(i) offset(-0.05) icon2d(icons[i]);

// ------------------------- FOAM RING ----------------------------------
module lip_gasket() ring(win_r + 0.2, glass_d/2 - 0.3, gasket_t);   // the whole black border, hidden under the face ring

// ------------------------- BAR CLAMP ----------------------------------
// In its own frame: the bar along x through the origin; the joint above it at +z.
cl_r = bar_d/2 + clamp_rubber + clamp_t;
module clamp_body(upper, fingers=true) difference() {
  union() {
    if (upper) {
      intersection() { rotate([0, 90, 0]) cylinder(r=cl_r, h=clamp_w, center=true); translate([-clamp_w, -50, 0]) cube([2*clamp_w, 100, 50]); }
      translate([-clamp_w/2, -cl_r - 6, 0]) cube([clamp_w, 2*cl_r + 12, 6]);                // bolt ears
      if (fingers) {           // the riser and the 2 fingers
        for (x = gp_fingers2) translate([x - gp_finger_t/2, 0, 0]) rotate([0, 90, 0])
          hull() { translate([-riser, 0, 0]) cylinder(r=gp_r, h=gp_finger_t, $fn=48); translate([-cl_r + 2, -10, 0]) cube([0.01, 20, gp_finger_t]); }
        hull() for (x = gp_fingers2) translate([x - gp_finger_t/2, -10, cl_r - 2]) cube([gp_finger_t, 20, 0.01]);
        translate([-gp_finger_t - gp_gap/2, -10, 0]) cube([2*gp_finger_t + gp_gap, 20, cl_r]);
      }
    } else {
      intersection() { rotate([0, 90, 0]) cylinder(r=cl_r, h=clamp_w, center=true); translate([-clamp_w, -50, -50]) cube([2*clamp_w, 100, 50]); }
      translate([-clamp_w/2, -cl_r - 6, -6]) cube([clamp_w, 2*cl_r + 12, 6]);
    }
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=clamp_w + 2, center=true);
  translate([-clamp_w, -50, -0.4]) cube([2*clamp_w, 100, 0.8]);                    // gap between the halves
  for (s = [-1, 1]) translate([0, s*(cl_r + 1.5), -20]) {
    cylinder(d=clamp_bolt, h=40, $fn=24);
    if (!upper) translate([0, 0, 20 - 6 - 0.01]) cylinder(d=clamp_nut/cos(30), h=3.5, $fn=6);   // nut trap below
  }
  // the gap between the 2 fingers (for the cover's middle finger), and the bolt
  if (upper && fingers) {
    translate([-gp_gap/2, -20, cl_r - 2]) cube([gp_gap, 40, riser + 20]);
    translate([-20, 0, riser]) rotate([0, 90, 0]) cylinder(d=gp_hole, h=40, $fn=32);
  }
}
module clamp_upper() clamp_body(true);
module clamp_lower() clamp_body(false);

// ------------------------- THE BAR MOUNT (mount = "bar") ----------------
// In the mount's frame: the bar along x through the origin, y forward, z up, before the tilt (the clamps and the head
// turn about the bar together). 2 clamps (left, right), each: an upper half round the bar with a solid block back to
// a foot that bolts straight to the cover's back (2 M4 from inside the cover, a rubber pad between), and a cap. The clamp
// bolts come up from below through the cap into M4 inserts in the upper half (the front ear and the block).
cradle_span = bike_clamp[0] + 2*clamp_gap + cradle_clamp_w;   // centre to centre of the 2 clamps
crl_r = bar_d/2 + clamp_rubber + mount_t;           // the clamps' outer radius
cr_bolt_y = crl_r + 2.2;                            // the clamp bolts, either side of the bar
cr_ear = crl_r + 6.5;                               // the ears reach this far fore and aft
// The bike's clamp (fixed to the bike) seen in the mount's frame: turned back by the tilt. Its rear corner sets how close
// the gauge can come: the foot, the rubber and room for the bolt heads go between.
bc_rear = max([for (z = [-bar_d/2 - 4, bike_clamp[2]]) -(-bike_clamp[1]/2*cos(tilt) - z*sin(tilt))]);
// Placing the gauge to hide the mount: the eye in the mount's frame, then the gauge's face plane (y = face_y(hb)).
cr_eye = [0, -rider_eye[0]*cos(tilt) - rider_eye[1]*sin(tilt), -rider_eye[0]*sin(tilt) + rider_eye[1]*cos(tilt)];
function face_y(hb) = z_front - hb - shell_len - cover_back;
function up_for(hb) = cr_eye[2]*(1 - (face_y(hb) - cr_eye[1])/(-cr_eye[1]));   // the gauge's centre on the eye-to-clamps line
// The farthest any corner of the clamps (with their ears and caps) appears from the gauge's centre, seen from the eye,
// on the face's plane. Under face_r: hidden (the face alone is the smallest outline of the gauge, so this is safe).
function seen_r(hb) = max([for (x = [cradle_span/2 - cradle_clamp_w/2, cradle_span/2 + cradle_clamp_w/2], y = [-cr_ear, cr_ear], z = [-crl_r, crl_r])
  let(k = (face_y(hb) - cr_eye[1])/(y - cr_eye[1])) norm([k*x, cr_eye[2] + k*(z - cr_eye[2]) - up_for(hb)])]);
hb_min = max(bc_rear + mount_rubber + foot_t + 5, cr_ear + 6);   // as close as the bike's clamp allows
hb_max = hb_min + 25;
hb_ok = [for (hb = [ceil(hb_min):1:hb_max]) if (seen_r(hb) <= face_r - 0.8) hb];
head_back = mount == "bar" && len(hb_ok) > 0 ? hb_ok[0] : 34;   // the head's back face, this far behind the bar's centre
head_up = mount == "bar" ? up_for(head_back) : 20;  // the head's centre, this far above the bar's centre
module cr_head_frame() translate([0, -head_back - (shell_len + cover_back), head_up]) multmatrix(HEAD_TO_BIKE) children();
// One foot (side sx), in the head's frame: round the 2 bolts, on the rubber pad.
module foot_2d(sx) hull() for (b = bar_bolts) translate([-sx*b[0], b[1]]) circle(r=7, $fn=32);   // (the head's x is mirrored)
module bar_mount(sx) difference() {
  union() {
    translate([sx*cradle_span/2, 0, 0]) {
      intersection() { rotate([0, 90, 0]) cylinder(r=crl_r, h=cradle_clamp_w, center=true); translate([-cradle_clamp_w, -50, 0]) cube([2*cradle_clamp_w, 100, 50]); }
      translate([-cradle_clamp_w/2, 0, 0]) cube([cradle_clamp_w, cr_ear, 9]);                    // the front ear
    }
    // the block: from the clamp's back, straight back (and in) to the foot
    hull() {
      translate([sx*cradle_span/2 - cradle_clamp_w/2, -cr_ear, 0]) cube([cradle_clamp_w, cr_ear, crl_r]);
      cr_head_frame() translate([0, 0, shell_len + cover_back + mount_rubber]) linear_extrude(foot_t) foot_2d(sx);
    }
  }
  translate([sx*cradle_span/2, 0, 0]) {
    rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=cradle_clamp_w + 2, center=true);
    translate([-cradle_clamp_w, -50, -0.4]) cube([2*cradle_clamp_w, 100, 0.8]);
    for (s = [-1, 1]) translate([0, s*cr_bolt_y, -1]) cylinder(d=m4_insert_d, h=1 + m4_insert_l, $fn=24);   // inserts from below
    translate([-cradle_clamp_w/2 - 1, -cr_ear - 1, -50]) cube([cradle_clamp_w + 2, 2*cr_ear + 2, 50 - 0.4]);   // the cap's room below the split
  }
  // the foot's 2 M4 inserts (6 mm long), pressed in from the pad's side; the bolts come from inside the cover
  cr_head_frame() for (b = bar_bolts) translate([-sx*b[0], b[1], shell_len + cover_back + mount_rubber - 0.01]) cylinder(d=m4_insert_d, h=6.5, $fn=24);
  cr_head_frame() translate([0, 0, -1]) cylinder(r=shell_r + 0.01, h=shell_len + cover_back + mount_rubber + 1, $fn=120);   // clear of the gauge and the pad
  rotate([tilt, 0, 0]) translate([-bike_clamp[0]/2 - 1, -bike_clamp[1]/2 - 1, -50]) cube([bike_clamp[0] + 2, bike_clamp[1] + 2, 50 + bike_clamp[2] + 2]);   // clear of the bike's clamp
}
module cradle() for (sx = [-1, 1]) bar_mount(sx);    // both clamps' upper halves, for the pictures and the checks
// The rubber pad between a foot and the cover (2 of them): 2 mm rubber sheet, or print it in TPU.
module mount_pad(sx) cr_head_frame() translate([0, 0, shell_len + cover_back]) linear_extrude(mount_rubber) difference() {
  foot_2d(sx); for (b = bar_bolts) translate([-sx*b[0], b[1]]) circle(d=4.6, $fn=24); }
// The clamps' lower halves (2): M4 x 20 bolts up from below into the inserts.
module cradle_cap() difference() {
  union() {
    intersection() { rotate([0, 90, 0]) cylinder(r=crl_r, h=cradle_clamp_w, center=true); translate([-cradle_clamp_w, -50, -50]) cube([2*cradle_clamp_w, 100, 50]); }
    translate([-cradle_clamp_w/2, -cr_ear, -6]) cube([cradle_clamp_w, 2*cr_ear, 6]);
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=cradle_clamp_w + 2, center=true);
  translate([-cradle_clamp_w, -50, -0.4]) cube([2*cradle_clamp_w, 100, 0.8]);
  for (s = [-1, 1]) translate([0, s*cr_bolt_y, -20]) cylinder(d=4.5, h=40, $fn=24);
}
module bike_clamp_dummy() translate([-bike_clamp[0]/2, -bike_clamp[1]/2, -bar_d/2 - 4]) cube([bike_clamp[0], bike_clamp[1], bike_clamp[2] + bar_d/2 + 4]);

// ------------------------- THE CLUSTER ADAPTER (mount = "cluster") -----
// In the bike's frame (x along the bar, y forward, z up), the origin at the stock holes' centre on the bracket's top.
pad_gx = cradle_bolt[0] + 7;                        // the 2 gussets, outside the M4 bolts (their heads stay reachable)
foot_w = max(max([for (h = stock_holes) abs(h[0])])*2 + 24, 2*(pad_gx + abs(cl_x)) + 6);   // wide enough for the gussets, wherever the gauge sits
foot_d = max(max([for (h = stock_holes) abs(h[1])])*2 + 24, 24);
module stock_frame() rotate([stock_tilt, 0, 0]) children();
module cl_head_frame() translate([-cl_x, -cl_back, cl_up]) rotate([-tilt, 0, 0]) translate([0, -(shell_len + cover_back), 0]) multmatrix(HEAD_TO_BIKE) children();
module cluster_adapter() difference() {
  union() {
    cl_head_frame() translate([-pad_gx - 3, cradle_bolt[1] - 9, shell_len + cover_back]) cube([2*pad_gx + 6, 18, adapter_t]);   // the pad
    stock_frame() translate([-foot_w/2, -foot_d/2, 0]) cube([foot_w, foot_d, cl_foot_t]);                                  // the foot
    for (sx = [-1, 1]) hull() {                                                                                         // 2 gussets, upright
      cl_head_frame() translate([sx*pad_gx - 3, cradle_bolt[1] - 9, shell_len + cover_back]) cube([6, 18, adapter_t]);
      stock_frame() translate([-sx*pad_gx - cl_x - 3, -foot_d/2, 0]) cube([6, foot_d, cl_foot_t]);   // (the head's x is mirrored)
    }
  }
  // the 2 M4 bolts into the cover's inserts
  cl_head_frame() for (sx = [-1, 1]) translate([sx*cradle_bolt[0], cradle_bolt[1], shell_len + cover_back - 1]) cylinder(d=4.5, h=adapter_t + 2, $fn=24);
  // the stock holes: M6 bolts from below, nuts captive in the foot's top
  stock_frame() for (h = stock_holes) translate([h[0], h[1], -1]) {
    cylinder(d=stock_bolt, h=cl_foot_t + 2, $fn=32);
    translate([0, 0, 1 + cl_foot_t - 5.4]) cylinder(d=stock_nut/cos(30) + 0.3, h=10, $fn=6);
  }
  // keep clear of the gauge (it only touches the pad)
  cl_head_frame() translate([0, 0, -1]) cylinder(r=shell_r + 0.01, h=shell_len + cover_back + 1, $fn=120);
}
module stock_bracket_dummy() stock_frame() translate([-stock_plate[0]/2, -stock_plate[1]/2, -stock_plate[2]]) cube(stock_plate);

// ------------------------- ASSEMBLY -----------------------------------
// The head in its frame, then turned onto the clamp: the joint's axis is along the bar (x); tilt turns about it.
module head_parts(e=0) {
  color([0.16, 0.17, 0.19]) head_shell();
  color([0.95, 0.5, 0.15]) translate([0, 0, gasket_t > 0 ? -0.001 : 0]) lip_gasket();
  if (SHOW_DISPLAY) display_dummy();
  color([0.45, 0.47, 0.5]) translate([0, 0, e]) head_carrier();
  color([0.22, 0.23, 0.26]) translate([0, 0, 2*e]) head_cover();
  if (e == 0) { icons_lit(); logo_fill(); back_logo_fill(); }
  if (trim) color([0.78, 0.79, 0.82]) translate([0, 0, -e*0.5]) trim_ring();
  gps_patch();
}
joint_z = shell_len + cover_back + gp_reach;
// The head in the bike's frame (bar along x, y forward, z up): its axis points forward, its top up, turned by tilt.
HEAD_TO_BIKE = [[-1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];
module head_placed() {
  if (mount == "cluster") cl_head_frame() children();
  else if (mount == "stalk") translate([0, 0, riser]) rotate([-tilt, 0, 0]) multmatrix(HEAD_TO_BIKE) translate([0, gp_drop, -joint_z]) children();
  else rotate([-tilt, 0, 0]) translate([0, -head_back - (shell_len + cover_back), head_up]) multmatrix(HEAD_TO_BIKE) children();
}
module mount_parts(e=0) {
  if (mount == "cluster") color([0.25, 0.26, 0.28]) translate([0, e*0.6, 0]) cluster_adapter();
  else if (mount == "stalk") { color([0.25, 0.26, 0.28]) { clamp_upper(); clamp_lower(); } }
  else rotate([-tilt, 0, 0]) color([0.25, 0.26, 0.28]) {
    translate([0, e*0.6, 0]) cradle();
    color([0.1, 0.1, 0.1]) translate([0, e*0.3, 0]) for (sx = [-1, 1]) mount_pad(sx);
    for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, -e*0.6]) cradle_cap();
  }
}
module head_on_clamp(e=0) {
  if (mount != "stalk") head_placed() translate([0, 0, -e*1.2]) head_parts(e);
  else head_placed() head_parts(e);
  mount_parts(e);
  if (mount == "cluster") color([0.55, 0.56, 0.58, 0.45]) stock_bracket_dummy();   // where the bar is depends on your bike: not shown
  else color([0.75, 0.75, 0.75, 0.6]) rotate([0, 90, 0]) cylinder(d=bar_d, h=220, center=true);
  if (mount == "bar") color([0.55, 0.56, 0.58, 0.35]) bike_clamp_dummy();
}

// For check_hidden: seen from the rider's eye, any part of the cradle (or the cluster adapter) outside the gauge's shadow. Must be empty.
module head_envelope() translate([0, 0, z_front]) cylinder(r=face_r, h=head_len, $fn=120);
eye_bike = [0, -rider_eye[0], rider_eye[1]];
module gauge_shadow() hull() { head_placed() head_envelope(); translate(eye_bike) scale(6) translate(-eye_bike) head_placed() head_envelope(); }

// ------------------------- PART SELECTOR ------------------------------
if (PART == "assembly") head_on_clamp(0);
else if (PART == "exploded") head_on_clamp(25);
else if (PART == "front") head_parts(0);
else if (PART == "display_dummy") display_dummy();
else if (PART == "head_shell") translate([0, 0, lip_t]) head_shell();                 // face down (the icons come out crisp)
else if (PART == "head_carrier") translate([0, 0, -z_carrier]) head_carrier();         // plate on the bed
else if (PART == "head_cover") translate([0, 0, -z_cov]) head_cover();              // plug's front edge on the bed, fingers up
else if (PART == "trim_ring") translate([0, 0, -z_front]) trim_ring();
else if (PART == "icons") for (i = [0:len(icons) - 1]) translate([i*12, 0]) icon2d(icons[i]);   // 2D, for checking
else if (PART == "lip_gasket") lip_gasket();
else if (PART == "clamp_upper") clamp_upper();
else if (PART == "clamp_lower") rotate([180, 0, 0]) clamp_lower();
else if (PART == "bar_mount_right") translate([0, 0, -cradle_span/2 + cradle_clamp_w/2]) rotate([0, -90, 0]) bar_mount(1);   // on the clamp's inner face (round clamp; the block above: support under it)
else if (PART == "bar_mount_left") translate([0, 0, -cradle_span/2 + cradle_clamp_w/2]) rotate([0, 90, 0]) bar_mount(-1);
else if (PART == "mount_pad") mount_pad(1);         // flat (2 of them; mirror the second, or cut both from 2 mm rubber)
else if (PART == "cradle_cap") translate([0, 0, cradle_clamp_w/2]) rotate([0, 90, 0]) cradle_cap();   // on its face
else if (PART == "cluster_adapter") rotate([-stock_tilt, 0, 0]) cluster_adapter();   // the foot on the bed, the nut pockets up
// Checks: must be empty (or only touch).
else if (PART == "check_display") intersection() { display_dummy(); union() { head_shell(); head_carrier(); head_cover(); } }
else if (PART == "check_gasket") intersection() { display_dummy(); lip_gasket(); }   // must collide: the squeeze
else if (PART == "check_parts") {
  intersection() { head_shell(); head_carrier(); }
  intersection() { head_shell(); head_cover(); }
  intersection() { head_carrier(); head_cover(); }
  intersection() { head_shell(); gps_patch(); }
  if (trim) intersection() { head_shell(); trim_ring(); }
  intersection() { head_carrier(); gps_patch(); }
  intersection() { head_cover(); gps_patch(); }
  intersection() { head_shell(); lip_gasket(); }
}
else if (PART == "check_clamp") intersection() { clamp_upper(); clamp_lower(); }
// The head (every part) vs the mount, the bar and the bike's own handlebar clamp, at this tilt: must be empty
// (with mount = "bar" the cover only touches the cradle's bridge, where they bolt together; with "cluster", the
// adapter's pad. With "cluster" the bar isn't checked: its place depends on your bike).
else if (PART == "check_mount") {
  intersection() {
    head_placed() union() { head_shell(); head_cover(); }
    union() {
      if (mount != "cluster") rotate([0, 90, 0]) cylinder(d=bar_d, h=220, center=true);
      if (mount == "cluster") { cluster_adapter(); stock_bracket_dummy(); }
      else if (mount == "stalk") { clamp_upper(); clamp_lower(); }
      else { bike_clamp_dummy(); rotate([-tilt, 0, 0]) { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); } }
    }
  }
}
// The cradle vs its caps and the bike's handlebar clamp: must be empty.
else if (PART == "check_hidden") difference() {
  if (mount == "bar") rotate([-tilt, 0, 0]) { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); }
  else if (mount == "cluster") cluster_adapter();
  gauge_shadow();
}
else if (PART == "check_cradle") {
  intersection() { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); }
  intersection() { rotate([-tilt, 0, 0]) union() { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); } bike_clamp_dummy(); }
}
else if (PART == "none") { }

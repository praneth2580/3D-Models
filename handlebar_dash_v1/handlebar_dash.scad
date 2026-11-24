/*
  HANDLEBAR DASH v1: the display head (a round gauge with its tell-tales in the face) and its handlebar mount.
  OpenSCAD 2021.01. PART selects what to show or export (list below). The interface box comes next.

  Built around these parts (see COMPONENTS.md; buy exactly these, or the parts won't fit):
    - Waveshare ESP32-S3 2.8" round display board (ESP32-S3-Touch-LCD-2.8C or ESP32-S3-LCD-2.8C). Its sizes here are
      from Waveshare's published outline drawing and its official 3D model (STEP, 2024-12-26): cover glass 95.86 mm
      across and 1.26 mm thick, visible screen 70.13 mm across, 4 M2 brass standoffs (4 mm across) whose ends are
      9.71 mm behind the glass front, total thickness 9.73 mm.
    - u-blox NEO-M8N GPS with a 25 x 25 mm ceramic patch antenna on a cable (the antenna sits inside the face ring).
    - 8 x 5 mm addressable RGB LEDs (WS2812B family, e.g. XINGLIGHT XL-504RGBC-WS2812B or WS2812D-F5): the tell-tales.
    - SN65HVD230 CAN transceiver board (dash bus), GX12 4-pin panel socket (the cable to the interface box).

  How it goes together (front = the screen side, facing the rider):
    1. SHELL: a round tube with a thin front lip. The glass sits behind the lip on a foam ring (0.8 mm).
    2. CARRIER: a cup. The display screws onto its front with 4 x M2 x 6 into the display's own standoffs; the GPS
       module and the CAN board go on its back. The display and the carrier slide into the shell from the back;
       a key on the carrier fits a groove in the shell, so the screen can't be fitted rotated.
    3. COVER: a plug that closes the back. Its front edge presses the carrier forward, so the glass seats on the foam
       ring. 4 x M3 x 10 pan-head screws through the shoulder into heat-set inserts in the cover hold it all.
    TELL-TALES (owner: "options to show status indicators like high beam, abs"; "look like they are part of the model
       too, not an extra addon ... look are a great deal important"; "place the display a bit below so the logo can be
       placed above it ... reducing the overall bezel"; "how about showing them on the sides"; then both together):
       the display sits disp_drop below the face's centre, so the bezel is a slim 6 mm under the screen (bezel) and
       about 18 mm above it, where the LOGO sits; the tell-tales run in a column on each upper side, where the face is
       wide (5.5 mm icons, 4 a side), as in the gauge faces of the Indian Scout, KOSO and Daytona. Each icon is cut
       through the face's 0.8 mm skin into its own light chamber with a 5 mm addressable RGB LED behind it (one data
       line); fill the icons flush with translucent white UV resin. The logo: logo_text, or your own SVG/DXF
       (logo_file). icons: which and in what order; telltales = "none": no lamps. The upper half of the face is hollow
       behind its front wall: the LEDs go in from inside (windows in the bore), their wires run round the hollow to the
       top, and the GPS antenna lies behind the logo.
    4. MOUNT: a GoPro-style 3-prong joint on the cover: it fits the printed bar clamp here, or any GoPro handlebar
       mount. One M5 bolt sets the tilt.

  Frame: the head's axis is z, pointing from the screen into the housing (backwards). Origin: the centre of the front
  lip's back face (where the foam ring sits). y is up; x is to the right as seen from BEHIND (to the left as seen from
  the front), as in Waveshare's 3D model and back-view drawing.
*/

// ------------------------- OUTPUT SELECTION -------------------------
// "assembly" (head on its clamp), "exploded", "front", "head_shell", "head_carrier", "head_cover",
// "icons" (2D, the tell-tale icons),
// "lip_gasket" (TPU, or cut it from 0.8 mm foam), "clamp_upper", "clamp_lower", "display_dummy" (view only);
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
lip_over = 2.2;             // how far the front lip overlaps the glass edge (the glass's black border is 12.9 mm wide)
lip_t = 1.8;                // front lip thickness
edge_r = 2.0;               // rounded front edge
gasket_t = 0.8;             // foam ring under the lip (closed-cell, self-adhesive)
gasket_squeeze = 0.2;       // how much the cover squeezes it
carrier_t = 2.5;            // the carrier's front plate
carrier_skirt = 1.6;        // its tube wall
bay = 14;                   // room behind the carrier for the GPS module, the CAN board and the wires
cover_plug = 8;             // how far the cover plugs into the shell
cover_back = 3.0;           // the cover's back plate
key_w = 6;                  // the anti-rotation key and its groove
key_a = 315;                // its angle (degrees from +x): low on one side, clear of the tell-tales and the wire notches
key_d = 1.2;
screw_ang = [60, 120, 240, 300];   // the 4 radial cover screws (degrees from +x)
insert_d = 4.2;             // M3 heat-set inserts in the cover's ring (SELECT: check your inserts)
insert_l = 5.7;
csk_d = 6.0;                // M3 countersunk head
cover_ring = 7;             // the cover plug's ring (radial width): carries the inserts
disp_drop = 6;              // the display sits this far below the face's centre: a slim bezel under the screen, a wide
                            //   one above it for the logo (owner: "place the display a bit below so the logo can be
                            //   placed above it"), and the tell-tales on the upper sides, where the face is wide
bezel = 6;                  // the bezel under the screen (from the glass's bore): it sets the gauge's size
icon_side_a = 30;           // the tell-tale columns' centres, degrees above 3 and 9 o'clock (lower: they run off the face)
face_skin = 0.8;            // the face's front skin: the icons go through it
iw = 1.2;                   // the bore's wall, inside the face
ow = 1.6;                   // the face's outer wall, around the hollow
icons = ["left", "beam", "neutral", "abs", "engine", "fuel", "battery", "right"];   // half down the rider's left side (top first), half up the right
icon_size = 5.5;            // icon height, mm (bigger: widen the bezel)
cell_d = 6.0;               // each icon's light chamber: depth (front to the LED)
led_d = 5.2;                // 5 mm LED hole
cell_back = 2.0;            // the wall the LEDs sit in
logo_text = "DASH";         // the logo above the screen, engraved: your own word ("" = none)
logo_file = "";             // or your own logo as an SVG or DXF file (it takes the place of the text), scaled to logo_size high.
                            //   Your own artwork goes in private/ (never committed or published), for example private/my_logo.svg
logo_size = 6;              // logo height, mm
logo_depth = 0.5;           // engraved this deep (fill it with paint, or leave it)
back_logo_text = "";        // a logo on the back cover (seen from in front of the bike): a word ("" = none)
back_logo_file = "";        // or your own SVG/DXF (in private/, like logo_file)
back_logo_size = [44, 0];   // its size, mm [width, height]: 0 = in proportion. It must fit the free area (asserted)
back_logo_y = 12;           // its centre, above the cover's centre: high, so the bike's handlebar clamp doesn't hide it (GX12 socket above)
back_logo_depth = 0.6;      // engraved this deep into the 3 mm back plate
round_r = 2.0;              // the face's outer edge rounded
trim = true;                // SELECT: a separate trim ring around the face's edge (print it in silver or a contrast colour)
trim_wh = [2.0, 1.4];       // its width and height (a rebate in the face's edge takes it)
groove = [0.6, 0.4];        // accent groove around the screen: width, depth
gps_patch = [25.5, 25.5, 4.5];   // GPS antenna, inside the face ring (SELECT: check yours)
gx12_d = 12.2;              // GX12 panel socket hole (12 mm thread)

// ------------------------- MOUNT ----------------------------------------
// "bar": on the handlebar, Harley-style (owner: "on the handlebar not above it, something like the harleys"): the
// head sits low behind the bar, held by a cradle: 2 bar clamps either side of the bike's own handlebar clamp, joined
// by a bridge that bolts to the back cover. Turning the cradle on the bar sets the tilt.
// "stalk": a GoPro-style joint on a clamp above the bar (or any GoPro handlebar mount).
mount = "bar";              // SELECT: "bar" or "stalk"
cradle_span = 135;          // MEASURE: centre to centre of the cradle's 2 bar clamps (either side of your bike's handlebar clamp;
                            //   the bar must be straight for clamp_w beyond them)
head_back = 34;             // MEASURE: the head's back face, this far behind the bar's centre (clear your bike's handlebar clamp)
head_up = 20;               // the head's centre, this far above the bar's centre
bike_clamp = [100, 45, 28]; // MEASURE: your bike's own handlebar clamp: width along the bar, depth (front to back), top above
                            //   the bar's centre (only for the fit check). The Meteor 350's is a one-piece die-cast clamp (as
                            //   the Interceptor 650's) on 2 risers; no published size: this is a generous estimate
cradle_bolt = [18, -30];    // the cradle's 2 M4 bolts on the cover's back: +-x, y (below the head's centre)
m4_insert_d = 5.6;          // M4 heat-set inserts (SELECT: check yours)
m4_insert_l = 8;
bridge = [6, 18];           // the cradle's bridge: thickness, height

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
shell_r = bore_r + wall_t;                           // the back of the shell (around the cover)
face_r = bore_r + bezel + disp_drop;                  // the gauge's face, centred disp_drop above the display
hc = [0, disp_drop];
glass_z = gasket_t - gasket_squeeze;                 // the glass's front face, squeezed onto the foam
z_carrier = glass_z + standoff_z;                    // the carrier's front face = the standoffs' ends
z_cov = z_carrier + carrier_t + bay;                 // the cover's front edge = the carrier skirt's back end
shell_len = z_cov + cover_plug;                      // shell, from the lip's back face to its back rim
z_screw = z_cov + cover_plug/2;                      // the radial screws' plane
head_len = lip_t + shell_len + cover_back;           // overall depth (lip front to cover back)
gp_fingers3 = [-(gp_finger_t + gp_gap), 0, gp_finger_t + gp_gap];   // pod side: 3 fingers
gp_fingers2 = [-(gp_finger_t + gp_gap)/2, (gp_finger_t + gp_gap)/2]; // clamp side: 2 fingers

// ------------------------- CHECKS ------------------------------------
assert(glass_d/2 - lip_over > active_d/2 + 3, "The front lip would cover the screen.");
assert(insert_l + 0.8 <= cover_ring, "Insert too long for the cover's ring.");
assert(gp_gap >= gp_finger_t + 0.15, "GoPro fingers won't mesh.");
assert(z_screw - csk_d/2 > z_cov + 0.5 && z_screw + csk_d/2 < shell_len - 0.5, "Cover screws too close to the shell's rim.");
assert(glass_d/2 > active_d/2, "glass smaller than the screen?");
assert(gp_drop + gp_r + 3 <= shell_r, "The joint must stay on the cover.");
assert(z_screw - 3.1 >= cav_z1 + 0.15, "The cover screws' seats would break into the face ring's hollow.");
assert(z_sh0 > z_front + 20, "The face's shoulder starts too far forward (a smaller bezel).");
assert(roof_span <= 16, str("The face's hollow would need a ", roof_span, " mm bridge over it: a smaller bezel or disp_drop."));
assert(gps_patch[1] + z_front + ow + 0.3 <= cav_z1 - 0.2, "The GPS antenna is longer than the face's hollow.");
assert(cradle_span - clamp_w >= bike_clamp[0] + 4, "The cradle's clamps would sit on your bike's handlebar clamp: widen cradle_span.");
assert(head_back - bridge[0] >= bike_clamp[1]/2 + 3, "The cradle's bridge would hit your bike's handlebar clamp: raise head_back.");
assert(head_back - bridge[0] >= cl_r + 6 + 2, "The bridge would hit the clamp caps' bolt ears: raise head_back.");
echo(head = [2*face_r, head_len], bezel_top_side_bottom = [disp_drop + face_r - bore_r, sqrt(face_r*face_r - disp_drop*disp_drop) - bore_r, bezel], roof_span = roof_span, glass_z = glass_z, z_carrier = z_carrier, z_cov = z_cov, shell_len = shell_len);


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
// A gauge cup: the face (face_r) round the screen, a 45-degree shoulder back to the cover (shell_r), so it prints face
// down without supports; the front edge rounded. The face is hollow behind its front wall, all round: the tell-tales'
// light chambers, their LEDs' wires and the GPS antenna (behind the logo) live there.
z_front = -lip_t;
top_drop = disp_drop + face_r - shell_r;              // how far the face's top stands out beyond the back
z_sh1 = shell_len;                                    // the shoulder ends at the back
cav_z1 = z_screw - 3.1 - 0.2;                         // the hollow ends (clear of the cover screws' seats), with a flat roof
z_sh0 = max(z_sh1 - top_drop, cav_z1 - 1.5);          // the shoulder starts here: just before the hollow's roof, so the GPS
                                                      //   antenna fits (outside it's steeper than 45 degrees: fine, it narrows
                                                      //   upward as it prints face down; inside, only its last 1.5 mm)
cav_y0 = 0;                                           // the hollow is only in the upper half (the bottom stays solid)
roof_span = disp_drop + face_r - ow - (cav_z1 - z_sh0)*top_drop/(z_sh1 - z_sh0) - (bore_r + iw);   // the hollow's flat roof at the top
module disk(c, r, z) translate([c[0], c[1], z]) cylinder(r=r, h=0.01, $fn=240);
module cup_hull(inset=0) hull() {
  translate([hc[0], hc[1], z_front + round_r + inset]) rotate_extrude($fn=240) translate([face_r - round_r - inset, 0]) circle(round_r, $fn=16);
  disk(hc, face_r - inset, z_sh0);
  disk([0, 0], shell_r - inset, z_sh1 - 0.01);
}
// The tell-tales: in a curve down each side of the screen.
cell_w = icon_size + 1.6;                             // each chamber: width along the arc
cell_h = icon_size + 1.5;                             //   and height (radial)
icon_r = bore_r + iw + cell_h/2 + 0.2;
icon_pitch = (cell_w + 1.4)/icon_r*180/PI;
n_ic = len(icons);
n_left = ceil(n_ic/2);
// Icon i's angle in the head frame (x is mirrored as seen from the front: the rider's left is +x). Down the left side,
// then up the right, so the list reads rider's left to right and the turn arrows sit at the top of each side.
function icon_a(i) = i < n_left ? icon_side_a + ((n_left - 1)/2 - i)*icon_pitch
                                 : 180 - icon_side_a + ((n_ic - n_left - 1)/2 - (i - n_left))*icon_pitch;
// The face's edge, from the display's centre, in direction a.
function edge_r(a) = disp_drop*sin(a) + sqrt(face_r*face_r - pow(disp_drop*cos(a), 2));
icon_hw = (cell_w/2 + 1.4)/icon_r*180/PI;             // a chamber's half-width with its walls, degrees
function ang_d(a, b) = abs((a - b + 540) % 360 - 180);
gps_a = 90;                                           // the GPS antenna: behind the logo
logo_y = (bore_r + iw + disp_drop + face_r - (trim ? trim_wh[0] : 0))/2;
icon_col = [["left", [0.1, 0.9, 0.2]], ["right", [0.1, 0.9, 0.2]], ["neutral", [0.1, 0.9, 0.2]], ["beam", [0.15, 0.4, 1]],
            ["abs", [1, 0.6, 0]], ["engine", [1, 0.6, 0]], ["fuel", [1, 0.6, 0]], ["battery", [1, 0.1, 0.1]], ["oil", [1, 0.1, 0.1]]];
function icon_colour(n) = [for (c = icon_col) if (c[0] == n) c[1]][0];
with_icons = telltales == "face" && n_ic > 0;
// Checks (lists, not statements: no CSG nodes): the icons fit the bezel, and each clears the GPS antenna and the key.
icons_fit = [for (i = [0:max(0, n_ic - 1)]) if (with_icons)
  assert(icon_r + cell_h/2 + ow <= min(edge_r(icon_a(i) - icon_hw), edge_r(icon_a(i) + icon_hw)) - (trim ? trim_wh[0] + 0.3 : 0)
         && sin(icon_a(i) - icon_hw) > 0 && sin(icon_a(i) + icon_hw) > 0,
    str("Icon ", i + 1, " (", icons[i], ") runs off the face: a smaller icon_size, fewer icons or a bigger bezel.")) i];
icons_clear = [for (i = [0:max(0, n_ic - 1)]) if (with_icons)
  assert(ang_d(icon_a(i), gps_a)*PI/180*icon_r >= cell_w/2 + 1.4 + gps_patch[0]/2 + 0.5
      && ang_d(icon_a(i), key_a)*PI/180*icon_r >= cell_w/2 + 1.4 + key_w/2 + 3 + 0.5,
    str("Icon ", i + 1, " (", icons[i], ") runs into the GPS antenna or the key: fewer icons or a smaller icon_size.")) i];
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
z_cell0 = z_front + face_skin;
z_cell1 = z_cell0 + cell_d;
module logo2d() mirror([1, 0]) {
  if (logo_file != "") resize([0, logo_size], auto=true) import(logo_file, center=true);
  else if (logo_text != "") text(logo_text, size=logo_size, font="Liberation Sans:style=Bold", halign="center", valign="center", spacing=1.12);
}
module head_shell() difference() {
  union() {
    difference() {
      cup_hull();
      // the hollow, around the bore's wall
      difference() {
        intersection() { cup_hull(ow); translate([-200, cav_y0, z_front + ow]) cube([400, 200, cav_z1 - z_front - ow]); }
        translate([0, 0, z_front - 1]) cylinder(r=bore_r + iw, h=60);
      }
    }
    // a rib in the hollow behind the key's groove
    intersection() { ring_box(key_a, key_w + 6, bore_r + iw - 0.1, face_r, z_carrier - 1, cav_z1 + 0.1); cup_hull(); }
    // the tell-tales' block in the hollow (its chambers are cut below)
    if (with_icons) for (i = [0:n_ic - 1]) intersection() {
      ring_box(icon_a(i), cell_w + 2*1.4, bore_r + iw - 0.1, edge_r(icon_a(i)) + 1, z_front + ow - 0.1, z_cell1 + cell_back);
      cup_hull();
    }
  }
  // the trim ring's rebate, round the face's edge
  if (trim) translate([hc[0], hc[1], z_front - 1]) ring(face_r - trim_wh[0], face_r + 1, trim_wh[1] + 1);
  // the lip's window, its chamfer, the accent groove
  translate([0, 0, z_front - 1]) cylinder(r=glass_d/2 - lip_over, h=lip_t + 2);
  translate([0, 0, z_front - 0.01]) cylinder(r1=glass_d/2 - lip_over + 0.9, r2=glass_d/2 - lip_over, h=0.9);
  translate([0, 0, z_front - 0.01]) ring(bore_r + iw/2 - groove[0]/2, bore_r + iw/2 + groove[0]/2, groove[1] + 0.01);
  // the bore, behind the lip
  cylinder(r=bore_r, h=shell_len + 1);
  // the key's groove, from the back rim to the carrier
  rotate(key_a - 90) translate([-key_w/2 - 0.2, bore_r - 0.5, z_carrier - 0.2]) cube([key_w + 0.4, key_d + 0.7, shell_len]);
  // the 4 cover screws: holes through the wall, flat seats for the pan heads
  for (a = screw_ang) {
    radial_hole(a, z_screw, 3.4, 80);
    rotate(a) translate([bore_r + 3.5, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=6.2, h=20, $fn=32);
  }
  if (with_icons) for (i = [0:n_ic - 1]) {
    // the chamber, the icon through the skin, the LED, and a window in the bore's wall behind (to fit the LED from inside)
    ring_box(icon_a(i), cell_w, bore_r + iw - 0.01, icon_r + cell_h/2, z_cell0, z_cell1);
    translate([0, 0, z_front - 0.1]) linear_extrude(face_skin + 0.2) at_icon(i) icon2d(icons[i]);
    rotate(icon_a(i)) translate([icon_r, 0, z_cell1 - 0.1]) cylinder(d=led_d, h=cell_back + 0.2, $fn=32);
    ring_box(icon_a(i), cell_w, bore_r - 1, bore_r + iw + 0.01, z_cell1 + cell_back + 1, cav_z1 - 0.5);
  }
  // the logo, engraved, centred above the screen
  translate([0, logo_y, z_front - 0.01]) linear_extrude(logo_depth + 0.01) logo2d();
  // the GPS antenna's window (it goes in from inside, then lies on the bore's wall behind the logo)
  ring_box(gps_a, gps_patch[0] + 1, bore_r - 1, bore_r + iw + 0.01, z_front + ow + 0.5, cav_z1 - 0.5);
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
  // the skirt: notches top and bottom for the wires (the LEDs', the GPS antenna's, the GX12 socket's)
  for (a = [90, 270]) rotate(a - 90) translate([-9, bore_r - 5, z_carrier + carrier_t + 1]) cube([18, 6, z_cov - z_carrier]);
}
// The GPS module and the CAN board are fixed to the carrier's back with double-sided foam tape (no holes: their
// boards vary). The patch antenna sits in the face ring's hollow.

// ------------------------- COVER --------------------------------------
gx12_y = bore_r - 0.15 - cover_ring - 9;             // the GX12 socket, at the top of the cover (its plug clears the bike's clamp)
// The back logo's free area: below the GX12 socket, above the mount (the cradle's bridge or the joint).
back_top = gx12_y - gx12_d/2 - 2;
back_bot = mount == "stalk" ? -gp_drop + gp_r + 2 : cradle_bolt[1] + bridge[1]/2 + 2;
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
      // hollow inside the plug (a ring, 7 mm wide, carries the inserts)
      translate([0, 0, z_cov - 1]) cylinder(r=bore_r - 0.15 - cover_ring, h=cover_plug + 1);
    }
    if (mount == "stalk")     // GoPro-style 3 fingers
      for (x = gp_fingers3) translate([x - gp_finger_t/2, -gp_drop, shell_len + cover_back]) rotate([0, 90, 0])
        hull() { translate([-gp_reach, 0, 0]) cylinder(r=gp_r, h=gp_finger_t, $fn=48); translate([0, -gp_r - 2, 0]) cube([0.01, 2*gp_r + 4, gp_finger_t]); }
    else                      // 2 bosses inside, for the cradle's M4 inserts
      for (sx = [-1, 1]) translate([sx*cradle_bolt[0], cradle_bolt[1], shell_len - m4_insert_l - 1]) cylinder(d=10, h=m4_insert_l + 1.01, $fn=40);
  }
  // heat-set inserts for the 4 radial screws
  for (a = screw_ang) rotate(a) translate([bore_r - 0.15 - insert_l, 0, z_screw]) rotate([0, 90, 0]) cylinder(d=insert_d, h=insert_l + 1, $fn=32);
  if (mount == "stalk") translate([-20, -gp_drop, shell_len + cover_back + gp_reach]) rotate([0, 90, 0]) cylinder(d=gp_hole, h=40, $fn=32);
  else for (sx = [-1, 1]) translate([sx*cradle_bolt[0], cradle_bolt[1], shell_len - m4_insert_l]) cylinder(d=m4_insert_d, h=m4_insert_l + cover_back + 1, $fn=32);
  // GX12 4-pin socket
  translate([0, gx12_y, shell_len - 1]) cylinder(d=gx12_d, h=cover_back + 2, $fn=48);   // its nut (15 mm) inside the ring
  // the back logo, engraved (seen from behind the head, so not mirrored)
  if (back_logo_text != "" || back_logo_file != "")
    translate([0, back_logo_y, shell_len + cover_back - back_logo_depth]) linear_extrude(back_logo_depth + 0.01) back_logo2d();
}

// The trim ring: glued into the face's rebate, its outer front edge rounded.
module trim_ring() translate(hc) rotate_extrude($fn=240) translate([face_r - trim_wh[0] + 0.15, z_front])
  offset(r=0.6, $fn=12) offset(delta=-0.6) square([trim_wh[0] - 0.15, trim_wh[1]]);
// The GPS antenna, in the face ring's hollow, lying on the bore's wall.
module gps_patch() color([0.85, 0.8, 0.55]) rotate(gps_a - 90) translate([-gps_patch[0]/2, bore_r + iw + 0.2, z_front + ow + 0.3]) cube([gps_patch[0], gps_patch[2], gps_patch[1]]);
// The lit icons, for the pictures: resin-filled icon windows.
module back_logo_fill() if (back_logo_text != "" || back_logo_file != "")
  color([0.8, 0.81, 0.84]) translate([0, back_logo_y, shell_len + cover_back - back_logo_depth + 0.02]) linear_extrude(back_logo_depth) offset(-0.03) back_logo2d();
module logo_fill() color([0.8, 0.81, 0.84]) translate([0, logo_y, z_front - 0.02]) linear_extrude(logo_depth) offset(-0.03) logo2d();   // painted silver (pictures)
module icons_lit() if (with_icons) for (i = [0:n_ic - 1]) color(icon_colour(icons[i])) translate([0, 0, z_front - 0.02]) linear_extrude(face_skin) at_icon(i) offset(-0.05) icon2d(icons[i]);

// ------------------------- FOAM RING ----------------------------------
module lip_gasket() ring(glass_d/2 - lip_over + 0.3, glass_d/2 - 0.3, gasket_t);   // hidden under the lip

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

// ------------------------- THE CRADLE (mount = "bar") ------------------
// In the cradle's frame: the bar along x through the origin, y forward, z up, before the tilt (the whole cradle and
// the head turn about the bar together). The head's back face is at y = -head_back.
cr_bolt_z = head_up + cradle_bolt[1];               // the cradle bolts' height
cr_ear = cl_r + 6;                                  // the clamp caps' bolt ears reach this far fore and aft
module cradle() difference() {
  union() {
    for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) {
      clamp_body(true, false);                                       // the upper half of a bar clamp
      // the arm: over the clamp's rear bolt ear, then down behind it to the bridge
      hull() {
        translate([-clamp_w/2, -cl_r + 4, 1]) cube([clamp_w, 0.01, cl_r - 3]);
        translate([-clamp_w/2, -cr_ear - 2, 6.5]) cube([clamp_w, 2, 6]);
      }
      hull() {
        translate([-clamp_w/2, -cr_ear - 2, 6.5]) cube([clamp_w, 2, 6]);
        translate([-clamp_w/2, -head_back, cr_bolt_z - bridge[1]/2]) cube([clamp_w, bridge[0], bridge[1]]);
      }
    }
    translate([-cradle_span/2, -head_back, cr_bolt_z - bridge[1]/2]) cube([cradle_span, bridge[0], bridge[1]]);   // the bridge
  }
  rotate([0, 90, 0]) cylinder(d=bar_d + 2*clamp_rubber, h=cradle_span + clamp_w + 2, center=true);
  for (sx = [-1, 1]) translate([sx*cradle_bolt[0], -head_back - 1, cr_bolt_z]) rotate([-90, 0, 0]) {
    cylinder(d=4.5, h=bridge[0] + 2, $fn=24);
    translate([0, 0, bridge[0] - 1.5]) cylinder(d=8, h=5, $fn=32);                 // the bolt heads, on the bar side
  }
}
module cradle_cap() clamp_body(false);              // 2 of them: the clamps' lower halves (as clamp_lower)
module bike_clamp_dummy() translate([-bike_clamp[0]/2, -bike_clamp[1]/2, -bar_d/2 - 4]) cube([bike_clamp[0], bike_clamp[1], bike_clamp[2] + bar_d/2 + 4]);

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
  if (mount == "stalk") translate([0, 0, riser]) rotate([-tilt, 0, 0]) multmatrix(HEAD_TO_BIKE) translate([0, gp_drop, -joint_z]) children();
  else rotate([-tilt, 0, 0]) translate([0, -head_back - (shell_len + cover_back), head_up]) multmatrix(HEAD_TO_BIKE) children();
}
module mount_parts(e=0) {
  if (mount == "stalk") { color([0.25, 0.26, 0.28]) { clamp_upper(); clamp_lower(); } }
  else rotate([-tilt, 0, 0]) color([0.25, 0.26, 0.28]) {
    translate([0, e*0.6, 0]) cradle();
    for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, -e*0.6]) cradle_cap();
  }
}
module head_on_clamp(e=0) {
  if (mount == "bar") head_placed() translate([0, 0, -e*1.2]) head_parts(e);
  else head_placed() head_parts(e);
  mount_parts(e);
  color([0.75, 0.75, 0.75, 0.6]) rotate([0, 90, 0]) cylinder(d=bar_d, h=220, center=true);
  if (mount == "bar") color([0.55, 0.56, 0.58, 0.35]) bike_clamp_dummy();
}

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
else if (PART == "cradle") rotate([90, 0, 0]) translate([0, head_back, 0]) cradle();   // the bridge's back face on the bed
else if (PART == "cradle_cap") rotate([180, 0, 0]) cradle_cap();
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
  intersection() { head_shell(); lip_gasket(); }
}
else if (PART == "check_clamp") intersection() { clamp_upper(); clamp_lower(); }
// The head (every part) vs the mount, the bar and the bike's own handlebar clamp, at this tilt: must be empty
// (with mount = "bar" the cover only touches the cradle's bridge, where they bolt together).
else if (PART == "check_mount") {
  intersection() {
    head_placed() union() { head_shell(); head_cover(); }
    union() {
      rotate([0, 90, 0]) cylinder(d=bar_d, h=220, center=true);
      if (mount == "stalk") { clamp_upper(); clamp_lower(); }
      else { bike_clamp_dummy(); rotate([-tilt, 0, 0]) { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); } }
    }
  }
}
// The cradle vs its caps and the bike's handlebar clamp: must be empty.
else if (PART == "check_cradle") {
  intersection() { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); }
  intersection() { rotate([-tilt, 0, 0]) union() { cradle(); for (sx = [-1, 1]) translate([sx*cradle_span/2, 0, 0]) cradle_cap(); } bike_clamp_dummy(); }
}
else if (PART == "none") { }

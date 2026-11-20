// =============================================================================
// Meteor 350 display pod — central parameters (v4)
// Units: millimetres. All parts include this file.
//
// Source tags used on every input value:
//   [OFFICIAL]   Shenzhen Jingcai ESP32-2424S012 spec sheet / structure drawing
//                (copies in reference/vendor/)
//   [OTHER-MEAS] Measured by another maker on the same board
//                (github.com/mk0000001/ESP32-2424S012-MagSafe-Case)
//   [PHOTO]      Scaled from the vendor rear-layout image (USB-C = 8.94 mm ref.)
//   [STANDARD]   Published standard / catalogue dimension
//   [PROVISIONAL] Estimate — MUST be verified before the final print
//   [DESIGN]     Design choice (not a measurement)
//
// See documentation/measurements.md for the full list and verification status.
//
// COORDINATE SYSTEMS
//   Pod frame: Z = display axis, +Z points at the rider. z = 0 is the housing
//   rear face (= rear-cover front face). Angles are viewed from the FRONT
//   (looking at the display): 0° = right, 90° = top, 270° = bottom.
//   The USB-C port is at 270° and points down when the pod is locked.
//   Receiver frame = pod frame when the pod is in the LOCKED position.
// =============================================================================

$fn = 120;
eps = 0.01;

// ----------------------------------------------------------------------------
// Display board: ESP32-2424S012 (sold as "Electrobot ESP32-C3 1.28in")
// ----------------------------------------------------------------------------
board_d              = 37.0;   // [OFFICIAL] outline diameter "37.00"
board_total_h        = 38.5;   // [OFFICIAL] incl. USB tab "38.50"
board_tab_w          = 14.23;  // [OFFICIAL] USB tab width "14.23"
board_tab_shoulder_h = 3.74;   // [OFFICIAL] tab height from shoulder "3.74"
board_tab_edge_r     = board_total_h - board_d / 2;   // 20.0 from centre
pcb_t                = 1.2;    // [PROVISIONAL] PCB thickness (OTHER-MEAS model)
display_active_d     = 32.4;   // [OFFICIAL] effective display area Φ32.4
display_glass_d      = 36.0;   // [PROVISIONAL] glass outline — not published
glass_to_pcb         = 3.7;    // [OTHER-MEAS] 4.0 free / 3.0 pressed; 3.7 capture
rear_component_h     = 4.0;    // [PROVISIONAL] tallest rear part incl. mated battery plug
board_radial_clear   = 0.3;    // [DESIGN] bore clearance per side

// USB-C receptacle (mid-mount on the tab, on the board's rear side)
usb_angle            = 270;    // [OFFICIAL] layout drawing
usb_offset_x         = -2.4;   // [PHOTO] lateral offset in front view
usb_w                = 8.94;   // [STANDARD] USB-C receptacle shell width
usb_h                = 3.26;   // [STANDARD] USB-C receptacle shell height
usb_center_behind_pcb = 1.2;   // [OTHER-MEAS] centre behind PCB rear face
usb_plug_w           = 12.5;   // [PROVISIONAL] cable over-mould width — check your cable
usb_plug_h           = 7.0;    // [PROVISIONAL] cable over-mould height
usb_front_wall       = 0.6;    // [DESIGN] wall between receptacle face and plug recess

// Rear-side parts (angles in FRONT view; layout drawing is a rear view, mirrored)
switch_angle         = 175;    // [PHOTO] slide power switch at board edge
switch_center_behind_pcb = 1.5;// [PROVISIONAL]
switch_nub_out       = 1.0;    // [PROVISIONAL] actuator protrusion past board edge
switch_access        = true;   // [DESIGN] slot in housing wall to operate the switch
switch_slot_w        = 5.0;    // [PROVISIONAL] tangential (slide direction)
switch_slot_h        = 2.2;    // [PROVISIONAL] axial
rst_angle  = 40;  rst_r  = 16.5;   // [PHOTO] reset button, rear-facing
boot_angle = 135; boot_r = 15.0;   // [PHOTO] boot button, rear-facing
button_relief_d      = 6.0;        // [DESIGN] hole in retainer + foam over buttons
bat_conn_angle = 215; bat_conn_r = 13.5;   // [PHOTO] JST1.25-2P battery socket

// ----------------------------------------------------------------------------
// Battery (user requirement: small LiPo inside the pod)
// ----------------------------------------------------------------------------
battery_t            = 4.0;    // [PROVISIONAL] default 402030 (4 x 20 x 30, ~200-250 mAh)
battery_w            = 20.0;   // [PROVISIONAL]
battery_l            = 30.0;   // [PROVISIONAL] incl. protection PCB
battery_side_clear   = 0.5;    // [DESIGN] per side
battery_swell_clear  = 1.0;    // [DESIGN] axial room for swelling — never clamp the cell

// ----------------------------------------------------------------------------
// Front face, protective window (lens) and display seat
// ----------------------------------------------------------------------------
aperture_d           = display_active_d + 1.0;   // [DESIGN] 0.5 mm per side over active area
lens_bond_land       = 1.4;    // [DESIGN] adhesive land width under the lens
lens_d               = aperture_d + 2 * lens_bond_land;  // 36.2 polycarbonate disc
lens_t               = 1.0;    // [DESIGN] 1.0 mm polycarbonate
lens_adhesive_t      = 0.25;   // [DESIGN] adhesive ring / clear RTV bead
lens_clear           = 0.15;   // [DESIGN] radial clearance in recess
protective_rim_h     = 0.4;    // [DESIGN] rim stands 0.4 mm proud of the lens
front_ledge_t        = 1.0;    // [DESIGN] structural ring between lens and display glass
display_gasket_t     = 0.35;   // [DESIGN] 0.5 mm foam ring, compressed
ledge_chamfer        = 0.7;    // [DESIGN] 45° under-ledge chamfer (print overhang)

// ----------------------------------------------------------------------------
// Housing (Part A)
// ----------------------------------------------------------------------------
housing_front_od     = 45.0;   // [DESIGN]
housing_rear_od      = 52.0;   // [DESIGN] driven by insert walls around Ø37.6 bore
front_edge_r         = 2.0;    // [DESIGN]
rear_edge_chamfer    = 0.5;    // [DESIGN]
bore_d               = board_d + 2 * board_radial_clear;     // 37.6
tab_pocket_clear     = 0.3;    // [DESIGN] around the tab sides
fpc_fold_clear       = 0.6;    // [DESIGN] radial room for the display FPC fold at the tab

// Board retainer plate + foam (pushes the board forward onto the front ledge)
retainer_t           = 1.2;    // [DESIGN]
retainer_foam_t      = 1.0;    // [DESIGN] 1.5 mm EVA/PORON foam, compressed to 1.0
retainer_push_h      = 1.5;    // [DESIGN] retainer rear face above housing rear face
retainer_clear       = 0.2;    // [DESIGN] radial

// Rear cover fasteners: M2 x 8 socket cap screws into M2 x 3 heat-set inserts
cover_screw_r        = 22.6;   // [DESIGN]
cover_screw_angles   = [45, 200, 300];  // [DESIGN] uneven = cover fits one way only
insert_hole_d        = 3.2;    // [STANDARD] M2 heat-set insert hole (check insert brand)
insert_hole_depth    = 4.0;
cover_screw_clear_d  = 2.4;
cover_screw_head_d   = 4.2;    // M2 SHCS head 3.8 + clearance
cover_screw_head_h   = 2.2;

// ----------------------------------------------------------------------------
// Rear cover (Part B): battery bay + gasket seat + male bayonet
// ----------------------------------------------------------------------------
cover_od             = housing_rear_od;
cover_end_wall       = 1.2;    // [DESIGN] wall behind the battery
cover_rear_edge_r    = 1.0;    // [DESIGN]
gasket_t             = 1.0;    // [DESIGN] 1.0 mm silicone/EPDM sheet or TPU print
gasket_pocket_depth  = 0.7;    // [DESIGN] -> 30 % compression, hard stop at outer rim
gasket_id            = 38.8;   // [DESIGN]
gasket_od            = 50.4;   // [DESIGN]
gasket_pocket_id     = 38.6;
gasket_pocket_od     = 50.8;
push_post_angles     = [60, 120, 240, 300];  // [DESIGN] outside the battery footprint
push_post_r          = 17.0;
push_post_size       = 2.6;

// ----------------------------------------------------------------------------
// Bayonet (male on cover, female receiver = Part C)
// Lock = push in, rotate 30° CLOCKWISE (seen from the display side).
// ----------------------------------------------------------------------------
spigot_d             = 34.0;   // [DESIGN]
spigot_wall          = 2.5;    // [DESIGN] hollow spigot
spigot_len           = 6.0;    // [DESIGN] below the cover rear face
lug_count            = 3;
lug_angles           = [90, 210, 330];   // [DESIGN] LOCKED positions
lug_widths           = [9.0, 7.0, 7.0];  // [DESIGN] wide lug at top = one-way keying
lug_h                = 2.5;    // [DESIGN] axial
lug_radial           = 2.4;    // [DESIGN] beyond spigot surface
lug_root_overlap     = 0.5;    // [DESIGN] fuse into spigot wall
lock_rotation        = 30;     // [DESIGN]
entry_clear          = 0.4;    // [DESIGN] per side, slot and bore
track_clear          = 0.3;    // [DESIGN] per side, tangential
track_radial_clear   = 0.35;   // [DESIGN]
lock_gap             = 0.3;    // [DESIGN] spring lifts pod this far when locked
floor_clear          = 0.3;    // [DESIGN] below lug at full insertion

// Receiver (Part C)
receiver_id          = spigot_d + 2 * entry_clear;   // 34.8
receiver_od          = 46.0;   // [DESIGN]
receiver_base_t      = 4.0;    // [DESIGN]
receiver_lead_chamfer = 0.8;   // [DESIGN]
receiver_mount_screw_angles = [45, 150, 285];  // [DESIGN] radial M3 thread-forming screws (solid sectors)
receiver_mount_screw_z = 3.0;  // above receiver bottom (hole must not touch cup rim or floor)
receiver_pilot_d     = 2.5;    // [STANDARD] M3 thread-forming pilot in PETG/ASA
receiver_key_angle   = 90;     // [DESIGN] anti-rotation key
receiver_drain_angle = 270;    // [DESIGN] lowest point when mounted

// Spring-ball detent: commercial M4 stainless ball plunger, axial, in the receiver
// land; ball pushes the pod OUT, preloading the lugs against the track ceilings
// (no rattle) and clicking into a dimple on the cover at the locked position.
detent_angle         = 172;    // [DESIGN] solid sector between tracks
detent_r             = 20.2;   // [DESIGN]
detent_tap_d         = 3.3;    // [STANDARD] M4 tap drill — tap the printed hole
detent_ball_d        = 2.5;    // [PROVISIONAL] verify purchased plunger
detent_dimple_depth  = 0.35;   // [DESIGN]
detent_preload       = 0.15;   // [DESIGN] set by screwing plunger in/out
plunger_stroke_min   = detent_preload + detent_dimple_depth + lock_gap; // required stroke

// ----------------------------------------------------------------------------
// Handlebar mount (Part D)
// Mount frame: X = handlebar axis, Y = forward, Z = up, origin on bar axis.
// ----------------------------------------------------------------------------
bar_d                = 22.2;   // [PROVISIONAL] Meteor 350 centre section NOT measured
bar_shim_t           = 1.0;    // [DESIGN] rubber shim (EPDM / inner-tube strip)
bar_bore_d           = bar_d + 2 * bar_shim_t * 0.75;   // 25 % shim compression
clamp_split_gap      = 1.5;    // [DESIGN] gap between halves so the clamp can grip
clamp_w              = 22.0;   // [PROVISIONAL] along bar — check free bar length
clamp_wall           = 4.5;    // [DESIGN]
clamp_bolt_d         = 5.4;    // M5 clearance
clamp_bolt_offset    = bar_bore_d / 2 + 4.2;   // bolt axis from bar axis (Y)
clamp_bolt_head_d    = 9.0;    // M5 SHCS head 8.5
clamp_bolt_head_h    = 5.5;
clamp_nut_af         = 8.0;    // [STANDARD] M5 nyloc nut across flats
clamp_nut_h          = 5.2;
clamp_nut_z0         = 6.0;    // [DESIGN] nut pocket start above split plane centre
clamp_half_y         = clamp_bolt_offset + 5.5;
clamp_half_z         = bar_bore_d / 2 + clamp_wall;

display_tilt         = 40;     // [PROVISIONAL] pod axis from vertical, toward rider
cup_offset_y         = -8.0;   // [PROVISIONAL] cup centre behind (-) / ahead (+) of bar
cup_floor_z          = 26.0;   // [PROVISIONAL] cup floor centre above bar axis
cup_depth            = 5.0;    // [DESIGN]
cup_clear            = 0.15;   // [DESIGN] receiver fit in cup (radial)
cup_wall_od          = housing_rear_od;  // cup outside = pod rear OD (visual continuity)
cup_floor_t          = 3.0;    // [DESIGN]
cup_screw_clear_d    = 3.4;    // M3
key_rib_w            = 3.6;
key_rib_depth        = 1.3;

// ----------------------------------------------------------------------------
// Derived Z stack (pod frame, z = 0 at housing rear face)
// ----------------------------------------------------------------------------
lens_recess_d     = lens_d + 2 * lens_clear;
lens_recess_depth = protective_rim_h + lens_t + lens_adhesive_t;
z_ret_rear        = retainer_push_h;
z_ret_front       = z_ret_rear + retainer_t;
z_comp_rear       = z_ret_front + retainer_foam_t;
z_pcb_rear        = z_comp_rear + rear_component_h;
z_pcb_front       = z_pcb_rear + pcb_t;
z_glass_front     = z_pcb_front + glass_to_pcb;
z_ledge_rear      = z_glass_front + display_gasket_t;
z_lens_seat       = z_ledge_rear + front_ledge_t;
housing_depth     = z_lens_seat + lens_recess_depth;
z_usb             = z_pcb_rear - usb_center_behind_pcb;
z_switch          = z_pcb_rear - switch_center_behind_pcb;

// Rear cover stack (negative z)
z_bay_floor       = z_ret_rear - (battery_t + battery_swell_clear);
z_cover_rear      = z_bay_floor - cover_end_wall;
z_spigot_tip      = z_cover_rear - spigot_len;
pod_visible_depth = housing_depth - z_cover_rear;

// Bayonet / receiver stack (receiver frame: z = 0 at top land, downward negative)
lug_r_in          = spigot_d / 2 - lug_root_overlap;
lug_r_out         = spigot_d / 2 + lug_radial;
track_r_out       = lug_r_out + track_radial_clear;
ceiling_t         = spigot_len - lug_h - lock_gap;          // material above the track
z_track_ceiling   = -ceiling_t;
z_track_floor     = -(spigot_len + floor_clear);
receiver_h        = -z_track_floor + receiver_base_t;

// Housing outer radius at height z (straight taper, ignoring edge rounding)
function housing_r_at(z) =
    housing_rear_od / 2 - (housing_rear_od - housing_front_od) / 2 * (z / housing_depth);

// ----------------------------------------------------------------------------
// Sanity checks — rendering stops if a rule is broken
// ----------------------------------------------------------------------------
assert(ceiling_t >= 3.0, "Bayonet: material above the track is too thin");
assert(cover_screw_r - insert_hole_d / 2 - bore_d / 2 >= 1.5, "Insert too close to bore");
assert(housing_rear_od / 2 - cover_screw_r - insert_hole_d / 2 >= 1.5, "Insert too close to outside");
assert(cover_screw_r - cover_screw_head_d / 2 > spigot_d / 2 + 0.2, "Cover screw head hits spigot");
assert(detent_r - detent_tap_d / 2 - receiver_id / 2 >= 1.0, "Detent hole too close to bore");
assert(receiver_od / 2 - detent_r - detent_tap_d / 2 >= 1.0, "Detent hole too close to outside");
assert(sqrt(pow(battery_w + 2 * battery_side_clear, 2) + pow(battery_l + 2 * battery_side_clear, 2)) < bore_d,
       "Battery does not fit inside the housing bore");
assert(sqrt(pow(push_post_r + push_post_size / 2, 2) + pow(push_post_size / 2, 2)) < bore_d / 2 - retainer_clear,
       "Retainer legs outside housing bore");
assert(lens_recess_d / 2 + 2.5 < housing_front_od / 2, "Front wall around lens too thin");

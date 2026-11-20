// =============================================================================
// Front face: outer shell profile, protective window (lens) seat, display ledge
//
//   outside ──► 0.4 mm protective rim
//               1.0 mm polycarbonate lens, bonded on a 1.4 mm land
//               1.0 mm structural ledge with a Ø33.4 aperture
//               0.5 mm foam ring (0.35 compressed)
//               display glass
//
// Visible bezel = housing front face ring + the lens's own black border.
// The ledge (structural material) is hidden behind the lens.
// =============================================================================
include <parameters.scad>
use <lib.scad>

// Outer solid of the housing: straight taper Ø52 (rear) -> Ø45 (front),
// 2 mm front edge radius, small rear chamfer. Printed rear-face-down, so the
// rounded front edge is on top and needs no support.
module housing_outer_solid() {
    R_rear  = housing_rear_od / 2;
    R_front = housing_front_od / 2;
    hull() {
        cylinder(r = R_rear - rear_edge_chamfer, h = eps);
        translate([0, 0, rear_edge_chamfer]) cylinder(r = R_rear, h = eps);
        translate([0, 0, housing_depth - front_edge_r])
            rotate_extrude() translate([R_front - front_edge_r, 0]) circle(r = front_edge_r);
    }
}

// Negative volume for the front: lens recess + viewing aperture.
module front_window_cuts() {
    // Lens recess (window seat). Its floor is the adhesive land.
    translate([0, 0, z_lens_seat]) cylinder(d = lens_recess_d, h = lens_recess_depth + 1);
    // Viewing aperture through the ledge
    translate([0, 0, z_ledge_rear - 1]) cylinder(d = aperture_d, h = front_ledge_t + 2);
}

// Negative volume for the main board bore, with a 45° chamfer left under the
// ledge so the ledge overhang is only ~1.4 mm when printed rear-face-down.
module board_bore_cut() {
    translate([0, 0, -1]) cylinder(d = bore_d, h = z_ledge_rear - ledge_chamfer + 1);
    translate([0, 0, z_ledge_rear - ledge_chamfer])
        cylinder(d1 = bore_d, d2 = bore_d - 2 * ledge_chamfer, h = ledge_chamfer);
    // Region inside the chamfer, up to the ledge
    translate([0, 0, z_ledge_rear - ledge_chamfer - eps])
        cylinder(d = bore_d - 2 * ledge_chamfer, h = ledge_chamfer + eps);
}

// ---- Protective window and foam ring (cut/bought parts) -----------------------
module lens_2d()            { circle(d = lens_d); }
module lens()               { translate([0, 0, z_lens_seat + lens_adhesive_t]) cylinder(d = lens_d, h = lens_t); }
module display_gasket_2d()  { difference() { circle(d = display_glass_d - 0.4); circle(d = aperture_d + 0.4); } }

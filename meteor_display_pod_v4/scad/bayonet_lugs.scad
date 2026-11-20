// =============================================================================
// Male bayonet: hollow spigot + three lugs (part of the rear cover)
//
// The lugs are SOLIDLY joined to the spigot (0.5 mm root overlap). The v3 lugs
// floated 1 mm clear of the spigot, and the whole spigot floated 0.1 mm clear of
// the pod, so neither was attached.
//
// Lug faces:
//   top face (toward the pod) = load face: bears on the receiver track ceiling
//                               under spring preload and any pull-out force.
//   bottom face (spigot tip)  = flush with the tip.
// The wide lug (9 mm, at 90°) only fits its own wide entry slot, so the pod can
// only go on one way: display upright, USB-C down.
// =============================================================================
include <parameters.scad>
use <lib.scad>

// Lug solids in pod frame, tip at z = z_tip
module lugs(z_tip = z_spigot_tip, widen = 0) {
    for (i = [0 : lug_count - 1])
        radial_block(lug_angles[i], lug_r_in, lug_r_out, lug_widths[i] + 2 * widen,
                     z_tip, z_tip + lug_h);
}

// Hollow spigot below the cover rear face, with lugs at its tip
module spigot_with_lugs() {
    difference() {
        translate([0, 0, z_spigot_tip]) cylinder(d = spigot_d, h = spigot_len + eps);
        translate([0, 0, z_spigot_tip - 1]) cylinder(d = spigot_d - 2 * spigot_wall, h = spigot_len + 1);
    }
    lugs();
}

// Spherical dimple the detent ball clicks into at the locked position (negative volume)
module detent_dimple() {
    br = detent_ball_d / 2;
    at_polar(detent_angle, detent_r, z_cover_rear - (br - detent_dimple_depth))
        sphere(r = br, $fn = 32);
}

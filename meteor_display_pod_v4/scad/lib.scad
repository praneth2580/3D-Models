// Shared helper modules (no geometry of its own)

// Place children at polar position (angle in degrees, radius) in the XY plane,
// rotated so local +X points radially outward.
module at_polar(angle, r, z = 0) {
    rotate([0, 0, angle]) translate([r, 0, z]) children();
}

// Rounded rectangle, centred, in 2D
module rounded_rect(size, r) {
    rr = min(r, size[0] / 2 - 0.01, size[1] / 2 - 0.01);
    offset(r = rr) square([size[0] - 2 * rr, size[1] - 2 * rr], center = true);
}

// Radial block: spans radius r0..r1, tangential width w (centred on the angle),
// z0..z1. Used for lugs, slots and pockets.
module radial_block(angle, r0, r1, w, z0, z1) {
    rotate([0, 0, angle])
        translate([r0, -w / 2, z0]) cube([r1 - r0, w, z1 - z0]);
}

// Sweep a radial block from angle a0 to a1 (hull of steps): a curved track.
module arc_sweep(a0, a1, r0, r1, w, z0, z1, step = 2) {
    n = max(1, ceil(abs(a1 - a0) / step));
    for (i = [0 : n - 1])
        hull() {
            radial_block(a0 + (a1 - a0) * i / n,       r0, r1, w, z0, z1);
            radial_block(a0 + (a1 - a0) * (i + 1) / n, r0, r1, w, z0, z1);
        }
}

// Ring (annulus) in 3D
module ring(od, id, h) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, -0.01]) cylinder(d = id, h = h + 0.02);
    }
}

// Hexagon prism given across-flats size (for nut pockets)
module hex_prism(af, h) {
    cylinder(d = af / cos(30), h = h, $fn = 6);
}

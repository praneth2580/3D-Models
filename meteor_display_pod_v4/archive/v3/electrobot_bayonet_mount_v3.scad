/*
 Electrobot ESP32-C3 1.28in round display - central handlebar mount
 Parametric prototype: low-bezel pod + 3-lug 30-degree bayonet + metal spring-ball detent
 Units: mm. Verify exact PCB/USB/button/bar dimensions. Print fit_coupon first.
 PART: assembly | pod | rear_cover | receiver | clamp_lower | clamp_upper | fit_coupon | male_coupon
 Display faces +Z; handlebar axis X. Pod spigot points -Z into receiver.
*/
$fn=96;
part="assembly";

// PCB/display: provisional common board-family envelope, NOT verified for your revision
pcb_x=42.0; pcb_y=42.0; pcb_h=9.8; pcb_clear=0.45;
visible_d=32.5; window_d=34.0;

// Pod
pod_d=66.0; pod_h=19.0; front_t=2.4; wall=2.6;
rear_cover_t=2.5; cover_screw_d=2.8; cover_head_d=5.0; cover_head_h=1.4;
cover_bolt_circle=28.5; cover_n=3;
cover_insert_d=4.0; cover_insert_depth=4.5; // M2.5 heat-set insert pockets
// Side access is deliberately adjustable until the exact board orientation is measured.
usb_enabled=true; usb_angle=270; usb_width=11.0; usb_height=6.0; usb_z=9.5;
buttons_enabled=false; button_angles=[225,315]; button_z=[9.5,9.5]; button_d=3.0;

// Male bayonet
spigot_d=35.8; spigot_h=7.0; lug_count=3;
lug_radial=4.2; lug_tangent=7.0; lug_axial=2.4;
lug_radius=spigot_d/2+lug_radial/2+1.0; // lug overlaps receiver wall by ~0.2 mm
lock_angle=30; entry_clear=0.40; track_clear=0.25;

// Female receiver
receiver_id=spigot_d+2*entry_clear;
receiver_wall=5.0; receiver_od=receiver_id+2*receiver_wall;
receiver_h=10.0; receiver_floor=2.2;
receiver_flange_d=70.0; receiver_flange_t=3.0;
oring_cs=1.5; oring_groove_depth=1.0; oring_center_r=(receiver_id/2+receiver_od/2)/2;
ramp_drop=0.4;
track_z=receiver_h-(spigot_h-lug_axial/2); // align track with lugs when pod seats
entry_depth=receiver_h-track_z+lug_axial/2+0.4;
track_width=lug_tangent+2*track_clear;

// Detent: use a commercial stainless spring-ball plunger, not a printed spring
// Example M5 body envelope only. Confirm exact purchased plunger dimensions/thread.
detent_tap_drill=4.2; detent_ball_d=2.5; // M5 tap drill; verify purchased plunger
detent_r=receiver_od/2-receiver_wall/2;
detent_z=receiver_flange_t+track_z-ramp_drop;
detent_angle=lock_angle;

// Centre handlebar clamp. Measure actual centre section before final print.
bar_d=22.2; bar_clear=0.25;
clamp_x=42.0; clamp_y=42.0; clamp_z=30.0;
clamp_bolt_d=5.2; clamp_bolt_span=34.0;

// Receiver-to-clamp fasteners
mount_bolt_d=4.3; mount_bolt_span=44.0; mount_boss_d=7.0; mount_boss_h=5.0;
explode=8;

module screw_pattern(r,n){for(i=[0:n-1]) rotate([0,0,i*360/n]) translate([r,0,0]) children();}
module radial_box(a,r,radial_len,tan_w,z,h){rotate([0,0,a]) translate([r,0,z]) cube([radial_len,tan_w,h],center=true);}
module arc_channel(a0,a1,r,radial_len,tan_w,z,h){hull(){for(a=[a0:2:a1]) radial_box(a,r,radial_len,tan_w,z,h); radial_box(a1,r,radial_len,tan_w,z,h);}}
module arc_channel_ramped(a0,a1,r,radial_len,tan_w,z0,z1,h){
 hull(){
  for(a=[a0:2:a1]){
   zz=z0+(z1-z0)*(a-a0)/(a1-a0);
   radial_box(a,r,radial_len,tan_w,zz,h);
  }
  radial_box(a1,r,radial_len,tan_w,z1,h);
 }
}
module pod_side_cut(a,radial_len,tan_w,z,h){
 rotate([0,0,a]) translate([pod_d/2-wall/2,0,z]) cube([radial_len,tan_w,h],center=true);
}

// POD: front/display face at +Z; rear service opening and bayonet point -Z
module pod(){
 difference(){
  union(){
   cylinder(d=pod_d,h=pod_h);
   // Rear spigot points down from z=0
   translate([0,0,-spigot_h]) cylinder(d=spigot_d,h=spigot_h);
   // Three radial lugs near spigot tip
   for(i=[0:lug_count-1]) rotate([0,0,i*360/lug_count])
    translate([lug_radius,0,-spigot_h+lug_axial/2]) cube([lug_radial,lug_tangent,lug_axial],center=true);
  }
  // PCB cavity opens from rear (z=0), leaving the thin front wall
  translate([-(pcb_x+2*pcb_clear)/2,-(pcb_y+2*pcb_clear)/2,-0.1])
   cube([pcb_x+2*pcb_clear,pcb_y+2*pcb_clear,pod_h-front_t+0.1]);
  // Narrow front window and shallow relief
  translate([0,0,pod_h-front_t-0.1]) cylinder(d=window_d,h=front_t+0.2);
  translate([0,0,pod_h-front_t-0.35]) cylinder(d=visible_d+1.0,h=0.5);
  // Cover screw holes from rear rim
  screw_pattern(cover_bolt_circle,cover_n) translate([0,0,-0.1]) cylinder(d=cover_insert_d,h=cover_insert_depth+0.1);
  // One radial detent notch on each lug's outer face; ball engages one of them at lock position
  for(i=[0:lug_count-1]) rotate([0,0,i*360/lug_count])
   translate([lug_radius+lug_radial/2-0.1,0,-spigot_h+lug_axial/2])
    rotate([0,90,0]) cylinder(d=detent_ball_d+0.35,h=1.2,center=true);
 }
 // PCB support ledges near rear corners. Adjust after board inspection.
 for(sx=[-1,1],sy=[-1,1])
  translate([sx*(pcb_x/2-2.8),sy*(pcb_y/2-2.8),3.8]) cube([5,5,1.2],center=true);
}

module rear_cover(){
 difference(){
  cylinder(d=pod_d-0.35,h=rear_cover_t);
  screw_pattern(cover_bolt_circle,cover_n){
   translate([0,0,-0.1]) cylinder(d=cover_screw_d,h=rear_cover_t+0.2);
   translate([0,0,rear_cover_t-cover_head_h]) cylinder(d=cover_head_d,h=cover_head_h+0.2);
  }
 }
}

// Receiver cup opens upward (+Z) to accept the pod spigot inserted downward.
module receiver(){
 difference(){
  union(){
   cylinder(d=receiver_flange_d,h=receiver_flange_t);
   translate([0,0,receiver_flange_t]) cylinder(d=receiver_od,h=receiver_h);
   for(x=[-mount_bolt_span/2,mount_bolt_span/2],y=[-mount_bolt_span/2,mount_bolt_span/2])
    translate([x,y,-mount_boss_h/2]) cylinder(d=mount_boss_d,h=mount_boss_h);
  }
  // Socket cavity
  translate([0,0,receiver_flange_t+receiver_floor]) cylinder(d=receiver_id,h=receiver_h-receiver_floor+0.3);
  // Three L-shaped channels: axial entry then 30-degree circumferential capture track
  for(i=[0:lug_count-1]){
   a=i*360/lug_count;
   radial_box(a,receiver_id/2+receiver_wall/2,receiver_wall+2,lug_tangent+2*entry_clear,
      receiver_flange_t+receiver_h-entry_depth/2,entry_depth);
   arc_channel_ramped(a,a+lock_angle,receiver_id/2+receiver_wall/2,receiver_wall+2,track_width,
      receiver_flange_t+track_z,receiver_flange_t+track_z-ramp_drop,lug_axial+2*track_clear);
  }
  // O-ring groove on the receiver's top sealing land (nominal 1.5 mm CS silicone O-ring)
  translate([0,0,receiver_flange_t+receiver_h-oring_groove_depth])
   difference(){
    cylinder(d=2*(oring_center_r+oring_cs/2),h=oring_groove_depth+0.1);
    translate([0,0,-0.05]) cylinder(d=2*(oring_center_r-oring_cs/2),h=oring_groove_depth+0.2);
   }
  // Radial M5 tapped bore for a stainless spring-ball plunger at locked position
  rotate([0,0,detent_angle]) translate([detent_r,0,detent_z]) rotate([0,90,0])
   cylinder(d=detent_tap_drill,h=receiver_wall+2.5,center=true);
  // Four M4 receiver-to-clamp fasteners
  for(x=[-mount_bolt_span/2,mount_bolt_span/2],y=[-mount_bolt_span/2,mount_bolt_span/2])
   translate([x,y,-mount_boss_h-0.2]) cylinder(d=mount_bolt_d,h=receiver_flange_t+mount_boss_h+0.4);
 }
}

// Two-piece split clamp, handlebar axis X, split at Z=0.
module clamp_lower(){
 difference(){
  translate([0,0,-clamp_z/4]) cube([clamp_x,clamp_y,clamp_z/2],center=true);
  rotate([0,90,0]) cylinder(d=bar_d+2*bar_clear,h=clamp_x+2,center=true);
  for(y=[-clamp_bolt_span/2,clamp_bolt_span/2]) translate([0,y,-clamp_z/4]) cylinder(d=clamp_bolt_d,h=clamp_z/2+1,center=true);
 }
}
module clamp_upper(){
 difference(){
  union(){
   translate([0,0,clamp_z/4]) cube([clamp_x,clamp_y,clamp_z/2],center=true);
   // Raised flat seat for the receiver flange
   translate([0,0,clamp_z/2+2.5]) cube([receiver_flange_d,receiver_flange_d,5],center=true);
  }
  rotate([0,90,0]) cylinder(d=bar_d+2*bar_clear,h=clamp_x+2,center=true);
  for(y=[-clamp_bolt_span/2,clamp_bolt_span/2]) translate([0,y,clamp_z/4]) cylinder(d=clamp_bolt_d,h=clamp_z/2+1,center=true);
  for(x=[-mount_bolt_span/2,mount_bolt_span/2],y=[-mount_bolt_span/2,mount_bolt_span/2]){
   translate([x,y,clamp_z/2+2.5]) cylinder(d=mount_bolt_d,h=6,center=true);
   // M4 hex nut pocket opens from underside of receiver seat
   translate([x,y,clamp_z/2+0.1]) cylinder(d=7.2,h=3.4,$fn=6);
  }
 }
}

module fit_coupon(){
 // Small test socket for tuning FDM clearance before printing full receiver.
 difference(){
  cylinder(d=receiver_od+8,h=receiver_h+receiver_flange_t);
  translate([0,0,receiver_flange_t+receiver_floor]) cylinder(d=receiver_id,h=receiver_h);
  for(i=[0:lug_count-1]){
   a=i*360/lug_count;
   radial_box(a,receiver_id/2+receiver_wall/2,receiver_wall+2,lug_tangent+2*entry_clear,
      receiver_flange_t+receiver_h-entry_depth/2,entry_depth);
   arc_channel_ramped(a,a+lock_angle,receiver_id/2+receiver_wall/2,receiver_wall+2,track_width,
      receiver_flange_t+track_z,receiver_flange_t+track_z-ramp_drop,lug_axial+2*track_clear);
  }
 }
}

module male_coupon(){
 // Matching male spigot-only coupon for testing insertion and 30-degree twist fit.
 difference(){
  union(){
   translate([0,0,-spigot_h]) cylinder(d=spigot_d,h=spigot_h);
   for(i=[0:lug_count-1]) rotate([0,0,i*360/lug_count])
    translate([lug_radius,0,-spigot_h+lug_axial/2]) cube([lug_radial,lug_tangent,lug_axial],center=true);
  }
  for(i=[0:lug_count-1]) rotate([0,0,i*360/lug_count])
   translate([lug_radius+lug_radial/2-0.1,0,-spigot_h+lug_axial/2])
    rotate([0,90,0]) cylinder(d=detent_ball_d+0.35,h=1.2,center=true);
 }
}

module assembly(){
 pod();
 // Rear cover below the pod, shown exploded
 translate([0,0,-rear_cover_t-explode]) rear_cover();
 // Receiver top lip meets the pod rear plane at z=0
 translate([0,0,-receiver_flange_t-receiver_h]) receiver();
 // Clamp is below receiver; upper clamp seat meets receiver flange underside
 translate([0,0,-receiver_flange_t-receiver_h-mount_boss_h-(clamp_z/2+5)-explode]) clamp_lower();
 translate([0,0,-receiver_flange_t-receiver_h-mount_boss_h-(clamp_z/2+5)-explode]) clamp_upper();
}

if(part=="pod") pod();
else if(part=="rear_cover") rear_cover();
else if(part=="receiver") receiver();
else if(part=="clamp_lower") clamp_lower();
else if(part=="clamp_upper") clamp_upper();
else if(part=="fit_coupon") fit_coupon();
else if(part=="male_coupon") male_coupon();
else assembly();

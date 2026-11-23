/*
  DIAL COMBINATION LOCK (DEMO): open this file in OpenSCAD to look at the lock and export its parts. See DIAL_LOCK.md.
  - The lock's parts and settings are in lib/dial_lock.scad: set your key code (dial_code) there.
  - The dock it fits is phone_dock_v0.5.scad (included below); the lock goes in the dock's lock bay.
  - PART picks what to show: "dl_exploded" (picture); parts "dl_wheels", "dl_spindle", "dl_dial", "dl_fence", "dl_hammer", "dl_plunger", "dl_lifter", "lock_cartridge"; checks "dl_check_*";
    also "lock_bay_exploded" (the cartridge below the dock's lock bay), "assembled_view" (the one-piece base with
    the lock fitted) or "assembly" (the whole dock on the bar).
  - Export from the command line, for example:
      openscad -D 'PART="dl_wheels"' -o dl_wheels.stl dial_lock.scad
*/
include <phone_dock_v0.5.scad>
lock_type = "dial";
PART = "dl_exploded";

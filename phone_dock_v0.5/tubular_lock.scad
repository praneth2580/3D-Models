/*
  TUBULAR KEY LOCK: open this file in OpenSCAD to look at the lock and export its parts. See TUBULAR_LOCK.md.
  - The lock's parts and settings are in lib/tubular_lock.scad: set your key code (tl_code) there.
  - The dock it fits is phone_dock_v0.5.scad (included below); the lock goes in the dock's lock bay.
  - PART picks what to show: "tl_exploded", "tl_cutaway" (pictures); parts "tl_housing", "tl_plug", "tl_crank", "tl_key", "tl_pins", "lock_cartridge"; checks "tl_check_*";
    also "lock_bay_exploded" (the cartridge below the dock's lock bay), "assembled_view" (the one-piece base with
    the lock fitted) or "assembly" (the whole dock on the bar).
  - Export from the command line, for example:
      openscad -D 'PART="tl_key"' -o tl_key.stl tubular_lock.scad
*/
include <phone_dock_v0.5.scad>
lock_type = "tubular";
PART = "tl_exploded";

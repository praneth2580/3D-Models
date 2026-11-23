/*
  PRINTED PUSH-KEY LOCK: open this file in OpenSCAD to look at the lock and export its parts. See PRINTED_LOCK.md.
  - The lock's parts and settings are in lib/printed_lock.scad: set your key code (lock_code) there.
  - The dock it fits is phone_dock_v0.5.scad (included below); the lock goes in the dock's lock bay.
  - PART picks what to show: "plock_exploded", "plock_cutaway" (pictures); parts "plock_shuttle", "plock_wafers", "plock_key", "plock_lifter", "lock_cartridge"; checks "plock_check_*";
    also "lock_bay_exploded" (the cartridge below the dock's lock bay), "assembled_view" (the one-piece base with
    the lock fitted) or "assembly" (the whole dock on the bar).
  - Export from the command line, for example:
      openscad -D 'PART="plock_key"' -o plock_key.stl printed_lock.scad
*/
include <phone_dock_v0.5.scad>
lock_type = "printed";
PART = "plock_exploded";

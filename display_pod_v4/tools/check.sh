#!/usr/bin/env bash
# Runs every clearance check in scad/main.scad.
#   "must be empty"  -> the two parts must not overlap
#   "must collide"   -> a deliberate stop/key must block the motion
# Usage: tools/check.sh            (from the project root)
set -u
cd "$(dirname "$0")/../scad" || exit 1
OUT=$(mktemp -d)
fail=0

run() {  # $1 = part, $2 = expect (empty|collide)
    local log="$OUT/$1.log" stl="$OUT/$1.stl"
    openscad -D "part=\"$1\"" -o "$stl" main.scad >"$log" 2>&1
    local empty=0
    if grep -qiE "top level object is empty|No top level geometry|Current top level object is not a 3D object" "$log" || [ ! -s "$stl" ]; then
        empty=1
    fi
    if grep -qE "^ERROR|Assertion" "$log"; then
        echo "ERROR  $1"; grep -E "^ERROR|Assertion" "$log" | head -3; fail=1; return
    fi
    if [ "$2" = empty ]; then
        if [ $empty = 1 ]; then echo "PASS   $1 (no overlap)"; else echo "FAIL   $1 (parts overlap)"; fail=1; fi
    else
        if [ $empty = 0 ]; then echo "PASS   $1 (blocked as intended)"; else echo "FAIL   $1 (NOT blocked)"; fail=1; fi
    fi
}

run check_board_housing     empty
run check_board_retainer    empty
run check_retainer_housing  empty
run check_cover_housing     empty
run check_battery           empty
run check_bayonet_insert    empty
run check_bayonet_rotate    empty
run check_bayonet_locked    empty
run check_bayonet_pullout   collide
run check_wrong_orientation collide
run check_receiver_mount    empty
run check_pod_mount         empty

rm -rf "$OUT"
exit $fail

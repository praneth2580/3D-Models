#!/usr/bin/env bash
# Exports every printable part (STL, print orientation) and the cut templates (DXF).
# Usage: tools/export.sh            (from the project root)
set -u
cd "$(dirname "$0")/../scad" || exit 1
EXP=../exports
mkdir -p "$EXP"
fail=0
for p in housing rear_cover board_retainer receiver clamp_upper clamp_lower usb_plug cover_gasket bayonet_test_male; do
    if openscad -D "part=\"$p\"" -o "$EXP/$p.stl" main.scad >"$EXP/.$p.log" 2>&1 && [ -s "$EXP/$p.stl" ]; then
        echo "OK     $p.stl"; rm -f "$EXP/.$p.log"
    else
        echo "FAILED $p.stl (see exports/.$p.log)"; fail=1
    fi
done
for p in lens_2d display_gasket_2d cover_gasket_2d retainer_foam_2d; do
    if openscad -D "part=\"$p\"" -o "$EXP/${p%_2d}.dxf" main.scad >"$EXP/.$p.log" 2>&1 && [ -s "$EXP/${p%_2d}.dxf" ]; then
        echo "OK     ${p%_2d}.dxf"; rm -f "$EXP/.$p.log"
    else
        echo "FAILED ${p%_2d}.dxf (see exports/.$p.log)"; fail=1
    fi
done
exit $fail

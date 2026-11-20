# Print settings

**Material.** Print the prototype in **PETG**, and the final parts in **ASA** once the fit is right. **No PLA:** it softens in the sun. Print the plug and gasket in **TPU 95A**. Use a light colour for the housing and cover if you can, because the board is rated to only 70 °C.

**General settings:** 0.4 mm nozzle, 0.2 mm layers (0.12 mm for the receiver and cover bayonet), 4 perimeters, 30 % gyroid infill. Turn off "ironing" on the gasket faces.

## Orientation and supports

STLs in `exports/` are already in print orientation.

| Part | On the bed | Supports | Notes |
|---|---|---|---|
| housing | Rear (gasket) face | None | The USB recess roof bridges 12.5 mm. The ledge overhang is about 1.4 mm. |
| rear_cover | Front (gasket) face | None | The battery-bay end wall bridges 21 mm. Lug load faces overhang 2.4 mm; check they print clean. |
| board_retainer | Plate | None | |
| receiver | Top land | None | The track ceilings (load faces) print as clean top surfaces. Keep the 0.12 mm layers here. |
| clamp_upper | Split face | **Yes:** build plate only | The tilted cup and tower overhang behind the clamp. |
| clamp_lower | Split face | None | |
| usb_plug, cover_gasket | Flat | None | TPU, slow (20–25 mm/s) |
| bayonet_test_male | Disc | None | Fit test with the receiver |

## Fit tuning (do this first)

1. Print **receiver.stl** and **bayonet_test_male.stl**. Together they take about 1.5 h.
2. Push in, twist 30° clockwise, twist back and lift out.
   - **Too tight:** increase `entry_clear` / `track_clear` in `scad/parameters.scad` by 0.05–0.1.
   - **Wobbles axially when locked (no plunger fitted yet):** that's expected. The plunger preload removes it.
3. Fit the M4 plunger and check the click at the locked position.
4. Re-export with `tools/export.sh`, then print the full parts.

## Verifying before printing

From the project root:

```bash
tools/check.sh                 # clearance and mechanism checks (all must PASS)
tools/export.sh                # writes exports/*.stl and *.dxf
python3 tools/stl_check.py exports/*.stl   # every part: shells=1 bad_edges=0
```

A successful render does not prove a part is printable or strong enough. Test the physical parts.

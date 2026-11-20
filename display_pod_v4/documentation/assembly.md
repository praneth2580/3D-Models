# Assembly

## Parts and hardware

| Part | Qty | Notes |
|---|---:|---|
| housing.stl | 1 | ASA (PETG for the prototype) |
| rear_cover.stl | 1 | ASA / PETG |
| board_retainer.stl | 1 | ASA / PETG |
| receiver.stl | 1 | ASA / PETG |
| clamp_upper.stl / clamp_lower.stl | 1 each | ASA / PETG |
| usb_plug.stl | 1 | TPU 95A |
| cover_gasket.stl or cover_gasket.dxf | 1 | TPU 85A–95A print, or cut from 1 mm silicone/EPDM sheet |
| Polycarbonate lens, Ø36.2 × 1.0 (lens.dxf) | 1 | Laser-cut or hand-cut clear PC |
| Foam ring (display_gasket.dxf), 0.5 mm | 1 | Thin closed-cell foam tape |
| Foam pad (retainer_foam.dxf), 1.5 mm | 1 | EVA or PORON |
| M2 × 3 heat-set inserts | 3 | |
| M2 × 8 socket cap screws, stainless | 3 | |
| M4 stainless spring-ball plunger | 1 | Check stroke ≥ 0.8 mm |
| M3 × 6–8 thread-forming screws (for plastic) | 3 | Receiver to cup |
| M5 × 25 socket cap screws + M5 nyloc nuts | 2 + 2 | Clamp |
| Rubber shim, about 1 mm, 22 × 75 mm | 1 | Wraps the bar |
| LiPo cell with protection PCB (default 402030) | 1 | JST 1.25 mm 2-pin plug, **check polarity** |
| Clear RTV silicone or VHB ring | — | Lens bond |

## Pod

1. **Heat-set inserts.** Press the three M2 inserts into the housing's rear face with a soldering iron (about 220 °C for PETG, 240 °C for ASA). Keep them flush or 0.1 mm below the surface. Proud inserts will hold the gasket open.
2. **Lens.** Clean the recess. Put a thin, continuous bead of clear RTV (or a VHB ring) on the 1.4 mm land and press the lens in. It should sit 0.4 mm below the rim. Wipe off any excess and let it cure for 24 h. This is the front seal.
3. **Foam ring.** Stick the 0.5 mm foam ring to the underside of the ledge, inside the housing.
4. **Board.** Slide the board in from the rear, display first, with the USB-C tab in the tab pocket at the bottom. Check the USB-C lines up with the side opening, and the switch nub with its slot.
5. **Retainer.** Stick the 1.5 mm foam pad to the front of the board retainer, lining up its holes with the plate's holes over RST/BOOT. Fit the retainer, key tab into the USB pocket, and feed the battery lead through the edge notch.
6. **Battery.** Connect the battery to the JST socket. **Check the polarity first:** clone boards and cells often have it reversed. Lay the cell flat in the cover's bay, long side horizontal. Don't wrap or squash it; it needs its 1 mm of room to swell.
7. **Gasket and cover.** Put the gasket in the cover's pocket. The screw spacing is uneven, so the cover fits only one way. Tighten the three M2 screws evenly, a little at a time, until the cover's outer rim touches the housing. That rim is the compression stop. Don't over-tighten.
8. **USB plug.** Fit the TPU plug into the USB-C recess.

## Mount

1. **Plunger.** Tap the receiver's detent hole M4 (it's printed at Ø3.3). Screw the ball plunger in from below until the ball stands about 0.5 mm above the top land. Don't use thread-locker: it cracks ASA and PETG. A dab of silicone will hold it.
2. **Receiver into cup.** Drop the receiver into the cup (key into rib, drain notch at the bottom). Fix it with the three M3 thread-forming screws through the cup wall.
3. **Clamp.** Put the M5 nyloc nuts in the side slots of the upper clamp. Wrap the bar with the rubber shim and close the clamp around it. Fit the M5 bolts from below and tighten evenly, leaving the split gap even on both sides. Before final tightening, check the steering turns lock to lock without touching the tank, cables or instrument cluster.

## Fitting and removing the pod

1. **To fit:** hold the pod with the display turned about 30° anticlockwise from upright. Only the wide lug at the top fits its wide slot, so it goes in only one way. Push it into the receiver until the cover touches the receiver top.
2. **Lock:** rotate about **30° clockwise** until it stops and the detent clicks. The display is now upright with the USB-C pointing down.
3. **To remove:** rotate anticlockwise past the detent until it stops, then lift out.
4. **Adjusting:** if the pod rattles, screw the plunger in a little. If it's too stiff to turn, screw it out.

## Before riding

CAD checks are not physical validation. Before using it on the road:

- **Pull test:** pull hard on the locked pod. It must not come out or turn.
- **Vibration:** ride slowly over rough roads, then check for loosening.
- **Heat:** park in the sun and measure the temperature inside the pod. The board is rated to only 70 °C, and the battery shouldn't be charged above about 45 °C.
- **Water:** spray-test, then open the pod and check for moisture.
- **Fatigue:** check the lugs and the receiver track for wear after a few weeks.

This is not IP-rated: no water testing has been done.

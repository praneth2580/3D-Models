# Mechanism demo video (v0.5)

`mechanism_demo.mp4` (1280 × 720, 24 fps, about 97 s) is rendered from the real CAD in `../phone_dock_v0.5.scad`. Change the design, re-run the script, and the video updates with it.

| Time | Scene |
|---|---|
| 0–3 s | Title |
| 3–10 s | Exploded view of the module stack: clamps, base plate, dock, case |
| 10–17.5 s | Slim rear-loading case: the phone drops into the shell, the O-ring back cover closes, then the front view shows the thin border |
| 17.5–23.5 s | Tilt adjustment by rotating the two clamps on the bar |
| 23.5–30.5 s | Docking: the case slides down the rails, with its nose in the centre channel |
| 30.5–36 s | Cutaway: the 10 pogo pins (2 rows) compress onto the nose's contact pads |
| 36–40.5 s | **Wiring, dock end** (x-ray close-up). An orange highlight follows the power from the bike's USB lead (wired straight in and potted), through the fuse and the MOSFET power switch on the dock board, and along the colour-coded wires to the pogo pins |
| 40.5–45 s | **Wiring, case end** (the camera pulls back). From the pads up the cable potted through the back cover, along the channel at the bottom edge, and into the phone through the 90° plug. The screen lights up when the power arrives |
| 45–54 s | **Dock electronics** (labelled, square-on x-ray of the dock board): the bike lead, F1 fuse, Q2 MOSFET power switch, U3 USB ESD, resistors, 3 mm status LEDs and pogo pins. With the case off, power stops at the switch and only the yellow PWR LED is lit. The case docks: the DET line glows, the pins go live and the green DOCK LED lights. The case lifts: the pins switch off again |
| 54–60 s | **Over-heat cut-off** (x-ray of the whole case). The thermostat behind the phone opens (it glows red), charging stops at the switch, the green LED goes out and the red OFF LED lights. When it cools, charging resumes |
| 60–65.5 s | The key goes in horizontally from the right-hand side, behind the case's top corner (well clear of the tank), and turns a quarter turn |
| 65.5–70.5 s | Side cutaway through the bolt: the crank and yoke lift the flat 14 × 9 mm steel bolt (yellow) up into the case's strike, where it lies flat against the key-steel bearing block (orange-red). The clamps and plate are hidden for this shot |
| 70.5–78.5 s | **Lock cartridge** (from below the pod, the dock level). The cover drops, and the store lock's cartridge drops out of the bay with the lock, crank, yoke and bolt in it. The printed lock's cartridge, with its chunky key, goes up into the same bay, and the cover goes back on |
| 78.5–83.5 s | Vibration damping on the rubber grommets (exaggerated) |
| 83.5–92.5 s | Swapping the base plate for a "smart base" (Arduino and speakers concept) |
| 92.5–96.5 s | Closing shot |

`mechanism_anim.scad` adds some **visual-only** stand-ins on top of the real parts. These are illustrations, not designed parts:
- the pins and pads;
- the O-ring and screws;
- the grommets;
- the store lock's key and body (the crank, yoke, flat bolt, bearing block, cartridges and the printed lock are the real parts);
- the phone screen;
- the smart base;
- the status LEDs (yellow whenever the bike is powered, green while the case is docked and charging, red while it is docked but too hot, in every scene);
- the thermostat in the case;
- the wiring: bike lead and plug, dock board (drawn as perfboard; a PCB is the same size) and its parts, wires, cable and potting. The routing follows the real channels and holes in the CAD, and the wire colours follow the pinout in `../WIRING.md` (DET yellow, VBUS red, D+ green, D− white, GND black, PRESENT blue, spares orange and purple).

## Re-render

```sh
pip install pillow imageio-ffmpeg
python3 make_video.py                     # renders frames into ./frames, writes mechanism_demo.mp4
python3 make_video.py --test 18,44        # quick contact sheet of chosen times
python3 make_video.py --stills            # labelled wiring renders -> ../images/wiring_dock.png, wiring_case.png
```

On Windows, point the script at the console build of OpenSCAD, which prints its messages: `OPENSCAD="C:/Program Files/OpenSCAD/openscad.com"`. The captions use Arial when DejaVu isn't installed.

Part labels in the dock-electronics scene are drawn by `make_video.py`. It projects anchor points that `mechanism_anim.scad` prints, using OpenSCAD's camera (checked to within about 6 px), so the labels follow the CAD.

The full render takes about 5–6 minutes on 4 cores with OpenSCAD 2021.01 on Linux, and about 15 minutes with 8 jobs on Windows. The v0.4 video is not kept; re-render it from `archive/v0.4` if needed.

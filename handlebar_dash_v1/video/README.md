# The dash's video

`dash_demo.mp4` (24 s, 1280 × 720) shows the display head on a bike, rendered straight from the CAD:
- a turn round the bike's front end;
- the rider's view: ignition on, the lamp check, the speed climbing through the gears, the left turn signal;
- a close-up of the face with the high beam on.

**The bike is a simple stand-in**, painted a sunset orange, for the reference bike's front end (a 350 cruiser like the Meteor 350): a round headlamp, a 41 mm fork, a 19" front wheel, a wide pulled-back 22.2 mm bar and a teardrop tank. It's modelled in `dash_anim.scad` from estimates, not measurements, and carries no maker's badges. There is no licensed 3D model of the real bike to use, so this one is drawn from scratch. The dash itself is the real CAD: the parts' STLs from `../parts/`, on its 2 bar clamps (`mount = "bar"`), hidden behind the gauge. The screen's picture is a mock-up of what the firmware could show.

**Make it** (OpenSCAD, plus Pillow and imageio-ffmpeg in a venv):

```sh
python3 make_dash_video.py                    # all frames -> dash_demo.mp4, and ../images/hd_video_poster.png
python3 make_dash_video.py --test 2,9,14,20   # a contact sheet of a few times (s)
```

Re-export the parts first if the CAD changed: the video imports `../parts/head_shell.stl`, `head_cover.stl`, `trim_ring.stl`, `bar_mount_right.stl`, `bar_mount_left.stl` and `cradle_cap.stl`. Each frame takes about a second; the whole video takes a few minutes on 4 cores.

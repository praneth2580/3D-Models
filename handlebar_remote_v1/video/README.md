# The remote's video

`remote_demo.mp4` (26 s, 1280 × 720) shows the remote on a stand-in bar, grip and switch cube, rendered straight from the CAD:
- the remote between the grip and the switch cube;
- from behind and low: its curved face stays below the switch cube's top;
- the joystick on its own platform, its cap rocking all the way round;
- the 4 buttons pressed in turn;
- the capsule's back: the back button pressed, the status LED blinking;
- taken apart: the hinged halves, the 2 switch carriers, the keypad, the capsule's plugs.

**Make it** (OpenSCAD, plus Pillow and imageio-ffmpeg in a venv):

```sh
python3 make_remote_video.py                       # all frames -> remote_demo.mp4, and ../images/hr_video_poster.png
python3 make_remote_video.py --test 2,7.5,11,16,20,23   # a contact sheet of a few times (s)
python3 make_remote_video.py --views               # re-export the parts in place after CAD changes
```

The parts are exported once from `../handlebar_remote.scad` in their places on the bar (`frames_remote/view/`, not committed), so each frame is a quick preview render (`remote_anim.scad`): the whole video takes about a minute and a half on 8 cores. **After a CAD change, run with `--views` first**, or the video shows the old parts.

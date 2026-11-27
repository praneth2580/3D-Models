#!/usr/bin/env python3
"""
Renders the Handlebar Remote's video from remote_anim.scad: the remote on a stand-in bar, grip and switch cube.

Needs: openscad (2021.01+), Pillow, imageio-ffmpeg (pip install pillow imageio-ffmpeg, in a venv).
  python3 make_remote_video.py                   # the full video -> remote_demo.mp4 (and ../images/hr_video_poster.png)
  python3 make_remote_video.py --test 2,7,10,13  # a contact sheet of a few times (s)
  python3 make_remote_video.py --views           # (re)export the parts in place (frames_remote/view/), then stop
The parts are exported once in their places on the bar (frames_remote/view/: rerun with --views after CAD changes), so
each frame is a quick preview render.
"""
import argparse, math, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "remote_anim.scad")
MAIN = os.path.join(HERE, "..", "handlebar_remote.scad")
FRAMES = os.path.join(HERE, "frames_remote")
VIEW = os.path.join(FRAMES, "view")
W, H, FPS, LENGTH = 1280, 720, 24, 26.0
OPENSCAD = os.environ.get("OPENSCAD", "openscad")
FONT_DIR = "/usr/share/fonts/truetype/liberation/"

# The parts in place on the bar (bike frame), for the frames to import.
VIEWS = {
    "collar_top": "collar_top(); ribs();",
    "collar_bottom": "collar_bottom();",
    "keypad": "keypad();",
    "joy_cap": "joy_cap();",
    "carrier_0": "carrier(0);", "carrier_1": "carrier(1);",
    "switches_0": "group_switches(0);", "switches_1": "group_switches(1);",
    "boards": "bay_frame() { translate([mcu_x, y_fi + 0.2, z_m0]) cube([mcu[2], mcu[0], mcu[1]]);"
              " translate([usb_x - usb_c[1]/2, y_fi + 0.2 - usb_out, usb_z - usb_c[0]/2]) cube([usb_c[1], usb_out + 0.01, usb_c[0]]);"
              " translate([can_x, y_fi + 0.2, z_m0 + 1]) cube([can_pcb[2], can_pcb[0], can_pcb[1]]);"
              " translate([-(bay_in[0] - 0.6)/2, y_a - aux_t, aux_z[0]]) cube([bay_in[0] - 0.6, aux_t, aux_z[1] - aux_z[0]]); }",
    "bay_plug": "bay_plug();", "usb_plug": "usb_plug();", "back_pad": "back_pad();",
}

def export_views(jobs):
    os.makedirs(VIEW, exist_ok=True)
    def one(item):
        name, body = item
        src = os.path.join(VIEW, f"_{name}.scad")
        with open(src, "w") as f: f.write(f'include <{os.path.abspath(MAIN)}>\nPART = "none";\n{body}\n')
        out = os.path.join(VIEW, f"{name}.stl")
        r = subprocess.run([OPENSCAD, "-o", out, src], capture_output=True, text=True)
        if r.returncode or not os.path.exists(out): sys.exit(f"export {name} failed:\n{r.stderr[-800:]}")
        os.remove(src); return name
    with ThreadPoolExecutor(jobs) as ex:
        for n in ex.map(one, VIEWS.items()): print("exported", n, flush=True)

def ease(u): u = max(0.0, min(1.0, u)); return u*u*(3 - 2*u)
def lerp(a, b, u): return [x + (y - x)*u for x, y in zip(a, b)]

# Camera keys: (time, eye xyz + centre xyz) in the bike frame (x to the rider's right, y forward, z up); eased between.
KEYS = [(0.0, [-215, -285, 200, 5, -8, -4]),
        (3.5, [-190, -240, 170, 0, -5, 3]),
        (6.0, [-150, -300, 25, 4, 0, 6]),        # from behind, low: the face against the switch cube's top
        (8.5, [-150, -300, 25, 4, 0, 6]),
        (10.0, [-85, -125, 15, -2, -24, -3]),    # the joystick on its platform
        (13.5, [-85, -125, 15, -2, -24, -3]),
        (15.0, [-95, -95, 120, 0, -6, 16]),      # the buttons over the top
        (17.5, [-95, -95, 120, 0, -6, 16]),
        (19.0, [-75, -165, -95, 0, -8, -24]),    # the capsule's back: its button and LEDs
        (21.0, [-75, -165, -95, 0, -8, -24]),
        (22.5, [-185, -215, 55, 2, -12, -8]),    # taken apart
        (24.5, [-185, -215, 55, 2, -12, -8]),
        (26.0, [-215, -285, 200, 5, -8, -4])]
def camera(t):
    for (t0, a), (t1, b) in zip(KEYS, KEYS[1:]):
        if t <= t1: return lerp(a, b, ease((t - t0)/(t1 - t0)))
    return KEYS[-1][1]

def state(t):
    """The remote at time t: taken apart, the joystick's tilt, the button pressed, the back button, the LEDs."""
    expl = ease((t - 21.2)/1.3) if t < 24.5 else 1 - ease((t - 24.5)/1.2)
    joy = [0, 0]
    if 10.0 <= t < 13.5:                                    # the cap rocks once all the way round, then a press
        u = (t - 10.0)/2.8
        joy = [14*ease(min(1, u*5))*ease(min(1, (1 - u)*5)), 360*u] if u < 1 else [0, 0]
    press = next((i for i, (a, b) in enumerate([(15.2, 15.7), (15.8, 16.3), (16.4, 16.9), (17.0, 17.5)]) if a <= t < b), -1)
    back = 1 if 19.6 <= t < 20.2 else 0
    status = [0.2, 0.45, 1.0]
    leds = [1, 1 if (t < 19.6 or t >= 20.2 or int(t*6) % 2) else 0]   # the status LED blinks while the back button is held
    return expl, joy, press, back, leds, status

CAPTIONS = [(0.3, 5.6, "A thumb remote between the grip and the switch cube", "For the Handlebar Dash and your phone (Bluetooth)"),
            (6.0, 9.3, "Its face curves round the bar", "Nothing stands higher than the switch cube's top"),
            (10.0, 13.8, "The joystick on its own platform", "Angled toward your hand; it rocks all the way round"),
            (14.9, 17.9, "4 buttons up and over the top", "Each in its own cup; a ridge between 2 and 3"),
            (18.8, 21.0, "The electronics in a slim capsule", "A button and 2 status LEDs at its back, facing you"),
            (21.3, 24.6, "Hinged halves, 2 switch carriers, a rubber keypad", "No screws on the face; the capsule closes with a rubber plug"),
            (24.8, 26.0, "Handlebar Remote v1", "Free to download and print, CC BY-NC-SA 4.0")]

def render(job):
    i, t, out = job
    expl, joy, press, back, leds, status = state(t)
    cam = ",".join(f"{c:.3f}" for c in camera(t))
    cmd = [OPENSCAD, "-o", out, f"--imgsize={W},{H}", "--colorscheme=Tomorrow", f"--camera={cam}", "-D", 'PART="none"',
           "-D", f"EXPL={expl:.4f}", "-D", f"JOY=[{joy[0]:.3f},{joy[1]:.3f}]", "-D", f"PRESS={press}", "-D", f"BACK_PRESS={back}",
           "-D", f"LEDS=[{leds[0]},{leds[1]}]", "-D", "STATUS=[" + ",".join(map(str, status)) + "]", SCAD]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if not os.path.exists(out): sys.exit(f"frame {i} failed:\n{r.stderr[-800:]}")
    caption(out, t)
    return out

def caption(path, t):
    from PIL import Image, ImageDraw, ImageFont
    im = Image.open(path).convert("RGB")
    for t0, t1, head, sub in CAPTIONS:
        if not (t0 <= t <= t1): continue
        a = min(1.0, (t - t0)/0.35, (t1 - t)/0.35)
        over = Image.new("RGBA", im.size, (0, 0, 0, 0)); d = ImageDraw.Draw(over)
        fb = ImageFont.truetype(FONT_DIR + "LiberationSans-Bold.ttf", 30); fr = ImageFont.truetype(FONT_DIR + "LiberationSans-Regular.ttf", 21)
        w = max(d.textlength(head, font=fb), d.textlength(sub, font=fr)) + 44
        d.rounded_rectangle([28, H - 128, 28 + w, H - 30], 10, fill=(20, 24, 30, int(200*a)))
        d.text((50, H - 117), head, font=fb, fill=(255, 255, 255, int(255*a)))
        d.text((50, H - 74), sub, font=fr, fill=(200, 210, 222, int(255*a)))
        im = Image.alpha_composite(im.convert("RGBA"), over).convert("RGB")
    im.save(path)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--test"); ap.add_argument("--views", action="store_true")
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    a = ap.parse_args()
    if a.views or not all(os.path.exists(os.path.join(VIEW, f"{n}.stl")) for n in VIEWS):
        export_views(a.jobs)
        if a.views: return
    os.makedirs(FRAMES, exist_ok=True)
    if a.test:
        from PIL import Image
        ts = [float(x) for x in a.test.split(",")]
        jobs = [(i, t, os.path.join(FRAMES, f"test_{i}.png")) for i, t in enumerate(ts)]
        with ThreadPoolExecutor(a.jobs) as ex: outs = list(ex.map(render, jobs))
        cols = 2; rows = (len(outs) + 1)//2
        sheet = Image.new("RGB", (cols*W//2, rows*H//2), "white")
        for k, o in enumerate(outs): sheet.paste(Image.open(o).resize((W//2, H//2)), ((k % cols)*W//2, (k//cols)*H//2))
        sheet.save(os.path.join(FRAMES, "contact.png")); print("wrote", os.path.join(FRAMES, "contact.png")); return
    n = int(LENGTH*FPS)
    jobs = [(i, i/FPS, os.path.join(FRAMES, f"f{i:04d}.png")) for i in range(n)]
    with ThreadPoolExecutor(a.jobs) as ex:
        for k, _ in enumerate(ex.map(render, jobs)):
            if k % 48 == 0: print(f"frame {k}/{n}", flush=True)
    import imageio_ffmpeg
    from PIL import Image
    out = os.path.join(HERE, "remote_demo.mp4")
    w = imageio_ffmpeg.write_frames(out, (W, H), fps=FPS, quality=8, macro_block_size=8)
    w.send(None)
    for _, _, f in jobs: w.send(Image.open(f).convert("RGB").tobytes())
    w.close()
    Image.open(jobs[int(11.0*FPS)][2]).save(os.path.join(HERE, "..", "images", "hr_video_poster.png"))
    print("wrote", out)

if __name__ == "__main__": main()

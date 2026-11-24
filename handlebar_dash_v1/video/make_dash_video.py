#!/usr/bin/env python3
"""
Renders the handlebar dash's video (the dash on a stand-in of the reference bike's front end) from dash_anim.scad.

Needs: openscad (2021.01+), Pillow, imageio-ffmpeg (pip install pillow imageio-ffmpeg, in a venv).
  python3 make_dash_video.py                  # the full video -> dash_demo.mp4 (and ../images/hd_video_poster.png)
  python3 make_dash_video.py --test 3,9,14,18 # a contact sheet of a few times (s)
  python3 make_dash_video.py --jobs 4 --frames DIR
"""
import argparse, math, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "dash_anim.scad")
W, H, FPS, LENGTH = 1280, 720, 24, 24.0
OPENSCAD = os.environ.get("OPENSCAD", "openscad")
FONT_DIR = "/usr/share/fonts/truetype/liberation/"

def ease(u): u = max(0.0, min(1.0, u)); return u*u*(3 - 2*u)
def lerp(a, b, u): return [x + (y - x)*u for x, y in zip(a, b)]

# Camera keys: (time, [cx, cy, cz, rx, ry, rz, dist]) in the bike frame (OpenSCAD gimbal camera); eased between keys.
FACE = [0, 60, 70]
KEYS = [(0.0, [0, 80, -280, 80, 0, 200, 2700]),
        (6.0, [0, 30, -150, 72, 0, 320, 2000]),
        (8.0, [0, 40, 60, 62, 0, 360, 1000]),
        (16.0, [0, 45, 65, 63, 0, 360, 820]),
        (18.0, FACE + [65, 0, 360, 345]),
        (21.0, FACE + [65, 0, 360, 315]),
        (24.0, [0, 30, -40, 70, 0, 325, 1500])]
def camera(t):
    for (t0, a), (t1, b) in zip(KEYS, KEYS[1:]):
        if t <= t1: return lerp(a, b, ease((t - t0)/(t1 - t0)))
    return KEYS[-1][1]

GEARS = [(0, "1"), (16, "2"), (29, "3"), (43, "4")]
def state(t):
    """The dash at time t: lit tell-tales, the screen, speed and gear."""
    if t < 8.0: return [], "off", 0, "N"
    if t < 9.6: return ["left", "beam", "neutral", "abs", "engine", "fuel", "battery", "right"], "boot", 0, "N"
    if t < 10.8: return ["neutral", "abs"], "ride", 0, "N"
    v = 62*ease((t - 10.8)/5.2) if t < 19 else 62 - 4*ease((t - 19)/2.0)
    v = int(round(v))
    gear = [g for s, g in GEARS if v >= s][-1]
    lit = []
    if 12.6 <= t < 15.8 and (t - 12.6) % 0.66 < 0.33: lit.append("left")
    if t >= 17.0: lit.append("beam")
    return lit, "ride", v, gear

CAPTIONS = [(0.3, 5.6, "A round 2.8\" dash where the stock cluster was", "On a stand-in of the reference bike's front end (a Meteor 350; sizes estimated)"),
            (6.3, 8.0, "Mounted behind the gauge", "Nothing shows round it from the seat"),
            (8.1, 10.6, "Ignition on: a lamp check", "Every tell-tale lights, then the screen starts"),
            (11.0, 16.4, "Speed, gear, clock and trip on the screen", "Turn signals, neutral and high beam lit in the face"),
            (17.0, 21.0, "The logo and tell-tales sit on the display's own black border", "102.5 mm across: only 3 mm wider than the glass"),
            (21.6, 24.0, "Handlebar Dash: display head v1", "Free to download and print, CC BY-NC-SA 4.0")]

def render(job):
    i, t, out = job
    lit, scr, v, gear = state(t)
    cam = ",".join(f"{c:.3f}" for c in camera(t))
    cmd = [OPENSCAD, "-o", out, f"--imgsize={W},{H}", "--colorscheme=Tomorrow", f"--camera={cam}",
           "-D", "LIT=[" + ",".join(f'"{n}"' for n in lit) + "]", "-D", f'SCREEN="{scr}"', "-D", f"SPEED={v}", "-D", f'GEAR="{gear}"', SCAD]
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
    ap.add_argument("--test"); ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--frames", default=os.path.join(HERE, "frames_dash"))
    a = ap.parse_args()
    os.makedirs(a.frames, exist_ok=True)
    if a.test:
        from PIL import Image
        ts = [float(x) for x in a.test.split(",")]
        jobs = [(i, t, os.path.join(a.frames, f"test_{i}.png")) for i, t in enumerate(ts)]
        with ThreadPoolExecutor(a.jobs) as ex: outs = list(ex.map(render, jobs))
        cols = 2; rows = (len(outs) + 1)//2
        sheet = Image.new("RGB", (cols*W//2, rows*H//2), "white")
        for k, o in enumerate(outs): sheet.paste(Image.open(o).resize((W//2, H//2)), ((k % cols)*W//2, (k//cols)*H//2))
        sheet.save(os.path.join(a.frames, "contact.png")); print("wrote", os.path.join(a.frames, "contact.png")); return
    n = int(LENGTH*FPS)
    jobs = [(i, i/FPS, os.path.join(a.frames, f"f{i:04d}.png")) for i in range(n)]
    with ThreadPoolExecutor(a.jobs) as ex:
        for k, _ in enumerate(ex.map(render, jobs)):
            if k % 48 == 0: print(f"frame {k}/{n}", flush=True)
    import imageio_ffmpeg
    from PIL import Image
    out = os.path.join(HERE, "dash_demo.mp4")
    w = imageio_ffmpeg.write_frames(out, (W, H), fps=FPS, quality=8, macro_block_size=8)
    w.send(None)
    for _, _, f in jobs: w.send(Image.open(f).convert("RGB").tobytes())
    w.close()
    Image.open(jobs[int(18.5*FPS)][2]).save(os.path.join(HERE, "..", "images", "hd_video_poster.png"))
    print("wrote", out)

if __name__ == "__main__": main()

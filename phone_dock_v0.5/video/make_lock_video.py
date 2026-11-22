#!/usr/bin/env python3
"""
Renders the lock video (how the store, printed and dial-code locks move the bolt) from lock_anim.scad.

Needs: openscad (2021.01+), Pillow, imageio-ffmpeg. Set OPENSCAD if it isn't "openscad" on the PATH
(on Windows: "C:/Program Files/OpenSCAD/openscad.com").

  python3 make_lock_video.py                 # -> lock_demo.mp4
  python3 make_lock_video.py --test 6,20,33  # contact sheet of chosen times
"""
import argparse, os, subprocess
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "lock_anim.scad")
W, H, FPS = 1280, 720, 24
OPENSCAD = os.environ.get("OPENSCAD", "openscad")

def ease(u):
    u = max(0.0, min(1.0, u)); return u*u*(3 - 2*u)
def ramp(t, t0, t1, a, b):
    return a + (b - a)*ease((t - t0)/(t1 - t0))

def load_font(bold, size):
    from PIL import ImageFont
    for f in (("DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"),):
        for p in ("/usr/share/fonts/truetype/dejavu/" + f, "arialbd.ttf" if bold else "arial.ttf"):
            try: return ImageFont.truetype(p, size)
            except OSError: pass
    return ImageFont.load_default()

PLK_S, PLK_DROP = 7.0, 1.3        # printed lock: shuttle travel and wafer drop (printed_lock.scad)
CLICK = 18.0                      # EC11: 20 clicks a turn

# (start, end, caption)
SCENES = [
    (0.0, 3.0, ""),
    (3.0, 5.4, "1. Store cam lock: the key goes in from the side of the pod"),
    (5.4, 8.0, "A quarter turn turns the crank (the lock's own cam); its pin pulls the yoke and the steel bolt down"),
    (8.0, 10.8, "Unlocked: the bolt is out of the case's strike, so the case slides off the rails"),
    (10.8, 13.0, "Turn back: the bolt rises into the strike and sits flat against its steel block (orange-red)"),
    (13.0, 14.5, "Locked, the crank pin is straight up: pushing on the bolt can't turn the lock"),
    (14.5, 16.0, "2. Printed push-key lock: with no key, the springs drop the wafers and their tabs block the shuttle"),
    (16.0, 18.3, "The chunky key's cuts lift every wafer to exactly the height of the groove"),
    (18.3, 21.0, "Push the key 7 mm: the shuttle slides in, the lifter's pin runs down its slanted track, the bolt drops"),
    (21.0, 23.3, "Unlocked: the case slides off. The key can't come out here: the groove holds the wafers"),
    (23.3, 25.6, "Pull the key back: the bolt rises. Only here the wafers have pockets, so the key comes out"),
    (25.6, 27.5, "Locked, the pin sits on a flat part of the track: pushing the bolt can't push the shuttle"),
    (27.5, 29.0, "3. Dial-code demo: a rotary knob, an ATtiny85 and a micro servo"),
    (29.0, 33.4, "Dial like a safe, counting clicks: right 7, left 12, right 4"),
    (33.4, 35.4, "Right code: the servo's horn turns a quarter turn; its pin pulls the lifter and the bolt down"),
    (35.4, 37.6, "Unlocked: the case slides off"),
    (37.6, 40.0, "Press the knob to lock: the servo turns back, pin straight up, bolt up"),
    (40.0, 43.0, ""),
]
DURATION = SCENES[-1][1]

def cam(t, t0, t1, rz0=44, rz1=58):
    return [64, 28, -14, 76, 0, rz0 + (rz1 - rz0)*ease((t - t0)/(t1 - t0)), 175]

def case_off(t, t0):
    """Slide the case up the rails and back down, starting at t0 (2.2 s)."""
    return ramp(t, t0, t0 + 0.9, 0, 40) if t < t0 + 1.2 else ramp(t, t0 + 1.2, t0 + 2.1, 40, 0)

def state(t):
    p = dict(lock_type='"store"', L_turn=1, L_key_out=0, L_key_rot=0, L_shift=0, L_wafer=0, L_show_key=1, L_case_dy=0,
             kp_knob_a=0, kp_knob_press=0)
    if t < 14.5:                                   # store lock
        p["L_key_out"] = 35 if t < 3.3 else (ramp(t, 3.3, 5.0, 35, 0) if t < 13.0 else ramp(t, 13.4, 14.4, 0, 35))
        if t < 10.8:
            p["L_turn"] = ramp(t, 5.6, 7.6, 1, 0); p["L_key_rot"] = ramp(t, 5.6, 7.6, 0, 90)
        else:
            p["L_turn"] = ramp(t, 11.0, 12.8, 0, 1); p["L_key_rot"] = ramp(t, 11.0, 12.8, 90, 0)
        p["L_case_dy"] = case_off(t, 8.3) if 8.3 <= t < 10.8 else 0
        c = cam(t, 0, 14.5)
    elif t < 27.5:                                 # printed lock
        p["lock_type"] = '"printed"'
        out = 40 if t < 16.0 else (ramp(t, 16.0, 18.0, 40, 0) if t < 25.6 else ramp(t, 25.8, 27.3, 0, 40))
        p["L_key_out"] = out
        p["L_wafer"] = -PLK_DROP + PLK_DROP*min(1, max(0, (3 - out)/2.5))   # the key lifts them as it reaches them
        p["L_shift"] = ramp(t, 18.5, 20.8, 0, PLK_S) if t < 23.3 else ramp(t, 23.5, 25.4, PLK_S, 0)
        p["L_case_dy"] = case_off(t, 21.1) if 21.1 <= t < 23.3 else 0
        c = cam(t, 14.5, 27.5)
    else:                                          # dial-code demo
        p["lock_type"] = '"keypad"'; p["L_show_key"] = 0
        a = 0.0
        if t >= 29.2: a += 7*CLICK*min(1, (t - 29.2)/1.3)
        if t >= 30.7: a -= 12*CLICK*min(1, (t - 30.7)/1.6)
        if t >= 32.5: a += 4*CLICK*min(1, (t - 32.5)/0.7)
        p["kp_knob_a"] = a
        p["L_turn"] = ramp(t, 33.6, 35.0, 1, 0) if t < 37.6 else ramp(t, 38.3, 39.7, 0, 1)
        p["kp_knob_press"] = 0.8 if 37.8 <= t < 38.3 else 0
        p["L_case_dy"] = case_off(t, 35.5) if 35.5 <= t < 37.6 else 0
        c = cam(t, 27.5, DURATION, 44, 62)
    return p, c

def render_frame(i, t, outdir):
    p, c = state(t)
    png = os.path.join(outdir, f"raw_{i:05d}.png")
    cmd = [OPENSCAD, "-o", png, f"--imgsize={W},{H}", "--colorscheme=Tomorrow", "--camera=" + ",".join(f"{v:.3f}" for v in c)]
    for k, v in p.items(): cmd += ["-D", f"{k}={v}"]
    r = subprocess.run(cmd + [SCAD], capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(png):
        raise RuntimeError(f"frame {i} (t={t:.2f}) failed:\n{(r.stderr + r.stdout)[-800:]}")
    return png

def annotate(png, t, out):
    from PIL import Image, ImageDraw
    im = Image.open(png).convert("RGB"); d = ImageDraw.Draw(im, "RGBA")
    cap = next((c for s, e, c in SCENES if s <= t < e), "")
    if cap:
        f = load_font(False, 24)
        d.rectangle([0, H - 78, W, H], fill=(20, 24, 30, 205))
        d.text(((W - d.textlength(cap, font=f))/2, H - 56), cap, font=f, fill=(255, 255, 255, 255))
    if t < 3.0 or t >= SCENES[-1][0]:
        a = int(255*min(1, min(t, DURATION - t)/0.6 + 0.2))
        title, sub = (("How the locks work", "Handlebar phone dock v0.5: one dock, three lock cartridges") if t < 3.0 else
                      ("Store, printed or dial-code lock", "Same dock, cover, steel bolt and strike  |  CAD: phone_dock_v0.5.scad"))
        f1, f2 = load_font(True, 44), load_font(False, 24)
        d.rectangle([0, 0, W, 150], fill=(20, 24, 30, min(215, a)))
        d.text(((W - d.textlength(title, font=f1))/2, 30), title, font=f1, fill=(255, 255, 255, a))
        d.text(((W - d.textlength(sub, font=f2))/2, 92), sub, font=f2, fill=(200, 210, 220, a))
    im.save(out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--frames", default=os.path.join(HERE, "lock_frames"))
    ap.add_argument("--out", default=os.path.join(HERE, "lock_demo.mp4"))
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--test", default="")
    a = ap.parse_args()
    os.makedirs(a.frames, exist_ok=True)
    if a.test:
        from PIL import Image
        times = [float(x) for x in a.test.split(",")]
        with ThreadPoolExecutor(a.jobs) as ex:
            pngs = list(ex.map(lambda it: render_frame(it[0], it[1], a.frames), enumerate(times)))
        outs = []
        for i, (png, t) in enumerate(zip(pngs, times)):
            o = os.path.join(a.frames, f"test_{i:02d}.png"); annotate(png, t, o); outs.append(o)
        rows = (len(outs) + 1)//2
        sheet = Image.new("RGB", (W, H*rows//2), "white")
        for i, o in enumerate(outs):
            sheet.paste(Image.open(o).resize((W//2, H//2)), ((i % 2)*W//2, (i//2)*H//2))
        sheet.save(os.path.join(a.frames, "contact_sheet.png")); print(os.path.join(a.frames, "contact_sheet.png"))
        return
    n = int(DURATION*FPS)
    def job(i):
        t = i/FPS
        final = os.path.join(a.frames, f"f_{i:05d}.png")
        if not os.path.exists(final):
            png = render_frame(i, t, a.frames); annotate(png, t, final); os.remove(png)
        if i % 96 == 0: print(f"frame {i}/{n}", flush=True)
    with ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(job, range(n)))
    import imageio_ffmpeg
    subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), "-y", "-loglevel", "error", "-framerate", str(FPS),
                    "-i", os.path.join(a.frames, "f_%05d.png"), "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20",
                    "-movflags", "+faststart", a.out], check=True)
    print("wrote", a.out)

if __name__ == "__main__":
    main()

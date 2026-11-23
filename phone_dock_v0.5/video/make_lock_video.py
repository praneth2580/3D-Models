#!/usr/bin/env python3
"""
Renders the lock video (how the store, printed, dial and tubular locks move the bolt) from lock_anim.scad.

Needs: openscad (2021.01+), Pillow, imageio-ffmpeg. Set OPENSCAD if it isn't "openscad" on the PATH
(on Windows: "C:/Program Files/OpenSCAD/openscad.com").

  python3 make_lock_video.py                 # -> lock_demo.mp4
  python3 make_lock_video.py --test 6,20,33  # contact sheet of chosen times
"""
import argparse, ast, math, os, re, subprocess, tempfile
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

PLK_S, PLK_DROP = 7.0, 1.3        # printed lock: shuttle travel and wafer drop (lib/printed_lock.scad)


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
]

def cam(t, t0, t1, rz0=44, rz1=58):
    return [64, 28, -14, 76, 0, rz0 + (rz1 - rz0)*ease((t - t0)/(t1 - t0)), 175]

def _scad_echo():                  # anchors, close-up focus and the dial's numbers, echoed by lock_anim.scad (they follow the CAD)
    with tempfile.TemporaryDirectory() as d:
        r = subprocess.run([OPENSCAD, "-o", os.path.join(d, "x.csg"), "-D", 'lock_type="dial"', SCAD], capture_output=True, text=True)
    out = r.stderr + r.stdout                 # Windows' openscad.com prints ECHO to stdout
    get = lambda name: ast.literal_eval(re.search(name + r" = (\[.*\])", out).group(1))
    return get("dl_label_points"), get("dl_focus"), get("dl_anim")
DL_POINTS, DL_FOCUS, (DL_N, DL_DELTA, DL_GATES, DL_CODE, DL_HOME, DL_HUMP, DL_HLIFT, DL_STROKE) = _scad_echo()
DL_LABELS = [("Wheels: one per digit", 0, (40, -100)), ("Notch (at the bottom: right digit)", 1, (60, 120)),
             ("Fence: rises into the notches", 2, (-260, 90)), ("Latch: tooth in the button's notch", 3, (40, 70)),
             ("Reset hammer", 4, (110, 40)), ("Heart cam (front wheel)", 5, (90, -40)), ("Dial 0-9", 6, (40, -60))]
CLOSE = list(DL_FOCUS) + [76, 0, 24, 125]

# ---- the dial's mechanism, simulated: element 0 = drive cam (turns with the dial), 1..N = wheels from the rear.
# A part picks up the next when their flies touch: the next one sits between +delta and +(360 - delta) of it.
def dl_settle(a):
    for k in range(1, DL_N + 1):
        a[k] = min(max(a[k], a[k - 1] + DL_DELTA), a[k - 1] + 360 - DL_DELTA)
    return a
def dl_wheel_rots(a):                   # CAD order (front wheel first): wheel i is chain element N - i
    return [a[DL_N - i] for i in range(DL_N)]
def dl_misalign(a):                     # worst notch's distance from the bottom, degrees
    return max(abs(((r + g + 180) % 360) - 180) for r, g in zip(dl_wheel_rots(a), DL_GATES))
def dl_build():
    """Path of the dial, as (time, dial angle) keys with the parts' states, and the timeline's marks."""
    a = dl_settle([0.0] + [0.0]*DL_N)
    for k in range(1, DL_N + 1): a[k] = a[k - 1] + 120 + 37*k          # scrambled
    a = dl_settle(a)
    keys, t, marks = [(29.8, list(a))], 29.8, {}
    def turn(a, travel, t, dur):
        steps = max(2, int(abs(travel)))
        out = []
        for n in range(1, steps + 1):
            a = list(a); a[0] += travel/steps; a = dl_settle(a)
            out.append((t + dur*ease(n/steps), a))
        return out, a
    for j in range(DL_N):                                             # dial the code: right, left, right...
        sgn = -1 if j % 2 == 0 else 1
        target = -36*DL_CODE[j]
        for m in range(0, 8):                                         # the shortest turn that picks up enough wheels
            travel = sgn*(((sgn*(target - a[0])) % 360) + 360*m)
            _, after = turn(a, travel, 0, 1)
            k = DL_N - j                                              # this step sets chain element k (wheel j)
            bound = after[k - 1] + (360 - DL_DELTA if sgn < 0 else DL_DELTA)   # pushed along, flies touching
            if abs(after[k] - bound) < 1e-6 and all(abs(after[q] - a[q]) < 1e-6 for q in range(k + 1, DL_N + 1)):
                break
        dur = 0.35 + abs(travel)/800
        seg, a = turn(a, travel, t, dur)
        keys += seg; marks[f"stop{j}"] = (t, t + dur, sgn, DL_CODE[j]); t += dur + 0.35
    assert dl_misalign(a) < 0.5, f"the simulated dialling doesn't line the notches up ({dl_misalign(a):.1f} deg)"
    marks["open"] = t
    # Relock: (later) spin the dial a turn and a bit to the left; a wheel moves and the fence is pushed down.
    return keys, a, marks
DL_KEYS, DL_OPEN, DL_MARKS = dl_build()
T_OPEN = DL_MARKS["open"]
T_POP = T_OPEN + 0.4                    # the fence has risen; the button pops out (the hammer clears the code)
T_POP_END = T_POP + 1.6
T_CASE = T_POP_END + 0.5
T_PRESS = T_CASE + 2.3                  # one press: the bolt goes up, the hammer clears the code, the latch snaps in
T_PRESS_END = T_PRESS + 2.0
T_END = T_PRESS_END + 2.6
def dl_hammer_at(s):                    # as dl_hammer_at() in lib/dial_lock.scad: the hump in the button's groove
    s0, s1, s2, s3 = DL_HUMP
    if s >= s0 or s <= s3: return 0.0
    if s >= s1: return DL_HLIFT*(s0 - s)/(s0 - s1)
    if s >= s2: return DL_HLIFT
    return DL_HLIFT*(s - s3)/(s1 - s3 - (s1 - s2))
def dl_button_at(t):
    if t < T_PRESS: return ramp(t, T_POP, T_POP_END, 0, DL_STROKE)
    return ramp(t, T_PRESS + 0.2, T_PRESS_END, DL_STROKE, 0)
def dl_state_at(t):
    """Parts' turns at time t: the dialling, then the front wheel turned home by the hammer (on the way out)."""
    if t <= DL_KEYS[0][0]: return DL_KEYS[0][1]
    a = DL_KEYS[-1][1]
    for (t0, a0), (t1, a1) in zip(DL_KEYS, DL_KEYS[1:]):
        if t0 <= t <= t1: a = a1; break
    a = list(a)
    if t >= T_POP:                      # the hammer pushes the heart: the front wheel (chain element N) turns home
        s = dl_button_at(t)             # on the way out the hump goes up from DL_HUMP[3] to its top at DL_HUMP[2]
        frac = 0.0 if s <= DL_HUMP[3] else min(1.0, dl_hammer_at(s)/DL_HLIFT) if s < DL_HUMP[2] else 1.0
        if t >= T_PRESS: frac = 1.0
        home = DL_HOME + 360*round((a[DL_N] - DL_HOME)/360)
        a[DL_N] = a[DL_N] + (home - a[DL_N])*frac
    return a
def dl_fence_at(a):                     # the fence rises as far as the V notches let it
    return 1.5*max(0.0, min(1.0, 1 - (dl_misalign(a) - 2)/9))

names = lambda: ", ".join(f"{'right' if DL_MARKS[f'stop{j}'][2] < 0 else 'left'} to {DL_CODE[j]}" for j in range(DL_N))
SCENES += [
    (27.5, 29.6, f"3. Dial lock: one dial numbered 0-9, a {DL_N}-digit code. Locked: the button is in"),
    (29.6, DL_MARKS["stop0"][0] + 0.8, "Inside: one notched wheel per digit; pins pick each wheel up after nearly a turn"),
    (DL_MARKS["stop0"][0] + 0.8, T_OPEN, "Dial the code like a safe: " + names()),
    (T_OPEN, T_POP + 0.5, "Every notch at the bottom: the fence rises into them and lifts the latch"),
    (T_POP + 0.5, T_POP_END, "The button pops out; on its way, a hump lifts the hammer, which snaps the front wheel home: the code is cleared"),
    (T_POP_END, T_CASE + 2.3, "Unlocked: the bolt is down, the case slides off"),
    (T_PRESS, T_PRESS_END, "To lock, just press the button: its ramp lifts the bolt, the latch snaps into its notch"),
    (T_PRESS_END, T_END - 0.5, "Locked with one press. To open it again, the whole code has to be dialled"),
]
T4 = T_END - 0.5                        # tubular key lock
TL_CLOSE = [82, 29, -14, 35, 0, 10, 125]
SCENES += [
    (T4, T4 + 2.6, "4. Tubular key lock (printed): a hollow key, 6 pins. No key: the drivers cross into the plug"),
    (T4 + 2.6, T4 + 5.0, "The key goes in: each notch pushes its pin back to exactly the gap between plug and housing"),
    (T4 + 5.0, T4 + 7.6, "Now the plug turns: a quarter turn, and the crank's steel pin pulls the yoke and the bolt down"),
    (T4 + 7.6, T4 + 10.0, "Unlocked: the case slides off. The key's tabs are behind the face, so it can't come out"),
    (T4 + 10.0, T4 + 12.2, "Turn back: the bolt rises into the strike, and the tabs line up with their notches again"),
    (T4 + 12.2, T4 + 14.6, "Pull the key out: the springs push the drivers back across the gap, and the plug is held"),
    (T4 + 14.6, T4 + 18.0, ""),
]
DURATION = SCENES[-1][1]

def lerp(a, b, u): return [x + (y - x)*u for x, y in zip(a, b)]

def project(pt, c, W=W, H=H, fov=22.5):
    """Pixel position of a point for an OpenSCAD 2021 gimbal camera [cx,cy,cz, rx,ry,rz, dist] (as make_video.py)."""
    cx, cy, cz, rx, ry, rz, dist = c
    v = [pt[0] - cx, pt[1] - cy, pt[2] - cz]
    def rot(v, axis, a):
        a = math.radians(a); co, si = math.cos(a), math.sin(a); x, y, z = v
        if axis == 0: return [x, y*co - z*si, y*si + z*co]
        if axis == 1: return [x*co + z*si, y, -x*si + z*co]
        return [x*co - y*si, x*si + y*co, z]
    v = rot(rot(rot(v, 2, -rz), 1, -ry), 0, 90 - rx)
    depth = v[1] + dist
    f = 1/math.tan(math.radians(fov/2))
    return ((1 + f*(H/W)*v[0]/depth)*W/2, (1 - f*v[2]/depth)*H/2)

def case_off(t, t0):
    """Slide the case up the rails and back down, starting at t0 (2.2 s)."""
    return ramp(t, t0, t0 + 0.9, 0, 40) if t < t0 + 1.2 else ramp(t, t0 + 1.2, t0 + 2.1, 40, 0)

def state(t):
    p = dict(lock_type='"store"', L_tl_cut=0, L_turn=1, L_key_out=0, L_key_rot=0, L_shift=0, L_wafer=0, L_show_key=1, L_case_dy=0,
             L_dl_s=0, L_dl_rot=0, L_dl_w="[0,0,0,0,0,0]", L_dl_f=0, L_dl_l=0, L_dl_h=0, L_dl_cut=0)
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
    elif t >= T4:                                  # tubular lock
        u = t - T4
        p["lock_type"] = '"tubular"'
        p["L_key_out"] = 40 if u < 2.8 else (ramp(u, 2.8, 4.6, 40, 0) if u < 12.2 else ramp(u, 12.9, 14.3, 0, 40))
        p["L_turn"] = ramp(u, 5.8, 7.4, 1, 0) if u < 10.0 else ramp(u, 10.2, 11.8, 0, 1)
        p["L_case_dy"] = case_off(t, T4 + 7.7) if 7.7 <= u < 10.0 else 0
        wide = cam(t, T4 + 5.0, T4 + 12.2, 44, 60)
        if u < 5.0: c = TL_CLOSE
        elif u < 5.6: c = lerp(TL_CLOSE, wide, ease((u - 5.0)/0.6))
        elif u < 12.2: c = wide
        elif u < 12.8: c = lerp(wide, TL_CLOSE, ease((u - 12.2)/0.6))
        else: c = TL_CLOSE
        p["L_tl_cut"] = int(u < 5.0 or u >= 12.8)   # the pins' cut view only while the key goes in and out (it renders slowly)
    else:                                          # dial lock
        p["lock_type"] = '"dial"'; p["L_show_key"] = 0
        a = dl_state_at(t)
        sb = dl_button_at(t) if t >= T_POP else 0.0
        p["L_dl_rot"] = f"{a[0]:.2f}"
        p["L_dl_w"] = "[" + ",".join(f"{x:.2f}" for x in dl_wheel_rots(a) + [0]*(6 - DL_N)) + "]"
        f = dl_fence_at(a)
        p["L_dl_f"] = f"{f:.3f}"
        # The latch's tooth: up with the fence; riding on the button's bar while it's out; in its notch when in.
        l = 1.5 if (f > 0.75 or sb > 0.2) else f
        if t >= T_PRESS and sb <= 0.2: l = 0.0
        p["L_dl_l"] = f"{max(l, f):.3f}"
        p["L_dl_h"] = f"{dl_hammer_at(sb):.3f}"
        p["L_dl_s"] = f"{sb:.3f}"
        p["L_case_dy"] = case_off(t, T_CASE) if T_CASE <= t < T_PRESS else 0
        wide = cam(t, 27.5, T4, 44, 62)
        if t < 29.0: c = wide
        elif t < 29.6: c = lerp(wide, CLOSE, ease((t - 29.0)/0.6))
        elif t < T_POP_END: c = CLOSE           # close on the wheels (near halves cut away), the fence, latch and hammer
        elif t < T_POP_END + 0.8: c = lerp(CLOSE, wide, ease((t - T_POP_END)/0.8))
        elif t < T_PRESS - 0.6: c = wide
        elif t < T_PRESS: c = lerp(wide, CLOSE, ease((t - T_PRESS + 0.6)/0.6))
        elif t < T_PRESS_END + 0.6: c = CLOSE
        else: c = lerp(CLOSE, wide, ease(min(1, (t - T_PRESS_END - 0.6)/0.8)))
        p["L_dl_cut"] = int(29.0 <= t < T_POP_END + 0.8 or T_PRESS - 0.6 <= t < T_PRESS_END + 1.4)
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
    if 29.6 <= t < DL_MARKS["stop0"][0] + 0.8:     # part labels on the dial lock's close-up
        a = int(255*min(1, (t - 29.6)/0.4, (DL_MARKS["stop0"][0] + 0.8 - t)/0.3))
        fl = load_font(False, 19)
        _, c = state(t)
        for txt, k, (dx, dy) in DL_LABELS:
            x, y = project(DL_POINTS[k], c); tx, ty = x + dx, y + dy
            w = d.textlength(txt, font=fl); bx0 = tx - w - 16 if dx < 0 else tx
            d.line([(x, y), (tx, ty)], fill=(255, 255, 255, a), width=2)
            d.ellipse([x - 4, y - 4, x + 4, y + 4], fill=(255, 255, 255, a), outline=(20, 24, 30, a))
            d.rounded_rectangle([bx0, ty - 15, bx0 + w + 16, ty + 15], radius=6, fill=(20, 24, 30, min(a, 215)))
            d.text((bx0 + 8, ty - 12), txt, font=fl, fill=(255, 255, 255, a))
    cap = next((c for s, e, c in SCENES if s <= t < e), "")
    if cap:
        f = load_font(False, 24)
        d.rectangle([0, H - 78, W, H], fill=(20, 24, 30, 205))
        d.text(((W - d.textlength(cap, font=f))/2, H - 56), cap, font=f, fill=(255, 255, 255, 255))
    if t < 3.0 or t >= SCENES[-1][0]:
        a = int(255*min(1, min(t, DURATION - t)/0.6 + 0.2))
        title, sub = (("How the locks work", "Handlebar phone dock v0.5: one dock, four lock cartridges") if t < 3.0 else
                      ("Store, push-key, dial or tubular lock", "Same dock, cover, steel bolt and strike  |  CAD: phone_dock_v0.5.scad"))
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

#!/usr/bin/env python3
"""
Renders the mechanism demo video from mechanism_anim.scad.

Needs: openscad (2021.01+), Pillow, imageio-ffmpeg (pip install pillow imageio-ffmpeg).

  python3 make_video.py                       # full video -> mechanism_demo.mp4
  python3 make_video.py --test 5,18,30        # render a few times (s) into a contact sheet
  python3 make_video.py --frames DIR --jobs 4 # choose the frame folder / parallel renders
"""
import argparse, math, os, subprocess, sys
from concurrent.futures import ThreadPoolExecutor

HERE = os.path.dirname(os.path.abspath(__file__))
SCAD = os.path.join(HERE, "mechanism_anim.scad")
W, H, FPS = 1280, 720, 24

# ---------------------------------------------------------------- helpers
def ease(u):                       # smoothstep 0..1
    u = max(0.0, min(1.0, u)); return u*u*(3 - 2*u)
def ramp(t, t0, t1, a, b):         # eased value from a (at t0) to b (at t1)
    return a + (b - a)*ease((t - t0)/(t1 - t0))
def lerp(a, b, u):
    return [x + (y - x)*u for x, y in zip(a, b)]

TILT = 40.0
def _scad_dims():                  # read the live dock position from the CAD (it depends on arm_up)
    import re, tempfile
    with tempfile.TemporaryDirectory() as d:
        r = subprocess.run(["openscad", "-o", os.path.join(d, "x.csg"), "-D", 'PART="none"',
                            os.path.join(HERE, "..", "phone_dock_v0.5.scad")], capture_output=True, text=True)
    m = re.search(r"dock_z = ([-\d.]+), amps_offset_y = ([-\d.]+)", r.stderr)
    k = re.search(r"lock_focus = \[([-\d., ]+)\], bolt_focus = \[([-\d., ]+)\]", r.stderr)
    b = re.search(r"bolt_section = \[([-\d., ]+)\]", r.stderr)
    if not (m and k and b): sys.exit("could not read dimensions from phone_dock_v0.5.scad:\n" + r.stderr)
    vec = lambda g: tuple(float(v) for v in g.split(","))
    return float(m.group(2)), float(m.group(1)), vec(k.group(1)), vec(k.group(2)), vec(b.group(1))
AMPS_OFFSET_Y, DOCK_Z, LOCK_DOCK, BOLT_DOCK, BOLT_SECTION = _scad_dims()   # dock frame -> plate frame -> clamp frame
def dock_to_bike(p, tilt=TILT):
    x, y, z = p; y -= AMPS_OFFSET_Y; z += DOCK_Z; t = math.radians(tilt)
    return [x, y*math.cos(t) - z*math.sin(t), y*math.sin(t) + z*math.cos(t)]

# Camera = [cx, cy, cz, rx, ry, rz, dist] (OpenSCAD gimbal camera)
CENTER = [0, -35, 35]
PINS = dock_to_bike((0, -35.5, -4))
LOCK = dock_to_bike(LOCK_DOCK)
CAMSEC = dock_to_bike(BOLT_DOCK)

# ---------------------------------------------------------------- timeline
BASE_SCENES = [
    (0.0,  3.0,  ""),
    (3.0,  10.0, "Modular stack:  handlebar clamps  >  base plate  >  dock  >  slim phone case"),
    (10.0, 17.5, "Slim rear-loading case: phone drops in from behind, O-ring back cover, 4 hidden corner screws"),
    (17.5, 23.5, "Two clamps on the bar. Rotate both to set the screen tilt (shims fit 22.2 / 25.4 / 28.6 mm bars)"),
    (23.5, 30.5, "Docking: the case slides down the rails; its nose runs in the centre channel"),
    (30.5, 36.0, "Cutaway: flat pads on the nose press onto 10 pogo pins (2 rows). Power + USB data"),
    (36.0, 41.5, "Key goes in from the side, behind the top corner, well clear of the tank. Quarter turn"),
    (41.5, 46.5, "Cutaway: a flat 14 x 9 mm steel bolt rises against a steel block in the case: full-face contact"),
    (46.5, 51.5, "Rubber grommets isolate the dock and phone from vibration (motion exaggerated)"),
    (51.5, 60.5, "Upgrade later: swap the base plate for a smart base (Arduino, speakers). Same bolt patterns"),
    (60.5, 64.5, ""),
]
# Inserted after the pin cutaway: the wiring scene (9 s) and the dock-electronics scene (9 s).
# Every later scene moves back by INSERT_LEN.
WIRE_T0, WIRE_LEN = 36.0, 9.0
ELEC_T0, ELEC_LEN = 45.0, 9.0
HEAT_T0, HEAT_LEN = 54.0, 6.0
INSERT_T0, INSERT_LEN = WIRE_T0, WIRE_LEN + ELEC_LEN + HEAT_LEN
INSERT_SCENES = [
    (36.0, 40.5, "Wiring: bike USB lead wired straight in > fuse > MOSFET switch (5 V only when docked) > pins"),
    (40.5, 45.0, "Pads on the nose > cable potted through the back cover > edge channel > 90-degree plug"),
    (45.0, 48.0, "Dock board (perfboard or PCB): fuse, MOSFET switch, USB ESD, LEDs. Case off: pins dead"),
    (48.0, 51.6, "Case docks: its DET pad grounds the DET pin, the switch turns on, green DOCK LED lights"),
    (51.6, 54.0, "Case removed: the switch cuts the pins at once, so rain can't short live pins"),
    (54.0, 57.2, "Too hot: the thermostat behind the phone opens at 45 C. Charging stops, red OFF LED lights"),
    (57.2, 60.0, "Cooled to about 30 C: it closes again and charging resumes by itself (green DOCK LED)"),
]
def _scenes():
    return sorted([(s + INSERT_LEN if s >= INSERT_T0 else s, e + INSERT_LEN if e > INSERT_T0 else e, c) for s, e, c in BASE_SCENES]
                  + INSERT_SCENES)
SCENES = _scenes()
DURATION = SCENES[-1][1]
END_T = SCENES[-1][0]

def defaults():
    return dict(A_explode=0, A_tilt=TILT, A_case_dy=0, A_lock=1, A_key_in=0, A_show_key=0,
                A_wobble=0, A_wobble_z=0, A_dock_lift=0, A_plate_x=0, A_smart_x=400,
                A_highlight='""', A_section='""', A_cut=0, A_show_bar=1,
                A_case_only=0, A_phone_z=0, A_cover_z=0, A_show_mount=1, A_wiring=0, A_wire=0)

WIRE_CLOSE = dock_to_bike((-14, -50, -4)) + [52, 0, 338, 165]   # dock end: socket, board, pin wires
WIRE_WIDE = dock_to_bike((18, -22, 0)) + [52, 0, 340, 400]     # whole path through the case
def wiring_state(u):
    """Wiring scene, u = seconds into it: x-ray view, power highlight runs from the bike lead to the phone.
    First half: close on the dock end while it reaches the pads. Second half: pull back as it runs to the phone."""
    p = defaults()
    if u < 4.5: w = 0.5*max(0.0, min(1.0, (u - 0.4)/3.8))
    else:       w = 0.5 + 0.5*max(0.0, min(1.0, (u - 4.7)/3.6))
    p.update(A_wiring=1, A_show_mount=0, A_show_bar=0, A_wire=w)
    cam = lerp(WIRE_CLOSE, WIRE_WIDE, ease((u - 4.0)/1.2))
    return p, cam

def _label_points():               # anchors echoed by mechanism_anim.scad, so they follow the CAD
    import re, tempfile, ast
    with tempfile.TemporaryDirectory() as d:
        r = subprocess.run(["openscad", "-o", os.path.join(d, "x.csg"), SCAD], capture_output=True, text=True)
    m = re.search(r"label_points = (\[.*\])", r.stderr)
    if not m: sys.exit("could not read label points from mechanism_anim.scad:\n" + r.stderr)
    pts = ast.literal_eval(m.group(1))
    keys = ["socket", "led_pwr", "led_dock", "u1", "u2", "res", "pins", "pad", "potting", "channel", "plug", "therm", "led_off", "esd"]
    return dict(zip(keys, [tuple(p) for p in pts]))
SCAD_LABEL_POINTS = _label_points()

ELEC_CAM = dock_to_bike((-15, -41.5, -4)) + [40, 0, 0, 115]    # square-on to the dock face (dock +z is 40 deg from up)
CASE_OFF = 60.0
def elec_state(u):
    """Dock-electronics scene, u = seconds into it. Case off -> docks -> removed again; the highlight stops
    at the switch (power_path point 3) while undocked and runs on to the pads (point 7) once docked."""
    p = defaults()
    if u < 3.0:   dy = CASE_OFF
    elif u < 7.2: dy = ramp(u, 3.0, 5.0, CASE_OFF, 0)
    else:         dy = ramp(u, 7.2, 8.2, 0, CASE_OFF)
    docked = dy <= 0.5
    if u < 3.0:   seg = ramp(u, 0.3, 1.8, 0, 3)
    elif docked:  seg = ramp(u, 5.1, 6.0, 3, 7)
    else:         seg = 3
    moving = 0.3 < u < 1.8 or (docked and 5.1 < u < 6.0)
    p.update(A_wiring=1, A_show_mount=0, A_show_bar=0, A_case_dy=dy, A_wire_seg=seg, A_det=int(docked), A_head=int(moving))
    return p, list(ELEC_CAM)

def heat_cam(): return dock_to_bike((8, -30, 0)) + [40, 0, 0, 300]
def heat_state(u):
    """Thermal cut-off scene: docked and charging, then the thermostat opens (too hot), then recloses."""
    hot = 1.0 <= u < 3.6
    p = defaults()
    p.update(A_wiring=1, A_show_mount=0, A_show_bar=0, A_hot=int(hot), A_det=int(not hot), A_head=0,
             A_wire_seg=3 if hot else 15)
    return p, list(heat_cam())
def heat_labels():
    L = SCAD_LABEL_POINTS
    return [("Thermostat, 45 C (behind the phone)", L["therm"], (60, -110)),
            ("PWR", L["led_pwr"], (-50, 60)), ("DOCK", L["led_dock"], (-30, 70)), ("OFF", L["led_off"], (40, 70))]

# Labels: (text, dock-frame anchor, text offset in px). Shown in the dock-electronics scene.
def elec_labels():
    L = SCAD_LABEL_POINTS
    return [("Bike lead, wired in + potted", L["socket"], (-150, 60)),
            ("PWR LED (yellow)", L["led_pwr"], (-90, 40)),
            ("DOCK LED (green)", L["led_dock"], (60, 110)),
            ("OFF LED (red)", L["led_off"], (220, 60)),
            ("Q2 P-MOSFET switch (AO3401A)", L["u1"], (60, -170)),
            ("F1 resettable fuse 1.5 A", L["u2"], (-150, -40)),
            ("U3 USB ESD (USBLC6)", L["esd"], (-120, -95)),
            ("Resistors", L["res"], (-140, -175)),
            ("10 pogo pins (P75), 2 rows", L["pins"], (40, -150))]

def labels_for(t):
    if ELEC_T0 <= t < ELEC_T0 + ELEC_LEN:
        return [(txt, dock_to_bike(pt), off) for txt, pt, off in elec_labels()]
    if HEAT_T0 <= t < HEAT_T0 + HEAT_LEN:
        return [(txt, dock_to_bike(pt), off) for txt, pt, off in heat_labels()]
    return []

def project(pt, cam, W=W, H=H, fov=22.5):
    """Pixel position of a bike-frame point for an OpenSCAD 2021 gimbal camera [cx,cy,cz, rx,ry,rz, dist]."""
    cx, cy, cz, rx, ry, rz, dist = cam
    v = [pt[0] - cx, pt[1] - cy, pt[2] - cz]
    def rot(v, axis, a):
        a = math.radians(a); c, s_ = math.cos(a), math.sin(a); x, y, z = v
        if axis == 0: return [x, y*c - z*s_, y*s_ + z*c]
        if axis == 1: return [x*c + z*s_, y, -x*s_ + z*c]
        return [x*c - y*s_, x*s_ + y*c, z]
    v = rot(rot(rot(v, 2, -rz), 1, -ry), 0, 90 - rx)     # checked against marker renders: within ~6 px
    depth = v[1] + dist                                     # eye at (0, -dist, 0) looking along +y, z up
    f = 1/math.tan(math.radians(fov/2))
    return ((1 + f*(H/W)*v[0]/depth)*W/2, (1 - f*v[2]/depth)*H/2)

def state(t):
    """Return (scad_params dict, camera list, caption) for time t (s)."""
    cap = next((c for s, e, c in SCENES if s <= t < e), "")
    if WIRE_T0 <= t < WIRE_T0 + WIRE_LEN:
        p, cam = wiring_state(t - WIRE_T0)
    elif ELEC_T0 <= t < ELEC_T0 + ELEC_LEN:
        p, cam = elec_state(t - ELEC_T0)
    elif HEAT_T0 <= t < HEAT_T0 + HEAT_LEN:
        p, cam = heat_state(t - HEAT_T0)
    else:
        p, cam = base_state(t - INSERT_LEN if t >= INSERT_T0 + INSERT_LEN else t)
    return p, cam, cap

def base_state(t):
    """(scad_params, camera) on the original timeline (no wiring scene)."""
    p = defaults()

    if t < 3.0:                                         # title: slow orbit, assembled, locked
        cam = [0, -35, 40, 62, 0, 330 + 12*t/3, 700]
    elif t < 10.0:                                      # explode / collapse
        p["A_explode"] = ramp(t, 3.5, 5.5, 0, 60) if t < 7.5 else ramp(t, 7.5, 9.5, 60, 0)
        cam = [0, -75, 95, 72, 0, 38 + 25*ease((t-3)/7), 880]
    elif t < 17.5:                                      # case construction (case only)
        p["A_case_only"] = 1
        p["A_phone_z"] = ramp(t, 10.5, 12.5, -45, 0)
        p["A_cover_z"] = ramp(t, 13.0, 15.0, -75, 0)
        if 12.5 <= t < 16.0: p["A_highlight"] = '"oring"'
        if t < 15.8:
            cam = [0, 0, -10, 128, 0, 20 + 10*ease((t-10)/5.8), 430]
        else:
            u = ease((t-15.8)/1.5)
            cam = [0, 0, 8, 128 - 73*u, 0, 30 - 30*u + 0, 430 - 40*u]
    elif t < 23.5:                                      # tilt by rotating the clamps
        if t < 19.5: p["A_tilt"] = ramp(t, 18.0, 19.5, 40, 15)
        elif t < 21.5: p["A_tilt"] = ramp(t, 19.5, 21.5, 15, 60)
        else: p["A_tilt"] = ramp(t, 21.5, 23.0, 60, 40)
        p["A_highlight"] = '"clamps"'
        cam = [0, -30, 30, 88, 0, 90, 600]
    elif t < 30.5:                                      # docking slide
        p["A_lock"] = 0
        p["A_case_dy"] = ramp(t, 24.0, 29.0, 90, 0)
        cam = lerp([0, -10, 60, 66, 0, 55, 620], [0, -30, 40, 70, 0, 68, 520], ease((t-23.5)/7))
    elif t < 36.0:                                      # pins, x-section through the middle pin
        p["A_lock"] = 0
        p["A_case_dy"] = ramp(t, 31.0, 34.5, 7, 0)
        p["A_section"] = '"x"'; p["A_cut"] = -1.27; p["A_show_bar"] = 0   # through a pin
        p["A_highlight"] = '"pins"'
        cam = PINS + [90, 0, 90, 50]
    elif t < 41.5:                                      # key in + turn
        p["A_show_key"] = 1
        p["A_key_in"] = ramp(t, 36.5, 38.3, 0, 1)
        p["A_lock"] = ramp(t, 38.8, 40.3, 0, 1)
        p["A_highlight"] = '"lock"'
        cam = LOCK + [70, 0, 60, 360]
    elif t < 46.5:                                      # y-section through the cam plane
        p["A_lock"] = ramp(t, 42.5, 44.5, 0, 1)
        # Side cut through the bolt's centre (keep x < bolt_x), seen from the cut side: the bolt rises beside its
        # key-steel bearing block.
        p["A_section"] = '"x"'; p["A_cut"] = BOLT_SECTION[0]; p["A_show_bar"] = 0; p["A_show_mount"] = 0
        p["A_highlight"] = '"lock"'
        cam = dock_to_bike((BOLT_SECTION[0], BOLT_SECTION[1] + 2, -10)) + [90, 0, 90, 120]
    elif t < 51.5:                                      # vibration on grommets
        u = t - 47.0
        if u > 0:
            env = math.exp(-u*0.9)
            p["A_wobble"] = 3.0*env*math.sin(2*math.pi*2.2*u)
            p["A_wobble_z"] = 1.5*env*math.sin(2*math.pi*3.1*u + 1)
        p["A_highlight"] = '"grommets"'
        cam = [0, -35, 35, 72, 0, 300, 480]
    elif t < 60.5:                                      # base plate -> smart base
        if t < 54.5:
            p["A_dock_lift"] = ramp(t, 52.0, 53.5, 0, 70)
            p["A_plate_x"] = ramp(t, 53.5, 54.5, 0, -320)
            if t >= 53.5: p["A_smart_x"] = 400
        else:
            p["A_dock_lift"] = ramp(t, 57.0, 58.5, 70, 0)
            p["A_plate_x"] = 400
            p["A_smart_x"] = ramp(t, 54.5, 56.5, 320, 0)
        cam = [0, -60, 80, 72, 0, 45, 880]
    else:                                               # end orbit with the smart base
        p["A_plate_x"] = 400; p["A_smart_x"] = 0
        cam = [0, -35, 40, 62, 0, 330 + 40*ease((t-60.5)/4), 700]
    return p, cam

# ---------------------------------------------------------------- render
def render_frame(i, t, outdir):
    p, cam, cap = state(t)
    png = os.path.join(outdir, f"raw_{i:05d}.png")
    cmd = ["openscad", "-o", png, f"--imgsize={W},{H}", "--colorscheme=Tomorrow",
           "--camera=" + ",".join(f"{v:.3f}" for v in cam)]
    for k, v in p.items():
        cmd += ["-D", f"{k}={v}"]
    cmd.append(SCAD)
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(png):
        raise RuntimeError(f"frame {i} (t={t:.2f}) failed:\n{r.stderr[-800:]}")
    return png, cap, t

def draw_labels(d, labels, cam, a, fl, size=(W, H)):
    """Part labels: a dot on the part, a leader line, and a dark tag at the given pixel offset."""
    for txt, pt, (dx, dy) in labels:
        x, y = project(pt, cam, *size)
        tx, ty = x + dx, y + dy
        w = d.textlength(txt, font=fl)
        bx0 = tx - w - 16 if dx < 0 else tx
        d.line([(x, y), (tx, ty)], fill=(255, 255, 255, a), width=2)
        d.ellipse([x - 4, y - 4, x + 4, y + 4], fill=(255, 255, 255, a), outline=(20, 24, 30, a))
        d.rounded_rectangle([bx0, ty - 15, bx0 + w + 16, ty + 15], radius=6, fill=(20, 24, 30, min(a, 215)))
        d.text((bx0 + 8, ty - 12), txt, font=fl, fill=(255, 255, 255, a))

# Labelled x-ray stills of the wiring for WIRING.md (python3 make_video.py --stills).
CASE_CAM = dock_to_bike((22, -8, 4)) + [40, 0, 0, 330]
def case_labels():
    L = SCAD_LABEL_POINTS
    return [("Pad board in the shoe nose (DET via thermostat, PRESENT to GND)", L["pad"], (40, 150)),
            ("Cable potted through the nose and back cover", L["potting"], (-80, -190)),
            ("4-core cable in the bottom-edge channel", L["channel"], (80, -70)),
            ("90-degree plug in the USB bay (USB-C or micro-USB)", L["plug"], (-40, -150)),
            ("Thermostat (45 C NC) in the DET loop", L["therm"], (60, -260))]
def stills(outdir, size=(1600, 900)):
    from PIL import Image, ImageDraw, ImageFont
    # Docked, LEDs on, no flow highlight, so the real wire colours show.
    p_dock = defaults(); p_dock.update(A_wiring=1, A_show_mount=0, A_show_bar=0, A_wire_seg=0, A_head=0)
    p_case = dict(p_dock)
    dock_labels = elec_labels() + [("8 wires: DET, VBUS, D+, D-, GND, PRESENT + 2 spares (orange, purple)", (-11.0, -40.4, -5.0), (-60, 380))]
    titles = ("Dock side: bike lead wired in > fuse + MOSFET switch + ESD > 8 wires > 10 pogo pins",
              "Case side: pads > potted cable > edge channel > 90-degree plug > phone")
    shots = [("wiring_dock.png", p_dock, ELEC_CAM, dock_labels, titles[0]),
             ("wiring_case.png", p_case, CASE_CAM, case_labels(), titles[1])]
    sw, sh = size
    for name, p, cam, labels, title in shots:
        png = os.path.join(outdir, name)
        cmd = ["openscad", "-o", png, f"--imgsize={sw},{sh}", "--colorscheme=Tomorrow", "--camera=" + ",".join(f"{v:.3f}" for v in cam)]
        for k, v in p.items(): cmd += ["-D", f"{k}={v}"]
        subprocess.run(cmd + [SCAD], capture_output=True, check=True)
        im = Image.open(png).convert("RGB"); d = ImageDraw.Draw(im, "RGBA")
        try: fl, ft = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20), ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 24)
        except OSError: fl = ft = ImageFont.load_default()
        draw_labels(d, [(t, dock_to_bike(pt), off) for t, pt, off in labels], cam, 255, fl, size)
        d.rectangle([0, 0, sw, 50], fill=(20, 24, 30, 215)); d.text((20, 12), title, font=ft, fill=(255, 255, 255, 255))
        im.save(png); print("wrote", png)

def annotate(png, cap, t, out):
    from PIL import Image, ImageDraw, ImageFont
    im = Image.open(png).convert("RGB")
    d = ImageDraw.Draw(im, "RGBA")
    fdir = "/usr/share/fonts/truetype/dejavu/"
    def font(name, size):
        try: return ImageFont.truetype(fdir + name, size)
        except OSError: return ImageFont.load_default()
    # Part labels: a dot on the part, a leader line, and a dark tag at the given pixel offset.
    labels = labels_for(t)
    if labels:
        _, cam, _ = state(t)
        t0, t1 = (ELEC_T0, ELEC_T0 + ELEC_LEN) if t < HEAT_T0 else (HEAT_T0, HEAT_T0 + HEAT_LEN)
        draw_labels(d, labels, cam, int(255*min(1, (t - t0)/0.5, (t1 - t)/0.3)), font("DejaVuSans.ttf", 19))
    if cap:
        d.rectangle([0, H-78, W, H], fill=(20, 24, 30, 205))
        f = font("DejaVuSans.ttf", 25)
        w = d.textlength(cap, font=f)
        d.text(((W-w)/2, H-56), cap, font=f, fill=(255, 255, 255, 255))
    if t < 3.0 or t >= END_T:
        a = int(255*min(1, (min(t, DURATION - t))/0.6 + 0.2))
        d.rectangle([0, 0, W, 150], fill=(20, 24, 30, min(215, a)))
        f1, f2 = font("DejaVuSans-Bold.ttf", 44), font("DejaVuSans.ttf", 24)
        title = "Modular handlebar navigation dock" if t < 3 else "Concept v0.5: every dimension is parametric"
        sub = ("v0.5 slim case + compact dock: how it works" if t < 3
               else "CAD: phone_dock_v0.5.scad  |  not yet road-tested")
        d.text(((W - d.textlength(title, font=f1))/2, 30), title, font=f1, fill=(255, 255, 255, a))
        d.text(((W - d.textlength(sub, font=f2))/2, 92), sub, font=f2, fill=(200, 210, 220, a))
    im.save(out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--frames", default=None)
    ap.add_argument("--out", default=None)
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    ap.add_argument("--test", default="")
    ap.add_argument("--stills", nargs="?", const=os.path.join(HERE, "..", "images"), default=None,
                    help="write the labelled wiring stills (default: ../images) and exit")
    a = ap.parse_args()
    a.frames = a.frames or os.path.join(HERE, "frames")
    a.out = a.out or os.path.join(HERE, "mechanism_demo.mp4")
    if a.stills:
        stills(a.stills); return
    os.makedirs(a.frames, exist_ok=True)

    if a.test:
        times = [float(x) for x in a.test.split(",")]
        with ThreadPoolExecutor(a.jobs) as ex:
            res = list(ex.map(lambda it: render_frame(it[0], it[1], a.frames), enumerate(times)))
        from PIL import Image
        outs = []
        for i, (png, cap, t) in enumerate(res):
            o = os.path.join(a.frames, f"test_{i:02d}.png"); annotate(png, cap, t, o); outs.append(o)
        cols = 2; rows = (len(outs)+1)//2
        sheet = Image.new("RGB", (W*cols//2, H*rows//2), "white")
        for i, o in enumerate(outs):
            sheet.paste(Image.open(o).resize((W//2, H//2)), ((i % cols)*W//2, (i//cols)*H//2))
        sheet.save(os.path.join(a.frames, "contact_sheet.png")); print(os.path.join(a.frames, "contact_sheet.png"))
        return

    n = int(DURATION*FPS)
    done = [0]
    def job(i):
        t = i/FPS
        final = os.path.join(a.frames, f"f_{i:05d}.png")
        if not os.path.exists(final):
            png, cap, _ = render_frame(i, t, a.frames); annotate(png, cap, t, final); os.remove(png)
        done[0] += 1
        if done[0] % 48 == 0: print(f"{done[0]}/{n} frames", flush=True)
    with ThreadPoolExecutor(a.jobs) as ex:
        list(ex.map(job, range(n)))

    import imageio_ffmpeg
    ff = imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run([ff, "-y", "-loglevel", "error", "-framerate", str(FPS), "-i", os.path.join(a.frames, "f_%05d.png"),
                    "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "20", "-movflags", "+faststart", a.out], check=True)
    print("wrote", a.out)

if __name__ == "__main__":
    main()

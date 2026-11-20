#!/usr/bin/env python3
"""Writes the wiring diagrams (WIRING.md): the whole harness, or one side of it with its own title and legend.

  python3 make_wiring_diagram.py wiring_diagram.svg              # bike -> dock board -> pins/pads -> case -> phone
  python3 make_wiring_diagram.py wiring_diagram_dock.svg dock    # bike lead -> dock board -> 10 pogo pins
  python3 make_wiring_diagram.py wiring_diagram_case.svg case    # pads -> thermostat -> case cable -> phone plug

Bike USB lead (wired straight in, potted) -> dock board, hand-wired perfboard or a small PCB (PTC fuse, AO3401A
P-MOSFET switch, USBLC6 ESD, 3 mm LEDs, 2N7002 OFF-LED driver, JP1 charge-only jumper) -> 10 x P75 pogo pins in
2 rows -> pad strip (DET via thermostat, PRESENT to GND) -> 4-core cable (power + USB data) -> phone.
Hand-placed layout: if the circuit in WIRING.md changes, edit the coordinates here to match.
"""
import sys

VARIANT = sys.argv[2] if len(sys.argv) > 2 else "full"
assert VARIANT in ("full", "dock", "case"), "variant must be full, dock or case"
# Each variant is a window onto the same drawing (x0, y0, width, height); the side views are taller for their legends.
VIEW = {"full": (0, 0, 1500, 1000), "dock": (10, 0, 1012, 1100), "case": (920, 0, 570, 1100)}[VARIANT]
VX = VIEW[0]
out = []
def add(s): out.append(s)

C = dict(det="#e0b000", vbus="#d62828", dm="#b8b8b8", gnd="#222222", dp="#22a03a", present="#2659f2",
         ink="#1f2329", sub="#5b6370", board="#eaf4ec", boardline="#2f7d4a",
         amber="#ffb000", green="#2bd84f", red="#ff2a1a", gold="#d9a520", sheath="#555a60")
FONT = "font-family='DejaVu Sans, Arial, sans-serif'"

def text(x, y, s, size=14, anchor="start", weight="normal", fill=C["ink"], italic=False):
    st = " font-style='italic'" if italic else ""
    add(f"<text x='{x}' y='{y}' font-size='{size}' text-anchor='{anchor}' font-weight='{weight}' fill='{fill}' {FONT}{st}>{s}</text>")
def line(pts, color=C["ink"], w=1.6, dash=None):
    d = " ".join(f"{x},{y}" for x, y in pts)
    da = f" stroke-dasharray='{dash}'" if dash else ""
    add(f"<polyline points='{d}' fill='none' stroke='{color}' stroke-width='{w}' stroke-linejoin='round' stroke-linecap='round'{da}/>")
def wire(pts, color, w=4.5):
    if color == C["dm"]: line(pts, "#6d6d6d", w + 2)
    line(pts, color, w)
def rect(x, y, w, h, fill="none", stroke=C["ink"], sw=1.6, r=6, dash=None):
    da = f" stroke-dasharray='{dash}'" if dash else ""
    add(f"<rect x='{x}' y='{y}' width='{w}' height='{h}' rx='{r}' fill='{fill}' stroke='{stroke}' stroke-width='{sw}'{da}/>")
def dot(x, y, r=3.5, fill=C["ink"]): add(f"<circle cx='{x}' cy='{y}' r='{r}' fill='{fill}'/>")
def gnd(x, y):
    line([(x, y), (x, y + 8)])
    for i, hw in enumerate((9, 6, 3)): line([(x - hw, y + 8 + 4*i), (x + hw, y + 8 + 4*i)])
def res_v(x, y0, y1, label, lx=10, anchor="start"):
    n = 6; h = (y1 - y0 - 10)/n
    pts = [(x, y0), (x, y0 + 5)] + [(x + (6 if i % 2 == 0 else -6), y0 + 5 + h*(i + 0.5)) for i in range(n)] + [(x, y1 - 5), (x, y1)]
    line(pts); text(x + lx, (y0 + y1)/2 + 4, label, 12, anchor, fill=C["sub"])
def res_h(x0, x1, y, label):
    n = 6; w = (x1 - x0 - 10)/n
    pts = [(x0, y), (x0 + 5, y)] + [(x0 + 5 + w*(i + 0.5), y + (6 if i % 2 == 0 else -6)) for i in range(n)] + [(x1 - 5, y), (x1, y)]
    line(pts); text((x0 + x1)/2, y - 10, label, 12, "middle", fill=C["sub"])
def cap_v(x, y0, label):
    line([(x, y0), (x, y0 + 8)]); line([(x - 9, y0 + 8), (x + 9, y0 + 8)], w=2.2)
    line([(x - 9, y0 + 14), (x + 9, y0 + 14)], w=2.2); line([(x, y0 + 14), (x, y0 + 22)])
    text(x + 13, y0 + 16, label, 12, fill=C["sub"])
def led_v(x, y0, colour, label, lx=14):
    line([(x, y0), (x, y0 + 5)])
    add(f"<polygon points='{x-8},{y0+5} {x+8},{y0+5} {x},{y0+18}' fill='{colour}' stroke='{C['ink']}' stroke-width='1.4'/>")
    line([(x - 8, y0 + 18), (x + 8, y0 + 18)], w=2); line([(x, y0 + 18), (x, y0 + 24)])
    for dx in (0, 6): line([(x + 10 + dx, y0 + 6), (x + 17 + dx, y0 - 1)], colour, 1.6)
    text(x + lx, y0 + 16, label, 12, weight="bold")

x0, y0, vw, vh = VIEW
add(f"<svg xmlns='http://www.w3.org/2000/svg' width='{vw}' height='{vh}' viewBox='{x0} {y0} {vw} {vh}'>")
add(f"<rect x='{x0}' y='{y0}' width='{vw}' height='{vh}' fill='#ffffff'/>")
TITLE = {"full": ("Complete wiring, bike to phone",
                  "Power + USB data, no connectors. Dock board: hand-wired perfboard or a small PCB (same circuit). Wire colours are the physical wires; thin black lines are board tracks."),
         "dock": ("Dock side: bike lead > dock board > 10 pogo pins",
                  "Dock board: hand-wired perfboard or a small PCB, same circuit. Thin black lines are board tracks."),
         "case": ("Case side: pads > cable > phone", "Everything here comes off with the phone.")}[VARIANT]
text(VX + 24, 38, TITLE[0], 22, weight="bold")
text(VX + 24, 62, TITLE[1], 14 if VARIANT == "full" else 13, fill=C["sub"])
for x0, x1, label in ((20, 236, "BIKE"), (252, 1018, "DOCK  (stays on the bike)"), (1022, 1480, "CASE  (comes off with the phone)")):
    rect(x0, 78, x1 - x0, 26, fill="#f3f4f6", stroke="none", r=4); text((x0 + x1)/2, 96, label, 14, "middle", "bold", C["sub"])

# ---------------------------------------------------------------- bike
rect(28, 290, 196, 128, fill="#f7f7f7")
text(126, 318, "Bike USB supply", 15, "middle", "bold")
for i, s_ in enumerate(("the bike's own USB socket,", "or a 12 V handlebar USB", "charger wired after the", "ignition (USB-A out)")):
    text(126, 340 + 18*i, s_, 12, "middle", fill=C["sub"])
line([(224, 354), (262, 354)], C["sheath"], 9)
text(126, 440, "USB-A lead, cut and wired in", 11, "middle", fill=C["sub"]); text(126, 454, "(all 4 wires used)", 11, "middle", fill=C["sub"])

# ---------------------------------------------------------------- dock board (perfboard)
rect(262, 120, 620, 660, fill=C["board"], stroke=C["boardline"], sw=2, r=10)
text(278, 142, "DOCK BOARD: perfboard or PCB in the receiver pocket, potted in clear epoxy", 13, weight="bold", fill=C["boardline"])
text(278, 160, "lead enters through a potted hole in the dock's lower edge", 11, fill=C["sub"])
wire([(262, 350), (300, 300), (330, 300)], C["vbus"], 3.5)
wire([(262, 356), (300, 470), (380, 470)], C["dp"], 3.5)
wire([(262, 358), (300, 500), (380, 500)], C["dm"], 3.5)
wire([(262, 360), (284, 560), (330, 560)], C["gnd"], 3.5)
text(304, 292, "VBUS_RAW", 10, fill=C["sub"])
# PWR LED from VBUS_RAW
dot(345, 300); res_v(345, 300, 338, "R6 1k", 10); led_v(345, 338, C["amber"], "D1 PWR"); gnd(345, 362)
# PTC fuse
line([(330, 300), (395, 300)])
rect(395, 288, 50, 24, fill="#fff"); text(420, 305, "F1", 11, "middle", "bold"); text(420, 330, "PTC 1.5 A", 10, "middle", fill=C["sub"])
line([(445, 300), (520, 300)]); dot(470, 300); text(450, 292, "VBUS_IN", 10, fill=C["sub"])
cap_v(470, 300, ""); gnd(470, 322); text(470, 356, "C1 10 µF", 11, "middle", fill=C["sub"])
# R3 pull-up VBUS_IN -> gate/DET node
dot(500, 300); res_v(500, 210, 300, "R3 100k", -8, "end"); dot(500, 210)
# Q2 P-MOSFET
rect(520, 270, 96, 60, fill="#fff"); text(568, 296, "Q2", 13, "middle", "bold"); text(568, 312, "AO3401A", 10, "middle"); text(568, 324, "P-MOSFET", 9, "middle", fill=C["sub"])
text(524, 296, "S", 9, fill=C["sub"]); text(612, 296, "D", 9, "end", fill=C["sub"]); text(574, 282, "G", 9, fill=C["sub"])
line([(568, 270), (568, 210)]); dot(568, 210)
line([(500, 210), (640, 210)]); res_h(640, 700, 210, "R5 1k"); line([(700, 210), (870, 210)])
text(720, 200, "DET (pulled high = switch OFF)", 10, fill=C["sub"])
# VBUS_OUT
line([(616, 300), (870, 300)]); text(640, 292, "VBUS_OUT", 10, fill=C["sub"])
dot(660, 300); res_v(660, 300, 338, "R7 1k", 10); led_v(660, 338, C["green"], "D2 DOCK"); gnd(660, 362)
# USB data through the ESD chip, JP1
rect(380, 452, 90, 66, fill="#fff"); text(425, 476, "U3 ESD", 12, "middle", "bold"); text(425, 490, "USBLC6-2SC6", 9, "middle"); text(425, 503, "(VBUS pin to VBUS_IN)", 7, "middle", fill=C["sub"])
line([(425, 518), (425, 526)]); gnd(425, 526)
line([(470, 470), (870, 470)]); line([(470, 500), (870, 500)])
text(490, 464, "D+", 10, fill=C["sub"]); text(490, 494, "D-", 10, fill=C["sub"])
dot(580, 470); dot(580, 500); line([(580, 470), (580, 478)]); line([(580, 492), (580, 500)])
add("<rect x='574' y='478' width='12' height='5' fill='#c8a24a'/><rect x='574' y='487' width='12' height='5' fill='#c8a24a'/>")
text(594, 488, "JP1 (open)", 10, weight="bold"); text(670, 488, "solder shut = charge-only fast charging", 9, fill=C["sub"])
# GND rail
line([(330, 560), (870, 560)]); text(760, 552, "GND", 10, fill=C["sub"])
# red OFF LED + Q1
text(540, 596, "VBUS_RAW", 9, "middle", fill=C["sub"]); res_v(540, 600, 638, "R8 1k", -8, "end"); dot(540, 640)
led_v(540, 640, C["red"], ""); text(520, 656, "D3 OFF", 12, "end", weight="bold"); dot(540, 670)
line([(540, 670), (540, 720), (870, 720)]); text(780, 712, "PRESENT", 10, fill=C["sub"])
rect(590, 628, 62, 52, fill="#fff"); text(621, 650, "Q1", 12, "middle", "bold"); text(621, 665, "2N7002", 9, "middle", fill=C["sub"])
line([(540, 640), (590, 640)]); line([(540, 670), (590, 670)]); text(594, 638, "D", 8, fill=C["sub"]); text(594, 677, "S", 8, fill=C["sub"])
line([(652, 654), (720, 654)]); dot(720, 654); text(646, 651, "G", 8, "end", fill=C["sub"])
text(720, 592, "VBUS_OUT", 9, "middle", fill=C["sub"]); res_v(720, 596, 650, "R9 10k", 8)
res_v(720, 658, 694, "R10 100k", 8); gnd(720, 694)
text(278, 768, "Q1 shorts D3 while charging. Perfboard: solder Q1, Q2 (SOT-23) and U3 (SOT-23-6) on with short wire legs.", 11, fill=C["sub"])

# ---------------------------------------------------------------- 6 wires -> pogo pins
PIN_Y = [210, 300, 470, 500, 560, 720]
COLS = [C["det"], C["vbus"], C["dp"], C["dm"], C["gnd"], C["present"]]
NAMES = ["DET", "VBUS", "D+", "D-", "GND", "PRESENT"]
for y, col in zip(PIN_Y, COLS): wire([(870, y), (930, y)], col)
if VARIANT != "case": text(900, 806, "8 wires", 11, "middle", fill=C["sub"])
rect(930, 170, 70, 590, fill="#f4f4f4")
text(965, 780, "10 x P75", 11, "middle", "bold"); text(965, 794, "POGO PINS", 11, "middle", "bold")
if VARIANT != "case":
    rect(560, 796, 300, 54, fill="#fffbe8", stroke="#c8a24a")
    text(570, 814, "Pin row 2: VBUS2 + GND2 bridged to VBUS and", 10, weight="bold")
    text(570, 828, "GND on the pin strip (doubled power contacts);", 10, fill=C["sub"]); text(570, 842, "SPARE1 + SPARE2 wired to 2 spare board pads.", 10, fill=C["sub"])
for i, (y, n) in enumerate(zip(PIN_Y, NAMES)):
    text(965, y - 10, f"{i+1} {n}", 10, "middle", "bold"); line([(1000, y), (1012, y)], C["gold"], 3); dot(1014, y, 3.5, C["gold"])
line([(1020, 150), (1020, 820)], C["sub"], 1.6, "6,5")
if VARIANT != "dock": text(1024, 135, "contacts mate when the case is docked;", 10, fill=C["sub"]); text(1024, 148, "the printed snap holds it there", 10, fill=C["sub"])

# ---------------------------------------------------------------- pad board + case
rect(1028, 170, 70, 590, fill="#f4f4f4")
text(1063, 780, "PAD STRIP", 11, "middle", "bold"); text(1066, 794, "(perfboard/PCB,", 10, "middle", fill=C["sub"]); text(1066, 807, "in shoe nose)", 10, "middle", fill=C["sub"])
for y in PIN_Y: add(f"<rect x='1028' y='{y-9}' width='7' height='18' fill='{C['gold']}'/>")
line([(1035, 560), (1080, 560)], C["gnd"], 2.2); line([(1080, 236), (1080, 720), (1035, 720)], C["gnd"], 2.2); dot(1080, 560, 3.5, C["gnd"])
text(1104, 742, "PRESENT tied to GND", 9, fill=C["sub"])
wire([(1035, 210), (1140, 210)], C["det"], 3.5); wire([(1080, 236), (1140, 236)], C["gnd"], 3.5)
rect(1140, 186, 200, 76, fill="#fff4f0", stroke="#c0392b")
text(1150, 206, "TH1 thermostat, 45 °C NC", 11, weight="bold")
for i, s_ in enumerate(("KSD9700, on the phone's back.", "Opens when too hot: DET high,", "charging off, red OFF LED on.")):
    text(1150, 222 + 13*i, s_, 10, fill=C["sub"])
for y, col in ((300, C["vbus"]), (470, C["dp"]), (500, C["dm"]), (560, C["gnd"])):
    wire([(1098, y), (1118, y), (1150, 440)], col, 3.5)
line([(1150, 440), (1300, 440)], C["sheath"], 12)
text(1160, 480, "Case cable", 12, weight="bold")
for i, s_ in enumerate(("6-8 cm of a USB-A to 90°", "plug lead: red VBUS, green", "D+, white D-, black GND;", "shield to GND. Potted", "through the nose and back", "cover (with the 2", "thermostat leads).")):
    text(1160, 497 + 15*i, s_, 11, fill=C["sub"])
line([(1300, 440), (1330, 440), (1330, 250), (1345, 250)], C["sheath"], 8)
line([(1330, 440), (1330, 540), (1345, 540)], C["sheath"], 8, "10,6")
rect(1345, 190, 125, 130, fill="#fff"); text(1407, 212, "USB-C phone", 13, "middle", "bold")
for i, s_ in enumerate(("90° USB-C plug", "(factory cable: its", "56 kΩ CC resistor", "is already inside)")):
    text(1355, 232 + 16*i, s_, 10, fill=C["sub"])
text(1407, 420, "OR", 14, "middle", "bold", C["sub"])
rect(1345, 470, 125, 130, fill="#fff"); text(1407, 492, "Micro-USB", 13, "middle", "bold")
for i, s_ in enumerate(("90° micro-USB plug,", "cable leaving toward", "the phone's back.", "ID pin: not connected")):
    text(1355, 512 + 16*i, s_, 10, fill=C["sub"])

# ---------------------------------------------------------------- legend
LY = 912
def leds(x, y):
    text(x, y, "Status LEDs (3 mm, below the case):", 13, weight="bold")
    for i, (col, s_) in enumerate(((C["amber"], "PWR (yellow): bike power in"), (C["green"], "DOCK (green): charging"), (C["red"], "OFF (red): docked but NOT charging"))):
        add(f"<circle cx='{x+10}' cy='{y+20+20*i}' r='6' fill='{col}'/>"); text(x + 22, y + 24 + 20*i, s_, 12)
def colours(x, y, step=130, ncol=2):
    text(x, y, "Wire colours:", 13, weight="bold")
    for i, (n, col) in enumerate(zip(NAMES, COLS)):
        xx = x + (i % ncol)*step; yy = y + 22 + (i // ncol)*22
        wire([(xx, yy), (xx + 24, yy)], col, 4); text(xx + 30, yy + 4, n, 12)
def notes(x, y, title, lines):
    text(x, y, title, 13, weight="bold")
    for i, s_ in enumerate(lines): text(x, y + 24 + 20*i, s_, 12)
if VARIANT == "full":
    rect(20, LY - 26, 1460, 116, fill="#f7f8fa", stroke="#d9dce1")
    leds(36, LY - 4)
    notes(440, LY - 4, "How it works:", ("No case: R3 holds Q2's gate high, so the pins carry no power.",
          "Docked and cool: the case grounds DET through the thermostat, Q2 turns on, DOCK lights.",
          "Too hot, short (F1 trips) or bad contact: VBUS_OUT is off while PRESENT is grounded, so OFF lights.",
          "USB data passes straight through. If the phone charges slowly from your bike charger, solder JP1 shut."))
    colours(1210, LY - 4)
elif VARIANT == "dock":
    rect(20, LY - 26, 992, 200, fill="#f7f8fa", stroke="#d9dce1")
    leds(36, LY - 4)
    colours(36, LY + 86, 110)
    notes(420, LY - 4, "How it works:", ("No case: R3 holds Q2's gate high, so the pins carry no power.",
          "Docked and cool: the case grounds DET via the thermostat, Q2 turns on,",
          "  DOCK lights. Too hot, short (F1 trips) or bad contact: VBUS_OUT is off",
          "  while PRESENT is grounded, so OFF lights.",
          "USB data passes straight through. If the phone charges slowly from",
          "  your bike charger, solder JP1 shut."))
else:
    rect(930, LY - 26, 550, 200, fill="#f7f8fa", stroke="#d9dce1")
    notes(946, LY - 4, "Case side:", ("DET pad goes to GND through the thermostat; PRESENT pad",
          "  is tied to GND, so the dock knows the case is there.",
          "Pad row 2: VBUS2/GND2 pads bridged to the VBUS/GND pads;",
          "  the 2 spare pads stay unconnected, for later.",
          "Pot the cable and thermostat leads through the nose."))
    colours(946, LY + 126, 170, 3)
add("</svg>")
open(sys.argv[1], "w").write("\n".join(out))

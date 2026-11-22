# CLAUDE.md: 3D Models repository

Read this first. It records the projects, the decisions already made (don't re-open them unless asked), the owner's preferences, how to build and check everything, and the traps already hit.

## The owner and how they work

- **GitHub:** `praneth2580`. Repository `praneth2580/3D-Models`. Website: https://praneth2580.github.io/3D-Models/
- **Location:** Mumbai, India. Give **all prices in INR**, from Indian sources:
  - Amazon.in, Flipkart, Robu.in, DigiKey India, iFuturetech;
  - Lamington Road (electronics) and Nagdevi Street (screws, hardware).
  - Mark unchecked prices "(est.)".
- **No 3D printer:** parts are printed by a service, at about ₹5–10/g (FDM, PETG/ASA).
- **Soldering:** the owner does all soldering and assembly. They are comfortable with electronics and Arduino, and still learning mechanical CAD, so explain mechanical decisions in plain words.
- **Budget:** cost matters. The phone dock must stay under about **₹5,000** in total.
- **Generic naming:** the designs are **general purpose, for any motorcycle**. Never name a project or page after one bike: no "Meteor", no "Royal Enfield". A Royal Enfield Meteor 350 was the first reference bike, but every bike-specific value is a parameter.
- **One design, not variants:** the owner rejected separate "budget" and "full" builds. Keep one design. Where there's a real choice (perfboard or PCB, store lock or printed lock), present it as an option inside the one design.
- **Publishing:** everything goes on the website, free to download, licensed **CC BY-NC-SA 4.0** (`LICENSE.md`). New work in this repo is meant to appear on the site. It has been the practice to commit and push to `main` after a change, but confirm before pushing anything unusual.
- **Images:** the owner likes rendered images and the video kept in sync with the CAD. Re-render after design changes.

## Repository layout

```
README.md              project list (between <!-- projects:start/end -->), how to add a project
LICENSE.md             CC BY-NC-SA 4.0, for the whole repo unless a project has its own
CLAUDE.md              this file
.github/workflows/pages.yml   builds site/ and deploys GitHub Pages on every push to main
site/                  website generator (build.py, style.css, app.js, site.json, README.md)
phone_dock_v0.5/       Handlebar Phone Dock (main project)
display_pod_v4/        Round Display Pod (has its own CLAUDE.md design brief: follow it there)
_site/                 built website (gitignored)
```

**Never published or committed:**
- `*/reference/`: the pod's vendor datasheet, drawings and store screenshots. They are third-party copyrighted files, kept local and gitignored.
- Excluded from the website and its zips: `archive/` (old versions), `website/`, `CLAUDE.md`.

## Website (site/build.py)

- **Generator:** `python3 site/build.py` builds `_site/`, using the Python standard library only.
- **Project list:** add `--readme` to also refresh the project table in the root README.
- **Preview:** `python3 -m http.server -d _site`.
- **A project** is any top-level folder with `.stl` or `.scad` files. Each one gets:
  - a page with a gallery and video;
  - a three.js STL viewer (CDN r128);
  - a download-all zip plus single STL and DXF files;
  - "Adjust it to your hardware";
  - links to its docs.
- **Automatic adjust list:** `.scad` lines tagged `MEASURE`, `SELECT` or `PROVISIONAL` fill the adjust section, unless the project has a `website/adjust.html`.
- **Optional `<project>/website/`:** `project.json` sets title, tagline, summary, status, order, cover, video, gallery, part descriptions, DXF descriptions, exclude, sections, nav and docs. HTML sections (`features.html`, `adjust.html`, others) live in the same folder. The format is in `site/README.md`.
- **When adding STLs:** add their descriptions to `website/project.json` → `parts`, or they show with auto names.
- **Repo URL:** the build reads it from `GITHUB_REPOSITORY`, or from the git remote with credentials stripped. Never print the remote URL.
- **Pages:** the source is set to "GitHub Actions" in the repo settings (already done).

## Phone dock (phone_dock_v0.5/)

An old phone becomes a permanent handlebar navigation screen.
- **Main CAD:** `phone_dock_v0.5.scad`, OpenSCAD 2021.01, with asserts. `PART=` selects an export.
- **Printed lock:** `include <printed_lock.scad>` near the end of the main file.

**Decisions in place:**
- **Case:** slim sealed case. The phone drops in from behind, with a 2 mm polycarbonate window, an O-ring back cover and 4 hidden M3 screws.
- **Contacts:** the case slides down dovetail rails onto the dock. A nose on the shoe presses a 2-row pad strip onto **10 P75 pogo pins**:
  - **row 1:** DET, VBUS, D+, D−, GND, PRESENT;
  - **row 2:** VBUS2 and GND2 (bridged to VBUS and GND), SPARE1 and SPARE2.
- **Electronics** (one design):
  - the bike's USB lead is **wired straight in** and potted (no connector);
  - 1.5 A PTC fuse, then an AO3401A P-MOSFET switch (gate pulled up by 100k, pulled low through 1k by DET when docked);
  - USBLC6-2SC6 ESD, so USB data passes through;
  - JP1 solder jumper (D+ to D−) for charge-only fast charging;
  - 3 mm LEDs: yellow PWR, green DOCK, red OFF (shorted by a 2N7002 while VBUS_OUT is on);
  - KSD9700 45 °C NC thermostat in the case, in series with DET (over-heat cut-off);
  - dock board 21.5 × 14.5 × 1.6 mm, built either on **hand-wired perfboard or a small ordered PCB**.
- **Snap:** a printed flexure snap in the channel walls holds the case on the pins, even unlocked.
- **Lock:**
  - **Position:** at the top right, behind the case's upper-right corner, away from the tank. The key goes in horizontally from the side.
  - **Store option:** a 16 mm quarter-turn cam lock. Its own cam is drilled to become the crank, using `crank_template`.
  - **Mechanism:** a scotch-yoke lifts a flat **14 × 9 DIN 6885 key-steel bolt** against a key-steel bearing block in the printed strike. No custom steel fabrication.
- **Lock bay and cartridges (2026-11-22, Update 16):** the pod's tall part is one plain bay, open underneath, with a notch in the side wall. Each lock comes in a printed cartridge (`lock_cartridge()`; `lock_type` picks the cuts) that goes up into the bay from below, its face plate flush in the notch. Inside the wall it is wider than the notch, and the lock cover is screwed into it. **The dock and the lock cover are the same for both locks**; only the cartridge differs (`lock_cartridge.stl` / `printed_lock/plock_cartridge.stl`). The store lock's nut cavity opens on the cartridge's upper side.
- **Printed lock (optional):** `printed_lock.scad`, `PRINTED_LOCK.md`, STLs in `printed_lock/`.
  - Redesigned 2026-11-22 for printing (owner: "no need for it to be a regular lock"): a **push key**. A chunky 6 × 10 mm key (owner: a thin printed key breaks; 3 mm fillets at the bow) slides straight into a slot in the cartridge's face plate and pushes a printed shuttle 7 mm; a pin on the printed lifter (carries the steel bolt, replaces the yoke) runs in a slanted track on the shuttle, so shuttle in = bolt down. Flat dwell when locked: no back-drive.
  - Code: 4 flat wafers in the shuttle, each pushed down by a 3 mm spring onto the key's top edge; each wafer's side tab must line up with a groove in the cartridge. Pockets only at the locked position, so the key comes out only when locked. 1 mm code steps, 81 codes.
  - It fits the standard dock through its own cartridge (`printed_lock/plock_cartridge.stl`). Fits both mounts.
  - `lock_code` sets the key. Built-in checks: `PART="plock_check_*"` (pod, cover, parts, pin = empty/touch; nokey, wrongkey, keyout, backdrive = must collide).
- **Dial lock (demo, Update 21; replaced the electronic dial-code demo of Update 19; owner: "I don't want it to be electronic, rather mechanical", then "a single dial ... all the digits 4-6"):** `dial_lock.scad`, `DIAL_LOCK.md`, `dial_lock/`. `lock_type = "dial"`: a third cartridge. Safe-style: one dial 0-9 on a spindle with a drive cam, one notched wheel per digit (`dial_code`, 4-6 digits) on a fixed tube, flies at r 5 picking up after nearly a turn; a spring fence under the wheels rises into the notches and lifts its latch tooth out of the button bar's notch; the button's 40° ramp lifts the lifter's pin 7 mm. Notch angles from the pickup kinematics (`dl_gate_a`, `dl_delta` 16.1°); `video/make_lock_video.py` simulates the dialling and asserts the notches line up. Lock: press the button and spin the dial a turn. Checks `PART="dl_check_*"` (scrambled, held and backdrive must collide).
- **Mount (main build since 2026-11-22, Update 18: owner "I want the merged one to be v5", meaning the main v0.5 build):** `mount = "merged"` is the **default**: 2 rotating bar clamps (set the tilt) → one-piece `dock_base` on rubber at the clamp bolts → case. Top-level STLs are the merged ones (`dock_base`, `iso_pad`, `shoe`, `case_back`, `strike_keeper`).
  - **Option `mount = "modular"`:** base plate on 4 grommets → dock (`receiver`) → case; a smart base can replace the plate later. Its files are in `modular/` (`receiver`, `base_plate` + DXF, `shoe_modular`, `case_back_modular`, `strike_keeper_modular` + DXF). Images `modular_*.png`.
  - **The one-piece `dock_base`:** dock + plate in one part. The damping moves to the clamp bolts (`iso_pad` rubber pads, rubber washers, M5 spacers as compression limiters). The mount sits 2 mm higher than the modular one, clamp spacing is 132–154 mm (the bolt heads must clear the strike), and there is no smart base.
  - **Its look (owner's goal: aesthetic and minimal):** the base takes the case outline with side and end walls, so case + base read as one slab. The lock pod is 7 mm lower so it hides behind the case, which moves the shoe's strike: the modular option needs its own `modular/shoe_modular.stl` and `case_back_modular.stl`. Fixed: the clamp bolt pattern and the docking interface.
- **Cost:** about ₹3,650–5,600 with perfboard for the one-piece build (the modular option about ₹250–650 less); a PCB adds about ₹700–2,300 (`SHOPPING_LIST_INDIA.md`). The top of the range is over the ₹5,000 target: printing `dock_base` is the big item.

**Docs:**
- `README.md`: design, fitting, build order.
- `WIRING.md`: circuit, parts, perfboard or PCB, bring-up.
- `SHOPPING_LIST_INDIA.md`: parts list with Indian prices.
- `PRINTED_LOCK.md`: the printed lock.
- `CAD_QA.md`: numbered "Update N" log of every change and its checks. **Add an entry for each design change.**

**Video and images:**
- **Video:** `video/make_video.py` renders `mechanism_anim.scad` into `video/mechanism_demo.mp4` (96.5 s); `--test t1,t2` makes a contact sheet. On Windows set `OPENSCAD` to `openscad.com` and use a venv with Pillow and imageio-ffmpeg; a full render takes about 15 minutes with `--jobs 8`.
  - Labels use OpenSCAD's gimbal camera projection: `rot(rot(rot(v,2,-rz),1,-ry),0,90-rx)`, fov 22.5.
- **Lock video:** `video/make_lock_video.py` renders `lock_anim.scad` into `video/lock_demo.mp4` (43 s: all three locks, see-through pod, `lock_type` per frame). It is shown on the site through `project.json` `videos`.
- **Wiring stills:** `make_video.py --stills` writes `images/wiring_dock.png` and `wiring_case.png`.
- **Wiring diagrams:** `images/make_wiring_diagram.py out.svg [full|dock|case]` draws the hand-placed SVGs. Convert them to PNG with `google-chrome --headless=new --force-device-scale-factor=1.5 --window-size=W,H --screenshot=...`.
- **Video Python:** it needs Pillow and imageio-ffmpeg. pip is blocked system-wide (PEP 668), so use a venv.

**Known issue, not fixed:** the store lock's own cam screw or nut sits on the axis behind the crank, only 0.5 mm from the yoke. Check the actual lock; the yoke may need a relief pocket.

## Display pod (display_pod_v4/)

A round minimal-bezel enclosure for the ESP32-2424S012 1.28" round display, with a LiPo and a three-lug, 30° quick-release bayonet.
- **Source:** `scad/parameters.scad` holds every dimension, tagged [OFFICIAL], [PROVISIONAL] and so on. `scad/main.scad` is the part selector.
- **Tools:** `tools/check.sh` runs clearance checks (all must pass); `tools/export.sh` writes `exports/`.
- **Design brief:** follow `display_pod_v4/CLAUDE.md` when working on it. Never invent unknown board measurements.

## How to verify CAD changes (do this every time)

1. **Asserts:** `openscad -o /tmp/x.csg -D 'PART="none"' file.scad` must give no WARNING or ERROR.
2. **Export and mesh-check every changed part:** watertight, consistent winding, one body.
3. **Interference checks:** render `intersection()` of two parts.
   - "Empty" (top level object is empty) means no overlap.
   - A zero-volume STL means the parts only touch.
   - Use deliberate "must collide" checks for stops, locks and keys.
4. Re-export the STLs, re-render the affected images or video, update the docs and `CAD_QA.md`, then rebuild the site.

## Traps already hit

- **Nested modules:** OpenSCAD 2021 can't define a `module` inside an `if` or `else` block (parser error). Define helpers at the top level.
- **xargs quoting:** xargs strips quotes from `-D name="value"`. Quote it as `'phone_port=\"microusb\"'`, or use a wrapper script.
- **zsh `$path`:** in zsh, `$path` is tied to `PATH`. Never name a shell variable `path`.
- **Coplanar faces:** coplanar cut faces Z-fight in renders. Offset colour cuts by 0.1–0.2 mm.
- **Cut-face colours:** in preview, cut faces take the cutter's colour. For coloured sections, use `projection(cut=true)` slices or colour each `intersection()`.
- **Order of definition:** a variable used before it's defined is undef in asserts. Keep definitions in order.
- **Token in the remote:** the git remote URL contains a GitHub access token. Never echo it; mask push output with `sed -E 's/ghp_[A-Za-z0-9]+/<token>/g'`. The owner has been advised to revoke it and use `gh auth login`.
- **Copyright:** don't copy third-party designs without a license (for example twanvl/locks, which has none). Use their general ideas only, and cite sources.

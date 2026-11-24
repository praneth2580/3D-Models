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
- **A project** is any top-level folder with `.stl` or `.scad` files, or with a `website/project.json` (a project still being planned, such as the handlebar dash before its CAD: owner asked "why am i not seeing it on the website"). Each one gets:
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
- **Part groups and the customizer (2026-11-23; owner: "i want the models to be grouped together and allow custom resizing as per the models not all resizing only the specific section that are resizeable"):** `project.json` `part_groups` (collapsible headings in the viewer and the table) and `customize` (settings per group). Each part shows only the settings that change it, from `website/param_deps.json`.
  - **Rerun `python3 site/param_deps.py <project>` after CAD changes** and commit the JSON (build.py warns when stale).
  - Parts are made in the visitor's browser by `site/scad-worker.js` (openscad-wasm 0.0.4 from jsDelivr, `--backend=Manifold`, binary STL; fonts in `site/fonts/`, OFL). New settings: add them to `customize` with a label and range; parts made differently from `PART=<stem>` need `parts.<stem>.make`.
  - Don't run the downloaded wasm locally with Node (not allowed here); test it in Chrome on the local preview.

## Phone dock (phone_dock_v0.5/)

An old phone becomes a permanent handlebar navigation screen.
- **Main CAD:** `phone_dock_v0.5.scad`, OpenSCAD 2021.01, with asserts. `PART=` selects an export.
- **Lock files:** each optional lock's parts and settings (key code) are in `lib/<lock>.scad`, included near the end of the main file (`lock_type` itself is set in the main file). `lib/` files are not models on their own (they use the main file's variables). The top-level `printed_lock.scad`, `dial_lock.scad` and `tubular_lock.scad` are what you open: they include the main file and set `lock_type` and `PART` (2026-11-23, Update 25; owner: the lock files gave errors when opened).

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
- **Lock bay and cartridges (2026-11-22, Update 16):** the pod's tall part is one plain bay, open underneath, with a notch in the side wall. Each lock comes in a printed cartridge (`lock_cartridge()`; `lock_type` picks the cuts) that goes up into the bay from below, its face plate flush in the notch. Inside the wall it is wider than the notch, and the lock cover is screwed into it. **The dock and the lock cover are the same for every lock**; only the cartridge differs (`lock_cartridge.stl` / `printed_lock/plock_cartridge.stl` / `dial_lock/dl_cartridge.stl` / `tubular_lock/tl_cartridge.stl`). The store lock's nut cavity opens on the cartridge's upper side.
- **Printed lock (optional):** `printed_lock.scad` (opens it; parts in `lib/printed_lock.scad`), `PRINTED_LOCK.md`, STLs in `printed_lock/`.
  - Redesigned 2026-11-22 for printing (owner: "no need for it to be a regular lock"): a **push key**. A chunky 6 × 10 mm key (owner: a thin printed key breaks; 3 mm fillets at the bow) slides straight into a slot in the cartridge's face plate and pushes a printed shuttle 7 mm; a pin on the printed lifter (carries the steel bolt, replaces the yoke) runs in a slanted track on the shuttle, so shuttle in = bolt down. Flat dwell when locked: no back-drive.
  - Code: 4 flat wafers in the shuttle, each pushed down by a 3 mm spring onto the key's top edge; each wafer's side tab must line up with a groove in the cartridge. Pockets only at the locked position, so the key comes out only when locked. 1 mm code steps, 81 codes.
  - It fits the standard dock through its own cartridge (`printed_lock/plock_cartridge.stl`). Fits both mounts.
  - `lock_code` sets the key. Built-in checks: `PART="plock_check_*"` (pod, cover, parts, pin = empty/touch; nokey, wrongkey, keyout, backdrive = must collide).
- **Dial lock (demo, Update 21; replaced the electronic dial-code demo of Update 19; owner: "I don't want it to be electronic, rather mechanical", then "a single dial ... all the digits 4-6"):** `dial_lock.scad` (parts in `lib/`), `DIAL_LOCK.md`, `dial_lock/`. `lock_type = "dial"`: a third cartridge. Safe-style: one dial 0-9 on a spindle with a drive cam, one notched wheel per digit (`dial_code`, 4-6 digits) on a fixed tube, flies at r 5 picking up after nearly a turn; a spring fence under the wheels rises into the notches and lifts its latch tooth out of the button bar's notch; the button's 40° ramp lifts the lifter's pin 7 mm. Notch angles from the pickup kinematics (`dl_gate_a`, `dl_delta` 16.1°); `video/make_lock_video.py` simulates the dialling and asserts the notches line up. Lock: just press the button (Update 22, owner: "while locking I want a button, not the entire code again"): a hump in a groove in the button's bar lifts a hammer that presses a heart cam on the front wheel, resetting it to home (notch at the top), so re-opening needs the whole code; the latch is a springy printed arm on the fence (tooth snaps into the button's notch). Checks `PART="dl_check_*"` (scrambled, held, backdrive and reset must collide). The digits are on the dial's rim (ten flats, luggage style), read at the index mark 45° from the top toward the rider (`dl_index_a`; Update 26, owner: numbers on the side, not the flat face).
- **Tubular key lock (optional, Update 23, 2026-11-23; owner: "could we make a tubular key", then "try to create one"):** `tubular_lock.scad` (parts in `lib/`), `TUBULAR_LOCK.md`, `tubular_lock/`. `lock_type = "tubular"`: a fourth cartridge.
  - Pin tumbler with a hollow printed key (13.5 mm OD, 3 mm wall): 6 pins on r 5.25, 3 depths of 1 mm (`tl_code`, 729 codes). Key pins are stepped (2 mm tip through the plug's face); drivers and 3 mm springs in the housing. Right key: all at the shear line (plug's back face).
  - **Level tips (Update 27; owner: "the tubular key pins are visible and i feel its dangers"):** every key pin's tip is the same length (4.4 mm) and the code is in its hidden body (0.8 + digit mm), so with no key all tips stand 3.4 mm proud and the keyhole shows nothing. (First version: the tips stood at the code's heights, readable with a ruler.) With no key the drivers cross 1.2-3.2 mm by digit, so each driver is a 1.4 mm head + 2 × 2.7 mm stem inside its spring (no extra length; the housing, crank and cartridge did not move). Springs 10 mm free.
  - Printed housing (separate part, so its bore prints round; drops into the cartridge from below, back corners on the cartridge), plug (front sleeve, stop lug in a 90° pocket), printed crank with a 4 × 8 steel dowel pin driving the **standard `lock_yoke`** (crank geometry and TDC as the store lock), M3 × 8 countersunk screw from the plug's face into the crank shaft.
  - Two key tabs at 270° and 210° (both 2.4 mm): they take the twist, fit only one way round, and stay in the keyhole's round lower half (its top is a pointed teardrop for printing, wide enough to let a tab out). Key out only when locked.
  - Length is the limit: ~19.5 mm from the wall to the yoke. Springs need 2.9 mm at a 2-step-wrong key, which is why 3 depths, not 4.
  - Checks `PART="tl_check_*"` (nokey, wrongkey with `tl_wrong_i`, keyout, keyangle, stops, backdrive = must collide).
- **Assembled view models (Update 24):** `assembled/assembled_{store,printed,tubular,dial}.stl` = `PART="assembled_view"` per `lock_type` (merged dock + cartridge + lock locked with key + bolt + cover), binary STL, view only. On the site they are `"view": true` parts (not zipped, not counted) and `viewer_default` is a list, so the viewer opens on the chosen lock's assembly. Re-export them (and convert to binary) when the dock or a lock changes.
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
- **Lock video:** `video/make_lock_video.py` renders `lock_anim.scad` into `video/lock_demo.mp4` (64 s: all four locks, see-through pod, `lock_type` per frame; the tubular close-ups use `render()` cuts and take ~30 s a frame). It is shown on the site through `project.json` `videos`.
- **Wiring stills:** `make_video.py --stills` writes `images/wiring_dock.png` and `wiring_case.png`.
- **Wiring diagrams:** `images/make_wiring_diagram.py out.svg [full|dock|case]` draws the hand-placed SVGs. Convert them to PNG with `google-chrome --headless=new --force-device-scale-factor=1.5 --window-size=W,H --screenshot=...`.
- **Video Python:** it needs Pillow and imageio-ffmpeg. pip is blocked system-wide (PEP 668), so use a venv.

**Known issue, not fixed:** the store lock's own cam screw or nut sits on the axis behind the crank, only 0.5 mm from the yoke. Check the actual lock; the yoke may need a relief pocket.

## Display pod (display_pod_v4/)

A round minimal-bezel enclosure for the ESP32-2424S012 1.28" round display, with a LiPo and a three-lug, 30° quick-release bayonet.
- **Source:** `scad/parameters.scad` holds every dimension, tagged [OFFICIAL], [PROVISIONAL] and so on. `scad/main.scad` is the part selector.
- **Tools:** `tools/check.sh` runs clearance checks (all must pass); `tools/export.sh` writes `exports/`.
- **Design brief:** follow `display_pod_v4/CLAUDE.md` when working on it. Never invent unknown board measurements.

## Handlebar dash (handlebar_dash_v1/), started 2026-11-23

A round colour display on its own handlebar clamp that **replaces the stock instrument cluster** (owner's choices: replace the stock instruments, large round display, handlebar clamp; show GPS speed/trip, clock, battery voltage, air temperature, lean angle/g, and the bike's gear, fuel and indicators). Reference bike: the J-platform 350 with harness J1D3 (Meteor 350); keep it generic, bike values as settings.
- **Status: phase 1 ready to build; display head v1 modelled.** `README.md` is the design brief: the stock cluster's 18-pin connector (from Royal Enfield's J1D3 schematic), the CAN bus (ECU, ABS, cluster, OBD-2 and Diagnostic sockets; speed arrives only over CAN), the two-box plan (interface box on the bike's cluster connector + display head) and the phases (phase 1: a listen-only CAN logger on the OBD-2 socket, and measurements on the bike).
- `reference/` holds Royal Enfield's manual and schematic (never committed). The schematic URL is in the manual's wiring-diagram QR code.
- **Decisions (2026-11-23, owner):** the **2.8" round display** (Waveshare ESP32-S3-Touch-LCD-2.8C, 480 × 480) ("bigger is better"); an **"OBD+" port and expansion slots** ("some slots for expansion ... could expand more"): a standard 16-pin OBD-II socket on the interface box (bike CAN on 6/14, ground 4/5, +12 V 16) and 3 sealed 6-pin expansion slots (12 V, 5 V, ground, dash-bus CAN H/L, one spare I/O) on a **private dash bus**; the interface box is an **ESP32-C6** (two CAN controllers: bike bus listen-only, dash bus); **Meteor 350 first**, other bikes later.
- **Components (`COMPONENTS.md`; owner: "mention the component for which you are create the models ... india and prefer amazon or flipkart"):** the exact parts the housings are modelled around (marked "Model fits this"), Amazon.in / Flipkart first, with the much cheaper Indian electronics stores noted where it matters. **Model the CAD to these parts; if a part changes, update COMPONENTS.md first.**
- **Owner, 2026-11-24: "reduce icon sizes and try to reduce bezels too, and place the display a bit below so the logo can be placed above it ... the icons are too big for the bezel".** So the face is now **eccentric**: the display (origin) sits `disp_drop` 6 below the face's centre `hc`; `face_r` = `shell_r` + `disp_drop` (114.5 mm across), so the bottom is flush with the back (3 mm bezel) and the top has 15 mm for the **logo** (`logo_text` "DASH" or `logo_file` SVG/DXF, engraved, centred) with the **tell-tales either side** (`icon_size` 5.5, 4 a side from `logo_gap` 21 deg on a circle round the screen). The outline is one hull (front rounded edge at `hc`, the back's `shell_r` at the origin): a 45-degree shoulder at the top only. The hollow is only above `cav_y0`; the GPS antenna lies behind the logo. `telltale_layout` is gone. Asserts: each icon inside `edge_r()`, the icons clear of the GPS antenna. The website customizer gained a free-text setting type (`"type": "text"`) for the logo.
- **Owner, then (2026-11-23): "consider the size of the handler on the basis of the default meteor handlebar"; tell-tales "look like they are part of the model too not a extra addon", customisable; "look are a great deal important ... the main thing show"; get inspired by others.** So the brow was replaced: the head is a **gauge cup** (front drum `face_r` 61.9 with a 2.5 mm draft, 45-degree shoulder to `shell_r`, rounded edges, accent groove, optional silver `trim_ring` in a rebate) with the **tell-tales in its face** (icons through a 0.8 mm skin, light chambers in the hollow face ring, 5 mm WS2812B LEDs fitted from inside through bore-wall windows, icons filled with white UV resin), as on the Indian Scout / KOSO DL-04 / Daytona Velona round gauges. Options: `telltale_layout` bottom/top/sides, `icons`, `icon_size`, `telltales` face/none, `trim`, `face_text`. The GPS antenna lies in the face ring's hollow opposite the icons. Meteor bar 22.2 mm (riser makers); its one-piece die-cast top clamp has no published size: `bike_clamp` [100, 45, 28] is an estimate, `cradle_span` 135, `head_back` 34. With these, the bar mount clears 0-30 deg of tilt (33 touches the estimated clamp). STLs in `parts/` are binary; the face's rounding offsets use a low `$fn` (16/12) to keep them small.
- **Earlier (2026-11-23): no sun hood; "options to show status indicators like high beam, abs"; "on the handlebar not above it, something like the harleys".** So: `telltales` = "brow" (8 LED tell-tales in an arc above the screen: icons cut through a 0.8 mm skin, one light chamber each, white diffuser squares, 5 mm WS2812B-family LEDs on one data line; icons drawn upright as the rider sees them, mirrored into the head frame, stencil bridges in A and B) or "none" (GPS cap); `mount` = "bar" (Harley-style cradle: 2 bar clamps either side of the bike's handlebar clamp, a bridge bolted to the cover with 2 M4 inserts; tilt by turning the cradle on the bar; clear 0-40 deg against the `bike_clamp` stand-in, MEASURE) or "stalk" (GoPro-style joint). The GX12 socket is at the top of the cover. The head-to-box cable carries 5 V.
- **Display head v1 CAD (`handlebar_dash.scad`, STLs in `parts/`; owner: "there is not image or model etc why is that ??"):** modelled around Waveshare's published drawing and official STEP model of the 2.8" board (glass 95.86 x 1.26, screen 70.13, 4 M2 standoffs ending 9.71 behind the glass at (+-18.0, -25.56) and (+-29.5, +15.14), total 9.73). Frame: head axis z points into the housing, x right as seen from BEHIND (as Waveshare's model). Shell (front lip, foam ring; now the gauge cup, see above) + carrier (display on its standoffs) + plug cover (4 radial M3 screws into inserts; cradle inserts or the GoPro-style joint) + mount. (The first version's sun hood and then the brow were dropped.) Checks: `check_display`, `check_parts`, `check_gasket` (must collide), `check_clamp`, `check_mount` (clear at tilt 0-60). Waveshare's STEP/STL stays in the scratchpad/reference only; checked by placing its vertices in the head frame (max radius 47.94 < bore 48.23; only the standoff ends touch the carrier). Preview trap: an intersection() cutter coplanar with a visible face shows through in renders: start cutters behind the glass.
- **Phase 1** (`PHASE1_LOGGER.md`): `firmware/can_logger/` (listen-only TWAI logger, candump format, GPS speed and markers on microSD; compiles cleanly with arduino-cli 1.6.0 in `~/.local/bin` and esp32 core 3.3.13, for the C6 and S3; not yet run on hardware) and `tools/can_analyze.py` (per-ID summary, `--speed` finds the field that follows GPS speed, `--marks` finds steady byte changes at markers; tested on a synthetic log).

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
- **Opening an included file:** a file meant to be included (it uses the includer's variables) gives "unknown variable" warnings when opened in OpenSCAD on its own. Don't make it include the main file back: a circular include only warns "Can't open include file". Instead put the parts in `lib/` and give the user a small top-level file that includes the main file and overrides settings (a later assignment wins everywhere, as `-D` does).
- **`pkill -f`:** `pkill -f "http.server 8765"` also matches the shell running that command and kills it, so nothing after it runs. Kill the server by PID, or use a pattern like `"http.serve[r] 8765"`.
- **Headless viewer checks:** headless Chrome never scrolls the 3D viewer into view, so it never loads a part. Check the viewer in a real browser.
- **Copyright:** don't copy third-party designs without a license (for example twanvl/locks, which has none). Use their general ideas only, and cite sources.

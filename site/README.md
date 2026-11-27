# Website generator

`build.py` builds the GitHub Pages site into `_site/`:
- an index page with a card for every project;
- one page per project.

It uses only the Python standard library. GitHub Actions runs it on every push to `main` (`.github/workflows/pages.yml`).

```sh
python3 site/build.py            # build; preview with: python3 -m http.server -d _site
python3 site/build.py --readme   # also refresh the project table in the root README.md
```

## What counts as a project

A project is any top-level folder (not hidden, not `site`) that contains `.stl` or `.scad` files, or a `website/project.json` (a project still being planned, with no models yet: its page shows the intro, the sections and the docs). With no setup at all, its page gets:

| Section | Comes from |
|---|---|
| Title, summary | The README's `#` heading and first paragraph |
| Card picture, gallery | Images in `images/`, `renders/`, `photos/`, `media/` or the folder root |
| Video | Set in `project.json` (see below) |
| 3D viewer, parts table | Every `.stl`, except in `archive/`, `reference/` and `website/` |
| Cutting templates | Every `.dxf` |
| Download-all zip | The whole folder, except `archive/`, `reference/`, `website/`, `CLAUDE.md`, `AGENTS.md`, caches and `*.csg` |
| Adjust it to your hardware | `.scad` lines whose comment contains `MEASURE`, `SELECT` or `PROVISIONAL`, grouped under `// ---- Section ----` headings |
| Docs | Every `.md` file, linked on GitHub |
| License | The project's `LICENSE.md` if it has one, otherwise the root `LICENSE.md` (`site.json`) |

## Richer pages: `<project>/website/`

The richer page is built from `project.json`, plus optional HTML sections in the same folder. All `project.json` keys are optional:

| Key | Meaning |
|---|---|
| `title`, `tagline`, `summary` | Page title, headline, intro paragraph |
| `status` | The status note under the intro (for prototypes) |
| `order` | Position on the index (lower comes first; default 100) |
| `cover` | Card and hero image, as a path in the project |
| `video`, `poster` | An `.mp4` and its poster image |
| `videos` | More videos after the main one, shown as tabs: `[{"src": "video/x.mp4", "poster": "images/x.png", "title": "..."}]`. `video_title` names the main video's tab |
| `build_options` | A "Choose your build" picker in the download section: `[{"id": "lock", "label": "Lock", "choices": [{"id": "store", "label": "Store lock", "note": "..."}]}]`. The first choice is the default. The parts list, the 3D viewer and a "Download this build (.zip)" button (made in the browser) follow the choice |
| `parts.<stem>.when` | Which builds need the part: `{"lock": "store"}` or `{"lock": ["store", "dial"]}`. Parts without it are in every build |
| `dxf_when` | The same for DXF files: `{"<stem>": {"mount": "modular"}}` |
| `see_title`, `see_sub` | Heading and text of the pictures section |
| `gallery` | `[{"src": "images/x.png", "caption": "..."}]` |
| `viewer_default` | The STL shown first, without `.stl`. Or a list of them: the first one in the chosen build is shown (and the viewer follows the build picker) |
| `parts.<stem>.view` | `true` for a view-only model (an assembly, say): marked "view only" in the parts table, left out of the zips and the printable-parts count |
| `parts` | `{"stem": {"name", "what", "qty", "material", "note", "optional"}}`, listed in this order (within their groups) |
| `part_groups` | Headings for the 3D viewer's part list and the parts table: `[{"label": "Case", "parts": ["case_shell", ...], "closed": false}]`. Each heading opens and closes; parts in no group go under "Other parts" |
| `customize` | The in-browser customizer ("Make it your size"), see below |
| `parts.<stem>.make` | How OpenSCAD makes the part, for the customizer: `{"part": "shoe", "set": {"mount": "modular"}}`. Default: the part variable set to the stem, nothing else |
| `dxf` | `{"stem": "description"}` |
| `exclude` | File patterns to leave out of the page and zip, such as `["old_part.stl"]` |
| `download_note` | HTML shown under the downloads |
| `sections`, `nav` | Extra HTML sections after "Adjust" (`["build.html"]`), and their nav links (`[["Build", "#build"]]`) |
| `docs` | `[{"label": "...", "file": "README.md"}]`, replacing the automatic list |
| `license` | `{"name": "...", "url": "..."}` |

**What to buy: `website/buy.json`.** A "What to buy" section (after Download, with its own nav link): every item to buy besides the printed parts, grouped, with checked listings and ready-made search links at the Indian stores that suit that kind of part.

```json
{"title": "What to buy", "sub": "...", "note": "...",
 "groups": [{"label": "Display head: electronics", "note": "...", "items": [
   {"name": "...", "for": "what it's for", "qty": 1, "price": "₹3,700–9,200", "fits": true, "note": "...",
    "when": {"mount": "bar"},
    "buy": [{"store": "Evelta", "url": "https://...", "price": "₹4,396", "note": "(no touch)"}],
    "search": "ESP32-S3-Touch-LCD-2.8C", "stores": "modules",
    "local": "Lamington Road", "where": "free text"}]}],
 "totals": [["The whole dash", "about ₹14,000–17,000"]]}
```

- `buy`: listings that were checked (shown first, with their price). `search` + `stores` adds search links: `modules` (Amazon.in, Flipkart, Robu.in, Evelta, ElectronicsComp), `components` (Robu.in, Evelta, ElectronicsComp, DigiKey India, Amazon.in), `hardware` and `general` (Amazon.in, Flipkart). The stores and their search URLs are `STORES` in `build.py`. `local`: a Mumbai market; `where`: any other advice.
- `fits: true` adds a "model fits this" badge (the printed parts are modelled around that exact item).
- `when` works as for parts: the build picker hides items for options not chosen.
- Prices in INR; mark unchecked ones "(est.)".

**Special HTML files:**
- `features.html`: shown inside the pictures section.
- `adjust.html`: replaces the automatic "Adjust it to your hardware" section.

Every section is HTML using the classes in `style.css`. Images go in as `media/<file name>` and downloads as `files/<file name>`.

**Examples:** `phone_dock_v0.5/website/` and `display_pod_v4/website/`.

## Make it your size: the in-browser customizer

With a `customize` block, each part in the 3D viewer gets a "Make it your size" panel. Visitors change the settings, press **Make this part**, and OpenSCAD runs in their browser (`scad-worker.js`, a background thread with [openscad-wasm](https://www.npmjs.com/package/openscad-wasm) 0.0.4, OpenSCAD 2025.07.18 with the fast Manifold engine, loaded from jsDelivr; about 14 MB, only when first used). The new STL shows in the viewer and can be downloaded. With build options there is also **"... with your sizes (.zip)"**: the parts whose settings were changed are made in the browser, the rest are the ready-made files. Values are kept in the visitor's browser (`localStorage`), shared by all the project's parts.

**Each part offers only the settings that change it.** That list is worked out by OpenSCAD, not by hand:

```sh
python3 site/param_deps.py phone_dock_v0.5     # writes phone_dock_v0.5/website/param_deps.json; commit it
```

It exports every part as CSG (fast, no mesh) with each setting changed in turn, and records which settings change which part. **Run it after any CAD change** that could change that (new parts, moved settings, new dependencies). `build.py` warns when the file looks out of date (a default changed, or the parts differ), and reads every default from the CAD itself.

```json
"customize": {
  "entry": "phone_dock_v0.5.scad",
  "sources": ["phone_dock_v0.5.scad", "lib/tubular_lock.scad"],
  "part_var": "PART",
  "groups": [
    {"label": "Your phone", "note": "optional text", "params": [
      {"name": "phone_w", "label": "Phone width", "unit": "mm", "step": 0.1, "min": 50, "max": 95, "help": "..."},
      {"name": "phone_port", "label": "Charging port", "choices": [["usbc", "USB-C"], ["microusb", "Micro-USB"]]},
      {"name": "tl_code", "label": "Key code", "type": "code", "digits": [0, 2], "length": [4, 6]},
      {"name": "logo_text", "label": "Logo", "type": "text", "max_length": 12},
      {"name": "logo_file", "label": "Your own logo (SVG)", "type": "file", "accept": ".svg", "max_kb": 1024}
    ]}
  ]
}
```

- `sources`: every `.scad` file the entry includes (paths in the project). They are published under `scad/` for the browser.
- Each setting needs a literal default in the sources (`name = 22.2;`), and is passed to OpenSCAD with `-D`, so it overrides the file's value (the last assignment wins).
- The design's own `assert()`s still apply: a refused size shows the assert's message on the page.
- Setting types: a number (with `min`, `max`, `step`, `unit`), `choices`, `"type": "code"` (a list of digits), `"type": "text"` (a short word: letters, digits, spaces, dots, dashes) and `"type": "file"` (an SVG the visitor picks, up to `max_kb`). A picked file never leaves the visitor's browser: the worker writes it next to the design as `upload/<name>.svg` and passes that path with `-D`, and the browser remembers it if it fits in localStorage. On the visitor's computer, the shown command expects it in the project's `private/` folder. `param_deps.py` probes a file setting with a small test SVG.
- `"probe_with": ["setting"]` in the customize block (optional): `param_deps.py` also probes every setting with each other value of these choice settings, so a setting that matters only with another choice (the headset's battery size, only when `batt_at` is "pod") is still offered on the parts it changes.
- `text()` in a model uses the Liberation Sans fonts in `site/fonts/` (SIL Open Font License, `OFL.txt`).
- Big parts take about 1-5 s in a desktop browser; a phone is slower.

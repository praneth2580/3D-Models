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

A project is any top-level folder (not hidden, not `site`) that contains `.stl` or `.scad` files. With no setup at all, its page gets:

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
| `parts` | `{"stem": {"name", "what", "qty", "material", "note", "optional"}}`, listed in this order |
| `dxf` | `{"stem": "description"}` |
| `exclude` | File patterns to leave out of the page and zip, such as `["old_part.stl"]` |
| `download_note` | HTML shown under the downloads |
| `sections`, `nav` | Extra HTML sections after "Adjust" (`["build.html"]`), and their nav links (`[["Build", "#build"]]`) |
| `docs` | `[{"label": "...", "file": "README.md"}]`, replacing the automatic list |
| `license` | `{"name": "...", "url": "..."}` |

**Special HTML files:**
- `features.html`: shown inside the pictures section.
- `adjust.html`: replaces the automatic "Adjust it to your hardware" section.

Every section is HTML using the classes in `style.css`. Images go in as `media/<file name>` and downloads as `files/<file name>`.

**Examples:** `phone_dock_v0.5/website/` and `display_pod_v4/website/`.

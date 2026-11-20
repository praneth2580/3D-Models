# 3D Models

**Website: https://praneth2580.github.io/3D-Models/**

Open-source, parametric, 3D-printable designs. Every project has its own page on the website with:
- pictures (and a video where there is one);
- a 3D viewer for every part;
- free downloads: one .zip, or single STL and DXF files;
- what to adjust for your own hardware.

## Projects

<!-- projects:start -->
| Project | What it is | Website | Folder |
|---|---|---|---|
| **Handlebar Phone Dock** | Turn an old phone into a permanent motorcycle navigation screen. | [page](https://praneth2580.github.io/3D-Models/phone_dock_v0.5/) | [`phone_dock_v0.5/`](phone_dock_v0.5/) |
| **Round Display Pod** | A round, minimal-bezel instrument pod for a 1.28" ESP32 display. | [page](https://praneth2580.github.io/3D-Models/display_pod_v4/) | [`display_pod_v4/`](display_pod_v4/) |
<!-- projects:end -->

License: [CC BY-NC-SA 4.0](LICENSE.md) unless a project says otherwise. Free to download, print and remix with credit, but not for selling.

## Adding a new project

1. Put it in a **new top-level folder** that contains its `.stl` and/or `.scad` files, plus a `README.md`. Its title and summary come from the README's `#` heading and first paragraph.
2. Optionally, add an `images/` folder (the first image becomes the card picture) and a `video/` folder with an `.mp4`.
3. Mark the values people need to change with `MEASURE`, `SELECT` or `PROVISIONAL` in a comment, for example `bar_d = 22.2; // MEASURE: handlebar diameter`. They appear automatically in the page's "Adjust it to your hardware" section.
4. Push to `main`. The website rebuilds itself, and the new project appears with no other setup.
5. Refresh the project list above: `python3 site/build.py --readme`.

For a richer page (part descriptions, a curated gallery, custom sections), add a `website/` folder to the project. See [`site/README.md`](site/README.md).

**Never published:** `archive/` and `reference/` folders (old versions and other people's files, such as vendor datasheets), `website/`, `CLAUDE.md`, and caches. They are left out of the site and the zips; `reference/` is also kept out of git.

## Preview the website locally

```sh
python3 site/build.py && python3 -m http.server -d _site
```

Then open http://localhost:8000. GitHub Actions (`.github/workflows/pages.yml`) builds and deploys the same thing on every push to `main`.

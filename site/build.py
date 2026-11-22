#!/usr/bin/env python3
"""Builds the GitHub Pages website for every project in this repository.

    python3 site/build.py              # writes _site/ (preview: python3 -m http.server -d _site)
    python3 site/build.py --readme     # also refreshes the project list in the root README.md

A "project" is any top-level folder that contains .stl or .scad files. New folders appear on the site
automatically. Each gets a page with its pictures, a 3D viewer, downloads (one .zip plus single files),
a table of the settings to adjust for your own hardware, and links to its docs.

Optional, per project: <project>/website/project.json (title, summary, part descriptions, ...) and HTML
sections in the same folder. See site/README.md for the format. Standard library only.
"""
import fnmatch, html, json, os, re, shutil, subprocess, sys, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE_SRC = os.path.join(ROOT, "site")
OUT = os.path.join(ROOT, "_site")
SKIP_DIRS = {"site", "_site", "archive", "reference", "website", "node_modules", "__pycache__", "frames"}
NEVER_ZIP = ["*/archive/*", "*/reference/*", "*/website/*", "*/__pycache__/*", "*.csg", "*/CLAUDE.md",
             "*/AGENTS.md", "*/frames/*", "*/.*"]
MEDIA_EXT = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".mp4", ".webm"}
DOC_SKIP = {"CLAUDE.md", "AGENTS.md"}
TAG_RE = re.compile(r"\b(MEASURE|SELECT|PROVISIONAL)\b")
esc = html.escape

# ------------------------------------------------------------------ repo + config
def load_json(path, default):
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    return default

SITE = load_json(os.path.join(SITE_SRC, "site.json"), {})

def repo_info():
    """owner/repo and branch: from GitHub Actions, or from the local git remote (credentials never kept)."""
    repo = os.environ.get("GITHUB_REPOSITORY")
    if not repo:
        try:
            url = subprocess.check_output(["git", "-C", ROOT, "remote", "get-url", "origin"], text=True,
                                          stderr=subprocess.DEVNULL).strip()
        except Exception:
            url = ""
        m = re.search(r"github\.com[:/]([^/\s]+/[^/\s]+?)(?:\.git)?/?$", url)
        repo = m.group(1) if m else SITE.get("repo", "")
    branch = os.environ.get("GITHUB_REF_NAME") or SITE.get("branch", "main")
    return repo, branch

REPO, BRANCH = repo_info()
OWNER = REPO.split("/")[0] if REPO else SITE.get("author", "")
GH = f"https://github.com/{REPO}" if REPO else ""
PAGES = f"https://{REPO.split('/')[0].lower()}.github.io/{REPO.split('/')[1]}/" if REPO else ""

def gh_blob(rel): return f"{GH}/blob/{BRANCH}/{rel}" if GH else rel
def gh_tree(rel): return f"{GH}/tree/{BRANCH}/{rel}" if GH else rel

# ------------------------------------------------------------------ helpers
def walk_files(base, exts, extra_skip=()):
    """Files under base with one of exts, skipping archive/reference/website/hidden folders."""
    found = []
    for d, dirs, files in os.walk(base):
        dirs[:] = sorted(x for x in dirs if x not in SKIP_DIRS and not x.startswith("."))
        for f in sorted(files):
            if os.path.splitext(f)[1].lower() in exts:
                rel = os.path.relpath(os.path.join(d, f), base)
                if not any(fnmatch.fnmatch(rel, p) or fnmatch.fnmatch(f, p) for p in extra_skip):
                    found.append(rel)
    return found

def fmt_size(b):
    return f"{b / 1048576:.1f} MB" if b >= 1048576 else f"{max(1, round(b / 1024))} KB"

def strip_md(s):
    s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)
    s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)
    s = re.sub(r"[*_`]", "", s)
    return s.strip()

def readme_meta(path):
    """Title (first # heading) and summary (first plain paragraph) of a README."""
    title, para = None, []
    if not os.path.exists(path):
        return None, ""
    in_code = False
    for line in open(path, encoding="utf-8"):
        t = line.strip()
        if t.startswith("```"):
            in_code = not in_code; continue
        if in_code: continue
        if title is None:
            if t.startswith("# "): title = strip_md(t[2:])
            continue
        if not t:
            if para: break
            continue
        if t[0] in "#>|-*!<" or re.match(r"^\d+\.", t) or t.startswith("**") and t.endswith("**"):
            if para: break
            continue
        para.append(t)
    return title, strip_md(" ".join(para))

def pretty(stem): return stem.replace("_", " ").replace("-", " ").strip().capitalize()

def license_for(proj_dir):
    for name in ("LICENSE.md", "LICENSE", "LICENSE.txt"):
        if os.path.exists(os.path.join(proj_dir, name)):
            return name
    return None

# ------------------------------------------------------------------ settings to adjust (from the .scad files)
def scad_params(proj_dir):
    """Lines like  name = value;  // ... MEASURE / SELECT / PROVISIONAL ...  grouped by section heading."""
    groups = []
    for rel in walk_files(proj_dir, {".scad"}):
        lines = open(os.path.join(proj_dir, rel), encoding="utf-8", errors="replace").read().splitlines()
        section, pending_tag, prev_dash = pretty(os.path.splitext(os.path.basename(rel))[0]), None, False
        for raw in lines:
            line = raw.strip()
            m = re.match(r"^//\s*-{3,}\s*([A-Za-z].*?)\s*-{3,}\s*$", line)
            if m: section = m.group(1).strip().title(); prev_dash = False; continue
            if re.match(r"^//\s*[-=]{6,}\s*$", line): prev_dash = True; continue
            if prev_dash and line.startswith("//"):
                txt = line.lstrip("/ ").strip()
                if txt: section = re.split(r"[:(]", txt)[0].strip()[:60] or section
                prev_dash = False; continue
            prev_dash = False
            if line.startswith("//"):
                pending_tag = TAG_RE.search(line) and line.lstrip("/ ") or pending_tag
                continue
            m = re.match(r"^([A-Za-z_]\w*)\s*=\s*([^;]+);\s*(?://\s*(.*))?$", line)
            if not m:
                if line and not line.startswith("//"): pending_tag = None if not line.endswith(";") else pending_tag
                continue
            name, val, note = m.group(1), m.group(2).strip(), (m.group(3) or "").strip()
            tag = TAG_RE.search(note)
            if not tag and pending_tag and not note:
                tag = TAG_RE.search(pending_tag); note = pending_tag
            if not tag: continue
            note = re.sub(r"^\[?(MEASURE|SELECT|PROVISIONAL)\]?:?\s*", "", note).strip()
            if not groups or groups[-1][0] != (rel, section):
                groups.append([(rel, section), []])
            groups[-1][1].append((name, val, tag.group(1), note))
    return groups

def auto_adjust_section(proj, groups):
    if not groups: return ""
    files = sorted({g[0][0] for g in groups})
    rows = []
    for (rel, section), items in groups:
        trs = "".join(
            f"<tr><td><code>{esc(n)}</code> <span class='default'>= {esc(v)}</span></td>"
            f"<td>{esc(note) or '&nbsp;'} <span class='tag {t.lower()}'>{t}</span></td></tr>" for n, v, t, note in items)
        rows.append(f"<details class='adj' open><summary><span class='adj-title'>{esc(section)}</span>"
                    f"<span class='adj-why'>{esc(rel)}</span></summary><table class='params'>{trs}</table></details>")
    return f"""
<section id="adjust">
  <div class="wrap">
    <h2>Adjust it to your hardware</h2>
    <p class="sub">These values are marked in the source as needing a measurement from your hardware
      (<span class="tag measure">MEASURE</span>), a check against the part you buy (<span class="tag select">SELECT</span>)
      or confirmation (<span class="tag provisional">PROVISIONAL</span>). Edit them in {", ".join(f"<code>{esc(f)}</code>" for f in files)},
      then re-export the parts with <a href="https://openscad.org/downloads.html">OpenSCAD</a> (free).</p>
    <div class="adjust-grid">{''.join(rows)}</div>
  </div>
</section>"""

# ------------------------------------------------------------------ page shell
FONTS = ('<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
         '<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">')
ICON = ("data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'><path d='M16 3l11 6v14l-11 6-11-6V9z' "
        "fill='%23e8590c'/><path d='M16 15l11-6M16 15v14M16 15L5 9' stroke='white' stroke-width='1.8' fill='none'/></svg>")

def page(title, desc, body, root, nav_links, image=None, scripts=""):
    og = f'<meta property="og:image" content="{esc(image)}">' if image else ""
    links = "".join(f'<a href="{h}">{esc(t)}</a>' for t, h in nav_links)
    menu = (f'<details class="menu"><summary aria-label="Sections">Menu</summary><div class="menu-pop">{links}</div></details>'
            if len(nav_links) > 1 else "")
    site_title = SITE.get("title", "3D Models")
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{esc(title)}</title>
<meta name="description" content="{esc(desc)}">
<meta property="og:title" content="{esc(title)}">
<meta property="og:description" content="{esc(desc)}">
{og}
<link rel="icon" href="{ICON}">
{FONTS}
<link rel="stylesheet" href="{root}style.css">
<script>document.documentElement.classList.add("js")</script>
</head>
<body>
<header class="nav">
  <div class="wrap nav-in">
    <a class="brand" href="{root}"><span class="logo"></span>{esc(site_title)}</a>
    <nav class="sections">{links}</nav>
    {menu}
    {f'<a class="btn small ghost gh" href="{GH}">GitHub</a>' if GH else ''}
  </div>
</header>
<main id="top">
{body}
</main>
<footer>
  <div class="wrap foot-in">
    <p>{esc(site_title)} by <a href="https://github.com/{esc(OWNER)}">{esc(OWNER)}</a>. Free to download. {SITE_LICENSE_HTML}</p>
    <p class="muted">{esc(SITE.get("disclaimer", ""))}</p>
  </div>
</footer>
{scripts}
</body>
</html>
"""

SITE_LIC = SITE.get("license", {})
SITE_LICENSE_HTML = (f'Unless a project says otherwise, licensed <a href="{esc(SITE_LIC["url"])}">{esc(SITE_LIC["name"])}</a>.'
                     if SITE_LIC else "")

def chip_note(ch):
    return f'<small>{esc(ch["note"])}</small>' if ch.get("note") else ""

# ------------------------------------------------------------------ one project
class Project:
    def __init__(self, folder):
        self.folder = folder
        self.dir = os.path.join(ROOT, folder)
        self.webdir = os.path.join(self.dir, "website")
        self.cfg = load_json(os.path.join(self.webdir, "project.json"), {})
        t, s = readme_meta(os.path.join(self.dir, "README.md"))
        self.title = self.cfg.get("title") or t or pretty(folder)
        self.tagline = self.cfg.get("tagline", "")
        self.summary = self.cfg.get("summary") or s
        self.status = self.cfg.get("status", "")
        self.order = self.cfg.get("order", 100)
        self.exclude = self.cfg.get("exclude", [])
        self.stls = walk_files(self.dir, {".stl"}, self.exclude)
        self.dxfs = walk_files(self.dir, {".dxf"}, self.exclude)
        self.scads = walk_files(self.dir, {".scad"}, self.exclude)
        top = [f for f in self.scads if os.sep not in f]
        self.main_scad = top[0] if len(top) == 1 else (self.scads[0] if len(self.scads) == 1 else None)
        self.media = [m for m in walk_files(self.dir, MEDIA_EXT, self.exclude)
                      if m.split(os.sep)[0] in ("images", "renders", "video", "media", "photos") or os.sep not in m]
        cover = self.cfg.get("cover")
        imgs = [m for m in self.media if os.path.splitext(m)[1].lower() in {".png", ".jpg", ".jpeg", ".webp", ".gif"}]
        self.cover = cover or (imgs[0] if imgs else None)
        self.lic_file = license_for(self.dir)
        self.lic = self.cfg.get("license") or SITE_LIC

    @property
    def slug(self): return self.folder

    def media_url(self, rel): return "media/" + os.path.basename(rel)

    def part_rows(self):
        meta = self.cfg.get("parts", {})
        stems = [os.path.splitext(os.path.basename(p))[0] for p in self.stls]
        order = [s for s in meta if s in stems] + [s for s in stems if s not in meta]
        rows = []
        for stem in order:
            m = meta.get(stem, {})
            rel = self.stls[stems.index(stem)]
            rows.append(dict(stem=stem, file=os.path.basename(rel), rel=rel, name=m.get("name", pretty(stem)),
                             what=m.get("what", ""), qty=str(m.get("qty", "1")), material=m.get("material", ""),
                             note=m.get("note", ""), optional=m.get("optional", False), when=m.get("when", {}),
                             size=os.path.getsize(os.path.join(self.dir, rel))))
        return rows

    def docs(self):
        listed = self.cfg.get("docs")
        if listed:
            return [(d["label"], d["file"]) for d in listed]
        mds = [m for m in walk_files(self.dir, {".md"}, self.exclude) if os.path.basename(m) not in DOC_SKIP]
        mds.sort(key=lambda m: (os.path.basename(m) != "README.md", m.count(os.sep), m))
        return [(pretty(os.path.splitext(os.path.basename(m))[0]) if os.path.basename(m) != "README.md" else "README: overview", m)
                for m in mds]

    def fragment(self, name):
        p = os.path.join(self.webdir, name)
        return open(p, encoding="utf-8").read() if os.path.exists(p) else ""

    # -------------------------------------------------------------- build
    def build(self):
        out = os.path.join(OUT, self.slug)
        os.makedirs(os.path.join(out, "files"), exist_ok=True)
        os.makedirs(os.path.join(out, "media"), exist_ok=True)
        for rel in self.stls + self.dxfs:
            shutil.copy2(os.path.join(self.dir, rel), os.path.join(out, "files", os.path.basename(rel)))
        for rel in [self.main_scad] if self.main_scad else []:
            shutil.copy2(os.path.join(self.dir, rel), os.path.join(out, "files", os.path.basename(rel)))
        for rel in self.media:
            shutil.copy2(os.path.join(self.dir, rel), os.path.join(out, "media", os.path.basename(rel)))
        self.zip_name = f"{self.slug}.zip"
        self.zip_size = self.make_zip(os.path.join(out, "files", self.zip_name))
        with open(os.path.join(out, "index.html"), "w", encoding="utf-8") as f:
            f.write(self.render())

    def make_zip(self, path):
        pats = NEVER_ZIP + [f"*/{p}" for p in self.exclude]
        with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
            for d, dirs, files in os.walk(self.dir):
                dirs[:] = sorted(dirs)
                for fn in sorted(files):
                    full = os.path.join(d, fn)
                    arc = os.path.relpath(full, ROOT)
                    if any(fnmatch.fnmatch(arc, p) for p in pats): continue
                    z.write(full, arc)
            if not self.lic_file and os.path.exists(os.path.join(ROOT, "LICENSE.md")):
                z.write(os.path.join(ROOT, "LICENSE.md"), f"{self.folder}/LICENSE.md")
        return os.path.getsize(path)

    def render(self):
        c, parts = self.cfg, self.part_rows()
        cover = self.media_url(self.cover) if self.cover else None
        src_link = gh_tree(self.folder)
        lic_link = gh_blob(f"{self.folder}/{self.lic_file}") if self.lic_file else gh_blob("LICENSE.md")
        lic = (f'Licensed <a href="{esc(self.lic["url"])}">{esc(self.lic["name"])}</a> '
               f'(<a href="{lic_link}">details</a>).') if self.lic else ""
        nav = [("See it", "#see")] if (c.get("video") or self.gallery()) else []
        nav += [("3D viewer", "#viewer")] if parts else []
        nav += [("Download", "#download")]
        adjust = self.fragment("adjust.html")
        groups = scad_params(self.dir) if not adjust else []
        nav += [("Adjust", "#adjust")] if adjust or groups else []
        nav += [(t, h) for t, h in c.get("nav", [])]
        nav += [("Docs", "#docs")] if self.docs() else []

        hero = f"""
<section class="hero">
  <div class="wrap hero-in{'' if cover else ' no-img'}">
    <div class="hero-text">
      <p class="eyebrow"><a href="../">All projects</a> &middot; {c.get("eyebrow", "Open-source &middot; 3D-printable &middot; parametric")}</p>
      <h1>{esc(self.tagline or self.title)}</h1>
      {f'<p class="kicker">{esc(self.title)}</p>' if self.tagline else ''}
      <p class="lead">{esc(self.summary)}</p>
      <div class="cta">
        <a class="btn" href="files/{self.zip_name}" download>Download everything (.zip, {fmt_size(self.zip_size)})</a>
        <a class="btn ghost" href="{src_link}">Source on GitHub</a>
      </div>
      <p class="note">Free to download, print and modify. {lic}</p>
    </div>
    {f'<figure class="hero-img"><img src="{cover}" alt="{esc(self.title)}"></figure>' if cover else ''}
  </div>
  {f'<div class="wrap"><div class="status"><strong>Status:</strong> {esc(self.status)}</div></div>' if self.status else ''}
</section>"""

        see = ""
        gal = self.gallery()
        if c.get("video") or gal:
            vids = ([dict(src=c["video"], poster=c.get("poster"), title=c.get("video_title", "Video"))] if c.get("video") else []) \
                   + c.get("videos", [])                  # more videos: shown as tabs
            panes = "".join(
                f'<div class="video" data-pane="{i}"{"" if i == 0 else " hidden"}><video controls preload="metadata"'
                f'{(" poster=" + chr(34) + self.media_url(v["poster"]) + chr(34)) if v.get("poster") else ""}>'
                f'<source src="{self.media_url(v["src"])}" type="video/mp4">Your browser can\'t play this video.</video></div>'
                for i, v in enumerate(vids))
            tabs = ("".join(f'<button class="tab" role="tab" data-tab="{i}" aria-selected="{str(i == 0).lower()}">{esc(v.get("title", ""))}</button>'
                            for i, v in enumerate(vids)))
            vid = (f'<div class="tabs" role="tablist" aria-label="Videos">{tabs}</div>' if len(vids) > 1 else "") + \
                  (f'<div class="videos">{panes}</div>' if vids else "")
            figs ="".join(f'<figure><a class="zoom" href="{self.media_url(g["src"])}"><img src="{self.media_url(g["src"])}" alt="{esc(g.get("caption", ""))}" loading="lazy"></a>'
                           f'<figcaption>{esc(g.get("caption", ""))}</figcaption></figure>' for g in gal)
            see = f"""
<section id="see" class="band">
  <div class="wrap">
    <h2>{esc(c.get("see_title", "How it works" if c.get("video") else "Pictures"))}</h2>
    {f'<p class="sub">{esc(c["see_sub"])}</p>' if c.get("see_sub") else ''}
    {vid}
    {self.fragment("features.html")}
    {f'<div class="gallery">{figs}</div>' if figs else ''}
  </div>
</section>"""

        viewer = ""
        if parts:
            viewer = """
<section id="viewer">
  <div class="wrap">
    <h2>Look at every part in 3D</h2>
    <p class="sub">Pick a part, then drag to rotate, scroll or pinch to zoom, and right-drag to pan.<span class="build-note" hidden> Showing the parts for <b class="build-name"></b> (<a href="#choose">change</a>).</span></p>
    <div class="viewer">
      <div class="part-list" id="part-buttons" role="tablist" aria-label="Parts"></div>
      <div class="stage">
        <canvas id="stl-canvas" aria-label="3D view of the selected part"></canvas>
        <div class="stage-info" id="stage-info">Loading&hellip;</div>
        <a class="btn small stage-dl" id="stage-dl" href="#" download>Download this STL</a>
      </div>
    </div>
  </div>
</section>"""

        rows = ""
        for p in parts:
            opt = " <span class='opt'>(optional)</span>" if p["optional"] else ""
            note = f"<br><span class='opt'>{esc(p['note'])}</span>" if p["note"] else ""
            rows += (f"<tr data-when='{esc(json.dumps(p['when']))}' data-file='{esc(p['file'])}'><td>{esc(p['name'])}{opt}</td><td>{esc(p['what'])}{note}</td>"
                     f"<td>{esc(p['qty'])}</td><td>{esc(p['material'])}</td>"
                     f"<td><a class='file' href='files/{esc(p['file'])}' download>{esc(p['file'])}</a> "
                     f"<span class='opt'>{fmt_size(p['size'])}</span></td></tr>")
        dxf_meta, dxf_when = c.get("dxf", {}), c.get("dxf_when", {})
        dxf_rows = "".join(
            f"<tr data-when='{esc(json.dumps(dxf_when.get(os.path.splitext(os.path.basename(d))[0], {})))}' data-file='{esc(os.path.basename(d))}'><td><a class='file' href='files/{esc(os.path.basename(d))}' download>{esc(os.path.basename(d))}</a></td>"
            f"<td>{esc(dxf_meta.get(os.path.splitext(os.path.basename(d))[0], ''))}</td>"
            f"<td><span class='opt'>{fmt_size(os.path.getsize(os.path.join(self.dir, d)))}</span></td></tr>" for d in self.dxfs)
        if self.main_scad:
            src_card = (f'<a class="dl-card" href="files/{esc(os.path.basename(self.main_scad))}" download><span class="dl-title">Parametric source</span>'
                        f'<span class="dl-meta">{esc(os.path.basename(self.main_scad))} &middot; OpenSCAD</span></a>')
        elif self.scads:
            src_card = (f'<a class="dl-card" href="{gh_tree(self.folder)}"><span class="dl-title">Parametric source</span>'
                        f'<span class="dl-meta">{len(self.scads)} OpenSCAD files (in the .zip, or browse on GitHub)</span></a>')
        else:
            src_card = ""
        docs = self.docs()
        opts = c.get("build_options", [])
        builder = ""
        if opts and parts:
            groups_html = "".join(
                f'<div class="b-opt"><span class="b-label">{esc(o["label"])}</span><div class="chips" role="radiogroup" aria-label="{esc(o["label"])}">'
                + "".join(f'<button class="chip" role="radio" data-opt="{esc(o["id"])}" data-choice="{esc(ch["id"])}" aria-checked="{str(k == 0).lower()}">'
                          f'<span>{esc(ch["label"])}</span>{chip_note(ch)}</button>'
                          for k, ch in enumerate(o["choices"]))
                + '</div></div>' for o in opts)
            builder = f"""
    <div class="builder" id="choose">
      <h3>Choose your build</h3>
      <p class="sub">Pick the options; the list below and the 3D viewer show only the parts you need.</p>
      {groups_html}
      <div class="b-sum">
        <span class="b-count" id="b-count"></span>
        <button class="btn" id="b-zip" type="button">Download this build (.zip)</button>
        <label class="b-all"><input type="checkbox" id="b-all"> Show every part</label>
      </div>
      <p class="b-status" id="b-status" aria-live="polite"></p>
    </div>"""
        download = f"""
<section id="download" class="band">
  <div class="wrap">
    <h2>Download</h2>
    <p class="sub">Everything is free. The <strong>.zip</strong> has the whole project: printable parts, source, templates and docs.</p>
    <div class="dl-top">
      <a class="dl-card primary" href="files/{self.zip_name}" download><span class="dl-title">Everything</span><span class="dl-meta">.zip &middot; {fmt_size(self.zip_size)}</span></a>
      {src_card}
      {f'<a class="dl-card" href="{gh_blob(self.folder + "/" + docs[0][1])}"><span class="dl-title">Guide</span><span class="dl-meta">{esc(docs[0][0])} (on GitHub)</span></a>' if docs else ''}
    </div>
    {builder}
    {f'''<h3 class="table-title">Printable parts</h3>
    <div class="table-wrap"><table class="parts">
      <thead><tr><th>Part</th><th>What it is</th><th>Qty</th><th>Material / notes</th><th>File</th></tr></thead>
      <tbody>{rows}</tbody></table></div>''' if parts else ''}
    {f'''<h3 class="table-title">Cutting templates (DXF)</h3>
    <div class="table-wrap"><table class="parts small"><tbody>{dxf_rows}</tbody></table></div>''' if dxf_rows else ''}
    {f'<p class="small-note">{c["download_note"]}</p>' if c.get("download_note") else ''}
  </div>
</section>"""

        adjust_html = adjust or auto_adjust_section(self, groups)
        extra = "".join(self.fragment(f) for f in c.get("sections", []))
        docs_html = ""
        if docs:
            lis = "".join(f'<li><a href="{gh_blob(self.folder + "/" + f)}">{esc(label)}</a> <span class="opt">{esc(f)}</span></li>'
                          for label, f in docs)
            docs_html = f"""
<section id="docs" class="band">
  <div class="wrap">
    <h2>Documentation</h2>
    <p class="sub">The full guides live with the source on GitHub.</p>
    <ul class="doc-list">{lis}</ul>
  </div>
</section>"""

        data = dict(parts=[dict(file=p["file"], name=p["name"], qty=p["qty"], when=p["when"]) for p in parts],
                    default=c.get("viewer_default"), options=c.get("build_options", []), slug=self.slug)
        scripts = ""
        if parts:
            scripts = ('<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>\n'
                       '<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/STLLoader.js"></script>\n'
                       '<script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>\n'
                       + ('<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>\n' if c.get("build_options") else ""))
        scripts += f'<script>window.PROJECT = {json.dumps(data)};</script>\n<script src="../app.js"></script>'   # viewer, build picker, tabs, gallery
        body = hero + see + viewer + download + adjust_html + extra + docs_html
        return page(f"{self.title}", self.summary[:200], body, "../", nav, cover, scripts)

    def gallery(self):
        if "gallery" in self.cfg:
            return self.cfg["gallery"]
        imgs = [m for m in self.media if os.path.splitext(m)[1].lower() in {".png", ".jpg", ".jpeg", ".webp", ".gif"}
                and m != self.cover]
        return [dict(src=m, caption=pretty(os.path.splitext(os.path.basename(m))[0])) for m in imgs[:9]]

# ------------------------------------------------------------------ discovery + index
def discover():
    projs = []
    for name in sorted(os.listdir(ROOT)):
        d = os.path.join(ROOT, name)
        if not os.path.isdir(d) or name.startswith(".") or name in SKIP_DIRS:
            continue
        if walk_files(d, {".stl", ".scad"}):
            projs.append(Project(name))
    projs.sort(key=lambda p: (p.order, p.title.lower()))
    return projs

def render_index(projs):
    cards = []
    for p in projs:
        img = f'<img src="{p.slug}/{p.media_url(p.cover)}" alt="" loading="lazy">' if p.cover else '<div class="card-noimg"></div>'
        n = len(p.stls)
        cards.append(f"""
<a class="card" href="{p.slug}/">
  <div class="card-img">{img}</div>
  <div class="card-body">
    <h3>{esc(p.title)}</h3>
    <p>{esc(p.tagline or p.summary)[:220]}</p>
    <p class="card-meta">{n} printable part{'s' if n != 1 else ''} &middot; free download</p>
  </div>
</a>""")
    body = f"""
<section class="hero index-hero">
  <div class="wrap">
    <p class="eyebrow">Open-source &middot; 3D-printable &middot; parametric</p>
    <h1>{esc(SITE.get("headline", "3D-printable designs, free to download"))}</h1>
    <p class="lead">{esc(SITE.get("intro", ""))}</p>
  </div>
</section>
<section class="index-list">
  <div class="wrap">
    <div class="cards">{''.join(cards)}</div>
  </div>
</section>
<section class="band">
  <div class="wrap how">
    <div><h3>Make it fit your hardware</h3><p>Every design is parametric OpenSCAD. Each project page lists the settings to measure on your own phone, bike or parts, then you re-export the STLs with <a href="https://openscad.org/downloads.html">OpenSCAD</a> (free).</p></div>
    <div><h3>No printer?</h3><p>Upload the STLs to a local 3D-printing service. Each project lists the materials and print settings to ask for.</p></div>
    <div><h3>Prototypes</h3><p>These are working designs, not finished products. Check the status note on each project, and test the fit and strength before trusting them on a vehicle.</p></div>
  </div>
</section>"""
    return page(SITE.get("title", "3D Models"), SITE.get("intro", ""), body, "", [("Projects", "#top")],
                f"{projs[0].slug}/{projs[0].media_url(projs[0].cover)}" if projs and projs[0].cover else None)

def update_readme(projs):
    path = os.path.join(ROOT, "README.md")
    s = open(path, encoding="utf-8").read()
    a, b = "<!-- projects:start -->", "<!-- projects:end -->"
    if a not in s or b not in s:
        print("README.md has no <!-- projects:start/end --> markers; not updated"); return
    rows = ["| Project | What it is | Website | Folder |", "|---|---|---|---|"]
    for p in projs:
        what = (p.tagline or p.summary).replace("|", "/")
        what = what if len(what) <= 160 else what[:157].rsplit(" ", 1)[0] + "..."
        rows.append(f"| **{p.title}** | {what} | [page]({PAGES}{p.slug}/) | [`{p.folder}/`]({p.folder}/) |")
    new = s[:s.index(a) + len(a)] + "\n" + "\n".join(rows) + "\n" + s[s.index(b):]
    if new != s:
        open(path, "w", encoding="utf-8").write(new); print("updated README.md project list")
    else:
        print("README.md project list already up to date")

def main():
    projs = discover()
    if not projs: sys.exit("no projects found (folders with .stl or .scad files)")
    shutil.rmtree(OUT, ignore_errors=True)
    os.makedirs(OUT)
    for f in ("style.css", "app.js"):
        shutil.copy2(os.path.join(SITE_SRC, f), os.path.join(OUT, f))
    open(os.path.join(OUT, ".nojekyll"), "w").close()
    for p in projs:
        p.build()
        print(f"  {p.slug}/  {len(p.stls)} STL, {len(p.dxfs)} DXF, zip {fmt_size(p.zip_size)}")
    with open(os.path.join(OUT, "index.html"), "w", encoding="utf-8") as f:
        f.write(render_index(projs))
    if "--readme" in sys.argv:
        update_readme(projs)
    print(f"built {OUT}: {len(projs)} project(s)")

if __name__ == "__main__":
    main()

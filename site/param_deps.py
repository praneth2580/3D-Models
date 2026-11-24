#!/usr/bin/env python3
"""Work out which customizer settings change which part, by asking OpenSCAD itself.

For every printable part listed in <project>/website/project.json, and every setting in its "customize" block,
it exports the part as CSG (fast: no mesh is computed) once with the default values and once with the setting
changed. If the CSG differs, the setting changes that part. The result goes to <project>/website/param_deps.json,
which site/build.py reads: the website then offers each part only the settings that change it.

Run it after changing the CAD or the customize block, and commit the JSON:
    python3 site/param_deps.py phone_dock_v0.5 [--jobs 4]
Needs OpenSCAD on the PATH (or set OPENSCAD). Uses the Python standard library only.
"""
import argparse, datetime, hashlib, json, os, re, subprocess, sys, tempfile
from concurrent.futures import ThreadPoolExecutor

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OPENSCAD = os.environ.get("OPENSCAD", "openscad")


def scad_literal(v):
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(v)
    if isinstance(v, str): return json.dumps(v)
    if isinstance(v, list): return "[" + ",".join(scad_literal(x) for x in v) + "]"
    raise ValueError(v)


def read_defaults(proj_dir, sources, names):
    """The first top-level `name = value;` for each setting, in the order the sources are listed."""
    out = {}
    for src in sources:
        text = open(os.path.join(proj_dir, src), encoding="utf-8").read()
        for n in names:
            if n in out: continue
            m = re.search(r"^\s*" + re.escape(n) + r"\s*=\s*([^;]+);", text, re.M)
            if m:
                raw = m.group(1).strip()
                try: out[n] = json.loads(raw)
                except ValueError: out[n] = None          # an expression: the default comes from the CAD itself
    return out


TEST_SVG = os.path.join(tempfile.gettempdir(), "param_deps_test_logo.svg")   # a plain shape, for "file" settings


def test_values(p, default):
    """Other values to try, in order: the first one OpenSCAD accepts is used."""
    if p.get("type") == "file":
        with open(TEST_SVG, "w") as f:
            f.write('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="20"><path d="M0 0H40V20H0Z"/></svg>')
        return [TEST_SVG]
    if "choices" in p:
        return [c[0] for c in p["choices"] if c[0] != default]
    if p.get("type") == "text":
        return [default + "X" if default else "X"]
    if p.get("type") == "code":          # other digits, and (if allowed) a longer and a shorter code
        lo, hi = p["digits"]; n0, n1 = p["length"]
        vals = [[lo + (x - lo + 1) % (hi - lo + 1) for x in default]]
        if len(default) < n1: vals.append(default + [lo])
        if len(default) > n0: vals.append(default[:-1])
        return vals
    step = p.get("step", 0.1)
    vals = [default + 5*step, default - 5*step, default + step, default - step]
    lo, hi = p.get("min", -1e9), p.get("max", 1e9)
    return [round(v, 6) for v in vals if lo <= v <= hi]


def make_args(cfg, stem, meta):
    mk = meta.get("make", {})
    args = ["-D", f'{cfg.get("part_var", "PART")}={json.dumps(mk.get("part", stem))}']
    for k, v in mk.get("set", {}).items():
        args += ["-D", f"{k}={scad_literal(v)}"]
    return args


def csg_hash(proj_dir, entry, args):
    with tempfile.TemporaryDirectory() as d:
        out = os.path.join(d, "x.csg")
        r = subprocess.run([OPENSCAD, "-o", out] + args + [os.path.join(proj_dir, entry)], capture_output=True, text=True)
        log = r.stderr + r.stdout
        bad = [l for l in log.splitlines() if l.startswith(("ERROR", "WARNING: Ignoring unknown variable"))]
        if r.returncode != 0 or bad or not os.path.exists(out):
            return None, (bad or log.splitlines()[-3:])
        return hashlib.sha1(open(out, "rb").read()).hexdigest(), None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("project")
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 4)
    a = ap.parse_args()
    proj_dir = os.path.join(ROOT, a.project)
    pj = json.load(open(os.path.join(proj_dir, "website", "project.json"), encoding="utf-8"))
    cfg = pj["customize"]
    params = [p for g in cfg["groups"] for p in g["params"]]
    defaults = read_defaults(proj_dir, cfg["sources"], [p["name"] for p in params])
    missing = [p["name"] for p in params if p["name"] not in defaults]
    if missing: sys.exit(f"Settings not found in the sources: {missing}")
    parts = {s: m for s, m in pj.get("parts", {}).items() if not m.get("view")}

    tests, kind = {}, {p["name"]: p.get("type", "") for p in params}
    for p in params:
        d = defaults[p["name"]]
        if d is None: sys.exit(f"{p['name']}: its default is an expression; give it a literal value in the CAD")
        tests[p["name"]] = test_values(p, d)

    def probe(job):
        stem, name, base = job
        if name is None: return csg_hash(proj_dir, cfg["entry"], base)
        err, hashes = None, []
        for v in tests[name]:          # numbers: the first test value OpenSCAD accepts (an assert can refuse one);
            h, err = csg_hash(proj_dir, cfg["entry"], base + ["-D", f"{name}={scad_literal(v)}"])
            if h is not None:          # codes: every test value (the digits and the length can matter separately)
                hashes.append(h)
                if kind[name] != "code": break
        return (hashes, None) if hashes else (None, err or ["no test value in range"])

    jobs = [(stem, name, make_args(cfg, stem, meta)) for stem, meta in parts.items() for name in [None] + [p["name"] for p in params]]
    print(f"{len(parts)} parts x {len(params)} settings: {len(jobs)} probes", flush=True)
    with ThreadPoolExecutor(a.jobs) as ex:
        results = dict(zip([(j[0], j[1]) for j in jobs], ex.map(probe, jobs)))

    deps, problems = {}, []
    for stem in parts:
        base_h, base_err = results[(stem, None)]
        if base_h is None:
            problems.append(f"{stem}: the default export fails: {base_err}"); continue
        names = []
        for p in params:
            h, err = results[(stem, p["name"])]
            if h is None:              # every test value refused: assume it matters to this part
                names.append(p["name"]); problems.append(f"{stem} / {p['name']}: no test value accepted ({err})"); continue
            if any(x != base_h for x in h): names.append(p["name"])
        deps[stem] = names
    out = {"generated": datetime.date.today().isoformat(),
           "note": "Made by site/param_deps.py: which customizer settings change each part. Regenerate after CAD changes.",
           "defaults": defaults, "parts": deps}
    with open(os.path.join(proj_dir, "website", "param_deps.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1); f.write("\n")
    for stem, names in deps.items(): print(f"  {stem}: {', '.join(names) or '(nothing)'}")
    for pr in problems: print("  !", pr)
    print("wrote", os.path.join(a.project, "website", "param_deps.json"))


if __name__ == "__main__":
    main()

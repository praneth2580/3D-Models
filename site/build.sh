#!/usr/bin/env bash
# Builds the GitHub Pages site into _site/ (run from the repository root, or from anywhere).
# Used by .github/workflows/pages.yml; run it locally to preview:  bash site/build.sh && python3 -m http.server -d _site
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/meteor_phone_dock_v0.5"
OUT="$ROOT/_site"
NAME="meteor_phone_dock_v0.5"

rm -rf "$OUT"
mkdir -p "$OUT/files" "$OUT/media"
cp "$ROOT"/site/index.html "$ROOT"/site/style.css "$ROOT"/site/app.js "$OUT/"
touch "$OUT/.nojekyll"

# Printable parts, 2D cutting files, the parametric source and the docs.
for f in "$SRC"/*.stl "$SRC"/*.dxf "$SRC"/*.scad "$SRC"/*.md; do
  case "$(basename "$f")" in cam_template.stl) continue ;; esac   # obsolete (replaced by crank_template)
  cp "$f" "$OUT/files/"
done
cp "$SRC"/images/*.png "$SRC"/images/*.svg "$OUT/media/"
cp "$SRC"/video/mechanism_demo.mp4 "$OUT/media/"

# One zip with everything needed to build or modify it (no old versions, no caches).
( cd "$ROOT" && zip -q -r "$OUT/files/$NAME.zip" "$NAME" \
    -x "$NAME/archive/*" "*/__pycache__/*" "*.csg" "$NAME/cam_template.stl" )

# File sizes for the download table.
python3 - "$OUT/files" <<'PY'
import json, os, sys
d = sys.argv[1]
json.dump({f: os.path.getsize(os.path.join(d, f)) for f in sorted(os.listdir(d))},
          open(os.path.join(d, "manifest.json"), "w"), indent=1)
PY
echo "built $OUT ($(du -sh "$OUT" | cut -f1))"

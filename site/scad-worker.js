// Runs OpenSCAD (compiled to WebAssembly) in a background thread, so the page stays responsive while a part is made.
// The page sends {id, base, sources, entry, defines, uploads}; uploads are [path, text] files the visitor chose in their
// own browser (a logo SVG), written next to the design: they never leave this computer. The worker fetches the project's .scad files from `base`,
// runs OpenSCAD on `entry` with the -D settings, and sends back {id, ok, stl (ArrayBuffer), log, error, ms}.
// It also sends {id, status} lines while it works. A fresh OpenSCAD instance is used for every part (one run each).
const OPENSCAD_URL = "https://cdn.jsdelivr.net/npm/openscad-wasm@0.0.4/openscad.js";   // OpenSCAD 2025.07.18, GPL-2.0
const FONTS = ["LiberationSans-Regular.ttf", "LiberationSans-Bold.ttf"];                 // SIL OFL 1.1, see fonts/OFL.txt

let lib = null;
const texts = {}, binaries = {};
const getText = async (url) => texts[url] ?? (texts[url] = await fetchOk(url).then((r) => r.text()));
const getBin = async (url) => binaries[url] ?? (binaries[url] = new Uint8Array(await fetchOk(url).then((r) => r.arrayBuffer())));
async function fetchOk(url) {
  const r = await fetch(url);
  if (!r.ok) throw new Error(`couldn't load ${url} (${r.status})`);
  return r;
}
function mkdirs(FS, path) {
  let p = "";
  for (const part of path.split("/").slice(1, -1)) {
    p += "/" + part;
    try { FS.mkdir(p); } catch (e) { /* exists */ }
  }
}

self.onmessage = async (e) => {
  const { id, base, fontBase, sources, entry, defines, uploads = [] } = e.data;
  const say = (status) => self.postMessage({ id, status });
  const t0 = performance.now();
  const log = [];
  try {
    if (!lib) { say("Downloading OpenSCAD (about 14 MB, once)…"); lib = await import(OPENSCAD_URL); }
    say("Loading the design…");
    const files = await Promise.all(sources.map(async (rel) => [rel, await getText(base + rel)]));
    const needFonts = files.some(([, t]) => /\btext\s*\(/.test(t));
    const fonts = needFonts ? await Promise.all(FONTS.map(async (f) => [f, await getBin(fontBase + f)])) : [];
    say("Starting OpenSCAD…");
    const o = await lib.createOpenSCAD({ print: (t) => log.push(t), printErr: (t) => { log.push(t); if (/^(Rendering|Geometries|Total rendering|Compiling)/.test(t)) say(t); } });
    const inst = o.getInstance();
    for (const [rel, text] of files) { mkdirs(inst.FS, "/p/" + rel); inst.FS.writeFile("/p/" + rel, text); }
    const dir = entry.includes("/") ? entry.replace(/[^/]*$/, "") : "";
    for (const [rel, text] of uploads) { mkdirs(inst.FS, "/p/" + dir + rel); inst.FS.writeFile("/p/" + dir + rel, text); }
    for (const [f, data] of fonts) { mkdirs(inst.FS, "/fonts/" + f); inst.FS.writeFile("/fonts/" + f, data); }
    const args = ["/p/" + entry, "-o", "/out.stl", "--export-format=binstl", "--backend=Manifold"];
    for (const d of defines) args.push("-D", d);
    say("Making the part…");
    let rc;
    try { rc = inst.callMain(args); } catch (err) { rc = typeof err === "object" && err && "status" in err ? err.status : String(err); }
    const errors = log.filter((l) => /^(ERROR|WARNING: (Ignoring unknown|Can't open))|Assertion .* failed/.test(l));
    let stl = null;
    try { stl = inst.FS.readFile("/out.stl"); } catch (err) { /* no output */ }
    if (!stl || !stl.length || (rc !== 0 && rc !== undefined)) {
      const assert = errors.find((l) => /Assertion/.test(l));
      // A failed check in the design (an assert) carries a message for people: show just that.
      const msg = assert && (assert.match(/failed: "(.*)"/) || [])[1];
      const why = msg ? `the design's own check refused these sizes: ${msg.replace(/\\"/g, '"')}` :
        (errors[0] || log.slice(-3).join(" ") || `OpenSCAD stopped (${rc})`).replace(/ in file .*$/, "");
      self.postMessage({ id, ok: false, error: why, log: log.slice(-40), ms: performance.now() - t0 });
      return;
    }
    const buf = stl.buffer.slice(stl.byteOffset, stl.byteOffset + stl.byteLength);
    self.postMessage({ id, ok: true, stl: buf, log: log.slice(-40), warnings: errors, ms: performance.now() - t0 }, [buf]);
  } catch (err) {
    self.postMessage({ id, ok: false, error: String(err && err.message || err), log: log.slice(-40), ms: performance.now() - t0 });
  }
};

// Project page behaviour. The page sets window.PROJECT = {parts: [{file, name, qty, when, group, make, params}], groups,
// customize, default, options, slug}. Each part works without the others: menu, video tabs, gallery lightbox, 3D viewer
// (parts listed in groups), build picker, and the customizer (makes a part to your sizes with OpenSCAD in the browser).
const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

// ---------- menu: close the mobile menu after a pick; mark the section in view
(function () {
  const menu = document.querySelector(".menu");
  if (menu) menu.addEventListener("click", (e) => { if (e.target.closest("a")) menu.open = false; });
  const links = [...document.querySelectorAll('.sections a[href^="#"], .menu-pop a[href^="#"]')];
  const ids = [...new Set(links.map((a) => a.getAttribute("href").slice(1)))].filter((id) => document.getElementById(id));
  if (!ids.length || !("IntersectionObserver" in window)) return;
  const mark = (id) => links.forEach((a) => a.classList.toggle("here", a.getAttribute("href") === "#" + id));
  const io = new IntersectionObserver((es) => {
    const vis = es.filter((e) => e.isIntersecting).sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
    if (vis.length) mark(vis[0].target.id);
  }, { rootMargin: "-40% 0px -55% 0px" });
  ids.forEach((id) => io.observe(document.getElementById(id)));
})();

// ---------- video tabs (only one player shown; switching pauses the other)
(function () {
  const tabs = [...document.querySelectorAll(".tabs .tab")];
  if (!tabs.length) return;
  const panes = [...document.querySelectorAll(".videos [data-pane]")];
  tabs.forEach((t) => t.addEventListener("click", () => {
    tabs.forEach((x) => x.setAttribute("aria-selected", String(x === t)));
    panes.forEach((p) => {
      const on = p.dataset.pane === t.dataset.tab;
      p.hidden = !on;
      if (!on) { const v = p.querySelector("video"); if (v) v.pause(); }
    });
  }));
})();

// ---------- gallery lightbox: click a picture to see it big; arrows and Esc
(function () {
  const links = [...document.querySelectorAll(".gallery a.zoom")];
  if (!links.length) return;
  const box = document.createElement("div");
  box.className = "lightbox"; box.hidden = true;
  box.setAttribute("role", "dialog"); box.setAttribute("aria-modal", "true"); box.setAttribute("aria-label", "Picture");
  box.innerHTML = '<button class="lb-close" aria-label="Close">&times;</button><button class="lb-prev" aria-label="Previous">&#8249;</button>' +
    '<figure><img alt=""><figcaption></figcaption></figure><button class="lb-next" aria-label="Next">&#8250;</button>';
  document.body.appendChild(box);
  const img = box.querySelector("img"), cap = box.querySelector("figcaption");
  let i = 0, last = null;
  const show = (k) => {
    i = (k + links.length) % links.length;
    img.src = links[i].href; img.alt = links[i].querySelector("img").alt;
    cap.textContent = links[i].closest("figure").querySelector("figcaption")?.textContent || "";
  };
  const open = (k) => { last = document.activeElement; show(k); box.hidden = false; document.body.classList.add("lb-open"); box.querySelector(".lb-close").focus(); };
  const close = () => { box.hidden = true; document.body.classList.remove("lb-open"); if (last) last.focus(); };
  links.forEach((a, k) => a.addEventListener("click", (e) => { e.preventDefault(); open(k); }));
  box.querySelector(".lb-close").onclick = close;
  box.querySelector(".lb-prev").onclick = () => show(i - 1);
  box.querySelector(".lb-next").onclick = () => show(i + 1);
  box.addEventListener("click", (e) => { if (e.target === box) close(); });
  document.addEventListener("keydown", (e) => {
    if (box.hidden) return;
    if (e.key === "Escape") close();
    if (e.key === "ArrowLeft") show(i - 1);
    if (e.key === "ArrowRight") show(i + 1);
  });
})();

// ---------- 3D STL viewer
const VIEWER = (function () {
  const P = window.PROJECT;
  const canvas = document.getElementById("stl-canvas");
  const api = { setVisible() {}, visible: () => [], current: () => -1, showBuffer() {}, onPart: null };
  if (!P || !P.parts || !P.parts.length || !canvas) return api;
  const info = document.getElementById("stage-info");
  const dl = document.getElementById("stage-dl");
  const btns = document.getElementById("part-buttons");
  let visible = P.parts.map(() => true), current = -1, started = false;

  // The part list, in the project's groups (each one opens and closes).
  const groups = P.groups && P.groups.length ? P.groups : [{ label: "" }];
  const partBtn = (p, i) => `<button class="part-btn" role="tab" data-i="${i}" aria-selected="false">${esc(p.name)}` +
    `<small>${esc(p.file)} · qty ${esc(p.qty)}${p.params && p.params.length ? ' · <span class="adj-badge">your size</span>' : ""}</small></button>`;
  btns.innerHTML = groups.map((g, gi) => {
    const items = P.parts.map((p, i) => [p, i]).filter(([p]) => (p.group || 0) === gi);
    if (!items.length) return "";
    const head = g.label ? `<button class="pg-head" type="button" aria-expanded="${!g.closed}"><span>${esc(g.label)}</span><span class="pg-n"></span></button>` : "";
    return `<div class="pgroup" data-g="${gi}">${head}<div class="pg-body"${g.closed ? " hidden" : ""}>${items.map(([p, i]) => partBtn(p, i)).join("")}</div></div>`;
  }).join("");
  const buttons = [...btns.querySelectorAll(".part-btn")];
  const openGroup = (box, open) => {
    const h = box.querySelector(".pg-head"), body = box.querySelector(".pg-body");
    if (h) h.setAttribute("aria-expanded", String(open));
    body.hidden = !open;
  };
  const countGroups = () => btns.querySelectorAll(".pgroup").forEach((box) => {
    const n = [...box.querySelectorAll(".part-btn")].filter((b) => !b.hidden).length;
    box.hidden = n === 0;
    const c = box.querySelector(".pg-n"); if (c) c.textContent = n;
  });
  countGroups();
  const selectBtn = (i) => buttons.forEach((b) => {
    const on = +b.dataset.i === i;
    b.setAttribute("aria-selected", String(on));
    if (on) openGroup(b.closest(".pgroup"), true);
  });

  let show = (i) => { current = i; selectBtn(i); if (api.onPart) api.onPart(i); };
  api.visible = () => visible.slice();
  api.current = () => current;
  // The part shown first: P.default is a stem or a list of stems; the first one that is in the chosen build wins.
  const defaults = [].concat(P.default || []);
  const pick = () => {
    for (const d of defaults) { const k = P.parts.findIndex((p, i) => visible[i] && p.file.replace(/\.stl$/i, "") === d); if (k >= 0) return k; }
    return Math.max(0, visible.indexOf(true));
  };
  api.setVisible = (vis) => {
    const was = current >= 0 ? defaults.indexOf(P.parts[current].file.replace(/\.stl$/i, "")) : -1;
    visible = vis;
    buttons.forEach((b, i) => { b.hidden = !vis[i]; });
    countGroups();
    // Showing a default (say, the assembled model for one lock) or a part no longer in the build: switch to the new default.
    if (started && current >= 0 && (!vis[current] || was >= 0)) { const k = pick(); if (k !== current) show(k); }
  };

  if (!window.THREE || !THREE.STLLoader || !THREE.OrbitControls) {
    info.textContent = "The 3D viewer couldn't load (offline, or scripts blocked). The downloads below still work.";
    dl.style.display = "none";
    return api;
  }

  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 5000);
  const controls = new THREE.OrbitControls(camera, canvas);
  controls.enableDamping = true;
  scene.add(new THREE.HemisphereLight(0xffffff, 0x445566, 0.85));
  const key = new THREE.DirectionalLight(0xffffff, 0.75); key.position.set(1, 1.5, 2); scene.add(key);
  const rim = new THREE.DirectionalLight(0xffffff, 0.35); rim.position.set(-2, -1, -1); scene.add(rim);
  const accent = getComputedStyle(document.documentElement).getPropertyValue("--accent").trim() || "#e8590c";
  const material = new THREE.MeshStandardMaterial({ color: new THREE.Color(accent), roughness: 0.55, metalness: 0.05 });
  const loader = new THREE.STLLoader();
  const cache = {};
  let mesh = null, token = 0;

  function resize() {
    const w = canvas.clientWidth, h = canvas.clientHeight;
    if (!w || !h) return;
    renderer.setSize(w, h, false);
    camera.aspect = w / h; camera.updateProjectionMatrix();
  }
  window.addEventListener("resize", resize);

  // Put a geometry on the stage, framed. label: what the info line says it is.
  function place(geo, label) {
    if (mesh) scene.remove(mesh);
    mesh = new THREE.Mesh(geo, material);
    scene.add(mesh);
    geo.computeBoundingBox();
    const bb = geo.boundingBox, size = new THREE.Vector3(), c = new THREE.Vector3();
    bb.getSize(size); bb.getCenter(c);
    mesh.position.copy(c).multiplyScalar(-1);
    const d = (size.length() / 2) / Math.sin(THREE.MathUtils.degToRad(camera.fov / 2)) * 1.05;
    camera.up.set(0, 0, 1);
    camera.position.set(d * 0.55, -d * 0.65, d * 0.55);
    camera.near = d / 100; camera.far = d * 10; camera.updateProjectionMatrix();
    controls.target.set(0, 0, 0); controls.update();
    info.innerHTML = `${label} · ${size.x.toFixed(0)} × ${size.y.toFixed(0)} × ${size.z.toFixed(0)} mm`;
  }

  show = function (i) {
    current = i;
    const part = P.parts[i];
    selectBtn(i);
    dl.href = `files/${part.file}`; dl.textContent = "Download this STL"; dl.download = part.file;
    info.innerHTML = `<b>${esc(part.name)}</b> · loading…`;
    const my = ++token;
    const done = (geo) => { if (my === token) place(geo, `<b>${esc(part.name)}</b>`); };
    if (api.onPart) api.onPart(i);
    if (cache[part.file]) return done(cache[part.file]);
    loader.load(`files/${part.file}`, (geo) => { geo.computeVertexNormals(); cache[part.file] = geo; done(geo); },
      undefined, () => { if (my === token) info.innerHTML = `<b>${esc(part.name)}</b> · couldn't load this file.`; });
  };

  // Show an STL made in the browser (the customizer), with its own download link.
  api.showBuffer = (i, buf, url, fileName) => {
    if (i !== current) show(i);
    ++token;
    const geo = loader.parse(buf); geo.computeVertexNormals();
    place(geo, `<b>${esc(P.parts[i].name)}</b>, <span class="yours">your size</span>`);
    dl.href = url; dl.download = fileName; dl.textContent = "Download your STL";
  };

  btns.addEventListener("click", (e) => {
    const h = e.target.closest(".pg-head");
    if (h) { const box = h.closest(".pgroup"); openGroup(box, box.querySelector(".pg-body").hidden); return; }
    const b = e.target.closest(".part-btn");
    if (b) show(+b.dataset.i);
  });

  // Load the first part only when the viewer comes into view, so the page itself stays light.
  const start = () => {
    if (started) return; started = true; resize();
    show(pick());
  };
  if ("IntersectionObserver" in window) {
    new IntersectionObserver((es, o) => { if (es.some((e) => e.isIntersecting)) { start(); o.disconnect(); } }, { rootMargin: "200px" }).observe(canvas);
  } else start();

  (function loop() { requestAnimationFrame(loop); if (started) { controls.update(); renderer.render(scene, camera); } })();
  return api;
})();

// ---------- customizer: make the selected part to your own sizes, with OpenSCAD running in the browser.
// Each part offers only the settings that change it (worked out by site/param_deps.py). Your values are kept for
// every part, and in this browser for next time.
const CUSTOM = (function () {
  const P = window.PROJECT, box = document.getElementById("custom");
  if (!P || !P.customize || !box) return null;
  const C = P.customize, KEY = "sizes:" + P.slug;
  const defs = {};
  C.groups.forEach((g) => g.params.forEach((q) => { defs[q.name] = q; }));
  let values = {};
  try { values = JSON.parse(localStorage.getItem(KEY) || "{}"); } catch (e) { /* storage blocked */ }
  Object.keys(values).forEach((k) => { if (!defs[k]) delete values[k]; });
  const val = (n) => (n in values ? values[n] : defs[n].default);
  const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);
  const changed = (names) => names.filter((n) => !same(val(n), defs[n].default));
  const save = () => { try { localStorage.setItem(KEY, JSON.stringify(values)); } catch (e) { /* not saved */ } };
  const lit = (v) => (typeof v === "string" ? JSON.stringify(v) : Array.isArray(v) ? "[" + v.join(",") + "]" : String(v));
  const stem = (p) => p.file.replace(/\.stl$/i, "");
  const defines = (p) => [`${C.part_var}=${JSON.stringify(p.make.part)}`]
    .concat(Object.entries(p.make.set || {}).map(([k, v]) => `${k}=${lit(v)}`))
    .concat(p.params.map((n) => `${n}=${lit(val(n))}`));
  const shown = (v, q) => (q.type === "code" ? v.join(" ") : String(v));

  // ---- the worker (one part at a time)
  let worker = null, seq = 0;
  const waiting = {};
  function run(p, onStatus) {
    if (!worker) {
      worker = new Worker(new URL("../scad-worker.js", location.href), { type: "module" });
      worker.onmessage = (e) => {
        const w = waiting[e.data.id]; if (!w) return;
        if ("status" in e.data) { w.onStatus(e.data.status); return; }
        delete waiting[e.data.id]; w.resolve(e.data);
      };
      worker.onerror = (e) => Object.keys(waiting).forEach((id) => { waiting[id].resolve({ ok: false, error: e.message || "the OpenSCAD worker failed" }); delete waiting[id]; });
    }
    const id = ++seq;
    return new Promise((resolve) => {
      waiting[id] = { resolve, onStatus };
      worker.postMessage({ id, base: new URL("scad/", location.href).href, fontBase: new URL("../fonts/", location.href).href,
                           sources: C.sources, entry: C.entry, defines: defines(p) });
    });
  }

  // ---- results, kept per part and per set of values
  const made = {};                       // file -> {key, url, buf, name}
  const keyOf = (p) => JSON.stringify(p.params.map((n) => val(n)));
  let busy = false;

  function field(q) {
    const v = val(q.name), id = "cz-" + q.name, dflt = shown(q.default, q);
    let input;
    if (q.choices) {
      input = `<select id="${id}" data-n="${q.name}">` + q.choices.map(([cv, lb]) =>
        `<option value='${esc(JSON.stringify(cv))}'${same(cv, v) ? " selected" : ""}>${esc(lb)}</option>`).join("") + "</select>";
    } else if (q.type === "code") {
      input = `<input id="${id}" data-n="${q.name}" type="text" inputmode="numeric" autocomplete="off" spellcheck="false" value="${esc(v.join(" "))}">`;
    } else {
      input = `<span class="cz-num"><input id="${id}" data-n="${q.name}" type="number" step="${q.step ?? "any"}"` +
        `${q.min != null ? ` min="${q.min}"` : ""}${q.max != null ? ` max="${q.max}"` : ""} value="${v}">${q.unit ? `<span class="unit">${esc(q.unit)}</span>` : ""}</span>`;
    }
    const isChanged = !same(v, q.default);
    return `<div class="cz-field${isChanged ? " changed" : ""}"><label for="${id}">${esc(q.label)}</label>${input}` +
      `<small>${q.help ? esc(q.help) + " " : ""}Default ${esc(q.choices ? (q.choices.find(([cv]) => same(cv, q.default)) || [, dflt])[1] : dflt)}${q.unit && !q.choices && q.type !== "code" ? " " + esc(q.unit) : ""}.</small>` +
      `<span class="cz-err" hidden></span></div>`;
  }
  function parse(q, el) {
    if (q.choices) return { v: JSON.parse(el.value) };
    if (q.type === "code") {
      const d = el.value.trim().split(/[\s,]+/).filter(Boolean).map(Number);
      const [lo, hi] = q.digits, [n0, n1] = q.length;
      if (d.some((x) => !Number.isInteger(x) || x < lo || x > hi)) return { err: `Digits ${lo} to ${hi} only.` };
      if (d.length < n0 || d.length > n1) return { err: n0 === n1 ? `${n0} digits.` : `${n0} to ${n1} digits.` };
      return { v: d };
    }
    const x = Number(el.value);
    if (el.value.trim() === "" || !isFinite(x)) return { err: "Enter a number." };
    if ((q.min != null && x < q.min) || (q.max != null && x > q.max)) return { err: `Between ${q.min} and ${q.max}${q.unit ? " " + q.unit : ""}.` };
    return { v: x };
  }

  function render(i) {
    if (i < 0) { box.hidden = true; return; }
    const p = P.parts[i];
    box.hidden = false;
    if (!p.params || !p.params.length) {
      box.innerHTML = `<p class="cz-none"><b>${esc(p.name)}</b> is the same for every build: none of the sizes you can set change it.` +
        (P.customize ? ` Pick a part marked <span class="adj-badge">your size</span> to make it to your own measurements.` : "") + "</p>";
      return;
    }
    const groups = C.groups.map((g) => [g, g.params.filter((q) => p.params.includes(q.name))]).filter(([, qs]) => qs.length);
    const ch = changed(p.params);
    const ready = made[p.file] && made[p.file].key === keyOf(p);
    box.innerHTML = `<div class="cz-head"><h3>Make it your size: ${esc(p.name)}</h3>` +
      `<p class="sub">Only the settings that change this part are shown. Your values are kept for every part (in this browser).</p></div>` +
      groups.map(([g, qs]) => `<fieldset><legend>${esc(g.label)}</legend>${g.note ? `<p class="cz-note">${esc(g.note)}</p>` : ""}` +
        `<div class="cz-grid">${qs.map(field).join("")}</div></fieldset>`).join("") +
      `<div class="cz-actions"><button class="btn" type="button" data-act="make"${busy ? " disabled" : ""}>Make this part${ch.length ? "" : " (default sizes)"}</button>` +
      `${ready ? `<a class="btn ghost" href="${made[p.file].url}" download="${esc(made[p.file].name)}">Download your STL</a><button class="btn ghost" type="button" data-act="show">Show it</button>` : ""}` +
      `<button class="btn ghost" type="button" data-act="reset"${ch.length ? "" : " disabled"}>Back to the defaults</button></div>` +
      `<p class="cz-status" aria-live="polite">${ready ? "Your version is ready." : ch.length ? `${ch.length} setting${ch.length > 1 ? "s" : ""} changed from the ready-made file.` : "These are the ready-made file's sizes."}</p>` +
      `<details class="cz-cmd"><summary>Or make it with OpenSCAD on your computer</summary><pre><code>${esc(command(p))}</code></pre>` +
      `<p class="small-note">Run it in the folder with <code>${esc(C.entry)}</code> (in the project's .zip).</p></details>`;
  }
  function command(p) {
    const q = (s) => "'" + s.replace(/'/g, "'\\''") + "'";
    return `openscad ${defines(p).filter((d, k) => k < 1 + Object.keys(p.make.set || {}).length || !same(val(d.split("=")[0]), defs[d.split("=")[0]].default))
      .map((d) => "-D " + q(d)).join(" ")} -o ${stem(p)}.stl ${C.entry}`;
  }

  box.addEventListener("change", (e) => {
    const el = e.target.closest("[data-n]"); if (!el) return;
    const q = defs[el.dataset.n], r = parse(q, el);
    const err = el.closest(".cz-field").querySelector(".cz-err");
    err.hidden = !r.err; err.textContent = r.err || "";
    if (r.err) return;
    if (same(r.v, q.default)) delete values[q.name]; else values[q.name] = r.v;
    save();
    render(VIEWER.current());
  });
  box.addEventListener("click", async (e) => {
    const b = e.target.closest("[data-act]"); if (!b) return;
    const i = VIEWER.current(), p = P.parts[i];
    if (b.dataset.act === "reset") { p.params.forEach((n) => delete values[n]); save(); render(i); return; }
    if (b.dataset.act === "show") { const m = made[p.file]; VIEWER.showBuffer(i, m.buf, m.url, m.name); return; }
    if (b.dataset.act !== "make" || busy) return;
    if (box.querySelector(".cz-err:not([hidden])")) return;
    busy = true; b.disabled = true;
    const status = box.querySelector(".cz-status");
    status.textContent = "Starting…";
    const res = await run(p, (t) => { status.textContent = t; });
    busy = false;
    if (!res.ok) { render(i); box.querySelector(".cz-status").innerHTML = `<span class="cz-fail">Couldn't make it: ${esc(res.error)}</span>`; return; }
    const name = `${stem(p)}-your-size.stl`;
    if (made[p.file]) URL.revokeObjectURL(made[p.file].url);
    made[p.file] = { key: keyOf(p), buf: res.stl, url: URL.createObjectURL(new Blob([res.stl], { type: "model/stl" })), name };
    if (VIEWER.current() === i) VIEWER.showBuffer(i, res.stl, made[p.file].url, name);
    render(VIEWER.current());
    if (VIEWER.current() === i) box.querySelector(".cz-status").textContent = `Made in ${(res.ms / 1000).toFixed(0)} s. It's in the viewer now; check it, then download it.`;
  });

  VIEWER.onPart = render;
  render(VIEWER.current());
  return { run, values: () => values, changed, made, keyOf, defines };
})();

// ---------- build picker: show only the parts for the chosen options; zip them in the browser
(function () {
  const P = window.PROJECT;
  const box = document.getElementById("choose");
  if (!P || !P.options || !P.options.length || !box) return;
  const KEY = "build:" + P.slug;
  const state = {};
  P.options.forEach((o) => { state[o.id] = o.choices[0].id; });
  try { Object.assign(state, JSON.parse(localStorage.getItem(KEY) || "{}")); } catch (e) { /* storage blocked: use the defaults */ }
  const all = document.getElementById("b-all");
  const rows = [...document.querySelectorAll("#download tr[data-when]")];
  const fits = (when) => Object.entries(when || {}).every(([k, v]) => (Array.isArray(v) ? v : [v]).includes(state[k]));
  const label = () => P.options.map((o) => (o.choices.find((c) => c.id === state[o.id]) || {}).label).join(" + ");

  function apply() {
    box.querySelectorAll(".chip").forEach((c) => c.setAttribute("aria-checked", String(state[c.dataset.opt] === c.dataset.choice)));
    const showAll = all.checked;
    let n = 0;
    rows.forEach((r) => {
      const ok = fits(JSON.parse(r.dataset.when || "{}"));
      r.hidden = !(ok || showAll);
      r.classList.toggle("other", !ok);
      if (ok && /\.stl$/i.test(r.dataset.file) && !r.dataset.view) n++;
    });
    document.querySelectorAll("#download tr.group-row").forEach((g) => {
      g.hidden = !rows.some((r) => !r.hidden && r.dataset.group === g.dataset.group);
    });
    document.getElementById("b-count").innerHTML = `<b>${n}</b> printable parts for <b>${esc(label())}</b>`;
    VIEWER.setVisible(P.parts.map((p) => showAll || fits(p.when)));
    document.querySelectorAll(".build-note").forEach((e) => { e.hidden = showAll; e.querySelector(".build-name").textContent = label(); });
    try { localStorage.setItem(KEY, JSON.stringify(state)); } catch (e) { /* not saved: fine */ }
  }
  box.addEventListener("click", (e) => {
    const c = e.target.closest(".chip");
    if (!c) return;
    state[c.dataset.opt] = c.dataset.choice;
    apply();
  });
  all.addEventListener("change", apply);
  apply();

  const zipBtn = document.getElementById("b-zip"), mineBtn = document.getElementById("b-zip-mine"), status = document.getElementById("b-status");
  // mine: parts whose settings you changed are made to your sizes in the browser; the rest are the ready-made files.
  async function makeZip(btn, mine) {
    if (!window.JSZip) { status.textContent = "The zip tool couldn't load. Use the download links in the list instead."; return; }
    const files = [...new Set(rows.filter((r) => !r.dataset.view && fits(JSON.parse(r.dataset.when || "{}"))).map((r) => r.dataset.file))];
    const zip = new JSZip();
    const folder = zip.folder(P.slug + "-" + Object.values(state).join("-") + (mine ? "-your-size" : ""));
    const yours = [];
    zipBtn.disabled = true; if (mineBtn) mineBtn.disabled = true;
    try {
      let k = 0;
      for (const f of files) {
        const p = P.parts.find((x) => x.file === f);
        const custom = mine && p && CUSTOM && CUSTOM.changed(p.params || []).length;
        status.textContent = `${custom ? "Making" : "Adding"} ${++k} of ${files.length}: ${f}${custom ? " (your size; big parts take a minute)" : ""}`;
        if (custom) {
          const m = CUSTOM.made[f];
          let buf = m && m.key === CUSTOM.keyOf(p) ? m.buf : null;
          if (!buf) {
            const res = await CUSTOM.run(p, (t) => { status.textContent = `Making ${k} of ${files.length}: ${f}: ${t}`; });
            if (!res.ok) throw new Error(`${f}: ${res.error}`);
            buf = res.stl;
          }
          folder.file(f, buf); yours.push(f);
          continue;
        }
        const res = await fetch("files/" + f);
        if (!res.ok) throw new Error(f);
        folder.file(f, await res.blob());
      }
      const sizes = mine ? Object.entries(CUSTOM.values()).map(([n, v]) => `  ${n} = ${JSON.stringify(v)}`).join("\n") : "";
      folder.file("BUILD.txt", `${document.title}\nBuild: ${label()}\nParts: ${files.join(", ")}\n` +
        (mine ? `\nMade to your sizes in the browser: ${yours.join(", ") || "(none: no setting changed)"}\nYour settings:\n${sizes}\n` : "") +
        `\nThe source, the guides and the full list are in the project's main .zip.\n`);
      status.textContent = "Packing…";
      const blob = await zip.generateAsync({ type: "blob" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob); a.download = folder.root.replace(/\/$/, "") + ".zip";
      document.body.appendChild(a); a.click(); a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 4000);
      status.textContent = `Downloaded ${files.length} files${mine ? `, ${yours.length} made to your sizes` : ""}.`;
    } catch (e) {
      status.textContent = "Couldn't make the zip (" + e.message + "). Use the download links in the list instead.";
    }
    zipBtn.disabled = false; if (mineBtn) mineBtn.disabled = false;
  }
  zipBtn.addEventListener("click", () => makeZip(zipBtn, false));
  if (mineBtn) mineBtn.addEventListener("click", () => makeZip(mineBtn, true));
})();

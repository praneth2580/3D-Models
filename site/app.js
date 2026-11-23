// Project page behaviour. The page sets window.PROJECT = {parts: [{file, name, qty, when}], default, options, slug}.
// Each part works without the others: menu, video tabs, gallery lightbox, 3D viewer, build picker.
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
  const api = { setVisible() {} };
  if (!P || !P.parts || !P.parts.length || !canvas) return api;
  const info = document.getElementById("stage-info");
  const dl = document.getElementById("stage-dl");
  const btns = document.getElementById("part-buttons");
  let visible = P.parts.map(() => true), current = -1, started = false;

  btns.innerHTML = P.parts.map((p, i) =>
    `<button class="part-btn" role="tab" data-i="${i}" aria-selected="false">${esc(p.name)}<small>${esc(p.file)} · qty ${esc(p.qty)}</small></button>`).join("");
  const buttons = [...btns.querySelectorAll(".part-btn")];

  let show = (i) => { current = i; buttons.forEach((b) => b.setAttribute("aria-selected", String(+b.dataset.i === i))); };
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

  show = function (i) {
    current = i;
    const part = P.parts[i];
    buttons.forEach((b) => b.setAttribute("aria-selected", String(+b.dataset.i === i)));
    dl.href = `files/${part.file}`;
    info.innerHTML = `<b>${esc(part.name)}</b> · loading…`;
    const my = ++token;
    const done = (geo) => {
      if (my !== token) return;
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
      info.innerHTML = `<b>${esc(part.name)}</b> · ${size.x.toFixed(0)} × ${size.y.toFixed(0)} × ${size.z.toFixed(0)} mm`;
    };
    if (cache[part.file]) return done(cache[part.file]);
    loader.load(`files/${part.file}`, (geo) => { geo.computeVertexNormals(); cache[part.file] = geo; done(geo); },
      undefined, () => { if (my === token) info.innerHTML = `<b>${esc(part.name)}</b> · couldn't load this file.`; });
  };

  btns.addEventListener("click", (e) => {
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

  const zipBtn = document.getElementById("b-zip"), status = document.getElementById("b-status");
  zipBtn.addEventListener("click", async () => {
    if (!window.JSZip) { status.textContent = "The zip tool couldn't load. Use the download links in the list instead."; return; }
    const files = [...new Set(rows.filter((r) => !r.dataset.view && fits(JSON.parse(r.dataset.when || "{}"))).map((r) => r.dataset.file))];
    const zip = new JSZip();
    const folder = zip.folder(P.slug + "-" + Object.values(state).join("-"));
    zipBtn.disabled = true;
    try {
      let k = 0;
      for (const f of files) {
        status.textContent = `Adding ${++k} of ${files.length}: ${f}`;
        const res = await fetch("files/" + f);
        if (!res.ok) throw new Error(f);
        folder.file(f, await res.blob());
      }
      folder.file("BUILD.txt", `${document.title}\nBuild: ${label()}\nParts: ${files.join(", ")}\n\nThe source, the guides and the full list are in the project's main .zip.\n`);
      status.textContent = "Packing…";
      const blob = await zip.generateAsync({ type: "blob" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob); a.download = folder.root.replace(/\/$/, "") + ".zip";
      document.body.appendChild(a); a.click(); a.remove();
      setTimeout(() => URL.revokeObjectURL(a.href), 4000);
      status.textContent = `Downloaded ${files.length} files.`;
    } catch (e) {
      status.textContent = "Couldn't make the zip (" + e.message + "). Use the download links in the list instead.";
    }
    zipBtn.disabled = false;
  });
})();

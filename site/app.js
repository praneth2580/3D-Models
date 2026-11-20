// Meteor Phone Dock website: parts table, download sizes and the 3D STL viewer.

const LICENSE = {
  name: "CC BY-NC-SA 4.0",
  url: "https://creativecommons.org/licenses/by-nc-sa/4.0/",
  short: "Licensed CC BY-NC-SA 4.0: share and remix it, credit the author, non-commercial.",
};

// [file stem, name, what it is, qty, material / notes, depends on (phone | bar | -), optional]
const PARTS = [
  ["case_shell", "Case shell", "Front of the slim case: the window lip, side walls and plug bay", "1", "ASA or PETG", "phone"],
  ["case_back", "Case back", "Back cover: O-ring tongue, cable channel, thermostat pocket", "1", "ASA or PETG", "phone"],
  ["window_template", "Window template", "Guide for cutting the 2 mm polycarbonate window", "1", "Any (PLA is fine)", "phone", true],
  ["shoe", "Shoe", "Plate on the case's back: dovetail rails, contact nose, lock strike", "1", "ASA or PETG", "-"],
  ["receiver", "Dock", "Rail channels, pogo-pin pocket, dock-board pocket, printed snap, lock pod", "1", "ASA or PETG, printed back face down", "-"],
  ["dock_lid", "Dock lid", "Closes the dock-board pocket", "1", "ASA or PETG", "-"],
  ["base_plate", "Base plate", "Joins the clamps to the dock through rubber grommets", "1", "ASA or PETG (or cut from base_plate.dxf)", "-"],
  ["clamp_body", "Clamp body", "Handlebar clamp, lower half", "2", "PETG, ASA or PA12, 100 % infill round the ring", "bar"],
  ["clamp_cap", "Clamp cap", "Handlebar clamp, upper half", "2", "PETG, ASA or PA12, 100 % infill round the ring", "bar"],
  ["bar_shim", "Bar shim", "Adapts the clamps to a smaller bar (or use strips of old inner tube)", "2", "TPU 95A", "bar", true],
  ["pad_spacer", "Pad spacer", "Raises the mount if the instrument cluster needs room", "as needed", "ASA or PETG", "-", true],
  ["lock_yoke", "Lock yoke", "Carries the steel bolt; driven by the lock's cam", "1", "PA12 best, or PETG", "-"],
  ["lock_cover", "Lock cover", "Closes the lock pod, with a drain slot", "1", "ASA or PETG", "-"],
  ["crank_template", "Crank template", "Drilling guide for the crank-pin hole in the lock's cam", "1", "Any", "-"],
  ["strike_keeper", "Steel keeper", "Optional steel strike; cut it from strike_keeper_2d.dxf (set steel_keeper = true)", "1", "6 mm steel plate", "-", true],
];
const DEPENDS = { phone: "Re-export for your phone", bar: "Depends on your bar size" };

let sizes = {};
const fmt = (b) => b > 1048576 ? (b / 1048576).toFixed(1) + " MB" : Math.max(1, Math.round(b / 1024)) + " KB";

function fillLicense() {
  const s = document.getElementById("license-short");
  if (s) s.textContent = LICENSE.short;
  const l = document.getElementById("license-long");
  if (l) l.innerHTML = `Licensed under <a href="${LICENSE.url}">${LICENSE.name}</a>.`;
}

function fillTable() {
  const tb = document.getElementById("parts-table");
  tb.innerHTML = PARTS.map(([stem, name, what, qty, mat, dep, opt]) => {
    const file = `${stem}.stl`;
    const size = sizes[file] ? ` <span class="opt">${fmt(sizes[file])}</span>` : "";
    const depNote = DEPENDS[dep] ? `<br><span class="opt">${DEPENDS[dep]}</span>` : "";
    return `<tr><td>${name}${opt ? ' <span class="opt">(optional)</span>' : ""}</td><td>${what}${depNote}</td><td>${qty}</td><td>${mat}</td>
      <td><a class="file" href="files/${file}" download>${file}</a>${size}</td></tr>`;
  }).join("");
  document.querySelectorAll("[data-size]").forEach((el) => {
    const b = sizes[el.dataset.size];
    if (b) el.textContent += ` · ${fmt(b)}`;
  });
}

async function loadSizes() {
  try {
    const r = await fetch("files/manifest.json");
    if (r.ok) sizes = await r.json();
  } catch (e) { /* sizes are optional */ }
  fillTable();
}

// ---------------------------------------------------------------- 3D viewer
function initViewer() {
  const canvas = document.getElementById("stl-canvas");
  const info = document.getElementById("stage-info");
  const dl = document.getElementById("stage-dl");
  const btns = document.getElementById("part-buttons");
  const viewerParts = PARTS;

  btns.innerHTML = viewerParts.map(([stem, name, , qty], i) =>
    `<button class="part-btn" role="tab" data-i="${i}" aria-selected="false">${name}<small>${stem}.stl · qty ${qty}</small></button>`).join("");

  if (!window.THREE || !THREE.STLLoader || !THREE.OrbitControls) {
    info.textContent = "The 3D viewer couldn't load (offline, or scripts blocked). The STL downloads below still work.";
    dl.style.display = "none";
    return;
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

  function show(i) {
    const [stem, name] = viewerParts[i];
    btns.querySelectorAll(".part-btn").forEach((b) => b.setAttribute("aria-selected", b.dataset.i == i));
    dl.href = `files/${stem}.stl`;
    info.innerHTML = `<b>${name}</b> · loading…`;
    const my = ++token;
    const done = (geo) => {
      if (my !== token) return;
      if (mesh) scene.remove(mesh);
      mesh = new THREE.Mesh(geo, material);
      scene.add(mesh);
      geo.computeBoundingBox();
      const bb = geo.boundingBox, size = new THREE.Vector3(); bb.getSize(size);
      const c = new THREE.Vector3(); bb.getCenter(c);
      mesh.position.sub(c);
      const r = size.length() / 2;
      const d = r / Math.sin(THREE.MathUtils.degToRad(camera.fov / 2)) * 1.05;
      camera.position.set(d * 0.55, -d * 0.65, d * 0.55);
      camera.up.set(0, 0, 1);
      camera.near = d / 100; camera.far = d * 10; camera.updateProjectionMatrix();
      controls.target.set(0, 0, 0); controls.update();
      info.innerHTML = `<b>${name}</b> · ${size.x.toFixed(0)} × ${size.y.toFixed(0)} × ${size.z.toFixed(0)} mm`;
    };
    if (cache[stem]) return done(cache[stem]);
    loader.load(`files/${stem}.stl`, (geo) => { geo.computeVertexNormals(); cache[stem] = geo; done(geo); },
      undefined, () => { if (my === token) info.innerHTML = `<b>${name}</b> · couldn't load this file.`; });
  }

  btns.addEventListener("click", (e) => {
    const b = e.target.closest(".part-btn");
    if (b) show(+b.dataset.i);
  });

  // Load the first part only when the viewer scrolls into view, so the page itself stays light.
  let started = false;
  const start = () => { if (started) return; started = true; resize(); show(viewerParts.findIndex((p) => p[0] === "receiver")); };
  if ("IntersectionObserver" in window) {
    new IntersectionObserver((es, o) => { if (es.some((e) => e.isIntersecting)) { start(); o.disconnect(); } }, { rootMargin: "200px" }).observe(canvas);
  } else start();

  (function loop() { requestAnimationFrame(loop); if (started) { controls.update(); renderer.render(scene, camera); } })();
}

fillLicense();
loadSizes();
initViewer();

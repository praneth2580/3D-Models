// 3D STL viewer for a project page. The page sets window.PROJECT = {parts: [{file, name, qty}], default}.
(function () {
  const P = window.PROJECT;
  const canvas = document.getElementById("stl-canvas");
  if (!P || !P.parts || !P.parts.length || !canvas) return;
  const info = document.getElementById("stage-info");
  const dl = document.getElementById("stage-dl");
  const btns = document.getElementById("part-buttons");
  const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

  btns.innerHTML = P.parts.map((p, i) =>
    `<button class="part-btn" role="tab" data-i="${i}" aria-selected="false">${esc(p.name)}<small>${esc(p.file)} · qty ${esc(p.qty)}</small></button>`).join("");

  if (!window.THREE || !THREE.STLLoader || !THREE.OrbitControls) {
    info.textContent = "The 3D viewer couldn't load (offline, or scripts blocked). The downloads below still work.";
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
    const part = P.parts[i];
    btns.querySelectorAll(".part-btn").forEach((b) => b.setAttribute("aria-selected", String(+b.dataset.i === i)));
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
  }

  btns.addEventListener("click", (e) => {
    const b = e.target.closest(".part-btn");
    if (b) show(+b.dataset.i);
  });

  // Load the first part only when the viewer comes into view, so the page itself stays light.
  let started = false;
  const first = Math.max(0, P.parts.findIndex((p) => p.file.replace(/\.stl$/i, "") === P.default));
  const start = () => { if (started) return; started = true; resize(); show(first); };
  if ("IntersectionObserver" in window) {
    new IntersectionObserver((es, o) => { if (es.some((e) => e.isIntersecting)) { start(); o.disconnect(); } }, { rootMargin: "200px" }).observe(canvas);
  } else start();

  (function loop() { requestAnimationFrame(loop); if (started) { controls.update(); renderer.render(scene, camera); } })();
})();

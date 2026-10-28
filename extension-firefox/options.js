const apiBrowser = globalThis.keroAPI || globalThis.chrome;
const DEFAULTS = { port: 9614, intercept: true, minSizeKB: 0, captureAllFiles: true, bubbleSize: "normal", bubbleScale: null };
const OLD_SIZES = { small: 85, normal: 100, large: 125 };

function saved() {
  const el = document.getElementById("saved");
  el.textContent = "Saved ✔";
  setTimeout(() => (el.textContent = ""), 1500);
}

async function init() {
  const opts = Object.assign({}, DEFAULTS, await apiBrowser.storage.local.get(DEFAULTS));
  const intercept = document.getElementById("intercept");
  const minSize = document.getElementById("minSize");
  const port = document.getElementById("port");
  const allFiles = document.getElementById("allFiles");
  allFiles.checked = opts.captureAllFiles;
  allFiles.addEventListener("change", () => apiBrowser.storage.local.set({ captureAllFiles: allFiles.checked }).then(saved));
  intercept.checked = opts.intercept;
  minSize.value = opts.minSizeKB;
  port.value = opts.port;
  const scale = document.getElementById("bubbleScale");
  const scaleText = document.getElementById("bubbleScaleText");
  const pct = opts.bubbleScale != null ? Math.round(opts.bubbleScale * 100) : OLD_SIZES[opts.bubbleSize] || 100;
  scale.value = String(pct);
  scaleText.textContent = `${pct}%`;
  scale.addEventListener("input", () => {
    scaleText.textContent = `${scale.value}%`;
    apiBrowser.storage.local.set({ bubbleScale: Number(scale.value) / 100 });
  });
  scale.addEventListener("change", saved);
  intercept.addEventListener("change", () => apiBrowser.storage.local.set({ intercept: intercept.checked }).then(saved));
  minSize.addEventListener("change", () =>
    apiBrowser.storage.local.set({ minSizeKB: Math.max(0, Number(minSize.value) || 0) }).then(saved)
  );
  port.addEventListener("change", () => {
    const p = Number(port.value);
    if (p >= 1024 && p <= 65535) apiBrowser.storage.local.set({ port: p }).then(saved);
  });
}

init();

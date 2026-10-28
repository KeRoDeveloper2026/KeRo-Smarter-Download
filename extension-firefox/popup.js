const apiBrowser = globalThis.keroAPI || globalThis.chrome;
function captionControls(item, container, fallback = []) {
  const tracks = item.yt?.subtitles?.length ? item.yt.subtitles : fallback;
  if (!tracks.length || /^(mp3|audio)$/.test(item.yt?.quality || "")) return () => ({});
  const label = document.createElement("label"), check = document.createElement("input"), language = document.createElement("select");
  check.type = "checkbox"; label.textContent = "Subtitles "; label.prepend(check);
  for (const track of tracks) { const option = document.createElement("option"); option.value = track.lang; option.textContent = track.lang; language.append(option); }
  label.append(language); container.append(label);
  return () => ({ downloadSubtitles: check.checked, subtitleLanguage: language.value, subtitleTracks: check.checked ? tracks : [] });
}
const fmtSize = (n) => {
  if (!n) return "";
  const u = ["B", "KB", "MB", "GB"];
  let i = 0;
  while (n >= 1024 && i < u.length - 1) {
    n /= 1024;
    i++;
  }
  return `${n.toFixed(i ? 1 : 0)} ${u[i]}`;
};

async function init() {
  document.getElementById("settings").addEventListener("click", () => {
    apiBrowser.runtime.openOptionsPage();
    window.close();
  });

  // the on / off switch: off = the browser keeps its downloads, no buttons
  // on videos, nothing is looked up (the add-in stays installed)
  const on = document.getElementById("enabled");
  const showOn = (v) => {
    on.checked = v;
    document.body.classList.toggle("off", !v);
    document.getElementById("onText").textContent = v ? "KeRo Smarter Download is on" : "KeRo Smarter Download is paused";
    document.getElementById("onHint").textContent = v
      ? "Downloads and videos of this browser go to KeRo Smarter Download"
      : "The browser keeps its downloads, no buttons on videos";
  };
  apiBrowser.storage.local.get({ enabled: true }, (o) => showOn(o.enabled !== false));
  on.addEventListener("change", () => {
    apiBrowser.storage.local.set({ enabled: on.checked });
    showOn(on.checked);
  });

  const look = document.getElementById("look");
  apiBrowser.storage.local.get({ bubbleStyle: "blue" }, (o) => (look.value = o.bubbleStyle || "blue"));
  look.addEventListener("change", () => apiBrowser.storage.local.set({ bubbleStyle: look.value }));

  // size of the "Download this video" button on pages (also in the settings page)
  const scale = document.getElementById("scale");
  const scaleText = document.getElementById("scaleText");
  const OLD = { small: 85, normal: 100, large: 125 };
  const show = (v) => {
    scale.value = String(v);
    scaleText.textContent = `${v}%`;
  };
  apiBrowser.storage.local.get({ bubbleScale: null, bubbleSize: "normal" }, (o) =>
    show(o.bubbleScale != null ? Math.round(o.bubbleScale * 100) : OLD[o.bubbleSize] || 100)
  );
  const save = (v) => {
    show(v);
    apiBrowser.storage.local.set({ bubbleScale: v / 100 });
  };
  scale.addEventListener("input", () => save(Number(scale.value)));
  document.getElementById("scaleReset").addEventListener("click", () => save(100));

  apiBrowser.runtime.sendMessage({ type: "swiftget-status" }, (res) => {
    const el = document.getElementById("status");
    const ok = res && res.ok;
    el.textContent = ok ? "connected" : "app not running";
    el.classList.toggle("on", !!ok);
    if (!ok) {
      // the program registers "kero-download:" when it is installed
      const open = document.createElement("a");
      open.href = "kero-download://open";
      open.className = "open";
      open.textContent = "Open KeRo Smarter Download";
      open.addEventListener("click", () => setTimeout(() => window.close(), 300));
      document.querySelector("section").appendChild(open);
    }
  });

  const [tab] = await apiBrowser.tabs.query({ active: true, currentWindow: true });
  if (!tab) return;
  apiBrowser.runtime.sendMessage({ type: "swiftget-get-media", tabId: tab.id }, (items) => {
    if (!items || !items.length) return;
    const box = document.getElementById("media");
    box.replaceChildren();
    const title = (tab.title || "video").replace(/[<>:"/\\|?*\u0000-\u001f]/g, "_").slice(0, 120);
    // a YouTube playlist: all of its videos in the app's playlist window
    if (/youtube\.com/i.test(tab.url || "") && /[?&]list=/.test(tab.url || "")) {
      const row = document.createElement("div");
      row.className = "media";
      const info = document.createElement("div");
      info.textContent = "All videos of this playlist";
      const btn = document.createElement("button");
      btn.className = "all";
      btn.textContent = "Download all";
      btn.addEventListener("click", () =>
        apiBrowser.runtime.sendMessage({ type: "swiftget-playlist", url: tab.url }, (res) => {
          btn.textContent = res && res.ok ? "Opened ✔" : "App not running";
        })
      );
      row.append(info, btn);
      box.appendChild(row);
    }
    items.forEach((m) => {
      const row = document.createElement("div");
      row.className = "media";
      const info = document.createElement("div");
      info.textContent = m.label;
      const small = document.createElement("small");
      small.textContent = m.sub || "";
      info.appendChild(small);
      const captions = captionControls(m, info, items.find((item) => item.yt?.subtitles?.length)?.yt.subtitles || []);
      const btn = document.createElement("button");
      btn.textContent = "Download";
      btn.disabled = !!m.disabled;
      btn.addEventListener("click", () => {
        if (m.resolve) {
          // a stream: its qualities come from the app, shown in its place
          btn.textContent = "…";
          btn.disabled = true;
          apiBrowser.runtime.sendMessage({ type: "swiftget-resolve-video", resolve: m.resolve }, (res) => {
            if (!res || res.error || !res.items) {
              btn.textContent = (res && res.error) || "App not running";
              return;
            }
            const rows = res.items.map((it) => {
              const r = document.createElement("div");
              r.className = "media";
              const inf = document.createElement("div");
              inf.textContent = it.label;
              const captions = captionControls(it, inf, res.items.find((item) => item.yt?.subtitles?.length)?.yt.subtitles || []);
              const go = document.createElement("button");
              go.textContent = "Download";
              go.addEventListener("click", () =>
                apiBrowser.runtime.sendMessage({ type: "swiftget-download", ...captions(), item: it, title: tab.title, referrer: tab.url, fileName: `${title}.${it.ext || "mp4"}` }, (r2) => {
                  go.textContent = r2 && r2.ok ? "Sent ✔" : "App not running";
                })
              );
              r.append(inf, go);
              return r;
            });
            row.replaceWith(...rows);
          });
          return;
        }
        apiBrowser.runtime.sendMessage(
          { type: "swiftget-download", ...captions(), item: m, title: tab.title, referrer: tab.url, fileName: `${title}.${m.ext || "mp4"}` },
          (res) => {
            btn.textContent = res && res.ok ? "Sent ✔" : "App not running";
          }
        );
      });
      row.append(info, btn);
      box.appendChild(row);
    });
  });
}

init();

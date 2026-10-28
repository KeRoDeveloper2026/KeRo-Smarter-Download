// Floating "Download this video" button, shown when the background worker
// detects a video/audio file or HLS stream on the page. Runs in every frame:
// videos inside frames (embedded players) and inside shadow DOM get their
// own button too.
(() => {
  const apiBrowser = globalThis.keroAPI || globalThis.chrome;
  if (window.__keroDownload) return;
  window.__keroDownload = true;
  const TOP = window.top === window;

  // Safely send fire-and-forget events across Chrome, Brave and Firefox.
  // Chromium callback-style sendMessage can return undefined (not a Promise).
  const sendQuietly = (message) => {
    try {
      const result = apiBrowser.runtime.sendMessage(message, () => {
        // Read lastError to acknowledge a disconnected/reloaded extension.
        void apiBrowser.runtime.lastError;
      });
      if (result && typeof result.catch === "function") result.catch(() => {});
    } catch (_) {
      // Content scripts can outlive the extension during reload/update.
    }
  };


  let items = [];
  // Options > File Types > "Download panel for web players"
  let panel = { enabled: true, skipSites: [] };
  const hostMatches = (host, p) => {
    p = String(p).replace(/^https?:\/\//i, "").split("/")[0].toLowerCase();
    if (!p) return false;
    if (p.includes("*")) return new RegExp("^" + p.replace(/[.]/g, "\\.").replace(/\*/g, ".*") + "$").test(host);
    return host === p || host.endsWith("." + p);
  };
  // the on / off switch of the add-in's window
  let switchedOn = true;
  const panelAllowed = () =>
    switchedOn && panel.enabled !== false && !(panel.skipSites || []).some((s) => hostMatches(location.hostname.toLowerCase(), s));

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
  const fmtLen = (s) => {
    s = Math.round(Number(s) || 0);
    if (!s) return "";
    const two = (n) => String(n).padStart(2, "0");
    return s >= 3600 ? `${Math.floor(s / 3600)}:${two(Math.floor(s / 60) % 60)}:${two(s % 60)}` : `${Math.floor(s / 60)}:${two(s % 60)}`;
  };
  // the resolution in plain words (the app sends it; streams seen in the
  // player only have the height)
  const tagOf = (h) => (!h ? "" : h >= 4320 ? "8K" : h >= 2160 ? "4K" : h >= 1440 ? "2K" : h >= 1080 ? "Full HD" : h >= 720 ? "HD" : "SD");

  const cleanTitle = () =>
    (document.title || "video").replace(/[<>:"/\\|?*\u0000-\u001f]/g, "_").trim().slice(0, 120) || "video";

  // --------------------------------------------------------------- videos
  // Videos of the page, also those inside shadow DOM (players built as web
  // components). The deep search is slower, so it runs every few rounds.
  const shadowVideos = new Set();
  let videoCache = [], videosDirty = true;
  const rootObservers = new Map();
  const addedRoots = new Set();
  let discoveryTimer = 0;
  let frame = 0;
  function schedulePlace() {
    if (document.hidden || frame) return;
    frame = requestAnimationFrame(() => { frame = 0; place(); });
  }
  function discover(root, depth = 0) {
    if (depth > 6 || !root.querySelectorAll) return;
    if (root.matches?.("video")) shadowVideos.add(root);
    for (const v of root.querySelectorAll("video")) shadowVideos.add(v);
    // Shadow discovery runs only for new subtrees, never in a polling loop.
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT);
    let node = root;
    do {
      if (node.shadowRoot && !rootObservers.has(node.shadowRoot) && rootObservers.size < 64) {
        observeRoot(node.shadowRoot);
        discover(node.shadowRoot, depth + 1);
      }
    } while ((node = walker.nextNode()));
    discoverFiles(root);
    const embedded = root.querySelectorAll("embed[src], object[data], iframe[src]");
    const pdfs = [];
    for (const node of embedded) {
      const url = node.src || node.data || "";
      if (/^https?:/i.test(url) && (/\.pdf(?:[?#]|$)/i.test(url) || /pdf/i.test(node.type || ""))) pdfs.push({ url, ext: "pdf", label: "PDF document" });
    }
    if (pdfs.length) sendQuietly({ type: "swiftget-files-found", items: pdfs.slice(0, 24) });
  }
  // Offer any file-like URL, excluding server-side page routes. A download
  // attribute or a response attachment can identify extensionless files too.
  const FILE_LINK = { test(value) {
    try {
      const path = new URL(value, location.href).pathname;
      return /\.[a-z0-9]{1,16}$/i.test(path) && !/\.(?:html?|aspx?|php\d?|jsp)$/i.test(path);
    } catch { return false; }
  } };
  const foundFiles = new Set();
  function discoverFiles(root) {
    if (!TOP || !switchedOn) return;
    const links = [];
    const add = (node) => {
      if (links.length >= 24 || foundFiles.size >= 256) return;
      const url = node.href;
      if (!/^https?:/i.test(url || "") || (!node.hasAttribute("download") && !FILE_LINK.test(url)) || foundFiles.has(url)) return;
      foundFiles.add(url);
      links.push({ url, ext: (url.split(/[?#]/)[0].split(".").pop() || "file").toLowerCase().slice(0, 12),
        label: (node.getAttribute("download") || node.textContent || "File").trim().slice(0, 120) });
    };
    if (root.matches?.("a[href]")) add(root);
    for (const node of root.querySelectorAll("a[href]")) { add(node); if (links.length >= 24) break; }
    if (links.length) sendQuietly({ type: "swiftget-files-found", items: links });
  }
  function observeRoot(root) {
    if (rootObservers.has(root)) return;
    const observer = new MutationObserver((records) => {
      for (const record of records) {
        videosDirty = true;
        if (record.type === "attributes") {
          if (/^(VIDEO|SOURCE|AUDIO)$/.test(record.target.tagName)) schedulePlace();
          else if (record.target.tagName === "A") addedRoots.add(record.target);
        }
        for (const node of record.addedNodes || []) {
          if (node.nodeType === 1 && !node.hasAttribute("data-kero-panel") && addedRoots.size < 64) addedRoots.add(node);
        }
      }
      if (!discoveryTimer) discoveryTimer = setTimeout(() => {
        discoveryTimer = 0;
        for (const node of addedRoots) if (node.isConnected) discover(node);
        addedRoots.clear();
        for (const [sr, ob] of rootObservers) if (sr.host && !sr.host.isConnected) { ob.disconnect(); rootObservers.delete(sr); }
        for (const video of shadowVideos) if (!video.isConnected) shadowVideos.delete(video);
        schedulePlace();
        if (!document.hidden) watchVideos();
      }, 100);
    });
    observer.observe(root, { childList: true, subtree: true, attributes: true, attributeFilter: ["src", "href"] });
    rootObservers.set(root, observer);
  }
  function allVideos() {
    if (videosDirty) {
      const list = new Set(document.querySelectorAll("video"));
      for (const video of shadowVideos) {
        if (video.isConnected) list.add(video); else shadowVideos.delete(video);
      }
      videoCache = [...list];
      videosDirty = false;
    }
    return videoCache;
  }

  // The video the user is watching: a playing one first, else the biggest
  // one on screen.
  function biggestVideo() {
    let best = null;
    let score = 0;
    for (const v of allVideos()) {
      const r = v.getBoundingClientRect();
      if (r.width < 200 || r.height < 100) continue;
      const visible = Math.max(0, Math.min(r.bottom, innerHeight) - Math.max(r.top, 0));
      if (visible < 60) continue;
      const s = r.width * visible * (!v.paused && !v.ended ? 4 : 1);
      if (s > score) {
        best = v;
        score = s;
      }
    }
    return best;
  }
  const playing = (v) => !v.paused && !v.ended && v.duration > 3;

  // Pages that are one video: their own address is the best link for it.
  const VIDEO_PAGE = [
    /youtube\.com\/(watch|shorts\/|live\/|embed\/)/i,
    /youtube-nocookie\.com\/embed\//i,
    /tiktok\.com\/@[^/]+\/(video|photo)\//i,
    /instagram\.com\/(reels?|p|tv)\//i,
    /facebook\.com\/(.+\/videos\/|watch|reels?\/|stories\/|share\/[vr]\/|plugins\/video)/i,
    /fb\.watch\//i,
    /(twitter|x)\.com\/[^/]+\/status\//i,
    /vimeo\.com\/\d+/i,
    /player\.vimeo\.com\/video\//i,
    // (not the "geo.dailymotion.com/player/…" frame: that is only the player)
    /dailymotion\.com\/(video\/|embed\/video\/)/i,
    /dai\.ly\//i,
    /reddit\.com\/r\/[^/]+\/comments\//i,
    /twitch\.tv\/(videos\/|[^/]+\/clip\/)/i,
    /clips\.twitch\.tv\//i,
    /pinterest\.[a-z.]+\/pin\//i,
    /snapchat\.com\/(spotlight|add)\//i,
    /linkedin\.com\/(posts|feed\/update)\//i,
  ];
  const isVideoPage = (u) => VIDEO_PAGE.some((r) => r.test(u));

  // In feeds (Facebook, Instagram, X...) the page shows many videos: look for
  // the post / reel link around the video being watched.
  function linkFor(video) {
    if (isVideoPage(location.href)) return location.href;
    return ownLink(video) || location.href;
  }

  // the post / video link next to this very video ("" = none found)
  function ownLink(video) {
    let el = video;
    for (let depth = 0; el && depth < 8; depth++) {
      if (el === document.body || el === document.documentElement) break;
      const links = el.querySelectorAll ? el.querySelectorAll("a[href]") : [];
      for (const a of links) {
        if (isVideoPage(a.href)) return a.href.split("#")[0];
      }
      if (el.tagName === "ARTICLE") break;
      // out of a shadow root: on to the element that holds it
      el = el.parentElement || (el.parentNode && el.parentNode.host) || null;
    }
    // an embedded player: the frame's own address is the video
    if (!TOP && isVideoPage(location.href)) return location.href;
    return "";
  }

  let lastPage = "";
  function watchVideos() {
    const v = biggestVideo();
    if (!v) return;
    // ignore tiny muted background loops that never play for long
    if (v.paused && !(v.duration > 3) && !v.currentSrc) return;
    // in a frame (an embedded player): its own address when it is a video
    // page (YouTube / Vimeo embeds), otherwise the page around it (the
    // add-in knows that one)
    const page = TOP ? linkFor(v) : isVideoPage(location.href) ? location.href : "";
    if (page !== lastPage || (!TOP && !lastPage)) {
      if (!TOP && lastPage === "frame:" + page) return;
      lastPage = TOP ? page : "frame:" + page;
      sendQuietly({ type: "swiftget-video-seen", page, src: directSrc(v), frame: !TOP });
    }
  }

  // ---------------------------------------------------------------- bubbles
  // One "Download" bubble on every video of the page. The main video (the
  // one playing / the biggest) uses what the add-in found for the page; any
  // other video is looked up when its bubble is clicked. A bubble can be
  // dragged anywhere on its video and stays there.
  const dismissedVideos = new WeakSet();
  const bubbles = new Map(); // video -> bubble
  function removeAll() {
    for (const b of bubbles.values()) b.dispose();
    bubbles.clear();
  }
  // size of the button: the slider in the add-in's menu (50% - 200%)
  const OLD_SIZES = { small: 0.85, normal: 1, large: 1.25 };
  // its look: the add-in's menu > "Button style"
  const STYLES = ["blue", "dark", "light", "green", "icon"];
  let look = "blue";
  const applyLook = () => {
    for (const b of bubbles.values()) {
      const w = b.root.querySelector(".wrap");
      if (w) w.className = "wrap " + look;
      placeOne(b);
    }
  };
  const clampZoom = (z) => Math.min(2, Math.max(0.5, Number(z) || 1));
  let zoom = 1;
  const applyZoom = () => {
    for (const b of bubbles.values()) {
      b.host.style.setProperty("--z", String(zoom));
      placeOne(b);
    }
  };
  try {
    apiBrowser.storage.local.get({ enabled: true }, (o) => {
      switchedOn = !o || o.enabled !== false;
      if (!switchedOn) removeAll();
    });
    apiBrowser.storage.onChanged.addListener((ch) => {
      if (!ch.enabled) return;
      switchedOn = ch.enabled.newValue !== false;
      if (!switchedOn) removeAll();
      else apiBrowser.runtime.sendMessage({ type: "swiftget-media-request" }, (res) => !apiBrowser.runtime.lastError && update(res));
    });
  } catch (_) {
    // storage not reachable (add-in reloading): stays on
  }
  try {
    apiBrowser.storage.local.get({ bubbleScale: null, bubbleSize: "normal", bubbleStyle: "blue" }, (o) => {
      zoom = clampZoom(o && o.bubbleScale != null ? o.bubbleScale : OLD_SIZES[o && o.bubbleSize]);
      look = STYLES.includes(o && o.bubbleStyle) ? o.bubbleStyle : "blue";
      applyZoom();
      applyLook();
    });
    apiBrowser.storage.onChanged.addListener((ch) => {
      if (ch.bubbleStyle) {
        look = STYLES.includes(ch.bubbleStyle.newValue) ? ch.bubbleStyle.newValue : "blue";
        applyLook();
        return;
      }
      if (ch.bubbleScale) zoom = clampZoom(ch.bubbleScale.newValue);
      else if (ch.bubbleSize) zoom = clampZoom(OLD_SIZES[ch.bubbleSize.newValue]);
      else return;
      applyZoom();
    });
  } catch (_) {
    // storage not reachable (add-in reloading): default size
  }
  const STYLE = `
    :host { all: initial; }
    .wrap { font: 12px/1.35 "Segoe UI", system-ui, sans-serif; color: #eaf4ff; display: inline-block; zoom: var(--z, 1); }
    .btn { display: inline-flex; align-items: stretch; color: #fff; border: 1px solid #19c9ec;
           background: linear-gradient(135deg, #102f53, #061427); border-radius: 11px;
           box-shadow: 0 1px 6px rgba(0,0,0,.35); font: inherit; font-weight: 600;
           opacity: .96; transition: opacity .15s; user-select: none; white-space: nowrap; }
    .btn:hover, .btn.open { opacity: 1; }
    .btn.drag { opacity: 1; }
    .part { display: inline-flex; align-items: center; gap: 7px; padding: 7px 10px; cursor: grab; }
    .part:hover { background: rgba(255,255,255,.12); }
    .btn.drag .part { cursor: grabbing; }
    .side { padding: 6px 8px; cursor: pointer; border-left: 1px solid rgba(255,255,255,.28); display: inline-flex; align-items: center; }
    .side:hover { background: rgba(255,255,255,.18); }
    #label { color: #80efff; }
    .ico { width: 19px; height: 19px; flex: none; }
    .caret { font-size: 9px; opacity: .9; }
    .spin { width: 9px; height: 9px; border: 2px solid rgba(255,255,255,.4); border-top-color: #fff; border-radius: 50%;
            animation: r .8s linear infinite; flex: none; }
    @keyframes r { to { transform: rotate(360deg); } }
    .list { width: min(350px, calc(100vw - 16px)); margin-top: 4px; background: #0b1f3a; border-radius: 6px; box-shadow: 0 6px 22px rgba(0,0,0,.28);
            overflow: hidden; max-height: 360px; overflow-y: auto; border: 1px solid #1d4580; }
    .head { padding: 7px 10px; background: #10305c; border-bottom: 1px solid #16396b; font-weight: 600; color: #cfe6ff;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .item { padding: 6px 10px; cursor: pointer; border-bottom: 1px solid #16396b; display: flex; gap: 6px; }
    .item:last-child { border-bottom: 0; }
    .item:hover { background: #12427f; }
    .num { color: #8fb0d6; min-width: 16px; text-align: right; }
    .body { flex: 1; min-width: 0; }
    .t { font-weight: 600; display: flex; align-items: center; gap: 5px; flex-wrap: wrap; }
    .s { color: #8fb0d6; font-size: 10.5px; overflow-wrap: anywhere; }
    .tag { font-size: 9.5px; font-weight: 700; padding: 0 4px; border-radius: 3px; color: #fff; background: #7b8794; line-height: 14px; }
    .tag.HD { background: #1d8f5a; } .tag.FullHD { background: #1d63d6; } .tag.K2 { background: #7b3fd6; }
    .tag.K4 { background: #d6631d; } .tag.K8 { background: #c0262d; }
    .codec { font-size: 9.5px; color: #9cc3ee; border: 1px solid #2a4a7a; border-radius: 3px; padding: 0 3px; line-height: 13px; }
    .all { font-weight: 700; color: #f5b83d; }
    .msg { padding: 8px 10px; color: #3fcf7a; }
    .help { padding: 8px 10px; color: #ffe9a8; background: #2a2410; border-bottom: 1px solid #5a4a14; }
    .act { margin-top: 6px; display: inline-block; background: #1560d6; color: #fff; border-radius: 4px; padding: 3px 9px; cursor: pointer; }
    .act:hover { background: #1a56b8; }
    .off { cursor: default; opacity: .7; }
    .off:hover { background: #0b1f3a; }
    .err { color: #ff6b62; }
    /* looks */
    .dark .btn { background: linear-gradient(#3a3f47, #23272e); border-color: #15181c; }
    .dark .btn:hover, .dark .btn.open { background: linear-gradient(#454b55, #2a2f37); }
    .dark .ico path { fill: #23272e; }
    .light .btn { background: linear-gradient(#ffffff, #e9eef5); border-color: #b8c3d1; color: #1f2733; }
    .light .btn:hover, .light .btn.open { background: linear-gradient(#ffffff, #dfe7f1); }
    .light .ico circle { fill: #1d63d6; }
    .light .ico path { fill: #fff; }
    .light .side { border-left-color: #c9d3df; }
    .light .spin { border-color: rgba(29,99,214,.3); border-top-color: #1d63d6; }
    .green .btn { background: linear-gradient(#35b36b, #1f8a4c); border-color: #176b3a; }
    .green .btn:hover, .green .btn.open { background: linear-gradient(#3cc276, #1d8048); }
    .green .ico path { fill: #1f8a4c; }
    .icon .btn { border-radius: 50%; }
    .icon .part { padding: 5px; }
    .icon #label, .icon .caret, .icon .side { display: none; }
    .icon .ico { width: 16px; height: 16px; }`;

  function isMain(video) {
    return TOP && video === biggestVideo();
  }

  function directSrc(video) {
    const src = video.currentSrc || video.src || video.querySelector("source[src]")?.src || "";
    return /^https?:/i.test(src) && !/\.m3u8|\.mpd/i.test(src) ? src : "";
  }

  // where the bubbles live: in full screen the player's own element (the
  // only thing the browser shows then)
  function layer() {
    const f = document.fullscreenElement || document.webkitFullscreenElement;
    return f && f.tagName !== "VIDEO" ? f : document.documentElement;
  }

  const el = (tag, props = {}, ...kids) => {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(props)) {
      if (k === "text") e.textContent = v;
      else e.setAttribute(k, v);
    }
    e.append(...kids);
    return e;
  };

  function makeBubble(video) {
    const host = document.createElement("div");
    host.setAttribute("data-kero-panel", "");
    host.style.all = "initial";
    host.style.position = "fixed";
    host.style.zIndex = "2147483647";
    host.style.setProperty("--z", String(zoom));
    const root = host.attachShadow({ mode: "closed" });
    const svgNs = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(svgNs, "svg");
    svg.setAttribute("class", "ico");
    svg.setAttribute("viewBox", "0 0 16 16");
    const circle = document.createElementNS(svgNs, "circle");
    for (const [k, v] of [["cx", "8"], ["cy", "8"], ["r", "7"], ["fill", "#082840"], ["stroke", "#24def6"]]) circle.setAttribute(k, v);
    const arrow = document.createElementNS(svgNs, "path");
    arrow.setAttribute("d", "M4 3.5h2V7l3-3.5h2.5L7.8 8l4.2 4.5H9.5L6 8.7v3.8H4z");
    arrow.setAttribute("fill", "#54eaff");
    svg.append(circle, arrow);
    const list = el("div", { class: "list", id: "list" });
    list.hidden = true;
    const spin = el("span", { class: "spin", id: "spin" });
    spin.hidden = true;
    root.append(
      el("style", { text: STYLE }),
      el(
        "div",
        { class: "wrap " + look },
        el(
          "div",
          { class: "btn", id: "main" },
          el("span", { class: "part", id: "grab" }, svg, spin, el("span", { id: "label", text: "Download" }), el("span", { class: "caret", text: "▼" })),
          el("span", { class: "side", id: "help", title: "Help", text: "?" }),
          el("span", { class: "side", id: "close", title: "Hide", text: "✕" })
        ),
        list
      )
    );
    const events = new AbortController();
    const b = { host, root, video, open: false, own: null, loading: false, dx: null, dy: null, help: false,
      disposed: false, waitTimer: 0, flashTimer: 0,
      dispose() { this.disposed = true; events.abort(); clearInterval(this.waitTimer); clearTimeout(this.flashTimer); this.own = null; this.host.remove(); } };
    const grab = root.getElementById("grab");
    // drag: move it anywhere on the video; a short press is a click
    let down = null;
    grab.addEventListener("mousedown", (e) => {
      if (e.button !== 0) return;
      const hr = host.getBoundingClientRect();
      down = { x: e.clientX, y: e.clientY, ox: e.clientX - hr.left, oy: e.clientY - hr.top, moved: false };
      e.preventDefault();
    });
    addEventListener("mousemove", (e) => {
      if (!down) return;
      if (!down.moved && Math.abs(e.clientX - down.x) + Math.abs(e.clientY - down.y) < 5) return;
      down.moved = true;
      root.getElementById("main").classList.add("drag");
      const r = video.getBoundingClientRect();
      b.dx = e.clientX - down.ox - r.left;
      b.dy = e.clientY - down.oy - r.top;
      placeOne(b);
    }, { signal: events.signal });
    addEventListener("mouseup", () => {
      if (!down) return;
      const wasDrag = down.moved;
      down = null;
      root.getElementById("main").classList.remove("drag");
      if (!wasDrag) clicked(b);
    }, { signal: events.signal });
    root.getElementById("help").addEventListener("click", () => {
      b.help = !b.help;
      b.open = true;
      renderOne(b);
    });
    root.getElementById("close").addEventListener("click", () => {
      dismissedVideos.add(video);
      b.dispose();
      bubbles.delete(video);
    });
    layer().appendChild(host);
    bubbles.set(video, b);
    renderOne(b);
    placeOne(b);
    return b;
  }

  function itemsOf(b) {
    const whatsapp = /(^|\.)web\.whatsapp\.com$/i.test(location.hostname);
    // WhatsApp serves preview JPEGs and encrypted attachment fragments. Neither
    // is the video the user is watching. Prefer the actual HTMLMediaElement.
    const blob = b.video.currentSrc || b.video.src || "";
    if (whatsapp && /^blob:/i.test(blob)) {
      return [{ label: "WhatsApp status · original video", blob, ext: "mp4", sub: "Save video from the player to KeRo" }];
    }
    if (b.own && !whatsapp) return b.own;
    const known = isMain(b.video) ? items : [];
    if (whatsapp) {
      const direct = directSrc(b.video);
      if (/^https?:/i.test(direct) && /\.(?:mp4|webm|mov)(?:[?#]|$)/i.test(direct))
        return [{ label: "WhatsApp status · video", url: direct, ext: (direct.match(/\.(mp4|webm|mov)(?:[?#]|$)/i) || [,'mp4'])[1].toLowerCase(), sub: "Video source" }];
      return [{ label: "Video source unavailable", disabled: true, sub: "Open and play the status to expose its media source" }];
    }
    if (known.some((item) => !item.disabled)) return known;
    const src = directSrc(b.video);
    return src ? [{ label: "Direct video file", url: src, ext: (/\.(\w{2,4})(?:[?#]|$)/.exec(src) || [])[1] || "mp4", sub: "Ready to download" }] : known;
  }

  function lookUp(b, stream) {
    // another video on the page (or nothing found for it yet): look it up now
    if (b.loading || b.disposed) return;
    b.loading = true;
    b.open = true;
    renderOne(b, "Looking for the video qualities…");
    apiBrowser.runtime.sendMessage(
      // its own post / video link, or its own file; the page only when
      // neither is there
      {
        type: "swiftget-resolve-video",
        resolve: stream || "",
        // in a frame that is only a player: the add-in uses the page around it
        page: ownLink(b.video) || (directSrc(b.video) || !TOP ? "" : location.href),
        src: directSrc(b.video),
        frame: !TOP,
      },
      (res) => {
        const failed = apiBrowser.runtime.lastError;
        if (b.disposed) return;
        b.loading = false;
        if (failed || !res) return notRunning(b, () => lookUp(b, stream));
        if (res.error) {
          if (/not running/i.test(res.error)) return notRunning(b, () => lookUp(b, stream));
          return renderOne(b, res.error, true);
        }
        b.own = res.items || [];
        renderOne(b);
      }
    );
  }

  function clicked(b) {
    const list = itemsOf(b);
    if (!list.some((item) => !item.disabled) && !b.loading) return lookUp(b);
    b.help = false;
    b.open = !b.open;
    renderOne(b);
  }

  // The app is closed: offer to open it, then do what the user wanted.
  function notRunning(b, retry) {
    b.open = true;
    renderOne(b, "KeRo Smarter Download is not running.", true, {
      text: "Open KeRo Smarter Download",
      run: () => {
        // the program registers "kero-download:" when it is installed
        const a = document.createElement("a");
        a.href = "kero-download://open";
        a.style.display = "none";
        document.documentElement.appendChild(a);
        a.click();
        a.remove();
        renderOne(b, "Opening KeRo Smarter Download…");
        let tries = 0;
        clearInterval(b.waitTimer);
        const wait = b.waitTimer = setInterval(() => {
          tries++;
          apiBrowser.runtime.sendMessage({ type: "swiftget-status" }, (res) => {
            if (apiBrowser.runtime.lastError) {
              if (tries >= 25) clearInterval(wait);
              return;
            }
            if (res && res.ok) {
              clearInterval(wait);
              retry();
            } else if (tries >= 25) {
              clearInterval(wait);
              renderOne(b, "KeRo Smarter Download did not start. Open it from the Start menu and try again.", true);
            }
          });
        }, 1000);
      },
    });
  }

  function heightOf(q) {
    const m = /^(\d{3,4})p/.exec(q || "");
    return m ? Number(m[1]) : 0;
  }

  // One line of the menu, in plain words: "MP4 file · 1080p [Full HD] AV1",
  // under it "12:34 · 2,500 kbps · 245 MB".
  function describe(m) {
    const y = m.yt;
    if (!y) return { main: m.label, tag: "", codec: "", sub: m.sub || "" };
    const audio = y.quality === "audio" || y.quality === "mp3" || /^audio\|/.test(y.key || "");
    const ext = (y.ext || "mp4").toUpperCase();
    const q = audio ? "" : y.quality || "";
    const tag = audio ? "" : y.tag || tagOf(heightOf(q));
    const codec = audio ? "" : y.codec || (/\bAV1\b/.test(m.label || "") ? "AV1" : "");
    const kbps = y.kbps || (y.size && y.duration ? Math.round((y.size * 8) / y.duration / 1000) : 0);
    const sub = [
      fmtLen(y.duration),
      kbps ? `${kbps.toLocaleString("en")} kbps` : "",
      y.size ? (y.quality === "mp3" ? "about " : "") + fmtSize(y.size) : "",
      y.quality === "mp3" ? "made into MP3 after the download" : "",
    ]
      .filter(Boolean)
      .join(" · ");
    const kind = audio ? `${ext} audio` : `${ext} file`;
    return { main: q ? `${q} ${ext}` : kind, tag, codec, sub };
  }

  // "Download all": the whole playlist (YouTube list), or every file found
  function downloadAllOf(b, usable) {
    if (TOP && /youtube\.com/i.test(location.hostname) && /[?&]list=/.test(location.search)) {
      return { text: "Download all videos of this playlist", run: () => sendPlaylist(b) };
    }
    const files = usable.filter((m) => !m.yt && m.url);
    if (files.length >= 2) {
      return {
        text: `Download all (${files.length} files)`,
        run: () => files.forEach((m, i) => setTimeout(() => download(b, m), i * 300)),
      };
    }
    return null;
  }

  function sendPlaylist(b) {
    apiBrowser.runtime.sendMessage({ type: "swiftget-playlist", url: location.href }, (res) => {
      if (apiBrowser.runtime.lastError || !res || !res.ok) return notRunning(b, () => sendPlaylist(b));
      flashOne(b, "The playlist is open in KeRo Smarter Download ✔", false);
    });
  }

  function renderOne(b, note, isError, action) {
    const list = itemsOf(b);
    const usable = list.filter((i) => !i.disabled);
    const busy = b.loading || (!usable.length && list.some((i) => i.disabled && /Getting/.test(i.label)));
    b.root.getElementById("label").textContent = usable.length > 1 ? `Download · ${usable.length}` : busy ? "Finding media…" : "Download";
    b.root.getElementById("spin").hidden = !busy;
    b.root.querySelector("svg").style.display = busy ? "none" : "";
    b.root.getElementById("main").classList.toggle("open", b.open);
    const box = b.root.getElementById("list");
    box.hidden = !b.open;
    box.replaceChildren();
    // Do not allocate quality rows/listeners until the user opens the menu.
    if (!b.open || b.disposed) return;
    const tracks = usable.find((item) => item.yt?.subtitles?.length)?.yt.subtitles || [];
    if (tracks.length) {
      const check = el("input", { type: "checkbox" }); check.checked = !!b.withSubtitles;
      check.addEventListener("change", () => { b.withSubtitles = check.checked; });
      const languages = el("select", { title: "Subtitle language" });
      for (const track of tracks) languages.append(el("option", { value: track.lang, text: track.lang }));
      b.subtitleLanguage ||= tracks[0].lang; languages.value = b.subtitleLanguage;
      languages.addEventListener("change", () => { b.subtitleLanguage = languages.value; });
      box.append(el("label", { class: "item" }, check, el("span", { text: "Subtitles with video" }), languages));
    }
    if (b.help) {
      box.appendChild(
        el("div", {
          class: "help",
          text: "Click the button to choose a quality. Drag it to move it on the video. ✕ hides it for this video. Its size can be changed in the KeRo Smarter Download add-in menu.",
        })
      );
    }
    if (note) {
      const d = el("div", { class: "msg" + (isError ? " err" : ""), text: note });
      if (action) {
        const a = el("div", { class: "act", text: action.text });
        a.addEventListener("click", action.run);
        d.append(el("br"), a);
      }
      box.appendChild(d);
      return;
    }
    if (!list.length) {
      box.appendChild(el("div", { class: "msg", text: "Looking for the video qualities…" }));
      return;
    }
    const title = (list.find((m) => m.yt && m.yt.title) || {}).yt;
    box.appendChild(el("div", { class: "head", title: (title && title.title) || cleanTitle(), text: (title && title.title) || cleanTitle() }));
    const all = downloadAllOf(b, usable);
    if (all) {
      const row = el("div", { class: "item" }, el("span", { class: "num", text: "⇊" }), el("div", { class: "body" }, el("div", { class: "t all", text: all.text })));
      row.addEventListener("click", all.run);
      box.appendChild(row);
    }
    let n = 0;
    list.forEach((m) => {
      const d = describe(m);
      const t = el("div", { class: "t" }, el("span", { text: d.main }));
      if (d.tag) t.append(el("span", { class: "tag " + d.tag.replace(/\s/g, "").replace(/^(\d)K$/, "K$1"), text: d.tag }));
      if (d.codec) t.append(el("span", { class: "codec", text: d.codec }));
      const sub = d.sub.length > 110 ? d.sub.slice(0, 110) + "…" : d.sub;
      const row = el(
        "div",
        { class: "item" + (m.disabled ? " off" : "") },
        el("span", { class: "num", text: m.disabled ? "" : `${++n}.` }),
        el("div", { class: "body" }, t, el("div", { class: "s", text: sub }))
      );
      if (!m.disabled) row.addEventListener("click", () => download(b, m));
      box.appendChild(row);
    });
  }

  function placeOne(b) {
    const fs = document.fullscreenElement || document.webkitFullscreenElement;
    const r = b.video.getBoundingClientRect();
    const onScreen =
      r.bottom > 0 && r.top < innerHeight && r.width >= 200 && r.height >= 100 && b.video.isConnected &&
      !(fs && fs.tagName === "VIDEO") && (!fs || fs.contains(b.video) || fs.shadowRoot);
    b.host.style.display = onScreen ? "block" : "none";
    if (!onScreen) return;
    if (b.host.parentNode !== layer()) layer().appendChild(b.host);
    // its real size (the user can make the button smaller or bigger)
    const w = b.host.getBoundingClientRect().width || 170;
    const h = b.root.getElementById("main").getBoundingClientRect().height || 22;
    let x = b.dx == null ? r.right - w - 8 : r.left + b.dx;
    let y = b.dy == null ? r.top + 8 : r.top + b.dy;
    x = Math.max(r.left, Math.min(x, r.right - 60));
    y = Math.max(r.top, Math.min(y, r.bottom - h));
    b.host.style.left = `${Math.max(4, Math.min(x, innerWidth - w))}px`;
    b.host.style.top = `${Math.max(4, Math.min(y, innerHeight - h - 4))}px`;
  }

  function place() {
    if (document.hidden || !panelAllowed()) return;
    const vids = allVideos().filter((v) => {
      const r = v.getBoundingClientRect();
      return r.width >= 200 && r.height >= 100 && r.bottom > 0 && r.top < innerHeight;
    });
    // bubbles of videos that went away
    for (const [v, b] of bubbles) {
      if (!v.isConnected || !vids.slice(0, 4).includes(v)) {
        b.dispose();
        bubbles.delete(v);
      }
    }
    // the main video once the add-in found media or it plays (then it shows
    // "looking for qualities"), any other one as soon as it is a real player
    for (const v of vids.slice(0, 4)) {
      if (dismissedVideos.has(v)) continue;
      let b = bubbles.get(v);
      if (!b) {
        const show = isMain(v) ? items.length || playing(v) : !(v.paused && !(v.duration > 3) && !directSrc(v));
        if (!show) continue;
        b = makeBubble(v);
      }
      if (!b.dismissed) placeOne(b);
    }
  }

  function flashOne(b, text, isError) {
    b.open = true;
    renderOne(b, text, isError);
    clearTimeout(b.flashTimer);
    b.flashTimer = setTimeout(() => {
      if (b.disposed) return;
      b.open = false;
      renderOne(b);
    }, 2500);
  }

  function download(b, m) {
    if (m.blob) return importBlob(b, m);
    // a stream whose qualities are not known yet: ask the app for them
    if (m.resolve) return lookUp(b, m.resolve);
    const fileName = `${cleanTitle()}.${m.ext || "mp4"}`;
    apiBrowser.runtime.sendMessage(
      { type: "swiftget-download", item: m, title: document.title, fileName, referrer: location.href,
        downloadSubtitles: !!b.withSubtitles, subtitleLanguage: b.subtitleLanguage,
        subtitleTracks: b.withSubtitles ? itemsOf(b).find((item) => item.yt?.subtitles?.length)?.yt.subtitles : [] },
      (res) => {
        if (apiBrowser.runtime.lastError || !res || !res.ok) notRunning(b, () => download(b, m));
        else flashOne(b, "Sent to KeRo Smarter Download ✔", false);
      }
    );
  }

  async function importBlob(b, item) {
    if (b.loading) return;
    b.loading = true; b.open = true;
    renderOne(b, "Saving the opened status…");
    const request = (msg) => new Promise((resolve, reject) => apiBrowser.runtime.sendMessage(msg, (res) => {
      const error = apiBrowser.runtime.lastError;
      if (error || !res?.ok) reject(new Error(error?.message || res?.error || "Could not save this media")); else resolve(res);
    }));
    let id;
    try {
      const response = await fetch(item.blob);
      const size = Number(response.headers.get("content-length"));
      const mime = response.headers.get("content-type") || "";
      if (!response.ok || !size || size > 512 * 1024 * 1024 || !/^(video|audio)\//i.test(mime)) throw new Error("This player does not expose a downloadable media file. Try the detected network stream instead.");
      id = (await request({ type: "swiftget-import-start", fileName: `${cleanTitle()}.${mime.includes("webm") ? "webm" : "mp4"}`, size, source: location.href })).id;
      const reader = response.body.getReader(); let offset = 0;
      try {
        while (true) {
          const { value, done } = await reader.read(); if (done) break;
          for (let start = 0; start < value.length; start += 256 * 1024) {
            const part = value.subarray(start, start + 256 * 1024);
            let binary = "";
            for (let i = 0; i < part.length; i += 8192) binary += String.fromCharCode(...part.subarray(i, i + 8192));
            await request({ type: "swiftget-import-chunk", id, offset, data: btoa(binary) });
            offset += part.length;
          }
        }
      } finally { await reader.cancel().catch(() => {}); reader.releaseLock(); }
      await request({ type: "swiftget-import-finish", id }); id = null;
      flashOne(b, "Saved to KeRo Smarter Download ✔");
    } catch (error) {
      if (id) await request({ type: "swiftget-import-cancel", id }).catch(() => {});
      if (!b.disposed) renderOne(b, error.message, true);
    } finally { b.loading = false; }
  }

  function update(newItems) {
    if (!TOP) return; // frames look up their own videos
    items = Array.isArray(newItems) ? newItems.slice(0, 80) : [];
    if (!items.length) {
      // new page / new video: forget the bubbles and "hidden"
      for (const b of bubbles.values()) b.dispose();
      bubbles.clear();
      return;
    }
    if (!panelAllowed()) return;
    place();
    for (const b of bubbles.values()) if (!b.own && !b.loading) renderOne(b);
  }

  document.addEventListener("click", (event) => {
    if (event.button !== 0 || event.altKey || event.ctrlKey || event.shiftKey || event.metaKey || event.defaultPrevented || !switchedOn) return;
    const anchor = event.composedPath().find((node) => node?.tagName === "A" && node.href);
    if (!anchor || !/^https?:/i.test(anchor.href) || (!anchor.hasAttribute("download") && !FILE_LINK.test(anchor.href))) return;
    event.preventDefault(); event.stopImmediatePropagation();
    const url = anchor.href;
    apiBrowser.runtime.sendMessage({ type: "swiftget-direct-link", url,
      fileName: anchor.getAttribute("download") || "", referrer: location.href }, (res) => {
      if (apiBrowser.runtime.lastError || !res?.taken) location.assign(url);
    });
  }, true);

  // magnet links of torrents go to KeRo Smarter Download (Alt + click: to the browser)
  addEventListener(
    "click",
    (e) => {
      if (e.button !== 0 || e.altKey || e.defaultPrevented || !switchedOn) return;
      const a = e.composedPath ? e.composedPath().find((n) => n && n.tagName === "A" && n.href) : null;
      const href = a ? String(a.href) : "";
      if (!/^magnet:\?/i.test(href) || !/xt=urn:bt[im]h:/i.test(href)) return;
      e.preventDefault();
      e.stopPropagation();
      apiBrowser.runtime.sendMessage({ type: "swiftget-magnet", url: href }, (res) => {
        // not taken (the app is closed, or sending is off): the browser's way
        if (apiBrowser.runtime.lastError || !res || !res.ok) location.href = href;
      });
    },
    true
  );

  // a click anywhere else closes an open menu
  addEventListener(
    "mousedown",
    (e) => {
      const path = e.composedPath ? e.composedPath() : [];
      for (const b of bubbles.values()) {
        if (b.open && !path.includes(b.host)) {
          b.open = false;
          b.help = false;
          renderOne(b);
        }
      }
    },
    true
  );
  addEventListener("keydown", (e) => {
    if (e.key !== "Escape") return;
    for (const b of bubbles.values()) {
      if (b.open) {
        b.open = false;
        renderOne(b);
      }
    }
  });
  for (const ev of ["fullscreenchange", "webkitfullscreenchange"]) {
    document.addEventListener(ev, () => setTimeout(() => bubbles.forEach((b) => placeOne(b)), 50));
  }

  // every link of the page (or the selection) for "Download all links"
  function collectLinks(selectionOnly) {
    const sel = selectionOnly ? getSelection() : null;
    const inSel = (el) => !sel || (sel.rangeCount > 0 && sel.containsNode(el, true));
    const out = [];
    const seen = new Set();
    const add = (url, text) => {
      if (!url || !/^https?:/i.test(url)) return;
      url = url.split("#")[0];
      if (seen.has(url)) return;
      seen.add(url);
      out.push({ url, text: (text || "").replace(/\s+/g, " ").trim().slice(0, 200) });
    };
    // the page itself and the parts built as web components
    const roots = [document];
    try {
      for (const el of document.querySelectorAll("*")) if (el.shadowRoot) roots.push(el.shadowRoot);
    } catch (_) {
      /* a strange page */
    }
    for (const root of roots) {
      for (const a of root.querySelectorAll("a[href]")) if (inSel(a)) add(a.href, a.innerText || a.title);
      for (const el of root.querySelectorAll("img[src], video[src], audio[src], source[src], embed[src]")) {
        if (inSel(el)) add(el.src, el.alt || el.title || "");
      }
    }
    // addresses written as plain text (pages that show a list of links, a
    // note or a paste): what the user sees is what is collected
    const text = sel ? String(sel) : (document.body && document.body.innerText) || "";
    for (const m of text.slice(0, 2000000).matchAll(/\bhttps?:\/\/[^\s"'<>()\[\]{}]+/gi)) {
      add(m[0].replace(/[.,;:!?]+$/, ""), "");
      if (out.length > 5000) break;
    }
    return { page: location.href, links: out };
  }

  apiBrowser.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    if (msg.type === "swiftget-media") update(msg.items);
    if (msg.type === "swiftget-collect-links") {
      if (!TOP) return false; // the page itself answers
      sendResponse(collectLinks(!!msg.selection));
      return true;
    }
    if (msg.type === "swiftget-open-panel") {
      const v = biggestVideo();
      if (!v) return false;
      let b = bubbles.get(v);
      if (!b) b = makeBubble(v);
      dismissedVideos.delete(v);
      b.dismissed = false;
      layer().appendChild(b.host);
      b.open = true;
      if (!itemsOf(b).length) lookUp(b);
      else renderOne(b);
      placeOne(b);
    }
    return false;
  });
  apiBrowser.runtime.sendMessage({ type: "swiftget-config" }, (res) => {
    if (!apiBrowser.runtime.lastError && res) {
      panel = res;
      if (!panelAllowed()) {
        for (const b of bubbles.values()) b.dispose();
        bubbles.clear();
      }
    }
  });
  if (TOP) {
    // keys held while clicking a link: Alt = let the browser download it, etc.
    addEventListener(
      "mousedown",
      (e) => {
        sendQuietly({ type: "swiftget-keys", alt: e.altKey, ctrl: e.ctrlKey, shift: e.shiftKey });
      },
      true
    );
    // media detected before this script loaded
    apiBrowser.runtime.sendMessage({ type: "swiftget-media-request" }, (res) => {
      if (!apiBrowser.runtime.lastError) update(res);
    });
  }

  addEventListener("scroll", schedulePlace, { passive: true, capture: true });
  addEventListener("resize", schedulePlace, { passive: true });
  for (const event of ["play", "loadedmetadata", "durationchange", "emptied"]) {
    document.addEventListener(event, () => { videosDirty = true; watchVideos(); schedulePlace(); }, true);
  }
  // Some web components attach a shadow root without a light-DOM mutation.
  // Discover those when the user reaches the player, without rescanning the page.
  document.addEventListener("pointerover", (event) => {
    if (document.hidden || !panelAllowed()) return;
    for (const node of event.composedPath()) {
      if (node.shadowRoot && !rootObservers.has(node.shadowRoot)) {
        discover(node); videosDirty = true; schedulePlace(); break;
      }
    }
  }, { passive: true, capture: true });
  document.addEventListener("visibilitychange", () => {
    if (document.hidden) { if (frame) cancelAnimationFrame(frame); frame = 0; }
    else { videosDirty = true; watchVideos(); schedulePlace(); }
  });
  addEventListener("popstate", () => { videosDirty = true; foundFiles.clear(); watchVideos(); schedulePlace(); });
  addEventListener("pagehide", (event) => {
    if (event.persisted) return;
    removeAll();
    for (const observer of rootObservers.values()) observer.disconnect();
    rootObservers.clear(); shadowVideos.clear(); videoCache = [];
    clearTimeout(discoveryTimer); addedRoots.clear();
    if (frame) cancelAnimationFrame(frame);
  });
  observeRoot(document);
  discover(document);
  watchVideos(); schedulePlace();
  // A visible-page fallback handles SPA URL changes and player resizing.
  // Hidden tabs do no work, and this path never rescans shadow DOM.
  setInterval(() => {
    if (document.hidden || !panelAllowed() || !videoCache.length) return;
    watchVideos(); schedulePlace();
  }, 2500);
})();

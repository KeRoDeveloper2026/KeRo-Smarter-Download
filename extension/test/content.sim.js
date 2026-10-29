// DOM simulation for lifecycle/performance regressions; no network or browser.
const fs = require('fs'), vm = require('vm'), path = require('path'), assert = require('assert');
const FIREFOX = process.argv.includes('--firefox');
const FAILURE = (process.argv.find((s) => s.startsWith('--invalidated=')) || '--invalidated=throw').split('=')[1];
const messages = [], shadows = [], observers = [], windowListeners = new Map(), intervals = [];
let fullWalks = 0;
class Node {
  constructor(tag) { this.tagName = tag.toUpperCase(); this.nodeType = 1; this.children = []; this.attrs = {}; this.style = { setProperty(k, v) { this[k] = v; } }; this.listeners = {}; this.classList = { add() {}, remove() {}, toggle() {} }; this.textContent = ''; }
  get isConnected() { return this === html || !!this.parentNode?.isConnected || !!this.host?.isConnected; }
  setAttribute(k, v) { this.attrs[k] = String(v); if (k === 'src' || k === 'href') this[k] = String(v); }
  getAttribute(k) { return this.attrs[k] ?? null; }
  hasAttribute(k) { return k in this.attrs; }
  append(...nodes) { for (const n of nodes) if (typeof n === 'object') { n.remove(); n.parentNode = this; n.parentElement = this; this.children.push(n); } }
  appendChild(n) { this.append(n); return n; }
  remove() { if (this.parentNode) { const a = this.parentNode.children; const i = a.indexOf(this); if (i >= 0) a.splice(i, 1); } this.parentNode = this.parentElement = null; }
  replaceChildren(...nodes) { for (const n of [...this.children]) n.remove(); this.append(...nodes); }
  attachShadow() { const r = new Node('shadow'); r.host = this; shadows.push(r); return r; }
  matches(q) { return q.split(',').some((s) => { s = s.trim(); if (s === '*') return true; const m = /^([a-z]+)(?:\[([^\]]+)\])?$/.exec(s); return m && this.tagName === m[1].toUpperCase() && (!m[2] || this.hasAttribute(m[2])); }); }
  querySelectorAll(q) { if (q === '*') fullWalks++; const out = []; for (const c of this.children) { if (c.matches(q)) out.push(c); out.push(...c.querySelectorAll(q)); } return out; }
  querySelector(q) { return q.startsWith('#') ? this.getElementById(q.slice(1)) : this.querySelectorAll(q)[0] || null; }
  getElementById(id) { for (const c of this.children) { if (c.attrs.id === id) return c; const x = c.getElementById(id); if (x) return x; } return null; }
  getBoundingClientRect() { return this.tagName === 'VIDEO' ? { left: 10, top: 10, right: 650, bottom: 370, width: 640, height: 360 } : { left: 10, top: 10, right: 190, bottom: 46, width: 180, height: 36 }; }
  addEventListener(name, fn, opts) { const list = this.listeners[name] ||= []; if (opts?.signal?.aborted) return; list.push(fn); opts?.signal?.addEventListener('abort', () => { const i = list.indexOf(fn); if (i >= 0) list.splice(i, 1); }, {once:true}); }
  focus() {}
  contains(n) { return this === n || this.children.some((c) => c.contains(n)); }
}
const html = new Node('html'), body = new Node('body'); html.append(body);
const doc = new Node('document'); doc.children = [html]; doc.documentElement = html; doc.body = body; doc.title = 'Test clip'; doc.hidden = false;
doc.createTreeWalker = (root) => { const nodes = root.querySelectorAll('*'); let index = 0; return { nextNode: () => nodes[index++] || null }; };
doc.createElement = (tag) => new Node(tag); doc.createElementNS = (_ns, tag) => new Node(tag);
const video = new Node('video'); video.src = video.currentSrc = 'https://cdn.example/clip.mp4'; video.paused = false; video.ended = false; video.duration = 120; body.append(video);
function addWindow(name, fn, options) { let listeners = windowListeners.get(name); if (!listeners) windowListeners.set(name, listeners = new Set()); listeners.add(fn); options?.signal?.addEventListener('abort', () => listeners.delete(fn), { once: true }); }
const ctx = { document: doc, window: null, location: new URL('https://site.example/watch'), innerWidth: 1000, innerHeight: 800,
  addEventListener: addWindow, AbortController, console, URL, NodeFilter: { SHOW_ELEMENT: 1 }, getSelection: () => null,
  setTimeout, clearTimeout, setInterval(fn, ms) { intervals.push({ fn, ms, active:true }); return intervals.length; }, clearInterval(id) { if (intervals[id-1]) intervals[id-1].active=false; },
  requestAnimationFrame: (fn) => setTimeout(fn, 0), cancelAnimationFrame: clearTimeout,
  MutationObserver: class { constructor(fn) { this.fn = fn; observers.push(this); } observe() {} disconnect() { this.disconnected = true; } },
  chrome: { storage: { local: { get(defaults, cb) { if (FIREFOX) return Promise.resolve(defaults); queueMicrotask(() => cb(defaults)); } }, onChanged: { addListener() {} } },
    runtime: { id: 'kero-test-extension', lastError: null, onMessage: { addListener(fn) { ctx.receive = fn; } }, sendMessage(msg, cb) { messages.push(msg); const result = msg.type === 'swiftget-config' ? {enabled: true} : msg.type === 'swiftget-direct-link' ? {taken: true} : [];
      if (cb) queueMicrotask(() => cb(result)); return Promise.resolve(result); } } },
};
ctx.window = ctx; ctx.top = ctx;
if (FIREFOX) { ctx.browser = ctx.chrome; ctx.browser.runtime.getBrowserInfo = async () => ({name: 'Firefox'}); }
vm.createContext(ctx);
vm.runInContext(fs.readFileSync(path.join(__dirname, '../compat.js'), 'utf8'), ctx);
vm.runInContext(fs.readFileSync(path.join(__dirname, '../content.js'), 'utf8'), ctx);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
// A page loaded after an unload must not create any UI or touch DOM APIs.
for (const throws of [false, true]) {
  const runtime = {}; Object.defineProperty(runtime, 'id', {get(){if(throws)throw new Error('Extension context invalidated.');return undefined;}});
  const stale = {chrome:{runtime}, window:{}}; vm.createContext(stale);
  assert.doesNotThrow(() => vm.runInContext(fs.readFileSync(path.join(__dirname,'../content.js'),'utf8'),stale));
  assert.strictEqual(stale.window.__keroDownload,undefined);
}

(async () => {
  await sleep(20);
  let root = shadows.find((s) => s.host.isConnected);
  assert(root, 'a playing video gets a panel without a polling delay');
  assert.strictEqual(root.getElementById('label').textContent, 'Download');
  const menu = root.getElementById('list');
  assert.strictEqual(menu.children.length, 0, 'closed quality menu allocates no rows');
  const baselineWalks = fullWalks;
  for (let n = 0; n < 20; n++) for (const timer of intervals) timer.fn();
  await sleep(20);
  assert.strictEqual(fullWalks, baselineWalks, 'fallback positioning does not deep-scan the DOM');
  assert.strictEqual(windowListeners.get('mousemove').size, 1);
  // Unknown file extensions are routed before browser navigation; a domain
  // suffix such as .com is not mistaken for a file extension.
  {
    const click = doc.listeners.click[0]; let prevented = false;
    const anchor = new Node('a'); anchor.setAttribute('href', 'https://example.com/');
    const event = {button:0,altKey:false,ctrlKey:false,shiftKey:false,metaKey:false,defaultPrevented:false,
      composedPath:() => [anchor], preventDefault(){prevented=true;}, stopImmediatePropagation(){}};
    click(event); assert(!prevented, 'ordinary home pages keep normal navigation');
    anchor.setAttribute('href', 'https://files.example/project.customtype');
    click(event); await sleep(5); assert(prevented);
    assert(messages.some((m) => m.type === 'swiftget-direct-link' && m.url.endsWith('.customtype')));
  }
  // Opening uses the browser-exposed direct source without metadata analysis.
  const grab = root.getElementById('grab');
  grab.listeners.mousedown[0]({ button: 0, clientX: 20, clientY: 20, preventDefault() {} });
  for (const fn of [...windowListeners.get('mouseup')]) fn({});
  assert(menu.children.length > 0, 'quality rows are created when opened');
  assert(!messages.some((m) => m.type === 'swiftget-resolve-video'), 'direct video does not start analysis');
  root.getElementById('close').listeners.click[0]({});
  assert.strictEqual(windowListeners.get('mousemove').size, 0, 'close releases per-panel movement listeners');
  assert.strictEqual(windowListeners.get('mouseup').size, 0, 'close releases per-panel release listeners');
  for (const timer of intervals) timer.fn(); await sleep(20);
  assert(!shadows.some((s) => s.host.isConnected), 'dismissed panel does not reappear');
  // Replace many players: detached panels must not retain listeners.
  for (let n = 0; n < 12; n++) {
    video.remove();
    const next = new Node('video'); Object.assign(next, { src: `https://cdn.example/${n}.mp4`, currentSrc: `https://cdn.example/${n}.mp4`, paused: false, ended: false, duration: 30 }); body.append(next);
    observers[0].fn([{ type: 'childList', addedNodes: [next] }]);
    await sleep(120);
    assert((windowListeners.get('mousemove')?.size || 0) <= 1, 'detached players leak no mouse handlers');
    next.remove();
  }
  // A WhatsApp status Blob is exported in ordered chunks, not handed to
  // the desktop as a browser-only URL or as an encrypted network file.
  {
    ctx.location = new URL('https://web.whatsapp.com/');
    const status = new Node('video');
    Object.assign(status, {currentSrc:'blob:https://web.whatsapp.com/status-1', src:'', duration:30, paused:false, ended:false});
    body.append(status); observers[0].fn([{type:'childList', addedNodes:[status]}]);
    const data = Uint8Array.from({length:600000}, (_, i) => i % 251), chunks = []; let finished = false;
    ctx.btoa = (text) => Buffer.from(text, 'binary').toString('base64');
    ctx.fetch = async () => ({ok:true, headers:{get:(name) => name === 'content-length' ? String(data.length) : 'video/mp4'},
      body:{getReader:() => {let done=false;return {read:async () => {if(done)return {done:true};done=true;return {done:false,value:data};}, cancel:async()=>{}, releaseLock(){}};}}});
    ctx.chrome.runtime.sendMessage = (msg, cb) => {
      messages.push(msg);
      let result = {ok:true};
      if (msg.type === 'swiftget-import-start') result.id='test-status';
      if (msg.type === 'swiftget-import-chunk') {
        const bytes = Buffer.from(msg.data, 'base64');
        assert(bytes.length <= 256 * 1024); assert.strictEqual(msg.offset, chunks.reduce((n, b) => n + b.length, 0)); chunks.push(bytes);
      }
      if (msg.type === 'swiftget-import-finish') finished=true;
      if (cb) queueMicrotask(() => cb(result)); return Promise.resolve(result);
    };
    await sleep(120);
    const panel = shadows.find((r) => r.host.isConnected);
    ctx.receive({type:'swiftget-media',items:[{url:'https://cdn.example/encrypted.enc',label:'Encrypted network file',ext:'enc'}]}, {}, () => {});
    const grab = panel.getElementById('grab');
    grab.listeners.mousedown[0]({button:0,clientX:20,clientY:20,preventDefault(){}});
    for (const fn of [...windowListeners.get('mouseup')]) fn({});
    const row = panel.getElementById('list').children.find((r) => r.listeners.click?.length);
    assert(row, 'status has a download choice');
    await row.listeners.click[0]();
    assert(finished); assert.strictEqual(chunks.length, 3);
    assert.deepStrictEqual(Buffer.concat(chunks), Buffer.from(data));
    status.remove();
    console.log('WhatsApp Blob simulation: ordered 256KiB chunks, exact byte equality and finish acknowledgement passed');
  }
  doc.hidden = true;
  const count = messages.length, walks = fullWalks;
  for (const timer of intervals) timer.fn(); await sleep(10);
  assert.strictEqual(messages.length, count, 'hidden pages do not send analysis messages');
  assert.strictEqual(fullWalks, walks, 'hidden pages do not scan');
  // Disconnects from reloads must not break page links or keep old observers alive.
  {
    doc.hidden = false;
    const navigations = [];
    ctx.location.assign = (url) => navigations.push(url);
    const click = doc.listeners.click[0];
    const anchor = new Node('a'); anchor.setAttribute('href', 'https://files.example/final.zip');
    const makeEvent = () => ({button:0,altKey:false,ctrlKey:false,shiftKey:false,metaKey:false,defaultPrevented:false,
      composedPath:() => [anchor], preventDefault(){this.defaultPrevented=true;}, stopImmediatePropagation(){this.stopped=true;}});
    // A temporary transport error leaves the extension usable, but restores navigation.
    ctx.chrome.runtime.sendMessage = (_msg, cb) => {
      const error = new Error('Could not establish connection. Receiving end does not exist.');
      if (FIREFOX) return Promise.reject(error);
      queueMicrotask(() => {ctx.chrome.runtime.lastError=error; try {cb();} finally {ctx.chrome.runtime.lastError=null;}});
    };
    let event = makeEvent(); click(event); await sleep(10);
    assert(event.defaultPrevented); assert.deepStrictEqual(navigations, [anchor.href]);
    assert.strictEqual(doc.listeners.click.length, 1, 'temporary transport errors do not retire a valid context');
    // A healthy callback-only Chromium API (or Promise-only Firefox API) takes the link.
    ctx.chrome.runtime.sendMessage = (_msg, cb) => {
      const result={taken:true,ok:true};
      if(FIREFOX)return Promise.resolve(result);
      queueMicrotask(() => cb(result)); return undefined;
    };
    event=makeEvent(); click(event); await sleep(10);
    assert(event.defaultPrevented); assert.strictEqual(navigations.length, 1, 'successful handoff never starts a browser fallback');
    const player=new Node('video'); Object.assign(player,{currentSrc:'https://cdn.example/final.mp4',src:'https://cdn.example/final.mp4',paused:false,ended:false,duration:90});
    body.append(player); observers[0].fn([{type:'childList',addedNodes:[player]}]); await sleep(120);
    assert(shadows.some((r) => r.host.isConnected), 'a live panel exists before invalidation');
    let attempts=0;
    ctx.chrome.runtime.sendMessage = (_msg, cb) => {
      attempts++;
      const error=new Error('Extension context invalidated.');
      if(FAILURE==='reject')return Promise.reject(error);
      if(FAILURE==='last-error' && !FIREFOX){
        queueMicrotask(() => {ctx.chrome.runtime.lastError=error;try{cb();}finally{ctx.chrome.runtime.lastError=null;}});
        // Some adapters both reject and call back: navigation must happen once.
        return Promise.reject(error);
      }
      throw error;
    };
    if(FAILURE==='missing-id')ctx.chrome.runtime.id=undefined;
    event=makeEvent(); click(event); await sleep(20);
    if(FAILURE==='missing-id'){
      assert(!event.defaultPrevented && !event.stopped, 'a known-invalid context never intercepts page navigation');
      assert.strictEqual(attempts,0); assert.strictEqual(navigations.length,1);
    }else{
      assert(event.defaultPrevented); assert.strictEqual(attempts,1);
      assert.strictEqual(navigations.length,2,'a send-time failure restores navigation exactly once');
    }
    assert(!shadows.some((r) => r.host.isConnected),'invalidation removes stale download panels');
    assert(observers.every((o) => o.disconnected),'invalidation disconnects DOM observers');
    assert(intervals.every((t) => !t.active),'invalidation cancels polling intervals');
    assert.strictEqual(doc.listeners.click.length,0,'stale interception handlers are removed');
    const after=messages.length;
    for(const timer of intervals)timer.fn();
    for(const fn of [...(windowListeners.get('scroll') || [])])fn();
    event=makeEvent();click(event);await sleep(10);
    assert(!event.defaultPrevented,'a retired handler cannot intercept any later click');
    assert.strictEqual(messages.length,after,'retired scripts send no more messages');
    assert.strictEqual(attempts,FAILURE==='missing-id'?0:1);
    console.log(`context invalidation (${FIREFOX?'Firefox':'Chromium'}, ${FAILURE}): normal handoff, temporary-error recovery, single fallback and full cleanup passed`);
  }
  for (const fn of windowListeners.get('pagehide')) fn({ persisted: false });
  assert.strictEqual(windowListeners.get('mousemove').size, 0);
  console.log('content lifecycle: direct-source fast path, lazy menu, no repeated deep scans, handler cleanup after 12 player replacements, dismiss and hidden-tab suspension passed');
})().catch((e) => { console.error(e); process.exitCode = 1; });


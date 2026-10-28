// Adapt Firefox's Promise API to the mixed Promise/callback style used here.
// Chrome retains its native API; no polling or polyfill package is required.
(() => {
  if (globalThis.keroAPI) return;
  const source = globalThis.browser;
  if (!source?.runtime?.getBrowserInfo) { globalThis.keroAPI = globalThis.chrome; return; }
  let callbackError = null;
  const api = Object.create(source);
  const put = (object, key, value) => Object.defineProperty(object, key, { value, writable: true, configurable: true, enumerable: true });
  const adapt = (owner, names) => {
    const out = Object.create(owner || null);
    for (const name of names) if (typeof owner?.[name] === 'function') {
      put(out, name, (...args) => {
        const cb = typeof args[args.length - 1] === 'function' ? args.pop() : null;
        let work;
        try { work = Promise.resolve(owner[name](...args)); } catch (e) { work = Promise.reject(e); }
        if (!cb) return work;
        work.then((value) => cb(value), (error) => {
          callbackError = { message: String(error?.message || error) };
          try { cb(); } finally { callbackError = null; }
        });
      });
    }
    return out;
  };
  put(api, "runtime", adapt(source.runtime, ['sendMessage', 'openOptionsPage']));
  for (const name of ['getManifest', 'reload', 'getURL']) if (typeof source.runtime[name] === 'function') put(api.runtime, name, source.runtime[name].bind(source.runtime));
  Object.defineProperty(api.runtime, 'lastError', { get: () => callbackError || source.runtime.lastError });
  put(api, "storage", Object.create(source.storage));
  for (const area of ['local', 'session', 'sync']) if (source.storage[area]) put(api.storage, area, adapt(source.storage[area], ['get', 'set', 'remove', 'clear']));
  put(api, "tabs", adapt(source.tabs, ['get', 'query', 'sendMessage', 'create', 'update']));
  put(api, "downloads", adapt(source.downloads, ['download', 'cancel', 'erase', 'search']));
  put(api, "cookies", adapt(source.cookies, ['getAll']));
  put(api, "action", adapt(source.action, ['setBadgeText', 'setBadgeBackgroundColor']));
  put(api, "contextMenus", adapt(source.contextMenus, ['removeAll']));
  if (typeof source.contextMenus?.create === 'function') put(api.contextMenus, 'create', source.contextMenus.create.bind(source.contextMenus));
  globalThis.keroAPI = api;
})();

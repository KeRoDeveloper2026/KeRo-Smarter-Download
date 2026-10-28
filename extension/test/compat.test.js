const fs = require('fs'), vm = require('vm'), path = require('path'), assert = require('assert');
const native = { runtime: {getBrowserInfo: async () => ({}), sendMessage: async (msg) => {if (msg.fail) throw new Error('offline'); return {ok:true};}},
  storage: {local: {get: async (defaults) => ({...defaults, ready:true})}}, tabs: {}, downloads: {}, cookies: {}, action: {}, contextMenus: {} };
// Real host APIs may expose non-writable properties. The adapter must shadow,
// rather than try to assign through those inherited properties.
for (const key of Object.keys(native)) Object.defineProperty(native, key, {value:native[key], writable:false});
const context = {browser:native, console}; vm.createContext(context);
vm.runInContext(fs.readFileSync(path.join(__dirname, '../compat.js'), 'utf8'), context);
(async () => {
  const api = context.keroAPI;
  assert((await api.storage.local.get({enabled:true})).ready);
  await new Promise((resolve) => api.storage.local.get({enabled:true}, (r) => {assert(r.ready && r.enabled); resolve();}));
  await new Promise((resolve) => api.runtime.sendMessage({fail:true}, (r) => {assert(!r); assert.strictEqual(api.runtime.lastError.message, 'offline'); resolve();}));
  assert(!api.runtime.lastError, 'lastError is cleared after its callback');
  await assert.rejects(api.runtime.sendMessage({fail:true}), /offline/);
  console.log('Firefox compatibility: Promise-only APIs, callbacks, read-only host namespaces and scoped lastError passed');
})().catch((e) => {console.error(e);process.exitCode=1;});

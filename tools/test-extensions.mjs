import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const cases = [
  ['extension/test/compat.test.js'],
  ['extension/test/yt-core.test.js'],
  ['extension/test/background.sim.js'],
  ['extension/test/background.sim.js', '--firefox'],
];
for (const failure of ['throw', 'missing-id', 'reject', 'last-error']) {
  cases.push(['extension/test/content.sim.js', `--invalidated=${failure}`]);
  cases.push(['extension/test/content.sim.js', '--firefox', `--invalidated=${failure}`]);
}
for (const args of cases) {
  const result = spawnSync(process.execPath, args, { cwd: root, stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) process.exit(result.status ?? 1);
}
console.log(`Passed ${cases.length} Chromium/Firefox test runs.`);

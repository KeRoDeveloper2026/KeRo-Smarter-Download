"""Synchronize browser manifest versions with Cargo.toml; --check never writes."""
import argparse
import json
import re
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFESTS = (
    'extension/manifest.json',
    'extension/manifest.firefox.json',
    'extension-firefox/manifest.json',
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    version = tomllib.loads((ROOT / 'Cargo.toml').read_text(encoding='utf-8'))['workspace']['package']['version']
    if not re.fullmatch(r'\d+\.\d+\.\d+', version) or any(int(x) > 65535 for x in version.split('.')):
        raise SystemExit('Use a stable numeric release version supported by both browsers')
    mismatches = []
    for name in MANIFESTS:
        path = ROOT / name
        manifest = json.loads(path.read_text(encoding='utf-8'))
        if manifest['version'] == version:
            continue
        if args.check:
            mismatches.append(name)
        else:
            manifest['version'] = version
            path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    if mismatches:
        raise SystemExit('Extension/app version mismatch: ' + ', '.join(mismatches) +
                         '. Run python tools/sync-extension-version.py after updating Cargo.toml.')
    print(f'Browser extension versions match app {version}')


if __name__ == '__main__':
    main()

"""Set the GitHub signing secret and update only the public key locally.
Requires Python 3.9+, cryptography and authenticated GitHub CLI.
Use UPDATE_SIGNING_KEY from the environment, or --generate once for a new identity.
"""
import argparse
import os
from pathlib import Path
import re
import secrets
import shutil
import subprocess
import sys
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--generate', action='store_true', help='NEW identity; old installations need a manual reinstall')
    args = parser.parse_args()
    if not shutil.which('gh'):
        parser.error('Install GitHub CLI and run gh auth login first.')
    source = Path(__file__).resolve().parents[1] / 'crates/engine/src/selfupdate.rs'
    text = source.read_text(encoding='utf-8')
    repo = re.search(r'pub const REPO: &str = "([^"]+)";', text)
    pattern = r'pub const UPDATE_PUBLIC_KEY: &str = "[0-9a-f]{64}";'
    if not repo or len(re.findall(pattern, text)) != 1:
        parser.error('Cannot find repository or public key in selfupdate.rs.')
    seed = os.environ.get('UPDATE_SIGNING_KEY', '').strip()
    if args.generate:
        if seed:
            parser.error('Unset UPDATE_SIGNING_KEY before generating a new identity.')
        seed = secrets.token_hex(32)
    if not re.fullmatch(r'[0-9a-fA-F]{64}', seed):
        parser.error('Provide UPDATE_SIGNING_KEY as 64 hex characters, or use --generate once.')
    public = Ed25519PrivateKey.from_private_bytes(bytes.fromhex(seed)).public_key().public_bytes(
        serialization.Encoding.Raw, serialization.PublicFormat.Raw
    ).hex()
    candidate = source.with_suffix('.rs.tmp')
    try:
        candidate.write_text(re.sub(pattern, f'pub const UPDATE_PUBLIC_KEY: &str = "{public}";', text), encoding='utf-8')
        # Private bytes go through stdin, never argv, logs, or repository files.
        result = subprocess.run(['gh', 'secret', 'set', 'UPDATE_SIGNING_KEY', '--repo', repo.group(1)],
                                input=seed + '\n', text=True, capture_output=True, check=False)
        if result.returncode:
            print('Could not set secret. Check gh auth status and repository permissions. Public key unchanged.', file=sys.stderr)
            return 1
        candidate.replace(source)
    finally:
        candidate.unlink(missing_ok=True)
    print('GitHub signing secret configured. Public key:', public)
    print('Commit and push crates/engine/src/selfupdate.rs before publishing.')
    print('Install the first build manually. Do not regenerate the key for each release.')
    return 0


if __name__ == '__main__':
    sys.exit(main())

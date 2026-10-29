"""Require an explicit stable release tag matching the workspace version."""
import argparse
import re
from pathlib import Path
import tomllib


def validate(tag, version):
    if not re.fullmatch(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", tag):
        raise ValueError("Release tag must have the form vMAJOR.MINOR.PATCH")
    if tag != f"v{version}":
        raise ValueError(f"Tag {tag} does not match Cargo.toml version {version}")
    return version


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tag")
    parser.add_argument("--manifest", type=Path, default=Path("Cargo.toml"))
    args = parser.parse_args()
    manifest = tomllib.loads(args.manifest.read_text(encoding="utf-8"))
    try:
        print(validate(args.tag, manifest["workspace"]["package"]["version"]))
    except ValueError as error:
        parser.exit(1, f"Release validation failed: {error}\n")

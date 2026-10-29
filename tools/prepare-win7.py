"""Verify and retarget classic COM bindings to Windows 7's Ole32.

Both windows-core and windows contain generated bindings for the same COM APIs.
Only these three existing APIs are retargeted; newer APIs remain blocked by the
PE import check. Use windows_slim_errors to avoid the separate WinRT error APIs.
"""
import argparse
import hashlib
import os
from pathlib import Path


def prepare(cargo_root):
    changes = (
        ('windows-core-0.62.2', 'src/imp/bindings.rs',
         '7e54bcd14f10e690320e91caecc5cd4cbbf0eab5278c72df2913c7ca5d7323ba',
         'windows_link::link!', ('CoTaskMemAlloc', 'CoTaskMemFree')),
        ('windows-core-0.62.2', 'src/imp/marshaler.rs',
         '563e4965ee8db90106174caeb8ee800eb3a11f24ca6607a53606bb98fbafa8f9',
         'windows_link::link!', ('CoCreateFreeThreadedMarshaler',)),
        ('windows-0.62.2', 'src/Windows/Win32/System/Com/mod.rs',
         'baafc59ea14e937eff7ecfd57a9e29a4774b56d822d7dadd19652f792735cae3',
         'windows_core::link!',
         ('CoTaskMemAlloc', 'CoTaskMemFree', 'CoCreateFreeThreadedMarshaler')),
    )
    pending = []
    for package, relative, original_hash, macro, functions in changes:
        roots = list((cargo_root / 'registry' / 'src').glob(f'*/{package}'))
        if len(roots) != 1:
            raise RuntimeError(f'Expected exactly one verified {package} package')
        path = roots[0] / relative
        current = path.read_bytes()
        original = current
        # Accept our exact previous patch as well, to support cached sources.
        for function in functions:
            old = f'{macro}("combase.dll" "system" fn {function}('.encode()
            new = old.replace(b'combase.dll', b'ole32.dll')
            if current.count(old) + current.count(new) != 1:
                raise RuntimeError(f'Unexpected binding for {package}: {function}')
            original = original.replace(new, old)
        if hashlib.sha256(original).hexdigest() != original_hash:
            raise RuntimeError(f'Unrecognized upstream source: {package}/{relative}')
        patched = original
        for function in functions:
            old = f'{macro}("combase.dll" "system" fn {function}('.encode()
            patched = patched.replace(old, old.replace(b'combase.dll', b'ole32.dll'))
        pending.append((path, patched))
    # Validate every input before modifying any source file.
    for path, patched in pending:
        if path.read_bytes() != patched:
            path.write_bytes(patched)
    print('Windows 7 COM compatibility: 6 verified bindings use Ole32.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--cargo-root', type=Path, default=Path(os.environ.get('CARGO_HOME', Path.home() / '.cargo')))
    prepare(parser.parse_args().cargo_root)

"""Apply a narrow, verified source compatibility patch for windows-core 0.62.2.

These classic COM functions exist in Ole32 on Windows 7. Newer generated
bindings import them from Combase (Windows 8+). No replacement DLL is shipped.
Use with the documented windows_slim_errors cfg to avoid WinRT error APIs.
"""
import argparse
import hashlib
import os
from pathlib import Path


def prepare(cargo_root):
    roots = list((cargo_root / 'registry' / 'src').glob('*/windows-core-0.62.2'))
    if len(roots) != 1:
        raise RuntimeError('Expected exactly one verified windows-core 0.62.2 package')
    changes = {
        'src/imp/bindings.rs': (
            '7e54bcd14f10e690320e91caecc5cd4cbbf0eab5278c72df2913c7ca5d7323ba',
            ('CoTaskMemAlloc', 'CoTaskMemFree'),
        ),
        'src/imp/marshaler.rs': (
            '563e4965ee8db90106174caeb8ee800eb3a11f24ca6607a53606bb98fbafa8f9',
            ('CoCreateFreeThreadedMarshaler',),
        ),
    }
    pending = []
    for relative, (original_hash, functions) in changes.items():
        path = roots[0] / relative
        current = path.read_bytes()
        original = current
        # Accept our exact previous patch as well, to support cached sources.
        for function in functions:
            old = f'windows_link::link!("combase.dll" "system" fn {function}('
            new = old.replace('combase.dll', 'ole32.dll')
            if current.decode().count(old) + current.decode().count(new) != 1:
                raise RuntimeError(f'Unexpected binding for {function}')
            original = original.replace(new.encode(), old.encode())
        if hashlib.sha256(original).hexdigest() != original_hash:
            raise RuntimeError(f'Unrecognized upstream source: {relative}')
        patched = original
        for function in functions:
            old = f'windows_link::link!("combase.dll" "system" fn {function}('
            patched = patched.replace(old.encode(), old.replace('combase.dll', 'ole32.dll').encode())
        pending.append((path, patched))
    # Validate every input before modifying any source file.
    for path, patched in pending:
        if path.read_bytes() != patched:
            path.write_bytes(patched)
    print('Windows 7 COM compatibility: 3 verified bindings use Ole32.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--cargo-root', type=Path, default=Path(os.environ.get('CARGO_HOME', Path.home() / '.cargo')))
    prepare(parser.parse_args().cargo_root)

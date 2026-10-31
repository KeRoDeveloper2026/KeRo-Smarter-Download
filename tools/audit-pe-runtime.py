"""Read direct/delay PE imports and bundled PyInstaller PE payloads; execute nothing.

Independent implementation for this repository, using struct/zlib only. This is
an import audit, not proof that every dynamically selected plugin/API works on a
clean OS. A real clean Windows VM remains a required release check.
"""
import argparse
import hashlib
import json
import re
import struct
import zlib
from pathlib import Path, PurePosixPath

RUNTIME = re.compile(r'^(vcruntime\d.*|msvcp\d.*|msvcr\d.*|api-ms-win-crt-.*|ucrtbase(d)?)\.dll$', re.I)
UCRT = re.compile(r'^(api-ms-win-crt-.*|ucrtbase)\.dll$', re.I)
COOKIE = b'MEI\x0c\x0b\x0a\x0b\x0e'


def pe_imports(data):
    def read(fmt, at):
        size = struct.calcsize(fmt)
        if at < 0 or at + size > len(data):
            raise ValueError('Truncated PE structure')
        return struct.unpack_from(fmt, data, at)

    if data[:2] != b'MZ':
        raise ValueError('Not a PE executable')
    pe, = read('<I', 60)
    if data[pe:pe + 4] != b'PE\0\0':
        raise ValueError('Missing PE signature')
    machine, count = read('<HH', pe + 4)
    opt_size, = read('<H', pe + 20)
    opt = pe + 24
    magic, = read('<H', opt)
    if magic not in (0x10b, 0x20b):
        raise ValueError('Unsupported optional header')
    wide = magic == 0x20b
    base, = read('<Q' if wide else '<I', opt + (24 if wide else 28))
    dirs = opt + (112 if wide else 96)
    sections = [read('<IIII', opt + opt_size + 40 * i + 8) for i in range(count)]

    def offset(rva):
        for virtual_size, addr, raw_size, raw in sections:
            if addr <= rva < addr + max(virtual_size, raw_size):
                at = raw + rva - addr
                if 0 <= at < len(data):
                    return at
        raise ValueError(f'Unmapped PE RVA: {rva:x}')

    def name(rva):
        at = offset(rva)
        end = data.find(b'\0', at, min(len(data), at + 1024))
        if end < 0:
            raise ValueError('Unterminated DLL name')
        return data[at:end].decode('ascii').lower()

    result = {'direct': [], 'delay': []}
    for index, kind, width in [(1, 'direct', 20), (13, 'delay', 32)]:
        if dirs + index * 8 + 8 > opt + opt_size:
            continue
        table_rva, size = read('<II', dirs + index * 8)
        if not table_rva:
            continue
        at = offset(table_rva)
        for _ in range(min(size // width + 1, 4096)):
            fields = read('<' + 'I' * (width // 4), at)
            if not any(fields):
                break
            dll_rva = fields[3] if kind == 'direct' else fields[1]
            if kind == 'delay' and not fields[0] & 1:
                dll_rva -= base
            result[kind].append(name(dll_rva))
            at += width
        else:
            raise ValueError('Unterminated import directory')
    return machine, {k: sorted(set(v)) for k, v in result.items()}


def embedded_files(data):
    """Inspect modern CArchive cookies/TOCs without importing third-party code."""
    pos = data.rfind(COOKIE)
    if pos < 0:
        return {}, False
    if pos + 88 > len(data):
        raise ValueError('Unsupported/truncated PyInstaller cookie')
    _, size, toc_offset, toc_size, _, _ = struct.unpack_from('!8sIIII64s', data, pos)
    start = pos + 88 - size
    at, end = start + toc_offset, start + toc_offset + toc_size
    if start < 0 or not start <= at <= end <= pos:
        raise ValueError('Invalid PyInstaller archive bounds')
    files = {}
    budget = 512 * 1024 * 1024
    while at < end:
        if at + 18 > end:
            raise ValueError('Truncated PyInstaller TOC')
        entry_size, entry_offset, stored, expanded, compressed, kind = struct.unpack_from('!IIIIBc', data, at)
        if entry_size < 18 or at + entry_size > end:
            raise ValueError('Invalid PyInstaller TOC entry')
        name = data[at + 18:at + entry_size].split(b'\0', 1)[0].decode('utf-8')
        normalized = name.replace('\\', '/')
        if kind == b'b' or normalized.lower().endswith(('.dll', '.exe', '.pyd')):
            if expanded > 128 * 1024 * 1024 or expanded > budget:
                raise ValueError('Embedded binary exceeds audit memory limit')
            lo, hi = start + entry_offset, start + entry_offset + stored
            if not start <= lo <= hi <= start + toc_offset:
                raise ValueError('Invalid embedded binary bounds')
            payload = data[lo:hi]
            if compressed:
                decoder = zlib.decompressobj()
                payload = decoder.decompress(payload, expanded + 1)
                if len(payload) != expanded or not decoder.eof:
                    raise ValueError('Invalid compressed embedded binary')
            if len(payload) != expanded:
                raise ValueError('Embedded binary length mismatch')
            files[normalized] = payload
            budget -= len(payload)
        at += entry_size
    return files, True


def audit(stage, legacy):
    stage = Path(stage)
    report, errors, main_errors = [], [], []
    main_found = False
    for path in sorted(stage.rglob('*')):
        if not path.is_file() or path.suffix.lower() not in ('.exe', '.dll', '.pyd'):
            continue
        data = path.read_bytes()
        embedded, container = embedded_files(data)
        members = {'<outer>': data, **{n: b for n, b in embedded.items() if b[:2] == b'MZ'}}
        for member, binary in members.items():
            machine, imports = pe_imports(binary)
            runtimes = sorted({n for names in imports.values() for n in names if RUNTIME.fullmatch(n)})
            main = path.name.lower() == 'kerodownload.exe' and member == '<outer>'
            main_found |= main
            resolution = {}
            for dll in runtimes:
                local = path.parent / dll
                # Windows is case-insensitive even when this audit runs on Linux.
                local_found = any(p.is_file() and p.name.lower() == dll for p in path.parent.iterdir())
                embedded_found = member != '<outer>' and any(PurePosixPath(n).name.lower() == dll for n in embedded)
                resolution[dll] = 'app-local' if local_found else 'embedded' if embedded_found else 'Windows 10/11 UCRT' if not legacy and UCRT.fullmatch(dll) else 'UNRESOLVED'
                if main or resolution[dll] == 'UNRESOLVED':
                    message=f'{path.name}:{member} imports {dll} ({resolution[dll]})'
                    errors.append(message)
                    if main: main_errors.append(message)
            report.append({'file': str(path.relative_to(stage)), 'member': member, 'machine': hex(machine),
                           'sha256': hashlib.sha256(binary).hexdigest(), 'imports': imports,
                           'runtime_resolution': resolution, 'pyinstaller_container': container})
    if not main_found:
        errors.append('Main application was not inspected')
        main_errors.append('Main application was not inspected')
    return {'legacy_windows7': legacy, 'binaries': report, 'errors': errors, 'main_errors': main_errors,
            'limitations': 'Direct/delay imports and recognized PyInstaller PE members only. Dynamic LoadLibrary choices, unsupported packers, optional features and actual clean-OS behavior require a clean Windows VM test.'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage')
    parser.add_argument('--legacy-win7', action='store_true')
    parser.add_argument('--output', required=True)
    parser.add_argument('--allow-helper-prerequisites', action='store_true', help='Trial only: retain helper prerequisite warnings while still rejecting every main-app runtime dependency')
    args = parser.parse_args()
    result = audit(args.stage, args.legacy_win7)
    result['helper_prerequisites_accepted_for_trial'] = args.allow_helper_prerequisites
    Path(args.output).write_text(json.dumps(result, indent=2), encoding='utf-8')
    print(f"Inspected {len(result['binaries'])} outer/embedded PE binaries; {len(result['errors'])} unresolved/main-runtime dependencies")
    if result['main_errors'] or (result['errors'] and not args.allow_helper_prerequisites):
        raise SystemExit('\n'.join(result['errors']))
    if result['errors']:
        print('WARNING: existing helper OS/runtime prerequisites remain; consult the report before testing on a clean OS.')

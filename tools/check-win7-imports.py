"""Reject direct imports of known post-Windows-7 APIs (not a runtime certification)."""
import json
import struct
import sys
from pathlib import Path


def imports(path):
    data = Path(path).read_bytes()
    pe = struct.unpack_from('<I', data, 60)[0]
    sections = struct.unpack_from('<H', data, pe + 6)[0]
    opt_size = struct.unpack_from('<H', data, pe + 20)[0]
    opt = pe + 24
    is64 = struct.unpack_from('<H', data, opt)[0] == 0x20b
    dirs = opt + (112 if is64 else 96)
    tables = []
    for i in range(sections):
        at = opt + opt_size + i * 40
        virtual_size, virtual_addr, raw_size, raw_addr = struct.unpack_from('<IIII', data, at + 8)
        tables.append((virtual_addr, max(virtual_size, raw_size), raw_addr))

    def offset(rva):
        for addr, size, raw in tables:
            if addr <= rva < addr + size:
                return raw + rva - addr
        raise ValueError(f'Invalid PE address: {rva:x}')

    def string(rva):
        at = offset(rva)
        return data[at:data.index(b'\0', at)].decode('ascii')

    import_rva = struct.unpack_from('<I', data, dirs + 8)[0]
    if not import_rva:
        return {}
    descriptor = offset(import_rva)
    result = {}
    while True:
        original, _, _, name, first = struct.unpack_from('<IIIII', data, descriptor)
        if not name:
            break
        dll = string(name)
        thunk = offset(original or first)
        names = []
        while True:
            value = struct.unpack_from('<Q' if is64 else '<I', data, thunk)[0]
            if not value:
                break
            if not value & (1 << (63 if is64 else 31)):
                names.append(string(value + 2))
            thunk += 8 if is64 else 4
        result[dll] = names
        descriptor += 20
    return result


POST_WIN7 = {
    'ProcessPrng', 'WaitOnAddress', 'WakeByAddressAll', 'WakeByAddressSingle',
    'GetSystemTimePreciseAsFileTime', 'GetOverlappedResultEx', 'CreateFile2',
    'GetCurrentPackageFullName', 'GetCurrentPackageFamilyName', 'GetTempPath2W',
    'SetThreadDescription', 'GetThreadDescription', 'SetThreadDpiAwarenessContext',
    'GetDpiForWindow', 'GetDpiForSystem', 'AdjustWindowRectExForDpi',
    'SetProcessDpiAwareness', 'GetProcessDpiAwareness', 'GetDpiForMonitor',
    'DCompositionCreateDevice', 'DCompositionCreateDevice2',
    'UiaDisconnectProvider', 'UiaRaiseNotificationEvent', 'CoIncrementMTAUsage',
    'RoInitialize', 'RoGetActivationFactory', 'RoGetAgileReference', 'RoOriginateErrorW',
}

if __name__ == '__main__':
    report = {str(path): imports(path) for path in sys.argv[1:]}
    print(json.dumps(report, indent=2))
    bad = [(path, dll, name) for path, dlls in report.items()
           for dll, names in dlls.items() for name in names if name in POST_WIN7]
    bad_dlls = [(path, dll) for path, dlls in report.items() for dll in dlls
                if dll.lower() in {'combase.dll', 'shcore.dll'}
                or dll.lower().startswith('api-ms-win-core-winrt-')]
    if bad_dlls:
        raise SystemExit(f'Known post-Windows-7 DLLs: {bad_dlls}')
    if bad:
        raise SystemExit(f'Known post-Windows-7 direct imports: {bad}')

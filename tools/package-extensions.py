"""Build reproducible desktop browser packages; no native application is rebuilt."""
import hashlib
import json
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'extension'
OUT = ROOT / 'dist-extensions'


def main():
    chromium = json.loads((SOURCE / 'manifest.json').read_text())
    firefox = json.loads((SOURCE / 'manifest.firefox.json').read_text())
    version = chromium['version']
    if firefox['version'] != version:
        raise RuntimeError('Browser manifest versions differ')
    for name in ('content.js', 'background.js'):
        if (SOURCE / name).read_bytes() != (ROOT / 'extension-firefox' / name).read_bytes():
            raise RuntimeError(f'Firefox source copy differs: {name}')
    if json.loads((ROOT / 'extension-firefox/manifest.json').read_text()) != firefox:
        raise RuntimeError('Firefox manifest copy differs')
    legacy = json.loads(json.dumps(firefox))
    legacy['name'] = 'KeRo Smarter Download (Windows 7)'
    legacy['browser_specific_settings']['gecko']['strict_min_version'] = '115.0'
    legacy['browser_specific_settings']['gecko'].pop('data_collection_permissions', None)
    legacy['browser_specific_settings'].pop('gecko_android', None)
    entries = {}
    for path in sorted(SOURCE.rglob('*')):
        relative = path.relative_to(SOURCE)
        if not path.is_file() or 'test' in relative.parts or path.name in ('manifest.json', 'manifest.firefox.json'):
            continue
        entries[relative.as_posix()] = path.read_bytes()
    instructions = '''KeRo Smarter Download - browser extension update

العربية:
فك ضغط الحزمة في مجلد ثابت. افتح صفحة إضافات متصفحك ثم حدّث مسار الإضافة إلى المجلد الجديد.
Chromium: اختر Developer mode ثم Load unpacked ومجلد extension.
Firefox: افتح about:debugging#/runtime/this-firefox ثم Load Temporary Add-on
واختر manifest.json من مجلد extension-firefox. التحميل مؤقت؛ أعده بعد إعادة تشغيل Firefox.
نسخة Firefox-Win7 مخصصة لـFirefox 115 ESR. النسخة الحديثة تتطلب Firefox 140 أو أحدث.
أوقف النسخة القديمة المتكررة، وشغّل برنامج KeRo ثم حدّث الصفحات المفتوحة مرة واحدة.
لا تحتاج إلى إعادة تثبيت برنامج سطح المكتب.

English:
Extract to a permanent folder. Chromium browsers: enable Developer mode,
select Load unpacked and the extension folder. Firefox: open
about:debugging#/runtime/this-firefox, select Load Temporary Add-on and
extension-firefox/manifest.json. The unsigned Firefox add-on is temporary.
Use Firefox-Win7 for Firefox 115 ESR; the modern package needs Firefox 140+.
Disable any duplicate old copy, run the KeRo desktop app and refresh open
web pages once. No desktop app reinstallation is required.

Chrome: chrome://extensions
Brave: brave://extensions
Edge: edge://extensions
Opera / Opera GX: opera://extensions
Vivaldi: vivaldi://extensions
Firefox: about:debugging#/runtime/this-firefox

Desktop Windows browser packages. Safari, mobile browsers and live Windows 7
browser compatibility have not been validated. Details:
https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/blob/main/docs/BROWSERS.md
'''
    OUT.mkdir(exist_ok=True)
    hashes = []
    for label, folder, manifest in (
        ('Chromium', 'extension', chromium),
        ('Firefox', 'extension-firefox', firefox),
        ('Firefox-Win7', 'extension-firefox', legacy),
    ):
        payload = {f'{folder}/{name}': data for name, data in entries.items()}
        payload[f'{folder}/manifest.json'] = (json.dumps(manifest, ensure_ascii=False, indent=2) + '\n').encode()
        payload['INSTALL-README.txt'] = ('\ufeff' + instructions).encode()
        for name in manifest['content_scripts'][0]['js']:
            if f'{folder}/{name}' not in payload:
                raise RuntimeError(f'Missing content script: {name}')
        background = manifest['background']
        for name in background.get('scripts', [background.get('service_worker')]):
            if name and f'{folder}/{name}' not in payload:
                raise RuntimeError(f'Missing background script: {name}')
        for name in manifest['icons'].values():
            if f'{folder}/{name}' not in payload:
                raise RuntimeError(f'Missing icon: {name}')
        archive = OUT / f'KeRo-Extension-v{version}-{label}.zip'
        with ZipFile(archive, 'w') as z:
            for name, data in sorted(payload.items()):
                info = ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                info.compress_type = ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                z.writestr(info, data)
        # Verify the archived manifest and fixed scripts, not just the filenames.
        with ZipFile(archive) as z:
            assert json.loads(z.read(f'{folder}/manifest.json')) == manifest
            assert z.read(f'{folder}/content.js') == (SOURCE / 'content.js').read_bytes()
            assert z.read(f'{folder}/background.js') == (SOURCE / 'background.js').read_bytes()
            assert not any('/test/' in name for name in z.namelist())
        hashes.append(f'{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive.name}')
        print(f'Validated: {archive.name}')
    (OUT / f'KeRo-Extensions-v{version}-SHA256SUMS.txt').write_text('\n'.join(hashes) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()

# KeRo Smarter Download v1.1.4

تحديث مجاني لتحسين أمان حفظ البيانات الحساسة ووضوح رسائل فشل الحفظ، مع الحفاظ على الإعدادات وسجل التنزيلات وتكامل المتصفح.

## Downloads / التحميل

| Windows | Architecture | Installer |
|---|---|---|
| Windows 10 / 11 | x64 | [Download](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe) |
| Windows 10 / 11 | x86 (32-bit app) | [Download](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x86.exe) |
| Windows 7 SP1 — experimental | x64 | [Download](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x64.exe) |
| Windows 7 SP1 — experimental | x86 | [Download](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win7-Experimental-x86.exe) |

## Changes

- Designated settings/download secrets now fail safely when Windows protection fails, instead of falling back to plaintext.
- A failed save preserves the previous file and shows a localized warning. Pending download changes can retry saving, and automatic shutdown is cancelled if saving fails.
- Update signing limits the existing private key to the compiled signing utility. The update trust key is unchanged.
- Includes browser extension 1.1.1. Installer AppId, browser protocol and saved profile identifiers are preserved.
- Registry dependency versions are unchanged.

## Validation and provenance

These are the exact installers provided for preview and approved for publication; they were not rebuilt or repackaged for the release. Each architecture passed 73 engine tests, helper checks, and installation over the checksum-verified matching v1.1.3 installer. CI settings/history (or synthetic canaries where absent) and partial-download data were preserved byte-for-byte.

All automated runtime checks ran on Windows Server 2022. Actual Windows 7 runtime compatibility is not established: those builds remain experimental and require updated Windows 7 SP1. Actual UI/browser handoff and live download continuation across an upgrade still need user-machine testing.

- [Successful build and upgrade checks](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions/runs/40953114738)
- [Successful quality checks](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions/runs/40953122626)
- [SHA256SUMS](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/SHA256SUMS.txt) and PROVENANCE.json record asset hashes and the tested source.

`KeRoDownload-Setup.exe` is an identical compatibility alias for the clearly named Windows 10/11 x64 installer. Each architecture has its own signed update manifest. Existing FFmpeg recovery archives and independent extension 1.1.1 ZIPs are retained unchanged from v1.1.3.

Exit the app from the system tray before a manual upgrade. Ed25519 update signatures do not add a Windows publisher certificate; existing Windows trust warnings may still appear.

البرنامج مجاني تمامًا — مع تحيات المطور KeRo HaZem.

## Independent browser extension 1.1.4

Standalone Chromium, Firefox and Firefox-Win7 packages now use version 1.1.4 to match the app. This is a version-number alignment; browser logic and permissions are unchanged. Original desktop installers remain byte-for-byte unchanged and still bundle extension 1.1.1. Update the extension using the separate ZIP package and reload it; Firefox packages remain unsigned temporary-loading packages. The versions were aligned for this update; current packaging allows independent app and extension versions while keeping the browser variants consistent.

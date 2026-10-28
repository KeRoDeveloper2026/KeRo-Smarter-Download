<div align="center">

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

A Windows download manager built with **Rust** and **Slint**, with browser integration, an Arabic interface and a floating progress widget.

[العربية](../README.md) · [Releases](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases) · [Actions](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions)

</div>

## Features

- Multi-connection downloads, up to 32 connections when supported by the server.
- Pause, resume, queues, scheduling and speed limits.
- Media quality selection, playlists and audio conversion through helper tools.
- Chromium and Firefox extensions.
- A draggable floating progress widget.
- Eight interface languages, including Arabic with right-to-left layout.

Download speed, available formats and resume support depend on the source and network. Download only content you are authorized to access and save.

## Getting started

Requires Windows 10/11 x64. If a built release is available, download `KeRoDownload-Setup.exe` from its assets. The source ZIP must be compiled before use.

To build on Windows, run `BUILD.bat`. It uses winget to install missing development tools, downloads helper tools and creates `dist/KeRoDownload-Setup.exe` after successful packaging. Tool installation may require administrator permission.

For Chromium browsers, enable Developer mode on the extensions page and load the `extension` folder. For Firefox, use `about:debugging` to temporarily load `extension-firefox/manifest.json`. The bundled Firefox package is unsigned and intended for development loading.

## Verification and release status

Source version: **1.1.0**. Browser API simulations are distinct from live browser tests. Windows compilation, installation and runtime behavior require verification on Windows. See the [test report](../TEST_REPORT.md) for the original verification scope.

The bundled update source still points to the original repository and requires review before release from this repository. See [release preparation](RELEASING.md) for signing, update URLs and workflow behavior.

## Privacy and contribution

The extension communicates with the desktop app over loopback and may pass download-related cookies and page context. The source uses Windows DPAPI for designated sensitive fields, with plaintext fallback paths; do not share settings, cookies or private download lists.

See [contribution guidance](../CONTRIBUTING.md), [security reporting](../SECURITY.md) and [third-party notices](../THIRD-PARTY-NOTICES.txt).

## License status

The supplied Cargo metadata says MIT, while the original documentation states all rights reserved. No standalone LICENSE file was supplied. The owner must clarify the intended license; this documentation does not grant a new license.

Developed by **KeRo** — [KeRoDeveloper2026](https://github.com/KeRoDeveloper2026).

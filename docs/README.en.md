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

Requires Windows 10/11 x64. Download the owner-supplied [Windows installer (EXE)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRoDownload-Setup.exe), or the [Setup ZIP](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRoDownload-Setup.zip). Run `KeRoDownload-Setup.exe`; extract the ZIP first if you choose the archive.

Direct extension downloads: [Chromium](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Chromium.zip) · [Firefox](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Firefox.zip) · [Combined bundle](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Smarter-Download.zip).

The combined bundle contains browser extensions only. For full source, use GitHub's Code → Download ZIP. The uploaded installer was not executed or validated on Windows in the repository preparation environment. See [SHA256SUMS.txt](../SHA256SUMS.txt) for download integrity hashes.

To build on Windows, run `BUILD.bat`. It uses winget to install missing development tools, downloads helper tools and creates `dist/KeRoDownload-Setup.exe` after successful packaging. Tool installation may require administrator permission.

For Chromium browsers, enable Developer mode on the extensions page and load the `extension` folder. For Firefox, use `about:debugging` to temporarily load `extension-firefox/manifest.json`. The bundled Firefox package is unsigned and intended for development loading.

## Verification and release status

Source version: **1.1.1**. The updater now targets this repository; a new signed installer must be built and published after configuring the signing secret. See [release setup](RELEASING.md). Browser API simulations are distinct from live browser tests. Windows compilation, installation and runtime behavior require verification on Windows. See the [test report](../TEST_REPORT.md) for the original verification scope.

The updater accepts signed releases from this repository. See [release preparation](RELEASING.md) for one-time signing setup, manual first installation and publishing from Actions.

## Privacy and contribution

The extension communicates with the desktop app over loopback and may pass download-related cookies and page context. The source uses Windows DPAPI for designated sensitive fields, with plaintext fallback paths; do not share settings, cookies or private download lists.

See [contribution guidance](../CONTRIBUTING.md), [security reporting](../SECURITY.md) and [third-party notices](../THIRD-PARTY-NOTICES.txt).

## License status

The supplied Cargo metadata says MIT, while the original documentation states all rights reserved. No standalone LICENSE file was supplied. The owner must clarify the intended license; this documentation does not grant a new license.

Developed by **KeRo** — [KeRoDeveloper2026](https://github.com/KeRoDeveloper2026).

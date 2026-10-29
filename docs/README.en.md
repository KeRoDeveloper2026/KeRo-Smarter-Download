<div align="center">

**🌐 Choose your language**

[العربية](../README.md) · **English** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

<br>

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="156">

# KeRo Smarter Download

### Your downloads, in one place

Download files, video and audio. Choose media quality and follow progress in a floating window.<br>
A Windows desktop app with Chromium and Firefox integration.

[![Choose a Windows installer](https://img.shields.io/badge/DOWNLOAD-WINDOWS_APP-0078D4?style=for-the-badge&logo=windows&logoColor=white)](#downloads--v113)
[![Download browser extensions](https://img.shields.io/badge/DOWNLOAD-BROWSER_EXTENSIONS-6D28D9?style=for-the-badge)](#browser-extension-downloads)

[![Release v1.1.3](https://img.shields.io/badge/APP-v1.1.3-0EA5A4?style=flat-square)](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3)
![Windows 10 and 11](https://img.shields.io/badge/WINDOWS-10_%7C_11-0078D4?style=flat-square)
![8 interface languages](https://img.shields.io/badge/APP_UI-8_LANGUAGES-6366F1?style=flat-square)
[![12 documentation languages](https://img.shields.io/badge/DOCS-12_LANGUAGES-0EA5A4?style=flat-square)](LANGUAGES.md)

**Free to use · Developed by KeRo HaZem**

[Features](#features) · [Installation](#getting-started) · [Browser support](BROWSERS.md) · [Report an issue](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues/new/choose)

</div>

| ⬇️ Download & resume | 🎬 Video & audio | 🌐 Browser integration |
|:---:|:---:|:---:|
| Multiple connections, queues and scheduling | Quality selection and audio conversion | Chromium and Firefox extensions |

Documentation is available in **12 languages**. The app interface supports **8 languages**: Arabic, English, French, Spanish, German, Portuguese, Turkish and Russian. [Language guide](LANGUAGES.md).

## Features

- Multi-connection downloads, up to 32 connections when supported by the server.
- Pause, resume, queues, scheduling and speed limits.
- Media quality selection, playlists and audio conversion through helper tools.
- Chromium and Firefox extensions.
- A draggable floating progress widget.
- Eight interface languages, including Arabic with right-to-left layout.

Download speed, available formats and resume support depend on the source and network. Download only content you are authorized to access and save.

## Downloads — v1.1.3

**Free to use.** Choose the installer for your Windows version and system architecture.

| Windows version | Architecture | Direct download | Status |
|---|---|---|---|
| Windows 10 / Windows 11 | 64-bit · x64 | [Download EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-Setup.exe) | Available |
| Windows 10 / Windows 11 | 32-bit · x86 | [Download EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win10_11-x86.exe) | Available |
| Windows 7 SP1 | 64-bit · x64 | [Download EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x64.exe) | Experimental |
| Windows 7 SP1 | 32-bit · x86 | [Download EXE](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRoDownload-v1.1.3-Win7-Experimental-x86.exe) | Experimental |

On 32-bit Windows 10, choose Win10/11 x86. On 64-bit Windows 10 or Windows 11, choose Win10/11 x64; the x86 app is also available. On Windows 7 SP1, choose the matching experimental x86 or x64 package. Check **Control Panel → System → System type** if unsure.

Windows 7 packages passed engine tests, helper smoke tests and import checks on Windows Server 2022. **Installation, GUI behavior and browser integration on an actual Windows 7 device have not been tested.** See [Windows build details](WINDOWS-BUILDS.md).

## Getting started

Run your selected EXE installer, open the app and add a download link. Installers include the helper tools and the `extension` and `extension-firefox` folders. Use the folders installed with your selected package. Windows 7 packages contain a Firefox manifest adapted for **Firefox 115 ESR**; modern packages require Firefox 140 or newer. The Firefox extension is unsigned and loaded temporarily.

### Browser extension downloads

Standalone extension update **v1.1.1** works with the installed desktop app 1.1.3; no desktop reinstallation is needed:

| Desktop browser on Windows | Updated extension |
|---|---|
| Chrome, Brave, Edge, Opera / Opera GX, Vivaldi | [Chromium v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Chromium.zip) |
| Firefox 140+ | [Firefox v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox.zip) |
| Firefox 115 ESR on Windows 7 (experimental) | [Firefox-Win7 v1.1.1](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extension-v1.1.1-Firefox-Win7.zip) |

Extract to a permanent folder, load the updated extension folder and disable any duplicate old copy. Refresh existing website tabs once after the update. The published desktop installers can still contain an older extension version.

[Package SHA-256 checksums](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.3/KeRo-Extensions-v1.1.1-SHA256SUMS.txt) · [Browser compatibility and validation details](BROWSERS.md). API simulations passed; live testing on every listed browser and Windows 7 is still required. Safari and mobile browser packages are not included.

Extension ZIP files contain the extension and installation instructions, not the desktop installer. For full source, use **Code → Download ZIP**. Each installer has a separate signed update manifest in [release v1.1.3](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3). Checksums for the older v1.1.0 assets are available in [that release's SHA256SUMS.txt](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/SHA256SUMS.txt). Generated ZIP/XPI packages are published in Releases rather than tracked in Git.

To build on Windows, run `BUILD.bat`. It uses winget to install missing development tools, downloads helper tools and creates `dist/KeRoDownload-Setup.exe` after successful packaging. Tool installation may require administrator permission.

For Chromium browsers, enable Developer mode on the extensions page and load the `extension` folder. For Firefox, use `about:debugging` to temporarily load `extension-firefox/manifest.json`. The bundled Firefox package is unsigned and intended for development loading.

## Verification and release status

Source version: **1.1.3**. Each platform package has its own signed update manifest. Builds and engine/helper checks passed on Windows Server 2022; these checks do not establish Windows 7 runtime support. See [Windows build details](WINDOWS-BUILDS.md), [release setup](RELEASING.md) and the [original test report](../TEST_REPORT.md). Browser API simulations are distinct from live browser tests.

The updater accepts signed releases from this repository. See [release preparation](RELEASING.md) for one-time signing setup, manual first installation and publishing from Actions.

## Privacy and contribution

If the app is useful to you, consider starring this repository and sharing its download page.

The extension communicates with the desktop app over loopback and may pass download-related cookies and page context. The source uses Windows DPAPI for designated sensitive fields, with plaintext fallback paths; do not share settings, cookies or private download lists.

See [contribution guidance](../CONTRIBUTING.md), [security reporting](../SECURITY.md) and [third-party notices](../THIRD-PARTY-NOTICES.txt).

## License and third-party components

**Free of charge · Open source · Developed by KeRo HaZem**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](../LICENSE)

The official **KeRo Smarter Download** app is free of charge. Read the source, understand how it works and contribute under **GNU GPL-3.0-only**.

| Item | Documented details |
|---|---|
| Original code copyright | **Copyright (c) 2026 KeRo HaZem** — [copyright notice](../COPYRIGHT) |
| Project license | [Full GPL-3.0 text](../LICENSE) · [rights and obligations](LICENSING.md) |
| Source and releases | [Desktop source](../crates) · [extension source](../extension) · [release downloads](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases) |
| Third-party components | [Sources, versions and license notices](../THIRD-PARTY-NOTICES.txt) for Slint, yt-dlp, FFmpeg, LAME, aria2 and Rust libraries |
| Contribute | [Contribution guide](../CONTRIBUTING.md) · [report an issue](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/issues/new/choose) |

When distributing modified versions, provide recipients with the Corresponding Source and retain copyright and license notices as required by the GPL. Commercial use is allowed; private modifications that are not distributed need not be published. Third-party components retain their own copyrights and license terms.

This license applies to the current source; it does not modify previously published installers and is not a code-signing certificate or a guarantee against Windows warnings. Download only content you are entitled to access and save.

Developed by **KeRo HaZem** — [KeRoDeveloper2026](https://github.com/KeRoDeveloper2026).

## Dependency locking

The source includes `Cargo.lock`; build and test commands use `--locked` to prevent automatic dependency changes. See [dependency versions, verification and update policy](DEPENDENCIES.md). Published installers are unchanged.

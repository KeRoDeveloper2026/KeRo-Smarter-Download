<div align="center">

<img src="../crates/app/ui/kero-logo.png" alt="KeRo Smarter Download" width="128">

# KeRo Smarter Download

[العربية](../README.md) · **English** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md)  
[Русский](README.ru.md) · [Türkçe](README.tr.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [हिन्दी](README.hi.md)

A Windows download manager built with **Rust** and **Slint**, with browser integration, an Arabic interface and a floating progress widget.

[Languages](LANGUAGES.md) · [Releases](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases) · [Actions](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/actions)

</div>

**Choose a page language above.** Project and download guides are available in **12 languages**. The app interface supports **8 languages**: Arabic, English, French, Spanish, German, Portuguese, Turkish and Russian. A translated project page does not add interface languages to the app. [Language guide](LANGUAGES.md).

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

Standalone extension archives from **v1.1.0** remain available: [Chromium](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Chromium.zip) · [Firefox](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Extension-Firefox.zip) · [Combined bundle](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.0/KeRo-Smarter-Download.zip). Windows 7 users should use the extension folders bundled with their Win7 installer.

The combined bundle contains extensions only. For full source, use **Code → Download ZIP**. Each installer has a separate signed update manifest in [release v1.1.3](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/tag/v1.1.3). Root `SHA256SUMS.txt` describes the older v1.1.0 assets.

To build on Windows, run `BUILD.bat`. It uses winget to install missing development tools, downloads helper tools and creates `dist/KeRoDownload-Setup.exe` after successful packaging. Tool installation may require administrator permission.

For Chromium browsers, enable Developer mode on the extensions page and load the `extension` folder. For Firefox, use `about:debugging` to temporarily load `extension-firefox/manifest.json`. The bundled Firefox package is unsigned and intended for development loading.

## Verification and release status

Source version: **1.1.3**. Each platform package has its own signed update manifest. Builds and engine/helper checks passed on Windows Server 2022; these checks do not establish Windows 7 runtime support. See [Windows build details](WINDOWS-BUILDS.md), [release setup](RELEASING.md) and the [original test report](../TEST_REPORT.md). Browser API simulations are distinct from live browser tests.

The updater accepts signed releases from this repository. See [release preparation](RELEASING.md) for one-time signing setup, manual first installation and publishing from Actions.

## Privacy and contribution

The extension communicates with the desktop app over loopback and may pass download-related cookies and page context. The source uses Windows DPAPI for designated sensitive fields, with plaintext fallback paths; do not share settings, cookies or private download lists.

See [contribution guidance](../CONTRIBUTING.md), [security reporting](../SECURITY.md) and [third-party notices](../THIRD-PARTY-NOTICES.txt).

## License status

The supplied Cargo metadata says MIT, while the original documentation states all rights reserved. No standalone LICENSE file was supplied. The owner must clarify the intended license; this documentation does not grant a new license.

Developed by **KeRo** — [KeRoDeveloper2026](https://github.com/KeRoDeveloper2026).

# Additional Windows builds

The current release remains available as `KeRoDownload-Setup.exe` (Windows 10/11 x64).
The **Additional Windows architectures** workflow supplements the existing release;
it never replaces its installer or `version.json`.

| Package | Rust target | Status |
| --- | --- | --- |
| `KeRoDownload-v1.1.3-Win10_11-x86.exe` | `i686-pc-windows-msvc` | 32-bit app for Windows 10; Windows 11 runs x86 apps through compatibility support |
| `KeRoDownload-v1.1.3-Win7-Experimental-x64.exe` | `x86_64-win7-windows-msvc` | Experimental, requires testing on Windows 7 SP1 |
| `KeRoDownload-v1.1.3-Win7-Experimental-x86.exe` | `i686-win7-windows-msvc` | Experimental, requires testing on Windows 7 SP1 |

Windows 7 builds compile their own Rust standard library with nightly `build-std`.
They use the community `nicolaasjan/yt-dlp` Windows 7 builds, pinned to
`2026.10.27.141215` and checked against their SHA-256 digests. Automatic yt-dlp
self-update is disabled in these builds to prevent replacement with an official
executable requiring Windows 10. Updating that helper requires a reviewed release.
FFmpeg is built from the same verified FFmpeg and LAME sources for each architecture.
aria2 is also matched to the application's architecture. Rust links the CRT statically.

The workflow verifies PE architecture, runs engine tests and executes each helper
on Windows Server 2022. These checks **do not establish Windows 7 runtime support**.
Slint's documented test platforms are Windows 10/11; third-party dependencies and
TLS support still require validation on an updated Windows 7 SP1 installation.
Windows 7 users may need Windows Management Framework 5.1 for the manual repair script.

Each supplemental build has a separate signed update manifest. The x86 and Windows 7
builds never request the default x64 `version.json`. Future releases must include the
matching manifests and helper archives before these installations can update.
Missing manifests fail safely instead of switching architecture or operating system.

All three builds must succeed before the workflow uploads any supplemental installers.
Release uploads do not use `--clobber`. A rerun encountering existing asset names
requires reviewing the existing assets; it does not silently replace them.

References:
- https://doc.rust-lang.org/nightly/rustc/platform-support/win7-windows-msvc.html
- https://docs.slint.dev/latest/docs/slint/guide/platforms/desktop/windows/general/
- https://github.com/nicolaasjan/yt-dlp/releases/tag/2026.10.27.141215

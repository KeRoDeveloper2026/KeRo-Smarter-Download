# No-admin / static-runtime trial — not a published release

Baseline: main `39ee9218219427c5e90c12c3983461c30cdd5403`, application 1.1.4.
The rejected UI preview is not used. Application/engine Rust sources, the floating
logo, AppId, update verification key and helper bundling stay unchanged.

## Audit before edits

| Item | Existing behavior |
|---|---|
| Installer | `installer/KeRo.iss`, the only ISS script |
| PrivilegesRequired | Already `lowest` |
| PrivilegesRequiredOverridesAllowed | Absent: Inno's default is blank |
| DefaultDirName | `{localappdata}\Programs\KeRo Smarter Download` |
| AppId | `{F4573E06-78AB-4FAD-BC73-710024AFB9E2}` |
| Registry writes | HKCU only: install marker, current-user Run entry, kero-download protocol |
| HKLM use | Read-only runtime detection in obsolete optional redist code; no writes |
| Shared destinations | No `{commonappdata}`, `{commondesktop}`, `{commonstartmenu}`, `{pf}`, `{commonpf}` installation destinations |
| Shortcuts | `{group}` and `{autodesktop}`, per-user under lowest privileges |
| Run / Code | App launch/relaunch, current-user taskkill; no services/firewall. Optional `ShellExec('runas', vc_redist...)` could still request UAC on interactive installation |
| Main app manifest | Already `asInvoker` in crates/app/build.rs |
| Auto-update | SHA-256 plus Ed25519 checks, hash rechecked immediately before direct installer spawn. `/SILENT` or `/VERYSILENT`, `/AUTOUPDATE=1`, `/DIR=current installation` |

`{autopf}` maps to `{userpf}` in non-administrative install mode. The existing
explicit LocalAppData destination is retained to avoid moving an already correct
installation. `UsePreviousAppDir=yes` retains a prior per-user custom location.
A protected all-users installation cannot be replaced in place without access
rights; it is not silently migrated or elevated.

| Target | Existing CRT / build route |
|---|---|
| x86_64-pc-windows-msvc | Config already +crt-static; tag workflow Rust 1.99.1 |
| i686-pc-windows-msvc | Config already +crt-static; four-platform preview workflow Rust 1.99.1 |
| aarch64-pc-windows-msvc | Config already +crt-static; no requested ARM build |
| x86_64-win7-windows-msvc | CI flags +crt-static, nightly-2026-10-29, build-std, legacy-win7, pinned older import libraries and windows_slim_errors |
| i686-win7-windows-msvc | Same Win7 strategy; x86 import library variant |

The normal tag workflow builds the modern x64 package. The additional-platform
workflow currently contains the Win7 variants; the prior four-platform preview
workflow includes modern x86. Local BUILD.bat invokes build-windows.ps1, which
selects stable-msvc, not a pinned Rust release. This trial does not refactor those
release routes.

## Focused source changes

- `installer/KeRo.iss`: retain lowest, directory and AppId; explicitly prohibit
  privilege overrides, preserve the prior directory, remove optional redist
  extraction/elevation entirely, check a prior directory is writable before
  stopping the running app.
- `.cargo/config.toml`: add static CRT defaults for both Win7 targets. Existing
  x64/x86/ARM64 flags are preserved. CI legacy encoded flags are not replaced.
- `build-windows.ps1`: remove optional redist staging; inspect staged PE runtime
  dependencies before signing/packaging. No helper download/bundling changes.
- `tools/check-native-crt.ps1`: use installed MSVC dumpbin to reject dynamic
  VC/UCRT imports in the main EXE and unresolved VC runtime imports in helpers.
- `.github/workflows/build.yml` and `tools/package-platform.ps1`: add the same
  pre-packaging gate for their existing stage; no publishing behavior changes.
- `tools/audit-pe-runtime.py`: independently implemented stdlib-only import audit
  for direct/delay imports and recognized PyInstaller embedded DLL/PYD/EXE files.
  Runtime DLLs embedded by a helper are distinguished from missing dependencies;
  Windows 10/11 UCRT is distinguished from the bare Windows 7 baseline.
- `tools/prepare-noadmin-stage.ps1`: trial-only staging from SHA-256-pinned
  existing 1.1.4 installers, retaining all helper files byte-for-byte. Browser
  folders use the current source, as normal packaging does.
- `tools/test-noadmin-host.ps1` and `tools/test-noadmin-child.ps1`: trial-only
  standard-user account tests on disposable GitHub-hosted Windows runners.
- `.github/workflows/noadmin-runtime-preview.yml`: build the four trial variants,
  preserve each successful application and installer before later tests, run the
  existing engine tests with --locked --no-fail-fast, inspect dependencies and
  test per-user install/upgrade/uninstall. Artifact-only; no release, signing
  secret, production update manifest or tag.
- This audit document: findings, scope and manual verification checklist.

No fallback redist installer is included: packaging is refused if the main EXE
still requires dynamic VC/UCRT runtime DLLs. A helper that needs an unbundled
runtime is reported instead of being silently altered or causing elevation.
The scanner code is written for this repository, not copied from another project.

## Verification boundaries

Runtime import inspection is stronger than a build flag alone, but does not
certify every delayed LoadLibrary choice or unsupported embedded packer. The
hosted Windows Server 2022 image contains development tools and runtimes. Running
under a new non-admin account does not remove those machine-wide components.
Reports must therefore not be described as clean-Windows certification.

No production Ed25519 private key or version.json is needed for trial packaging.
Existing signature/hash rejection tests cover the verification layer; the
standard-user test exercises the silent installer's `/AUTOUPDATE=1` route. A real
signed newer-version end-to-end update remains a clean-VM/manual release check.
Win7 remains experimental; its Tier-3 toolchain strategy is retained.

## Manual clean-VM checklist

Use snapshots and a standard Windows user, separately for each intended OS and
architecture. Do not install the trial on a production profile merely to inspect
it: the AppId is intentionally unchanged and it can upgrade that user's install.

1. Clean OS VM with no separately installed VC++ Redistributable. Record OS/SP/
   updates; bare Win7 SP1 and updated Win7 are different runtime baselines.
2. Fresh normal and silent install: no UAC, per-user Programs path, HKCU shortcuts/
   protocol/autostart; no machine-level changes.
3. Launch app; verify absence of VCRUNTIME/MSVCP/UCRT loader errors. Exercise each
   bundled helper, including video resolve, merge/MP3 and torrent functionality.
4. Connect the browser extension to the app and perform an actual download.
5. Install the previous official matching-architecture version, create settings,
   history and a partial download, then upgrade in place with the trial. Verify
   both preservation and actual resumed bytes.
6. Test a genuinely newer, approved SHA-256/Ed25519-signed update; verify no UAC,
   restart, correct current directory and rejection of altered/unsigned updates.
7. Uninstall as the same standard user: no UAC; user data/partial downloads remain.
8. Test a non-writable old installation: clear failure without elevation or
   automatic migration; the old files/data must remain intact.

## Primary references

- https://jrsoftware.org/ishelp/topic_setup_privilegesrequired.htm
- https://jrsoftware.org/ishelp/topic_setup_privilegesrequiredoverridesallowed.htm
- https://jrsoftware.org/ishelp/topic_consts.htm
- https://jrsoftware.org/ishelp/topic_setup_usepreviousappdir.htm
- https://doc.rust-lang.org/reference/linkage.html
- https://doc.rust-lang.org/rustc/platform-support/win7-windows-msvc.html
- https://pyinstaller.org/en/stable/operating-mode.html

Per-platform build, dumpbin, embedded-runtime and account-test reports accompany
successful trial installers. Failures and unverified items must remain explicit.

## Confirmed trial finding: existing Win7 x86 yt-dlp prerequisite

The preserved Win7 x86 helper contains embedded Python/extension PE binaries
that import Universal CRT API-set DLLs not present in that helper bundle. Bare
Windows 7 SP1 does not include the Windows 10 Universal CRT. This is distinct
from the main KeRo executable, which must still pass the strict static-CRT gate.
The helper bytes are not altered. The Win7 x86 trial may be packaged with a
clearly recorded helper-prerequisite warning; no OS update or redist installer
is started. An updated Win7 VM must be tested separately from bare SP1.

Microsoft's Universal CRT update information:
https://support.microsoft.com/en-us/servicing/os/windows/2020/04/update-for-universal-c-runtime-in-windows

The default packaging gate remains strict. Only explicit trial verification can
accept recorded helper prerequisites; a main-app runtime dependency always
fails. Packed x86 yt-dlp bootloaders may be unreadable by dumpbin (LNK1106); the
independent PE/CArchive audit is used instead, with the original dumpbin error
saved in the reports. No helper file is patched to make the audit pass.

Build-machine provisioning (MSVC Build Tools/Rust) is separate from end-user
installation. The delivered installer never runs BUILD.bat or installs a compiler.

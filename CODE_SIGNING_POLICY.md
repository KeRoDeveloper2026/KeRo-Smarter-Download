# Code signing policy

KeRo Smarter Download is a free, open-source Windows download manager. The project source uses [GPL-3.0-only](LICENSE); third-party components retain their own [licenses and notices](THIRD-PARTY-NOTICES.txt).

## Current status

The public release workflows currently sign **update metadata with Ed25519**. They do not contain a production SignPath or Windows Authenticode signing integration. Publishing this policy does not issue a certificate, sign an installer, or change any already published binary.

SignPath application submission or approval has not been established by the repository configuration. This document therefore does not claim an approved subscription, an issued certificate, or SignPath-signed releases. If the owner has a pending application, that external application remains separate from an operational signing integration.

The local build script has an optional certificate-based signing path. That option alone is not proof that any public release has a publicly trusted signature.

Valid Authenticode signing can identify the certificate publisher, but does not guarantee that Windows SmartScreen warnings disappear or that software is free of defects.

## Project and contact

- Project owner: KeRo HaZem ([KeRoDeveloper2026](https://github.com/KeRoDeveloper2026))
- [Source repository](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download)
- [Release downloads](https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases)
- Contact supplied by the owner: [centerinformation2030@gmail.com](mailto:centerinformation2030@gmail.com)
- Security reports: follow [SECURITY.md](SECURITY.md). Do not publish cookies, passwords, private links or exploitation details in public issues.

## Two separate kinds of signing

| Mechanism | Current behavior |
|---|---|
| Update metadata | Each platform's `version*.json` contains an Ed25519 signature over its version and installer SHA-256. The app verifies the signature and downloaded file hash before accepting an update. This uses the project's pinned update trust key. |
| Windows Authenticode | No production Authenticode integration is configured in the public release workflows. Its certificate chain and publisher identity would be separate from the Ed25519 update key. |

`version*.json` files are signed for the updater; they are not Windows executables and are not Authenticode-signed. See [release and key-management procedures](docs/RELEASING.md).

## Current build and publication process

The [tag build](.github/workflows/build.yml) validates the app version against Cargo.toml and runs quality checks. Additional platform builds have their own workflows. Version 1.1.4 was built and tested in the [preview workflow](.github/workflows/preview-builds.yml), then published from checksum-pinned retained artifacts using the [promotion](.github/workflows/publish-v1.1.4.yml) and [publication-resume](.github/workflows/resume-v1.1.4.yml) workflows. The application installers were not rebuilt for publication.

The Ed25519 signing utility is compiled without the private key. Only the dedicated signing step receives that key from GitHub Secrets. Existing public-key trust is preserved. Published installer hashes, source revision and test runs are recorded in release `PROVENANCE.json` and checksum files.

These source files document the process; they do not by themselves configure GitHub access controls, MFA, protected environments or manual service approvals.

## Planned SignPath integration — not active

If the project is approved, the owner must configure and verify an actual integration before describing a release as SignPath-signed:

- Submit only this project's own application executable and installers from verifiable CI artifacts, with an identifiable source revision and validated checksums. Local developer builds are not eligible for this proposed production route.
- Apply consistent product names and product versions to the project binaries submitted for signing. Browser extension versions may evolve independently.
- Restrict signing submission and approval to the owner's authorized roles. Require an explicit production signing approval and review external contributions before signing.
- Use SignPath-managed certificate keys as required by the approved service; do not put certificate private keys in Git, release assets or logs. The separate Ed25519 updater key still follows RELEASING.md.
- Sign the application executable before packaging it, then sign the installer and validate the resulting certificate chain. Signing changes file hashes: signed outputs need fresh hashes, update signatures, verification and a new reviewed release. Do not replace existing release installers silently.

Proposed scope includes `KeRoDownload.exe`, the clearly named Windows 10/11 x64 and x86 installers, the compatible `KeRoDownload-Setup.exe` alias, and experimental Windows 7 installers only if the provider approves that target. Windows 7 certificate and timestamp compatibility must be tested separately.

Third-party helpers (yt-dlp, FFmpeg, aria2) are not represented as this project's own signed binaries. Browser ZIP packages are not Authenticode targets. The current Firefox ZIPs are unsigned temporary-loading packages; Mozilla signing is a separate process.

| Responsibility | Responsible maintainer |
|---|---|
| Project author / committer | KeRo HaZem |
| Review of external contributions | KeRo HaZem |
| Proposed production signing approver | KeRo HaZem, after approval controls are configured |

Any provider acknowledgement will be added only after the service is approved and active. SignPath Foundation certificates identify the Foundation as the certificate holder; they are not personal certificates issued in the developer's name. Provider conditions and eligibility remain the provider's decision.

References: [SignPath Foundation conditions](https://signpath.org/terms), [signing and approval configuration](https://docs.signpath.io/projects).

## Network use and privacy

Network activity includes downloads requested by the user, automatic app update checks against this repository's GitHub Releases, and automatic helper availability/update checks or downloads where the implementation enables them. These requests can expose ordinary connection metadata to the destination services. This policy does not claim that every network request requires a separate user click.

The browser extension sends download context to the local app over `127.0.0.1` (default port 9614), including relevant page URLs and, where needed, cookies or request context. The app and helper tools can then contact the selected content providers to perform the download. Do not share sensitive settings or download lists.

Designated credentials stored in settings/download records use Windows DPAPI, with fail-safe saving in v1.1.4. This does not encrypt every file or all download context. See [privacy and connections in the README](README.md#الخصوصية-والاتصالات) and [SECURITY.md](SECURITY.md). No telemetry or privacy guarantee for external services is implied by this signing policy.

## Reporting signing concerns

Report a suspected mismatch between a release and its source, or suspected signing-key misuse, using the contact above and the guidance in SECURITY.md. Include the release version, file name and hash without exposing private credentials. Maintainers should investigate and follow the incident procedures in RELEASING.md.

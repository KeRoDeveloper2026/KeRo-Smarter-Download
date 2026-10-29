# v1.1.4 — candidate for user testing

This release has not been published. Public downloads remain on v1.1.3 until the candidate is approved.

- Settings and download secrets now fail safely when Windows protection fails, instead of falling back to plaintext.
- Failed saves preserve the previous file and report a localized warning; downloads can retry saving. Automatic shutdown is cancelled if saving fails.
- Update signing exposes the existing private key only to the precompiled signer. The update trust key is unchanged.
- Includes the current browser extension 1.1.1. Browser protocol and saved profile identifiers are preserved.

## Candidate validation

Build one installer for each supported target: Windows 10/11 x64 and x86, plus experimental Windows 7 SP1 x64 and x86. Run engine tests, helper architecture/smoke checks, and installer upgrade preservation checks on Windows Server 2022. These checks do not establish Windows 7 runtime compatibility.

Before publication, test installation over v1.1.3, settings and download history, pause/resume, browser handoff and protected credentials on a real user machine. Windows 7 candidates need separate testing on updated Windows 7 SP1.

No publicly trusted Authenticode certificate has been added; Windows SmartScreen may still warn.

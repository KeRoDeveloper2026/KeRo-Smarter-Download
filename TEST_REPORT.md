# Test report — 1.1.0

Executed: Node.js simulations and JavaScript syntax checks. No live account data was used.

## extension/test/compat.test.js

Result: PASS

```text
Firefox compatibility: Promise-only APIs, callbacks, read-only host namespaces and scoped lastError passed
```

## extension/test/yt-core.test.js

Result: PASS

```text
yt-core: all tests passed; 1080p Full HD · MP4 | 1080p Full HD · WEBM | 720p HD · MP4 | Audio only · M4A 128k | Audio · MP3 128k | Audio · MP3 160k | Audio · MP3 192k | Audio · MP3 256k | Audio · MP3 320k
```

## extension/test/background.sim.js

Result: PASS

```text
button shows: 1080p Full HD · MP4 | Audio only · M4A 128k | Audio · MP3 128k | Audio · MP3 160k | Audio · MP3 192k | Audio · MP3 256k | Audio · MP3 320k
sent to app: 1080p MP4 - Cool video.mp4 | audio: true
SABR video via app: 1080p MP4 - Real_ Title.mp4 | key: 1080p|MP4
Instagram reel via app: 1080p MP4 - Real_ Title.mp4
browser downloads: restored ones ignored, no repeats, no loop
self update: reloads once when the program has a newer add-in
player in a frame: uses the page's qualities
on / off switch: off leaves everything to the browser
DASH stream: offered, qualities from the app with the page as referrer
performance regressions: direct-file fast path, bounded media bursts, navigation cleanup, resolution deduplication and two-analyzer limit passed
Chrome API simulation: direct-click handoff, scrolling PDF size, quality prefix and selected subtitles passed
background simulation: all checks passed
```

## extension/test/background.sim.js --firefox

Result: PASS

```text
button shows: 1080p Full HD · MP4 | Audio only · M4A 128k | Audio · MP3 128k | Audio · MP3 160k | Audio · MP3 192k | Audio · MP3 256k | Audio · MP3 320k
sent to app: 1080p MP4 - Cool video.mp4 | audio: true
SABR video via app: 1080p MP4 - Real_ Title.mp4 | key: 1080p|MP4
Instagram reel via app: 1080p MP4 - Real_ Title.mp4
browser downloads: restored ones ignored, no repeats, no loop
self update: reloads once when the program has a newer add-in
player in a frame: uses the page's qualities
on / off switch: off leaves everything to the browser
DASH stream: offered, qualities from the app with the page as referrer
performance regressions: direct-file fast path, bounded media bursts, navigation cleanup, resolution deduplication and two-analyzer limit passed
Firefox API simulation: direct-click handoff, scrolling PDF size, quality prefix and selected subtitles passed
background simulation: all checks passed
```

## extension/test/content.sim.js

Result: PASS

```text
WhatsApp Blob simulation: ordered 256KiB chunks, exact byte equality and finish acknowledgement passed
content lifecycle: direct-source fast path, lazy menu, no repeated deep scans, handler cleanup after 12 player replacements, dismiss and hidden-tab suspension passed
```

## extension/test/content.sim.js --firefox

Result: PASS

```text
WhatsApp Blob simulation: ordered 256KiB chunks, exact byte equality and finish acknowledgement passed
content lifecycle: direct-source fast path, lazy menu, no repeated deep scans, handler cleanup after 12 player replacements, dismiss and hidden-tab suspension passed
```

## Static checks

PASS: all JavaScript parses; manifest versions/resources; Firefox background scripts and blocking permission; Tip of the Day removed from Help and startup.

## Not executed

- Rust / Slint compilation and native Windows tests: cargo/rustc and Windows are unavailable.
- Added Rust tests: typed extensions, transient status classification, subtitle/MP3 metadata, and complete browser-file import/move/delete byte integrity.
- No actual Chrome/Firefox installation, live Facebook/WhatsApp account, native PDF viewer, or RAM/network throughput benchmark was run.
- Firefox package is unsigned and intended for temporary developer loading.
- The GitHub workflow runs the extension tests and native engine tests and now blocks packaging on engine test failures.

## Build checksum hotfix

Fixed Windows PowerShell's scalar-pipeline indexing bug in build-windows.ps1: a bare SHA-256 line could become System.Char when indexed with [0]. The checksum is now read as the string value of a validated regex capture. The same parser is used in repair-ffmpeg.ps1, and yt-dlp checksum comparison also enforces a complete 64-character string. Parsing fixtures covered bare hashes, filename suffixes, CRLF, case, leading whitespace, truncated values, overlong hashes and HTML error responses. These fixtures ran in Python; Windows PowerShell itself was not available. No checksum verification was disabled.

## E0599 subtitle receiver hotfix

The reported call at manager.rs:1590 passed &Manager to add_subtitles, whose receiver requires &Arc<Manager>. Changed resolve_pick to receive self: &Arc<Self>. Its only caller, run_download, already has the same receiver, so the shared owner is preserved through the call chain. Verified the source declarations and call sites and ZIP integrity. Rust/Slint compilation remains unexecuted because cargo/rustc are unavailable here.

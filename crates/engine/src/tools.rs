//! The helper programs that come with KeRo Smarter Download: yt-dlp (finds the video
//! links) and aria2 (torrents) from their GitHub releases, and our own small
//! ffmpeg build (joins video + audio, MP3; built by tools/ffmpeg/build.sh). They live in the "tools" folder
//! of the install folder. Once a day, silently, KeRo Smarter Download checks for new
//! versions and updates them, and puts them back if one went missing.

use crate::mux::hide_window;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{Duration, SystemTime};

#[cfg(all(not(target_arch = "x86"), not(feature = "legacy-win7")))]
const YTDLP_URL: &str = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe";
#[cfg(all(target_arch = "x86", not(feature = "legacy-win7")))]
const YTDLP_URL: &str = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_x86.exe";
#[cfg(all(feature = "legacy-win7", target_arch = "x86"))]
const YTDLP_URL: &str =
    "https://github.com/nicolaasjan/yt-dlp/releases/download/2026.10.27.141215/yt-dlp_x86_win7.exe";
#[cfg(all(feature = "legacy-win7", not(target_arch = "x86")))]
const YTDLP_URL: &str =
    "https://github.com/nicolaasjan/yt-dlp/releases/download/2026.10.27.141215/yt-dlp_win7.exe";
const YTDLP_ASSET: &str = match (cfg!(feature = "legacy-win7"), cfg!(target_arch = "x86")) {
    (true, true) => "yt-dlp_x86_win7.exe",
    (true, false) => "yt-dlp_win7.exe",
    (false, true) => "yt-dlp_x86.exe",
    (false, false) => "yt-dlp.exe",
};
#[cfg(not(feature = "legacy-win7"))]
const YTDLP_SUMS_URL: &str =
    "https://github.com/yt-dlp/yt-dlp/releases/latest/download/SHA2-256SUMS";
#[cfg(feature = "legacy-win7")]
const YTDLP_SUMS_URL: &str =
    "https://github.com/nicolaasjan/yt-dlp/releases/download/2026.10.27.141215/SHA2-256SUMS";
/// none of the helpers is anywhere near this big
const MAX_TOOL_BYTES: u64 = 400 << 20;
/// aria2 for torrents: one fixed, known build (it changes rarely), checked
/// against this SHA-256 before use
/// ffmpeg, when the setup does not carry it: the public "essentials" build,
/// checked against the SHA-256 that is published next to it
const FFMPEG_URL: &str = match (cfg!(feature = "legacy-win7"), cfg!(target_arch = "x86")) {
    (true, true) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win7-x86.zip",
    (true, false) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win7-x64.zip",
    (false, true) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win10_11-x86.zip",
    (false, false) => "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip",
};
const FFMPEG_SUM_URL: &str = match (cfg!(feature = "legacy-win7"), cfg!(target_arch = "x86")) {
    (true, true) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win7-x86.zip.sha256",
    (true, false) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win7-x64.zip.sha256",
    (false, true) => "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win10_11-x86.zip.sha256",
    (false, false) => "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip.sha256",
};
#[cfg(not(target_arch = "x86"))]
pub const ARIA2_URL: &str = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip";
#[cfg(target_arch = "x86")]
pub const ARIA2_URL: &str = "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-32bit-build1.zip";
#[cfg(not(target_arch = "x86"))]
pub const ARIA2_ZIP_SHA256: &str =
    "67d015301eef0b612191212d564c5bb0a14b5b9c4796b76454276a4d28d9b288";
#[cfg(target_arch = "x86")]
pub const ARIA2_ZIP_SHA256: &str =
    "35f6514cc5dd7e98a87b3c4c2d25a0754b9b063dbe59bc0f22d483464f61e5b6";
#[cfg(not(target_arch = "x86"))]
pub const ARIA2_EXE_SHA256: &str =
    "be2099c214f63a3cb4954b09a0becd6e2e34660b886d4c898d260febfe9d70c2";
#[cfg(target_arch = "x86")]
pub const ARIA2_EXE_SHA256: &str =
    "b9cd71b275af11b63c33457b0f43f2f2675937070c563e195f223efd7fa4c74b";

fn exe(name: &str) -> String {
    if cfg!(windows) {
        format!("{name}.exe")
    } else {
        name.to_string()
    }
}

/// Folders searched for the tools, best first.
pub fn tool_dirs() -> Vec<PathBuf> {
    let mut v = Vec::new();
    if let Some(dir) = std::env::current_exe()
        .ok()
        .and_then(|e| e.parent().map(Path::to_path_buf))
    {
        v.push(dir.join("tools"));
        v.push(dir);
    }
    if let Some(p) = directories::ProjectDirs::from(
        "com",
        "KeRo",
        if cfg!(feature = "design-preview") {
            "KeRoDesignPreview"
        } else {
            "KeRoDownload"
        },
    ) {
        v.push(p.data_dir().join("tools"));
    }
    v
}

/// A folder of ours for the helpers' temporary files.
pub fn work_dir() -> Option<PathBuf> {
    let dir = directories::ProjectDirs::from(
        "com",
        "KeRo",
        if cfg!(feature = "design-preview") {
            "KeRoDesignPreview"
        } else {
            "KeRoDownload"
        },
    )?
    .data_dir()
    .join("tmp");
    std::fs::create_dir_all(&dir).ok()?;
    Some(dir)
}

/// A tool shipped with the app (not one somewhere on PATH).
pub fn bundled(name: &str) -> Option<PathBuf> {
    tool_dirs()
        .into_iter()
        .map(|d| d.join(exe(name)))
        .find(|p| p.is_file() && p.metadata().map(|m| m.len() > 0).unwrap_or(false))
}

/// Where new copies go: the install folder's "tools" when we may write
/// there, else our data folder.
fn writable_dir(name: &str) -> Option<PathBuf> {
    // keep updating the copy that is already used
    if let Some(p) = bundled(name) {
        if let Some(dir) = p.parent() {
            if can_write(dir) {
                return Some(dir.to_path_buf());
            }
        }
    }
    tool_dirs()
        .into_iter()
        .find(|d| std::fs::create_dir_all(d).is_ok() && can_write(d))
}

fn can_write(dir: &Path) -> bool {
    let probe = dir.join(".kero-write-test");
    let ok = std::fs::write(&probe, b"x").is_ok();
    let _ = std::fs::remove_file(&probe);
    ok
}

fn due(stamp: &Path, every: Duration) -> bool {
    std::fs::metadata(stamp)
        .and_then(|m| m.modified())
        .ok()
        .and_then(|t| SystemTime::now().duration_since(t).ok())
        .map(|age| age > every)
        .unwrap_or(true)
}

/// The SHA-256 of `name` in a checksum list ("<sha256>  <name>" per line).
pub fn sum_for(list: &str, name: &str) -> Option<String> {
    list.lines().find_map(|l| {
        let mut it = l.split_whitespace();
        let (sum, file) = (it.next()?, it.next()?);
        (file.trim_start_matches('*') == name
            && sum.len() == 64
            && sum.chars().all(|c| c.is_ascii_hexdigit()))
        .then(|| sum.to_ascii_lowercase())
    })
}

async fn get_text(client: &reqwest::Client, url: &str) -> anyhow::Result<String> {
    let text = client
        .get(url)
        .header(
            reqwest::header::USER_AGENT,
            crate::config::DEFAULT_USER_AGENT,
        )
        .send()
        .await?
        .error_for_status()?
        .text()
        .await?;
    if text.len() > 1 << 20 {
        anyhow::bail!("unexpected answer from {url}");
    }
    Ok(text)
}

/// Download `url` to `dest`. It is used only when its SHA-256 is `sha256`
/// (from the checksum list its makers publish): a changed or broken file is
/// thrown away and never run.
async fn download(
    client: &reqwest::Client,
    url: &str,
    dest: &Path,
    sha256: &str,
) -> anyhow::Result<()> {
    use sha2::{Digest, Sha256};
    let mut resp = client
        .get(url)
        .header(
            reqwest::header::USER_AGENT,
            crate::config::DEFAULT_USER_AGENT,
        )
        .send()
        .await?
        .error_for_status()?;
    use std::io::Write;
    let tmp = dest.with_extension("download");
    let mut file = std::fs::File::create(&tmp)?;
    let mut h = Sha256::new();
    let mut total: u64 = 0;
    while let Some(chunk) = resp.chunk().await? {
        total += chunk.len() as u64;
        if total > MAX_TOOL_BYTES {
            drop(file);
            let _ = std::fs::remove_file(&tmp);
            anyhow::bail!("the download of {url} is far bigger than expected");
        }
        h.update(&chunk);
        file.write_all(&chunk)?;
    }
    drop(file);
    let got: String = h.finalize().iter().map(|b| format!("{b:02x}")).collect();
    if !got.eq_ignore_ascii_case(sha256) {
        let _ = std::fs::remove_file(&tmp);
        anyhow::bail!("the download of {url} does not match its published SHA-256");
    }
    replace(&tmp, dest)
}

/// Put `new` in place of `target`, even if `target` is running right now
/// (Windows lets us rename a running program, not delete it).
fn replace(new: &Path, target: &Path) -> anyhow::Result<()> {
    if target.exists() {
        let old = target.with_extension("old");
        let _ = std::fs::remove_file(&old);
        if std::fs::remove_file(target).is_err() {
            std::fs::rename(target, &old)?;
        }
    }
    std::fs::rename(new, target)?;
    Ok(())
}

/// yt-dlp missing: get it. Present: `yt-dlp -U` (at most once a day).
async fn yt_dlp(client: &reqwest::Client, data_dir: &Path) {
    if bundled("yt-dlp").is_none() {
        if cfg!(windows) {
            if let Some(dir) = writable_dir("yt-dlp") {
                if let Ok(sums) = get_text(client, YTDLP_SUMS_URL).await {
                    if let Some(sum) = sum_for(&sums, YTDLP_ASSET) {
                        let _ = download(client, YTDLP_URL, &dir.join(exe("yt-dlp")), &sum).await;
                    }
                }
            }
        }
        return;
    }
    if cfg!(feature = "legacy-win7") {
        return;
    }
    let stamp = data_dir.join("yt-dlp-updated");
    if !due(&stamp, Duration::from_secs(20 * 3600)) {
        return;
    }
    let Some(tool) = bundled("yt-dlp") else {
        return;
    };
    let ok = tokio::task::spawn_blocking(move || {
        let mut cmd = Command::new(&tool);
        if let Some(dir) = work_dir() {
            cmd.env("TEMP", &dir).env("TMP", &dir).current_dir(&dir);
        }
        cmd.args(["--ignore-config", "-U"]);
        hide_window(&mut cmd);
        cmd.output().map(|o| o.status.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false);
    if ok {
        let _ = std::fs::write(&stamp, b"ok");
    }
}

/// aria2c missing (an older install): get the known build.
async fn aria2(client: &reqwest::Client) -> anyhow::Result<()> {
    if !cfg!(windows) || bundled("aria2c").is_some() {
        return Ok(());
    }
    let Some(dir) = writable_dir("aria2c") else {
        return Ok(());
    };
    let work = std::env::temp_dir().join(format!("kero-aria2-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&work);
    std::fs::create_dir_all(&work)?;
    let zip = work.join("aria2.zip");
    download(client, ARIA2_URL, &zip, ARIA2_ZIP_SHA256).await?;
    let (zip2, work2) = (zip.clone(), work.clone());
    let unpacked = tokio::task::spawn_blocking(move || {
        let mut cmd = Command::new(crate::system::windows_tool("tar.exe"));
        cmd.arg("-xf").arg(&zip2).arg("-C").arg(&work2);
        hide_window(&mut cmd);
        cmd.output().map(|o| o.status.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false);
    let found = unpacked.then(|| find_file(&work, &exe("aria2c"))).flatten();
    let result = match found {
        Some(f) if sha256_of(&f).as_deref() == Some(ARIA2_EXE_SHA256) => {
            let staged = dir.join("aria2c.new");
            std::fs::copy(&f, &staged)?;
            replace(&staged, &dir.join(exe("aria2c")))
        }
        Some(_) => Err(anyhow::anyhow!(
            "aria2c.exe does not match its known SHA-256"
        )),
        None => Err(anyhow::anyhow!("aria2c.exe was not found in the download")),
    };
    let _ = std::fs::remove_dir_all(&work);
    result
}

/// ffmpeg missing (it did not come with the setup): download it once.
async fn ffmpeg(client: &reqwest::Client) -> anyhow::Result<()> {
    // Startup maintenance and simultaneous downloads share one installation.
    static INSTALL: tokio::sync::Mutex<()> = tokio::sync::Mutex::const_new(());
    let _guard = INSTALL.lock().await;
    if !cfg!(windows) || bundled("ffmpeg").is_some() {
        return Ok(());
    }
    let dir = writable_dir("ffmpeg")
        .ok_or_else(|| anyhow::anyhow!("No writable folder is available for ffmpeg.exe"))?;
    let text = client
        .get(FFMPEG_SUM_URL)
        .header(
            reqwest::header::USER_AGENT,
            crate::config::DEFAULT_USER_AGENT,
        )
        .send()
        .await?
        .error_for_status()?
        .text()
        .await?;
    let sum = text.split_whitespace().next().unwrap_or("").to_string();
    if sum.len() != 64 || !sum.chars().all(|c| c.is_ascii_hexdigit()) {
        anyhow::bail!("the SHA-256 of ffmpeg could not be read");
    }
    let work = std::env::temp_dir().join(format!("kero-ffmpeg-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&work);
    std::fs::create_dir_all(&work)?;
    let zip = work.join("ffmpeg.zip");
    download(client, FFMPEG_URL, &zip, &sum).await?;
    let (zip2, work2) = (zip.clone(), work.clone());
    let unpacked = tokio::task::spawn_blocking(move || {
        let mut cmd = Command::new(crate::system::windows_tool("tar.exe"));
        cmd.arg("-xf").arg(&zip2).arg("-C").arg(&work2);
        hide_window(&mut cmd);
        cmd.output().map(|o| o.status.success()).unwrap_or(false)
    })
    .await
    .unwrap_or(false);
    let found = unpacked.then(|| find_file(&work, &exe("ffmpeg"))).flatten();
    let result = match found {
        Some(f) => {
            let staged = dir.join("ffmpeg.new");
            std::fs::copy(&f, &staged)?;
            replace(&staged, &dir.join(exe("ffmpeg")))
        }
        None => Err(anyhow::anyhow!("ffmpeg.exe was not found in the download")),
    };
    let _ = std::fs::remove_dir_all(&work);
    result
}

/// Required before muxing: recover a missing helper now instead of racing
/// the best-effort startup updater. Existing video/audio parts are retained.
pub async fn ensure_ffmpeg(client: &reqwest::Client) -> anyhow::Result<PathBuf> {
    use anyhow::Context;
    if let Some(path) = crate::mux::find_ffmpeg() {
        return Ok(path);
    }
    tokio::time::timeout(Duration::from_secs(600), ffmpeg(client))
        .await.context("Timed out restoring ffmpeg.exe; check the internet connection and retry")?
        .context("Could not restore ffmpeg.exe. Run REPAIR-FFMPEG.bat or copy ffmpeg.exe into the tools folder beside KeRoDownload.exe, then resume this download")?;
    crate::mux::find_ffmpeg().ok_or_else(|| {
        anyhow::anyhow!(
            "ffmpeg.exe is unavailable. Run REPAIR-FFMPEG.bat, then resume this download"
        )
    })
}

fn sha256_of(path: &Path) -> Option<String> {
    use sha2::{Digest, Sha256};
    let data = std::fs::read(path).ok()?;
    Some(
        Sha256::digest(&data)
            .iter()
            .map(|b| format!("{b:02x}"))
            .collect(),
    )
}

fn find_file(dir: &Path, name: &str) -> Option<PathBuf> {
    for entry in std::fs::read_dir(dir).ok()?.flatten() {
        let p = entry.path();
        if p.is_dir() {
            if let Some(f) = find_file(&p, name) {
                return Some(f);
            }
        } else if p
            .file_name()
            .map(|n| n.eq_ignore_ascii_case(name))
            .unwrap_or(false)
        {
            return Some(p);
        }
    }
    None
}

/// Check both tools now (only does work when a day has passed or one is
/// missing). Never shows anything; errors just mean "try again later".
pub async fn update_all(client: reqwest::Client, data_dir: PathBuf) {
    // A slow yt-dlp update must not postpone recovery of the other tools.
    let _ = tokio::join!(yt_dlp(&client, &data_dir), ffmpeg(&client), aria2(&client));
    // leftovers of earlier updates
    for dir in tool_dirs() {
        for name in ["yt-dlp", "ffmpeg", "aria2c"] {
            let _ = std::fs::remove_file(dir.join(exe(name)).with_extension("old"));
        }
    }
}

/// Run `update_all` now and then every few hours while the app is open.
pub fn spawn_updater(rt: &tokio::runtime::Handle, client: reqwest::Client, data_dir: PathBuf) {
    rt.spawn(async move {
        // let the app start first
        tokio::time::sleep(Duration::from_secs(20)).await;
        loop {
            update_all(client.clone(), data_dir.clone()).await;
            tokio::time::sleep(Duration::from_secs(6 * 3600)).await;
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn replace_and_find() {
        let dir = std::env::temp_dir().join(format!("kero-tools-test-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(dir.join("a/b")).unwrap();
        std::fs::write(dir.join("a/b/ffmpeg.exe"), b"new").unwrap();
        assert!(find_file(&dir, "FFMPEG.EXE").is_some());
        let target = dir.join("tool.exe");
        std::fs::write(&target, b"old").unwrap();
        let new = dir.join("tool.new");
        std::fs::write(&new, b"fresh").unwrap();
        replace(&new, &target).unwrap();
        assert_eq!(std::fs::read(&target).unwrap(), b"fresh");
        let _ = std::fs::remove_dir_all(&dir);
    }
}

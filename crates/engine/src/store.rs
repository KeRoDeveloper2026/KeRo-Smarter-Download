//! Saving the download list so everything survives a restart or a crash.

use crate::model::DownloadRecord;
use serde::Serialize;
use std::path::Path;

pub fn write_json_atomic<T: Serialize>(path: &Path, value: &T) -> anyhow::Result<()> {
    // Finish serialization (including DPAPI) before touching either disk file.
    let bytes = serde_json::to_vec_pretty(value)?;
    write_bytes_atomic(path, &bytes)
}

fn write_bytes_atomic(path: &Path, bytes: &[u8]) -> anyhow::Result<()> {
    if let Some(dir) = path.parent() {
        std::fs::create_dir_all(dir)?;
    }
    let tmp = path.with_extension("json.tmp");
    std::fs::write(&tmp, bytes)?;
    std::fs::rename(&tmp, path)?;
    Ok(())
}

pub fn load_downloads(path: &Path) -> Vec<DownloadRecord> {
    std::fs::read_to_string(path)
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default()
}

/// The download list: saved often, so without spaces (smaller, faster).
pub fn save_downloads(path: &Path, list: &[DownloadRecord]) -> anyhow::Result<()> {
    let bytes = serde_json::to_vec(list)?;
    write_bytes_atomic(path, &bytes)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[derive(serde::Serialize)]
    struct Secret {
        #[serde(with = "crate::secret::string")]
        password: String,
    }

    #[test]
    fn protection_failure_never_touches_the_existing_or_temporary_file() {
        let dir = std::env::temp_dir().join(format!("kero-protected-save-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("settings.json");
        let previous = br#"{"previous":"valid"}"#;
        std::fs::write(&path, previous).unwrap();
        let tmp = path.with_extension("json.tmp");
        std::fs::write(&tmp, b"previous temporary file").unwrap();
        crate::secret::with_failed_protection(|| {
            let error = write_json_atomic(
                &path,
                &Secret {
                    password: "test-private-value".into(),
                },
            )
            .unwrap_err();
            assert!(!error.to_string().contains("test-private-value"));
            assert_eq!(std::fs::read(&path).unwrap(), previous.to_vec());
            assert_eq!(
                std::fs::read(&tmp).unwrap(),
                b"previous temporary file".to_vec()
            );
            let missing = dir.join("new/subdirectory/settings.json");
            assert!(write_json_atomic(
                &missing,
                &Secret {
                    password: "test-private-value".into()
                }
            )
            .is_err());
            assert!(!missing.parent().unwrap().exists());
        });
        std::fs::remove_dir_all(dir).unwrap();
    }
}

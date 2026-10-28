//! Bounded transfer of browser-owned Blob files (e.g. an opened WhatsApp status).
//! Never accepts local paths from a browser, never buffers a whole video in RAM.
use crate::api::{self, ApiEvent};
use serde::Deserialize;
use std::collections::HashMap;
use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use std::path::PathBuf;
use std::sync::{Mutex, OnceLock};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};
use tiny_http::Request;

const CHUNK: u64 = 256 * 1024;
const MAX_SIZE: u64 = 512 * 1024 * 1024;
#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct Start { file_name: String, size: u64, source: String }
struct Transfer { path: Option<PathBuf>, file: Option<File>, name: String, source: String, size: u64, written: u64, touched: Instant }
impl Drop for Transfer {
    fn drop(&mut self) {
        self.file.take();
        if let Some(path) = self.path.take() { let _ = std::fs::remove_file(path); }
    }
}
fn transfers() -> &'static Mutex<HashMap<String, Transfer>> {
    static ALL: OnceLock<Mutex<HashMap<String, Transfer>>> = OnceLock::new();
    ALL.get_or_init(|| Mutex::new(HashMap::new()))
}
fn error(req: Request, text: &str) { api::reply(req, 400, &serde_json::json!({"ok":false,"error":text}).to_string()); }

pub(crate) fn handle(mut req: Request, on_event: &impl Fn(ApiEvent)) {
    let path = req.url().split('?').next().unwrap_or("").to_string();
    let mut all = transfers().lock().unwrap_or_else(|e| e.into_inner());
    all.retain(|_, t| t.touched.elapsed() < Duration::from_secs(600));
    if path == "/import/start" {
        if all.len() >= 2 { return error(req, "Two media imports are already in progress"); }
        let mut body = String::new();
        if req.as_reader().take(16 * 1024).read_to_string(&mut body).is_err() { return error(req, "Invalid import request"); }
        let Ok(start) = serde_json::from_str::<Start>(&body) else { return error(req, "Invalid import request"); };
        if start.size == 0 || start.size > MAX_SIZE || !(start.source.starts_with("https://") || start.source.starts_with("http://")) {
            return error(req, "Media must be between 1 byte and 512 MiB");
        }
        let directory = swiftget_engine::default_data_dir().join("browser-imports");
        if std::fs::create_dir_all(&directory).is_err() { return error(req, "Cannot create the media import folder"); }
        let stamp = SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_nanos();
        let id = format!("{}-{stamp}", std::process::id());
        let file_path = directory.join(format!("{id}.part"));
        let Ok(file) = OpenOptions::new().write(true).create_new(true).open(&file_path) else { return error(req, "Cannot create a temporary media file"); };
        all.insert(id.clone(), Transfer { path: Some(file_path), file: Some(file), name: swiftget_engine::filename::sanitize(&start.file_name), source: start.source, size: start.size, written: 0, touched: Instant::now() });
        return api::reply(req, 200, &serde_json::json!({"ok":true,"id":id}).to_string());
    }
    let id = api::header(&req, "X-KeRo-Import").unwrap_or_default();
    if path == "/import/cancel" {
        all.remove(&id);
        return api::reply(req, 200, r#"{"ok":true}"#);
    }
    if path == "/import/finish" {
        let Some(mut transfer) = all.remove(&id) else { return error(req, "Media import has expired"); };
        if transfer.written != transfer.size { return error(req, "Incomplete media file; nothing was imported"); }
        if transfer.file.as_mut().map(|f| f.sync_all().is_err()).unwrap_or(true) { return error(req, "Could not save the media file"); }
        transfer.file.take();
        let staged = transfer.path.take().unwrap();
        drop(all);
        on_event(ApiEvent::Import { path: staged, name: transfer.name.clone(), source: transfer.source.clone() });
        return api::reply(req, 200, r#"{"ok":true}"#);
    }
    if path != "/import/chunk" { return error(req, "Unknown media import operation"); }
    let Some(transfer) = all.get_mut(&id) else { return error(req, "Media import has expired"); };
    let offset = api::header(&req, "X-KeRo-Offset").and_then(|n| n.parse::<u64>().ok());
    if offset != Some(transfer.written) { return error(req, "Media chunks are out of order"); }
    let mut bytes = Vec::with_capacity(CHUNK as usize);
    if req.as_reader().take(CHUNK + 1).read_to_end(&mut bytes).is_err() || bytes.is_empty() || bytes.len() as u64 > CHUNK || transfer.written + bytes.len() as u64 > transfer.size {
        return error(req, "Invalid media chunk size");
    }
    if transfer.file.as_mut().unwrap().write_all(&bytes).is_err() { return error(req, "Could not write the media chunk"); }
    transfer.written += bytes.len() as u64; transfer.touched = Instant::now();
    api::reply(req, 200, r#"{"ok":true}"#);
}

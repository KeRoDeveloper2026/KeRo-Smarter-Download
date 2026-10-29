//! Regression: imported status bytes, extensionless moves, and deleting a file.
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use swiftget_engine::{Manager, Status};

#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn import_move_and_delete_preserve_bytes_and_names() {
    let id = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let root = std::env::temp_dir().join(format!("kero-import-test-{}-{id}", std::process::id()));
    std::fs::create_dir_all(&root).unwrap();
    let manager = Manager::new(tokio::runtime::Handle::current(), root.join("data")).unwrap();
    let mut settings = manager.settings();
    settings.download_dir = root.join("downloads");
    settings.category_folders = false;
    settings.category_dirs.clear();
    manager.set_settings(settings).unwrap();
    let staged = root.join("status.part");
    let bytes: Vec<u8> = (0..600000usize).map(|i| (i % 251) as u8).collect();
    std::fs::write(&staged, &bytes).unwrap();
    let entry = manager
        .import_browser_file(&staged, "status.mp4", "https://web.whatsapp.com/")
        .unwrap();
    let imported = manager.get(entry).unwrap();
    assert_eq!(imported.status, Status::Completed);
    assert_eq!(std::fs::read(&imported.save_path).unwrap(), bytes);
    // Saving to the same file must never fall back to copying it over itself.
    manager.move_file(entry, &imported.save_path).unwrap();
    assert_eq!(std::fs::read(&imported.save_path).unwrap(), bytes);
    let renamed = root.join("downloads").join("renamed");
    manager.move_file(entry, &renamed).unwrap();
    let moved = manager.get(entry).unwrap();
    assert_eq!(moved.file_name, "renamed.mp4");
    assert!(!renamed.exists());
    assert!(!imported.save_path.exists());
    assert_eq!(std::fs::read(&moved.save_path).unwrap(), bytes);
    manager.remove(entry, true);
    for _ in 0..100 {
        if !moved.save_path.exists() {
            break;
        }
        tokio::time::sleep(Duration::from_millis(20)).await;
    }
    assert!(!moved.save_path.exists());
    let _ = std::fs::remove_dir_all(root);
}

//! Icon next to the clock (Windows): the app keeps running there when its
//! window is closed, like other download managers.

#[cfg_attr(not(windows), allow(dead_code))]
pub enum TrayAction {
    Show,
    AddUrl,
    ResumeAll,
    StopAll,
    ToggleLimiter,
    Scheduler,
    Options,
    About,
    Exit,
}

/// What was clicked on the small icon of a hidden download window.
#[cfg_attr(not(windows), allow(dead_code))]
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum DownloadAction {
    Show,
    Pause,
}

/// 3 x 5 dots for the digits 0-9 and "%" (index 10); one row per entry,
/// the lowest 3 bits are the dots from left to right.
const GLYPHS: [[u8; 5]; 11] = [
    [7, 5, 5, 5, 7],
    [2, 6, 2, 2, 7],
    [7, 1, 7, 4, 7],
    [7, 1, 7, 1, 7],
    [5, 5, 7, 1, 1],
    [7, 4, 7, 1, 7],
    [7, 4, 7, 5, 7],
    [7, 1, 1, 1, 1],
    [7, 5, 7, 5, 7],
    [7, 5, 7, 1, 7],
    [5, 1, 2, 4, 5],
];

/// 32 x 32 RGBA picture for a hidden download: the KeRo download logo
/// (ui/dl32.rgba) with the real progress in it, 0% to 100%
/// (`None`: size unknown, just the logo).
#[cfg_attr(not(windows), allow(dead_code))]
pub fn download_icon(progress: Option<f32>) -> Vec<u8> {
    const N: usize = 32;
    let mut px = include_bytes!("../ui/dl32.rgba").to_vec();
    px.resize(N * N * 4, 0);
    if let Some(p) = progress {
        let pct = (p.clamp(0.0, 1.0) * 100.0).round() as u32;
        let mut glyphs: Vec<usize> = pct.to_string().bytes().map(|b| (b - b'0') as usize).collect();
        glyphs.push(10);
        let width = glyphs.len() * 4 - 1;
        let x0 = (N - width) / 2;
        let y0 = 21usize;
        let mut dots: Vec<(usize, usize)> = Vec::new();
        for (gi, g) in glyphs.iter().enumerate() {
            for (row, bits) in GLYPHS[*g].iter().enumerate() {
                for col in 0..3 {
                    if bits & (4 >> col) != 0 {
                        dots.push((x0 + gi * 4 + col, y0 + row));
                    }
                }
            }
        }
        let mut put = |x: usize, y: usize, c: [u8; 4]| {
            if x < N && y < N {
                let i = (y * N + x) * 4;
                px[i..i + 4].copy_from_slice(&c);
            }
        };
        // a dark edge first, so the white digits read on any part of the logo
        for (x, y) in &dots {
            for dy in 0..3usize {
                for dx in 0..3usize {
                    if (x + dx) >= 1 && (y + dy) >= 1 {
                        put(x + dx - 1, y + dy - 1, [0x05, 0x12, 0x2e, 0xff]);
                    }
                }
            }
        }
        for (x, y) in &dots {
            put(*x, *y, [0xff, 0xff, 0xff, 0xff]);
        }
    }
    px
}

#[cfg(windows)]
mod imp {
    use super::{DownloadAction, TrayAction};
    use std::collections::HashMap;
    use tray_icon::menu::{CheckMenuItem, Menu, MenuEvent, MenuId, MenuItem, PredefinedMenuItem};
    use tray_icon::{Icon, MouseButton, MouseButtonState, TrayIcon, TrayIconBuilder, TrayIconEvent};

    const MAIN_ID: &str = "kero-main";
    const DL_PREFIX: &str = "kero-dl-";

    /// The icon of one hidden download window.
    struct Mini {
        icon: TrayIcon,
        show: MenuId,
        pause: MenuId,
        /// what it shows now, to change it only when needed
        step: Option<u32>,
        tip: String,
    }

    thread_local! {
        static HIDDEN: std::cell::RefCell<HashMap<u64, Mini>> = std::cell::RefCell::new(HashMap::new());
        static PENDING: std::cell::RefCell<Vec<(u64, DownloadAction)>> = const { std::cell::RefCell::new(Vec::new()) };
    }

    fn icon_for(progress: Option<f32>) -> Option<Icon> {
        Icon::from_rgba(super::download_icon(progress), 32, 32).ok()
    }

    /// A small icon next to the clock for a download whose window was hidden.
    pub fn show_download(id: u64, tip: &str, progress: Option<f32>, labels: (&str, &str)) -> bool {
        if HIDDEN.with(|h| h.borrow().contains_key(&id)) {
            return true;
        }
        let menu = Menu::new();
        let show = MenuItem::new(labels.0, true, None);
        let pause = MenuItem::new(labels.1, true, None);
        if menu.append(&show).is_err() || menu.append(&pause).is_err() {
            return false;
        }
        let Some(icon) = icon_for(progress) else { return false };
        let built = TrayIconBuilder::new()
            .with_id(format!("{DL_PREFIX}{id}"))
            .with_tooltip(super::short_tip(tip))
            .with_icon(icon)
            .with_menu(Box::new(menu))
            .with_menu_on_left_click(false)
            .build();
        let Ok(icon) = built else { return false };
        let mini = Mini {
            icon,
            show: show.id().clone(),
            pause: pause.id().clone(),
            step: progress.map(super::step_of),
            tip: tip.to_string(),
        };
        HIDDEN.with(|h| h.borrow_mut().insert(id, mini));
        true
    }

    /// New numbers for its icon and its hint.
    pub fn update_download(id: u64, tip: &str, progress: Option<f32>) {
        HIDDEN.with(|h| {
            if let Some(m) = h.borrow_mut().get_mut(&id) {
                let step = progress.map(super::step_of);
                if step != m.step {
                    m.step = step;
                    let _ = m.icon.set_icon(icon_for(progress));
                }
                if m.tip != tip {
                    m.tip = tip.to_string();
                    let _ = m.icon.set_tooltip(Some(super::short_tip(tip)));
                }
            }
        });
    }

    /// Its window is back (or it is done): the icon goes.
    pub fn remove_download(id: u64) {
        HIDDEN.with(|h| h.borrow_mut().remove(&id));
    }

    /// Clicks on the icons of hidden downloads since the last call.
    pub fn take_download_actions() -> Vec<(u64, DownloadAction)> {
        PENDING.with(|p| std::mem::take(&mut *p.borrow_mut()))
    }

    pub struct Tray {
        _icon: TrayIcon,
        limiter: CheckMenuItem,
        ids: Vec<(MenuId, fn() -> TrayAction)>,
    }

    impl Tray {
        pub fn new() -> Option<Tray> {
            let menu = Menu::new();
            let show = MenuItem::new(crate::i18n::t("Restore KeRo Smarter Download"), true, None);
            let add = MenuItem::new(crate::i18n::t("Add new download…"), true, None);
            let resume = MenuItem::new(crate::i18n::t("Resume all downloads"), true, None);
            let stop = MenuItem::new(crate::i18n::t("Stop all downloads"), true, None);
            let limiter = CheckMenuItem::new(crate::i18n::t("Speed Limiter"), true, false, None);
            let sched = MenuItem::new(crate::i18n::t("Scheduler…"), true, None);
            let options = MenuItem::new(crate::i18n::t("Options…"), true, None);
            let about = MenuItem::new(crate::i18n::t("About"), true, None);
            let exit = MenuItem::new(crate::i18n::t("Exit"), true, None);
            menu.append(&show).ok()?;
            menu.append(&PredefinedMenuItem::separator()).ok()?;
            menu.append(&add).ok()?;
            menu.append(&resume).ok()?;
            menu.append(&stop).ok()?;
            menu.append(&PredefinedMenuItem::separator()).ok()?;
            menu.append(&limiter).ok()?;
            menu.append(&sched).ok()?;
            menu.append(&options).ok()?;
            menu.append(&PredefinedMenuItem::separator()).ok()?;
            menu.append(&about).ok()?;
            menu.append(&exit).ok()?;
            let icon = Icon::from_rgba(include_bytes!("../ui/tray32.rgba").to_vec(), 32, 32).ok()?;
            let tray = TrayIconBuilder::new()
                .with_id(MAIN_ID)
                .with_tooltip("KeRo Smarter Download")
                .with_icon(icon)
                .with_menu(Box::new(menu))
                // the menu on a right click only; a double click opens the window
                .with_menu_on_left_click(false)
                .build()
                .ok()?;
            let ids: Vec<(MenuId, fn() -> TrayAction)> = vec![
                (show.id().clone(), || TrayAction::Show),
                (add.id().clone(), || TrayAction::AddUrl),
                (resume.id().clone(), || TrayAction::ResumeAll),
                (stop.id().clone(), || TrayAction::StopAll),
                (limiter.id().clone(), || TrayAction::ToggleLimiter),
                (sched.id().clone(), || TrayAction::Scheduler),
                (options.id().clone(), || TrayAction::Options),
                (about.id().clone(), || TrayAction::About),
                (exit.id().clone(), || TrayAction::Exit),
            ];
            Some(Tray { _icon: tray, limiter, ids })
        }

        /// Clicks since the last call (those on hidden downloads go to
        /// [`take_download_actions`]).
        pub fn poll(&self) -> Vec<TrayAction> {
            let mut out = Vec::new();
            while let Ok(ev) = TrayIconEvent::receiver().try_recv() {
                let id = ev.id().0.clone();
                if let Some(dl) = id.strip_prefix(DL_PREFIX).and_then(|n| n.parse::<u64>().ok()) {
                    // one click on a hidden download's icon: its window
                    if let TrayIconEvent::Click { button: MouseButton::Left, button_state: MouseButtonState::Up, .. } = ev {
                        PENDING.with(|p| p.borrow_mut().push((dl, DownloadAction::Show)));
                    }
                    continue;
                }
                // left double click: the window (the menu is on the right button)
                if let TrayIconEvent::DoubleClick { button: MouseButton::Left, .. } = ev {
                    out.push(TrayAction::Show);
                }
            }
            while let Ok(ev) = MenuEvent::receiver().try_recv() {
                if let Some((_, make)) = self.ids.iter().find(|(id, _)| *id == ev.id) {
                    out.push(make());
                    continue;
                }
                let hit = HIDDEN.with(|h| {
                    h.borrow().iter().find_map(|(dl, m)| {
                        if ev.id == m.show {
                            Some((*dl, DownloadAction::Show))
                        } else if ev.id == m.pause {
                            Some((*dl, DownloadAction::Pause))
                        } else {
                            None
                        }
                    })
                });
                if let Some(hit) = hit {
                    PENDING.with(|p| p.borrow_mut().push(hit));
                }
            }
            out
        }

        /// Keep the check mark of "Speed Limiter" in step with the app.
        pub fn set_limiter(&self, on: bool) {
            if self.limiter.is_checked() != on {
                self.limiter.set_checked(on);
            }
        }
    }
}

#[cfg(not(windows))]
mod imp {
    use super::{DownloadAction, TrayAction};
    pub fn show_download(_id: u64, _tip: &str, _progress: Option<f32>, _labels: (&str, &str)) -> bool {
        false
    }
    pub fn update_download(_id: u64, _tip: &str, _progress: Option<f32>) {}
    pub fn remove_download(_id: u64) {}
    pub fn take_download_actions() -> Vec<(u64, DownloadAction)> {
        Vec::new()
    }
    pub struct Tray;
    impl Tray {
        pub fn new() -> Option<Tray> {
            None
        }
        pub fn poll(&self) -> Vec<TrayAction> {
            Vec::new()
        }
        pub fn set_limiter(&self, _on: bool) {}
    }
}

pub use imp::{remove_download, show_download, take_download_actions, update_download, Tray};

/// Windows shows at most 127 characters in an icon's hint.
#[cfg_attr(not(windows), allow(dead_code))]
fn short_tip(tip: &str) -> String {
    if tip.chars().count() <= 120 {
        tip.to_string()
    } else {
        tip.chars().take(119).chain(Some('…')).collect()
    }
}

/// The icon changes in steps of 1 % (the number it shows).
#[cfg_attr(not(windows), allow(dead_code))]
fn step_of(p: f32) -> u32 {
    (p.clamp(0.0, 1.0) * 100.0).round() as u32
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn download_icon_shows_the_progress() {
        let empty = download_icon(Some(0.0));
        let half = download_icon(Some(0.5));
        let full = download_icon(Some(1.0));
        assert_eq!(empty.len(), 32 * 32 * 4);
        assert_ne!(empty, half);
        assert_ne!(half, full);
        assert_ne!(download_icon(None), empty);
        // corners are see-through
        assert_eq!(half[3], 0);
        assert_eq!(short_tip(&"x".repeat(300)).chars().count(), 120);
        assert_eq!(step_of(0.5), 50);
    }
}

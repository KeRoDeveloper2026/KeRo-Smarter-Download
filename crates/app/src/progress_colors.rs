//! Download-window colors have a separate file; engine settings are untouched.
use crate::{i18n::t, DetailsDialog, ProgressPalette};
use serde::{Deserialize, Serialize};
use slint::ComponentHandle;
use std::rc::Rc;

#[derive(Clone, Serialize, Deserialize)]
#[serde(default)]
pub(crate) struct Colors {
    pub preset: i32,
    pub accent: String,
    pub secondary: String,
    pub surface: String,
}

impl Default for Colors {
    fn default() -> Self {
        Self::preset(0)
    }
}

impl Colors {
    fn preset(index: i32) -> Self {
        let values = match index {
            1 => ["#C995FF", "#7853EF", "#18102D"],
            2 => ["#45E5B4", "#138D81", "#071F24"],
            3 => ["#FFD36B", "#D18C24", "#211B12"],
            4 => ["#FF9CCF", "#C34E99", "#261327"],
            _ => ["#00D9FF", "#006BFF", "#061428"],
        };
        Self {
            preset: index.clamp(0, 4),
            accent: values[0].into(),
            secondary: values[1].into(),
            surface: values[2].into(),
        }
    }

    fn valid(&self) -> bool {
        [&self.accent, &self.secondary, &self.surface]
            .iter()
            .all(|s| parse(s).is_some())
    }

    fn load() -> Self {
        std::fs::read(swiftget_engine::default_data_dir().join("progress-colors.json"))
            .ok()
            .and_then(|bytes| serde_json::from_slice::<Self>(&bytes).ok())
            .filter(|c| c.valid())
            .map(|mut c| {
                c.preset = c.preset.clamp(0, 5);
                c
            })
            .unwrap_or_default()
    }

    fn save(&self) -> anyhow::Result<()> {
        let dir = swiftget_engine::default_data_dir();
        std::fs::create_dir_all(&dir)?;
        // Do not replace existing preferences until every value is valid.
        anyhow::ensure!(self.valid(), "Invalid color");
        std::fs::write(
            dir.join("progress-colors.json"),
            serde_json::to_vec_pretty(self)?,
        )?;
        Ok(())
    }

    pub(crate) fn apply(&self, d: &DetailsDialog) {
        let palette = d.global::<ProgressPalette>();
        if let (Some(a), Some(b), Some(c)) = (
            parse(&self.accent),
            parse(&self.secondary),
            parse(&self.surface),
        ) {
            palette.set_accent(a);
            palette.set_secondary(b);
            palette.set_surface(c);
            d.set_color_preset(self.preset);
            d.set_accent_hex(self.accent.clone().into());
            d.set_secondary_hex(self.secondary.clone().into());
            d.set_surface_hex(self.surface.clone().into());
        }
    }
}

fn parse(text: &str) -> Option<slint::Color> {
    let text = text.strip_prefix('#')?;
    if text.len() != 6 || !text.bytes().all(|b| b.is_ascii_hexdigit()) {
        return None;
    }
    let value = u32::from_str_radix(text, 16).ok()?;
    Some(slint::Color::from_rgb_u8(
        (value >> 16) as u8,
        (value >> 8) as u8,
        value as u8,
    ))
}

pub(crate) fn bind(d: &DetailsDialog, changed: impl Fn(&Colors) + 'static) {
    Colors::load().apply(d);
    let changed = Rc::new(changed);
    let (weak, notify) = (d.as_weak(), changed.clone());
    d.on_colors_preset(move |index| {
        let Some(d) = weak.upgrade() else { return };
        if index == 5 {
            d.set_color_message(t("Enter colors as #RRGGBB, then apply.").into());
            return;
        }
        commit(&d, &Colors::preset(index), &*notify);
    });
    let weak = d.as_weak();
    d.on_colors_apply(move || {
        let Some(d) = weak.upgrade() else { return };
        let colors = Colors {
            preset: 5,
            accent: d.get_accent_hex().trim().to_ascii_uppercase(),
            secondary: d.get_secondary_hex().trim().to_ascii_uppercase(),
            surface: d.get_surface_hex().trim().to_ascii_uppercase(),
        };
        if !colors.valid() {
            d.set_color_message(t("Invalid color. Use #RRGGBB, for example #00D9FF.").into());
            return;
        }
        commit(&d, &colors, &*changed);
    });
}

fn commit(d: &DetailsDialog, colors: &Colors, notify: &dyn Fn(&Colors)) {
    if let Err(error) = colors.save() {
        d.set_color_message(format!("{}: {error}", t("Could not save colors")).into());
        return;
    }
    colors.apply(d);
    notify(colors);
    d.set_color_message(t("Colors saved").into());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn invalid_or_partial_hex_never_reaches_the_palette() {
        for value in ["", "#FFF", "#00000G", "#00000000", "00D9FF", "#😀xx"] {
            assert!(parse(value).is_none());
        }
        assert_eq!(
            parse("#00d9FF").unwrap(),
            slint::Color::from_rgb_u8(0, 217, 255)
        );
        assert!((0..5).all(|i| Colors::preset(i).valid()));
    }
}

//! Named boundary: no unsafe blocks inside Slint .on_ callback hosts.
//! Prefer safe APIs; if FFI is required, isolate under a named SAFETY module with allow.

use slint::ComponentHandle;

slint::include_modules!();

pub fn wire_safe(ui: &AppWindow) {
    let ui_handle = ui.as_weak();
    ui.on_bumped(move || {
        let Some(ui) = ui_handle.upgrade() else { return };
        ui.set_counter(ui.get_counter() + 1);
    });
}

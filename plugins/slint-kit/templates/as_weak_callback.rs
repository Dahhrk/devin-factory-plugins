//! Named boundary: capture Weak handles in Slint callbacks (prefer as_weak).
//! Copy into product crates; keep slint-rg-allow only on intentional clone_strong seams.

use slint::ComponentHandle;

slint::include_modules!();

pub fn wire_counter(ui: AppWindow) -> slint::Result<()> {
    let ui_handle = ui.as_weak();
    ui.on_bumped(move || {
        let Some(ui) = ui_handle.upgrade() else { return };
        ui.set_counter(ui.get_counter() + 1);
    });
    Ok(())
}

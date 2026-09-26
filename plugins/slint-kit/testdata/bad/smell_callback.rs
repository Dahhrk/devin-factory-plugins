//! Intentional smells for slint-rg-gate discrimination (not product code).
use slint::ComponentHandle;

pub fn wire_bad(ui: &AppWindow) {
    let strong = ui.clone_strong();
    ui.on_bang(move || {
        let _ = &strong;
        unsafe {
            let _ = 0;
        }
    });
}

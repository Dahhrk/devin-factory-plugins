//! Named boundary: Mutex / RwLock poison handling.
//! Prefer recovering the guard (or propagating) over `.lock().unwrap()`.
//! Use `rust-rg-allow` only when poison must abort (document why).

use std::sync::{Mutex, MutexGuard};

pub fn lock_or_recover<T>(m: &Mutex<T>) -> MutexGuard<'_, T> {
    m.lock().unwrap_or_else(|poisoned| poisoned.into_inner())
}

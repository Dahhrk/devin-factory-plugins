//! Named boundary: document SAFETY invariants before every unsafe block/fn.
//! Copy into product crates; keep rust-rg-allow only on intentional seams.

/// # Safety
/// Caller guarantees `p` is non-null and points to a valid `u8`.
pub unsafe fn read_byte(p: *const u8) -> u8 {
    // SAFETY: caller contract above.
    unsafe { *p } // rust-rg-allow: named unsafe boundary with SAFETY docs
}

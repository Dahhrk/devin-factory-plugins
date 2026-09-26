//! Named FFI boundary: document ABI, ownership, and thread-safety.
//! Prefer safe wrappers; mark the extern line with rust-rg-allow + rationale.

/// # Safety
/// `len` must be the byte length of the buffer at `ptr`. Caller owns the buffer.
#[no_mangle] // rust-rg-allow: stable C ABI export for host interop
pub unsafe extern "C" fn dark_copy(ptr: *const u8, len: usize, out: *mut u8) {
    // SAFETY: caller-provided pointers and length; no overlap assumed.
    if ptr.is_null() || out.is_null() || len == 0 {
        return;
    }
    unsafe {
        std::ptr::copy_nonoverlapping(ptr, out, len); // rust-rg-allow: FFI copy under caller contract
    }
}

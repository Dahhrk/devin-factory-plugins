#![allow(dead_code)]

pub fn add(a: i32, b: i32) -> i32 {
    a.checked_add(b).unwrap_or(i32::MAX)
}

/// Named boundary docs live here; intentional unsafe uses rust-rg-allow on the
/// same line as the keyword (see templates/unsafe_boundary.rs).
pub fn ok() -> Result<(), &'static str> {
    Ok(()) // rust-rg-allow: sentinel comment for selfcheck allow marker
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_works() {
        assert_eq!(add(1, 2), 3);
    }
}

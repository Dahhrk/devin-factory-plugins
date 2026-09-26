// Named boundary: prefer error unions over @panic / @trap in library code.
// Copy into product sources; keep zig-rg-allow only on intentional seams.
pub const LibError = error{
    OutOfMemory,
    InvalidInput,
};

pub fn parsePositive(raw: i32) LibError!u32 {
    if (raw < 0) return error.InvalidInput;
    return @intCast(raw);
}

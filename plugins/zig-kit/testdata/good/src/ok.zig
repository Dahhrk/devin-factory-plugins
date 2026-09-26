// Good fixture: try/errdefer, documented allow.
const std = @import("std");

pub fn copyOk(allocator: std.mem.Allocator, name: []const u8) ![]u8 {
    return try allocator.dupe(u8, name);
}

// Documented intentional seam (boot probe); keep allow on the smell line.
pub fn documentedLegacy(allocator: std.mem.Allocator) []u8 {
    return allocator.alloc(u8, 8) catch unreachable; // zig-rg-allow: fixture documents allow marker for intentional unchecked seam
}

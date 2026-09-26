// Named boundary: prefer try / errdefer over catch unreachable on alloc.
// Copy into product sources; keep zig-rg-allow only on intentional seams.
const std = @import("std");

pub fn copyName(allocator: std.mem.Allocator, name: []const u8) ![]u8 {
    const out = try allocator.dupe(u8, name);
    errdefer allocator.free(out);
    return out;
}

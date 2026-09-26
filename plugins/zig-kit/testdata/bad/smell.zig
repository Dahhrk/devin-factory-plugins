// Intentional smells for zig-rg-gate discrimination (not product code).
const std = @import("std");

pub fn panicBad() void {
    @panic("lib path should return error");
}

pub fn allocBad(allocator: std.mem.Allocator) []u8 {
    return allocator.alloc(u8, 16) catch unreachable;
}

pub fn todoBad() void {
    // TODO finish product path
}

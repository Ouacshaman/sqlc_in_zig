const std = @import("std");
const sqlc = @import("false_main.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();
    const allocator = gpa.allocator();

    try sqlc.sqlcGen(allocator);
}

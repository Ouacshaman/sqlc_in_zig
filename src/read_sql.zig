const std = @import("std");

pub fn read(allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().readFileAlloc(allocator, "./src/database/queries.sql", 1024 * 1024);
    const res: []const u8 = @as([]const u8, file);
    return res;
}

test "read" {
    const alloc = std.testing.allocator;
    const res = try read(alloc);
    defer alloc.free(res);

    try std.testing.expectEqualStrings("--\nSELECT * FROM users;\n", res);
}

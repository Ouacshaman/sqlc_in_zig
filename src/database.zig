const std = @import("std");

pub fn displayTable(db: []const u8, query: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = [_][]const u8{ "psql", "-d", db, "-c", query };
    var child = std.process.Child.init(&args, allocator);

    try child.spawn();
    _ = try child.wait();
}

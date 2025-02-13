const std = @import("std");
const db = @import("database.zig");

pub fn main() !void {
    const args = std.os.argv;
    std.debug.print("{s}", .{args[1]});
    _ = try db.displayTable(args[1][0..std.mem.len(args[1])], args[2][0..std.mem.len(args[2])]);
}

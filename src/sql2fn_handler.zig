const std = @import("std");

pub fn createFn(name: []const u8, query: []const u8, alloc: std.mem.Allocator) ![]const u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    try list.appendSlice(name);

    const signature = try std.fmt.allocPrint(allocator, "\npub fn {s} !void{s}\n", .{ name[11..], "{" });
    defer allocator.free(signature);
    try list.appendSlice(signature);

    const query_line = try std.fmt.allocPrint(allocator, "    try query.sendQuery(q.stream, q.allocato, {s});\n{s}\n", .{ query, "}" });
    defer allocator.free(query_line);
    try list.appendSlice(query_line);

    const joined = try list.toOwnedSlice();
    defer allocator.free(joined);
    const res = try alloc.dupe(u8, joined);

    return res;
}

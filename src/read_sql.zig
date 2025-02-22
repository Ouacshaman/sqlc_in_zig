const std = @import("std");

const QueryRes = struct {
    content: []const u8,
    queries: [][]const u8,
};

pub fn read(allocator: std.mem.Allocator) !QueryRes {
    const file = try std.fs.cwd().readFileAlloc(allocator, "./src/database/queries.sql", 1024 * 1024);
    errdefer allocator.free(file);

    var list = std.ArrayList([]const u8).init(allocator);
    defer list.deinit(); // Only Free the List not the items, so no need to worry about seg faults

    var split_string = std.mem.splitAny(u8, file, "\n");

    while (split_string.next()) |value| {
        const converted: []const u8 = @as([]const u8, value);
        try list.append(converted);
    }

    return QueryRes{
        .content = @as([]const u8, file),
        .queries = try list.toOwnedSlice(),
    };
}

//test "read" {
//    const alloc = std.testing.allocator;
//    const res = try read(alloc);
//    defer alloc.free(res);
//
//    try std.testing.expectEqualStrings("--\nSELECT * FROM users;\n", res);
//}

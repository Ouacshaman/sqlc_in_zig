const std = @import("std");
const query = @import("pg_proto_query.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const files = try listFilesInSQLQueries(allocator);
    defer {
        for (files) |file| {
            allocator.free(file);
        }
        allocator.free(files);
    }

    for (files) |file| {
        std.debug.print("Filename: {s}", .{file});
    }
}

// allocator.dupe is used since dir.walk will deinit after the function ends, if not used we will be accessing freed memory
pub fn listFilesInSQLQueries(allocator: std.mem.Allocator) ![][]const u8 {
    var dir = try std.fs.cwd().openDir("src/sql/queries", .{});
    defer dir.close();

    var walk = try dir.walk(allocator);
    defer walk.deinit();

    var list = std.ArrayList([]const u8).init(allocator);
    errdefer {
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }

    while (try walk.next()) |entry| {
        const owned_name = try allocator.dupe(u8, entry.basename);
        try list.append(owned_name);
    }

    return try list.toOwnedSlice();
}

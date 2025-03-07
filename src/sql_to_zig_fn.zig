const std = @import("std");
const readql = @import("read_sql.zig");
const handler = @import("sql2fn_handler.zig");

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

    try createSqlcZigFile();

    for (files) |file| {
        try writeSqlcZig(file);
        std.debug.print("Filename: {s}\n", .{file});
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

pub fn createSqlcZigFile() !void {
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

    for (files) |file_name| {
        // If string is not recognized at comptime use this to overcome
        const full_path = try std.fmt.allocPrint(allocator, "src/internal/database/{s}.zig", .{file_name});
        defer allocator.free(full_path);
        const file = try std.fs.cwd().createFile(full_path, .{});
        defer file.close();
    }
}

pub fn writeSqlcZig(file_name: []const u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("File Name: {s}\n", .{file_name});
    const lines = try readql.read(allocator);
    defer allocator.free(lines.content);
    defer allocator.free(lines.queries);

    const path = try std.fmt.allocPrint(allocator, "src/internal/database/{s}.zig", .{file_name});
    defer allocator.free(path);
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_write });
    defer file.close();

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    const std_lib = "const std = @import(\"std\");\n";
    const query_lib = "const query = @import(\"../../postgres_protocol/pg_proto_query.zig\");\n\n";

    try list.appendSlice(std_lib);
    try list.appendSlice(query_lib);

    var i: usize = 0;
    while (i < lines.queries.len) : (i += 1) {
        if (std.mem.startsWith(u8, lines.queries[i], "--")) {
            const out = try std.fmt.allocPrint(allocator, "//{s}", .{lines.queries[i]});
            defer allocator.free(out);
            const func = try handler.createFn(out, lines.queries[i + 1], allocator);
            defer allocator.free(func);
            try list.appendSlice(func);
        }
    }

    // toOwnedSlice creates a slice []const u8 here
    const joined = try list.toOwnedSlice();
    defer allocator.free(joined);

    std.debug.print("Joined: {s}", .{joined});

    _ = try file.writeAll(joined);
}

const std = @import("std");
const connect = @import("connect.zig");
const Startup = @import("pg_proto_startup.zig");
const Query = @import("pg_proto_query.zig");
const Json = @import("json.zig");
const ReadQL = @import("read_sql.zig");
const sqlcFn = @import("sql_to_zig_fn.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();
    const allocator = gpa.allocator();

    const args = std.os.argv;
    if (args.len < 1) {
        std.debug.print("Usage: {s} <query>\n", .{args[0]});
        return error.NoQuery;
    }
    const first_arg = args[1][0..std.mem.len(args[1])];

    if (std.mem.eql(u8, first_arg, "generate")) {
        const files = try sqlcFn.listFilesInSQLQueries(allocator);
        defer {
            for (files) |file| {
                allocator.free(file);
            }
            allocator.free(files);
        }

        try sqlcFn.createSqlcZigFile();

        for (files) |file| {
            try sqlcFn.writeSqlcZig(file);
            std.debug.print("Filename: {s}\n", .{file});
        }
    } else {
        std.debug.print("Not a Valid Entry: {s}", .{first_arg});
    }
}

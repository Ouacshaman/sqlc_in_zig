const std = @import("std");
const db = @import("database.zig");
const connect = @import("connect.zig");
const Startup = @import("pg_proto_startup.zig");
const Query = @import("pg_proto_query.zig");
const Json = @import("json.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();
    const allocator = gpa.allocator();

    const value = Json.readConfig(allocator) catch return error.UnableToReadJSON;
    defer {
        allocator.free(value.default_user);
        allocator.free(value.default_database);
        allocator.free(value.default_host);
        allocator.free(value.default_port);
    }

    const args = std.os.argv;

    if (args.len < 1) {
        std.debug.print("Usage: {s} <query>\n", .{args[0]});
        return error.NoQuery;
    }

    const port = try std.fmt.parseInt(u16, value.default_port, 10);

    const stream = try connect.connect(value.default_host, port);
    defer stream.close();

    std.debug.print("User: {s}, Database: {s}\n", .{ value.default_user, value.default_database });

    try Startup.sendStartup(stream, allocator, value.default_user, value.default_database);

    try Query.sendQuery(stream, allocator, args[1][0..std.mem.len(args[1])]);
}

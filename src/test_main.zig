const std = @import("std");
const Startup = @import("postgres_protocol/pg_proto_startup.zig");
const connect = @import("connect.zig");
const Json = @import("json.zig");
const queryZig = @import("internal/database/queries.sql.zig");

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

    const port = try std.fmt.parseInt(u16, value.default_port, 10);
    const stream = try connect.connect(value.default_host, port);
    defer stream.close();

    std.debug.print("User: {s}, Database: {s}\n", .{ value.default_user, value.default_database });

    try Startup.sendStartup(stream, allocator, value.default_user, value.default_database);

    const res = try queryZig.GetUsers(stream, allocator);
    defer allocator.free(res);
    std.debug.print("Results: {s}", .{res});
}

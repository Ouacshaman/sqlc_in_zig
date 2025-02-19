const std = @import("std");
const db = @import("database.zig");
const connect = @import("connect.zig");
const Startup = @import("pg_proto_startup.zig");
const Query = @import("pg_proto_query.zig");

pub fn main() !void {
    const args = std.os.argv;

    if (args.len < 4) {
        std.debug.print("Usage: {s} <username> <password> <query>\n", .{args[0]});
        return error.NotEnoughArguments;
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const stream = try connect.connect("127.0.0.1", 5432);
    defer stream.close();

    try Startup.sendStartup(stream, allocator, args[1][0..std.mem.len(args[1])], args[2][0..std.mem.len(args[2])]);
    try Query.sendQuery(stream, allocator, args[3][0..std.mem.len(args[3])]);
}

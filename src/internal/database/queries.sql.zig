const std = @import("std");
const query = @import("../../postgres_protocol/pg_proto_query.zig");

//-- name: GetUsers :
pub fn GetUsers(stream: std.net.Stream, allocator: std.mem.Allocator) ![]const u8{
    const res = try query.sendQuery(stream, allocator, "SELECT * FROM users;");
    return res;
}
//-- name: GetOne :
pub fn GetOne(stream: std.net.Stream, allocator: std.mem.Allocator) ![]const u8{
    const res = try query.sendQuery(stream, allocator, "SELECT 1;");
    return res;
}
//-- name: GetUserIDs :
pub fn GetUserIDs(stream: std.net.Stream, allocator: std.mem.Allocator) ![]const u8{
    const res = try query.sendQuery(stream, allocator, "SELECT email FROM users;");
    return res;
}

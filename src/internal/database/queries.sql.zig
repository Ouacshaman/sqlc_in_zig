const std = @import("std");
const query = @import("pg_proto_query.zig");

//-- name: GetUsers :many
pub fn GetUsers(stream: std.net.Stream, allocator: std.mem.Allocator) !void{
    try query.sendQuery(stream, allocator, "SELECT * FROM users;");
}
//-- name: GetOne :one
pub fn GetOne(stream: std.net.Stream, allocator: std.mem.Allocator) !void{
    try query.sendQuery(stream, allocator, "SELECT 1;");
}
//-- name: GetUserIDs :many
pub fn GetUserIDs(stream: std.net.Stream, allocator: std.mem.Allocator) !void{
    try query.sendQuery(stream, allocator, "SELECT email FROM users;");
}

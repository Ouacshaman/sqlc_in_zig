const std = @import("std");
const query = @import("pg_proto_query.zig");

//-- name: GetUsers :many
pub fn GetUsers() !void{
    try query.sendQuery(q.stream, q.allocator, "SELECT * FROM users;");
}
//-- name: GetOne :one
pub fn GetOne() !void{
    try query.sendQuery(q.stream, q.allocator, "SELECT 1;");
}
//-- name: GetUserIDs :many
pub fn GetUserIDs() !void{
    try query.sendQuery(q.stream, q.allocator, "SELECT email FROM users;");
}

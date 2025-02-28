//-- name: GetUsers :many
pub fn GetUsers :many !void{
    try query.sendQuery(q.stream, q.allocato, test);
}
//-- name: GetOne :one
pub fn GetOne :one !void{
    try query.sendQuery(q.stream, q.allocato, test);
}
//-- name: GetUserIDs :many
pub fn GetUserIDs :many !void{
    try query.sendQuery(q.stream, q.allocato, test);
}

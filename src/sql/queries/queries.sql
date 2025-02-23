-- name: GetUsers :many
SELECT * FROM users;

-- name: GetOne :one
SELECT 1;

-- name: GetUserIDs :many
SELECT email FROM users;

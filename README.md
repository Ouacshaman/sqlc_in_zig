# SQLC in Zig

It is not exactly like SQLC as it is not rewritting the sqlc code, but its more like attempting to create it from scratch. This is lacking quite a lot of the features compared to the original. It does not create structs to be return in function, return list or single structs for queries, or does it differentiates between executions and other queries for getting data or inserting data. All this does is just generate the functions that calls postgress protocol function for processing query and return a string. Which you will do your own prefer parsing.

clone this repo, then run "zig build" in the root directory to get the binary
Then Copy the following into your SRC file:

```plaintext
├── connect.zig
├── json.zig
└── postgres_protocol/
    ├── pg_proto_query.zig
    ├── pg_proto_response.zig
    └── pg_proto_startup.zig
```

Then make sure to setup this folder structure:

```plaintext
.
|
│   ├── internal/
│   │   └── database/

```

Directory so that a zig function can be generated

Then create your queries and place it in this directory:

```plaintext
│   └── sql/
│       └── queries/
│           └── queries.sql
```

You can name it queries.sql to something else if you like

Setup Database First:
create it, connect to it, then setup tables( for me I use psql)
Then use the CLI to do inserts, selects, deletes, and updates

Create Directory and file to store information in "~/.config/ziglc/config.json"
Recommend to install goose for database migration ( that is what I used)

copy and  past this in main()

```
const std = @import("std");
const Startup = @import("pg_proto_startup.zig");
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
```

these following files will need to be added to your src folder for zig:

1. pg_proto_response.zig 
2. pg_proto_startup.zig
3. pg_proto_query.zig
4. json.zig -- unless you would like to mod
5. connect.zig -- unless you would like to mod

```plaintext
.
├── src/
│   ├── connect.zig
│   ├── internal/
│   │   └── database/
│   ├── json.zig
│   ├── main.zig
│   ├── postgres_protocol/
│   │   ├── pg_proto_query.zig
│   │   ├── pg_proto_response.zig
│   │   └── pg_proto_startup.zig
│   │
│   └── sql/
│       └── queries/
│           └── queries.sql
```
## Important note: set up trusted local connections in your pg_hba.conf to avoid password prompt, this might only work for MacOs.
Once you got this structure then in your root directory outside of the src durectory and run the the bindary.

bootleg sqlc lol

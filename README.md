#Zig Cli

Setup Database First:
create it, connect to it, then setup tables( for me I use psql )
Then use the CLI to do inserts, selects, deletes, and updates

Store information in ~/.config/ziglc/config.json
Recommend to install goose for database migration
If you are building a zig project store the queries in the ./src/sql/queries/ folders



The next step:
Capture Output so it is returnable in a function
    This will have to be done in ./src/pg_proto_response.zig so that instead of printing values are returned
To do this I will have to setup an array in Handle Query function and have data returned and ignore non values such as errors or notices
Then make the stuff return first in sendquery in query messages then in public sendquery function



Items below might not be necessary
Create Zig file
Struct Generation
Function Generation

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

these following files will be added to your src folder for zig:
pg_proto_response.zig
pg_proto_startup.zig
pg_proto_query.zig
json.zig -- unless you would like to mod
connect.zig -- unless you would like to mod

bootleg sqlc lol

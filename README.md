# SQLC in Zig

This project is an attempt to create a SQLC-like tool in **Zig**, but rather than rewriting SQLC, it is built from scratch. It lacks many features compared to the original SQLC, such as:

- Struct generation for query results
- Differentiation between execution queries and data retrieval
- Automatic handling of query results (lists or single structs)

Instead, this tool **generates functions** that call PostgreSQL protocol functions for processing queries and returning raw strings. You will need to handle your own parsing.

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository
```sh
git clone https://github.com/Ouacshaman/sqlc_in_zig.git
cd sqlc_in_zig
```

### 2️⃣ Build the Binary
Run the following command:
```sh
zig build
```

### 3️⃣ Setup Your Project Structure

Copy the following **required source files** into your project:
```
├── connect.zig
├── json.zig
└── postgres_protocol/
    ├── pg_proto_query.zig
    ├── pg_proto_response.zig
    └── pg_proto_startup.zig
```

Then, ensure your **directory structure** looks like this:

```
.
├── internal/
│   └── database/
```

This structure allows the Zig function generator to work correctly.

---

## 📂 Organizing Your Queries

Create a **queries directory** and store your SQL queries inside:

```
.
└── sql/
    └── queries/
        └── queries.sql
```

> *You can rename `queries.sql` if needed.*

---

## 📌 Setting Up the Database

1. **Create & connect to your database**
2. **Define your tables** (Example: using `psql` and `goose`)
3. **Use the CLI to run queries** (INSERT, SELECT, DELETE, UPDATE)

---

## ⚙ Configuration

Create a config file to store database connection details:
```
~/.config/ziglc/config.json
```
```json
{
	"default_user": "",
	"default_database": "",
	"default_host": "",
	"default_port": ""
}
```
> **Recommendation:** Use `goose` for database migration (this project relies on it).

---

## 📝 Example Usage in `main.zig`

```zig
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

---

## 🗂 Required Source Files

The following files **must** be added to your `src/` folder:

```
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

---

## ⚠ Important Notes

### 🔹 Configure `pg_hba.conf` for Trusted Local Connections

To avoid authentication errors, update your **pg_hba.conf** file to set authentication to **trust**.

**For Homebrew Users:**
If you installed PostgreSQL via Homebrew, navigate to:
```sh
/opt/homebrew/var/postgresql@16/
```
Modify the `pg_hba.conf` file accordingly.

---

## 🏁 Running the Binary

Once your project is set up, navigate to the **root directory** (outside of `src/`) and run the binary:

```sh
./zig-out/bin/zig_sqlc
```

---

## 🎭 Bootleg SQLC

This is a **simple**, **bootstrapped** version of SQLC in Zig—without all the bells and whistles. If you need more advanced features, you’ll have to extend it yourself! 🌠🎀 awawa

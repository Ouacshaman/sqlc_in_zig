const std = @import("std");

const Config = struct {
    default_user: []const u8,
    default_database: []const u8,
    default_host: []const u8,
    default_port: []const u8,
};

pub fn readConfig(allocator: std.mem.Allocator) !Config {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arena_alloc = arena.allocator();

    const empty = Config{ .default_user = "", .default_database = "", .default_host = "", .default_port = "" };

    var env_map = try std.process.getEnvMap(arena_alloc);
    defer env_map.deinit();

    const home = env_map.get("HOME") orelse return empty;

    const config_path = try std.fmt.allocPrint(arena_alloc, "{s}/.config/ziglc/config.json", .{home});

    const file = std.fs.openFileAbsolute(config_path, .{}) catch return empty;
    defer file.close();

    const content = try file.readToEndAlloc(arena_alloc, 1024 * 1024);

    var parsed = try std.json.parseFromSlice(Config, arena_alloc, content, .{});
    defer parsed.deinit();

    return Config{
        .default_user = try allocator.dupe(u8, parsed.value.default_user),
        .default_database = try allocator.dupe(u8, parsed.value.default_database),
        .default_host = try allocator.dupe(u8, parsed.value.default_host),
        .default_port = try allocator.dupe(u8, parsed.value.default_port),
    };
}

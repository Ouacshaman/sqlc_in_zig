const std = @import("std");

const StartupMessage = struct {
    protocol_version: u32,
    parameters: [][]const u8,
    allocator: std.mem.Allocator,

    pub fn format(self: StartupMessage) ![]u8 {
        var size: usize = 8;
        for (self.parameters) |param| {
            size += param.len + 1;
        }
        size += 1;
        var buffer = try self.allocator.alloc(u8, size);

        std.mem.writeInt(u32, buffer[0..4], @as(u32, @intCast(size)), .big);
        std.mem.writeInt(u32, buffer[4..8], self.protocol_version, .big);

        var offset: usize = 8;
        for (self.parameters) |param| {
            @memcpy(buffer[offset .. offset + param.len], param);
            buffer[offset + param.len] = 0;
            offset += param.len + 1;
        }

        buffer[size - 1] = 0;

        return buffer;
    }

    pub fn deinit(self: StartupMessage, buffer: []u8) void {
        self.allocator.free(buffer);
    }
};

pub fn sendStartup(stream: std.net.Stream, allocator: std.mem.Allocator, username: ?[]const u8, database: ?[]const u8) !void {
    const proto_v: u32 = 196608;
    var params_list = try allocator.alloc([]const u8, 4);
    defer allocator.free(params_list);

    params_list[0] = "user";
    params_list[1] = username orelse return error.UsernameRequired;
    if (username.?.len == 0) return error.UsernameEmpty;
    params_list[2] = "database";
    params_list[3] = database orelse return error.DatabaseRequired;
    if (database.?.len == 0) return error.DatabaseEmpty;

    const params = StartupMessage{
        .protocol_version = proto_v,
        .parameters = params_list,
        .allocator = allocator,
    };
    const buffer = try params.format();
    defer params.deinit(buffer);

    _ = try stream.write(buffer);
}

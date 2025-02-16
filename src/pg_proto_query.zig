const std = @import("std");

const QueryMessage = struct {
    query_string: []const u8,
    allocator: std.mem.Allocator,

    pub fn format(self: QueryMessage) ![]u8 {
        const msg_type: u8 = 'Q';
        const length = 4 + self.query_string.len + 1;
        const total_size = 1 + length;

        var buffer = try self.allocator.alloc(u8, total_size);

        buffer[0] = msg_type;

        std.mem.writeInt(u32, buffer[1..5], length, .big);
        @memcpy(buffer[5..], self.query_string);
        buffer[total_size - 1] = 0;

        return buffer;
    }
    pub fn deinit(self: QueryMessage, buffer: []u8) void {
        self.allocator.free(buffer);
    }

    pub fn sendQuery(self: QueryMessage, stream: std.net.Stream) !void {
        const buffer = try self.format();
        defer self.deinit(buffer);

        try stream.write(buffer);
    }
};


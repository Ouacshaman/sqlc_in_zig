const std = @import("std");

pub const ResponseHandler = struct {
    //R
    pub fn handlerAuth(buffer: []const u8, stream: std.net.Stream, allocator: std.mem.Allocator) !void {
        if (buffer[0] != 'R') {
            return error.NotAuthMessage;
        }

        const auth_type = std.mem.readInt(u32, buffer[5..9], .big);

        switch (auth_type) {
            0 => {
                //AuthenticationOk
                std.debug.print("Authentication Successful\n", .{});
            },
            3 => {
                std.debug.print("Password: ", .{});

                var pw_buffer: [256]u8 = undefined;
                const pw = try std.io.getStdIn().reader().readUntilDelimiter(&pw_buffer, '\n');
                const total_length = 1 + 4 + pw.len + 1;
                const msg_length = 4 + pw.len + 1;

                var password_message = try allocator.alloc(u8, total_length);
                defer allocator.free(password_message);

                password_message[0] = 'p';
                std.mem.writeInt(u32, password_message[1..5], msg_length, .big);
                @memcpy(password_message[5 .. 5 + pw.len], pw);
                password_message[total_length - 1] = 0;

                try stream.write(password_message);
            },
            else => return error.UnsupportedAuthMethod,
        }
    }
    //T
    pub fn handlerRowDescription(buffer: []const u8) !void {
        std.debug.print("{s}", .{buffer});
    }
    //D
    pub fn handlerDataRow(buffer: []const u8) !void {
        std.debug.print("{s}", .{buffer});
    }
};

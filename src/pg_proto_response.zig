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
                const len_pw = std.math.cast(u32, pw.len) orelse return error.PWTooLong;
                const total_length = 1 + 4 + len_pw + 1;
                const msg_length = 4 + len_pw + 1;

                var password_message = try allocator.alloc(u8, total_length);
                defer allocator.free(password_message);

                password_message[0] = 'p';
                std.mem.writeInt(u32, password_message[1..5], msg_length, .big);
                @memcpy(password_message[5 .. 5 + pw.len], pw);
                password_message[total_length - 1] = 0;

                _ = try stream.write(password_message);
            },
            else => return error.UnsupportedAuthMethod,
        }
    }
    //S
    pub fn handleParameterStatus(buffer: []const u8) !void {
        var offset: usize = 5;

        const param_name_end = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
        const param_name = buffer[offset .. offset + param_name_end];
        std.debug.print("Parameter Name: {s}\n", .{param_name});

        offset += param_name_end + 1;

        const param_value_end = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
        const param_value = buffer[offset .. offset + param_value_end];
        std.debug.print("Parameter Value: {s}\n", .{param_value});
    }
    //K
    pub fn handleBackendKeyData(buffer: []const u8) !void {
        const process_id = buffer[5..9];
        const secret_key = buffer[9..13];
        std.debug.print("Process ID: {s}, Secret_key: {s}\n", .{ process_id, secret_key });
    }
    //Z
    pub fn handleReadyForQuery(buffer: []const u8) !void {
        const transaction_status = buffer[5];
        switch (transaction_status) {
            'I' => {
                std.debug.print("{s}\n", .{"Idle"});
            },
            'T' => {
                std.debug.print("{s}\n", .{"In Transaction"});
            },
            'E' => {
                std.debug.print("{s}\n", .{"Failed Transaction"});
            },
            else => {
                std.debug.print("Unknown: {c}\n", .{transaction_status});
            },
        }
    }
    //C
    pub fn handleCommandComplete(buffer: []const u8) !void {
        const offset: usize = 5;
        const field_name_end = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
        const command_tag = buffer[offset .. offset + field_name_end];
        std.debug.print("Command Tag: {s}", .{command_tag});
    }
    //T
    pub fn handlerRowDescription(buffer: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
        var list = std.ArrayList([]const u8).init(allocator);
        defer list.deinit();

        const field_count = std.mem.readInt(u16, buffer[5..7], .big);
        std.debug.print("Number of fields: {d}\n", .{field_count});

        var offset: usize = 7;
        var i: usize = 0;
        while (i < field_count) : (i += 1) {
            // Finds null terminator for field name
            const field_name_end = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
            const field_name = buffer[offset .. offset + field_name_end];
            std.debug.print("Field {d}: {s}\n", .{ i, field_name });
            const temp = try std.fmt.allocPrint(allocator, "Field {d}: {s}\n", .{ i, field_name });
            try list.append(temp);
            // Skip past other fields metadata
            offset += field_name_end + 1 + 18; // 18 is the size of fixed-length field metadata
        }
        std.debug.print("\n", .{});
        return try list.toOwnedSlice();
    }
    //D
    pub fn handlerDataRow(buffer: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
        var list = std.ArrayList([]const u8).init(allocator);
        defer list.deinit();

        const field_count = std.mem.readInt(u16, buffer[5..7], .big);
        std.debug.print("Number of fields; {d}\n", .{field_count});

        var offset: usize = 7;
        var i: usize = 0;
        while (i < field_count) : (i += 1) {
            const field_length = std.mem.readInt(u32, @as(*const [4]u8, @ptrCast(buffer[offset .. offset + 4])), .big);
            offset += 4;

            if (field_length == 0xFFFFFFFF) {
                std.debug.print("Field {d}: NULL\n", .{i});
            } else {
                const field_value = buffer[offset .. offset + field_length];
                std.debug.print("Field {d}: {s}\n", .{ i, field_value });
                const temp = try std.fmt.allocPrint(allocator, "Field {d}: {s}\n", .{ i, field_value });
                try list.append(temp);
                offset += field_length;
            }
        }
        return try list.toOwnedSlice();
    }
    //E
    pub fn handlerErrorResponse(buffer: []const u8) !void {
        const offset: usize = 5;
        const end_of_error = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
        const err = buffer[offset .. offset + end_of_error];
        std.debug.print("Error: {s}", .{err});
    }
    //N
    pub fn handlerNoticeResponse(buffer: []const u8) !void {
        const offset: usize = 5;
        const end_of_notice = std.mem.indexOfScalar(u8, buffer[offset..], 0) orelse return error.MalformedMessage;
        const notice = buffer[offset .. offset + end_of_notice];
        std.debug.print("Error: {s}", .{notice});
    }
};

pub fn readAuthResponse(stream: std.net.Stream, allocator: std.mem.Allocator) ![]u8 {
    var header_buf: [5]u8 = undefined;
    _ = try stream.read(header_buf[0..]);

    if (header_buf[0] != 'R') {
        return error.NotAuthMessage;
    }

    const msg_len = std.mem.readInt(u32, header_buf[1..5], .big);

    var buffer = try allocator.alloc(u8, msg_len + 1);
    errdefer allocator.free(buffer);

    @memcpy(buffer[0..5], &header_buf);

    _ = try stream.read(buffer[5..]);

    return buffer;
}

pub fn handleQuery(stream: std.net.Stream, allocator: std.mem.Allocator) ![]const u8 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const gpalloc = gpa.allocator();

    var list = std.ArrayList(u8).init(gpalloc);
    defer list.deinit();
    try list.appendSlice("---start---\n");

    var type_buf: [1]u8 = undefined;
    while (true) {
        _ = try stream.read(type_buf[0..]);

        var len_buf: [4]u8 = undefined;
        _ = try stream.read(len_buf[0..]);
        const msg_len = std.mem.readInt(u32, len_buf[0..4], .big);

        var buffer = try allocator.alloc(u8, msg_len + 1);
        defer allocator.free(buffer);

        buffer[0] = type_buf[0];
        @memcpy(buffer[1..5], &len_buf);

        _ = try stream.read(buffer[5..]);

        switch (type_buf[0]) {
            'S' => {
                try ResponseHandler.handleParameterStatus(buffer);
            },
            'K' => {
                try ResponseHandler.handleBackendKeyData(buffer);
            },
            'Z' => {
                try ResponseHandler.handleReadyForQuery(buffer);
            },
            'T' => {
                const rd = try ResponseHandler.handlerRowDescription(buffer, gpalloc);
                defer {
                    for (rd) |item| {
                        gpalloc.free(item);
                    }
                    gpalloc.free(rd);
                }
                for (rd) |item| {
                    try list.appendSlice(item);
                }
            },
            'D' => {
                const dr = try ResponseHandler.handlerDataRow(buffer, gpalloc);
                defer {
                    for (dr) |item| {
                        gpalloc.free(item);
                    }
                    gpalloc.free(dr);
                }
                for (dr) |item| {
                    try list.appendSlice(item);
                }
            },
            'E' => {
                try ResponseHandler.handlerErrorResponse(buffer);
            },
            'N' => {
                try ResponseHandler.handlerNoticeResponse(buffer);
            },
            'C' => {
                try ResponseHandler.handleCommandComplete(buffer);
                break;
            },
            else => {
                std.debug.print("Unexpected message type: {c}\n", .{type_buf[0]});
            },
        }
    }
    try list.appendSlice("\n---end---");

    const joined = try list.toOwnedSlice();
    defer gpalloc.free(joined);
    const res = try allocator.dupe(u8, joined);

    return res;
}

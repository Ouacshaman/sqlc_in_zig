const std = @import("std");

pub const ResponseHandler = struct {
    //R
    pub fn handlerAuth(buffer: []const u8) !void {
        std.debug.print("{s}", .{buffer});
        if (std.mem.eql([]const u8, buffer[0], "R") == false) {
            return error.FailedAuth;
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

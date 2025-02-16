const std = @import("std");

pub const ResponseHandler = struct {
    //Q
    pub fn handlerQuery(buffer: []const u8) !void {
        std.debug.print("{s}", .{buffer});
    }
    //R
    pub fn handlerAuth(buffer: []const u8) !void {
        std.debug.print("{s}", .{buffer});
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

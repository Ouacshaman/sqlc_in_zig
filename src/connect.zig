const std = @import("std");

pub fn connect(host: []const u8, port: u16) !std.net.Stream {
    const addr = try std.net.Address.resolveIp(host, port);
    return try std.net.tcpConnectToAddress(addr);
}

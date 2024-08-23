const std = @import("std");

pub fn prompt(allocator: std.mem.Allocator, msg: []const u8) ![]const u8 {
    const in = std.io.getStdIn().reader();
    var value: []const u8 = undefined;
    errdefer allocator.free(value);
    std.debug.print("\x1B[1;32m?\x1B[0m {s} ", .{msg});
    while (true) {
        var input: []const u8 = try in.readUntilDelimiterAlloc(allocator, '\n', 1024);
        input = std.mem.trimRight(u8, input, "\r\n");
        if (input.len > 0) {
            value = input;
            break;
        }
    }
    return value;
}

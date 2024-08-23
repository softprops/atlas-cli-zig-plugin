const std = @import("std");
const args = @import("args.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const opts = try args.parse(allocator);
    defer opts.deinit();

    if (opts.options.help) {
        help();
        return;
    }
    if (opts.verb) |verb| {
        try switch (verb) {
            .hello => hello(),
            .printenv => printenv(allocator),
            .stdinreader => stdinreader(allocator),
        };
    } else {
        help();
    }
}

fn help() void {
    std.debug.print("Available Commands: hello, printenv, or stdinreader\n", .{});
}

fn hello() !void {
    std.debug.print("Hello zig ⚡!\n", .{});
}

fn printenv(allocator: std.mem.Allocator) !void {
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();
    var it = env.iterator();
    std.debug.print("Environment variables:\n", .{});
    while (it.next()) |entry| {
        std.debug.print("\t- {s}={s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}

fn stdinreader(allocator: std.mem.Allocator) !void {
    const name = try @import("./prompt.zig").prompt(allocator, "Please enter your name");
    defer allocator.free(name);

    std.debug.print("Hello, {s}!\n", .{name});
}

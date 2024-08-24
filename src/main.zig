const std = @import("std");
const args = @import("args.zig");
const tomlz = @import("tomlz");
const config = @import("config.zig");

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
            .echo => echo(allocator),
            .hello => hello(),
            .printenv => printenv(allocator),
            .stdinreader => stdinreader(allocator),
            .listprofiles => listProfiles(allocator),
        };
    } else {
        try @import("args").printHelp(args.Common, "zig-example", std.io.getStdOut().writer());
    }
}

fn echo(allocator: std.mem.Allocator) !void {
    var in = try std.process.argsWithAllocator(allocator);
    defer in.deinit();
    for (0..3) |_| _ = in.skip();
    while (in.next()) |arg| std.debug.print("{s} ", .{arg});
}

fn help() void {
    std.debug.print("Available Commands: echo, hello, printenv, or stdinreader\n", .{});
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

fn listProfiles(allocator: std.mem.Allocator) !void {
    if (try config.profileNames(allocator)) |names| {
        var namesMut = names;
        defer namesMut.deinit();
        std.debug.print("PROFILE NAME\n", .{});
        while (namesMut.next()) |name| {
            std.debug.print("{s}\n", .{name});
        }
    }
}

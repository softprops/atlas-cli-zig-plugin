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
        try args.printHelp(std.io.getStdOut().writer());
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
        try args.printHelp(std.io.getStdOut().writer());
    }
}

fn echo(allocator: std.mem.Allocator) !void {
    var in = try std.process.argsWithAllocator(allocator);
    defer in.deinit();
    for (0..3) |_| _ = in.skip();
    while (in.next()) |arg| std.debug.print("{s} ", .{arg});
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
    var names = try config.profileNames(allocator) orelse {
        return;
    };
    defer names.deinit();
    std.debug.print("PROFILE NAME\n", .{});
    while (names.next()) |name| {
        std.debug.print("{s}\n", .{name});
    }
}

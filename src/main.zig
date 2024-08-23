const std = @import("std");
const parseArgs = @import("args").parseWithVerb;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // program name
    _ = args.skip(); // atlas-provided root command name

    const opts = try parseArgs(
        struct {
            help: bool = false,
            pub const shorthands = .{ .h = "help" };
        },
        union(enum) {
            hello: void,
            printenv: void,
            stdinreader: void,
        },
        &args,
        allocator,
        .print,
    );
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
    std.debug.print("Hello world!\n", .{});
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

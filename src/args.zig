const std = @import("std");
const parseArgs = @import("args").parseWithVerb;
const ParseArgsResult = @import("args").ParseArgsResult;

pub const Common = struct {
    help: bool = false,
    pub const shorthands = .{ .h = "help" };
    pub const meta = .{
        .name = "zig-example",
        .full_text = "Root command of the zig atlas cli plugin example",
        .usage_summary = "[--help]",
        .option_docs = .{
            .help = "show this message",
        },
    };
};

const Commands = union(enum) {
    echo: void,
    hello: void,
    printenv: void,
    stdinreader: void,
    listprofiles: void,
};

pub fn parse(allocator: std.mem.Allocator) !ParseArgsResult(Common, Commands) {
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // program name
    _ = args.skip(); // atlas-provided root command name

    return try parseArgs(
        Common,
        Commands,
        &args,
        allocator,
        .print,
    );
}

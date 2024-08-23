const std = @import("std");
const parseArgs = @import("args").parseWithVerb;
const ParseArgsResult = @import("args").ParseArgsResult;

const Common = struct {
    help: bool = false,
    pub const shorthands = .{ .h = "help" };
};

const Commands = union(enum) {
    hello: void,
    printenv: void,
    stdinreader: void,
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

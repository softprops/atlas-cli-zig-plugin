const std = @import("std");
const parseArgs = @import("args").parseWithVerb;
const ParseArgsResult = @import("args").ParseArgsResult;

pub const Common = struct {
    help: bool = false,
    pub const shorthands = .{ .h = "help" };
    pub const meta = .{
        .name = "zig-example",
        .full_text = "Root command of the zig atlas cli plugin example",
        .usage_summary = "<command> [flags]",
        .option_docs = .{
            .help = "show this message",
        },
    };
};

const Commands = union(enum) {
    echo: struct {
        pub const meta = .{ .full_text = "Echos the input args" };
    },
    hello: struct {
        pub const meta = .{ .full_text = "The Hello World command" };
    },
    printenv: struct {
        pub const meta = .{ .full_text = "Prints environment variables" };
    },
    stdinreader: struct {
        pub const meta = .{ .full_text = "Reads name and prints it" };
    },
    listprofiles: struct {
        pub const meta = .{ .full_text = "Return a list of available profiles by name" };
    },
};

pub fn printHelp(writer: anytype) !void {
    try @import("args").printHelp(Common, "zig-example", writer);
    try writer.writeAll("\nAvailable Commands:\n");
    const maxLen = comptime blk: {
        var max = 0;
        for (@typeInfo(Commands).Union.fields) |fld| {
            max = @max(max, fld.name.len);
        }
        break :blk std.fmt.comptimePrint("{d}", .{max});
    };
    inline for (@typeInfo(Commands).Union.fields) |fld| {
        std.debug.print("  {s:<" ++ maxLen ++ "}", .{fld.name});
        if (@hasDecl(fld.type, "meta")) {
            const Meta = @TypeOf(fld.type.meta);
            if (@hasField(Meta, "full_text")) {
                try writer.print("\t{s}", .{fld.type.meta.full_text});
            }
        }
        std.debug.print("\n", .{});
    }
}

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

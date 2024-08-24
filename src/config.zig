const std = @import("std");
const tomlz = @import("tomlz");

pub const ProfileNames = struct {
    arena: std.heap.ArenaAllocator,
    iter: std.StringHashMapUnmanaged(tomlz.parser.Value).KeyIterator,

    fn init(allocator: std.mem.Allocator) !?@This() {
        var arena = std.heap.ArenaAllocator.init(allocator);
        errdefer arena.deinit();
        const dir = std.fs.getAppDataDir(arena.allocator(), "atlascli") catch {
            return null;
        };
        const path = std.fs.path.join(arena.allocator(), &.{ dir, "config.toml" }) catch {
            return null;
        };
        const file = std.fs.openFileAbsolute(path, .{ .mode = .read_only }) catch {
            return null;
        };
        const bytes = try file.readToEndAlloc(arena.allocator(), 1024 * 1024 * 4);
        return .{
            .iter = (try tomlz.parse(arena.allocator(), bytes)).table.keyIterator(),
            .arena = arena,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.arena.deinit();
    }

    pub fn next(self: *@This()) ?[]const u8 {
        if (self.iter.next()) |name| {
            return name.*;
        }
        return null;
    }
};

/// Returns an iterator over config profile names
pub fn profileNames(allocator: std.mem.Allocator) !?ProfileNames {
    return try ProfileNames.init(allocator);
}

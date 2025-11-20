const std = @import("std");

const Position = struct {
    x: u32,
    y: u32,
    sequence: []u8,
    alloc: std.mem.Allocator,
    const Self = @This();

    pub fn init(alloc: std.mem.Allocator, capacity: usize) !Position {
        const seq_len = try alloc.alloc(u8, capacity);
        return .{
            .x = 0,
            .y = 0,
            .sequence = seq_len,
            .alloc = alloc,
        };
    }

    pub fn deinit(self: *Position) void {
        self.alloc.free(self.sequence);
    }

    // Time complexity: O(n) where n is length of sequence
    // Space complexity: O(1) as map stores max 4 directions
    pub fn finalPosition(self: *Position, stack: []const u8) !void {
        @memcpy(self.sequence, stack);
        std.debug.print("Sequence {s}\n", .{self.sequence});

        var pos = std.hash_map.AutoHashMap(u8, u32).init(self.alloc);
        defer pos.deinit();

        for (self.sequence) |s| {
            const gop = try pos.getOrPut(s);
            if (!gop.found_existing) {
                gop.value_ptr.* = 1;
            } else {
                gop.value_ptr.* += 1;
            }
        }
        // If you know that the HashMap will always have at least 0 you can use .? otherwise use orelse 0
        self.x = (pos.get('R').?) - (pos.get('L') orelse 0);
        self.y = (pos.get('U') orelse 0) - (pos.get('D').?);
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    const seq = [_]u8{ 'U', 'R', 'L', 'D', 'U', 'U', 'R', 'R', 'R' };

    var position = try Position.init(alloc, seq.len);
    defer position.deinit();

    _ = try position.finalPosition(&seq);

    std.debug.print("Final position {d},{d}", .{ position.x, position.y });
}

const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        match: std.AutoArrayHashMap(T, T),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Stack(T) {
            return .{
                .items = try allocator.alloc(T, 5),
                .allocator = allocator,
                .match = std.AutoArrayHashMap(T, T).init(allocator),
            };
        }

        pub fn pop(self: *Stack(T)) T {
            const elem = self.items[self.items.len];
            self.items = self.items[self.items.len - 1];
            return elem;
        }
        pub fn isValid(self: *Stack(T), input: []const T) bool {
            for (input) |byte| {
                if (self.match.get(byte)) |e| {
                    self.items[self.items.len] = e;
                } else {}
            }
        }

        pub fn deinit(self: *Stack(T)) void {
            self.match.deinit();
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    const input = &[_]u8{ '{', '(', '[', ']', ')', '}' };
    var stack = Stack(u8).init(allocator, input);
    defer stack.deinit();
    try stack.match.put('(', ')');
    try stack.match.put('[', ']');
    try stack.match.put('{', '}');
}

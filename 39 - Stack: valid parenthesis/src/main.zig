const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        items: std.ArrayList(T),
        match: std.AutoArrayHashMap(T, T),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) !Stack(T) {
            return .{
                .items = try std.ArrayList(T).initCapacity(allocator, 0),
                .allocator = allocator,
                .match = std.AutoArrayHashMap(T, T).init(allocator),
            };
        }

        pub fn pop(self: *Stack(T)) T {
            const elem = self.items.pop().?;
            std.debug.print("Element : {d}\n", .{elem});
            return elem;
        }

        pub fn isValid(self: *Stack(T), input: []const T) !bool {
            for (input) |byte| {
                if (self.match.get(byte)) |e| {
                    std.debug.print("Pushing {any}\n", .{e});
                    try self.items.append(self.allocator, e);
                } else {
                    std.debug.print("Popping {any}\n", .{byte});
                    if (self.match.get(self.pop()) != byte) {
                        return false;
                    }
                }
            }
            return true;
        }

        pub fn deinit(self: *Stack(T)) void {
            self.items.deinit(self.allocator);
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
    std.debug.print("Input : {any}\n", .{input});
    var stack = try Stack(u8).init(allocator);
    defer stack.deinit();
    try stack.match.put('(', ')');
    try stack.match.put('[', ']');
    try stack.match.put('{', '}');
    const result = stack.isValid(input);
    std.debug.print("Result : {any}\n", .{result});
}

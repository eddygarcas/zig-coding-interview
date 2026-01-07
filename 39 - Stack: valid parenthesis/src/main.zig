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
        // isValid checks if the input sequence contains valid matching pairs
        // Returns true if all elements match correctly according to the match map
        // Basically gets the counterpart of the current character and later compares the next
        // character with the one on top of the stack, if all of them checks then it's a valid string.
        pub fn isValid(self: *Stack(T), input: []const T) !bool {
            for (input) |byte| {
                if (self.match.get(byte)) |_| {
                    std.debug.print("Pushing {c}\n", .{byte});
                    try self.items.append(self.allocator, byte);
                } else {
                    std.debug.print("Popping {c}\n", .{byte});
                    const item = self.items.pop().?;
                    if (self.match.get(item) != byte) {
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
    std.debug.print("Input : {s}\n", .{input});
    var stack = try Stack(u8).init(allocator);
    defer stack.deinit();
    try stack.match.put('(', ')');
    try stack.match.put('[', ']');
    try stack.match.put('{', '}');
    const result = stack.isValid(input);
    std.debug.print("Result : {any}\n", .{result});
}

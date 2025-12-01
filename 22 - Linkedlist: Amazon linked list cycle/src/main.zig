const std = @import("std");

const Entry = struct {
    value: ?usize = null,
    next: ?*Entry = null,
};

fn ListNode() type {
    return struct {
        item: Entry,
        allocator: std.mem.Allocator,

        const Self = @This();

        fn init(allocator: std.mem.Allocator, value: ?usize, next: ?*Entry) !Self {
            return .{
                .item = .{
                    .value = value,
                    .next = next,
                },
                .allocator = allocator,
            };
        }
        fn set(self: *Self, next: ?*Entry) bool {
            self.item.next = next;
            return next != null;
        }
    };
}

// main demonstrates the Floyd's cycle detection algorithm (Tortoise and Hare)
// by creating a linked list with a cycle and checking for a cycle's entry point.
// Also that recursive functions are way faster than tha loop to resolve this challenge
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }
    var first_item = try ListNode().init(allocator, null, null);
    std.debug.print("first element {?d}\n", .{first_item.item.value});

    switch (first_item.set(null)) {
        true => {
            std.debug.print("Insert", .{});
        },
        else => {
            std.debug.print("No element", .{});
        },
    }
}

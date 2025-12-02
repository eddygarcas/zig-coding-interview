const std = @import("std");

const Entry = struct {
    value: ?usize = null,
    next: ?*Entry = null,
    const Self = @This();

    fn init(self: *Self, value: ?usize, next: ?*Entry) void {
        self.value = value;
        self.next = next;
    }
};

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

    var node1 = try allocator.create(Entry);

    const head = node1;
    var cycle = node1;

    // Create a cycle list where last node will point to the thrird node.
    for (0..8) |i| {
        const node = try allocator.create(Entry);
        node.init(i, null);
        node1.next = node;
        switch (i) {
            3 => {
                cycle = node;
                node1 = node;
            },
            7 => {
                node1 = cycle;
            },
            else => {
                node1 = node;
            },
        }
    }

    // becuase we've create a cycle list will have to check visited nodes to avoid deallocate twice.
    destroyNodes(allocator, head);
}

fn destroyNodes(allocator: std.mem.Allocator, head: *Entry) void {
    var visited = std.AutoHashMap(*Entry, void).init(allocator);
    defer visited.deinit();

    var cur: ?*Entry = head;
    while (cur) |node| {
        if (visited.contains(node)) break;
        visited.put(node, {}) catch return;

        const next = node.next;
        allocator.destroy(node);

        cur = next;
    }
}

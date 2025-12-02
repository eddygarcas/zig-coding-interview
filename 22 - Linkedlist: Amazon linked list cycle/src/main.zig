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
// Also that recursive functions are not guaranteed to be faster in Zig, as recursive calls are added to the stack.
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
            },
            7 => {
                node.next = cycle;
            },
            else => {},
        }
        node1 = node;
    }

    const result = floydAlg(head);
    std.debug.print("Floyd Algorithm result {?d}\n", .{result.pos});
    // becuase we've create a cycle list will have to check visited nodes to avoid deallocate twice.
    destroyNodes(allocator, head);
}

// floydAlg implements Floyd's cycle detection algorithm (Tortoise and Hare).
// It takes two pointers (tortoise and hare) and checks for a cycle in the linked list.
// Returns the value at the node where the cycle is detected and true if a cycle exists,
// otherwise returns 0 and false.
fn floydAlg(node: *Entry) struct { result: bool, pos: ?usize } {
    var head: ?*Entry = node;
    var tail: ?*Entry = node;

    while (head != null and head.?.next != null) {
        head = head.?.next.?.next;
        tail = tail.?.next;
        std.debug.print("Values {?d} {?d}\n", .{ head.?.value, tail.?.value });
        if (tail == head) return .{ .result = true, .pos = tail.?.value };
    }
    return .{ .result = false, .pos = 0 };
}

// Will destroy the nodes taking care of the fact that its a cycle list, and avoid double deallocate.
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

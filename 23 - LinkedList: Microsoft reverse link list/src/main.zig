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

// reverseList reverses a singly linked list in-place.
// Takes the head of the list and returns the new head after reversal.
// Prints the value of each node as it is processed.
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var node1 = try allocator.create(Entry);
    const head = node1;

    // Create a cycle list where last node will point to the thrird node.
    for (0..8) |i| {
        const node = try allocator.create(Entry);
        node.init(i, null);
        node1.next = node;
        node1 = node;
    }

    const result = reveseList(head);
    std.debug.print("Result: {?d}\n", .{result.?.value});
    destroyNodes(allocator, result.?);
}

// reverseList reverses a singly linked list in-place.
// Takes the head of the list and returns the new head after reversal.
// Prints the value of each node as it is processed.
fn reveseList(head: *Entry) ?*Entry {
    var prev: ?*Entry = null;
    var current: ?*Entry = head;

    while (current) |node| {
        // Store the next node in the list before updating the current node's next pointer
        const nextNode = node.next;
        // Reverse the link between the current node and the previous node
        current.?.next = prev;
        //Update the prev node pointer
        prev = current;
        // Move to the next node in the list
        current = nextNode;
    }
    // Return the new head
    return prev;
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

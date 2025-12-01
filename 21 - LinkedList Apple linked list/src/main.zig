const std = @import("std");
// Package main implements a solution for merging two sorted linked lists.
// This is a common interview problem that tests understanding of linked list operations.

const ListNode = struct {
    value: usize,
    next: ?*ListNode = null,

    const Self = @This();

    fn init(self: *Self, value: usize, next: ?*Self) void {
        self.value = value;
        self.next = next;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    // Will allocate 4 LiseNode on both lists
    var list_1 = try allocator.alloc(ListNode, 4);
    defer allocator.free(list_1);
    var list_2 = try allocator.alloc(ListNode, 4);
    defer allocator.free(list_2);

    for (list_1, 0..) |*elem, i| {
        const next_ptr = if (i + 1 < list_1.len) &list_1[i + 1] else null;
        elem.init(i, next_ptr);
    }

    for (list_2, list_1.len.., 0..) |*elem, i, pos| {
        const next_ptr = if (pos + 1 < list_2.len) &list_2[pos + 1] else null;
        elem.init(i, next_ptr);
    }

    // Will allocate the head pointer to the first element of the final list
    var head = try allocator.create(ListNode);
    head.init(0, null);
    defer allocator.destroy(head);

    var cur: *ListNode = head;
    var ans = cur;

    var l_1: ?*ListNode = &list_1[0];
    var l_2: ?*ListNode = &list_2[0];

    // Merge the two lists by comparing values and linking nodes in sorted order
    // Continue until we've processed all nodes from both lists
    while (l_1 != null or l_2 != null) {
        // we don't need l_1.?.*.value as Zig is doing the dereference for us.
        if (l_1 == null or (l_2 != null and l_1.?.value > l_2.?.value)) {
            cur.next = l_2;
            l_2 = l_2.?.next;
        } else {
            cur.next = l_1;
            l_1 = l_1.?.next;
        }
        // Move the current pointer forward in the result list
        cur = cur.next.?;
    }

    while (ans.next != null) {
        std.debug.print(" {d}", .{ans.next.?.value});
        ans = ans.next.?;
    }
}

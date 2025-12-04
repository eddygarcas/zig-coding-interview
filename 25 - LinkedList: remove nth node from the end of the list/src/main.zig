const std = @import("std");

const Entry = struct {
    value: usize = 0,
    next: ?*Entry = null,
    const Self = @This();

    fn init(self: *Self, value: usize, next: ?*Entry) void {
        self.value = value;
        self.next = next;
    }
    // removeNthNode removes the nth node from the end of the singly linked list.
    // This is a method on the ListNode type.
    // Parameters:
    // n: The position from the end (1-based index)
    // Modifies the list in place. No return value.
    pub fn removeNthNode(self: *Self, allocator: std.mem.Allocator, i: usize) !void {
        // temp is used to count the total number of nodes in the list

        var temp: ?*Entry = self;

        var total: usize = 0;
        // First pass: count the total number of nodes in the list
        // Traverse the list to get the total count of nodes
        while (temp) |elem| {
            total += 1;
            temp = elem.next;
        }
        std.debug.print("Capacity {d}\n", .{total});
        if (i > total) {
            return error.Nth_Element_Out_Of_Range;
        }

        const target_index = total - i;
        // Second pass: move to the node just before the one to remove
        // We subtract n+1 from the total count to get the position from the start
        // Traverse the list to get to the node before the one to remove
        var cur: *Entry = self;
        for (0..(target_index - 1)) |_| {
            cur = cur.next.?;
        }
        //         to_remove
        //            |
        //            v
        // 1 → 2 → 3     5 → null
        //          \   /
        //           \ /
        //            X   (4 is now isolated)

        // Create a pointer to the node to remove
        const to_remove = cur.next.?;

        // By pass the cur.next node to point to the next node from to_remove
        cur.next = to_remove.next;

        // Just need to deallocate the node to remove
        to_remove.deinit(allocator);
    }
    // Will destroy the nodes taking care of the fact that its a cycle list, and avoid double deallocate.
    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        var visited = std.AutoHashMap(*Entry, void).init(allocator);
        defer visited.deinit();

        var cur: ?*Entry = self;
        while (cur) |node| {
            if (visited.contains(node)) break;
            visited.put(node, {}) catch return;

            const next = node.next;
            allocator.destroy(node);

            cur = next;
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var sum1 = try allocator.create(Entry);
    sum1.* = .{ .value = 1, .next = null };
    const head1 = sum1;
    defer head1.deinit(allocator);

    var node = try allocator.create(Entry);
    node.init(2, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(3, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(4, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(5, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(6, null);
    sum1.next = node;
    sum1 = node;

    head1.removeNthNode(allocator, 15) catch |err| {
        std.debug.print("Error {s}\n", .{@errorName(err)});
    };

    var put: ?*Entry = head1;
    while (put) |elem| {
        std.debug.print(" {d}", .{elem.value});
        put = elem.next;
    }
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

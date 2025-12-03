const std = @import("std");

const Entry = struct {
    value: usize = 0,
    next: ?*Entry = null,
    const Self = @This();

    fn init(self: *Self, value: usize, next: ?*Entry) void {
        self.value = value;
        self.next = next;
    }
};
// Adds two numbers represented as reversed linked lists.
// Each node contains a single digit (0–9), and the least significant digit
// is stored first (e.g., 342 → 2 → 4 → 3).
//
// Returns a new linked list representing the sum in the same reversed format.
// Example:
//   L1: 2 → 4 → 3   (342)
//   L2: 5 → 6 → 4   (465)
//   Out: 7 → 0 → 8  (807)
//
// Assumes no cycles in input lists. Caller must free the returned list.
// May return allocator errors.
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    // Build L1 = 2 → 4 → 3
    var sum1 = try allocator.create(Entry);
    sum1.* = .{ .value = 2, .next = null };
    const head1 = sum1;

    var node = try allocator.create(Entry);
    node.init(4, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(3, null);
    sum1.next = node;

    // Build L2 = 5 → 6 → 4
    var sum2 = try allocator.create(Entry);
    sum2.* = .{ .value = 5, .next = null };
    const head2 = sum2;

    node = try allocator.create(Entry);
    node.init(6, null);
    sum2.next = node;
    sum2 = node;

    node = try allocator.create(Entry);
    node.init(4, null);
    sum2.next = node;

    const result = try addTwoNumber(allocator, head1, head2);
    std.debug.print("Result: {d}\n", .{result});
    destroyNodes(allocator, head1);
    destroyNodes(allocator, head2);
}

// addTwoNumber adds two numbers represented by linked lists.
// Each node contains a single digit. Digits are stored in reverse order.
// Returns the sum as a new linked list in the same format.
fn addTwoNumber(allocator: std.mem.Allocator, sum1: ?*Entry, sum2: ?*Entry) !usize {
    const dummy = try allocator.create(Entry);
    // Will de-allocate the dummy nodes here calling destroyNodes() using defer.
    defer destroyNodes(allocator, dummy);

    dummy.* = .{ .value = 0, .next = null };

    var ans: *Entry = dummy;
    var carry: usize = 0;
    var sum: usize = 0;

    var t = sum1;
    var b = sum2;

    while (t != null or b != null) {
        sum = carry;
        if (t) |n| {
            std.debug.print("Node value = {d}\n", .{n.value});
            sum += n.value;
            t = n.next;
        }
        if (b) |n| {
            std.debug.print("Node value = {d}\n", .{n.value});
            sum += n.value;
            b = n.next;
        }
        var next = try allocator.create(Entry);
        next.init(@mod(sum, 10), null);

        carry = sum / 10;
        ans.next = next;
        ans = ans.next.?;
    }

    if (carry > 0) {
        var next = try allocator.create(Entry);
        next.init(carry, null);
        ans.next = next;
    }
    const result = dummy.next.?.value;
    return result;
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

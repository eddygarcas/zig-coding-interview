const std = @import("std");

const Entry = struct {
    value: usize = 0,
    next: ?*Entry = null,
    const Self = @This();

    fn init(self: *Self, value: usize, next: ?*Entry) void {
        self.value = value;
        self.next = next;
    }
    // oddEvenList rearranges the list so that all odd-indexed nodes are grouped together
    // followed by all even-indexed nodes. The operation is performed in-place.
    // Example: 1->2->3->4->5 becomes 1->3->5->2->4
    pub fn oddEvenList(self: *Self) void {
        var odds = self;
        var evens: ?*Entry = odds.next;
        const evenList = evens;

        while (evens) |even| {
            odds.next = even.next;
            odds = odds.next.?;

            even.next = odds.next;
            evens = even.next;
        }
        odds.next = evenList;
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
    sum1.* = .{ .value = 5, .next = null };
    const head1 = sum1;
    defer head1.deinit(allocator);

    var node = try allocator.create(Entry);
    node.init(2, null);
    sum1.next = node;
    sum1 = node;

    node = try allocator.create(Entry);
    node.init(1, null);
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

    head1.oddEvenList();

    var put: ?*Entry = head1;
    while (put) |elem| {
        std.debug.print(" {d}", .{elem.value});
        put = elem.next;
    }
}

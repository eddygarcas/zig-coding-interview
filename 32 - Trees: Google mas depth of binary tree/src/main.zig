const std = @import("std");

pub fn TreeMap(comptime V: type) type {
    return struct {
        value: V,
        left: ?*Self = null,
        right: ?*Self = null,
        allocator: std.mem.Allocator,

        const Self = @This();

        fn init(allocator: std.mem.Allocator, value: V) *Self {
            const node = allocator.create(Self) catch @panic("Error");
            node.* = .{
                .allocator = allocator,
                .value = value,
                .left = null,
                .right = null,
            };
            return node;
        }

        // depthOfBinaryTree calculates the maximum depth of a binary tree recursively
        // Returns 0 for empty tree, otherwise returns max depth of left or right subtree + 1
        // Again for this case we are going to use the queue approach rather than the recursivety.
        pub fn depthOfBinaryTree(self: *Self) !usize {
            var queue = try std.ArrayList(?*Self).initCapacity(self.allocator, 5);
            defer queue.deinit(self.allocator);

            try queue.append(self.allocator, self);

            var depth: usize = 0;
            while (queue.items.len > 0) {
                const count = queue.items.len;
                depth += 1;

                var i: usize = 0;
                while (i < count) : (i += 1) {
                    const node = queue.pop().?;
                    if (node.?.left) |l| try queue.append(self.allocator, l);
                    if (node.?.right) |r| try queue.append(self.allocator, r);
                }
            }
            return depth;
        }

        // sumPath using queue checks if there exists a root-to-leaf path summing to target
        // Returns true if such a path exists, false otherwise
        pub fn sumPath(self: *Self, target: usize) !bool {
            var queue = try std.ArrayList(struct {
                node: ?*Self,
                sum: usize,
            }).initCapacity(self.allocator, 5);
            defer queue.deinit(self.allocator);

            try queue.append(self.allocator, .{
                .node = self,
                .sum = target,
            });

            while (queue.pop()) |elem| {
                const node = elem.node;

                if (node == null) {
                    if (elem.sum == 0) return true;
                    continue;
                }

                const sum = elem.sum - node.?.value;

                try queue.append(self.allocator, .{
                    .node = node.?.left,
                    .sum = sum,
                });

                try queue.append(self.allocator, .{
                    .node = node.?.right,
                    .sum = sum,
                });
            }
            return false;
        }

        // sumPathRec recursively checks if there exists a root-to-leaf path summing to target
        // Returns true if such a path exists, false otherwise
        pub fn sumPathRec(self: ?*Self, target: usize) bool {
            if (self == null) return false;

            const node = self.?;
            const new_target = target - node.value;

            // leaf
            if (node.left == null and node.right == null)
                return new_target == 0;

            return sumPathRec(node.left, new_target) or
                sumPathRec(node.right, new_target);
        }

        // You can pass *TreeMap(V) or *Self will work either way
        pub fn deinit(self: *TreeMap(V)) void {
            if (self.left) |l| l.deinit();
            if (self.right) |r| r.deinit();
            self.allocator.destroy(self);
        }
    };
}

// main creates a sample binary tree and calculates its maximum depth
pub fn main() !void {
    const treeDrawing =
        \\ Binary tree:
        \\        2
        \\      /   \
        \\     4     7
        \\          / \
        \\         12  15
        \\        /    /
        \\       20   18
        \\        \
        \\        28
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    // root = 2
    var root = TreeMap(usize).init(allocator, 2);
    defer root.deinit();

    // level 1
    root.left = TreeMap(usize).init(allocator, 4);
    root.right = TreeMap(usize).init(allocator, 7);

    // level 2 (right subtree)
    root.right.?.left = TreeMap(usize).init(allocator, 12);
    root.right.?.right = TreeMap(usize).init(allocator, 15);

    // level 3
    root.right.?.left.?.left = TreeMap(usize).init(allocator, 20);
    root.right.?.right.?.left = TreeMap(usize).init(allocator, 18);

    // level 4
    root.right.?.left.?.left.?.right = TreeMap(usize).init(allocator, 28);

    const result = try root.depthOfBinaryTree();
    std.debug.print("{s}\n", .{treeDrawing});
    std.debug.print("Depth of binary tree: {d}\n", .{result});

    const sumpath = try root.sumPath(69);
    std.debug.print("Sum path: {}\n", .{sumpath});
    const sumpathRec = root.sumPathRec(69);
    std.debug.print("Sum path recursively: {}\n", .{sumpathRec});
}

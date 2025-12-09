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

        // This program finds the lowest common ancestor (LCA) of two nodes in a binary tree.
        // The LCA is the lowest node in the tree that has both nodes as descendants.
        // It uses a recursive depth-first search approach, we won't use queue/stack apporach as in this case
        // it's worst in terms of performance.
        // lcanode finds the lowest common ancestor of two nodes with values p and q in the binary tree
        // Returns the LCA node if found, nil otherwise
        // Uses post-order traversal where:
        // - If current node matches either value, return it
        // - Recursively search left and right subtrees
        // - If both subtrees return non-nil, current node is LCA
        // - If one subtree returns nil, return the non-nil subtree result
        pub fn lcanode(self: ?*Self, p: usize, q: usize) ?*Self {
            if (self == null) return null;

            if (self.?.value == p or self.?.value == q) return self;

            const left: ?*Self = if (self.?.left) |node| node.lcanode(p, q) else null;
            const right: ?*Self = if (self.?.right) |node| node.lcanode(p, q) else null;

            if (left != null and right != null) return self;
            if (left != null) return left;
            return right;
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

    const sumpath = try root.sumPath(69);
    const sumpathRec = root.sumPathRec(69);
    std.debug.print("🌳 Binary Tree:\n{s}\n", .{treeDrawing});
    std.debug.print("📐 Depth:              {d}\n", .{result});
    std.debug.print("🧮 Sum path (iter):    {any}\n", .{sumpath});
    std.debug.print("🔁 Sum path (rec):     {any}\n", .{sumpathRec});

    const lcavalue = root.lcanode(28, 4);
    std.debug.print("⚙️ LCA of 28 and 4 is: {d}\n", .{lcavalue.?.value});
}

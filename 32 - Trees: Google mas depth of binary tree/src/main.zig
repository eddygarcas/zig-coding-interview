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

        // This program finds the kth smallest element in a Binary Search Tree (BST).
        // It uses an in-order traversal approach since BST in-order traversal gives elements in ascending order.
        // The algorithm maintains a counter that decrements with each node visited until reaching the kth element.
        //
        // For example, given this BST:
        //                          130
        //                /                   \
        //              70                    190
        //           /      \              /       \
        //         40       100          160        220
        //       /    \    /    \      /    \     /    \
        //     20     55  80    110  140    170  200   240
        //    /  \        \      \     \      \    \   /  \
        //   5   15       90     120   150    180  210 230 250
        //
        // And k=7, the program will return 80 (the 7th smallest element)
        //
        // Time Complexity: O(n) where n is number of nodes
        // Space Complexity: O(h) where h is height of tree due to recursion stack
        //
        // smallestElement performs an in-order traversal to find the kth smallest element
        // Parameters:
        //   - root: pointer to current node in traversal
        //   - k: pointer to remaining count until kth element is found
        //
        // The method stores result in the receiver's ans field when k reaches 0
        pub fn smallestElement(self: ?*Self, count: *i8, smallest: *usize) void {
            const node = self orelse null;
            if (self == null) return;

            if (node.?.left) |left| left.smallestElement(count, smallest);

            count.* -= 1;
            if (count.* == 0) {
                smallest.* = node.?.value;
                return;
            }

            if (node.?.right) |right| right.smallestElement(count, smallest);
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

        // This program implements binary tree serialization and deserialization.
        // It converts a binary tree to a string format and back, using a preorder traversal approach.
        // 'X' is used to denote null nodes, and '#' is used as a delimiter between nodes.

        // serialize converts the binary tree to a string representation
        // using preorder traversal (root-left-right)
        // Each node's value is followed by '#' and null nodes are represented as 'X#'
        pub fn serialize(self: ?*Self, word: *std.ArrayList(u8)) !void {
            if (self == null) try word.appendSlice(self.?.allocator, "X#");

            const num = try std.fmt.allocPrint(self.?.allocator, "{d}#", .{self.?.value});
            defer self.?.allocator.free(num);
            try word.appendSlice(self.?.allocator, num);

            if (self.?.left) |left| {
                try left.serialize(word);
            } else {
                try word.appendSlice(self.?.allocator, "X#");
            }

            if (self.?.right) |right| {
                try right.serialize(word);
            } else {
                try word.appendSlice(self.?.allocator, "X#");
            }
        }

        // deserialize reconstructs a binary tree from its serialized byte representation
        // Returns the reconstructed tree node and remaining serialized data
        // Rather than use pointers on data, use an index to point to the next node to evaluate
        // this way it's simplier than using pointers to data as it will require more dereferences.
        pub fn deserialize(allocator: std.mem.Allocator, data: []const u8, index: *usize) !?*Self {
            if (index.* >= data.len) return error.NoSerializedData;

            const value = data[index.*];
            index.* += 1;

            if (value == 'X') {
                return null;
            }
            // This is what happen here: value - '0' == 55 - 48 == 7
            //const number: usize = value - '0';

            // The alternative is this one, which is better if value has more than one digit
            var buf = &[_]u8{value};
            const conv: u8 = try std.fmt.parseInt(u8, buf[0..], 10);
            //std.debug.print("Parse int value {d}", .{conv});

            const node = TreeMap(usize).init(allocator, conv);

            node.left = try deserialize(allocator, data, index);
            node.right = try deserialize(allocator, data, index);
            return node;
        }

        // Simple way to represent a tree data
        pub fn printByLevel(root: ?*Self, allocator: std.mem.Allocator) !void {
            if (root == null) return;

            var queue = try std.ArrayList(?*Self).initCapacity(allocator, 5);
            defer queue.deinit(allocator);

            try queue.append(allocator, root);

            var level: usize = 0;

            while (queue.items.len > 0) {
                const size = queue.items.len;
                std.debug.print("      -> Level {d}: ", .{level});

                for (0..size) |_| {
                    const node = queue.orderedRemove(0);

                    if (node) |n| {
                        std.debug.print("{d} ", .{n.value});
                        try queue.append(allocator, n.left);
                        try queue.append(allocator, n.right);
                    } else {
                        std.debug.print("X ", .{});
                    }
                }

                std.debug.print("\n", .{});
                level += 1;
            }
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

    var word = try std.ArrayList(u8).initCapacity(allocator, 5);
    defer word.deinit(allocator);
    try root.serialize(&word);
    std.debug.print("-> Serialized tree:    {s}\n", .{word.items});

    const nodes: []const u8 = "12XX34XX5XX";
    var idx: usize = 0;
    const rootDefer = try TreeMap(usize).deserialize(allocator, nodes, &idx);
    defer rootDefer.?.deinit();

    std.debug.print("-> De-serialized:      {s}\n", .{nodes});
    try rootDefer.?.printByLevel(allocator);
    //std.debug.print("-> De-serialized tree: {any}\n", .{rootDefer});

    const lcavalue = root.lcanode(28, 18);
    std.debug.print("⚙️ LCA of 28 and 18 is: {d}\n", .{lcavalue.?.value});

    var rootBST = TreeMap(usize).init(allocator, 130);
    defer rootBST.deinit();

    // Level 1
    rootBST.left = TreeMap(usize).init(allocator, 70);
    rootBST.right = TreeMap(usize).init(allocator, 190);

    // Level 2
    rootBST.left.?.left = TreeMap(usize).init(allocator, 40);
    rootBST.left.?.right = TreeMap(usize).init(allocator, 100);

    rootBST.right.?.left = TreeMap(usize).init(allocator, 160);
    rootBST.right.?.right = TreeMap(usize).init(allocator, 220);

    // Level 3 (40 subtree)
    rootBST.left.?.left.?.left = TreeMap(usize).init(allocator, 20);
    rootBST.left.?.left.?.right = TreeMap(usize).init(allocator, 55);

    // Level 3 (100 subtree)
    rootBST.left.?.right.?.left = TreeMap(usize).init(allocator, 80);
    rootBST.left.?.right.?.right = TreeMap(usize).init(allocator, 110);

    // Level 3 (160 subtree)
    rootBST.right.?.left.?.left = TreeMap(usize).init(allocator, 140);
    rootBST.right.?.left.?.right = TreeMap(usize).init(allocator, 170);

    // Level 3 (220 subtree)
    rootBST.right.?.right.?.left = TreeMap(usize).init(allocator, 200);
    rootBST.right.?.right.?.right = TreeMap(usize).init(allocator, 240);

    // Level 4 (20 subtree)
    rootBST.left.?.left.?.left.?.left = TreeMap(usize).init(allocator, 5);
    rootBST.left.?.left.?.left.?.right = TreeMap(usize).init(allocator, 15);

    // Level 4 (80 subtree)
    rootBST.left.?.right.?.left.?.right = TreeMap(usize).init(allocator, 90);

    // Level 4 (110 subtree)
    rootBST.left.?.right.?.right.?.right = TreeMap(usize).init(allocator, 120);

    // Level 4 (140 subtree)
    rootBST.right.?.left.?.left.?.right = TreeMap(usize).init(allocator, 150);

    // Level 4 (170 subtree)
    rootBST.right.?.left.?.right.?.right = TreeMap(usize).init(allocator, 180);

    // Level 4 (200 subtree)
    rootBST.right.?.right.?.left.?.right = TreeMap(usize).init(allocator, 210);

    // Level 4 (240 subtree)
    rootBST.right.?.right.?.right.?.left = TreeMap(usize).init(allocator, 230);
    rootBST.right.?.right.?.right.?.right = TreeMap(usize).init(allocator, 250);

    var count: i8 = 7;
    var smllel: usize = 0;
    rootBST.smallestElement(&count, &smllel);

    const CY = "\x1b[36m"; // cyan
    const YY = "\x1b[33m"; // yellow
    const RST = "\x1b[0m";

    const bst_tree =
        \\    
        \\🌳 Given this BST Tree:
        \\
        \\                 --------{s}130{s}--------
        \\                /                   \
        \\              {s}70{s}                    190
        \\           /      \              /       \
        \\         {s}40{s}       100          160        220
        \\       /    \    /    \      /    \     /    \
        \\     {s}20{s}     55  {s}80{s}    110  140    170  200   240
        \\    /  \          \     \    \      \    \   /  \
        \\   5   15         90    120  150   180  210 230 250
        \\
    ;

    std.debug.print(bst_tree, .{ CY, RST, CY, RST, CY, RST, CY, RST, YY, RST });

    std.debug.print("⚙️ Smallest {d}th value:  {any}\n", .{ 7, smllel });
}

const std = @import("std");

//In the context of binary trees, DFS (Depth-First Search) and BFS (Breadth-First Search)
//are two fundamental tree traversal algorithms — each explores the tree in a different order:
//DFS explores as deep as possible down one branch before backtracking.
//BFS visits nodes level by level, from top to bottom and left to right.

//| Feature     | DFS                           | BFS                        |
//| ----------- | ----------------------------- | -------------------------- |
//| Approach    | Go deep first                 | Visit level by level       |
//| Data Struct | Stack / Recursion             | Queue                      |
//| Memory      | Less if tree is deep          | More if tree is wide       |
//| Use Cases   | Path finding, tree properties | Shortest path, level order |
fn TreeNode(comptime T: type) type {
    return struct {
        const Self = @This();
        value: T,
        left: ?*TreeNode(T) = null,
        right: ?*TreeNode(T) = null,
        // In order to simplify the allocation process will define the result as part of the TreeNode struct.
        result: std.ArrayList([]T),
        allocator: std.mem.Allocator,

        // Here you can see clearly how to allocate and return an owned pointer.
        // Particularly usefull when the struct contains pointers to the same type,
        // this way the assigment it's pretty straight forward:
        //
        //    eg. treenode.left = try TreeNode(u32).init(allocator,2);
        //
        // Otherwise the allocation happens in the stack and creates dingling pointers
        // (A pointer that points to memory that is no longer valid) as soon as you leave the scope.
        pub fn init(allocator: std.mem.Allocator, value: T) !*TreeNode(T) {
            const n = try allocator.create(Self);
            n.* = .{
                .allocator = allocator,
                .value = value,
                .result = try std.ArrayList([]T).initCapacity(allocator, 0),
            };
            return n;
        }
        // levelOrder performs a Breadth-First Search (BFS) traversal of the binary tree
        // It uses a queue to visit nodes level by level, from left to right:
        // 1. Start with root node in queue
        // 2. For each level:
        //   - Get current level size
        //   - Process all nodes in current level
        //   - Add their children to queue for next level
        //
        // 3. Return array of arrays where each inner array represents one level
        // Time: O(n) where n is number of nodes
        // Space: O(w) where w is maximum width of tree
        //        3     Level 0: [3]
        //      /   \
        //     9     20  Level 1: [9,20]
        //          /  \
        //         15   25 Level 2: [15,25]

        // After BFS traversal, result will be: [[3], [9,20], [15,25]]
        pub fn levelOrder(self: *TreeNode(T), zigzag: bool) !std.ArrayList([]T) {
            var queue: std.ArrayList(*TreeNode(T)) = try std.ArrayList(*TreeNode(T)).initCapacity(self.allocator, 2);
            defer queue.deinit(self.allocator);
            // Clear previous reslts, the method has to free all the dupe() items and then reset the array list to zero.
            self.clearResults();

            try queue.append(self.allocator, self);

            var levelIndex: usize = 1;

            while (queue.items.len > 0) : (levelIndex += 1) {
                const size = queue.items.len;
                var level = try std.ArrayList(T).initCapacity(self.allocator, 1);
                defer level.deinit(self.allocator);

                for (0..size) |_| {
                    // As for BFS we want a FIFO queue rather than a LIFO will use the swapRemove() method
                    // that gets the element specified by an index and removes it.
                    const node = queue.swapRemove(0);
                    try level.append(self.allocator, node.value);
                    if (node.left) |left| try queue.append(self.allocator, left);
                    if (node.right) |right| try queue.append(self.allocator, right);
                }
                const level_copy = try self.allocator.dupe(T, level.items);

                if (@mod(levelIndex, 2) == 0 and zigzag) {
                    std.mem.reverse(T, level_copy);
                }
                try self.result.append(self.allocator, level_copy);
            }

            return self.result;
        }

        // levelPostOrder performs iterative post-order traversal using two stacks
        // Stack states visualization:
        // Initial:
        // stack1: [3]
        // stack2: []

        // After first pop from stack1:
        // stack1: [9, 20]  // Left and right children of 3
        // stack2: [3]

        // After second pop from stack1:
        // stack1: [20]
        // stack2: [3, 9]

        // After third pop from stack1:
        // stack1: [15, 7]  // Children of 20
        // stack2: [3, 9, 20]

        // After fourth pop from stack1:
        // stack1: [7]
        // stack2: [3, 9, 20, 15]

        // After fifth pop from stack1:
        // stack1: []
        // stack2: [3, 9, 20, 15, 7]

        // Final result after processing stack2:
        // result: [9, 15, 7, 20, 3]
        // Time: O(n) where n is number of nodes
        // Space: O(n) for the two stacks
        pub fn levelPostOrder(self: *TreeNode(T), result: *std.ArrayList(T)) !void {
            var stackone: std.ArrayList(*TreeNode(T)) = try std.ArrayList(*TreeNode(T)).initCapacity(self.allocator, 2);
            defer stackone.deinit(self.allocator);

            var stacktwo: std.ArrayList(*TreeNode(T)) = try std.ArrayList(*TreeNode(T)).initCapacity(self.allocator, 2);
            defer stacktwo.deinit(self.allocator);

            try stackone.append(self.allocator, self);

            while (stackone.pop()) |node| {
                try stacktwo.append(self.allocator, node);
                if (node.left) |left| try stackone.append(self.allocator, left);
                if (node.right) |right| try stackone.append(self.allocator, right);
            }
            while (stacktwo.pop()) |node| {
                try result.append(self.allocator, node.value);
            }
        }

        pub fn deinit(self: *TreeNode(T)) void {
            if (self.left) |left| left.deinit();
            if (self.right) |right| right.deinit();
            for (self.result.items) |lvl| self.allocator.free(lvl); // free each duped slice
            self.result.deinit(self.allocator);
            self.allocator.destroy(self);
        }

        pub fn clearResults(self: *TreeNode(T)) void {
            for (self.result.items) |lvl| self.allocator.free(lvl);
            self.result.clearRetainingCapacity(); // free each duped slice
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var treenode = try TreeNode(u32).init(allocator, 3);
    defer treenode.deinit();

    treenode.left = try TreeNode(u32).init(allocator, 9);
    treenode.right = try TreeNode(u32).init(allocator, 20);

    treenode.right.?.left = try TreeNode(u32).init(allocator, 15);
    treenode.right.?.right = try TreeNode(u32).init(allocator, 25);

    const tree =
        \\        3
        \\      /   \
        \\     9     20
        \\          /  \
        \\         15   25
    ;

    std.debug.print("Tree : \n{s}\n", .{tree});
    const result = try treenode.*.levelOrder(false);
    std.debug.print("Result Level order: {any}\n", .{result.items});

    const resultZigZag = try treenode.*.levelOrder(true);
    std.debug.print("Result Zig-Zag    : {any}\n", .{resultZigZag.items});

    var resultPostOrder = try std.ArrayList(u32).initCapacity(allocator, 0);
    defer resultPostOrder.deinit(allocator);
    _ = try treenode.*.levelPostOrder(&resultPostOrder);
    std.debug.print("Result Post Order : {any}\n", .{resultPostOrder.items});
}

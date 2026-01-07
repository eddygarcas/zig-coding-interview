const std = @import("std");

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
        pub fn levelOrder(self: *TreeNode(T)) !std.ArrayList([]T) {
            //var result = try std.ArrayList([]T).initCapacity(self.allocator, 2);
            //errdefer {
            //    for (result.items) |lvl| self.allocator.free(lvl);
            //    result.deinit(self.allocator);
            //}

            var queue: std.ArrayList(*TreeNode(T)) = try std.ArrayList(*TreeNode(T)).initCapacity(self.allocator, 2);
            defer queue.deinit(self.allocator);

            try queue.append(self.allocator, self);

            while (queue.items.len > 0) {
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
                std.debug.print("Level elements: {any}\n", .{level.items});
                const level_copy = try self.allocator.dupe(T, level.items);
                try self.result.append(self.allocator, level_copy);
            }

            return self.result;
        }

        pub fn deinit(self: *TreeNode(T)) void {
            if (self.left) |left| left.deinit();
            if (self.right) |right| right.deinit();
            for (self.result.items) |lvl| self.allocator.free(lvl); // free each duped slice
            self.result.deinit(self.allocator);
            self.allocator.destroy(self);
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

    const result = try treenode.*.levelOrder();
    std.debug.print("Result: {any}\n", .{result.items});
}

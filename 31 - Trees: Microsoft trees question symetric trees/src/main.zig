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

        // isSymetric checks if two binary trees are mirror images of each other
        // Will implement a version using Queue approach.
        // Using recursive calls has penalties as every call goes into the stack
        fn isSymetric(self: *Self) !bool {
            var queue = try std.ArrayList(struct {
                l: ?*TreeMap(V),
                r: ?*TreeMap(V),
            }).initCapacity(self.allocator, 5);

            defer queue.deinit(self.allocator);

            try queue.append(self.allocator, .{
                .l = self.left,
                .r = self.right,
            });

            const result = blk: {
                while (queue.pop()) |pair| {
                    const l = pair.l;
                    const r = pair.r;

                    if (l == null and r == null) continue;
                    if (l == null or r == null) break :blk false;
                    if (l.?.value != r.?.value) break :blk false;

                    // Basically to avoid the recursive call we need to replace the actuall call for
                    // adding same params in the Queue. No need to change previous conditions.
                    try queue.append(self.allocator, .{
                        .l = l.?.left,
                        .r = r.?.right,
                    });

                    try queue.append(self.allocator, .{
                        .l = l.?.right,
                        .r = r.?.left,
                    });
                }
                break :blk true;
            };
            return result;
        }

        // You can pass *TreeMap(V) or *Self will work either way
        pub fn deinit(self: *TreeMap(V)) void {
            if (self.left) |l| l.deinit();
            if (self.right) |r| r.deinit();
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

    var root = TreeMap(usize).init(allocator, 1);
    defer root.deinit();

    root.left = TreeMap(usize).init(allocator, 2);
    root.right = TreeMap(usize).init(allocator, 2);

    root.left.?.left = TreeMap(usize).init(allocator, 3);
    root.left.?.right = TreeMap(usize).init(allocator, 4);

    root.right.?.left = TreeMap(usize).init(allocator, 4);
    root.right.?.right = TreeMap(usize).init(allocator, 3);

    const result = try root.isSymetric();
    const treeDrawing =
        \\ Symmetric tree:
        \\      1
        \\    /   \
        \\   2     2
        \\  / \   / \
        \\ 3   4 4   3
    ;
    std.debug.print("{s}\n", .{treeDrawing});
    std.debug.print("Tree is symetric? {}", .{result});
}

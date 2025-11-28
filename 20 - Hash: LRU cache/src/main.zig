const std = @import("std");
// Package main implements a simple LRU (Least Recently Used) cache in Go.
// An LRU cache is a data structure that maintains a fixed number of items,
// discarding the least recently used items when the cache reaches its capacity.
const DoublyLinkedList = std.DoublyLinkedList;

const Entry = struct {
    key: u32,
    value: i32,
    node: DoublyLinkedList.Node,
};

fn LRUCache() type {
    return struct {
        capacity: usize,
        cache: std.DoublyLinkedList = .{},
        items: std.hash_map.AutoHashMap(u32, *Entry),
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, capacity: usize) Self {
            return .{
                .capacity = capacity,
                .allocator = allocator,
                .items = std.hash_map.AutoHashMap(u32, *Entry).init(allocator),
            };
        }

        pub fn put(self: *Self, key: u32, value: i32) !void {
            // If key exists, update its value and move it to front (most recently used)
            if (self.items.get(key)) |elem| {
                std.debug.print("Move to first {d}\n", .{value});
                self.cache.prepend(&elem.node);
                elem.*.value = value;
                // Will check whether the first element in the linked list is the recently value added.
                const top_elem: *Entry = @fieldParentPtr("node", self.cache.first.?);
                try std.testing.expect(top_elem.*.value == value);
                std.debug.print("Top element {d}\n", .{top_elem.*.value});
            } else {
                // If cache is at capacity, remove least recently used item (from back)
                // will use count() from the hash map to know how many items are stored as len()
                // from DoublyLinkedList time complexity is O(n)
                if (self.items.count() == self.capacity) {
                    // No need to destroy the Entry as it will happen when deinit()
                    //const to_remove: *Entry = @fieldParentPtr("node", self.cache.pop().?);
                    //self.allocator.destroy(to_remove);
                    _ = self.cache.pop();
                }
                std.debug.print("Create entry {d}\n", .{value});
                var new_elem = try self.allocator.create(Entry);
                new_elem.* = .{ .key = key, .value = value, .node = .{} };
                self.cache.prepend(&new_elem.node);
                try self.items.put(key, new_elem);
            }
        }

        pub fn deinit(self: *Self) void {
            var it = self.items.valueIterator();
            while (it.next()) |v| {
                self.allocator.destroy(v.*);
            }
            self.items.deinit();
        }
        pub fn is_init(self: *Self) bool {
            return self.cache.len() == 0;
        }
    };
}

pub fn main() !void {
    // LRUCache represents a Least Recently Used cache with a fixed capacity.
    // It stores key-value pairs and evicts the least recently used entry when full.
    // Implementation uses container/list package for O(1) operations.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var cache = LRUCache().init(allocator, 4);
    defer cache.deinit();
    std.debug.assert(cache.is_init());
    try cache.put(1, 1);
    try cache.put(1, 2);
    try cache.put(2, 2);
    try cache.put(3, 3);
    try cache.put(4, 4);
    try cache.put(5, 5);
    std.debug.print("Cache {any}\n", .{cache.cache});
}

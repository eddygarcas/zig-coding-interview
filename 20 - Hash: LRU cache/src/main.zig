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

        // Put inserts or updates a key-value pair in the cache.
        // If the key already exists, it updates the value and marks the entry as most recently used.
        // If the key doesn't exist and the cache is at capacity, it evicts the least recently used entry.
        //
        // Parameters:
        //   - key: The key to store
        //   - value: The value to associate with the key
        //
        // Time Complexity: O(1)
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

        // Get retrieves the value for a given key and marks it as most recently used.
        // Returns the value and true if found; 0 and false otherwise.
        //
        // Parameters:
        //   - key: The key to look up
        //
        // Returns:
        //   - value: The value associated with the key (0 if not found)
        //
        // Time Complexity: O(1)
        pub fn get(self: *Self, key: u32) !i32 {
            const node = self.items.get(key) orelse return error.EntryNotFound;

            self.cache.prepend(&node.*.node);
            return node.*.value;
        }

        pub fn deinit(self: *Self) void {
            var it = self.items.valueIterator();
            while (it.next()) |v| {
                self.allocator.destroy(v.*);
            }
            self.items.deinit();
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
    try cache.put(1, 1);
    try cache.put(1, 2);
    try cache.put(2, 2);
    try cache.put(3, 3);
    try cache.put(4, 4);
    try cache.put(5, 5);
    const get_val = try cache.get(3);
    std.debug.print("Element at 3 is {d}\n", .{get_val});

    _ = cache.get(9) catch |err| {
        std.debug.print("Getting key 9 gets this error {s}\n", .{@errorName(err)});
    };
}

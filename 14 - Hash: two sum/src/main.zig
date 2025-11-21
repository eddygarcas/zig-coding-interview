const std = @import("std");

pub fn main() !void {
    // This program solves the Two Sum problem using a hash map approach.
    // Given an array of integers and a target sum, it finds two numbers that add up to the target.
    // The solution uses a single pass through the array, storing complements in a hash map.
    // Time Complexity: O(n) where n is length of input array
    // Space Complexity: O(n) for storing the hash map

    const nums = [_]u8{ 2, 11, 7, 15 };
    const target: u8 = 26;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = arena.allocator();
    defer arena.deinit();

    var findMap = std.hash_map.AutoHashMap(u8, u8).init(alloc);
    defer findMap.deinit();

    outer: for (nums, 0..) |num, i| {
        const val = findMap.get(num);
        if (val) |v| {
            std.debug.print("Positions {d} and {d}\n", .{ v, i });
            //result = [2]u8{ val.value_ptr.*, @intCast(i) };
            break :outer;
        } else {
            try findMap.put((target - num), @intCast(i));
        }
    }
}

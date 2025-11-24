const std = @import("std");

pub fn main() !void {
    // This program checks if an array contains any duplicate values using a hash map.
    // It demonstrates a simple hash-based approach to track and identify duplicates:
    // 1. Create a map to store seen numbers
    // 2. Iterate through array once, checking if each number exists in map
    // 3. Return true immediately when a duplicate is found
    // 4. Otherwise mark number as seen and continue
    //
    // Time Complexity: O(n) - single pass through the array
    // Space Complexity: O(n) - hash map may store up to n elements

    const nums = [_]u8{ 2, 7, 11, 15, 2 };
    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const alloc = gpa.allocator();
    defer gpa.deinit();

    const result: bool = try duplicates(alloc, nums[0..]); //or &num
    std.debug.print("Reult is {}\n", .{result});
}

pub fn duplicates(alloc: std.mem.Allocator, nums: []const u8) !bool {
    var findMap = std.AutoHashMap(u8, bool).init(alloc);
    defer findMap.deinit();

    for (nums) |num| {
        var result = try findMap.getOrPut(num);
        if (result.found_existing) {
            std.debug.print("This ones is duplicated {d}\n", .{num});
            return result.value_ptr.*;
        }
        result.value_ptr.* = true;
    }
    return false;
}

const std = @import("std");

pub fn main() !void {
    // This program finds the majority element in an array using two approaches:
    // 1. A hashmap-based counting method
    // 2. The Boyer-Moore voting algorithm
    //
    // A majority element is defined as an element that appears more than n/2 times
    // in the array, where n is the array length.

    const nums = [_]u8{ 2, 1, 3, 1, 1, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 };

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    const alloc = gpa.allocator();

    var start = try std.time.Timer.start();
    var result: u8 = try majorityElement(alloc, nums[0..]);
    std.debug.print("Time elapsed majority {d}ns\n", .{start.lap()});
    std.debug.print("Result {d}\n", .{result});

    // Here will use a different wat to pass a comptime array using (&) rather than a slice [0..]
    result = majorityBoyer(&nums);
    std.debug.print("Time elapsed Boyer {d}ns\n", .{start.lap()});
    std.debug.print("Result Boyer {d}\n", .{result});
}

// majorityElement finds the element that appears more than n/2 times in the nums slice.
// It uses a hashmap to count occurrences of each element.
// Time complexity: O(n), Space complexity: O(n)
// Returns the majority element if it exists, otherwise returns 0.
pub fn majorityElement(alloc: std.mem.Allocator, nums: []const u8) !u8 {
    var findMap = std.hash_map.AutoHashMap(u8, u8).init(alloc);
    defer findMap.deinit();

    // Look here how we are using blocks (:blk) to handle the response.
    const result = blk: {
        for (nums) |num| {
            var item = try findMap.getOrPut(num);
            if (item.found_existing) {
                item.value_ptr.* += 1;
                if (item.value_ptr.* > (nums.len / 2)) {
                    break :blk num;
                }
            } else {
                item.value_ptr.* = 1;
            }
        }
        break :blk 0;
    };
    return result;
}
// majorityBoyer implements the Boyer-Moore voting algorithm to find the majority element.
// The algorithm works by maintaining a candidate and a count:
// 1. Initialize candidate as first element and count as 1
// 2. For each subsequent element:
//   - If count becomes 0, pick current element as new candidate
//   - If element matches candidate, increment count
//   - If element differs from candidate, decrement count
//
// 3. Final candidate is the majority element
//
// Time complexity: O(n), Space complexity: O(1)
// Note: This algorithm only works when a majority element is guaranteed to exist.
// For arrays like [1,1,2,2,3], it may give incorrect results.
pub fn majorityBoyer(nums: []const u8) u8 {
    var count: u8 = 1;
    var candidate: u8 = nums[0];
    for (nums) |num| {
        if (count == 0) {
            candidate = num;
        }
        if (num == candidate) {
            count += 1;
        } else {
            count -= 1;
        }
    }
    return candidate;
}

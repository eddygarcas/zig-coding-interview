const std = @import("std");

// This program solves the Group Anagrams problem using hash tables.
// It takes a list of strings and groups them based on whether they are anagrams of each other.
// Two strings are anagrams if they contain the same characters with the same frequencies.
//
// Example:
// Input: ["eat","tea","tan","ate","nat","bat"]
// Output: [["bat"],["nat","tan"],["ate","eat","tea"]]
//
// The program implements two different approaches:
// 1. Character counting using a hash map (groupAnagrams)
// 2. Sorting characters and using sorted string as key (groupAnagrams2)
pub fn main() !void {
    const input_vec =
        \\eat
        \\tea
        \\tan
        \\ate
        \\nat
        \\bat
    ;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    std.debug.print("input {any}\n", .{input_vec});
    try groupAnagrams(allocator, input_vec);
}

// groupAnagrams groups anagrams by sorting each string's characters.
// Uses sorted strings as keys in a hash map to group anagrams efficiently.
//
// Time Complexity: O(n * k log k), where n is number of strings, k is average string length
// Space Complexity: O(nk) for storing the map and result slices
pub fn groupAnagrams(allocator: std.mem.Allocator, input: []const u8) !void {
    const List = std.ArrayList([]const u8);
    var resultMap =
        std.array_hash_map.StringArrayHashMap(List).init(allocator);
    defer resultMap.deinit();

    var it = std.mem.splitScalar(u8, input[0..], '\n');
    while (it.next()) |element| {
        const sorted = try allocator.alloc(u8, element.len);
        // don't forget to free sorted
        @memcpy(sorted, element);
        std.sort.block(u8, sorted, {}, std.sort.asc(u8));

        const anagram = try resultMap.getOrPut(sorted);
        if (anagram.found_existing) {
            allocator.free(sorted);
            try anagram.value_ptr.*.append(allocator, element);
        } else {
            anagram.value_ptr.* = try List.initCapacity(allocator, 0);
            try anagram.value_ptr.*.append(allocator, element);
        }
    }
    var it_map = resultMap.iterator();
    while (it_map.next()) |elem| {
        var list = elem.value_ptr.*;
        const key = elem.key_ptr.*;
        {
            std.debug.print("\nGroup:\n", .{});
            for (list.items) |word| {
                std.debug.print(" {s}", .{word});
            }
            defer list.deinit(allocator);
            defer allocator.free(key);
        }
    }
}

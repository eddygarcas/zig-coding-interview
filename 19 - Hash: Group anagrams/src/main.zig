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
    const input = [_][]const u8{ "eat", "tea", "tan", "ate", "nat", "bat" };

    var output_buf: [10][]const u8 = undefined;
    const output = output_buf[0..];
    std.debug.print("input {any} {any}", .{ input, output });
    const out_len = try groupAnagrams(input);
    std.debug.print("len {d}", .{out_len});
}

// groupAnagrams groups anagrams by sorting each string's characters.
// Uses sorted strings as keys in a hash map to group anagrams efficiently.
//
// Time Complexity: O(n * k log k), where n is number of strings, k is average string length
// Space Complexity: O(nk) for storing the map and result slices
pub fn groupAnagrams(input: anytype) !usize {
    for (input) |element| {
        std.debug.print("element {s}\n", .{element});
        //std.sort.block([]const u8, element, {}, std.sort.asc(u8));
    }
    return 0;
}

// compareChars checks if two  strings are anagrams by comparing their character counts.
// It uses a hash map to track character frequencies.
//
// Time Complexity: O(k), where k is the length of the strings
// Space Complexity: O(1) since character set is fixed
pub fn compareChars(s: []const u8, t: []const u8) !bool {
    var count: [256]i8 = .{0} ** 256;

    for (s) |ch| {
        count[ch] += 1;
    }
    for (t) |ch| {
        if (count[ch] == 0) {
            return false;
        }
        count[ch] -= 1;
    }
    for (count) |ch| {
        if (ch != 0) return false;
    }
    return true;
}

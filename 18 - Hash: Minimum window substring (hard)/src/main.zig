const std = @import("std");

pub fn main() !void {
    // This program solves the Minimum Window Substring problem using a sliding window and hash map approach.
    // Given two strings 's' and 't', find the minimum window in 's' that contains all characters of 't'.
    //
    // Example:
    // s = e "ADOBECODEBANC", t = "ABC"
    // Output: "BANC" (smallest substring containing all characters from t)
    //
    // Algorithm:
    // 1. Use two pointers l and r to define a window
    // 2. Expand window by moving r until all characters of t are found
    // 3. Contract window by moving l while still maintaining all required characters
    // 4. Track minimum valid window found so far
    //
    // Time Complexity: O(n * m) where n is length of s and m is length of t
    // Space Complexity: O(k) where k is size of character set (constant for ASCII)
    const s: []const u8 = "abaaccadaaaaaaaaaaaaaaaaaaaaaaaaaaa";
    const t: []const u8 = "aca";

    const it_s = std.mem.splitScalar(u8, s, ' ');
    const it_t = std.mem.splitScalar(u8, t, ' ');
    std.debug.print("S lenght {d} and T lenght {d}\n", .{ it_s.buffer.len, it_t.buffer.len });
    std.debug.print("Buffer value {s}\n", .{it_s.buffer});
    var result: [256]u8 = undefined;
    const sub_len = try minSubstring(it_s.buffer, it_t.buffer, &result);
    std.debug.print("Result {s}", .{result[0..sub_len]});
}

// minSubstring returns the minimum window substring from 's' that contains all characters from 't'.
// Uses sliding window technique with two pointers to find minimum valid substring.
// Time Complexity: O(n * m) where n is length of s and m is length of t
// Space Complexity: O(1) for result slice
pub fn minSubstring(s: []const u8, t: []const u8, result: []u8) !usize {
    // assert that both types are SplitIterator(u8, ' ')
    //comptime {
    //   if (@TypeOf(s) != []const u8 or
    //       @TypeOf(t) != []const u8)
    //   {
    //       @compileError("Expected []u8");
    //   }
    //}
    var l: usize = 0;
    var r: usize = 0;
    //const result: [256]u8 = undefined;
    var best_len: usize = 0;

    while (l <= s.len and r <= s.len) {
        if (try isSubset(s[l..r], t)) {
            const w = s[l..r];
            std.debug.print("isSubset is true and substring {s}\n", .{w});

            if (best_len == 0 or w.len < best_len) {
                best_len = w.len;
                @memcpy(result[0..w.len], w);
            }
            if (best_len == t.len) {
                break;
            }
            l += 1;
        } else {
            r += 1;
        }
    }
    std.debug.print("pre-exit result {s} len {d}\n", .{ result[0..best_len], best_len });
    return best_len;
}

// isSubet checks if all characters in t are present in s with required frequency.
// Uses a hash map to track character frequencies.
// Time Complexity: O(m) where m is length of input slice s
// Space Complexity: O(k) where k is size of character smallest
pub fn isSubset(s: []const u8, t: []const u8) !bool {
    var freq_s: [256]u32 = .{0} ** 256;
    var freq_t: [256]u32 = .{0} ** 256;

    for (s) |ch| {
        freq_s[ch] += 1;
    }

    for (t) |ch| {
        freq_t[ch] += 1;
    }

    const res = blk: {
        for (t) |ch| {
            if (freq_t[ch] > freq_s[ch]) break :blk false;
        }
        break :blk true;
    };
    return res;
}

const std = @import("std");

pub fn main() !void {
    // This program solves the 4Sum II problem: Given four integer arrays A, B, C, and D,
    // compute how many tuples (i, j, k, l) there are such that A[i] + B[j] + C[k] + D[l] == 0.
    // It uses a hash map to optimize the search for complement sums.
    const a = [_]i8{ 1, 2 };
    const b = [_]i8{ -2, -1 };
    const c = [_]i8{ -1, 2 };
    const d = [_]i8{ 0, 2 };

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer gpa.deinit();
    const alloc = gpa.allocator();

    var result = std.hash_map.AutoHashMap(i8, i8).init(alloc);
    defer result.deinit();

    const ans = fourSumTwo(a[0..], b[0..], &result, false);

    const ans_2 = fourSumTwo(c[0..], d[0..], &result, true);

    std.debug.print("Results ({any},{any})\n", .{ ans, ans_2 });

    var it = result.iterator();
    while (it.next()) |next| {
        std.debug.print("{d} => {d}\n", .{ next.key_ptr.*, next.value_ptr.* });
    }
}

// fourSumTwo either populates the result hash map with sums (if check is false)
// or counts how many pairs from a and b sum with pairs from c and d to zero (if check is true).
pub fn fourSumTwo(a: []const i8, b: []const i8, result: *std.hash_map.AutoHashMap(i8, i8), check: bool) !u8 {
    var ans: u8 = 0;

    for (a) |num| {
        for (b) |sec| {
            if (check) {
                if (result.get(-(num + sec))) |_| {
                    ans += 1;
                }
            } else {
                const pos = try result.getOrPut(num + sec);
                // you must check found_existing other wise the increment will happen over an undefined value.
                if (pos.found_existing) {
                    pos.value_ptr.* += 1;
                } else {
                    pos.value_ptr.* = 1;
                }
            }
        }
    }
    return ans;
}

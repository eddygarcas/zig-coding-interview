const std = @import("std");

// This program solves the "Combination Sum" problem using backtracking.
// Given a set of candidate numbers and a target sum, it finds all unique combinations
// of candidates where the chosen numbers sum to the target.
// Each number in candidates may be used an unlimited number of times.
//
// Example:
// Input: candidates = [2,3,6], target = 8
// Output: [[2,2,2,2],[2,3,3],[3,3,2],[6,2]]

// candidates represents the data structure to store combinations and input numbers
const Candidates = struct {
    ans: std.ArrayList([]u32),
    ids: []const u32,
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, ids: []const u32) !Self {
        return .{
            .ids = ids,
            .ans = try std.ArrayList([]u32).initCapacity(allocator, 0),
            .allocator = allocator,
        };
    }

    // solution implements the backtracking algorithm to find all valid combinations
    // Parameters:
    //   - cur: Current combination being built
    //   - target: Target sum to achieve
    //   - index: Current index in candidates array
    //   - sum: Running sum of current combination
    //
    // You can actually move cur []int to be part of the struct this way would avoid the pointer.
    fn solution(self: *Self, cur: *std.ArrayList(u32), target: u32, index: usize, sum: u32) !void {
        if (sum == target) {
            const ans_cpy: []u32 = try self.allocator.dupe(u32, cur.items);
            try self.ans.append(self.allocator, ans_cpy);
        }
        if (sum < target) {
            // Backtrack algorithm iterate, add, Recurse and backtrack.
            for (self.ids[index..], 0..) |candidate, idx| {
                try cur.append(self.allocator, candidate); // Add candidate
                try self.solution(cur, target, idx, sum + self.ids[idx]); // Recurse
                // Will execute the following sentence for instance in this situation:
                // [2,2,2,2] -> because the previous execution SUM was be 8
                // So will pop cur to [2,2,2] and will run the next loop iteration
                _ = cur.pop(); // backtracking
            }
        }
    }

    fn deinit(self: *Self) void {
        for (self.ans.items) |item| {
            self.allocator.free(item);
        }
        self.ans.deinit(self.allocator);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .verbose_log = false,
        .never_unmap = true,
        .retain_metadata = true,
    }){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    const ids: []const u32 = &[_]u32{ 2, 3, 6 };
    var candidates = try Candidates.init(allocator, ids);
    defer candidates.deinit();

    var cur = try std.ArrayList(u32).initCapacity(allocator, 0);
    defer cur.deinit(allocator);

    try candidates.solution(&cur, 7, 0, 0);
    std.debug.print("Candidates : {any}\n", .{candidates.ids});
    std.debug.print("Answer     : {any}\n", .{candidates.ans.items});
}

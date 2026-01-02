const std = @import("std");

const Palindrome = struct {
    ans: std.ArrayList([][]u8),
    allocator: std.mem.Allocator,

    const Self = @This();

    fn init(allocator: std.mem.Allocator) !Self {
        return .{
            .allocator = allocator,
            .ans = try std.ArrayList([][]u8).initCapacity(allocator, 0),
        };
    }

    // solution implements backtracking to find all palindrome partitions
    // Parameters:
    //   - s: remaining string to partition
    //   - curArr: current partition being built
    fn solution(self: *Self, origin: []const u8, partition: *std.ArrayList([]const u8)) !void {
        std.debug.print("Origin: {s:5} -> ", .{origin});
        if (origin.len == 0) {
            // partition is an array of string ([]const u8) here what it's doing is allocate
            // an array of string (mutable) same lenght as the partition array.
            const partition_copy = try self.allocator.alloc([]u8, partition.items.len);

            // To copy every string as part of the answer, it loops partition array of strings
            // and for every string makes a mutable duplicate and assign it to the partition copy.
            for (partition.items, 0..) |item, idx| {
                partition_copy[idx] = try self.allocator.dupe(u8, item);
            }
            // Finally it appends partition copy to the answer array of array of strings.
            try self.ans.append(self.allocator, partition_copy);
            return;
        }

        // Try all possible prefixes of the remaining string
        // s = "aab" partition = [a] i = 1
        // s = "ab"  partition = [a,a] i = 1
        // s = "b"   partition = [a,a,b] i = 1
        // s = ""    partition = [a,a,b] i = 1
        // s = "aab" partition = []i = 2
        // s = "aab" partition = [a,a] i = 2
        // s = "b"   partition = [a,a] i = 1
        // s = "b"   partition = [a,a][b] i = 1
        for (1..origin.len + 1) |index| {
            const curStr = origin[0..index];
            const result = self.isPalindrome(curStr);
            if (result) {
                std.debug.print("palindrome : {s}\n", .{curStr});
                try partition.append(self.allocator, curStr);
                try self.solution(origin[index..], partition);
                _ = partition.pop();
            }
        }
    }

    // isPalindrome checks if a string is a palindrome using two pointers
    // Returns true if the string reads the same forwards and backwards
    fn isPalindrome(self: *Self, pal: []const u8) bool {
        _ = self;
        var l: usize = 0;
        var r: usize = pal.len - 1;

        while (l < r) {
            if (pal[l] != pal[r]) {
                return false;
            }
            l += 1;
            r -= 1;
        }
        return true;
    }

    fn print(self: *Self) void {
        for (self.ans.items) |pal| {
            std.debug.print("\nPalindrome: ", .{});
            for (pal) |word| {
                std.debug.print("{s} ", .{word});
            }
        }
    }

    fn deinit(self: *Self) void {
        for (self.ans.items) |item| {
            for (item) |e| {
                self.allocator.free(e);
            }
            self.allocator.free(item);
        }
        self.ans.deinit(self.allocator);
    }
};

// main demonstrates palindrome partitioning by finding all possible partitions
// of a string where each substring is a palindrome
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var palindrome = try Palindrome.init(allocator);
    defer palindrome.deinit();

    var partition = try std.ArrayList([]const u8).initCapacity(allocator, 0);
    defer partition.deinit(allocator);

    try palindrome.solution("babba", &partition);
    palindrome.print();
}

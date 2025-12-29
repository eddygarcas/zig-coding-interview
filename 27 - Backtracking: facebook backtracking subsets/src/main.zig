const std = @import("std");

const Result = struct {
    subset: std.ArrayList([]u32),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !Result {
        return .{
            .allocator = allocator,
            .subset = try std.ArrayList([]u32).initCapacity(allocator, 0),
        };
    }

    pub fn append(self: *Result, elements: []const u32) !void {
        const snapshot = try self.allocator.alloc(u32, elements.len);
        @memcpy(snapshot, elements);
        try self.subset.append(self.allocator, snapshot);
    }

    pub fn deinit(self: *Result) void {
        for (self.subset.items) |elem| {
            self.allocator.free(elem);
        }
        self.subset.deinit(self.allocator);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    const allocator = gpa.allocator();

    var result = try Result.init(allocator);
    defer result.deinit();

    var cur = try std.ArrayList(u32).initCapacity(allocator, 0);
    defer cur.deinit(allocator);

    const nums = try allocator.alloc(u32, 3);
    defer allocator.free(nums);
    @memcpy(nums, &[_]u32{ 1, 2, 3 });

    try recurSubset(nums, &result, &cur, 0, allocator);
    std.debug.print("Answer: {any}\n", .{result.subset.items});
}

fn recurSubset(nums: []const u32, ans: *Result, cur: *std.ArrayList(u32), index: usize, allocator: std.mem.Allocator) !void {
    // We could say nums.len as Zig dereference but here it's better to be explicit.
    if (index > nums.len) return;

    // We can't append items diretly to the Result items struct, we need to allocate and make a
    // copy first. So will pass items and then will make a memory copy of the array to be able to
    // add it as part of the answer.
    try ans.append(cur.items);
    var i = index;
    while (i < nums.len) : (i += 1) {
        if (i > index and nums[i] == nums[i - 1]) {
            continue;
        }
        //Add my choice to the current subset as valid answer
        try cur.append(allocator, nums[i]);
        // Exaplore all the remaining subsets
        try recurSubset(nums, ans, cur, i + 1, allocator);
        //Backtracking: I'm done exploring with this number, remove it and go back.
        cur.items.len -= 1;
    }
}

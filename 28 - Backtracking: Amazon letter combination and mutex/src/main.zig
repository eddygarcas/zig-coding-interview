const std = @import("std");

const Digits = fn () []const u32;

const PhoneText = struct {
    ans: std.ArrayList([]u8),
    digitToString: std.hash_map.AutoHashMap(u32, []const u8),
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) !Self {
        return .{
            .ans = try std.ArrayList([]u8).initCapacity(allocator, 0),
            .digitToString = std.hash_map.AutoHashMap(u32, []const u8).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn letterCombination(self: *Self, comptime digits: Digits, cur: []const u8, digitIndex: usize, isRoot: bool) !void {
        if (digits().len == 0) return;

        if (cur.len == digits().len) {
            // This may work also:
            // const copy = try allocator.alloc(u8, original.len);
            //defer allocator.free(copy);
            //@memcpy(copy, original);
            const cur_dupe = try self.allocator.dupe(u8, cur);
            //Do not fee here as you won't be able to print the result in main function.
            //defer self.allocator.free(cur_dupe);
            try self.ans.append(self.allocator, cur_dupe);
            return;
        }
        const currentDigit = digits()[digitIndex];

        for (self.digitToString.get(currentDigit).?) |char| {
            const s: [1]u8 = .{char};
            const next: []const u8 = try std.fmt.allocPrint(self.allocator, "{s}{s}", .{ cur, s });
            defer self.allocator.free(next);
            if (isRoot and digitIndex == 0) {
                try self.letterCombination(digits, next, digitIndex + 1, false);
            } else {
                try self.letterCombination(digits, next, digitIndex + 1, false);
            }
        }
    }

    pub fn deinit(self: *Self) void {
        self.digitToString.deinit();
        for (self.ans.items) |item| {
            self.allocator.free(item);
        }
        self.ans.deinit(self.allocator);
    }
};

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var phonetest = try PhoneText.init(allocator);
    defer phonetest.deinit();

    try phonetest.digitToString.put(2, "abc");
    try phonetest.digitToString.put(3, "def");
    try phonetest.digitToString.put(4, "ghi");
    try phonetest.digitToString.put(5, "jkl");
    try phonetest.digitToString.put(6, "mno");
    try phonetest.digitToString.put(7, "pqrs");
    try phonetest.digitToString.put(8, "tuv");
    try phonetest.digitToString.put(9, "wxyz");

    try phonetest.letterCombination(struct {
        fn call() []const u32 {
            return &[_]u32{ 2, 3, 4 };
        }
    }.call, "", 0, true);
    const result = phonetest.ans.items;
    for (result) |item| {
        std.debug.print("{s} ", .{item});
    }
}

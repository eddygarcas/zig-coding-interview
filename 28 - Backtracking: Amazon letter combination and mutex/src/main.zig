const std = @import("std");

const Digits = *const fn () []u32;

const PhoneText = struct {
    ans: std.ArrayList([]u8),
    digitToString: std.hash_map.AutoHashMap(u32, []u8),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .ans = try std.ArrayList([]u8).initCapacity(allocator, 0),
            .digitToString = try std.hash_map.AutoHashMap(u32, []u8).init(allocator),
        };
    }

    pub fn letterCombination(self: PhoneText, allocator: std.mem.Allocator, digits: Digits, cur: []const u8, digitIndex: usize, isRoot: bool) !void {}
};

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    const phonetest = PhoneText.init(allocator);
}

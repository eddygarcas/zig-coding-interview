const std = @import("std");

const point = struct {
    x: i8,
    y: i8,

    fn toArray(this: point) [2]i8 {
        return .{ this.x, this.y };
    }
};

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var p: point = point{ .x = -1, .y = -1 };
    const nums = [_]u8{ 10, 11, 11, 11, 12, 13, 18, 19, 19, 19, 21, 22, 23, 24, 25, 26, 26 };
    std.debug.print("Point array {any}\n", .{p.toArray()});

    const target: u8 = 19;

    var start = try std.time.Timer.start();
    for (nums, 0..) |num, i| {
        if (num == target) {
            if (p.x == -1) {
                p = point{ .x = @intCast(i), .y = @intCast(i) };
            } else {
                p.y = @intCast(i);
            }
        }
    }
    var elapsed = start.read();
    std.debug.print("Time elapsed using strcut version: {d}ns\n", .{elapsed});

    start = try std.time.Timer.start();
    p.x = findFirst(&nums, target);
    p.y = findLast(&nums, target);
    elapsed = start.read();
    std.debug.print("Time elapsed binary search: {d}ns\n", .{elapsed});
    std.debug.print("First and last position is {d} and {d}\n", .{ p.x, p.y });
}

pub fn findFirst(nums: []const u8, target: u8) i8 {
    var left: u8 = 0;
    var right: u8 = @intCast(nums.len);
    while (right >= left) {
        const mid: u8 = (right + left) / 2;
        if (nums[mid] == target) {
            if (mid == 0 or nums[mid - 1] != target) return @intCast(mid);
            right = mid - 1;
        } else if (nums[mid] > target) {
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    return -1;
}

pub fn findLast(nums: []const u8, target: u8) i8 {
    var left: u8 = 0;
    var right: u8 = @intCast(nums.len);
    while (right >= left) {
        const mid: u8 = (right + left) / 2;
        if (nums[mid] == target) {
            if (mid == @as(u8, @intCast(nums.len)) or nums[mid + 1] != target) return @intCast(mid);
            left = mid + 1;
        } else if (nums[mid] > target) {
            right = mid - 1;
        } else {
            left = mid + 1;
        }
    }
    return -1;
}

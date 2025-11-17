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

    for (nums, 0..) |num, i| {
        if (num == target) {
            if (p.x == -1) {
                p = point{ .x = @intCast(i), .y = @intCast(i) };
            } else {
                p.y = @intCast(i);
            }
        }
    }

    std.debug.print("First and last position is {d} and {d}\n", .{ p.x, p.y });
}

const std = @import("std");

const point = struct {
    x: i4,
    y: i4,

    fn toArray(this: point) [2]i4 {
        return .{ this.x, this.y };
    }
};

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const p: point = point{ .x = -1, .y = -1 };
    std.debug.print("Point array {any}\n", .{p.toArray()});
}

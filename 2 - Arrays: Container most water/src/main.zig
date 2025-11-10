const std = @import("std");

pub fn main() !void {
    const height = [_]u4{ 1, 8, 6, 2, 5, 7 };
    var left: u4 = 0;
    var right = height.len - 1;
    std.debug.print("Height {d} and lenght {d}\n", .{ left, right });

    var max_area: u64 = 0;
    while (left < right) {
        const width = right - left;
        if (height[left] < height[right]) {
            max_area = @max(max_area, width * height[left]);
            left += 1;
        } else {
            max_area = @max(max_area, width * height[right]);
            right -= 1;
        }
    }
    std.debug.print("Max area: {d}\n", .{max_area});
}

test "Test container most water" {
    try @call(.auto, main, .{});
}

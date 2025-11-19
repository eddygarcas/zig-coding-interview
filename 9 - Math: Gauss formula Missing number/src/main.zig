const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const input = [_]usize{ 5, 3, 2, 4, 0, 6, 1, 8, 9 };
    var sum: u8 = 0;
    // Apply Gauss formula
    for (input) |num| {
        sum += @intCast(num);
    }
    const i_sum: u8 = input.len * (input.len + 1) / 2;
    std.debug.print("The missing number is {d}\n", .{i_sum - sum});
}

const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const mountain = [_]u4{ 0, 4, 5, 6, 3, 2, 1, 1 };
    if (mountain.len < 3) return error.MountainLessThanThree;

    var max_value: u4 = 0;
    var max_index: u4 = 0;
    for (mountain, 0..) |elem, i| {
        if (elem > max_value) {
            max_value = elem;
            max_index = @intCast(i);
        }
    }
    std.debug.print("Max index: {d}\n", .{max_index});
    if ((max_index == (mountain.len - 1)) or (max_index == 0)) {
        return error.NoElementsToCover;
    }

    var valid: bool = false;

    m: for (mountain, 0..) |elem, i| {
        if (i == max_index) continue :m;
        if (elem < max_value) {
            valid = true;
        } else {
            valid = false;
            break :m;
        }
    }
    std.debug.print("Has a valid mountain array {any}\n", .{valid});

    // A more efficient way using while
    var i: usize = 0;

    while (i + 1 < mountain.len and mountain[i] < mountain[i + 1]) : (i += 1) {}

    if (i == 0 or i == mountain.len - 1) return error.NoElementToCover;

    while (i + 1 < mountain.len and mountain[i] >= mountain[i + 1]) : (i += 1) {}
    std.debug.print("Index {d} and len {d}\n", .{ i, (mountain.len - 1) });

    valid = i == mountain.len - 1;

    std.debug.print("Has a valid mountain using while {any}\n", .{valid});
}

test "Valid mountain array" {
    try @call(.auto, main, .{});
}

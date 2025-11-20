const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.

    const gpa = std.heap.page_allocator;
    var result = try std.ArrayList(u8).initCapacity(gpa, 5);
    defer result.deinit(gpa);

    const num_a = [_]u4{ 1, 0, 1, 1 };
    const num_b = [_]u4{ 1, 1, 0, 1 };

    // Use isize to avoid adding if ( i > 0)
    var i: isize = num_a.len;
    var j: isize = num_b.len;
    var carry: u8 = 0;

    while (i > 0 or j > 0 or carry != 0) : ({
        i -= 1;
        j -= 1;
    }) {
        var sum: u8 = carry;
        if (i > 0) sum += num_a[@intCast(i - 1)];
        if (j > 0) sum += num_b[@intCast(j - 1)];

        try result.append(gpa, @mod(sum, 2));
        carry = sum / 2;
    }
    std.mem.reverse(u8, result.items);

    std.debug.print("Result binary sum: {any}", .{result.items});
}

const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var people = [_]u4{ 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1 };
    const limit: u4 = 3;
    var boats: u4 = 0;

    std.sort.block(u4, people[0..], {}, std.sort.asc(u4));
    std.debug.print("Array of people {any}\n", .{people});
    var r = people.len - 1;
    var l: usize = 0;

    while (r > l) : (boats += 1) {
        if (people[r] + people[l] <= limit) {
            r -= 1;
            l += 1;
        } else {
            r -= 1;
        }
    }
    std.debug.print("Total boats {d}\n", .{boats});
}

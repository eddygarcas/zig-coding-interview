const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.

    const serie = [_]usize{ 2, 2, 1, 1, 4 };
    var final: usize = 0;
    // findSingleNumber returns the element that appears only once using XOR.
    // XOR properties used:
    // 1. a ^ a = 0 (XOR of a number with itself is 0)
    // 2. a ^ 0 = a (XOR of a number with 0 returns the number)
    // 3. a ^ b ^ a = b (XOR is associative and pairs cancel out)
    //
    // Example with binary representation:
    // input = [2, 2, 1, 1, 4]
    // 2:    0010
    // 2:    0010  -> 0010 ^ 0010 = 0000
    // 1:    0001
    // 1:    0001  -> 0000 ^ 0001 ^ 0001 = 0000
    // 4:    0100  -> 0000 ^ 0100 = 0100 (4)
    for (serie) |i| {
        final ^= i;
    }
    std.debug.print("Final number {d}\n", .{final});
}

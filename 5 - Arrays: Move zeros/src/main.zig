const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.

    var elements = [8]u8{ 6, 1, 0, 3, 0, 1, 0, 12 };
    // Here we are going to use a pointer to an array
    const elem_ptr: *[8]u8 = &elements;

    const start = std.time.nanoTimestamp();
    var position: usize = 0;

    for (elements[0..]) |element| {
        if (element != 0) {
            elem_ptr.*[position] = element;
            position += 1;
        }
    }
    std.debug.print("Half time result: {any}\n", .{elements});
    while (position < elements.len) : (position += 1) {
        elem_ptr[position] = 0;
    }
    std.debug.print("Result {any}\n", .{elements});
    const elapsed = std.time.nanoTimestamp() - start;
    std.debug.print("Elapsed time: {any}ns\n", .{elapsed});
}

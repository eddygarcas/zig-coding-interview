const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const elements = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 };
    std.debug.print("elements {any}\n", .{elements});

    var mid = elements.len / 2;
    var left: usize = 0;
    var right: usize = elements.len;

    while (left < right) {
        if (isBadVaersion(elements[mid])) {
            right = mid;
        } else {
            left = mid + 1;
        }
        mid = (right + left) / 2;
    }
    std.debug.print("First bad version {d}", .{elements[mid]});
}

fn isBadVaersion(version: usize) bool {
    return version >= 11;
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

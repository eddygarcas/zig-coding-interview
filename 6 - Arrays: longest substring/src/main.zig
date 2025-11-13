const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = std.heap.ArenaAllocator.init(gpa.allocator());
    defer allocator.deinit();

    const alloc = allocator.allocator();

    const elems = [_]u8{ 'a', 'c', 'c', 'd', 'e' };
    var subMap = std.hash_map.AutoHashMap(u8, usize).init(alloc);

    //var ans: usize = 0;
    var left: usize = 0;
    var right: usize = 0;

    for (elems, 0..) |elem, i| {
        if (subMap.get(elem)) |e| {
            const a: f64 = @floatFromInt(left);
            const b: f64 = @floatFromInt(e + 1);
            left = @intFromFloat(@max(a, b));
        }
        right += 1;

        try subMap.put(elem, i);
    }
}

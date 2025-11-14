const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var timer = try std.time.Timer.start();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = std.heap.ArenaAllocator.init(gpa.allocator());
    defer allocator.deinit();

    const alloc = allocator.allocator();

    const elems = [_]u8{ 'a', 'c', 'c', 'd', 'e' };
    var subMap = std.hash_map.AutoHashMap(u8, usize).init(alloc);
    defer subMap.deinit();

    var ans: usize = 0;
    var left: usize = 0;
    var right: usize = 0;

    for (elems, 0..) |elem, i| {
        if (subMap.get(elem)) |e| {
            left = @max(left, e + 1);
        }
        right += 1;

        try subMap.put(elem, i);
        ans = @max(right - left, ans);
    }
    const final: f64 = @floatFromInt(timer.lap() / std.time.ns_per_ms);

    std.debug.print("Time elapsed: {d:.3}ns\n", .{final});
    var it = subMap.iterator();
    while (it.next()) |kv| {
        std.debug.print("{},", .{kv.value_ptr.*});
    }
    std.debug.print("\nMax substring {d}\n", .{ans});
}

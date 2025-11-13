const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = std.heap.ArenaAllocator.init(gpa.allocator());
    defer allocator.deinit();

    const alloc = allocator.allocator();

    const elems = [_]u8{ 'a', 'c', 'c', 'd', 'e' };
    var subMap = std.hash_map.AutoHashMap(u8, usize).init(alloc);
}

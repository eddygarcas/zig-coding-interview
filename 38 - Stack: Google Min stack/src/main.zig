const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();
        // Use an struct like this rather than [][]T as far as allocation is concerned it's way simplier that
        // managing array matrix.
        const Entry = struct {
            value: T,
            min: T,
        };
        items: []Entry,
        allocator: std.mem.Allocator,
        lenght: usize,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Stack(T) {
            const items = try allocator.alloc(Entry, capacity);
            return .{
                .items = items,
                .allocator = allocator,
                .lenght = 0,
            };
        }

        pub fn top(self: *Stack(T)) ?Entry {
            if (self.lenght == 0) {
                return null;
            }
            return self.items[self.lenght - 1];
        }

        pub fn push(self: *Stack(T), value: T) !void {
            const minElement: T = if (self.top()) |e| @min(value, e.min) else value;

            if (self.lenght >= self.items.len) try self.realloc();

            self.items[self.lenght] = .{ .value = value, .min = minElement };
            self.lenght += 1;
        }

        pub fn pop(self: *Stack(T)) !T {
            if (self.lenght == 0) return error.NoElementsLeft;

            self.lenght -= 1;
            const elem = self.items[self.lenght];
            return elem.value;
        }

        // The solution is pretty straight forward, for every new element will check whether or not this new element
        // is less than the 'min' stored on the top element of the stack. So eventually just returning the 'min' value from the top
        // element of the stack would give us the stack minimum element.
        // Less efficient way would be go through the whole stack and compare to every element, which increase time complexity.
        // Another solution would be sort the stack first and then get the min element but again in this case an axuiliary stack would be
        // required to keep the original order, so not just intecreases the time complexity but also space.
        pub fn getMin(self: *Stack(T)) !T {
            var minElement: T = undefined;

            while (self.pop()) |elem| {
                minElement = @min(elem, minElement);
            }
        }

        // This solution will require a reallocation as initialize a minimum capacity was allocated, so as soon as
        // it reaches the capacity will re-allocate the array and double its size.
        fn realloc(self: *Stack(T)) !void {
            const new_capacity = self.items.len * 2;

            // Reallocator return a new memory address, so eventually the internal items array has to point to the new
            // one.
            const new_items = try self.allocator.realloc(self.items, new_capacity);
            self.items = new_items;

            const new_ptr = @intFromPtr(self.items.ptr);
            std.debug.print(
                "grow: mem. {d} -> {d} cap.\n",
                .{ new_ptr, self.items.len },
            );
        }

        pub fn deinit(self: *Stack(T)) void {
            self.allocator.free(self.items);
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    defer {
        const leaked = gpa.deinit();
        std.debug.assert(leaked == .ok);
    }

    var stack = try Stack(i32).init(allocator, 2);
    defer stack.deinit();
    try stack.push(5);
    try stack.push(30);
    try stack.push(-10);
    try stack.push(40);
    try stack.push(-5);
    try stack.push(32);
    try stack.push(34);
    std.debug.print("Stack items : {any}\n", .{stack.items});
    std.debug.print("Min element : {d}\n", .{stack.top().?.min});
    _ = try stack.pop();
    _ = try stack.pop();
    _ = try stack.pop();
    _ = try stack.pop();
    _ = try stack.pop();
    std.debug.print("Min element : {d}\n", .{stack.top().?.min});
}

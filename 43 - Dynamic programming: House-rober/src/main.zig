const std = @import("std");

fn Prospects(comptime T: type) type {
    return struct {
        const Self = @This();
        houses: std.ArrayList(T),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, numbers: []const T) !Self {
            var houses = try std.ArrayList(T).initCapacity(allocator, numbers.len);
            try houses.appendSlice(allocator, numbers[0..]);
            return .{
                .houses = houses,
                .allocator = allocator,
            };
        }

        pub fn robHouseFromTop(self: *Self, address: usize, route: *std.ArrayList(T)) !T {
            _ = self;
            _ = address;
            _ = route;

            return 0;
        }

        pub fn robHouseFromBottom(self: *Self) !T {
            _ = self;
        }

        pub fn deinit(self: *Self) void {
            self.houses.deinit(self.allocator);
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

    var prospects = try Prospects(u32).init(allocator, &[_]u32{ 1, 5, 3, 0, 9, 4, 1, 15 });
    defer prospects.deinit();

    var route = try std.ArrayList(u32).initCapacity(allocator, 1);
    defer route.deinit(allocator);

    const result = try prospects.robHouseFromTop(prospects.houses.items.len - 1, &route);
    _ = result;

    std.debug.print("Houses : {any}\n", .{prospects.houses.items});
}

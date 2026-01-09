const std = @import("std");

// This program solves the House Robber problem using dynamic programming.
// Problem: Given an array representing houses with money, determine maximum money
// that can be robbed without robbing adjacent houses.
//
// Dynamic Programming Approach:
// 1. For each house at index i, we have two choices:
//    a. Rob current house (i) and add it to max money from house (i-2)
//    b. Skip current house and take max money from house (i-1)
// 2. Use memoization array (route) to store computed results
// 3. Recurrence relation: dp[i] = max(nums[i] + dp[i-2], dp[i-1])
//
// Time Complexity: O(n) where n is number of houses
// Space Complexity: O(n) for memoization array
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

        // RobHouseFromTop calculates the maximum money that can be robbed from houses up to given address
        // using dynamic programming with memoization.
        // Parameters:
        //   - address: current house index being considered
        //   - route: memoization array storing max money for each house position
        //
        // The function achieves O(n) complexity by:
        // 1. First checking if result for current address is already calculated (route[address] > 0)
        // 2. If found, returns cached result instead of recalculating
        // 3. Otherwise calculates optimal money by either:
        //   - Including current house + max money from house (address-2)
        //   - Excluding current house and taking max money from house (address-1)
        //
        // 4. Caches and returns result
        pub fn robHouseFromTop(self: *Self, address: usize, route: *std.ArrayList(T)) !T {
            if (route.items[address] > 0) return route.items[address];
            if (address < 0) return 0;
            if (address == 0) return self.houses.items[0];
            if (address == 1) return @max(self.houses.items[0], self.houses.items[1]);

            const stoleHouse = self.houses.items[address] + try self.robHouseFromTop(address - 2, route);
            const notStoleHouse = try self.robHouseFromTop(address - 1, route);

            try route.insert(self.allocator, address, @max(stoleHouse, notStoleHouse));
            return route.items[address];
        }

        // RobHouseFromBottom calculates maximum money that can be robbed using bottom-up dynamic programming.
        // It iteratively builds the solution by:
        // 1. Handling base cases for 1-2 houses
        // 2. For each house i, choosing maximum between:
        //   - Previous max (not robbing current house)
        //   - Current house value + max money from i-2 houses
        //
        // Parameters: none
        // Returns: Maximum money that can be robbed
        pub fn robHouseFromBottom(self: *Self) T {
            if (self.houses.items.len == 1) return self.houses.swapRemove(0);

            var firstHouse = self.houses.swapRemove(0);
            var secondHouse = @max(firstHouse, self.houses.swapRemove(0));
            var result = secondHouse;

            // i=2: house=3  -> result=max(5, 3+1=4)    -> first=5, second=5
            // i=3: house=0  -> result=max(5, 0+5=5)    -> first=5, second=5
            // i=4: house=9  -> result=max(5, 9+5=14)   -> first=5, second=14
            // i=5: house=4  -> result=max(14, 4+5=9)   -> first=14, second=14
            // i=6: house=1  -> result=max(14, 1+14=15) -> first=14, second=15
            // i=7: house=15 -> result=max(15, 15+14=29)-> first=15, second=29
            for (self.houses.items) |item| {
                result = @max(secondHouse, (item + firstHouse));
                firstHouse = secondHouse;
                secondHouse = result;
            }
            return result;
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

    var route = try std.ArrayList(u32).initCapacity(allocator, 8);
    // Simpler way to initialize an array list. In this case we need this as the very first thing will check is the
    // the values in the route.
    try route.insertSlice(allocator, 0, &[_]u32{0} ** 8);
    defer route.deinit(allocator);

    const result = try prospects.robHouseFromTop(prospects.houses.items.len - 1, &route);

    std.debug.print("Money on Houses              : {any}\n", .{prospects.houses.items});
    std.debug.print("Result rob house from top    : {d}\n", .{result});

    const resultBottom = prospects.robHouseFromBottom();
    std.debug.print("Result rob house form bottom : {d}\n", .{resultBottom});
}

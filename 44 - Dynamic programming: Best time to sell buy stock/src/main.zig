const std = @import("std");

// This program solves the Best Time to Buy and Sell Stock problem using dynamic programming.
// Given an array of stock prices where prices[i] is the price on day i, find the maximum
// profit by choosing a single day to buy and a later day to sell.
//
// The algorithm uses a one-pass approach by tracking:
// - Minimum price seen so far (best buying opportunity)
// - Maximum profit possible by comparing (current price - minimum price)
// - Lower index to track the day with lowest price
// - Upper index to track the day with highest price after lowest price
//
// Example:
// Input prices: [1,5,3,0,9,4,1,15]
// Result: Buy at $1 (day 0), sell at $15 (day 7) for profit of $14
//
// Time Complexity: O(n) - single pass through prices array
// Space Complexity: O(1) - only tracking few variables regardless of input size
fn Stock(comptime T: type) type {
    return struct {
        const Self = @This();

        lowerIndex: T,
        upperIndex: T,
        prices: std.ArrayList(T),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, prices: []const T, lowerIndex: T, upperIndex: T) !*Stock(T) {
            const instance = try allocator.create(Self);
            var prices_copy = try std.ArrayList(T).initCapacity(allocator, prices.len);
            try prices_copy.appendSlice(allocator, prices[0..]);
            instance.* = .{
                .allocator = allocator,
                .lowerIndex = lowerIndex,
                .upperIndex = upperIndex,
                .prices = prices_copy,
            };
            return instance;
        }

        // bestSellingPrice recursively finds the optimal buying and selling prices to maximize profit.
        // The algorithm works by:
        // 1. Base case: when we reach end of prices array (i >= len(prices))
        //   - Check if we found valid buy/sell days (lowerIndex != -1 and before upperIndex)
        //   - Return error if no valid combination found
        //
        // 2. For each price:
        //   - Update minPrice if current price is lower
        //   - If new minPrice found, update lowerIndex if it's sequential
        //   - Calculate profit with current price (as potential sell price)
        //   - If profit is higher than maxProfit, update maxProfit and upperIndex
        //
        // 3. Recursively process next price
        //
        // Parameters:
        //
        //      minPrice: lowest price seen so far
        //      maxProfit: highest profit possible from prices seen so far
        //      i: current index in prices array
        //
        // Returns:
        //
        //      minPrice: final minimum price found
        //      maxProfit: maximum profit possible
        //      error: if no valid buy/sell combination found
        pub fn bestSellingPrice(self: *Self, minPrice: T, maxProfit: T, i: usize) !struct { T, T } {
            if (i >= self.prices.items.len) {
                if (self.lowerIndex == -1 or self.lowerIndex > self.upperIndex) {
                    return error.NoValidSellingPrice;
                }
                return .{ minPrice, maxProfit };
            }
            const min_price = @min(minPrice, self.prices.items[i]);
            if (min_price == self.prices.items[i] and i <= self.lowerIndex + 1) {
                self.lowerIndex = @intCast(i);
            }
            const current_profit = self.prices.items[i] - min_price;
            var max_profit = maxProfit;
            if (current_profit > maxProfit) {
                max_profit = current_profit;
                self.upperIndex = @intCast(i);
            }

            return self.bestSellingPrice(min_price, max_profit, i + 1);
        }

        // bestProfitSellingPriceNoDays calculates maximum profit possible by buying and selling once.
        // This simplified version only returns the profit amount without tracking buy/sell days.
        // Uses a single pass through prices to track minimum price seen and maximum profit possible.
        // Returns: Maximum profit achievable (may be 0 if no profit possible)
        pub fn bestProfitSellingPriceNoDays(self: *Self) !T {
            var buyPrice: T = std.math.maxInt(T);
            var profit: T = undefined;

            for (self.prices.items) |price| {
                if (price < buyPrice) {
                    buyPrice = price;
                } else {
                    profit = @max(profit, (price - buyPrice));
                }
            }
            return profit;
        }

        pub fn deinit(self: *Self) void {
            self.prices.deinit(self.allocator);
            self.allocator.destroy(self);
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

    var stock = try Stock(i32).init(allocator, &[_]i32{ 7, 1, 5, 3 }, -1, -1);
    defer stock.deinit();
    const result = try stock.bestSellingPrice(7, 0, 0);
    std.debug.print("Best selling price : {d}, price: {d}\n", .{ result[0], result[1] });

    const price_no_days = try stock.bestProfitSellingPriceNoDays();
    std.debug.print("Best price no days : {d}\n", .{price_no_days});
}

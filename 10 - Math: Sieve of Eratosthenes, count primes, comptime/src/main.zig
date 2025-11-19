const std = @import("std");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var start = try std.time.Timer.start();
    const primes: u8 = countPrimes(12);
    std.debug.print("Total number of primes {d}\n", .{primes});
    const elapsed = start.read();
    std.debug.print("Time elapsed {d}ns\n", .{elapsed});
}

fn countPrimes(comptime n: u8) u8 {
    if (n < 2) return 0;

    // Initialize all the array to true
    var isPrime = [_]bool{true} ** n;
    // set the first two positions as false as 1 and 2 are primes
    @memset(isPrime[0..2], false);

    // Apply Sieve formula
    const limit: u8 = @intFromFloat(@sqrt(@as(f64, @floatFromInt(n))));
    for (2..limit + 1) |i| {
        if (isPrime[i]) {
            var m: usize = i * i;
            while (m < n) : (m += i) {
                isPrime[m] = false;
            }
        }
    }
    std.debug.print("Total primes bool array {any}\n", .{isPrime});

    var count: u8 = 0;
    for (isPrime) |p| {
        if (p) {
            count += 1;
        }
    }
    return count;
}

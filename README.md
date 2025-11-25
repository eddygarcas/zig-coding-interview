# Zig Coding Interview Challenges

A comprehensive collection of coding interview problems implemented in Zig, covering essential algorithms and data structures commonly encountered in technical interviews.

## 🎯 Overview

This repository contains **18 coding challenges** organized by problem category, each implemented with clean, well-documented Zig code. The solutions demonstrate various algorithmic approaches, optimization techniques, and Zig-specific features like `comptime` evaluation.

## 📁 Project Structure

Each challenge is organized in its own directory with the following structure:
```
challenge-name/
├── src/
│   └── main.zig          # Main implementation
├── build.zig             # Build configuration
└── build.zig.zon         # Package configuration
```

## 🧮 Challenge Categories

### Arrays & Two Pointers
- **[2 - Container Most Water](./2%20-%20Arrays:%20Container%20most%20water/)** - Two-pointer technique for maximum area calculation
- **[3 - Valid Mountain Array](./3%20-%20Arrays:%20Valid%20mountain%20array/)** - Array validation with specific patterns
- **[4 - Boats to Save People](./4%20-%20Arrays:%20Boats%20to%20save%20people/)** - Greedy algorithm with two pointers
- **[5 - Move Zeros](./5%20-%20Arrays:%20Move%20zeros/)** - In-place array manipulation
- **[6 - Longest Substring](./6%20-%20Arrays:%20longest%20substring/)** - Sliding window technique
- **[7 - First and Last Position](./7%20-%20Arrays:%20First%20and%20last%20position/)** - Binary search implementation
- **[8 - First Bad Version](./8%20-%20Arrays:%20First%20bad%20version/)** - Binary search optimization

### Mathematics & Bit Manipulation
- **[9 - Missing Number (Gauss Formula)](./9%20-%20Math:%20Gauss%20formula%20Missing%20number/)** - Mathematical approach using sum formula
- **[10 - Sieve of Eratosthenes](./10%20-%20Math:%20Sieve%20of%20Eratosthenes,%20count%20primes,%20comptime/)** - Prime number generation with `comptime`
- **[11 - XOR Single Numbers](./11%20-%20Math:%20XOR%20Bitwise,%20single%20numbers/)** - Bitwise operations for finding unique elements
- **[12 - Robot Return to Origin](./12%20-%20Math:%20robot%20return%20to%20origin/)** - Coordinate tracking and validation
- **[13 - Binary Sum](./13%20-%20Math:%20Binary%20sum/)** - Binary arithmetic operations

### Hash Tables & Hash Maps
- **[14 - Two Sum](./14%20-%20Hash:%20two%20sum/)** - Classic hash map problem with O(n) solution
- **[15 - Contains Duplicates](./15%20-%20Hash:%20contains%20duplicates/)** - Duplicate detection using hash sets
- **[17 - 4Sum II](./17%20-%20Hash:%204sum2/)** - Advanced hash map usage for multi-array problems
- **[18 - Minimum Window Substring (Hard)](./18%20-%20Hash:%20Minimum%20window%20substring%20(hard)/)** - Complex sliding window with hash maps

### Advanced Algorithms
- **[16 - Boyer-Moore Majority Element](./16%20-%20Boyer-Moore,%20Majority%20element%20problem/)** - Voting algorithm implementation

## 🚀 Getting Started

### Prerequisites
- [Zig](https://ziglang.org/) (version 0.11.0 or later)

### Running a Challenge

Navigate to any challenge directory and run:

```bash
# Build and run
zig build run

# Run tests
zig build test

# Build only
zig build
```

### Example Usage

```bash
cd "14 - Hash: two sum"
zig build run
```

Expected output:
```
Positions 1 and 2
```

## 🔧 Key Zig Features Demonstrated

- **Memory Management**: Arena allocators, manual memory management
- **Comptime Evaluation**: Compile-time computations for performance
- **Error Handling**: Zig's explicit error handling with `try` and `!`
- **Type System**: Strong typing with type inference
- **Performance**: Zero-cost abstractions and manual optimizations
- **Hash Maps**: `std.hash_map.AutoHashMap` usage patterns
- **Slices vs Arrays**: Different approaches to data handling

## 📊 Complexity Analysis

Each solution includes:
- **Time Complexity**: Big O notation for runtime performance
- **Space Complexity**: Memory usage analysis
- **Alternative Approaches**: Multiple solution strategies where applicable

## 🎓 Learning Objectives

This collection helps you master:

1. **Algorithm Design Patterns**
   - Two pointers technique
   - Sliding window
   - Binary search
   - Hash table optimization

2. **Zig Programming Concepts**
   - Memory allocators
   - Comptime evaluation
   - Error handling
   - Performance optimization

3. **Interview Preparation**
   - Common problem patterns
   - Optimization techniques
   - Code organization
   - Testing strategies

## 🤝 Contributing

Feel free to:
- Add new challenges
- Improve existing solutions
- Add alternative implementations
- Enhance documentation
- Report issues or bugs

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Resources

- [Zig Language Reference](https://ziglang.org/documentation/master/)
- [Zig Standard Library](https://ziglang.org/documentation/master/std/)
- [LeetCode](https://leetcode.com/) - Source of many challenge problems
- [Zig Learning Resources](https://github.com/ziglang/zig/wiki/Learning-Resources)

---

**Happy Coding!** 🎉

*Each challenge is self-contained and can be studied independently. Start with the category that interests you most or follow the numerical order for a structured learning path.*

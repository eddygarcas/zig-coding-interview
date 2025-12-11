# Zig Coding Interview Challenges

A collection of coding interview challenges implemented in Zig. Each folder contains one or more solutions to a classic problem, often with multiple approaches in the same file (for example, naive vs optimized, hash map vs Boyer–Moore, or runtime vs `comptime` versions).

The goal of this project is to practice algorithms and data structures while learning how to write and structure real Zig programs. Many challenges are used to compare different techniques side by side.

## Overview

- **Language:** Zig
- **Focus:** Coding interview–style problems (LeetCode / big‑tech style)
- **Coverage:** Arrays, math / bitwise, hash maps, linked lists, trees, and more
- **Style:** Small, focused programs; many compare different approaches (e.g. hash map vs Boyer–Moore, brute force vs optimized, comptime use, etc.).

## Repository Structure

At the top level, each directory is one challenge (or a closely related set of variants for a single problem):

```text
2 - Arrays: Container most water/
3 - Arrays: Valid mountain array/
...
32 - Trees: Google mas depth of binary tree/
README.md
```

Inside a challenge directory:

```text
<n> - <Category>: <Title>/
├── src/
│   └── main.zig      # Main implementation file
├── build.zig         # Zig build definition
└── build.zig.zon     # Package metadata
```

Most problems are implemented entirely in `src/main.zig`. A single file will often contain:

- the main solution function(s)
- one or more alternative solutions (for comparison)
- small helper types (structs, enums) and utilities
- `test` blocks that exercise the implementation

## Challenge Categories

Below is a quick map of the current problems. Names are taken directly from the folders so you can copy–paste them into your shell.

### Arrays / Two Pointers / Sliding Window

- **2 - Arrays: Container most water** – two‑pointer maximum area
- **3 - Arrays: Valid mountain array** – array shape validation
- **4 - Arrays: Boats to save people** – greedy + two pointers
- **5 - Arrays: Move zeros** – in‑place reordering
- **6 - Arrays: longest substring** – sliding window
- **7 - Arrays: First and last position** – binary search variants
- **8 - Arrays: First bad version** – search over monotone predicate

### Math, Bitwise, Number Theory

- **9 - Math: Gauss formula Missing number** – missing value via sum formula
- **10 - Math: Sieve of Eratosthenes, count primes, comptime** – prime counting with `comptime`
- **11 - Math: XOR Bitwise, single numbers** – using XOR to isolate unique elements
- **12 - Math: robot return to origin** – coordinate accumulation
- **13 - Math: Binary sum** – binary addition

### Hash / Maps / Sets

- **14 - Hash: two sum** – classic two‑sum with a hash map
- **15 - Hash: contains duplicates** – duplicate detection with a set
- **17 - Hash: 4sum2** – counting zero‑sum 4‑tuples using hash maps
- **18 - Hash: Minimum window substring (hard)** – sliding window + hash counts
- **19 - Hash: Group anagrams** – grouping strings by signature
- **20 - Hash: LRU cache** – cache with eviction policy

### Majority / Voting Algorithms

- **16 - Boyer-Moore, Majority element problem** – hash‑map solution and Boyer–Moore voting

### Linked Lists

- **21 - LinkedList Apple linked list** – Apple‑style linked list question
- **22 - Linkedlist: Amazon linked list cycle** – cycle detection
- **23 - LinkedList: Microsoft reverse link list** – reversing a list
- **24 - LinkedList: Adobe linked list add two numbers** – addition via linked lists
- **25 - LinkedList: remove nth node from the end of the list** – two‑pointer removal
- **26 - LinkedList: Odd even LinkedList** – reordering by position

### Trees

- **31 - Trees: Microsoft trees question symetric trees** – symmetric tree check
- **32 - Trees: Google mas depth of binary tree** – maximum depth of a binary tree

There are more problems planned; new folders will follow the same naming pattern.

## How to Run a Challenge

From the repository root, change into the directory you want and use Zig’s build system. Each challenge has its own `build.zig`, so you always run commands from inside the challenge folder:

```bash
cd "14 - Hash: two sum"

# Build and run the example
zig build run

# Run tests (when defined for that challenge)
zig build test
```

This layout is repeated across all folders, so you can substitute any other challenge directory. When a file contains multiple solution variants, the `main` entry point usually selects one of them or runs a small comparison.

## What You Can Learn Here

- **Core interview patterns**
  - Two pointers
  - Sliding window
  - Binary search (including variants for first/last position)
  - Hash‑based counting and lookup
- **Zig concepts in practice**
  - Using the standard library (`std`) effectively
  - Allocators (e.g. `std.heap.ArenaAllocator`) and manual memory management
  - `comptime` for compile‑time work
  - Error handling with `!` and `try`

You can treat each folder as a small, focused Zig learning exercise.

## Contributing / Extending

You can extend this repo by:

- Adding new challenge folders following the existing naming scheme
- Providing alternative solutions (e.g. different time/space trade‑offs)
- Adding more tests inside existing `main.zig` files or splitting code into small helper modules

No strict style rules are enforced, but keeping code small, clear, and idiomatic to Zig is preferred.

## License

Unless specified otherwise, this project is intended as an open educational resource. If you plan to redistribute or use it in another project, consider adding an explicit license file that matches your needs (for example MIT or Apache‑2.0).


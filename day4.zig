const std = @import("std");

const input = @embedFile("assets/input4.txt");

const dirs: []const struct { i32, i32 } = &.{
    .{ -1, -1 },
    .{ -1, 0 },
    .{ -1, 1 },
    .{ 0, -1 },
    .{ 0, 1 },
    .{ 1, -1 },
    .{ 1, 0 },
    .{ 1, 1 },
};

const p1_search: []const u8 = "XMAS";
const p2_search: []const u8 = "MAS";

pub fn search_grid_p1(grid: []const []const u8, search: []const u8) u32 {
    var found: u32 = 0;
    _ = &found;
    for (grid, 0..) |row, y| {
        _ = y;
        for (row, 0..) |col, x| {
            _ = x;
            if (col == 'X') {
                for (dirs) |dir| {
                    _ = dir;
                    for (0..search.len - 1) |i| {
                        _ = i;
                        found += 1;
                    }
                }
            }
        }
    }
    return found;
}

pub fn main() !void {
    var part1: u64 = 0;
    var part2: u64 = 0;
    _, _ = .{ &part1, &part2 };
    std.debug.print("dirs: {*} {}\n", .{ dirs.ptr, dirs.len });

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var grid = std.ArrayList([]const u8).init(allocator);
    defer grid.deinit();

    var row_iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (row_iter.next()) |row| {
        try grid.append(row);
    }
    std.debug.print("{*}: {}, {*}: {}\n", .{ grid.items.ptr, grid.items.len, grid.items[0].ptr, grid.items[0].len });
    part1 += search_grid_p1(grid.items, p1_search);

    std.debug.print("part 1: {}\n", .{part1});
    std.debug.print("part 2: {}\n", .{part2});
}

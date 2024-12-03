const std = @import("std");

const input = @embedFile("assets/input2.txt");

const MAX_NUM_PER_ENTRY = 10;
var num_buf: [MAX_NUM_PER_ENTRY]i32 = undefined;

const State = enum {
    INIT,
    CHECK_INC_DEC,
    INCREASING,
    DECREASING,
    FAILED,
};

pub fn is_safe(nums: []const i32, limit: i32) bool {
    var state: State = .INIT;
    var last_num: i32 = 0;
    for (nums) |num| {
        switch (state) {
            .INIT => {
                state = .CHECK_INC_DEC;
            },
            .CHECK_INC_DEC => {
                if (num > last_num) {
                    if (num - last_num <= limit) {
                        state = .INCREASING;
                    } else {
                        state = .FAILED;
                        break;
                    }
                } else if (num < last_num) {
                    if (last_num - num <= limit) {
                        state = .DECREASING;
                    } else {
                        state = .FAILED;
                        break;
                    }
                } else {
                    state = .FAILED;
                    break;
                }
            },
            .DECREASING => {
                if (num >= last_num or (last_num - num) > limit) {
                    state = .FAILED;
                    break;
                }
            },
            .INCREASING => {
                if (num <= last_num or (num - last_num) > limit) {
                    state = .FAILED;
                    break;
                }
            },
            .FAILED => {
                break;
            },
        }
        last_num = num;
    }
    // if (state == .FAILED) {
    //     std.debug.print("Unsafe: {any}\n", .{nums});
    // } else {
    //     std.debug.print("Safe: {any}\n", .{nums});
    // }
    return state != .FAILED;
}

pub fn main() !void {
    var part1: u32 = 0;
    var part2: u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var line_num: usize = 0;
    while (lines.next()) |line| {
        line_num += 1;
        var readings = std.mem.tokenizeScalar(u8, line, ' ');
        var i: usize = 0;
        while (readings.next()) |reading| : (i += 1) {
            const num = try std.fmt.parseInt(i32, reading, 10);
            if (i >= MAX_NUM_PER_ENTRY) {
                std.debug.print("Entry on line {} exceeds buffer length {}\n", .{ line_num, MAX_NUM_PER_ENTRY });
                return error.InputTooLong;
            }
            num_buf[i] = num;
        }
        if (is_safe(num_buf[0..i], 3)) {
            part1 += 1;
        }
    }

    std.debug.print("part 1: {}\n", .{part1});
    _ = &part2;
    std.debug.print("part 2: {}\n", .{part2});
}

test "part 1" {
    const safe_vectors = [_][]const i32{
        &.{ 1, 2, 3, 4, 5 },
        &.{ 5, 4, 3, 2, 1 },
    };
    for (safe_vectors) |vec| {
        std.testing.expect(is_safe(vec, 3)) catch {
            std.debug.print("failed safe input: {any}\n", .{vec});
            return error.TestUnexpectedResult;
        };
    }

    const unsafe_vectors = [_][]const i32{
        &.{ 1, 1, 2, 3, 4 },
        &.{ 1, 2, 6, 7, 8 },
        &.{ 1, 2, 3, 4, 4 },
        &.{ 1, 2, 5, 4, 7 },
        &.{ 5, 6, 3, 2, 1 },
    };
    for (unsafe_vectors) |vec| {
        std.testing.expect(!is_safe(vec, 3)) catch {
            std.debug.print("failed unsafe input: {any}\n", .{vec});
            return error.TestUnexpectedResult;
        };
    }
}

test "part 2" {}

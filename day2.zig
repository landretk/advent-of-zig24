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

pub fn is_safe(nums: []const i32, limit: i32, ignore: ?usize) bool {
    var state: State = .INIT;
    var last_num: i32 = 0;
    var i: usize = 0;
    for (nums) |num| {
        if (ignore != null and i == ignore.?) {
            i += 1;
            continue;
        }
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
        i += 1;
    }
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
        if (is_safe(num_buf[0..i], 3, null)) {
            part1 += 1;
            part2 += 1;
        } else {
            for (0..i) |ignore_idx| {
                if (is_safe(num_buf[0..i], 3, ignore_idx)) {
                    part2 += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("part 1: {}\n", .{part1});
    std.debug.print("part 2: {}\n", .{part2});
}

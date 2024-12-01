const std = @import("std");

// const input =
//   \\1  2
//   \\3  4
//   \\5
// ;

const input = @embedFile("assets/input1.txt");
const MAX_INPUT_LEN = 1000;

const Number = u32;
const NumberPairs = struct {
    l: [MAX_INPUT_LEN]Number,
    r: [MAX_INPUT_LEN]Number,
};

var num_list: NumberPairs = undefined;

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var input_len: u32 = 0;
    while (lines.next()) |line| {
        var parts = std.mem.tokenizeScalar(u8, line, ' ');
        const ltkn, const rtkn = .{ parts.next(), parts.next() };
        if (ltkn != null and rtkn != null) {
            if (input_len >= MAX_INPUT_LEN) {
                std.debug.print("error: input longer than {} lines\n", .{MAX_INPUT_LEN});
                return error.InputTooLong;
            }
            num_list.l[input_len], num_list.r[input_len] = .{
                try std.fmt.parseInt(Number, ltkn.?, 10),
                try std.fmt.parseInt(Number, rtkn.?, 10),
            };
            input_len += 1;
        }
    }
    // std.debug.print("read {} pairs from input\n", .{input_len});

    std.mem.sort(Number, num_list.l[0..input_len], {}, std.sort.asc(Number));
    std.mem.sort(Number, num_list.r[0..input_len], {}, std.sort.asc(Number));

    // std.debug.print("sorted head: {any}, {any}\n", .{ input_numbers.l[0..5], input_numbers.r[0..5] });

    var part1: u64 = 0;
    for (0..input_len) |i| {
        part1 += @abs(@as(i64, num_list.r[i]) - @as(i64, num_list.l[i]));
    }
    std.debug.print("part 1: {}\n", .{part1});

    var part2: u64 = 0;
    for (num_list.l[0..input_len]) |l| {
        for (num_list.r[0..input_len]) |r| {
            if (l == r) {
                part2 += l;
            }
        }
    }
    std.debug.print("part 2: {}\n", .{part2});
}

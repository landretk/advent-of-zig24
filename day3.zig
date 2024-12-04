const std = @import("std");

const input = @embedFile("assets/input3.txt");

pub fn next_byte(reader: std.io.AnyReader) ?u8 {
    return reader.readByte() catch null;
}

const ParseState = enum {
    start,
    do,
    dont,
    mul,
};

const ParseStateMatchers = std.EnumArray(ParseState, []const u8).init(.{
    .start = "",
    .do = "do()",
    .dont = "don't()",
    .mul = "mul(ab)",
});

const ParseResult = struct {
    p1_res: u32 = 0,
    p2_res: u32 = 0,
};

const Parser = struct {
    state: ParseState = .start,
    idx: usize = 0,
    enabled: bool = true,
    n1: u32 = 0,
    n2: u32 = 0,

    const n1_idx = std.mem.indexOf(u8, ParseStateMatchers.get(.mul), "a").?;
    const n2_idx = std.mem.indexOf(u8, ParseStateMatchers.get(.mul), "b").?;

    pub fn iterator(self: *Parser, in_reader: std.io.AnyReader) ParseIterator {
        return ParseIterator{
            .reader = in_reader,
            .parser = self,
        };
    }

    fn match_idx(self: *const Parser, c: u8) bool {
        return c == ParseStateMatchers.get(self.state)[self.idx];
    }

    pub fn reset(self: *Parser) void {
        self.state = .start;
        self.idx = 0;
    }

    pub fn parse(self: *Parser, c: u8) ParseResult {
        switch (self.state) {
            .start => {
                switch (c) {
                    'd' => {
                        self.state = .do;
                        self.idx += 1;
                    },
                    'm' => {
                        self.n1 = 0;
                        self.n2 = 0;
                        self.state = .mul;
                        self.idx += 1;
                    },
                    else => {
                        self.reset();
                    },
                }
            },
            .do => {
                if (self.idx == 2) {
                    switch (c) {
                        '(' => self.idx += 1,
                        'n' => {
                            self.state = .dont;
                            self.idx += 1;
                        },
                        else => {},
                    }
                } else if (self.match_idx(c)) {
                    if (c == ')') {
                        self.enabled = true;
                        self.reset();
                    } else {
                        self.idx += 1;
                    }
                } else {
                    self.reset();
                }
            },
            .dont => {
                if (self.match_idx(c)) {
                    if (c == ')') {
                        self.enabled = false;
                        self.reset();
                    } else {
                        self.idx += 1;
                    }
                } else {
                    self.reset();
                }
            },
            .mul => {
                if (self.idx == n1_idx) {
                    switch (c) {
                        '0'...'9' => {
                            self.n1 *= 10;
                            self.n1 += c - '0';
                        },
                        ',' => {
                            self.idx += 1;
                        },
                        else => {
                            self.reset();
                        },
                    }
                } else if (self.idx == n2_idx) {
                    switch (c) {
                        '0'...'9' => {
                            self.n2 *= 10;
                            self.n2 += c - '0';
                        },
                        ')' => {
                            var result = ParseResult{};
                            result.p1_res = self.n1 * self.n2;
                            if (self.enabled) result.p2_res = result.p1_res;
                            self.reset();
                            return result;
                        },
                        else => {
                            self.reset();
                        },
                    }
                } else if (self.match_idx(c)) {
                    self.idx += 1;
                } else {
                    self.reset();
                }
            },
        }
        return ParseResult{};
    }
};

const ParseIterator = struct {
    reader: std.io.AnyReader,
    parser: *Parser,

    pub fn next(self: ParseIterator) ?ParseResult {
        const c = next_byte(self.reader);
        if (c) |val| {
            return self.parser.parse(val);
        } else {
            return null;
        }
    }
};

pub fn main() !void {
    var in_stream = std.io.fixedBufferStream(input);
    const in_reader = in_stream.reader().any();
    var parser = Parser{};
    const parse_iterator = parser.iterator(in_reader);

    var part1: u64 = 0;
    var part2: u64 = 0;

    while (parse_iterator.next()) |res| {
        part1 += res.p1_res;
        part2 += res.p2_res;
    }

    std.debug.print("part 1: {}\n", .{part1});
    std.debug.print("part 2: {}\n", .{part2});
}

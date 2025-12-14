const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
    //const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    var grid = std.ArrayList([]u8){};
    defer {
        grid.deinit(alloc);
    }
    var ops = std.ArrayList(u8){};
    defer ops.deinit(alloc);
    var stage: u8 = 0;
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        if (line[0] == '*' or line[0] == '+') {
            stage += 1;
        }
        switch (stage) {
            0 => {
                try grid.append(alloc, line);
            },
            1 => {
                var s_idx: u16 = 0;
                while (s_idx < line.len and line[s_idx] == ' ') s_idx += 1;
                var e_idx: u16 = s_idx;
                while (e_idx < line.len) {
                    while (e_idx < line.len and line[e_idx] != ' ') e_idx += 1;
                    if (e_idx - s_idx != 1) unreachable;
                    try ops.append(alloc, line[s_idx]);
                    while (e_idx < line.len and line[e_idx] == ' ') e_idx += 1;
                    s_idx = e_idx;
                }
            },
            else => unreachable,
        }
    }
    var breaks = std.ArrayList(usize){};
    try breaks.append(alloc, 0);
    defer breaks.deinit(alloc);
    outer: for (0..grid.items[0].len) |i| {
        var all_space = true;
        for (grid.items) |col| {
            if (i >= col.len) {
                break :outer;
            }
            all_space &= col[i] == ' ';
        }
        if (all_space) {
            try breaks.append(alloc, i);
        }
    }

    var cols = std.ArrayList(std.ArrayList([]u8)){};
    defer for (cols.items) |*c| {
        c.deinit(alloc);
        cols.deinit(alloc);
    };
    if (breaks.items.len != ops.items.len) unreachable;
    var ms: usize = 0;
    for(grid.items) |r| {
        ms = @max(r.len, ms);
    }
    try breaks.append(alloc, ms);
    var res: u64 = 0;
    for (1..breaks.items.len) |i| {
        const prev = breaks.items[i - 1];
        var cur = breaks.items[i] - 1;
//        std.debug.print("{} {}\n", .{prev, cur});
        var ir: u64 = if (ops.items[i - 1] == '*') 1 else 0;
        while (cur > prev or cur == 0) : (cur -= 1) {
            var num: u64 = 0;
            for (grid.items) |r| {
                const c = if (cur < r.len) r[cur] else ' ';
                if (c == ' ') continue;
                num *= 10;
                num += c - '0';
            }
//            std.debug.print("{}{c}", .{num, ops.items[i-1]});
            if (ops.items[i-1] == '*') ir *= num
            else if (ops.items[i-1] == '+') ir += num
            else unreachable;
            if (cur == 0) break;
        }
//        std.debug.print("={}\n\n", .{ir});
        res += ir;
    }
    std.debug.print("{}\n", .{res});
}

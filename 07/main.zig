const std = @import("std");

const pos = struct {
    x: usize,
    y: usize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
//    const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    var grid = std.ArrayList([]u8){};
    defer grid.deinit(alloc);
    var start: pos = undefined;
    var is: usize = 0;
    while (true): (is+=1) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        try grid.append(alloc, line);
        for(line, 0..line.len) |c, j| if (c=='S') {start = pos{.x = is, .y = @intCast(j)};};
    }
    var res: usize = 0;
    var dp = std.ArrayList(std.ArrayList(usize)){};
    try dp.resize(alloc, grid.items.len);
    for(dp.items) |*i| {
        i.* = std.ArrayList(usize){};
        try i.*.resize(alloc, grid.items[0].len);
        @memset(i.*.items, 0);
    }
    defer {
        for(dp.items) |*c| c.deinit(alloc);
        dp.deinit(alloc);
    }

    // init the dp
    dp.items[start.x].items[start.y] = 1;
    const w = grid.items[0].len;
    for(start.x..grid.items.len-1) |i| {
        const line = dp.items[i].items;
        const ndp = dp.items[i+1].items;
        const nline = grid.items[i+1];
        for(0..w) |j| {
            const c = line[j];
            if (c == 0) continue;
            if (nline[j] == '^') {
                if (j>0)
                    ndp[j-1] += c;
                if (j+1<nline.len)
                    ndp[j+1] += c;
            } else {
                ndp[j] += c;
            }
        }
    }
    for(dp.items[dp.items.len-1].items) |n| {
        res += n;
    }
    std.debug.print("{}\n", .{res});
}

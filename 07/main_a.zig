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
    grid.items[start.x][start.y] = '|';
    var res: usize = 0;
    for(start.x..grid.items.len-1) |i| {
        const line = grid.items[i];
        const nline = grid.items[i+1];
        for(0..line.len) |j| {
            const c = line[j];
            if (c != '|') continue;
            if (nline[j] == '^') {
                res += 1;
                if (j>0)
                    nline[j-1] = '|';
                if (j+1<nline.len)
                    nline[j+1] = '|';
            } else {
                nline[j] = '|';
            }
        }
    }
    std.debug.print("{}\n", .{res});
}

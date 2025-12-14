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
   // const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);

    var poss = std.ArrayList(pos){};
    defer poss.deinit(alloc);
    const comma = ",";
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const comidx = std.mem.indexOf(u8, line, comma).?;
        const x = try std.fmt.parseInt(usize, line[0..comidx], 10);
        const y = try std.fmt.parseInt(usize, line[comidx + 1 ..], 10);
        try poss.append(alloc, pos{ .x = x, .y = y });
    }
    var res: usize = 0;
    for (0..poss.items.len) |i| {
        const a = poss.items[i];
        for (i + 1..poss.items.len) |j| {
            const b = poss.items[j];
            const xw: usize = if (a.x > b.x) a.x - b.x + 1 else b.x - a.x + 1;
            const yw: usize = if (a.y > b.y) a.y - b.y + 1 else b.y - a.y + 1;
            res = @max(xw * yw, res);
        }
    }
    std.debug.print("{}\n", .{res});
}

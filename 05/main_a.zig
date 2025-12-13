const std = @import("std");

const range = struct {
    from: u64,
    to: u64,
};
fn range_cmp(_: void, lhs: range, rhs: range) bool {
    return lhs.from < rhs.from;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const filecontents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
    //const filecontents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(filecontents);
    var reader = std.Io.Reader.fixed(filecontents);
    var ranges = std.ArrayList(range){};
    defer ranges.clearAndFree(alloc);
    var ings = std.ArrayList(u64){};
    defer ings.clearAndFree(alloc);
    var stage: i32 = 0;
    const eq = "-";
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        if (line.len == 0) {
            stage += 1;
            continue;
        }
        switch (stage) {
            0 => {
                const idx = if (std.mem.lastIndexOf(u8, line, eq)) |v| v else unreachable;
                const from = try std.fmt.parseInt(u64, line[0..idx], 10);
                const to = try std.fmt.parseInt(u64, line[idx + 1 ..], 10);
                try ranges.append(alloc, range{ .from = from, .to = to });
            },
            1 => {
                const ing = try std.fmt.parseInt(u64, line, 10);
                try ings.append(alloc, ing);
            },
            else => unreachable,
        }
    }
    std.sort.heap(range, ranges.items, {}, range_cmp);
    var res: u64 = 0;
    for (ings.items) |ing| {
        var good = false;
        for (ranges.items) |r| {
            good |= ing >= r.from and ing <= r.to;
        }
        if (good) res += 1;
    }
    std.debug.print("{}\n", .{res});
}

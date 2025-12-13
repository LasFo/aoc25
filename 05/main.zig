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
    var stage: i32 = 0;
    const eq = "-";
    read: while (true) {
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
                break :read;
            },
            else => unreachable,
        }
    }
    std.sort.heap(range, ranges.items, {}, range_cmp);
    const ln = ranges.items.len;
    var i: u32 = 0;
    var ranges_merged = std.ArrayList(range){};
    defer ranges_merged.deinit(alloc);
    var cr = ranges.items[0];
    while (i < ln) {
        const r = ranges.items[i];
        if (cr.to >= r.from) {
            cr.to = @max(r.to, cr.to);
        } else {
            try ranges_merged.append(alloc, cr);
            cr = r;
        }
        i += 1;
       // std.debug.print("[{},{}]\n", .{ cr.from, cr.to });
    }
    try ranges_merged.append(alloc, cr);
    var res: u64 = 0;
    for (ranges_merged.items) |r| {
        res += 1 + r.to - r.from;
    }
    std.debug.print("{}\n", .{res});
}

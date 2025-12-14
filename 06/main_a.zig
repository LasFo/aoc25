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
    var rows = std.ArrayList(std.ArrayList(u64)){};
    defer {
        for (rows.items) |*r| r.deinit(alloc);
        rows.deinit(alloc);
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
                var s_idx: u16 = 0;
                while (s_idx < line.len and line[s_idx] == ' ') s_idx += 1;
                var e_idx: u16 = s_idx;
                var al = std.ArrayList(u64){};
                while (e_idx < line.len) {
                    while (e_idx < line.len and line[e_idx] != ' ') e_idx += 1;
                    if (e_idx == s_idx) {
                        std.debug.print("{}", .{s_idx});
                        for (line) |c|
                            std.debug.print("{c}", .{c});
                        std.debug.print("\n", .{});
                    }
                    const num = try std.fmt.parseInt(u64, line[s_idx..e_idx], 10);
                    try al.append(alloc, num);
                    while (e_idx < line.len and line[e_idx] == ' ') e_idx += 1;
                    s_idx = e_idx;
                }
                rows.append(alloc, al) catch al.deinit(alloc);
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
    var res: u64 = 0;
    for (0..ops.items.len, ops.items) |j, o| {
        var ir: u64 = if (o == '*') 1 else 0;
        for (0..rows.items.len) |idx| {
            if (o == '*') {
                ir *= rows.items[idx].items[j];
            } else if (o == '+'){
                ir += rows.items[idx].items[j];
            } else {
                unreachable;
            }
        }
        res += ir;
    }
    std.debug.print("{}\n", .{res});
}

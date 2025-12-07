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
    var res: u128 = 0;
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        var ds: [12]u8 = undefined;
        for(0..12) |i| ds[i] = line[i];
        var dis: [12]usize = undefined;
        for(0..12) |i| dis[i] = i;
        @memset(ds[0..], '0');
        var i: usize = 0;
        outer: while (i < line.len) : (i+=1) {
            var start: usize = 0;
            if (i + 12 > line.len) start = i + 12 - line.len;
            for (start..12) |j| {
                if (dis[j] > i) break;
                if (line[i] > ds[j]) {
                    for (0..(12-j)) |k| {
                        ds[j+k] = line[i + k];
                        dis[j+k] = i+k;
                    }
                    continue :outer;
                }
            }
        }
        var c: u128 = 0;
        for (0..12) |j| {
            c *= 10;
            c += @intCast(ds[j] - '0');
        }
        res += c;
    }
    std.debug.print("{}\n", .{res});
}

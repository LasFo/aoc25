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
    var res: i32 = 0;
    while (true) {
        const line = reader.takeDelimiterInclusive('\n') catch break;
        var d0: u8 = 0;
        var d1: u8 = 0;
        for (0..line.len - 2) |i| {
            if (line[i] > d0) {
                d1 = line[i+1];
                d0 = line[i];
                continue;
            }
            if (line[i] > d1) {
                d1 = line[i];
            }
        }
        if (line[line.len-2] > d1) d1 = line[line.len-2];
        std.debug.print("{c} {c}\n", .{d0, d1});
        var c:i32 = @intCast(d0 - '0');
        c *= 10;
        c += @intCast(d1 - '0');
        res += c;
    }
    std.debug.print("{}\n", .{res});
}

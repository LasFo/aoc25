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
    const sz = [_]i32{ 7, 7, 7, 5, 6, 7 };
    var res:u32 =0;
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const dim_w = try std.fmt.parseInt(i32, line[0..2], 10);
        const dim_h = try std.fmt.parseInt(i32, line[3..5], 10);
        const idx: usize = 7;
        var size: i32 = dim_w*dim_h;
        for (0..6) |i| {
            const num = try std.fmt.parseInt(i32, line[(i*3)+idx..(i*3)+idx+2], 10);
            size -= sz[i]*num;
        }
        if (size >= 0) res+=1;
    }
    std.debug.print("{}\n", .{res});
}

const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
//    const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    var val: i16 = 50;
    var zeros: u16 = 0;
    while (true) {
        const line = reader.takeDelimiterInclusive('\n') catch break;
        const num = try std.fmt.parseInt(i16, line[1..line.len-1], 10);
        std.debug.print("{} {c} {} ", .{val, line[0], num});
        var n:u16 = 0;
        const old_val = val;
        switch (line[0]) {
            'L' => {
                val = val - num;
                if (val == 0) n += 1;
            },
            'R' => val = val  + num,
            else => {
                std.debug.print("{}\n", .{line[0]});
                unreachable;
            },
        }
        n += @abs(@divTrunc(val,100));
        if (val < 0 and old_val != 0) {
            n+=1;
        }
        val = @mod(val,100);
        std.debug.print(" = {} => n={}\n", .{val, n});
        zeros += n;
    }

    // Print file contents
    std.debug.print("{}\n", .{zeros});
}

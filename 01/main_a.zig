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
        switch (line[0]) {
            'L' => val = @mod(val - num, 100),
            'R' => val = @mod(val  + num,  100),
            else => {
                std.debug.print("{}\n", .{line[0]});
                unreachable;
            },
        }
        zeros += if(val == 0) 1 else 0;
    }

    // Print file contents
    std.debug.print("{}\n", .{zeros});
}

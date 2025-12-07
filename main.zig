const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
//    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
    const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
    }
}

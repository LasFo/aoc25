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
    var res: i64 = 0;
    while (true) {
        var from = reader.takeDelimiterExclusive('-') catch break;
        _ = if (reader.discard(@enumFromInt(1)) == std.io.Reader.Error.EndOfStream) break;
        var to = reader.takeDelimiterExclusive(',') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const eql = to.len == from.len;
        if (eql and (to.len % 2 == 1)) continue;
        var addr: ?[]u8 = null;
        defer if (addr) |a| alloc.free(a);
        if (!eql) {
            if (from.len % 2 != 0) {
                from = try alloc.alloc(u8, to.len);
                @memset(from, '0');
                from[0] = '1';
                addr = from;
            } else if (to.len % 2 != 0) {
                to = try alloc.alloc(u8, from.len);
                @memset(to, '9');
                addr = to;
            } else {
                unreachable;
            }
        }

        // parse stuff
        const hl = @divTrunc(from.len + 1, 2);
        var fromubi = try std.fmt.parseInt(i64, from[0..hl], 10);
//        std.debug.print("starting with: {}\n", .{fromubi});
        const fromalli = try std.fmt.parseInt(i64, from, 10);
        const toubi = try std.fmt.parseInt(i64, to[0..hl], 10);
        const toalli = try std.fmt.parseInt(i64, to, 10);
        const tmpfrom = try alloc.alloc(u8, from.len);

        // compute all candidates
        defer alloc.free(tmpfrom);
        @memset(tmpfrom, '0');
        while (fromubi <= toubi) {
            const n = std.fmt.printInt(tmpfrom, fromubi, 10, std.fmt.Case.lower, std.fmt.Options{});
            _ = std.fmt.printInt(tmpfrom[n..], fromubi, 10, std.fmt.Case.lower, std.fmt.Options{});
//            std.debug.print("{} = {s}\n", .{ m, tmpfrom });
            const cand = try std.fmt.parseInt(i64, tmpfrom, 10);
            if (fromalli <= cand and cand <= toalli)
                res += cand;
            fromubi +=1;
        }
    }
    std.debug.print("{}\n", .{res});
}

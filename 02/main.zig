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
        const from = reader.takeDelimiterExclusive('-') catch break;
        _ = if (reader.discard(@enumFromInt(1)) == std.io.Reader.Error.EndOfStream) break;
        const to = reader.takeDelimiterExclusive(',') catch break;
        _ = try reader.discard(@enumFromInt(1));

        // parse stuff
        var fromalli = try std.fmt.parseInt(i64, from, 10);
        const toalli = try std.fmt.parseInt(i64, to, 10);

        // compute all candidates
        const tmpfrom = try alloc.alloc(u8, to.len);
        defer alloc.free(tmpfrom);
        while (fromalli <= toalli) : (fromalli += 1) {
            const n = std.fmt.printInt(tmpfrom, fromalli, 10, std.fmt.Case.lower, std.fmt.Options{});
            if (n == 1) continue;
            const cand = tmpfrom[0..n];
            for (0..@divTrunc(n + 1, 2)) |i| {
                if (cand.len % (i + 1) != 0) continue;
                const ss = cand[0 .. i + 1];
                var allequal: bool = true;
                eqloop: for (1..@divExact(cand.len, i + 1)) |j| {
                    for (0..ss.len) |k| {
                        if (cand[j * ss.len + k] != ss[k]) {
                            allequal = false;
                            break :eqloop;
                        }

                    }
                }
                if (allequal) {
                    res += fromalli;
                    break;
                }
            }
        }
    }
    std.debug.print("{}\n", .{res});
}

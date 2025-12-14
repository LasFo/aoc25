const std = @import("std");
const dsu = @import("dsu.zig");

const pos = struct {
    x: f64,
    y: f64,
    z: f64,
};

const dist = struct {
    dist: f64,
    idx_a: usize,
    idx_b: usize,

    fn cmp(_: void, lhs: dist, rhs: dist) bool {
        if (lhs.dist < rhs.dist) return true;
        if (lhs.dist > rhs.dist) return false;
        if (lhs.idx_a < rhs.idx_a) return true;
        if (lhs.idx_a > rhs.idx_a) return false;
        return lhs.idx_b < rhs.idx_b;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
    //const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    var poss = std.ArrayList(pos){};
    defer poss.deinit(alloc);
    const comma = ",";
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const first = std.mem.indexOf(u8, line, comma).?;
        const last = std.mem.lastIndexOf(u8, line, comma).?;
        const x = try std.fmt.parseFloat(f64, line[0..first]);
        const y = try std.fmt.parseFloat(f64, line[first+1..last]);
        const z = try std.fmt.parseFloat(f64, line[last+1..]);
        const p  = pos{.x=x,.y=y,.z=z};
        try poss.append(alloc, p);
    }
    var dists = std.ArrayList(dist){};
    try dists.ensureTotalCapacity(alloc, poss.items.len*poss.items.len);
    defer dists.deinit(alloc);
    const before = std.time.milliTimestamp();
    for(0..poss.items.len) |i| {
        for(i+1..poss.items.len) |j| {
            const a = poss.items[i];
            const b = poss.items[j];
            const sum =
                std.math.pow(f64, (a.x - b.x), 2) +
                std.math.pow(f64, (a.y - b.y), 2) +
                std.math.pow(f64, (a.z - b.z), 2);
            const di = std.math.sqrt(sum);
            try dists.append(alloc, dist{.dist = di, .idx_a = i, .idx_b = j});
        }
    }
    std.sort.heap(dist, dists.items, {}, dist.cmp);
    std.debug.print("computing and sorting dists took {}ms\n", .{std.time.milliTimestamp()-before});
    const d = dsu.dsu.new(alloc, poss.items.len);
    defer d.deinit();
    for(0..dists.items.len) |i| {
        const di = dists.items[i];
        if(poss.items.len == d.size(d.merge(di.idx_a, di.idx_b))) {
            std.debug.print("{}\n", .{poss.items[di.idx_a].x*poss.items[di.idx_b].x});
            return {};
        }
    }
}

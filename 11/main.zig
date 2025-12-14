const std = @import("std");

var res: usize = 0;

const Err = error{
    cycle,
};

const vis = struct {
    dac: bool,
    fft: bool,
};

const dp_type = std.StringArrayHashMap(std.AutoArrayHashMap(vis, u64));

const print = std.debug.print;

fn dfs(adj: *std.StringArrayHashMap(std.ArrayList([]u8)), i: []const u8, dp: *dp_type, v: vis) void {
    if (v.fft and v.dac) {
        for (i) |c| print("{c}", .{c});
        print("({},{})\n", .{ v.fft, v.dac });
    }
    const nv = vis{
        .dac = v.dac or std.mem.eql(u8, i, "dac"),
        .fft = v.fft or std.mem.eql(u8, i, "fft"),
    };

    const tos = adj.get(i).?;
    var cnt: u64 = 0;
    for (tos.items) |to| {
        const dpvis = dp.getPtr(to).?;
        if (dpvis.get(nv) == null) {
            //            for (to) |c| std.debug.print("{c}", .{c});
            //            std.debug.print(" dfs\n", .{});
            dfs(adj, to, dp, nv);
        }
        if (std.mem.eql(u8, to, "out")) {
            for (to) |c| std.debug.print("{c}", .{c});
            std.debug.print(" {} {}\n", .{nv.dac, nv.fft});
        }
        cnt += dpvis.get(nv).?;
    }

    var bla = dp.getPtr(i).?;
    if (bla.get(v) != null) unreachable;
    bla.put(v, cnt) catch unreachable;
    return;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 1 << 16);
    //const fileContents = try cwd.readFileAlloc(alloc, "sample.txt", 1 << 16);
    defer alloc.free(fileContents);
    var reader = std.io.Reader.fixed(fileContents);
    var adj = std.StringArrayHashMap(std.ArrayList([]u8)).init(alloc);
    defer {
        var it = adj.iterator();
        while (it.next()) |al| al.value_ptr.*.deinit(alloc);
        adj.deinit();
    }
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const col_idx = std.mem.indexOf(u8, line, ":").?;
        const from = line[0..col_idx];
        var al = std.ArrayList([]u8){};
        var targets = line[col_idx + 2 ..];
        while (std.mem.indexOf(u8, targets, " ")) |s_idx| {
            try al.append(alloc, targets[0..s_idx]);
            targets = targets[s_idx + 1 ..];
        }
        try al.append(alloc, targets);
        try adj.put(from, al);
    }
    var dp = dp_type.init(alloc);
    try dp.ensureTotalCapacity(adj.keys().len);
    var a_it = adj.iterator();
    while (a_it.next()) |a| try dp.put(a.key_ptr.*, std.AutoArrayHashMap(vis, u64).init(alloc));
    try dp.put("out", std.AutoArrayHashMap(vis, u64).init(alloc));
    var out_hm = dp.getPtr("out").?;
    try out_hm.put(vis{ .dac = false, .fft = false }, 0);
    try out_hm.put(vis{ .dac = true, .fft = false }, 0);
    try out_hm.put(vis{ .dac = false, .fft = true }, 0);
    try out_hm.put(vis{ .dac = true, .fft = true }, 1);
    defer {
        var it = dp.iterator();
        while (it.next()) |it_ptr| it_ptr.value_ptr.deinit();
        dp.deinit();
    }
    dfs(&adj, "svr", &dp, vis{ .dac = false, .fft = false });
    std.debug.print("{}\n", .{dp.get("svr").?.get(vis{ .fft = false, .dac = false }).?});
}

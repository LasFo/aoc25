const std = @import("std");

var res: usize = 0;

fn dfs(adj: *std.StringArrayHashMap(std.ArrayList([]u8)), i:  []const u8) void {
    if (std.mem.eql(u8, i, "out")) {
        res += 1;
        return;
    }
    const tos = adj.get(i).?;
    for (tos.items) |to| dfs(adj, to);
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
    dfs(&adj, "you");
    std.debug.print("{}\n", .{res});
}

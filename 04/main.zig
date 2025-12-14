const std = @import("std");

const Checker = struct {
    d: i32,
    pub fn check(self: Checker, i: i32, j: i32) bool {
        return 0 <= i and i < self.d and 0 <= j and j < self.d;
    }
};
const dir = struct {
    dx: i32,
    dy: i32,
};
const dirs = [_]dir{
    dir{ .dx = 0, .dy = 1 },
    dir{ .dx = 0, .dy = -1 },
    dir{ .dx = 1, .dy = 0 },
    dir{ .dx = 1, .dy = 1 },
    dir{ .dx = 1, .dy = -1 },
    dir{ .dx = -1, .dy = 0 },
    dir{ .dx = -1, .dy = 1 },
    dir{ .dx = -1, .dy = -1 },
};

//const dim = 10;
const dim = 136;
const c = Checker{
    .d = dim,
};

var res: usize = 0;

pub fn remove(grid: *[dim][dim]u8, i: i32, j: i32) void {
    //    std.debug.print("removing {} {}\n", .{i, j});
    grid.*[@intCast(i)][@intCast(j)] = 128;
    res += 1;
    for (dirs) |d| {
        const x: i32 = d.dx + @as(i32, @intCast(i));
        const y: i32 = d.dy + @as(i32, @intCast(j));
        if (!c.check(x, y)) continue;
        if (grid.*[@intCast(x)][@intCast(y)] == 0) std.debug.print("{} {} == 0", .{ x, y });
        grid.*[@intCast(x)][@intCast(y)] -= 1;
        if (grid.*[@intCast(x)][@intCast(y)] < 4) remove(grid, x, y);
    }
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
    var grid: [dim][dim]u8 = undefined;
    for (0..dim) |i| {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        if (line.len != dim) {
            std.debug.print("line.len={} != {}=dim\n", .{ line.len, dim });
            return;
        }
        for (0..dim) |j| grid[i][j] = line[j];
    }

    var dp: [dim][dim]u8 = undefined;
    for (0..dim) |i| {
        for (0..dim) |j| {
            dp[i][j] = 100;
            if (grid[i][j] == '.') continue;
            var ps: u8 = 0;
            for (dirs) |d| {
                const x: i32 = d.dx + @as(i32, @intCast(i));
                const y: i32 = d.dy + @as(i32, @intCast(j));
                if (c.check(x, y) and grid[@intCast(x)][@intCast(y)] == '@') ps += 1;
            }
            dp[i][j] = ps;
        }
    }
    for (0..dim) |i|
        for (0..dim) |j|
            if (dp[i][j] < 4) remove(&dp, @intCast(i), @intCast(j));

    std.debug.print("{}\n", .{res});
}

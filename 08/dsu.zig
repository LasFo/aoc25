const std = @import("std");

pub const dsu = struct {
    alloc: std.mem.Allocator,
    n: usize,
    parent_or_size: std.ArrayList(i32),

    pub fn new(alloc: std.mem.Allocator, n: usize) *dsu {
        var p = std.ArrayList(i32){};
        p.resize(alloc, @intCast(n)) catch unreachable;
        @memset(p.items, -1);
        const res = alloc.create(dsu) catch unreachable;
        res.* = dsu{
            .alloc = alloc,
            .n = n,
            .parent_or_size = p,
        };
        return res;
    }
    pub fn deinit(self: *dsu) void {
        self.parent_or_size.deinit(self.alloc);
        self.alloc.destroy(self);
    }
    pub fn leader(self: *dsu, a: usize) usize {
        if (a < 0 or a >= self.n) unreachable;
        if (self.parent_or_size.items[a] < 0) return a;
        self.parent_or_size.items[a] = @intCast(self.leader(@intCast(self.parent_or_size.items[a])));
        return @intCast(self.parent_or_size.items[a]);
    }
    pub fn merge(self: *dsu, a: usize, b: usize) usize {
        if (a < 0 or a >= self.n) unreachable;
        if (b < 0 or b >= self.n) unreachable;
        var x = self.leader(a);
        var y = self.leader(b);
        if (x == y) return x;

        if (-self.parent_or_size.items[x] < -self.parent_or_size.items[y]) {
           std.mem.swap(usize, &x, &y);
        }
        self.parent_or_size.items[x] += @intCast(self.parent_or_size.items[y]);
        self.parent_or_size.items[y] = @intCast(x);
        return x;
    }
    pub fn same(self: *dsu, a: usize, b:usize) bool {
        if (a < 0 or a >= self.n) unreachable;
        if (b < 0 or b >= self.n) unreachable;
        return self.leader(a) == self.leader(b);
    }
    pub fn size(self: *dsu, a: usize) usize {
        if (a < 0 or a >= self.n) unreachable;
        return @intCast(-self.parent_or_size.items[self.leader(a)]);
    }
};

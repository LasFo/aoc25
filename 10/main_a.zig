const std = @import("std");

const schema = struct {
    lights: []u8,
    buttons: std.ArrayList(std.ArrayList(u32)),
    joltages: std.ArrayList(u32),
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
    var res: usize = 0;
    while (true) {
        const line = reader.takeDelimiterExclusive('\n') catch break;
        _ = try reader.discard(@enumFromInt(1));
        const idx = std.mem.indexOf(u8, line, "]").?;
        var s = schema{ .lights = line[1..idx], .buttons = std.ArrayList(std.ArrayList(u32)){}, .joltages = undefined };

        var bend = std.mem.lastIndexOf(u8, line, ")").?;
        var buttons = line[idx + 1 .. bend + 1];
        defer {
            for (s.buttons.items) |*il| il.deinit(alloc);
            s.buttons.deinit(alloc);
        }
        while (std.mem.indexOf(u8, buttons, "(")) |bstart| {
            bend = std.mem.indexOf(u8, buttons, ")").?;
            var button = buttons[bstart + 1 .. bend];
            try s.buttons.append(alloc, std.ArrayList(u32){});
            var il = &s.buttons.items[s.buttons.items.len - 1];
            while (std.mem.indexOf(u8, button, ",")) |comma_idx| {
                const val = try std.fmt.parseInt(u32, button[0..comma_idx], 10);
                try il.append(alloc, val);
                button = button[comma_idx + 1 ..];
            }
            const val = try std.fmt.parseInt(u32, button, 10);
            try il.append(alloc,val);
            buttons = buttons[bend + 1 ..];
        }
        var start: u32 = 0;
        for (0..s.lights.len, s.lights) |i, c| {
            const bit = s.lights.len - i - 1;
            if (c != '#') continue;
            start += @as(u32, 1) << @intCast(bit);
        }
        var min_res = s.buttons.items.len + 1;
        for (0..@as(u32, 1) << @intCast(s.buttons.items.len)) |bc| {
            const nbits = @popCount(bc);
            if (nbits >= min_res) continue;
            var bits = start;
            for (0..s.buttons.items.len) |bi| {
                if (((@as(u32, 1) << @intCast(bi)) & bc) == 0) continue;
                for (s.buttons.items[bi].items) |button| {
                    const bit = s.lights.len - button - 1;
                    bits ^= @as(u32, 1) << @intCast(bit);
                }
            }
            if (bits == 0) min_res = @min(min_res, nbits);
        }
        res += min_res;
    }
    std.debug.print("{}\n", .{res});
}

const std = @import("std");

pub var tiles: [64][64][64]u32 = undefined;

/// Sets up a very basic voxel world
pub fn init(alloc: std.mem.Allocator) void {
    const start = std.time.milliTimestamp();
    _ = alloc;
    for (0..64) |x| {
        for (0..64) |z| {
            const h = (@sin(@as(f32, @floatFromInt(x)) / 12) + @sin(@as(f32, @floatFromInt(z)) / 12) + 3) * 4;
            for (0..64) |y| {
                if (@as(f32, @floatFromInt(y)) < h) {
                    tiles[x][y][z] = 1;
                } else {
                    tiles[x][y][z] = 0;
                }
            }
        }
    }
    std.debug.print("World initialised in {} ms\n", .{std.time.milliTimestamp() - start});
}

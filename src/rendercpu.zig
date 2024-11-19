const std = @import("std");
const rl = @import("c.zig");
const world = @import("world.zig");

const Vec3i = struct { x: isize, y: isize, z: isize };
var view_distance: usize = 64;

fn raycast(ray: rl.Ray) ?rl.Color {
    const step: Vec3i = .{
        .x = if (ray.direction.x > -0.0) 1 else -1,
        .y = if (ray.direction.y > -0.0) 1 else -1,
        .z = if (ray.direction.z > -0.0) 1 else -1,
    };

    const idir: rl.Vector3 = .{
        .x = if (@abs(ray.direction.x) != 0.0) @abs(1 / ray.direction.x) else std.math.floatMax(f32),
        .y = if (@abs(ray.direction.y) != 0.0) @abs(1 / ray.direction.y) else std.math.floatMax(f32),
        .z = if (@abs(ray.direction.z) != 0.0) @abs(1 / ray.direction.z) else std.math.floatMax(f32),
    };

    var period: rl.Vector3 = .{
        .x = if (@abs(ray.direction.x) != 0.0) @abs(@floor(std.math.clamp(@as(f32, @floatFromInt(step.x)), 0, 1) + ray.position.x) - ray.position.x) else std.math.floatMax(f32),
        .y = if (@abs(ray.direction.y) != 0.0) @abs(@floor(std.math.clamp(@as(f32, @floatFromInt(step.y)), 0, 1) + ray.position.y) - ray.position.y) else std.math.floatMax(f32),
        .z = if (@abs(ray.direction.z) != 0.0) @abs(@floor(std.math.clamp(@as(f32, @floatFromInt(step.z)), 0, 1) + ray.position.z) - ray.position.z) else std.math.floatMax(f32),
    };

    var tpos: Vec3i = .{
        .x = @intFromFloat(@floor(ray.position.x)),
        .y = @intFromFloat(@floor(ray.position.y)),
        .z = @intFromFloat(@floor(ray.position.z)),
    };

    var t: usize = 0;
    //
    while (t < view_distance) : (t += 1) {
        const inc: Vec3i = .{
            .x = @intFromBool(period.x <= period.y and period.x <= period.z),
            .y = @intFromBool(period.y <= period.x and period.y <= period.z),
            .z = @intFromBool(period.z <= period.x and period.z <= period.y),
        };

        period.x += idir.x * @as(f32, @floatFromInt(inc.x));
        period.y += idir.y * @as(f32, @floatFromInt(inc.y));
        period.z += idir.z * @as(f32, @floatFromInt(inc.z));
        tpos.x += step.x * inc.x;
        tpos.y += step.y * inc.y;
        tpos.z += step.z * inc.z;
        if (0 <= tpos.x and tpos.x < 64 and 0 <= tpos.y and tpos.y < 64 and 0 <= tpos.z and tpos.z < 64) {
            // Return different colours for basic shading based on the face intersected
            if (world.tiles[@intCast(tpos.x)][@intCast(tpos.y)][@intCast(tpos.z)] == 1) {
                if (inc.y == 1) {
                    return .{ .r = 0, .g = 192, .b = 32, .a = 255 };
                } else if (inc.x == 1) {
                    return .{ .r = 0, .g = 128, .b = 80, .a = 255 };
                } else {
                    return .{ .r = 0, .g = 96, .b = 80, .a = 255 };
                }
            }
        }
    }
    return null;
}

pub fn draw(camera: rl.Camera3D) void {
    const start = std.time.milliTimestamp();
    for (0..@intCast(rl.GetScreenWidth())) |x| {
        for (0..@intCast(rl.GetScreenHeight())) |y| {
            if (raycast(rl.GetMouseRay(.{ .x = @floatFromInt(x), .y = @floatFromInt(y) }, camera))) |colour| {
                rl.DrawPixel(@intCast(x), @intCast(y), colour);
            }
        }
    }
    std.debug.print("Frame time: {} ms\n", .{std.time.milliTimestamp() - start});
}

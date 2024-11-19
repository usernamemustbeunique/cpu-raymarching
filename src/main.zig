const std = @import("std");
const rl = @import("c.zig");
const render = @import("rendercpu.zig");
const world = @import("world.zig");

const Screen = enum {
    title,
    world,
};

var camera = rl.Camera3D{
    .position = rl.Vector3{ .x = 60.0, .y = 24.0, .z = 32.0 },
    .target = rl.Vector3{ .x = 32.0, .y = 8.0, .z = 32.0 },
    .up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 },
    .fovy = 60.0,
    .projection = rl.CAMERA_PERSPECTIVE,
};
var camera_speed: f32 = 16;

pub fn main() !void {
    rl.InitWindow(320, 240, "test title");
    rl.SetWindowState(rl.FLAG_WINDOW_RESIZABLE);
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()));

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    world.init(gpa.allocator());

    var screen = Screen.world;

    while (!rl.WindowShouldClose()) {
        switch (screen) {
            .title => {
                rl.BeginDrawing();
                rl.ClearBackground(rl.RAYWHITE);
                rl.EndDrawing();
            },

            .world => {
                rl.BeginDrawing();
                rl.ClearBackground(rl.SKYBLUE);
                render.draw(camera);
                rl.EndDrawing();

                // Basic movement controls, does not support mouse look etc.
                if (rl.IsKeyDown(rl.KEY_W)) {
                    camera.position.x -= camera_speed * rl.GetFrameTime();
                    camera.target.x -= camera_speed * rl.GetFrameTime();
                }
                if (rl.IsKeyDown(rl.KEY_A)) {
                    camera.position.z += camera_speed * rl.GetFrameTime();
                    camera.target.z += camera_speed * rl.GetFrameTime();
                }
                if (rl.IsKeyDown(rl.KEY_D)) {
                    camera.position.z -= camera_speed * rl.GetFrameTime();
                    camera.target.z -= camera_speed * rl.GetFrameTime();
                }
                if (rl.IsKeyDown(rl.KEY_S)) {
                    camera.position.x += camera_speed * rl.GetFrameTime();
                    camera.target.x += camera_speed * rl.GetFrameTime();
                }

                if (rl.IsKeyPressed(rl.KEY_V)) {
                    if (rl.IsWindowState(rl.FLAG_VSYNC_HINT)) {
                        rl.ClearWindowState(rl.FLAG_VSYNC_HINT);
                    } else {
                        rl.SetWindowState(rl.FLAG_VSYNC_HINT);
                    }
                }
                if (rl.IsKeyPressed(rl.KEY_I)) {
                    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()));
                }
                if (rl.IsKeyPressed(rl.KEY_O)) {
                    rl.SetTargetFPS(0);
                }
            },
        }
        if (rl.IsKeyDown(rl.KEY_SPACE)) {
            if (screen == .title) screen = .world else screen = .title;
        }
    }
    rl.CloseWindow();
}

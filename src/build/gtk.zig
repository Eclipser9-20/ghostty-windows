const std = @import("std");

pub const Targets = packed struct {
    x11: bool = false,
    wayland: bool = false,
};

/// Returns the targets that GTK4 was compiled with.
pub fn targets(b: *std.Build, target: std.Target) Targets {
    // On Windows, GTK4 only ever builds the win32 backend. MSYS2's
    // gtk4.pc reports "targets" inherited from upstream GTK's general
    // capability set (which can include x11/wayland) rather than what
    // was actually compiled for this platform, so trust the OS instead
    // of pkg-config here.
    if (target.os.tag == .windows) return .{};

    // Run pkg-config. We allow it to fail so that zig build --help
    // works without all dependencies. The build will fail later when
    // GTK isn't found anyways.
    var code: u8 = undefined;
    const output = b.runAllowFail(
        &.{ "pkg-config", "--variable=targets", "gtk4" },
        &code,
        .ignore,
    ) catch return .{};

    const x11 = std.mem.indexOf(u8, output, "x11") != null;
    const wayland = std.mem.indexOf(u8, output, "wayland") != null;

    return .{
        .x11 = x11,
        .wayland = wayland,
    };
}

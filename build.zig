const std = @import("std");
const builtin = @import("builtin");

const ArrayList = std.ArrayList;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const uv = b.addStaticLibrary(.{
        .name = "uv",
        .target = target,
        .optimize = optimize,
    });
    uv.linkLibC();
    if (target.isWindows()) {
        uv.linkSystemLibrary("psapi");
        uv.linkSystemLibrary("user32");
        uv.linkSystemLibrary("advapi32");
        uv.linkSystemLibrary("iphlpapi");
        uv.linkSystemLibrary("userenv");
        uv.linkSystemLibrary("ws2_32");
    }
    if (target.isLinux()) {
        uv.linkSystemLibrary("pthread");
    }

    uv.addIncludePath(.{ .path = "include" });
    uv.addIncludePath(.{ .path = "src" });

    var uv_flags = ArrayList([]const u8).init(b.allocator);
    var uv_sources = ArrayList([]const u8).init(b.allocator);
    defer uv_flags.deinit();
    defer uv_sources.deinit();

    if (!target.isWindows()) {
        uv_flags.append("-D_FILE_OFFSET_BITS=64") catch @panic("OOM");
        uv_flags.append("-D_LARGEFILE_SOURCE") catch @panic("OOM");
    }

    if (target.isLinux()) {
        uv_flags.append("-D_DARWIN_UNLIMITED_SELECT=1") catch @panic("OOM");
        uv_flags.append("-D_DARWIN_USE_64_BIT_INODE=1") catch @panic("OOM");
    }
    uv_sources.append("src/fs-poll.c") catch @panic("OOM");
    uv_sources.append("src/idna.c") catch @panic("OOM");
    uv_sources.append("src/inet.c") catch @panic("OOM");
    uv_sources.append("src/random.c") catch @panic("OOM");
    uv_sources.append("src/strscpy.c") catch @panic("OOM");
    uv_sources.append("src/strtok.c") catch @panic("OOM");
    uv_sources.append("src/threadpool.c") catch @panic("OOM");
    uv_sources.append("src/timer.c") catch @panic("OOM");
    uv_sources.append("src/uv-common.c") catch @panic("OOM");
    uv_sources.append("src/uv-data-getter-setters.c") catch @panic("OOM");
    uv_sources.append("src/version.c") catch @panic("OOM");

    if (!target.isWindows()) {
        uv_sources.append("src/unix/async.c") catch @panic("OOM");
        uv_sources.append("src/unix/core.c") catch @panic("OOM");
        uv_sources.append("src/unix/dl.c") catch @panic("OOM");
        uv_sources.append("src/unix/fs.c") catch @panic("OOM");
        uv_sources.append("src/unix/getaddrinfo.c") catch @panic("OOM");
        uv_sources.append("src/unix/getnameinfo.c") catch @panic("OOM");
        uv_sources.append("src/unix/loop-watcher.c") catch @panic("OOM");
        uv_sources.append("src/unix/loop.c") catch @panic("OOM");
        uv_sources.append("src/unix/pipe.c") catch @panic("OOM");
        uv_sources.append("src/unix/poll.c") catch @panic("OOM");
        uv_sources.append("src/unix/process.c") catch @panic("OOM");
        uv_sources.append("src/unix/random-devurandom.c") catch @panic("OOM");
        uv_sources.append("src/unix/signal.c") catch @panic("OOM");
        uv_sources.append("src/unix/stream.c") catch @panic("OOM");
        uv_sources.append("src/unix/tcp.c") catch @panic("OOM");
        uv_sources.append("src/unix/thread.c") catch @panic("OOM");
        uv_sources.append("src/unix/tty.c") catch @panic("OOM");
        uv_sources.append("src/unix/udp.c") catch @panic("OOM");
    }
    if (target.isWindows()) {
        uv_sources.append("src/win/async.c") catch @panic("OOM");
        uv_sources.append("src/win/core.c") catch @panic("OOM");
        uv_sources.append("src/win/detect-wakeup.c") catch @panic("OOM");
        uv_sources.append("src/win/dl.c") catch @panic("OOM");
        uv_sources.append("src/win/error.c") catch @panic("OOM");
        uv_sources.append("src/win/fs-event.c") catch @panic("OOM");
        uv_sources.append("src/win/fs.c") catch @panic("OOM");
        uv_sources.append("src/win/getaddrinfo.c") catch @panic("OOM");
        uv_sources.append("src/win/getnameinfo.c") catch @panic("OOM");
        uv_sources.append("src/win/handle.c") catch @panic("OOM");
        uv_sources.append("src/win/loop-watcher.c") catch @panic("OOM");
        uv_sources.append("src/win/pipe.c") catch @panic("OOM");
        uv_sources.append("src/win/poll.c") catch @panic("OOM");
        uv_sources.append("src/win/process-stdio.c") catch @panic("OOM");
        uv_sources.append("src/win/process.c") catch @panic("OOM");
        uv_sources.append("src/win/signal.c") catch @panic("OOM");
        uv_sources.append("src/win/snprintf.c") catch @panic("OOM");
        uv_sources.append("src/win/stream.c") catch @panic("OOM");
        uv_sources.append("src/win/tcp.c") catch @panic("OOM");
        uv_sources.append("src/win/thread.c") catch @panic("OOM");
        uv_sources.append("src/win/tty.c") catch @panic("OOM");
        uv_sources.append("src/win/udp.c") catch @panic("OOM");
        uv_sources.append("src/win/util.c") catch @panic("OOM");
        uv_sources.append("src/win/winapi.c") catch @panic("OOM");
        uv_sources.append("src/win/winsock.c") catch @panic("OOM");
    }

    if (target.isLinux() or target.isDarwin()) {
        uv_sources.append("src/unix/proctitle.c") catch @panic("OOM");
    }

    if (target.isLinux()) {
        uv_sources.append("src/unix/linux.c") catch @panic("OOM");
        uv_sources.append("src/unix/procfs-exepath.c") catch @panic("OOM");
        uv_sources.append("src/unix/random-getrandom.c") catch @panic("OOM");
        uv_sources.append("src/unix/random-sysctl-linux.c") catch @panic("OOM");
    }

    if (target.isDarwin() or
        target.isOpenBSD() or
        target.isNetBSD() or
        target.isFreeBSD() or
        target.isDragonFlyBSD())
    {
        uv_sources.append("src/unix/bsd-ifaddrs.c") catch @panic("OOM");
        uv_sources.append("src/unix/kqueue.c") catch @panic("OOM");
    }

    if (target.isDarwin() or target.isOpenBSD()) {
        uv_sources.append("src/unix/random-getentropy.c") catch @panic("OOM");
    }

    if (target.isDarwin()) {
        uv_sources.append("src/unix/darwin-proctitle.c") catch @panic("OOM");
        uv_sources.append("src/unix/darwin.c") catch @panic("OOM");
        uv_sources.append("src/unix/fsevents.c") catch @panic("OOM");
    }

    uv.addCSourceFiles(.{ .files = uv_sources.items, .flags = uv_flags.items });

    uv.installHeadersDirectory("include", "");

    b.installArtifact(uv);
}

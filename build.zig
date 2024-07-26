const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tracer = b.dependency("tracer", .{});

    const xml = b.addModule("xml", .{
        .root_source_file = b.path("mod.zig"),
        .target = target,
        .optimize = optimize,
    });
    xml.addImport("tracer", tracer.module("tracer"));

    {
        const exe = b.addExecutable(.{
            .name = "bench",
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport("xml", xml);
        exe.linkLibC();

        const run_exe = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_exe.addArgs(args);
        }

        const run_step = b.step("run", "Run benchmark");
        run_step.dependOn(&run_exe.step);
    }

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("test.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("xml", xml);

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

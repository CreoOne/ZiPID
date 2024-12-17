const std = @import("std");
const ziPID = @import("zipid.zig").ZiPID;

test "zero delta" {
    var pid: ziPID = .{ .proportional = 1.0, .integral = 1.0, .derivative = 1.0 };
    _ = pid.advance(1.0, 0.1);
    const actual = pid.advance(1.0, 0.0); // this should return the previous output as delta indicates no change
    try std.testing.expectEqual(1.11e1, actual);
}

test "no state leak" {
    var first: ziPID = .{ .proportional = 1.0, .integral = 1.0, .derivative = 1.0 };
    var second: ziPID = .{ .proportional = 1.0, .integral = 1.0, .derivative = 1.0 };
    const firstActual = first.advance(1.0, 0.1);
    const secondActual = second.advance(1.0, 0.1);
    try std.testing.expectEqual(11.1, firstActual);
    try std.testing.expectEqual(11.1, secondActual);
}

test "proportional part" {
    var pid: ziPID = .{ .proportional = 1.0, .integral = 0.0, .derivative = 0.0 };
    const actual = pid.advance(1.0, 0.1);
    try std.testing.expectEqual(1.0, actual);
}

test "integral part" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 1.0, .derivative = 0.0 };
    _ = pid.advance(1.0, 0.1);
    const actual = pid.advance(1.0, 0.1);
    try std.testing.expectEqual(0.2, actual);
}

test "derivative part" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 0.0, .derivative = 1.0 };
    const actual = pid.advance(1.0, 0.1);
    try std.testing.expectEqual(10.0, actual);
}

test "all parts" {
    var pid: ziPID = .{ .proportional = 1.0, .integral = 1.0, .derivative = 1.0 };
    const actual = pid.advance(1.0, 0.1);
    try std.testing.expectEqual(11.1, actual);
}

test "integral upper bound" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 1.0, .derivative = 0.0, .integralMax = 1.0 };
    _ = pid.advance(1.0, 1);
    const actual = pid.advance(1.0, 1);
    try std.testing.expectEqual(1.0, actual);
}

test "integral lower bound" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 1.0, .derivative = 0.0, .integralMin = -1.0 };
    _ = pid.advance(-1.0, 1.0);
    const actual = pid.advance(-1.0, 1.0);
    try std.testing.expectEqual(-1.0, actual);
}

test "integral positive overflow" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 1.0, .derivative = 0.0 };
    _ = pid.advance(std.math.floatMax(f64), 1.0);
    const actual = pid.advance(1.0, 1.0);
    try std.testing.expectEqual(std.math.floatMax(f64), actual);
}

test "integral negative overflow" {
    var pid: ziPID = .{ .proportional = 0.0, .integral = 1.0, .derivative = 0.0 };
    _ = pid.advance(std.math.floatMin(f64), 1.0);
    const actual = pid.advance(-1.0, 1.0);
    try std.testing.expectEqual(std.math.floatMin(f64), actual);
}

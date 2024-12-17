const std = @import("std");

pub const ZiPID = struct {
    proportional: f64 = 0,
    integral: f64 = 0,
    integralMin: f64 = std.math.floatMin(f64),
    integralMax: f64 = std.math.floatMax(f64),
    derivative: f64 = 0,

    integralAggregate: f64 = 0,
    previousDeviation: f64 = 0,
    previousOutput: f64 = 0,

    const Self = @This();

    pub fn advance(self: *Self, deviation: f64, delta: f64) f64 {
        if (delta == 0)
            return self.previousOutput;

        const prop = handleProportional(self, deviation);
        const int = handleIntegral(self, deviation, delta);
        const der = handleDerivative(self, deviation, delta);

        self.previousOutput = prop + int + der;
        return self.previousOutput;
    }

    fn handleProportional(self: *Self, deviation: f64) f64 {
        return self.proportional * deviation;
    }

    fn handleIntegral(self: *Self, deviation: f64, delta: f64) f64 {
        const delta_deviation = deviation * delta;

        if (delta_deviation > 0 and self.integralAggregate > self.integralMax - delta_deviation) {
            self.integralAggregate = self.integralMax;
        } else if (delta_deviation < 0 and self.integralAggregate < self.integralMin - delta_deviation) {
            self.integralAggregate = self.integralMin;
        } else {
            self.integralAggregate += delta_deviation;
        }

        return self.integral * self.integralAggregate;
    }

    fn handleDerivative(self: *Self, deviation: f64, delta: f64) f64 {
        const result = self.derivative * (deviation - self.previousDeviation) / delta;
        self.previousDeviation = deviation;
        return result;
    }
};

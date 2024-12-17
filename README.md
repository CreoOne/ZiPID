# ZiPID

PID controller implementation in ZIG

## Usage

```zig
var pid: ziPID = .{ .proportional = 1.0, .integral = 0.1, .derivative = 1.0 };
const deviation = -0.4; // control value -4/10th measurement units away from target/setpoint
const delta = 16e-3;    // ~60 times per time unit
const output = pid.advance(deviation, delta);
```

## Testing

Go to [sources/zipid.tests.zig](./sources/zipid.tests.zig)
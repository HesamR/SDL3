const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const Joystick = @import("joystick.zig").Joystick;

pub const HapticType = enum(u16) {
    ///  Constant haptic effect.
    constant = 1 << 0,

    ///  Periodic haptic effect that simulates sine waves.
    sine = 1 << 1,

    ///  Haptic effect for direct control over high/low frequency motors.
    /// \warning this value was SDL_HAPTIC_SQUARE right before 2.0.0 shipped. Sorry,
    ///          we ran out of bits, and this is important for XInput devices.
    left_right = 1 << 2,

    ///  Periodic haptic effect that simulates triangular waves.
    triangle = 1 << 3,

    ///  Periodic haptic effect that simulates saw tooth up waves.
    sawtooth_up = 1 << 4,

    ///  Periodic haptic effect that simulates saw tooth down waves.
    sawtooth_down = 1 << 5,

    ///  Ramp haptic effect.
    ramp = 1 << 6,

    ///  Condition haptic effect that simulates a spring.  Effect is based on the
    ///  axes position.
    spring = 1 << 7,

    ///  Condition haptic effect that simulates dampening.  Effect is based on the
    ///  axes velocity.
    damper = 1 << 8,

    ///  Condition haptic effect that simulates inertia.  Effect is based on the axes
    ///  acceleration.
    inertia = 1 << 9,

    ///  Condition haptic effect that simulates friction.  Effect is based on the
    ///  axes movement.
    friction = 1 << 10,

    ///  User defined custom haptic effect.
    custom = 1 << 11,
};

pub const HapticFeatures = packed struct(u16) {
    ///  Constant effect supported.
    ///
    ///  Constant haptic effect.
    ///
    constant: bool = false,

    ///  Sine wave effect supported.
    ///
    ///  Periodic haptic effect that simulates sine waves.
    ///
    sine: bool = false,

    ///  Left/Right effect supported.
    ///
    ///  Haptic effect for direct control over high/low frequency motors.
    ///
    ///  \sa SDL_HapticLeftRight
    /// \warning this value was SDL_HAPTIC_SQUARE right before 2.0.0 shipped. Sorry,
    ///          we ran out of bits, and this is important for XInput devices.
    left_right: bool = false,

    ///  Triangle wave effect supported.
    ///
    ///  Periodic haptic effect that simulates triangular waves.
    ///
    triangle: bool = false,

    ///  Sawtoothup wave effect supported.
    ///
    ///  Periodic haptic effect that simulates saw tooth up waves.
    ///
    sawtooth_up: bool = false,

    ///  Sawtoothdown wave effect supported.
    ///
    ///  Periodic haptic effect that simulates saw tooth down waves.
    ///
    sawtooth_down: bool = false,

    ///  Ramp effect supported.
    ///
    ///  Ramp haptic effect.
    ///
    ramp: bool = false,

    ///  Spring effect supported - uses axes position.
    ///
    ///  Condition haptic effect that simulates a spring.  Effect is based on the
    ///  axes position.
    ///
    spring: bool = false,

    ///  Damper effect supported - uses axes velocity.
    ///
    ///  Condition haptic effect that simulates dampening.  Effect is based on the
    ///  axes velocity.
    ///
    damper: bool = false,

    ///  Inertia effect supported - uses axes acceleration.
    ///
    ///  Condition haptic effect that simulates inertia.  Effect is based on the axes
    ///  acceleration.
    ///
    inertia: bool = false,

    ///  Friction effect supported - uses axes movement.
    ///
    ///  Condition haptic effect that simulates friction.  Effect is based on the
    ///  axes movement.
    ///
    friction: bool = false,

    ///  Custom effect is supported.
    ///
    ///  User defined custom haptic effect.
    custom: bool = false,

    ///  Device can set global gain.
    ///
    ///  Device supports setting the global gain.
    ///
    gain: bool = false,

    ///  Device can set autocenter.
    ///
    ///  Device supports setting autocenter.
    ///
    autocenter: bool = false,

    ///  Device can be queried for effect status.
    ///
    ///  Device supports querying effect status.
    ///
    status: bool = false,

    ///  Device can be paused.
    ///
    ///  Devices supports being paused.
    ///
    pause: bool = false,

    pub fn fromInt(val: c_uint) HapticFeatures {
        return @bitCast(@as(u16, @intCast(val)));
    }
};

pub const HapticDirectionEncoding = enum(u8) {
    ///  Uses polar coordinates for the direction.
    ///
    polar = 0,

    ///  Uses cartesian coordinates for the direction.
    ///
    cartesian = 1,

    ///  Uses spherical coordinates for the direction.
    ///
    spherical = 2,

    /// Use this value to play an effect on the steering wheel axis.
    ///
    /// This provides better compatibility across platforms and devices as SDL
    /// will guess the correct axis.
    ///
    steering_axis = 3,
};

pub const haptic_infinity = 4294967295;

///  Structure that represents a haptic direction.
///
///  This is the direction where the force comes from,
///  instead of the direction in which the force is exerted.
///
///  Directions can be specified by:
///   - ::SDL_HAPTIC_POLAR : Specified by polar coordinates.
///   - ::SDL_HAPTIC_CARTESIAN : Specified by cartesian coordinates.
///   - ::SDL_HAPTIC_SPHERICAL : Specified by spherical coordinates.
///
///  Cardinal directions of the haptic device are relative to the positioning
///  of the device.  North is considered to be away from the user.
///
///  The following diagram represents the cardinal directions:
///  \verbatim
///               .--.
///               |__| .-------.
///               |=.| |.-----.|
///               |--| ||     ||
///               |  | |'-----'|
///               |__|~')_____('
///                 [ COMPUTER ]
///
///
///                   North (0,-1)
///                       ^
///                       |
///                       |
/// (-1,0)  West <----[ HAPTIC ]----> East (1,0)
///                       |
///                       |
///                       v
///                    South (0,1)
///
///
///                    [ USER ]
///                      \|||/
///                      (o o)
///                ---ooO-(_)-Ooo---
///  \endverbatim
///
///  If type is ::SDL_HAPTIC_POLAR, direction is encoded by hundredths of a
///  degree starting north and turning clockwise.  ::SDL_HAPTIC_POLAR only uses
///  the first \c dir parameter.  The cardinal directions would be:
///   - North: 0 (0 degrees)
///   - East: 9000 (90 degrees)
///   - South: 18000 (180 degrees)
///   - West: 27000 (270 degrees)
///
///  If type is ::SDL_HAPTIC_CARTESIAN, direction is encoded by three positions
///  (X axis, Y axis and Z axis (with 3 axes)).  ::SDL_HAPTIC_CARTESIAN uses
///  the first three \c dir parameters.  The cardinal directions would be:
///   - North:  0,-1, 0
///   - East:   1, 0, 0
///   - South:  0, 1, 0
///   - West:  -1, 0, 0
///
///  The Z axis represents the height of the effect if supported, otherwise
///  it's unused.  In cartesian encoding (1, 2) would be the same as (2, 4), you
///  can use any multiple you want, only the direction matters.
///
///  If type is ::SDL_HAPTIC_SPHERICAL, direction is encoded by two rotations.
///  The first two \c dir parameters are used.  The \c dir parameters are as
///  follows (all values are in hundredths of degrees):
///   - Degrees from (1, 0) rotated towards (0, 1).
///   - Degrees towards (0, 0, 1) (device needs at least 3 axes).
///
///
///  Example of force coming from the south with all encodings (force coming
///  from the south means the user will have to pull the stick to counteract):
///  \code
///  SDL_HapticDirection direction;
///
///  // Cartesian directions
///  direction.type = SDL_HAPTIC_CARTESIAN; // Using cartesian direction encoding.
///  direction.dir[0] = 0; // X position
///  direction.dir[1] = 1; // Y position
///  // Assuming the device has 2 axes, we don't need to specify third parameter.
///
///  // Polar directions
///  direction.type = SDL_HAPTIC_POLAR; // We'll be using polar direction encoding.
///  direction.dir[0] = 18000; // Polar only uses first parameter
///
///  // Spherical coordinates
///  direction.type = SDL_HAPTIC_SPHERICAL; // Spherical encoding
///  direction.dir[0] = 9000; // Since we only have two axes we don't need more parameters.
///  \endcode
///
pub const HapticDirection = extern struct {
    type: HapticDirectionEncoding,
    dir: [3]i32,
};

/// A structure containing a template for a Constant effect.
///
/// This struct is exclusively for the ::SDL_HAPTIC_CONSTANT effect.
///
/// A constant effect applies a constant force in the specified direction
/// to the joystick.
///
pub const HapticConstant = extern struct {
    type: HapticType,
    direction: HapticDirection,

    length: u32,
    delay: u16,

    button: u16,
    interval: u16,

    level: i16,

    attack_length: u16,
    attack_level: u16,
    fade_length: u16,
    fade_level: u16,
};

///  A structure containing a template for a Periodic effect.
///
///  The struct handles the following effects:
///   - ::SDL_HAPTIC_SINE
///   - ::SDL_HAPTIC_LEFTRIGHT
///   - ::SDL_HAPTIC_TRIANGLE
///   - ::SDL_HAPTIC_SAWTOOTHUP
///   - ::SDL_HAPTIC_SAWTOOTHDOWN
///
///  A periodic effect consists in a wave-shaped effect that repeats itself
///  over time.  The type determines the shape of the wave and the parameters
///  determine the dimensions of the wave.
///
///  Phase is given by hundredth of a degree meaning that giving the phase a value
///  of 9000 will displace it 25% of its period.  Here are sample values:
///   -     0: No phase displacement.
///   -  9000: Displaced 25% of its period.
///   - 18000: Displaced 50% of its period.
///   - 27000: Displaced 75% of its period.
///   - 36000: Displaced 100% of its period, same as 0, but 0 is preferred.
///
///  Examples:
///  \verbatim
///  SDL_HAPTIC_SINE
///    __      __      __      __
///   /  \    /  \    /  \    /
///  /    \__/    \__/    \__/
///
///  SDL_HAPTIC_SQUARE
///   __    __    __    __    __
///  |  |  |  |  |  |  |  |  |  |
///  |  |__|  |__|  |__|  |__|  |
///
///  SDL_HAPTIC_TRIANGLE
///    /\    /\    /\    /\    /\
///   /  \  /  \  /  \  /  \  /
///  /    \/    \/    \/    \/
///
///  SDL_HAPTIC_SAWTOOTHUP
///    /|  /|  /|  /|  /|  /|  /|
///   / | / | / | / | / | / | / |
///  /  |/  |/  |/  |/  |/  |/  |
///
///  SDL_HAPTIC_SAWTOOTHDOWN
///  \  |\  |\  |\  |\  |\  |\  |
///   \ | \ | \ | \ | \ | \ | \ |
///    \|  \|  \|  \|  \|  \|  \|
///  \endverbatim
///
pub const HapticPeriodic = extern struct {
    type: HapticType,
    direction: HapticDirection,

    length: u32,
    delay: u16,

    button: u16,
    interval: u16,

    period: u16,
    magnitude: u16,
    offset: u16,
    phase: u16,

    attack_length: u16,
    attack_level: u16,
    fade_length: u16,
    fade_level: u16,
};

///  A structure containing a template for a Condition effect.
///
///  The struct handles the following effects:
///   - ::SDL_HAPTIC_SPRING: Effect based on axes position.
///   - ::SDL_HAPTIC_DAMPER: Effect based on axes velocity.
///   - ::SDL_HAPTIC_INERTIA: Effect based on axes acceleration.
///   - ::SDL_HAPTIC_FRICTION: Effect based on axes movement.
///
///  Direction is handled by condition internals instead of a direction member.
///  The condition effect specific members have three parameters.  The first
///  refers to the X axis, the second refers to the Y axis and the third
///  refers to the Z axis.  The right terms refer to the positive side of the
///  axis and the left terms refer to the negative side of the axis.  Please
///  refer to the ::SDL_HapticDirection diagram for which side is positive and
///  which is negative.
///
pub const HapticCondition = extern struct {
    type: HapticType,
    direction: HapticDirection,

    length: u32,
    delay: u16,

    button: u16,
    interval: u16,

    right_sat: [3]u16,
    left_sat: [3]u16,
    right_coeff: [3]i16,
    left_coeff: [3]i16,
    deadband: [3]u16,
    center: [3]i16,
};

/// A structure containing a template for a Ramp effect.
///
/// This struct is exclusively for the ::SDL_HAPTIC_RAMP effect.
///
/// The ramp effect starts at start strength and ends at end strength.
/// It augments in linear fashion.  If you use attack and fade with a ramp
/// the effects get added to the ramp effect making the effect become
/// quadratic instead of linear.
///
pub const HapticRamp = extern struct {
    type: HapticType,
    direction: HapticDirection,

    length: u32,
    delay: u16,

    button: u16,
    interval: u16,

    start: i16,
    end: i16,

    attack_length: u16,
    attack_level: u16,
    fade_length: u16,
    fade_level: u16,
};

/// A structure containing a template for a Left/Right effect.
///
/// This struct is exclusively for the ::SDL_HAPTIC_LEFTRIGHT effect.
///
/// The Left/Right effect is used to explicitly control the large and small
/// motors, commonly found in modern game controllers. The small (right) motor
/// is high frequency, and the large (left) motor is low frequency.
///
pub const HapticLeftRight = extern struct {
    type: HapticFeatures,

    lenght: u32,

    large_magnitude: u16,
    small_magnitude: u16,
};

/// A structure containing a template for the ::SDL_HAPTIC_CUSTOM effect.
///
/// This struct is exclusively for the ::SDL_HAPTIC_CUSTOM effect.
///
/// A custom force feedback effect is much like a periodic effect, where the
/// application can define its exact shape.  You will have to allocate the
/// data yourself.  Data should consist of channels * samples Uint16 samples.
///
/// If channels is one, the effect is rotated using the defined direction.
/// Otherwise it uses the samples in data for the different axes.
///
pub const HapticCustom = extern struct {
    type: HapticType,
    direction: HapticDirection,

    length: u32,
    delay: u16,

    button: u16,
    interval: u16,

    channels: u8,
    period: u16,
    samples: u16,
    data: [*]u16,

    attack_length: u16,
    attack_level: u16,
    fade_length: u16,
    fade_level: u16,
};

/// The generic template for any haptic effect.
///
/// All values max at 32767 (0x7FFF).  Signed values also can be negative.
/// Time values unless specified otherwise are in milliseconds.
///
/// You can also pass ::SDL_HAPTIC_INFINITY to length instead of a 0-32767
/// value.  Neither delay, interval, attack_length nor fade_length support
/// ::SDL_HAPTIC_INFINITY.  Fade will also not be used since effect never ends.
///
/// Additionally, the ::SDL_HAPTIC_RAMP effect does not support a duration of
/// ::SDL_HAPTIC_INFINITY.
///
/// Button triggers may not be supported on all devices, it is advised to not
/// use them if possible.  Buttons start at index 1 instead of index 0 like
/// the joystick.
///
/// If both attack_length and fade_level are 0, the envelope is not used,
/// otherwise both values are used.
///
/// Common parts:
/// \code
/// // Replay - All effects have this
/// Uint32 length;        // Duration of effect (ms).
/// Uint16 delay;         // Delay before starting effect.
///
/// // Trigger - All effects have this
/// Uint16 button;        // Button that triggers effect.
/// Uint16 interval;      // How soon before effect can be triggered again.
///
/// // Envelope - All effects except condition effects have this
/// Uint16 attack_length; // Duration of the attack (ms).
/// Uint16 attack_level;  // Level at the start of the attack.
/// Uint16 fade_length;   // Duration of the fade out (ms).
/// Uint16 fade_level;    // Level at the end of the fade.
/// \endcode
///
///
/// Here we have an example of a constant effect evolution in time:
/// \verbatim
/// Strength
/// ^
/// |
/// |    effect level -->  _________________
/// |                     /                 \
/// |                    /                   \
/// |                   /                     \
/// |                  /                       \
/// | attack_level --> |                        \
/// |                  |                        |  <---  fade_level
/// |
/// +--------------------------------------------------> Time
///                    [--]                 [---]
///                    attack_length        fade_length
///
/// [------------------][-----------------------]
/// delay               length
/// \endverbatim
///
/// Note either the attack_level or the fade_level may be above the actual
/// effect level.
///
pub const HapticEffect = extern union {
    type: HapticType,
    constant: HapticConstant,
    periodic: HapticPeriodic,
    condition: HapticCondition,
    remp: HapticRamp,
    left_right: HapticLeftRight,
    custom: HapticCustom,
};

pub const Haptic = opaque {
    /// Open a haptic device for use.
    ///
    /// The index passed as an argument refers to the N'th haptic device on this
    /// system.
    ///
    /// When opening a haptic device, its gain will be set to maximum and
    /// autocenter will be disabled. To modify these values use SDL_HapticSetGain()
    /// and SDL_HapticSetAutocenter().
    ///
    /// \param device_index index of the device to open
    /// \returns the device identifier or NULL on failure; call SDL_GetError() for
    ///          more information.
    ///
    fn open(device_index: c_int) Error!*Haptic {
        return SDL_HapticOpen(device_index) orelse internal.emitError();
    }

    /// Try to open a haptic device from the current mouse.
    ///
    /// \returns the haptic device identifier or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    fn openFromMouse() Error!*Haptic {
        return SDL_HapticOpenFromMouse() orelse internal.emitError();
    }

    /// Open a haptic device for use from a joystick device.
    ///
    /// You must still close the haptic device separately. It will not be closed
    /// with the joystick.
    ///
    /// When opened from a joystick you should first close the haptic device before
    /// closing the joystick device. If not, on some implementations the haptic
    /// device will also get unallocated and you'll be unable to use force feedback
    /// on that device.
    ///
    /// \param joystick the SDL_Joystick to create a haptic device from
    /// \returns a valid haptic device identifier on success or NULL on failure;
    ///          call SDL_GetError() for more information.
    ///
    fn openFromJoystick(joystick: *Joystick) Error!*Haptic {
        return SDL_HapticOpenFromJoystick(joystick) orelse internal.emitError();
    }

    /// Get the index of a haptic device.
    ///
    /// \param haptic the SDL_Haptic device to query
    /// \returns the index of the specified haptic device or a negative error code
    ///          on failure; call SDL_GetError() for more information.
    ///
    pub fn getIndex(self: *Haptic) Error!c_int {
        const index = SDL_HapticIndex(self);
        try internal.assertResult(index >= 0);
        return index;
    }

    /// Close a haptic device previously opened with SDL_HapticOpen().
    ///
    /// \param haptic the SDL_Haptic device to close
    ///
    pub fn close(self: *Haptic) void {
        SDL_HapticClose(self);
    }

    /// Get the number of effects a haptic device can store.
    ///
    /// On some platforms this isn't fully supported, and therefore is an
    /// approximation. Always check to see if your created effect was actually
    /// created and do not rely solely on SDL_HapticNumEffects().
    ///
    /// \param haptic the SDL_Haptic device to query
    /// \returns the number of effects the haptic device can store or a negative
    ///          error code on failure; call SDL_GetError() for more information.
    ///
    pub fn getNumEffects(self: *Haptic) Error!c_int {
        const num = SDL_HapticNumEffects(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the number of effects a haptic device can play at the same time.
    ///
    /// This is not supported on all platforms, but will always return a value.
    ///
    /// \param haptic the SDL_Haptic device to query maximum playing effects
    /// \returns the number of effects the haptic device can play at the same time
    ///          or a negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getNumEffectsPlaying(self: *Haptic) Error!c_int {
        const num = SDL_HapticNumEffectsPlaying(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the haptic device's supported features in bitwise manner.
    ///
    /// \param haptic the SDL_Haptic device to query
    /// \returns a list of supported haptic features in bitwise manner (OR'd), or 0
    ///          on failure; call SDL_GetError() for more information.
    ///
    pub fn getFeatures(self: *Haptic) Error!HapticFeatures {
        const flags = SDL_HapticQuery(self);
        try internal.assertResult(flags != 0);
        return HapticFeatures.fromInt(flags);
    }

    /// Get the number of haptic axes the device has.
    ///
    /// The number of haptic axes might be useful if working with the
    /// SDL_HapticDirection effect.
    ///
    /// \param haptic the SDL_Haptic device to query
    /// \returns the number of axes on success or a negative error code on failure;
    ///          call SDL_GetError() for more information.
    ///
    pub fn getNumAxes(self: *Haptic) Error!c_int {
        const num = SDL_HapticNumAxes(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Check to see if an effect is supported by a haptic device.
    ///
    /// \param haptic the SDL_Haptic device to query
    /// \param effect the desired effect to query
    /// \returns SDL_TRUE if effect is supported, SDL_FALSE if it isn't, or a
    ///          negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn isEffectSupported(self: *Haptic, effect: *HapticEffect) Error!bool {
        const res = SDL_HapticEffectSupported(self, effect);
        try internal.assertResult(res >= 0);
        return if (res == 0) false else true;
    }

    /// Create a new haptic effect on a specified device.
    ///
    /// \param haptic an SDL_Haptic device to create the effect on
    /// \param effect an SDL_HapticEffect structure containing the properties of
    ///               the effect to create
    /// \returns the ID of the effect on success or a negative error code on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn newEffect(self: *Haptic, effect: *HapticEffect) Error!c_int {
        const index = SDL_HapticNewEffect(self, effect);
        try internal.assertResult(index >= 0);
        return index;
    }

    /// Update the properties of an effect.
    ///
    /// Can be used dynamically, although behavior when dynamically changing
    /// direction may be strange. Specifically the effect may re-upload itself and
    /// start playing from the start. You also cannot change the type either when
    /// running SDL_HapticUpdateEffect().
    ///
    /// \param haptic the SDL_Haptic device that has the effect
    /// \param effect the identifier of the effect to update
    /// \param data an SDL_HapticEffect structure containing the new effect
    ///             properties to use
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn updateEffect(self: *Haptic, effect: c_int, data: *HapticEffect) Error!void {
        try internal.checkResult(SDL_HapticUpdateEffect(self, effect, data));
    }

    /// Run the haptic effect on its associated haptic device.
    ///
    /// To repeat the effect over and over indefinitely, set `iterations` to
    /// `SDL_HAPTIC_INFINITY`. (Repeats the envelope - attack and fade.) To make
    /// one instance of the effect last indefinitely (so the effect does not fade),
    /// set the effect's `length` in its structure/union to `SDL_HAPTIC_INFINITY`
    /// instead.
    ///
    /// \param haptic the SDL_Haptic device to run the effect on
    /// \param effect the ID of the haptic effect to run
    /// \param iterations the number of iterations to run the effect; use
    ///                   `SDL_HAPTIC_INFINITY` to repeat forever
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn runEffect(self: *Haptic, effect: c_int, iterations: u32) Error!void {
        try internal.checkResult(SDL_HapticRunEffect(self, effect, iterations));
    }

    /// Stop the haptic effect on its associated haptic device.
    ///
    /// \param haptic the SDL_Haptic device to stop the effect on
    /// \param effect the ID of the haptic effect to stop
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn stopEffect(self: *Haptic, effect: c_int) Error!void {
        try internal.checkResult(SDL_HapticStopEffect(self, effect));
    }

    /// Destroy a haptic effect on the device.
    ///
    /// This will stop the effect if it's running. Effects are automatically
    /// destroyed when the device is closed.
    ///
    /// \param haptic the SDL_Haptic device to destroy the effect on
    /// \param effect the ID of the haptic effect to destroy
    ///
    pub fn destroyEffect(self: *Haptic, effect: c_int) void {
        SDL_HapticDestroyEffect(self, effect);
    }

    /// Get the status of the current effect on the specified haptic device.
    ///
    /// Device must support the SDL_HAPTIC_STATUS feature.
    ///
    /// \param haptic the SDL_Haptic device to query for the effect status on
    /// \param effect the ID of the haptic effect to query its status
    /// \returns 0 if it isn't playing, 1 if it is playing, or a negative error
    ///          code on failure; call SDL_GetError() for more information.
    ///
    pub fn getEffectStatus(self: *Haptic, effect: c_int) Error!bool {
        const stat = SDL_HapticGetEffectStatus(self, effect);
        try internal.assertResult(stat >= 0);
        return if (stat == 0) false else true;
    }

    /// Set the global gain of the specified haptic device.
    ///
    /// Device must support the SDL_HAPTIC_GAIN feature.
    ///
    /// The user may specify the maximum gain by setting the environment variable
    /// `SDL_HAPTIC_GAIN_MAX` which should be between 0 and 100. All calls to
    /// SDL_HapticSetGain() will scale linearly using `SDL_HAPTIC_GAIN_MAX` as the
    /// maximum.
    ///
    /// \param haptic the SDL_Haptic device to set the gain on
    /// \param gain value to set the gain to, should be between 0 and 100 (0 - 100)
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setGain(self: *Haptic, gain: c_int) Error!void {
        try internal.checkResult(SDL_HapticSetGain(self, gain));
    }

    /// Set the global autocenter of the device.
    ///
    /// Autocenter should be between 0 and 100. Setting it to 0 will disable
    /// autocentering.
    ///
    /// Device must support the SDL_HAPTIC_AUTOCENTER feature.
    ///
    /// \param haptic the SDL_Haptic device to set autocentering on
    /// \param autocenter value to set autocenter to (0-100)
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setAutocenter(self: *Haptic, autocenter: c_int) Error!void {
        try internal.checkResult(SDL_HapticSetAutocenter(self, autocenter));
    }

    /// Pause a haptic device.
    ///
    /// Device must support the `SDL_HAPTIC_PAUSE` feature. Call
    /// SDL_HapticUnpause() to resume playback.
    ///
    /// Do not modify the effects nor add new ones while the device is paused. That
    /// can cause all sorts of weird errors.
    ///
    /// \param haptic the SDL_Haptic device to pause
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn pause(self: *Haptic) Error!void {
        try internal.checkResult(SDL_HapticPause(self));
    }

    /// Unpause a haptic device.
    ///
    /// Call to unpause after SDL_HapticPause().
    ///
    /// \param haptic the SDL_Haptic device to unpause
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn unpause(self: *Haptic) Error!void {
        try internal.checkResult(SDL_HapticUnpause(self));
    }

    /// Stop all the currently playing effects on a haptic device.
    ///
    /// \param haptic the SDL_Haptic device to stop
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn stopAll(self: *Haptic) Error!void {
        try internal.checkResult(SDL_HapticStopAll(self));
    }

    /// Check whether rumble is supported on a haptic device.
    ///
    /// \param haptic haptic device to check for rumble support
    /// \returns SDL_TRUE if effect is supported, SDL_FALSE if it isn't, or a
    ///          negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn isRumbleSupported(self: *Haptic) Error!bool {
        const res = SDL_HapticRumbleSupported(self);
        try internal.assertResult(res >= 0);
        return if (res == 0) false else true;
    }

    /// Initialize a haptic device for simple rumble playback.
    ///
    /// \param haptic the haptic device to initialize for simple rumble playback
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn rumbleInit(self: *Haptic) Error!void {
        try internal.checkResult(SDL_HapticRumbleInit(self));
    }

    /// Run a simple rumble effect on a haptic device.
    ///
    /// \param haptic the haptic device to play the rumble effect on
    /// \param strength strength of the rumble to play as a 0-1 float value
    /// \param length length of the rumble to play in milliseconds
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn rumblePlay(self: *Haptic, strength: f32, length: u32) Error!void {
        try internal.checkResult(SDL_HapticRumblePlay(self, strength, length));
    }

    /// Stop the simple rumble on a haptic device.
    ///
    /// \param haptic the haptic device to stop the rumble effect on
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn rumbleStop(self: *Haptic) Error!void {
        try internal.checkResult(SDL_HapticRumbleStop(self));
    }

    extern fn SDL_HapticOpen(device_index: c_int) ?*Haptic;
    extern fn SDL_HapticOpenFromMouse() ?*Haptic;
    extern fn SDL_HapticOpenFromJoystick(joystick: *Joystick) ?*Haptic;
    extern fn SDL_HapticIndex(haptic: *Haptic) c_int;
    extern fn SDL_HapticClose(haptic: *Haptic) void;
    extern fn SDL_HapticNumEffects(haptic: *Haptic) c_int;
    extern fn SDL_HapticNumEffectsPlaying(haptic: *Haptic) c_int;
    extern fn SDL_HapticQuery(haptic: *Haptic) c_uint;
    extern fn SDL_HapticNumAxes(haptic: *Haptic) c_int;
    extern fn SDL_HapticEffectSupported(haptic: *Haptic, effect: *HapticEffect) c_int;
    extern fn SDL_HapticNewEffect(haptic: *Haptic, effect: *HapticEffect) c_int;
    extern fn SDL_HapticUpdateEffect(haptic: *Haptic, effect: c_int, data: *HapticEffect) c_int;
    extern fn SDL_HapticRunEffect(haptic: *Haptic, effect: c_int, iterations: u32) c_int;
    extern fn SDL_HapticStopEffect(haptic: *Haptic, effect: c_int) c_int;
    extern fn SDL_HapticDestroyEffect(haptic: *Haptic, effect: c_int) void;
    extern fn SDL_HapticGetEffectStatus(haptic: *Haptic, effect: c_int) c_int;
    extern fn SDL_HapticSetGain(haptic: *Haptic, gain: c_int) c_int;
    extern fn SDL_HapticSetAutocenter(haptic: *Haptic, autocenter: c_int) c_int;
    extern fn SDL_HapticPause(haptic: *Haptic) c_int;
    extern fn SDL_HapticUnpause(haptic: *Haptic) c_int;
    extern fn SDL_HapticStopAll(haptic: *Haptic) c_int;
    extern fn SDL_HapticRumbleSupported(haptic: *Haptic) c_int;
    extern fn SDL_HapticRumbleInit(haptic: *Haptic) c_int;
    extern fn SDL_HapticRumblePlay(haptic: *Haptic, strength: f32, length: u32) c_int;
    extern fn SDL_HapticRumbleStop(haptic: *Haptic) c_int;
};

/// Count the number of haptic devices attached to the system.
///
/// \returns the number of haptic devices detected on the system or a negative
///          error code on failure; call SDL_GetError() for more information.
///
pub fn getNumHaptics() Error!c_int {
    const num = SDL_NumHaptics();
    try internal.assertResult(num >= 0);
    return num;
}

/// Get the implementation dependent name of a haptic device.
///
/// This can be called before any joysticks are opened. If no name can be
/// found, this function returns NULL.
///
/// \param device_index index of the device to query.
/// \returns the name of the device or NULL on failure; call SDL_GetError() for
///          more information.
///
pub fn getHapticName(device_index: c_int) Error![*:0]const u8 {
    return SDL_HapticName(device_index) orelse internal.emitError();
}

/// Check if the haptic device at the designated index has been opened.
///
/// \param device_index the index of the device to query
/// \returns 1 if it has been opened, 0 if it hasn't or on failure; call
///          SDL_GetError() for more information.
///
pub fn isHapticOpened(device_index: c_int) Error!bool {
    const res = SDL_HapticOpened(device_index);
    try internal.hasError();
    return if (res == 0) false else true;
}

extern fn SDL_NumHaptics() c_int;
extern fn SDL_HapticName(device_index: c_int) ?[*:0]const u8;
extern fn SDL_HapticOpened(device_index: c_int) c_int;
extern fn SDL_MouseIsHaptic() c_int;

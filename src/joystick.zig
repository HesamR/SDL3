const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const PropertiesID = @import("properties.zig").PropertiesID;
const GUID = @import("guid.zig").GUID;
const SensorType = @import("sensor.zig").SensorType;

pub const JoystickType = enum(c_uint) {
    unknown,
    gamepad,
    wheel,
    arcade_stick,
    flight_stick,
    dance_pad,
    guitar,
    drum_kit,
    arcade_pad,
    throttle,
};

pub const JoystickPowerLevel = enum(c_int) {
    unknown = -1,

    /// <= 5% */
    empty,

    /// <= 20% */
    low,

    /// <= 70% */
    medium,

    /// <= 100% */
    full,

    wired,
};

pub const JoystickHat = packed struct(u8) {
    up: bool = false,
    right: bool = false,
    down: bool = false,
    left: bool = false,

    __padding: u4 = 0,
};

pub const joystick_axis_max = 32767;
pub const joystick_axis_min = -32768;

/// Set max recognized G-force from accelerometer
/// See src/joystick/uikit/SDL_sysjoystick.m for notes on why this is needed
pub const iphone_max_gforce = 5.0;

pub const GamepadType = enum(c_uint) {
    unknown = 0,
    standard,
    xbox360,
    xboxone,
    ps3,
    ps4,
    ps5,
    nintendo_switch_pro,
    nintendo_switch_joycon_left,
    nintendo_switch_joycon_right,
    nintendo_switch_joycon_pair,
};

pub const GamepadButton = enum(c_int) {
    invalid = -1,

    /// Bottom face button (e.g. Xbox A button) */
    south,

    /// Right face button (e.g. Xbox B button) */
    east,

    /// Left face button (e.g. Xbox X button) */
    west,

    /// Top face button (e.g. Xbox Y button) */
    north,

    back,
    guide,
    start,
    left_stick,
    right_stick,
    left_shoulder,
    right_shoulder,
    dpad_up,
    dpad_down,
    dpad_left,
    dpad_right,

    /// Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button) */
    misc1,

    /// Upper or primary paddle, under your right hand (e.g. Xbox Elite paddle P1) */
    right_paddle1,

    /// Upper or primary paddle, under your left hand (e.g. Xbox Elite paddle P3) */
    left_paddle1,

    /// Lower or secondary paddle, under your right hand (e.g. Xbox Elite paddle P2) */
    right_paddle2,

    /// Lower or secondary paddle, under your left hand (e.g. Xbox Elite paddle P4) */
    left_paddle2,

    /// PS4/PS5 touchpad button */
    touchpad,
};

pub const GamepadButton8 = enum(u8) {
    south,
    east,
    west,
    north,
    back,
    guide,
    start,
    left_stick,
    right_stick,
    left_shoulder,
    right_shoulder,
    dpad_up,
    dpad_down,
    dpad_left,
    dpad_right,
    misc1,
    right_paddle1,
    left_paddle1,
    right_paddle2,
    left_paddle2,
    touchpad,
};

pub const GamepadButtonLabel = enum(c_uint) {
    unknown,
    a,
    b,
    x,
    y,
    cross,
    circle,
    square,
    triangle,
};

///  The list of axes available on a gamepad
///
///  Thumbstick axis values range from SDL_JOYSTICK_AXIS_MIN to SDL_JOYSTICK_AXIS_MAX,
///  and are centered within ~8000 of zero, though advanced UI will allow users to set
///  or autodetect the dead zone, which varies between gamepads.
///
pub const GamepadAxis = enum(c_int) {
    invalid = -1,
    leftx,
    lefty,
    rightx,
    righty,
    left_trigger,
    right_trigger,
};

pub const GamepadAxis8 = enum(u8) {
    leftx,
    lefty,
    rightx,
    righty,
    left_trigger,
    right_trigger,
};

pub const GamepadBindingType = enum(c_uint) {
    none = 0,
    button,
    axis,
    hat,
};

pub const GamepadBinding = extern struct {
    input_type: GamepadBindingType,
    input: extern union {
        button: c_int,

        axis: extern struct {
            axis: c_int,
            axis_min: c_int,
            axis_max: c_int,
        },

        hat: extern struct {
            hat: c_int,
            hat_mask: c_int,
        },
    },

    output_type: GamepadBindingType,
    output: extern union {
        button: GamepadButton,

        axis: extern struct {
            axis: GamepadAxis,
            axis_min: c_int,
            axis_max: c_int,
        },
    },
};

/// This is a unique ID for a joystick for the time it is connected to the system,
/// and is never reused for the lifetime of the application. If the joystick is
/// disconnected and reconnected, it will get a new ID.
///
/// The ID value starts at 1 and increments from there. The value 0 is an invalid ID.
pub const JoystickID = enum(u32) {
    invalid = 0,
    _,

    /// Get the SDL_Joystick associated with an instance ID, if it has been opened.
    ///
    /// \param instance_id the instance ID to get the SDL_Joystick for
    /// \returns an SDL_Joystick on success or NULL on failure or if it hasn't been
    ///          opened yet; call SDL_GetError() for more information.
    ///
    pub fn getJoystick(id: JoystickID) Error!*Joystick {
        return SDL_GetJoystickFromInstanceID(id) orelse internal.emitError();
    }

    /// Get the SDL_Gamepad associated with a joystick instance ID, if it has been
    /// opened.
    ///
    /// \param instance_id the joystick instance ID of the gamepad
    /// \returns an SDL_Gamepad on success or NULL on failure or if it hasn't been
    ///          opened yet; call SDL_GetError() for more information.
    ///
    pub fn getGamepad(id: JoystickID) Error!*Gamepad {
        return SDL_GetGamepadFromInstanceID(id) orelse internal.emitError();
    }

    /// Get the implementation dependent name of a joystick.
    ///
    /// This can be called before any joysticks are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the name of the selected joystick. If no name can be found, this
    ///          function returns NULL; call SDL_GetError() for more information.
    ///
    pub fn getName(self: JoystickID) Error![*:0]const u8 {
        return SDL_GetJoystickInstanceName(self) orelse internal.emitError();
    }

    /// Get the implementation dependent path of a joystick.
    ///
    /// This can be called before any joysticks are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the path of the selected joystick. If no path can be found, this
    ///          function returns NULL; call SDL_GetError() for more information.
    ///
    pub fn getPath(self: JoystickID) Error![*:0]const u8 {
        return SDL_GetJoystickInstancePath(self) orelse internal.emitError();
    }

    /// Get the player index of a joystick.
    ///
    /// This can be called before any joysticks are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the player index of a joystick, or -1 if it's not available
    ///
    pub fn getPlayerIndex(self: JoystickID) c_int {
        return SDL_GetJoystickInstancePlayerIndex(self);
    }

    /// Get the implementation-dependent GUID of a joystick.
    ///
    /// This can be called before any joysticks are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the GUID of the selected joystick. If called on an invalid index,
    ///          this function returns a zero GUID
    ///
    pub fn getGUID(self: JoystickID) GUID {
        return SDL_GetJoystickInstanceGUID(self);
    }

    /// Get the USB vendor ID of a joystick, if available.
    ///
    /// This can be called before any joysticks are opened. If the vendor ID isn't
    /// available this function returns 0.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the USB vendor ID of the selected joystick. If called on an
    ///          invalid index, this function returns zero
    ///
    pub fn getVendor(self: JoystickID) u16 {
        return SDL_GetJoystickInstanceVendor(self);
    }

    /// Get the USB product ID of a joystick, if available.
    ///
    /// This can be called before any joysticks are opened. If the product ID isn't
    /// available this function returns 0.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the USB product ID of the selected joystick. If called on an
    ///          invalid index, this function returns zero
    ///
    pub fn getProduct(self: JoystickID) u16 {
        return SDL_GetJoystickInstanceProduct(self);
    }

    /// Get the product version of a joystick, if available.
    ///
    /// This can be called before any joysticks are opened. If the product version
    /// isn't available this function returns 0.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the product version of the selected joystick. If called on an
    ///          invalid index, this function returns zero
    ///
    pub fn getProductVersion(self: JoystickID) u16 {
        return SDL_GetJoystickInstanceProductVersion(self);
    }

    /// Get the type of a joystick, if available.
    ///
    /// This can be called before any joysticks are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the SDL_JoystickType of the selected joystick. If called on an
    ///          invalid index, this function returns `SDL_JOYSTICK_TYPE_UNKNOWN`
    ///
    pub fn getType(self: JoystickID) JoystickType {
        return SDL_GetJoystickInstanceType(self);
    }

    /// Check if the given joystick is supported by the gamepad interface.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns SDL_TRUE if the given joystick is supported by the gamepad
    ///          interface, SDL_FALSE if it isn't or it's an invalid index.
    ///
    /// \since This function is available since SDL 3.0.0.
    ///
    pub fn isGamepad(self: JoystickID) bool {
        return SDL_IsGamepad(self).toZig();
    }

    /// Get the type of a gamepad.
    ///
    /// This can be called before any gamepads are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the gamepad type.
    ///
    pub fn getGamepadType(self: JoystickID) GamepadType {
        return SDL_GetGamepadInstanceType(self);
    }

    /// Get the type of a gamepad, ignoring any mapping override.
    ///
    /// This can be called before any gamepads are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the gamepad type.
    ///
    pub fn getRealGamepadType(self: JoystickID) GamepadType {
        return SDL_GetRealGamepadInstanceType(self);
    }

    /// Get the mapping of a gamepad.
    ///
    /// This can be called before any gamepads are opened.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns the mapping string. Must be freed with SDL_free(). Returns NULL if
    ///          no mapping is available.
    ///
    pub fn getGamepadMapping(self: JoystickID) ?[*:0]u8 {
        return SDL_GetGamepadInstanceMapping(self);
    }

    extern fn SDL_GetJoystickFromInstanceID(instance_id: JoystickID) ?*Joystick;
    extern fn SDL_GetJoystickInstanceName(instance_id: JoystickID) ?[*:0]const u8;
    extern fn SDL_GetJoystickInstancePath(instance_id: JoystickID) ?[*:0]const u8;
    extern fn SDL_GetJoystickInstancePlayerIndex(instance_id: JoystickID) c_int;
    extern fn SDL_GetJoystickInstanceGUID(instance_id: JoystickID) GUID;
    extern fn SDL_GetJoystickInstanceVendor(instance_id: JoystickID) u16;
    extern fn SDL_GetJoystickInstanceProduct(instance_id: JoystickID) u16;
    extern fn SDL_GetJoystickInstanceProductVersion(instance_id: JoystickID) u16;
    extern fn SDL_GetJoystickInstanceType(instance_id: JoystickID) JoystickType;
    extern fn SDL_GetGamepadFromInstanceID(instance_id: JoystickID) ?*Gamepad;
    extern fn SDL_IsGamepad(instance_id: JoystickID) Bool;
    extern fn SDL_GetGamepadInstanceType(instance_id: JoystickID) GamepadType;
    extern fn SDL_GetRealGamepadInstanceType(instance_id: JoystickID) GamepadType;
    extern fn SDL_GetGamepadInstanceMapping(instance_id: JoystickID) ?[*:0]u8;
};

/// The joystick structure used to identify an SDL joystick
pub const Joystick = opaque {
    /// Open a joystick for use.
    ///
    /// The joystick subsystem must be initialized before a joystick can be opened
    /// for use.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns a joystick identifier or NULL if an error occurred; call
    ///          SDL_GetError() for more information.
    ///
    pub fn open(self: JoystickID) Error!*Joystick {
        return SDL_OpenJoystick(self) orelse internal.emitError();
    }

    /// Get the SDL_Joystick associated with a player index.
    ///
    /// \param player_index the player index to get the SDL_Joystick for
    /// \returns an SDL_Joystick on success or NULL on failure; call SDL_GetError()
    ///          for more information.
    ///
    pub fn fromPlayerIndex(index: c_int) Error!*Joystick {
        return SDL_GetJoystickFromPlayerIndex(index) orelse internal.emitError();
    }

    /// Get the properties associated with a joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *Joystick) Error!PropertiesID {
        const id = SDL_GetJoystickProperties(self);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the implementation dependent name of a joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the name of the selected joystick. If no name can be found, this
    ///          function returns NULL; call SDL_GetError() for more information.
    ///
    pub fn getName(self: *Joystick) Error![*:0]const u8 {
        return SDL_GetJoystickName(self) orelse internal.emitError();
    }

    /// Get the implementation dependent path of a joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the path of the selected joystick. If no path can be found, this
    ///          function returns NULL; call SDL_GetError() for more information.
    ///
    pub fn getPath(self: *Joystick) Error![*:0]const u8 {
        return SDL_GetJoystickPath(self) orelse internal.emitError();
    }

    /// Get the player index of an opened joystick.
    ///
    /// For XInput controllers this returns the XInput user index. Many joysticks
    /// will not be able to supply this information.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the player index, or -1 if it's not available.
    ///
    pub fn getPlayerIndex(self: *Joystick) c_int {
        return SDL_GetJoystickPlayerIndex(self);
    }

    /// Set the player index of an opened joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \param player_index Player index to assign to this joystick, or -1 to clear
    ///                     the player index and turn off player LEDs.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setPlayerIndex(self: *Joystick, player_index: c_int) Error!void {
        try internal.checkResult(SDL_SetJoystickPlayerIndex(self, player_index));
    }

    /// Get the implementation-dependent GUID for the joystick.
    ///
    /// This function requires an open joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the GUID of the given joystick. If called on an invalid index,
    ///          this function returns a zero GUID; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getGUID(self: *Joystick) Error!GUID {
        const guid = SDL_GetJoystickGUID(self);
        try internal.assertResult(!guid.isZero());
        return guid;
    }

    /// Get the USB vendor ID of an opened joystick, if available.
    ///
    /// If the vendor ID isn't available this function returns 0.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the USB vendor ID of the selected joystick, or 0 if unavailable.
    ///
    pub fn getVendor(self: *Joystick) u16 {
        return SDL_GetJoystickVendor(self);
    }

    /// Get the USB product ID of an opened joystick, if available.
    ///
    /// If the product ID isn't available this function returns 0.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the USB product ID of the selected joystick, or 0 if unavailable.
    ///
    pub fn getProduct(self: *Joystick) u16 {
        return SDL_GetJoystickProduct(self);
    }

    /// Get the product version of an opened joystick, if available.
    ///
    /// If the product version isn't available this function returns 0.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the product version of the selected joystick, or 0 if unavailable.
    ///
    pub fn getProductVersion(self: *Joystick) u16 {
        return SDL_GetJoystickProductVersion(self);
    }

    /// Get the firmware version of an opened joystick, if available.
    ///
    /// If the firmware version isn't available this function returns 0.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the firmware version of the selected joystick, or 0 if
    ///          unavailable.
    ///
    pub fn getFirmwareVersion(self: *Joystick) u16 {
        return SDL_GetJoystickFirmwareVersion(self);
    }

    /// Get the serial number of an opened joystick, if available.
    ///
    /// Returns the serial number of the joystick, or NULL if it is not available.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the serial number of the selected joystick, or NULL if
    ///          unavailable.
    ///
    pub fn getSerial(self: *Joystick) Error![*:0]const u8 {
        return SDL_GetJoystickSerial(self) orelse internal.retError();
    }

    /// Get the type of an opened joystick.
    ///
    /// \param joystick the SDL_Joystick obtained from SDL_OpenJoystick()
    /// \returns the SDL_JoystickType of the selected joystick.
    ///
    pub fn getType(self: *Joystick) JoystickType {
        return SDL_GetJoystickType(self);
    }

    /// Get the status of a specified joystick.
    ///
    /// \param joystick the joystick to query
    /// \returns SDL_TRUE if the joystick has been opened, SDL_FALSE if it has not;
    ///          call SDL_GetError() for more information.
    ///
    pub fn isConnected(self: *Joystick) Error!bool {
        const res = SDL_JoystickConnected(self).toZig();
        try internal.hasError();
        return res;
    }

    /// Get the instance ID of an opened joystick.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \returns the instance ID of the specified joystick on success or 0 on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn getID(self: *Joystick) Error!JoystickID {
        const id = SDL_GetJoystickInstanceID(self);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the number of general axis controls on a joystick.
    ///
    /// Often, the directional pad on a game controller will either look like 4
    /// separate buttons or a POV hat, and not axes, but all of this is up to the
    /// device and platform.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \returns the number of axis controls/number of axes on success or a
    ///          negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getNumAxes(self: *Joystick) Error!c_int {
        const num = SDL_GetNumJoystickAxes(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the number of POV hats on a joystick.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \returns the number of POV hats on success or a negative error code on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn getNumHats(self: *Joystick) Error!c_int {
        const num = SDL_GetNumJoystickHats(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the number of buttons on a joystick.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \returns the number of buttons on success or a negative error code on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn getNumButtons(self: *Joystick) Error!c_int {
        const num = SDL_GetNumJoystickButtons(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the current state of an axis control on a joystick.
    ///
    /// SDL makes no promises about what part of the joystick any given axis refers
    /// to. Your game should have some sort of configuration UI to let users
    /// specify what each axis should be bound to. Alternately, SDL's higher-level
    /// Game Controller API makes a great effort to apply order to this lower-level
    /// interface, so you know that a specific axis is the "left thumb stick," etc.
    ///
    /// The value returned by SDL_GetJoystickAxis() is a signed integer (-32768 to
    /// 32767) representing the current position of the axis. It may be necessary
    /// to impose certain tolerances on these values to account for jitter.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \param axis the axis to query; the axis indices start at index 0
    /// \returns a 16-bit signed integer representing the current position of the
    ///          axis or 0 on failure; call SDL_GetError() for more information.
    ///
    pub fn getAxis(self: *Joystick, axis: c_int) i16 {
        const state = SDL_GetJoystickAxis(self, axis);
        try internal.assertResult(state == 0);
        return state;
    }

    /// Get the initial state of an axis control on a joystick.
    ///
    /// The state is a value ranging from -32768 to 32767.
    ///
    /// The axis indices start at index 0.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \param axis the axis to query; the axis indices start at index 0
    /// \param state Upon return, the initial value is supplied here.
    /// \returns SDL_TRUE if this axis has any initial value, or SDL_FALSE if not.
    ///
    pub fn getAxisInitialState(self: *Joystick, axis: c_int, state: *i16) bool {
        return SDL_GetJoystickAxisInitialState(self, axis, state).toZig();
    }

    /// Get the current state of a POV hat on a joystick.
    ///
    /// The returned value will be one of the following positions:
    ///
    /// - `SDL_HAT_CENTERED`
    /// - `SDL_HAT_UP`
    /// - `SDL_HAT_RIGHT`
    /// - `SDL_HAT_DOWN`
    /// - `SDL_HAT_LEFT`
    /// - `SDL_HAT_RIGHTUP`
    /// - `SDL_HAT_RIGHTDOWN`
    /// - `SDL_HAT_LEFTUP`
    /// - `SDL_HAT_LEFTDOWN`
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \param hat the hat index to get the state from; indices start at index 0
    /// \returns the current hat position.
    ///
    pub fn getHat(self: *Joystick, hat: c_int) JoystickHat {
        return SDL_GetJoystickHat(self, hat);
    }

    /// Get the current state of a button on a joystick.
    ///
    /// \param joystick an SDL_Joystick structure containing joystick information
    /// \param button the button index to get the state from; indices start at
    ///               index 0
    /// \returns 1 if the specified button is pressed, 0 otherwise.
    ///
    pub fn getButton(self: *Joystick, button: c_int) bool {
        return SDL_GetJoystickButton(self, button) != 0;
    }

    /// Start a rumble effect.
    ///
    /// Each call to this function cancels any previous rumble effect, and calling
    /// it with 0 intensity stops any rumbling.
    ///
    /// \param joystick The joystick to vibrate
    /// \param low_frequency_rumble The intensity of the low frequency (left)
    ///                             rumble motor, from 0 to 0xFFFF
    /// \param high_frequency_rumble The intensity of the high frequency (right)
    ///                              rumble motor, from 0 to 0xFFFF
    /// \param duration_ms The duration of the rumble effect, in milliseconds
    /// \returns 0, or -1 if rumble isn't supported on this joystick
    ///
    pub fn rumble(self: *Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int {
        return SDL_RumbleJoystick(self, low_frequency_rumble, high_frequency_rumble, duration_ms);
    }

    /// Start a rumble effect in the joystick's triggers
    ///
    /// Each call to this function cancels any previous trigger rumble effect, and
    /// calling it with 0 intensity stops any rumbling.
    ///
    /// Note that this is rumbling of the _triggers_ and not the game controller as
    /// a whole. This is currently only supported on Xbox One controllers. If you
    /// want the (more common) whole-controller rumble, use SDL_RumbleJoystick()
    /// instead.
    ///
    /// \param joystick The joystick to vibrate
    /// \param left_rumble The intensity of the left trigger rumble motor, from 0
    ///                    to 0xFFFF
    /// \param right_rumble The intensity of the right trigger rumble motor, from 0
    ///                     to 0xFFFF
    /// \param duration_ms The duration of the rumble effect, in milliseconds
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn rumbleTriggers(self: *Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) Error!void {
        try internal.checkResult(SDL_RumbleJoystickTriggers(self, left_rumble, right_rumble, duration_ms));
    }

    /// Query whether a joystick has an LED.
    ///
    /// An example of a joystick LED is the light on the back of a PlayStation 4's
    /// DualShock 4 controller.
    ///
    /// \param joystick The joystick to query
    /// \returns SDL_TRUE if the joystick has a modifiable LED, SDL_FALSE
    ///          otherwise.
    ///
    pub fn hasLED(self: *Joystick) bool {
        return SDL_JoystickHasLED(self).toZig();
    }

    /// Query whether a joystick has rumble support.
    ///
    /// \param joystick The joystick to query
    /// \returns SDL_TRUE if the joystick has rumble, SDL_FALSE otherwise.
    ///
    pub fn hasRumble(self: *Joystick) bool {
        return SDL_JoystickHasRumble(self).toZig();
    }

    /// Query whether a joystick has rumble support on triggers.
    ///
    /// \param joystick The joystick to query
    /// \returns SDL_TRUE if the joystick has trigger rumble, SDL_FALSE otherwise.
    ///
    pub fn hasRumbleTriggers(self: *Joystick) bool {
        return SDL_JoystickHasRumbleTriggers(self).toZig();
    }

    /// Update a joystick's LED color.
    ///
    /// An example of a joystick LED is the light on the back of a PlayStation 4's
    /// DualShock 4 controller.
    ///
    /// \param joystick The joystick to update
    /// \param red The intensity of the red LED
    /// \param green The intensity of the green LED
    /// \param blue The intensity of the blue LED
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setLED(self: *Joystick, red: u8, green: u8, blue: u8) Error!void {
        try internal.checkResult(SDL_SetJoystickLED(self, red, green, blue));
    }

    /// Send a joystick specific effect packet
    ///
    /// \param joystick The joystick to affect
    /// \param data The data to send to the joystick
    /// \param size The size of the data to send to the joystick
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn sendEffect(self: *Joystick, data: *const anyopaque, size: c_int) Error!void {
        try internal.checkResult(SDL_SendJoystickEffect(self, data, size));
    }

    /// Get the battery level of a joystick as SDL_JoystickPowerLevel.
    ///
    /// \param joystick the SDL_Joystick to query
    /// \returns the current battery level as SDL_JoystickPowerLevel on success or
    ///          `SDL_JOYSTICK_POWER_UNKNOWN` if it is unknown
    ///
    pub fn getPowerLevel(self: *Joystick) JoystickPowerLevel {
        return SDL_GetJoystickPowerLevel(self);
    }

    /// Query if a joystick has haptic features.
    ///
    /// \param joystick the SDL_Joystick to test for haptic capabilities
    /// \returns SDL_TRUE if the joystick is haptic, SDL_FALSE if it isn't, or a
    ///          negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn isHaptic(self: *Joystick) Error!bool {
        const res = SDL_JoystickIsHaptic(self);
        try internal.assertResult(res >= 0);
        return if (res == 0) false else true;
    }

    /// Close a joystick previously opened with SDL_OpenJoystick().
    ///
    /// \param joystick The joystick device to close
    ///
    pub fn close(self: *Joystick) void {
        SDL_CloseJoystick(self);
    }

    extern fn SDL_OpenJoystick(instance_id: JoystickID) ?*Joystick;
    extern fn SDL_GetJoystickFromPlayerIndex(player_index: c_int) ?*Joystick;
    extern fn SDL_GetJoystickProperties(joystick: *Joystick) PropertiesID;
    extern fn SDL_GetJoystickName(joystick: *Joystick) ?[*:0]const u8;
    extern fn SDL_GetJoystickPath(joystick: *Joystick) ?[*:0]const u8;
    extern fn SDL_GetJoystickPlayerIndex(joystick: *Joystick) c_int;
    extern fn SDL_SetJoystickPlayerIndex(joystick: *Joystick, player_index: c_int) c_int;
    extern fn SDL_GetJoystickGUID(joystick: *Joystick) GUID;
    extern fn SDL_GetJoystickVendor(joystick: *Joystick) u16;
    extern fn SDL_GetJoystickProduct(joystick: *Joystick) u16;
    extern fn SDL_GetJoystickProductVersion(joystick: *Joystick) u16;
    extern fn SDL_GetJoystickFirmwareVersion(joystick: *Joystick) u16;
    extern fn SDL_GetJoystickSerial(joystick: *Joystick) ?[*:0]const u8;
    extern fn SDL_GetJoystickType(joystick: *Joystick) JoystickType;
    extern fn SDL_JoystickConnected(joystick: *Joystick) Bool;
    extern fn SDL_GetJoystickInstanceID(joystick: *Joystick) JoystickID;
    extern fn SDL_GetNumJoystickAxes(joystick: *Joystick) c_int;
    extern fn SDL_GetNumJoystickHats(joystick: *Joystick) c_int;
    extern fn SDL_GetNumJoystickButtons(joystick: *Joystick) c_int;
    extern fn SDL_GetJoystickAxis(joystick: *Joystick, axis: c_int) i16;
    extern fn SDL_GetJoystickAxisInitialState(joystick: *Joystick, axis: c_int, state: *i16) Bool;
    extern fn SDL_GetJoystickHat(joystick: *Joystick, hat: c_int) u8;
    extern fn SDL_GetJoystickButton(joystick: *Joystick, button: c_int) u8;
    extern fn SDL_RumbleJoystick(joystick: *Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int;
    extern fn SDL_RumbleJoystickTriggers(joystick: *Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) c_int;
    extern fn SDL_JoystickHasLED(joystick: *Joystick) Bool;
    extern fn SDL_JoystickHasRumble(joystick: *Joystick) Bool;
    extern fn SDL_JoystickHasRumbleTriggers(joystick: *Joystick) Bool;
    extern fn SDL_SetJoystickLED(joystick: *Joystick, red: u8, green: u8, blue: u8) c_int;
    extern fn SDL_SendJoystickEffect(joystick: *Joystick, data: *const anyopaque, size: c_int) c_int;
    extern fn SDL_GetJoystickPowerLevel(joystick: *Joystick) JoystickPowerLevel;
    extern fn SDL_CloseJoystick(joystick: *Joystick) void;

    // from haptic.h
    extern fn SDL_JoystickIsHaptic(joystick: *Joystick) c_int;
};

pub const Gamepad = opaque {
    /// Open a gamepad for use.
    ///
    /// \param instance_id the joystick instance ID
    /// \returns a gamepad identifier or NULL if an error occurred; call
    ///          SDL_GetError() for more information.
    ///
    pub fn open(self: JoystickID) Error!*Gamepad {
        return SDL_OpenGamepad(self) orelse internal.emitError();
    }

    /// Get the SDL_Gamepad associated with a player index.
    ///
    /// \param player_index the player index, which different from the instance ID
    /// \returns the SDL_Gamepad associated with a player index.
    ///
    pub fn fromPlayerIndex(player_index: c_int) Error!*Gamepad {
        return SDL_GetGamepadFromPlayerIndex(player_index) orelse internal.emitError();
    }

    /// Get the properties associated with an opened gamepad.
    ///
    /// These properties are shared with the underlying joystick object.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *Gamepad) Error!PropertiesID {
        const props = SDL_GetGamepadProperties(self);
        try internal.assertResult(props != .invalid);
        return props;
    }

    /// Get the instance ID of an opened gamepad.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns the instance ID of the specified gamepad on success or 0 on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn getID(self: *Gamepad) Error!JoystickID {
        const id = SDL_GetGamepadInstanceID(self);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the implementation-dependent name for an opened gamepad.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns the implementation dependent name for the gamepad, or NULL if
    ///          there is no name or the identifier passed is invalid.
    ///
    pub fn getName(self: *Gamepad) ?[*:0]const u8 {
        return SDL_GetGamepadName(self);
    }

    /// Get the implementation-dependent path for an opened gamepad.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns the implementation dependent path for the gamepad, or NULL if
    ///          there is no path or the identifier passed is invalid.
    ///
    pub fn getPath(self: *Gamepad) ?[*:0]const u8 {
        return SDL_GetGamepadPath(self);
    }

    /// Get the type of an opened gamepad, ignoring any mapping override.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
    ///          available.
    ///
    pub fn getType(self: *Gamepad) GamepadType {
        return SDL_GetGamepadType(self);
    }

    /// Get the type of an opened gamepad, ignoring any mapping override.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the gamepad type, or SDL_GAMEPAD_TYPE_UNKNOWN if it's not
    ///          available.
    ///
    pub fn getRealType(self: *Gamepad) GamepadType {
        return SDL_GetRealGamepadType(self);
    }

    /// Get the player index of an opened gamepad.
    ///
    /// For XInput gamepads this returns the XInput user index.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the player index for gamepad, or -1 if it's not available.
    ///
    pub fn getPlayerIndex(self: *Gamepad) c_int {
        return SDL_GetGamepadPlayerIndex(self);
    }

    /// Set the player index of an opened gamepad.
    ///
    /// \param gamepad the gamepad object to adjust.
    /// \param player_index Player index to assign to this gamepad, or -1 to clear
    ///                     the player index and turn off player LEDs.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setPlayerIndex(self: *Gamepad, player_index: c_int) Error!void {
        try internal.checkResult(SDL_SetGamepadPlayerIndex(self, player_index));
    }

    /// Get the USB vendor ID of an opened gamepad, if available.
    ///
    /// If the vendor ID isn't available this function returns 0.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the USB vendor ID, or zero if unavailable.
    ///
    pub fn getVendor(self: *Gamepad) u16 {
        return SDL_GetGamepadVendor(self);
    }

    /// Get the USB product ID of an opened gamepad, if available.
    ///
    /// If the product ID isn't available this function returns 0.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the USB product ID, or zero if unavailable.
    ///
    pub fn getProduct(self: *Gamepad) u16 {
        return SDL_GetGamepadProduct(self);
    }

    /// Get the product version of an opened gamepad, if available.
    ///
    /// If the product version isn't available this function returns 0.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the USB product version, or zero if unavailable.
    ///
    pub fn getProductVersion(self: *Gamepad) u16 {
        return SDL_GetGamepadProductVersion(self);
    }

    /// Get the firmware version of an opened gamepad, if available.
    ///
    /// If the firmware version isn't available this function returns 0.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the gamepad firmware version, or zero if unavailable.
    ///
    pub fn getFirmwareVersion(self: *Gamepad) u16 {
        return SDL_GetGamepadFirmwareVersion(self);
    }

    /// Get the serial number of an opened gamepad, if available.
    ///
    /// Returns the serial number of the gamepad, or NULL if it is not available.
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the serial number, or NULL if unavailable.
    ///
    pub fn getSerial(self: *Gamepad) ?[*:0]const u8 {
        return SDL_GetGamepadSerial(self);
    }

    /// Get the Steam Input handle of an opened gamepad, if available.
    ///
    /// Returns an InputHandle_t for the gamepad that can be used with Steam Input
    /// API: https://partner.steamgames.com/doc/api/ISteamInput
    ///
    /// \param gamepad the gamepad object to query.
    /// \returns the gamepad handle, or 0 if unavailable.
    ///
    pub fn getSteamHandle(self: *Gamepad) u64 {
        return SDL_GetGamepadSteamHandle(self);
    }

    /// Get the battery level of a gamepad, if available.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns the current battery level as SDL_JoystickPowerLevel on success or
    ///          `SDL_JOYSTICK_POWER_UNKNOWN` if it is unknown
    ///
    pub fn getPowerLevel(self: *Gamepad) JoystickPowerLevel {
        return SDL_GetGamepadPowerLevel(self);
    }

    /// Check if a gamepad has been opened and is currently connected.
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    /// \returns SDL_TRUE if the gamepad has been opened and is currently
    ///          connected, or SDL_FALSE if not.
    ///
    pub fn isConnected(self: *Gamepad) bool {
        return SDL_GamepadConnected(self).toZig();
    }

    /// Get the underlying joystick from a gamepad
    ///
    /// This function will give you a SDL_Joystick object, which allows you to use
    /// the SDL_Joystick functions with a SDL_Gamepad object. This would be useful
    /// for getting a joystick's position at any given time, even if it hasn't
    /// moved (moving it would produce an event, which would have the axis' value).
    ///
    /// The pointer returned is owned by the SDL_Gamepad. You should not call
    /// SDL_CloseJoystick() on it, for example, since doing so will likely cause
    /// SDL to crash.
    ///
    /// \param gamepad the gamepad object that you want to get a joystick from
    /// \returns an SDL_Joystick object; call SDL_GetError() for more information.
    ///
    pub fn getJoystick(self: *Gamepad) Error!*Joystick {
        return SDL_GetGamepadJoystick(self) orelse internal.emitError();
    }

    /// Get the SDL joystick layer bindings for a gamepad
    ///
    /// \param gamepad a gamepad
    /// \param count a pointer filled in with the number of bindings returned
    /// \returns a NULL terminated array of pointers to bindings which should be
    ///          freed with SDL_free(), or NULL on error; call SDL_GetError() for
    ///          more details.
    ///
    pub fn getBindings(self: *Gamepad) Error![]*GamepadBinding {
        var len: c_int = 0;

        if (SDL_GetGamepadBindings(self, &len)) |arr|
            return arr[0..@intCast(len)]
        else
            return internal.emitError();
    }

    /// Query whether a gamepad has a given axis.
    ///
    /// This merely reports whether the gamepad's mapping defined this axis, as
    /// that is all the information SDL has about the physical device.
    ///
    /// \param gamepad a gamepad
    /// \param axis an axis enum value (an SDL_GamepadAxis value)
    /// \returns SDL_TRUE if the gamepad has this axis, SDL_FALSE otherwise.
    ///
    pub fn hasAxis(self: *Gamepad, axis: GamepadAxis) bool {
        return SDL_GamepadHasAxis(self, axis).toZig();
    }

    /// Query whether a gamepad has a given button.
    ///
    /// This merely reports whether the gamepad's mapping defined this button, as
    /// that is all the information SDL has about the physical device.
    ///
    /// \param gamepad a gamepad
    /// \param button a button enum value (an SDL_GamepadButton value)
    /// \returns SDL_TRUE if the gamepad has this button, SDL_FALSE otherwise.
    ///
    pub fn hasButton(self: *Gamepad, button: GamepadButton) bool {
        return SDL_GamepadHasButton(self, button).toZig();
    }

    /// Get the current state of an axis control on a gamepad.
    ///
    /// The axis indices start at index 0.
    ///
    /// The state is a value ranging from -32768 to 32767. Triggers, however, range
    /// from 0 to 32767 (they never return a negative value).
    ///
    /// \param gamepad a gamepad
    /// \param axis an axis index (one of the SDL_GamepadAxis values)
    /// \returns axis state (including 0) on success or 0 (also) on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getAxis(self: *Gamepad, axis: GamepadAxis) i16 {
        return SDL_GetGamepadAxis(self, axis);
    }

    /// Get the current state of a button on a gamepad.
    ///
    /// \param gamepad a gamepad
    /// \param button a button index (one of the SDL_GamepadButton values)
    /// \returns 1 for pressed state or 0 for not pressed state or error; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getButton(self: *Gamepad, button: GamepadButton) bool {
        return SDL_GetGamepadButton(self, button) == 1;
    }

    /// Get the number of touchpads on a gamepad.
    ///
    /// \param gamepad a gamepad
    /// \returns number of touchpads
    ///
    pub fn getNumTouchpads(self: *Gamepad) c_int {
        return SDL_GetNumGamepadTouchpads(self);
    }

    /// Get the number of supported simultaneous fingers on a touchpad on a game
    /// gamepad.
    ///
    /// \param gamepad a gamepad
    /// \param touchpad a touchpad
    /// \returns number of supported simultaneous fingers
    ///
    pub fn getNumTouchpadFingers(self: *Gamepad, touchpad: c_int) c_int {
        return SDL_GetNumGamepadTouchpadFingers(self, touchpad);
    }

    /// Get the current state of a finger on a touchpad on a gamepad.
    ///
    /// \param gamepad a gamepad
    /// \param touchpad a touchpad
    /// \param finger a finger
    /// \param state filled with state
    /// \param x filled with x position
    /// \param y filled with y position
    /// \param pressure filled with pressure value
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getTouchpadFinger(self: *Gamepad, touchpad: c_int, finger: c_int, state: *u8, x: *f32, y: *f32, pressure: *f32) Error!void {
        try internal.checkResult(SDL_GetGamepadTouchpadFinger(self, touchpad, finger, state, x, y, pressure));
    }

    /// Return whether a gamepad has a particular sensor.
    ///
    /// \param gamepad The gamepad to query
    /// \param type The type of sensor to query
    /// \returns SDL_TRUE if the sensor exists, SDL_FALSE otherwise.
    ///
    pub fn hasSensor(self: *Gamepad, ty: SensorType) bool {
        return SDL_GamepadHasSensor(self, ty).toZig();
    }

    /// Set whether data reporting for a gamepad sensor is enabled.
    ///
    /// \param gamepad The gamepad to update
    /// \param type The type of sensor to enable/disable
    /// \param enabled Whether data reporting should be enabled
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setSensorEnabled(self: *Gamepad, ty: SensorType, enabled: Bool) Error!void {
        try internal.checkResult(SDL_SetGamepadSensorEnabled(self, ty, enabled));
    }

    /// Query whether sensor data reporting is enabled for a gamepad.
    ///
    /// \param gamepad The gamepad to query
    /// \param type The type of sensor to query
    /// \returns SDL_TRUE if the sensor is enabled, SDL_FALSE otherwise.
    ///
    pub fn isSensorEnabled(self: *Gamepad, ty: SensorType) bool {
        return SDL_GamepadSensorEnabled(self, ty).toZig();
    }

    /// Get the data rate (number of events per second) of a gamepad sensor.
    ///
    /// \param gamepad The gamepad to query
    /// \param type The type of sensor to query
    /// \returns the data rate, or 0.0f if the data rate is not available.
    ///
    pub fn getSensorDataRate(self: *Gamepad, ty: SensorType) f32 {
        return SDL_GetGamepadSensorDataRate(self, ty);
    }

    /// Get the current state of a gamepad sensor.
    ///
    /// The number of values and interpretation of the data is sensor dependent.
    /// See SDL_sensor.h for the details for each type of sensor.
    ///
    /// \param gamepad The gamepad to query
    /// \param type The type of sensor to query
    /// \param data A pointer filled with the current sensor state
    /// \param num_values The number of values to write to data
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getSensorData(self: *Gamepad, ty: SensorType, data: []f32) Error!void {
        try internal.checkResult(SDL_GetGamepadSensorData(self, ty, data.ptr, @intCast(data.len)));
    }

    /// Start a rumble effect on a gamepad.
    ///
    /// Each call to this function cancels any previous rumble effect, and calling
    /// it with 0 intensity stops any rumbling.
    ///
    /// \param gamepad The gamepad to vibrate
    /// \param low_frequency_rumble The intensity of the low frequency (left)
    ///                             rumble motor, from 0 to 0xFFFF
    /// \param high_frequency_rumble The intensity of the high frequency (right)
    ///                              rumble motor, from 0 to 0xFFFF
    /// \param duration_ms The duration of the rumble effect, in milliseconds
    /// \returns 0, or -1 if rumble isn't supported on this gamepad
    ///
    pub fn rumble(self: *Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int {
        return SDL_RumbleGamepad(self, low_frequency_rumble, high_frequency_rumble, duration_ms);
    }

    /// Start a rumble effect in the gamepad's triggers.
    ///
    /// Each call to this function cancels any previous trigger rumble effect, and
    /// calling it with 0 intensity stops any rumbling.
    ///
    /// Note that this is rumbling of the _triggers_ and not the gamepad as a
    /// whole. This is currently only supported on Xbox One gamepads. If you want
    /// the (more common) whole-gamepad rumble, use SDL_RumbleGamepad() instead.
    ///
    /// \param gamepad The gamepad to vibrate
    /// \param left_rumble The intensity of the left trigger rumble motor, from 0
    ///                    to 0xFFFF
    /// \param right_rumble The intensity of the right trigger rumble motor, from 0
    ///                     to 0xFFFF
    /// \param duration_ms The duration of the rumble effect, in milliseconds
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn rumbleTriggers(self: *Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) Error!void {
        try internal.checkResult(SDL_RumbleGamepadTriggers(self, left_rumble, right_rumble, duration_ms));
    }

    /// Query whether a gamepad has rumble support.
    ///
    /// \param gamepad The gamepad to query
    /// \returns SDL_TRUE, or SDL_FALSE if this gamepad does not have rumble
    ///          support
    ///
    pub fn hasRumble(self: *Gamepad) bool {
        return SDL_GamepadHasRumble(self).toZig();
    }

    /// Query whether a gamepad has rumble support on triggers.
    ///
    /// \param gamepad The gamepad to query
    /// \returns SDL_TRUE, or SDL_FALSE if this gamepad does not have trigger
    ///          rumble support
    ///
    pub fn hasRumbleTriggers(self: *Gamepad) bool {
        return SDL_GamepadHasRumbleTriggers(self).toZig();
    }

    /// Query whether a gamepad has an LED.
    ///
    /// \param gamepad The gamepad to query
    /// \returns SDL_TRUE, or SDL_FALSE if this gamepad does not have a modifiable
    ///          LED
    ///
    pub fn hasLED(self: *Gamepad) bool {
        return SDL_GamepadHasLED(self).toZig();
    }

    /// Update a gamepad's LED color.
    ///
    /// \param gamepad The gamepad to update
    /// \param red The intensity of the red LED
    /// \param green The intensity of the green LED
    /// \param blue The intensity of the blue LED
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setLED(self: *Gamepad, red: u8, green: u8, blue: u8) Error!void {
        try internal.checkResult(SDL_SetGamepadLED(self, red, green, blue));
    }

    /// Send a gamepad specific effect packet
    ///
    /// \param gamepad The gamepad to affect
    /// \param data The data to send to the gamepad
    /// \param size The size of the data to send to the gamepad
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn sendEffect(self: *Gamepad, data: *const anyopaque, size: c_int) Error!void {
        try internal.checkResult(SDL_SendGamepadEffect(self, data, size));
    }

    /// Close a gamepad previously opened with SDL_OpenGamepad().
    ///
    /// \param gamepad a gamepad identifier previously returned by
    ///                SDL_OpenGamepad()
    ///
    /// \since This function is available since SDL 3.0.0.
    ///
    pub fn close(self: *Gamepad) void {
        SDL_CloseGamepad(self);
    }

    extern fn SDL_OpenGamepad(instance_id: JoystickID) ?*Gamepad;
    extern fn SDL_GetGamepadFromPlayerIndex(player_index: c_int) ?*Gamepad;
    extern fn SDL_GetGamepadProperties(gamepad: *Gamepad) PropertiesID;
    extern fn SDL_GetGamepadInstanceID(gamepad: *Gamepad) JoystickID;
    extern fn SDL_GetGamepadName(gamepad: *Gamepad) ?[*:0]const u8;
    extern fn SDL_GetGamepadPath(gamepad: *Gamepad) ?[*:0]const u8;
    extern fn SDL_GetGamepadType(gamepad: *Gamepad) GamepadType;
    extern fn SDL_GetRealGamepadType(gamepad: *Gamepad) GamepadType;
    extern fn SDL_GetGamepadPlayerIndex(gamepad: *Gamepad) c_int;
    extern fn SDL_SetGamepadPlayerIndex(gamepad: *Gamepad, player_index: c_int) c_int;
    extern fn SDL_GetGamepadVendor(gamepad: *Gamepad) u16;
    extern fn SDL_GetGamepadProduct(gamepad: *Gamepad) u16;
    extern fn SDL_GetGamepadProductVersion(gamepad: *Gamepad) u16;
    extern fn SDL_GetGamepadFirmwareVersion(gamepad: *Gamepad) u16;
    extern fn SDL_GetGamepadSerial(gamepad: *Gamepad) ?[*:0]const u8;
    extern fn SDL_GetGamepadSteamHandle(gamepad: *Gamepad) u64;
    extern fn SDL_GetGamepadPowerLevel(gamepad: *Gamepad) JoystickPowerLevel;
    extern fn SDL_GamepadConnected(gamepad: *Gamepad) Bool;
    extern fn SDL_GetGamepadJoystick(gamepad: *Gamepad) ?*Joystick;
    extern fn SDL_GetGamepadBindings(gamepad: *Gamepad, count: *c_int) ?[*]*GamepadBinding;
    extern fn SDL_GamepadHasAxis(gamepad: *Gamepad, axis: GamepadAxis) Bool;
    extern fn SDL_GamepadHasButton(gamepad: *Gamepad, button: GamepadButton) Bool;
    extern fn SDL_GetGamepadAxis(gamepad: *Gamepad, axis: GamepadAxis) i16;
    extern fn SDL_GetGamepadButton(gamepad: *Gamepad, button: GamepadButton) u8;
    extern fn SDL_GetNumGamepadTouchpads(gamepad: *Gamepad) c_int;
    extern fn SDL_GetNumGamepadTouchpadFingers(gamepad: *Gamepad, touchpad: c_int) c_int;
    extern fn SDL_GetGamepadTouchpadFinger(gamepad: *Gamepad, touchpad: c_int, finger: c_int, state: *u8, x: *f32, y: *f32, pressure: *f32) c_int;
    extern fn SDL_GamepadHasSensor(gamepad: *Gamepad, ty: SensorType) Bool;
    extern fn SDL_SetGamepadSensorEnabled(gamepad: *Gamepad, ty: SensorType, enabled: Bool) c_int;
    extern fn SDL_GamepadSensorEnabled(gamepad: *Gamepad, ty: SensorType) Bool;
    extern fn SDL_GetGamepadSensorDataRate(gamepad: *Gamepad, ty: SensorType) f32;
    extern fn SDL_GetGamepadSensorData(gamepad: *Gamepad, ty: SensorType, data: [*]f32, num_values: c_int) c_int;
    extern fn SDL_RumbleGamepad(gamepad: *Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) c_int;
    extern fn SDL_RumbleGamepadTriggers(gamepad: *Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) c_int;
    extern fn SDL_GamepadHasRumble(gamepad: *Gamepad) Bool;
    extern fn SDL_GamepadHasRumbleTriggers(gamepad: *Gamepad) Bool;
    extern fn SDL_GamepadHasLED(gamepad: *Gamepad) Bool;
    extern fn SDL_SetGamepadLED(gamepad: *Gamepad, red: u8, green: u8, blue: u8) c_int;
    extern fn SDL_SendGamepadEffect(gamepad: *Gamepad, data: *const anyopaque, size: c_int) c_int;
    extern fn SDL_CloseGamepad(gamepad: *Gamepad) void;
};

/// Get a list of currently connected joysticks.
///
/// \param count a pointer filled in with the number of joysticks returned
/// \returns a 0 terminated array of joystick instance IDs which should be
///          freed with SDL_free(), or NULL on error; call SDL_GetError() for
///          more details.
///
pub fn getJoysticks() Error![:.invalid]JoystickID {
    var len: c_int = 0;

    if (SDL_GetJoysticks(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

/// Get a list of currently connected gamepads.
///
/// \param count a pointer filled in with the number of gamepads returned
/// \returns a 0 terminated array of joystick instance IDs which should be
///          freed with SDL_free(), or NULL on error; call SDL_GetError() for
///          more details.
///
pub fn getGamepads() Error![:.invalid]JoystickID {
    var len: c_int = 0;

    if (SDL_GetGamepads(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

/// Add support for gamepads that SDL is unaware of or change the binding of an
/// existing gamepad.
///
/// The mapping string has the format "GUID,name,mapping", where GUID is the
/// string value from SDL_GetJoystickGUIDString(), name is the human readable
/// string for the device and mappings are gamepad mappings to joystick ones.
/// Under Windows there is a reserved GUID of "xinput" that covers all XInput
/// devices. The mapping format for joystick is:
///
/// - `bX`: a joystick button, index X
/// - `hX.Y`: hat X with value Y
/// - `aX`: axis X of the joystick
///
/// Buttons can be used as a gamepad axes and vice versa.
///
/// This string shows an example of a valid mapping for a gamepad:
///
/// ```c
/// "341a3608000000000000504944564944,Afterglow PS3 Controller,a:b1,b:b2,y:b3,x:b0,start:b9,guide:b12,back:b8,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,leftshoulder:b4,rightshoulder:b5,leftstick:b10,rightstick:b11,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b6,righttrigger:b7"
/// ```
///
/// \param mapping the mapping string
/// \returns 1 if a new mapping is added, 0 if an existing mapping is updated,
///          -1 on error; call SDL_GetError() for more information.
///
pub fn addGamepadMapping(mapping: [*:0]const u8) Error!void {
    try internal.checkResult(SDL_AddGamepadMapping(mapping));
}

/// Reinitialize the SDL mapping database to its initial state.
///
/// This will generate gamepad events as needed if device mappings change.
///
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn reloadGamepadMappings() Error!void {
    try internal.checkResult(SDL_ReloadGamepadMappings());
}

/// Set the state of joystick event processing.
///
/// If joystick events are disabled, you must call SDL_UpdateJoysticks()
/// yourself and check the state of the joystick when you want joystick
/// information.
///
/// \param enabled whether to process joystick events or not
///
pub fn setJoystickEventsEnabled(enabled: bool) void {
    SDL_SetJoystickEventsEnabled(Bool.fromZig(enabled));
}

/// Query the state of joystick event processing.
///
/// If joystick events are disabled, you must call SDL_UpdateJoysticks()
/// yourself and check the state of the joystick when you want joystick
/// information.
///
/// \returns SDL_TRUE if joystick events are being processed, SDL_FALSE
///          otherwise.
///
pub fn isJoystickEventsEnabled() bool {
    return SDL_JoystickEventsEnabled().toZig();
}

/// Update the current state of the open joysticks.
///
/// This is called automatically by the event loop if any joystick events are
/// enabled.
///
pub fn updateJoysticks() void {
    SDL_UpdateJoysticks();
}

/// Set the state of gamepad event processing.
///
/// If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
/// and check the state of the gamepad when you want gamepad information.
///
/// \param enabled whether to process gamepad events or not
///
pub fn setGamepadEventsEnabled(enabled: bool) void {
    SDL_SetGamepadEventsEnabled(Bool.fromZig(enabled));
}

/// Query the state of gamepad event processing.
///
/// If gamepad events are disabled, you must call SDL_UpdateGamepads() yourself
/// and check the state of the gamepad when you want gamepad information.
///
/// \returns SDL_TRUE if gamepad events are being processed, SDL_FALSE
///          otherwise.
///
pub fn isGamepadEventsEnabled() bool {
    return SDL_GamepadEventsEnabled().toZig();
}

/// Manually pump gamepad updates if not using the loop.
///
/// This function is called automatically by the event loop if events are
/// enabled. Under such circumstances, it will not be necessary to call this
/// function.
///
pub fn updateGamepads() void {
    SDL_UpdateGamepads();
}

/// Get the mapping at a particular index.
///
/// You must free the returned pointer with SDL_free() when you are done with
/// it, but you do _not_ free each string in the array.
///
/// \param count a pointer filled in with the number of mappings returned, can
///              be NULL.
/// \returns an array of the mapping strings, NULL-terminated. Must be freed
///          with SDL_free(). Returns NULL on error.
///
/// \since This function is available since SDL 3.0.0.
///
pub fn getGamepadMappings() Error![][*:0]const u8 {
    var len: c_int = 0;

    if (SDL_GetGamepadMappings(&len)) |arr|
        return arr[0..@intCast(len)]
    else
        return internal.emitError();
}

/// Get the gamepad mapping string for a given GUID.
///
/// The returned string must be freed with SDL_free().
///
/// \param guid a structure containing the GUID for which a mapping is desired
/// \returns a mapping string or NULL on error; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL 3.0.0.
///
/// \sa SDL_GetJoystickInstanceGUID
/// \sa SDL_GetJoystickGUID
///
pub fn getGamepadMappingForGUID(guid: GUID) Error![*:0]const u8 {
    return getGamepadMappingForGUID(guid) orelse internal.emitError();
}

extern fn SDL_GetJoysticks(count: *c_int) ?[*]JoystickID;
extern fn SDL_GetGamepads(count: *c_int) ?[*]JoystickID;
extern fn SDL_AddGamepadMapping(mapping: [*:0]const u8) c_int;
extern fn SDL_ReloadGamepadMappings() c_int;
extern fn SDL_SetJoystickEventsEnabled(enabled: Bool) void;
extern fn SDL_JoystickEventsEnabled() Bool;
extern fn SDL_UpdateJoysticks() void;
extern fn SDL_SetGamepadEventsEnabled(enabled: Bool) void;
extern fn SDL_GamepadEventsEnabled() Bool;
extern fn SDL_UpdateGamepads() void;
extern fn SDL_GetGamepadMappings(count: *c_int) ?[*][*:0]const u8;
extern fn SDL_GetGamepadMappingForGUID(guid: GUID) ?[*:0]const u8;

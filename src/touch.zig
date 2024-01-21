const internal = @import("internal.zig");
const Error = internal.Error;
const MouseID = @import("mouse.zig").MouseID;

pub const FingerID = u64;

pub const TouchDeviceType = enum(c_int) {
    invalid = -1,
    /// touch screen with window-relative coordinates */
    direct,
    /// trackpad with absolute device coordinates */
    indirect_absolute,
    /// trackpad with screen cursor-relative coordinates */
    indirect_relative,
};

pub const Finger = extern struct {
    id: FingerID,
    x: f32,
    y: f32,
    pressure: f32,
};

pub const touch_mouse_id: MouseID = .touch;
pub const mouse_touch_id: TouchID = .mouse;

pub const TouchID = enum(u64) {
    invalid = 0,
    mouse = @bitCast(@as(i64, -1)),
    _,

    /// Get the touch device name as reported from the driver.
    ///
    /// You do not own the returned string, do not modify or free it.
    ///
    /// \param touchID the touch device instance ID.
    /// \returns touch device name, or NULL on error; call SDL_GetError() for more
    ///          details.
    ///
    pub fn getName(self: TouchID) Error![*:0]const u8 {
        return SDL_GetTouchDeviceName(self) orelse internal.emitError();
    }

    /// Get the type of the given touch device.
    ///
    /// \param touchID the ID of a touch device
    /// \returns touch device type
    ///
    pub fn getType(self: TouchID) TouchDeviceType {
        return SDL_GetTouchDeviceType(self);
    }

    /// Get the number of active fingers for a given touch device.
    ///
    /// \param touchID the ID of a touch device
    /// \returns the number of active fingers for a given touch device on success
    ///          or a negative error code on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getNumFingers(self: TouchID) Error!c_int {
        const num = SDL_GetNumTouchFingers(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get the finger object for specified touch device ID and finger index.
    ///
    /// The returned resource is owned by SDL and should not be deallocated.
    ///
    /// \param touchID the ID of the requested touch device
    /// \param index the index of the requested finger
    /// \returns a pointer to the SDL_Finger object or NULL if no object at the
    ///          given ID and index could be found.
    ///
    pub fn getFinger(self: TouchID, index: c_int) ?*Finger {
        return SDL_GetTouchFinger(self, index);
    }

    extern fn SDL_GetTouchDeviceName(touch_id: TouchID) ?[*:0]const u8;
    extern fn SDL_GetTouchDeviceType(touch_id: TouchID) TouchDeviceType;
    extern fn SDL_GetNumTouchFingers(touch_id: TouchID) c_int;
    extern fn SDL_GetTouchFinger(touch_id: TouchID, index: c_int) ?*Finger;
};

/// Get a list of registered touch devices.
///
/// On some platforms SDL first sees the touch device if it was actually used.
/// Therefore the returned list might be empty, although devices are available.
/// After using all devices at least once the number will be correct.
///
/// This was fixed for Android in SDL 2.0.1.
///
/// \param count a pointer filled in with the number of devices returned, can
///              be NULL.
/// \returns a 0 terminated array of touch device IDs which should be freed
///          with SDL_free(), or NULL on error; call SDL_GetError() for more
///          details.
///
pub fn getTouchDevices() Error![:.invalid]TouchID {
    var len: c_int = 0;

    if (SDL_GetTouchDevices(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

extern fn SDL_GetTouchDevices(count: *c_int) ?[*]TouchID;

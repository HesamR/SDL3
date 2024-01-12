const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const GUID = @import("guid.zig").GUID;
const MouseID = @import("mouse.zig").MouseID;

pub const pen_mouse_id: MouseID = .mouse;

/// Pen axis indices
///
/// Below are the valid indices to the "axis" array from ::SDL_PenMotionEvent and ::SDL_PenButtonEvent.
/// The axis indices form a contiguous range of ints from 0 to ::SDL_PEN_AXIS_LAST, inclusive.
/// All "axis[]" entries are either normalised to  0..1 or report a (positive or negative)
/// angle in degrees, with 0.0 representing the centre.
/// Not all pens/backends support all axes: unsupported entries are always "0.0f".
///
/// To convert angles for tilt and rotation into vector representation, use
/// SDL_sinf on the XTILT, YTILT, or ROTATION component, e.g., "SDL_sinf(xtilt * SDL_PI_F / 180.0)".
pub const PenAxis = enum(c_uint) {
    /// Pen pressure.  Unidirectional: 0..1.0 */
    pressure = 0,
    /// Pen horizontal tilt angle.  Bidirectional: -90.0..90.0 (left-to-right). The physical max/min tilt may be smaller than -90.0 / 90.0, cf. SDL_PenCapabilityInfo */
    x_tilt,
    /// Pen vertical tilt angle.  Bidirectional: -90.0..90.0 (top-to-down). The physical max/min tilt may be smaller than -90.0 / 90.0, cf. SDL_PenCapabilityInfo */
    y_tilt,
    /// Pen distance to drawing surface.  Unidirectional: 0.0..1.0 */
    distance,
    /// Pen barrel rotation.  Bidirectional: -180..179.9 (clockwise, 0 is facing up, -180.0 is facing down). */
    rotation,
    /// Pen finger wheel or slider (e.g., Airbrush Pen).  Unidirectional: 0..1.0 */
    slider,
};

/// Pen types
///
/// Some pens identify as a particular type of drawing device (e.g., an airbrush or a pencil).
pub const PenSubtype = enum(c_uint) {
    invalid = 0,
    /// Eraser */
    eraser = 1,
    /// Generic pen; this is the default. */
    pen,
    /// Pencil */
    pencil,
    /// Brush-like device */
    brush,
    /// Airbrush device that "sprays" ink */
    airbrush,
};

pub const PenTip = enum(u8) {
    ink = 14,
    eraser = 15,
};

pub const PenCapabilityFlags = packed struct(u32) {
    __padding1: u13 = 0,

    /// Pen has a regular drawing tip (::SDL_GetPenCapabilities).  For events (::SDL_PenButtonEvent, ::SDL_PenMotionEvent, ::SDL_GetPenStatus) this flag is mutually exclusive with ::SDL_PEN_ERASER_MASK .  */
    ink: bool = false,
    /// Pen has an eraser tip (::SDL_GetPenCapabilities) or is being used as eraser (::SDL_PenButtonEvent , ::SDL_PenMotionEvent , ::SDL_GetPenStatus)  */
    eraser: bool = false,
    /// Pen provides pressure information in axis ::SDL_PEN_AXIS_PRESSURE */
    axis_pressure: bool = false,
    /// Pen provides horizontal tilt information in axis ::SDL_PEN_AXIS_XTILT */
    axis_xtilt: bool = false,
    /// Pen provides vertical tilt information in axis ::SDL_PEN_AXIS_YTILT */
    axis_ytilt: bool = false,
    /// Pen provides distance to drawing tablet in ::SDL_PEN_AXIS_DISTANCE */
    axis_distance: bool = false,
    /// Pen provides barrel rotation information in axis ::SDL_PEN_AXIS_ROTATION */
    axis_rotation: bool = false,
    /// Pen provides slider / finger wheel or similar in axis ::SDL_PEN_AXIS_SLIDER */
    axis_slider: bool = false,

    __padding2: u11 = 0,
};

pub const PenStatusFlags = packed struct(u16) {
    left: bool = false,
    middle: bool = false,
    right: bool = false,
    x1: bool = false,
    x2: bool = false,

    __padding1: u7 = 0,

    down: bool = false,
    ink: bool = false,
    eraser: bool = false,

    __padding2: u1 = 0,

    pub fn fromInt(val: u32) PenStatusFlags {
        return @bitCast(@as(u16, @intCast(val)));
    }
};

/// Pen capabilities, as reported by ::SDL_GetPenCapabilities()
pub const PenCapabilityInfo = extern struct {
    max_tilt: f32,
    wacom_id: u32,
    num_buttons: i8,
};

pub const PenID = enum(u32) {
    invalid = 0,
    _,

    /// Retrieves an ::SDL_PenID for the given ::SDL_GUID.
    ///
    /// \param guid A pen GUID.
    /// \returns A valid ::SDL_PenID, or ::SDL_PEN_INVALID if there is no matching
    ///          SDL_PenID.
    ///
    pub fn fromGUID(guid: GUID) PenID {
        return SDL_GetPenFromGUID(guid);
    }

    /// Retrieves the ::SDL_GUID for a given ::SDL_PenID.
    ///
    /// \param instance_id The pen to query.
    /// \returns The corresponding pen GUID; persistent across multiple sessions.
    ///          If "instance_id" is ::SDL_PEN_INVALID, returns an all-zeroes GUID.
    ///
    pub fn getGUID(self: PenID) GUID {
        return SDL_GetPenGUID(self);
    }

    /// Checks whether a pen is still attached.
    ///
    /// If a pen is detached, it will not show up for ::SDL_GetPens(). Other
    /// operations will still be available but may return default values.
    ///
    /// \param instance_id A pen ID.
    /// \returns SDL_TRUE if "instance_id" is valid and the corresponding pen is
    ///          attached, or SDL_FALSE otherwise.
    ///
    pub fn isConnected(self: PenID) bool {
        return SDL_PenConnected(self).toZig();
    }

    /// Retrieves a human-readable description for a ::SDL_PenID.
    ///
    /// \param instance_id The pen to query.
    /// \returns A string that contains the name of the pen, intended for human
    ///          consumption. The string might or might not be localised, depending
    ///          on platform settings. It is not guaranteed to be unique; use
    ///          ::SDL_GetPenGUID() for (best-effort) unique identifiers. The
    ///          pointer is managed by the SDL pen subsystem and must not be
    ///          deallocated. The pointer remains valid until SDL is shut down.
    ///          Returns NULL on error (cf. ::SDL_GetError())
    ///
    pub fn getName(self: PenID) Error![*:0]const u8 {
        return SDL_GetPenName(self) orelse internal.emitError();
    }

    /// Retrieves the pen's current status.
    ///
    /// If the pen is detached (cf. ::SDL_PenConnected), this operation may return
    /// default values.
    ///
    /// \param instance_id The pen to query.
    /// \param x Out-mode parameter for pen x coordinate. May be NULL.
    /// \param y Out-mode parameter for pen y coordinate. May be NULL.
    /// \param axes Out-mode parameter for axis information. May be null. The axes
    ///             are in the same order as ::SDL_PenAxis.
    /// \param num_axes Maximum number of axes to write to "axes".
    /// \returns a bit mask with the current pen button states (::SDL_BUTTON_LMASK
    ///          etc.), possibly ::SDL_PEN_DOWN_MASK, and exactly one of
    ///          ::SDL_PEN_INK_MASK or ::SDL_PEN_ERASER_MASK , or 0 on error (see
    ///          ::SDL_GetError()).
    ///
    pub fn getStatus(self: PenID, x: *f32, y: *f32, axes: []f32) Error!PenStatusFlags {
        const flags = SDL_GetPenStatus(self, x, y, axes.ptr, @intCast(axes.len));
        try internal.assertResult(flags != 0);
        return PenStatusFlags.fromInt(flags);
    }

    /// Retrieves capability flags for a given ::SDL_PenID.
    ///
    /// \param instance_id The pen to query.
    /// \param capabilities Detail information about pen capabilities, such as the
    ///                     number of buttons
    /// \returns a set of capability flags, cf. SDL_PEN_CAPABILITIES
    ///
    pub fn getCapabilities(self: PenID, capabilities: *PenCapabilityInfo) PenCapabilityFlags {
        return SDL_GetPenCapabilities(self, capabilities);
    }

    /// Retrieves the pen type for a given ::SDL_PenID.
    ///
    /// \param instance_id The pen to query.
    /// \returns The corresponding pen type (cf. ::SDL_PenSubtype) or 0 on error.
    ///          Note that the pen type does not dictate whether the pen tip is
    ///          ::SDL_PEN_TIP_INK or ::SDL_PEN_TIP_ERASER; to determine whether a
    ///          pen is being used for drawing or in eraser mode, check either the
    ///          pen tip on ::SDL_EVENT_PEN_DOWN, or the flag ::SDL_PEN_ERASER_MASK
    ///          in the pen state.
    ///
    pub fn getType(self: PenID) PenSubtype {
        return SDL_GetPenType(self);
    }

    extern fn SDL_GetPenFromGUID(guid: GUID) PenID;
    extern fn SDL_GetPenGUID(instance_id: PenID) GUID;
    extern fn SDL_PenConnected(instance_id: PenID) Bool;
    extern fn SDL_GetPenName(instance_id: PenID) ?[*:0]const u8;
    extern fn SDL_GetPenStatus(instance_id: PenID, x: *f32, y: *f32, axes: [*]f32, num_axes: usize) u32;
    extern fn SDL_GetPenCapabilities(instance_id: PenID, capabilities: *PenCapabilityInfo) PenCapabilityFlags;
    extern fn SDL_GetPenType(instance_id: PenID) PenSubtype;
};

/// Retrieves all pens that are connected to the system.
///
/// Yields an array of ::SDL_PenID values. These identify and track pens
/// throughout a session. To track pens across sessions (program restart), use
/// ::SDL_GUID .
///
/// \param count The number of pens in the array (number of array elements
///              minus 1, i.e., not counting the terminator 0).
/// \returns A 0 terminated array of ::SDL_PenID values, or NULL on error. The
///          array must be freed with ::SDL_free(). On a NULL return,
///          ::SDL_GetError() is set.
///
pub fn getPens() Error![:.invalid]PenID {
    var len: c_int = 0;

    if (SDL_GetPens(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

extern fn SDL_GetPens(count: *c_int) ?[*]PenID;

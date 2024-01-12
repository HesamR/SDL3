const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const Surface = @import("surface.zig").Surface;

const Window = opaque {};

pub const MouseID = enum(u32) {
    invalid = 0,
    touch = @bitCast(@as(i32, -1)),
    mouse = @bitCast(@as(i32, -2)),
    _,
};

pub const SystemCursor = enum(c_uint) {
    /// Arrow */
    arrow,
    /// I-beam */
    ibeam,
    /// Wait */
    wait,
    /// Crosshair */
    crosshair,
    /// Small wait cursor (or Wait if not available) */
    wait_arrow,
    /// Double arrow pointing northwest and southeast */
    size_nwse,
    /// Double arrow pointing northeast and southwest */
    size_nesw,
    /// Double arrow pointing west and east */
    size_we,
    /// Double arrow pointing north and south */
    size_ns,
    /// Four pointed arrow pointing north, south, east, and west */
    size_all,
    /// Slashed circle or crossbones */
    no,
    /// Hand */
    hand,
    /// Window resize top-left (or SIZENWSE) */
    window_topleft,
    /// Window resize top (or SIZENS) */
    window_top,
    /// Window resize top-right (or SIZENESW) */
    window_topright,
    /// Window resize right (or SIZEWE) */
    window_right,
    /// Window resize bottom-right (or SIZENWSE) */
    window_bottomright,
    /// Window resize bottom (or SIZENS) */
    window_bottom,
    /// Window resize bottom-left (or SIZENESW) */
    window_bottomleft,
    /// Window resize left (or SIZEWE) */
    window_left,
};

pub const MouseWheelDirection = enum(u32) {
    /// The scroll direction is normal */
    normal,
    /// The scroll direction is flipped / natural */
    flipped,
};

pub const MouseButton = enum(u8) {
    left = 1,
    middle = 2,
    right = 3,
    x1 = 4,
    x2 = 5,
};

pub const MouseButtonFlags = packed struct(u32) {
    left: bool = false,
    middle: bool = false,
    right: bool = false,
    x1: bool = false,
    x2: bool = false,

    __padding: u27 = 0,
};

pub const Cursor = opaque {
    /// Create a cursor using the specified bitmap data and mask (in MSB format).
    ///
    /// `mask` has to be in MSB (Most Significant Bit) format.
    ///
    /// The cursor width (`w`) must be a multiple of 8 bits.
    ///
    /// The cursor is created in black and white according to the following:
    ///
    /// - data=0, mask=1: white
    /// - data=1, mask=1: black
    /// - data=0, mask=0: transparent
    /// - data=1, mask=0: inverted color if possible, black if not.
    ///
    /// Cursors created with this function must be freed with SDL_DestroyCursor().
    ///
    /// If you want to have a color cursor, or create your cursor from an
    /// SDL_Surface, you should use SDL_CreateColorCursor(). Alternately, you can
    /// hide the cursor and draw your own as part of your game's rendering, but it
    /// will be bound to the framerate.
    ///
    /// Also, since SDL 2.0.0, SDL_CreateSystemCursor() is available, which
    /// provides twelve readily available system cursors to pick from.
    ///
    /// \param data the color value for each pixel of the cursor
    /// \param mask the mask value for each pixel of the cursor
    /// \param w the width of the cursor
    /// \param h the height of the cursor
    /// \param hot_x the X-axis location of the upper left corner of the cursor
    ///              relative to the actual mouse position
    /// \param hot_y the Y-axis location of the upper left corner of the cursor
    ///              relative to the actual mouse position
    /// \returns a new cursor with the specified parameters on success or NULL on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn create(data: [*]const u8, mask: [*]const u8, w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) Error!*Cursor {
        return SDL_CreateCursor(data, mask, w, h, hot_x, hot_y) orelse internal.emitError();
    }

    /// Create a system cursor.
    ///
    /// \param id an SDL_SystemCursor enum value
    /// \returns a cursor on success or NULL on failure; call SDL_GetError() for
    ///          more information.
    ///
    /// \since This function is available since SDL 3.0.0.
    ///
    pub fn createSystem(id: SystemCursor) Error!*Cursor {
        return SDL_CreateSystemCursor(id) orelse internal.emitError();
    }

    /// Create a color cursor.
    ///
    /// \param surface an SDL_Surface structure representing the cursor image
    /// \param hot_x the x position of the cursor hot spot
    /// \param hot_y the y position of the cursor hot spot
    /// \returns the new cursor on success or NULL on failure; call SDL_GetError()
    ///          for more information.
    ///
    pub fn createColor(surface: *Surface, hot_x: c_int, hot_y: c_int) Error!*Cursor {
        return SDL_CreateColorCursor(surface, hot_x, hot_y) orelse internal.emitError();
    }

    /// Set the active cursor.
    ///
    /// This function sets the currently active cursor to the specified one. If the
    /// cursor is currently visible, the change will be immediately represented on
    /// the display. SDL_SetCursor(NULL) can be used to force cursor redraw, if
    /// this is desired for any reason.
    ///
    /// \param cursor a cursor to make active
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn set(self: *Cursor) Error!void {
        try internal.checkResult(SDL_SetCursor(self));
    }

    /// Get the active cursor.
    ///
    /// This function returns a pointer to the current cursor which is owned by the
    /// library. It is not necessary to free the cursor with SDL_DestroyCursor().
    ///
    /// \returns the active cursor or NULL if there is no mouse.
    ///
    pub fn get() ?*Cursor {
        return SDL_GetCursor();
    }

    /// Get the default cursor.
    ///
    /// You do not have to call SDL_DestroyCursor() on the return value, but it is
    /// safe to do so.
    ///
    /// \returns the default cursor on success or NULL on failure.
    ///
    pub fn getDefault() Error!*Cursor {
        return SDL_GetDefaultCursor() orelse internal.emitError();
    }

    /// Show the cursor.
    ///
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn show() Error!void {
        try internal.checkResult(SDL_ShowCursor());
    }

    /// Hide the cursor.
    ///
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn hide() Error!void {
        try internal.checkResult(SDL_HideCursor());
    }

    /// Return whether the cursor is currently being shown.
    ///
    /// \returns `SDL_TRUE` if the cursor is being shown, or `SDL_FALSE` if the
    ///          cursor is hidden.
    ///
    pub fn isVisible() bool {
        return SDL_CursorVisible().toZig();
    }

    /// Free a previously-created cursor.
    ///
    /// Use this function to free cursor resources created with SDL_CreateCursor(),
    /// SDL_CreateColorCursor() or SDL_CreateSystemCursor().
    ///
    /// \param cursor the cursor to free
    ///
    pub fn destroy(self: *Cursor) void {
        SDL_DestroyCursor(self);
    }

    extern fn SDL_CreateCursor(data: [*]const u8, mask: [*]const u8, w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) ?*Cursor;
    extern fn SDL_CreateSystemCursor(id: SystemCursor) ?*Cursor;
    extern fn SDL_CreateColorCursor(surface: *Surface, hot_x: c_int, hot_y: c_int) ?*Cursor;
    extern fn SDL_SetCursor(cursor: *Cursor) c_int;
    extern fn SDL_GetCursor() ?*Cursor;
    extern fn SDL_GetDefaultCursor() ?*Cursor;
    extern fn SDL_ShowCursor() c_int;
    extern fn SDL_HideCursor() c_int;
    extern fn SDL_CursorVisible() Bool;
    extern fn SDL_DestroyCursor(cursor: *Cursor) void;
};

/// Get the window which currently has mouse focus.
///
/// \returns the window with mouse focus.
///
pub fn getMouseFocus() ?*Window {
    return SDL_GetMouseFocus();
}

/// Retrieve the current state of the mouse.
///
/// The current button state is returned as a button bitmask, which can be
/// tested using the `SDL_BUTTON(X)` macros (where `X` is generally 1 for the
/// left, 2 for middle, 3 for the right button), and `x` and `y` are set to the
/// mouse cursor position relative to the focus window. You can pass NULL for
/// either `x` or `y`.
///
/// \param x the x coordinate of the mouse cursor position relative to the
///          focus window
/// \param y the y coordinate of the mouse cursor position relative to the
///          focus window
/// \returns a 32-bit button bitmask of the current button state.
///
pub fn getMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return SDL_GetMouseState(x, y);
}

/// Get the current state of the mouse in relation to the desktop.
///
/// This works similarly to SDL_GetMouseState(), but the coordinates will be
/// reported relative to the top-left of the desktop. This can be useful if you
/// need to track the mouse outside of a specific window and SDL_CaptureMouse()
/// doesn't fit your needs. For example, it could be useful if you need to
/// track the mouse while dragging a window, where coordinates relative to a
/// window might not be in sync at all times.
///
/// Note: SDL_GetMouseState() returns the mouse position as SDL understands it
/// from the last pump of the event queue. This function, however, queries the
/// OS for the current mouse position, and as such, might be a slightly less
/// efficient function. Unless you know what you're doing and have a good
/// reason to use this function, you probably want SDL_GetMouseState() instead.
///
/// \param x filled in with the current X coord relative to the desktop; can be
///          NULL
/// \param y filled in with the current Y coord relative to the desktop; can be
///          NULL
/// \returns the current button state as a bitmask which can be tested using
///          the SDL_BUTTON(X) macros.
///
pub fn getGlobalMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return SDL_GetGlobalMouseState(x, y);
}

/// Retrieve the relative state of the mouse.
///
/// The current button state is returned as a button bitmask, which can be
/// tested using the `SDL_BUTTON(X)` macros (where `X` is generally 1 for the
/// left, 2 for middle, 3 for the right button), and `x` and `y` are set to the
/// mouse deltas since the last call to SDL_GetRelativeMouseState() or since
/// event initialization. You can pass NULL for either `x` or `y`.
///
/// \param x a pointer filled with the last recorded x coordinate of the mouse
/// \param y a pointer filled with the last recorded y coordinate of the mouse
/// \returns a 32-bit button bitmask of the relative button state.
///
pub fn getRelativeMouseState(x: *f32, y: *f32) MouseButtonFlags {
    return SDL_GetRelativeMouseState(x, y);
}

/// Set relative mouse mode.
///
/// While the mouse is in relative mode, the cursor is hidden, the mouse
/// position is constrained to the window, and SDL will report continuous
/// relative mouse motion even if the mouse is at the edge of the window.
///
/// This function will flush any pending mouse motion.
///
/// \param enabled SDL_TRUE to enable relative mode, SDL_FALSE to disable.
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setRelativeMouseMode(enabled: bool) Error!void {
    try internal.checkResult(SDL_SetRelativeMouseMode(Bool.fromZig(enabled)));
}

/// Query whether relative mouse mode is enabled.
///
/// \returns SDL_TRUE if relative mode is enabled or SDL_FALSE otherwise.
///
pub fn isRelativeMouseMode() bool {
    return SDL_GetRelativeMouseMode().toZig();
}

/// Move the mouse cursor to the given position within the window.
///
/// This function generates a mouse motion event if relative mode is not
/// enabled. If relative mode is enabled, you can force mouse events for the
/// warp by setting the SDL_HINT_MOUSE_RELATIVE_WARP_MOTION hint.
///
/// Note that this function will appear to succeed, but not actually move the
/// mouse when used over Microsoft Remote Desktop.
///
/// \param window the window to move the mouse into, or NULL for the current
///               mouse focus
/// \param x the x coordinate within the window
/// \param y the y coordinate within the window
///
pub fn warpMouseInWindow(window: ?*Window, x: f32, y: f32) void {
    SDL_WarpMouseInWindow(window, x, y);
}

/// Move the mouse to the given position in global screen space.
///
/// This function generates a mouse motion event.
///
/// A failure of this function usually means that it is unsupported by a
/// platform.
///
/// Note that this function will appear to succeed, but not actually move the
/// mouse when used over Microsoft Remote Desktop.
///
/// \param x the x coordinate
/// \param y the y coordinate
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn warpMouseGlobal(x: f32, y: f32) Error!void {
    try internal.checkResult(warpMouseGlobal(x, y));
}

/// Capture the mouse and to track input outside an SDL window.
///
/// Capturing enables your app to obtain mouse events globally, instead of just
/// within your window. Not all video targets support this function. When
/// capturing is enabled, the current window will get all mouse events, but
/// unlike relative mode, no change is made to the cursor and it is not
/// restrained to your window.
///
/// This function may also deny mouse input to other windows--both those in
/// your application and others on the system--so you should use this function
/// sparingly, and in small bursts. For example, you might want to track the
/// mouse while the user is dragging something, until the user releases a mouse
/// button. It is not recommended that you capture the mouse for long periods
/// of time, such as the entire time your app is running. For that, you should
/// probably use SDL_SetRelativeMouseMode() or SDL_SetWindowGrab(), depending
/// on your goals.
///
/// While captured, mouse events still report coordinates relative to the
/// current (foreground) window, but those coordinates may be outside the
/// bounds of the window (including negative values). Capturing is only allowed
/// for the foreground window. If the window loses focus while capturing, the
/// capture will be disabled automatically.
///
/// While capturing is enabled, the current window will have the
/// `SDL_WINDOW_MOUSE_CAPTURE` flag set.
///
/// Please note that as of SDL 2.0.22, SDL will attempt to "auto capture" the
/// mouse while the user is pressing a button; this is to try and make mouse
/// behavior more consistent between platforms, and deal with the common case
/// of a user dragging the mouse outside of the window. This means that if you
/// are calling SDL_CaptureMouse() only to deal with this situation, you no
/// longer have to (although it is safe to do so). If this causes problems for
/// your app, you can disable auto capture by setting the
/// `SDL_HINT_MOUSE_AUTO_CAPTURE` hint to zero.
///
/// \param enabled SDL_TRUE to enable capturing, SDL_FALSE to disable.
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn captureMouse(enabled: bool) Error!void {
    try internal.checkResult(SDL_CaptureMouse(Bool.fromZig(enabled)));
}

extern fn SDL_GetMouseFocus() ?*Window;
extern fn SDL_GetMouseState(x: *f32, y: *f32) MouseButtonFlags;
extern fn SDL_GetGlobalMouseState(x: *f32, y: *f32) MouseButtonFlags;
extern fn SDL_GetRelativeMouseState(x: *f32, y: *f32) MouseButtonFlags;
extern fn SDL_SetRelativeMouseMode(enabled: Bool) c_int;
extern fn SDL_GetRelativeMouseMode() Bool;
extern fn SDL_WarpMouseInWindow(window: ?*Window, x: f32, y: f32) void;
extern fn SDL_WarpMouseGlobal(x: f32, y: f32) c_int;
extern fn SDL_CaptureMouse(enabled: Bool) c_int;

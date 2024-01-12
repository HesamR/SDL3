const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const Window = @import("video.zig").Window;

pub const MessageBoxFlags = packed struct(u32) {
    __padding1: u4 = 0,

    err: bool = false,
    warning: bool = false,
    info: bool = false,
    buttons_left_to_right: bool = false,
    button_right_to_left: bool = false,

    __padding2: u19 = 0,
};

pub const MessageBoxButtonFlags = packed struct(u32) {
    return_default: bool = false,
    escape_default: bool = false,

    __padding: u30 = 0,
};

pub const MessageBoxButtonData = extern struct {
    flags: MessageBoxButtonFlags,
    button_id: c_int,
    text: [*:0]const u8,
};

pub const MessageBoxColor = extern struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const MessageBoxColorType = enum(usize) {
    background,
    text,
    button_border,
    button_background,
    button_selected,
};

pub const MessageBoxColorScheme = extern struct {
    colors: [5]MessageBoxColor = undefined,

    pub fn setColor(self: *MessageBoxColorScheme, typ: MessageBoxColorType, color: MessageBoxColor) void {
        self.colors[@intFromEnum(typ)] = color;
    }
};

pub const MessageBoxData = extern struct {
    flags: MessageBoxFlags,
    parent_window: ?*Window,
    title: [*:0]const u8,
    message: [*:0]const u8,

    num_button: c_int,
    buttons: [*]const MessageBoxButtonData,
    color_scheme: ?*MessageBoxColorScheme,
};

/// Create a modal message box.
///
/// If your needs aren't complex, it might be easier to use
/// SDL_ShowSimpleMessageBox.
///
/// This function should be called on the thread that created the parent
/// window, or on the main thread if the messagebox has no parent. It will
/// block execution of that thread until the user clicks a button or closes the
/// messagebox.
///
/// This function may be called at any time, even before SDL_Init(). This makes
/// it useful for reporting errors like a failure to create a renderer or
/// OpenGL context.
///
/// On X11, SDL rolls its own dialog box with X11 primitives instead of a
/// formal toolkit like GTK+ or Qt.
///
/// Note that if SDL_Init() would fail because there isn't any available video
/// target, this function is likely to fail for the same reasons. If this is a
/// concern, check the return value from this function and fall back to writing
/// to stderr if you can.
///
/// \param messageboxdata the SDL_MessageBoxData structure with title, text and
///                       other options
/// \param buttonid the pointer to which user id of hit button should be copied
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn showMessageBox(message_box_data: *const MessageBoxData, button_id: *c_int) Error!void {
    try internal.checkResult(SDL_ShowMessageBox(message_box_data, button_id));
}

/// Display a simple modal message box.
///
/// If your needs aren't complex, this function is preferred over
/// SDL_ShowMessageBox.
///
/// `flags` may be any of the following:
///
/// - `SDL_MESSAGEBOX_ERROR`: error dialog
/// - `SDL_MESSAGEBOX_WARNING`: warning dialog
/// - `SDL_MESSAGEBOX_INFORMATION`: informational dialog
///
/// This function should be called on the thread that created the parent
/// window, or on the main thread if the messagebox has no parent. It will
/// block execution of that thread until the user clicks a button or closes the
/// messagebox.
///
/// This function may be called at any time, even before SDL_Init(). This makes
/// it useful for reporting errors like a failure to create a renderer or
/// OpenGL context.
///
/// On X11, SDL rolls its own dialog box with X11 primitives instead of a
/// formal toolkit like GTK+ or Qt.
///
/// Note that if SDL_Init() would fail because there isn't any available video
/// target, this function is likely to fail for the same reasons. If this is a
/// concern, check the return value from this function and fall back to writing
/// to stderr if you can.
///
/// \param flags an SDL_MessageBoxFlags value
/// \param title UTF-8 title text
/// \param message UTF-8 message text
/// \param window the parent window, or NULL for no parent
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn showSimpleMessageBox(flags: MessageBoxFlags, title: [*:0]const u8, message: [*:0]const u8, parent_window: ?*Window) Error!void {
    try internal.checkResult(SDL_ShowSimpleMessageBox(flags, title, message, parent_window));
}

extern fn SDL_ShowMessageBox(message_box_data: *const MessageBoxData, button_id: *c_int) c_int;
extern fn SDL_ShowSimpleMessageBox(flags: MessageBoxFlags, title: [*:0]const u8, message: [*:0]const u8, parent_window: ?*Window) c_int;

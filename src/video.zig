const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const rect = @import("rect.zig");
const Rect = rect.Rect;
const Point = rect.Point;

const FunctionPointer = @import("stdinc.zig").FunctionPointer;
const PropertiesID = @import("properties.zig").PropertiesID;
const Surface = @import("surface.zig").Surface;
const PixelFormat = @import("pixels.zig").PixelFormat;

pub const gl = @import("opengl.zig");
pub const egl = @import("opengles.zig");

pub const SystemTheme = enum(c_uint) {
    /// Unknown system theme */
    unknown,
    /// Light colored system theme */
    light,
    /// Dark colored system theme */
    dark,
};

pub const DisplayMode = extern struct {
    display_id: DisplayID,
    format: PixelFormat,
    w: c_int,
    h: c_int,
    pixel_density: f32,
    refresh_rate: f32,
    driver_data: ?*anyopaque,
};

pub const DisplayOrientation = enum(c_uint) {
    /// The display orientation can't be determined */
    unknown,
    /// The display is in landscape mode, with the right side up, relative to portrait mode */
    landscape,
    /// The display is in landscape mode, with the left side up, relative to portrait mode */
    landscape_flipped,
    /// The display is in portrait mode */
    portrait,
    /// The display is in portrait mode, upside down */
    portrait_flipped,
};

pub const WindowFlags = packed struct(u32) {
    /// window is in fullscreen mode */
    fullscreen: bool = false,
    /// window usable with OpenGL context */
    opengl: bool = false,
    /// window is occluded */
    occluded: bool = false,
    /// window is neither mapped onto the desktop nor shown in the taskbar/dock/window list; SDL_ShowWindow() is required for it to become visible */
    hidden: bool = false,
    /// no window decoration */
    borderless: bool = false,
    /// window can be resized */
    resizable: bool = false,
    /// window is minimized */
    minimized: bool = false,
    /// window is maximized */
    maximized: bool = false,
    /// window has grabbed mouse input */
    mouse_grabbed: bool = false,
    /// window has input focus */
    input_focus: bool = false,
    /// window has mouse focus */
    mouse_focus: bool = false,
    /// window not created by SDL */
    external: bool = false,

    __padding1: u1 = 0,

    /// window uses high pixel density back buffer if possible */
    high_pixel_density: bool = false,
    /// window has mouse captured (unrelated to MOUSE_GRABBED) */
    mouse_capture: bool = false,
    /// window should always be above others */
    always_on_top: bool = false,

    __padding2: u1 = 0,

    /// window should be treated as a utility window, not showing in the task bar and window list */
    utility: bool = false,
    /// window should be treated as a tooltip */
    tooltip: bool = false,
    /// window should be treated as a popup menu */
    popup_menu: bool = false,
    /// window has grabbed keyboard input */
    keyboard_grabbed: bool = false,

    __padding3: u7 = 0,

    /// window usable for Vulkan surface */
    vulkan: bool = false,
    /// window usable for Metal view */
    metal: bool = false,
    /// window with transparent buffer */
    transparent: bool = false,
    /// window should not be focusable */
    not_focusable: bool = false,
};

pub const windowpos_undefined_mask = 0x1fff0000;
pub const windowpos_centered_mask = 0x2fff0000;

pub const FlashOperation = enum(c_uint) {
    /// Cancel any window flash state */
    cancel,
    /// Flash the window briefly to get attention */
    briefly,
    /// Flash the window until it gets focus */
    until_focused,
};

pub const HitTestResult = enum(c_uint) {
    normal,
    draggable,
    resize_topleft,
    resize_top,
    resize_topright,
    resize_right,
    resize_bottomright,
    resize_bottom,
    resize_bottomleft,
    resize_left,
};

pub const HitTest = *const fn (*Window, *const Point, ?*anyopaque) callconv(.C) HitTestResult;

pub const DisplayID = enum(u32) {
    invalid = 0,
    _,

    /// Get the display containing a point.
    ///
    /// \param point the point to query
    /// \returns the instance ID of the display containing the point or 0 on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn fromPoint(point: *const Point) Error!DisplayID {
        const id = SDL_GetDisplayForPoint(point);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the display primarily containing a rect.
    ///
    /// \param rect the rect to query
    /// \returns the instance ID of the display entirely containing the rect or
    ///          closest to the center of the rect on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn fromRect(r: *const Rect) Error!DisplayID {
        const id = SDL_GetDisplayForRect(r);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the properties associated with a display.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: DisplayID) Error!PropertiesID {
        const props = SDL_GetDisplayProperties(self);
        try internal.assertResult(props != .invalid);
        return props;
    }

    /// Get the name of a display in UTF-8 encoding.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns the name of a display or NULL on failure; call SDL_GetError() for
    ///          more information.
    ///
    pub fn getName(self: DisplayID) Error![*:0]const u8 {
        return SDL_GetDisplayName(self) orelse internal.emitError();
    }

    /// Get the desktop area represented by a display.
    ///
    /// The primary display is always located at (0,0).
    ///
    /// \param displayID the instance ID of the display to query
    /// \param rect the SDL_Rect structure filled in with the display bounds
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getBounds(self: DisplayID, r: *Rect) Error!void {
        try internal.checkResult(SDL_GetDisplayBounds(self, r));
    }

    /// Get the usable desktop area represented by a display, in screen
    /// coordinates.
    ///
    /// This is the same area as SDL_GetDisplayBounds() reports, but with portions
    /// reserved by the system removed. For example, on Apple's macOS, this
    /// subtracts the area occupied by the menu bar and dock.
    ///
    /// Setting a window to be fullscreen generally bypasses these unusable areas,
    /// so these are good guidelines for the maximum space available to a
    /// non-fullscreen window.
    ///
    /// \param displayID the instance ID of the display to query
    /// \param rect the SDL_Rect structure filled in with the display bounds
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getUsableBounds(self: DisplayID, r: *Rect) Error!void {
        try internal.checkResult(SDL_GetDisplayUsableBounds(self, r));
    }

    /// Get the orientation of a display when it is unrotated.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns The SDL_DisplayOrientation enum value of the display, or
    ///          `SDL_ORIENTATION_UNKNOWN` if it isn't available.
    ///
    pub fn getNaturalOrientation(self: DisplayID) DisplayOrientation {
        return SDL_GetNaturalDisplayOrientation(self);
    }

    /// Get the orientation of a display.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns The SDL_DisplayOrientation enum value of the display, or
    ///          `SDL_ORIENTATION_UNKNOWN` if it isn't available.
    ///
    pub fn getCurrentOrientation(self: DisplayID) DisplayOrientation {
        return SDL_GetCurrentDisplayOrientation(self);
    }

    /// Get the closest match to the requested display mode.
    ///
    /// The available display modes are scanned and `closest` is filled in with the
    /// closest mode matching the requested mode and returned. The mode format and
    /// refresh rate default to the desktop mode if they are set to 0. The modes
    /// are scanned with size being first priority, format being second priority,
    /// and finally checking the refresh rate. If all the available modes are too
    /// small, then NULL is returned.
    ///
    /// \param displayID the instance ID of the display to query
    /// \param w the width in pixels of the desired display mode
    /// \param h the height in pixels of the desired display mode
    /// \param refresh_rate the refresh rate of the desired display mode, or 0.0f
    ///                     for the desktop refresh rate
    /// \param include_high_density_modes Boolean to include high density modes in
    ///                                   the search
    /// \returns a pointer to the closest display mode equal to or larger than the
    ///          desired mode, or NULL on error; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getContentScale(self: DisplayID) Error!f32 {
        const scale = SDL_GetDisplayContentScale(self);
        try internal.assertResult(scale != 0);
        return scale;
    }

    /// Get information about the desktop's display mode.
    ///
    /// There's a difference between this function and SDL_GetCurrentDisplayMode()
    /// when SDL runs fullscreen and has changed the resolution. In that case this
    /// function will return the previous native display mode, and not the current
    /// display mode.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns a pointer to the desktop display mode or NULL on error; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getFullscreenDisplayModes(self: DisplayID) Error![]*const DisplayMode {
        var len: c_int = 0;

        if (SDL_GetFullscreenDisplayModes(self, &len)) |arr|
            return arr[0..@intCast(len)]
        else
            return internal.emitError();
    }

    /// Get the closest match to the requested display mode.
    ///
    /// The available display modes are scanned and `closest` is filled in with the
    /// closest mode matching the requested mode and returned. The mode format and
    /// refresh rate default to the desktop mode if they are set to 0. The modes
    /// are scanned with size being first priority, format being second priority,
    /// and finally checking the refresh rate. If all the available modes are too
    /// small, then NULL is returned.
    ///
    /// \param displayID the instance ID of the display to query
    /// \param w the width in pixels of the desired display mode
    /// \param h the height in pixels of the desired display mode
    /// \param refresh_rate the refresh rate of the desired display mode, or 0.0f
    ///                     for the desktop refresh rate
    /// \param include_high_density_modes Boolean to include high density modes in
    ///                                   the search
    /// \returns a pointer to the closest display mode equal to or larger than the
    ///          desired mode, or NULL on error; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getClosestFullscreenDisplayMode(self: DisplayID, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: bool) Error!*const DisplayMode {
        return SDL_GetClosestFullscreenDisplayMode(self, w, h, refresh_rate, Bool.fromZig(include_high_density_modes)) orelse internal.emitError();
    }

    /// Get information about the desktop's display mode.
    ///
    /// There's a difference between this function and SDL_GetCurrentDisplayMode()
    /// when SDL runs fullscreen and has changed the resolution. In that case this
    /// function will return the previous native display mode, and not the current
    /// display mode.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns a pointer to the desktop display mode or NULL on error; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getDesktopDisplayMode(self: DisplayID) Error!*const DisplayMode {
        return SDL_GetDesktopDisplayMode(self) orelse internal.emitError();
    }

    /// Get information about the current display mode.
    ///
    /// There's a difference between this function and SDL_GetDesktopDisplayMode()
    /// when SDL runs fullscreen and has changed the resolution. In that case this
    /// function will return the current display mode, and not the previous native
    /// display mode.
    ///
    /// \param displayID the instance ID of the display to query
    /// \returns a pointer to the desktop display mode or NULL on error; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getCurrentDisplayMode(self: DisplayID) Error!*const DisplayMode {
        return SDL_GetCurrentDisplayMode(self) orelse internal.emitError();
    }

    extern fn SDL_GetDisplayForPoint(point: *const Point) DisplayID;
    extern fn SDL_GetDisplayForRect(rect: *const Rect) DisplayID;
    extern fn SDL_GetDisplayProperties(displayID: DisplayID) PropertiesID;
    extern fn SDL_GetDisplayName(displayID: DisplayID) ?[*:0]const u8;
    extern fn SDL_GetDisplayBounds(displayID: DisplayID, rect: *Rect) c_int;
    extern fn SDL_GetDisplayUsableBounds(displayID: DisplayID, rect: *Rect) c_int;
    extern fn SDL_GetNaturalDisplayOrientation(displayID: DisplayID) DisplayOrientation;
    extern fn SDL_GetCurrentDisplayOrientation(displayID: DisplayID) DisplayOrientation;
    extern fn SDL_GetDisplayContentScale(displayID: DisplayID) f32;
    extern fn SDL_GetFullscreenDisplayModes(displayID: DisplayID, count: *c_int) ?[*]*const DisplayMode;
    extern fn SDL_GetClosestFullscreenDisplayMode(displayID: DisplayID, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: Bool) ?*const DisplayMode;
    extern fn SDL_GetDesktopDisplayMode(displayID: DisplayID) ?*const DisplayMode;
    extern fn SDL_GetCurrentDisplayMode(displayID: DisplayID) ?*const DisplayMode;
};

pub const Window = opaque {
    /// Create a window with the specified dimensions and flags.
    ///
    /// `flags` may be any of the following OR'd together:
    ///
    /// - `SDL_WINDOW_FULLSCREEN`: fullscreen window at desktop resolution
    /// - `SDL_WINDOW_OPENGL`: window usable with an OpenGL context
    /// - `SDL_WINDOW_VULKAN`: window usable with a Vulkan instance
    /// - `SDL_WINDOW_METAL`: window usable with a Metal instance
    /// - `SDL_WINDOW_HIDDEN`: window is not visible
    /// - `SDL_WINDOW_BORDERLESS`: no window decoration
    /// - `SDL_WINDOW_RESIZABLE`: window can be resized
    /// - `SDL_WINDOW_MINIMIZED`: window is minimized
    /// - `SDL_WINDOW_MAXIMIZED`: window is maximized
    /// - `SDL_WINDOW_MOUSE_GRABBED`: window has grabbed mouse focus
    ///
    /// The SDL_Window is implicitly shown if SDL_WINDOW_HIDDEN is not set.
    ///
    /// On Apple's macOS, you **must** set the NSHighResolutionCapable Info.plist
    /// property to YES, otherwise you will not receive a High-DPI OpenGL canvas.
    ///
    /// The window pixel size may differ from its window coordinate size if the
    /// window is on a high pixel density display. Use SDL_GetWindowSize() to query
    /// the client area's size in window coordinates, and
    /// SDL_GetWindowSizeInPixels() or SDL_GetRenderOutputSize() to query the
    /// drawable size in pixels. Note that the drawable size can vary after the
    /// window is created and should be queried again if you get an
    /// SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED event.
    ///
    /// If the window is created with any of the SDL_WINDOW_OPENGL or
    /// SDL_WINDOW_VULKAN flags, then the corresponding LoadLibrary function
    /// (SDL_GL_LoadLibrary or SDL_Vulkan_LoadLibrary) is called and the
    /// corresponding UnloadLibrary function is called by SDL_DestroyWindow().
    ///
    /// If SDL_WINDOW_VULKAN is specified and there isn't a working Vulkan driver,
    /// SDL_CreateWindow() will fail because SDL_Vulkan_LoadLibrary() will fail.
    ///
    /// If SDL_WINDOW_METAL is specified on an OS that does not support Metal,
    /// SDL_CreateWindow() will fail.
    ///
    /// On non-Apple devices, SDL requires you to either not link to the Vulkan
    /// loader or link to a dynamic library version. This limitation may be removed
    /// in a future version of SDL.
    ///
    /// \param title the title of the window, in UTF-8 encoding
    /// \param w the width of the window
    /// \param h the height of the window
    /// \param flags 0, or one or more SDL_WindowFlags OR'd together
    /// \returns the window that was created or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn create(title: [*:0]const u8, w: c_int, h: c_int, flags: WindowFlags) Error!*Window {
        return SDL_CreateWindow(title, w, h, flags) orelse internal.emitError();
    }

    /// Create a child popup window of the specified parent window.
    ///
    /// 'flags' **must** contain exactly one of the following: -
    /// 'SDL_WINDOW_TOOLTIP': The popup window is a tooltip and will not pass any
    /// input events. - 'SDL_WINDOW_POPUP_MENU': The popup window is a popup menu.
    /// The topmost popup menu will implicitly gain the keyboard focus.
    ///
    /// The following flags are not relevant to popup window creation and will be
    /// ignored:
    ///
    /// - 'SDL_WINDOW_MINIMIZED'
    /// - 'SDL_WINDOW_MAXIMIZED'
    /// - 'SDL_WINDOW_FULLSCREEN'
    /// - 'SDL_WINDOW_BORDERLESS'
    ///
    /// The parent parameter **must** be non-null and a valid window. The parent of
    /// a popup window can be either a regular, toplevel window, or another popup
    /// window.
    ///
    /// Popup windows cannot be minimized, maximized, made fullscreen, raised,
    /// flash, be made a modal window, be the parent of a modal window, or grab the
    /// mouse and/or keyboard. Attempts to do so will fail.
    ///
    /// Popup windows implicitly do not have a border/decorations and do not appear
    /// on the taskbar/dock or in lists of windows such as alt-tab menus.
    ///
    /// If a parent window is hidden, any child popup windows will be recursively
    /// hidden as well. Child popup windows not explicitly hidden will be restored
    /// when the parent is shown.
    ///
    /// If the parent window is destroyed, any child popup windows will be
    /// recursively destroyed as well.
    ///
    /// \param parent the parent of the window, must not be NULL
    /// \param offset_x the x position of the popup window relative to the origin
    ///                 of the parent
    /// \param offset_y the y position of the popup window relative to the origin
    ///                 of the parent window
    /// \param w the width of the window
    /// \param h the height of the window
    /// \param flags SDL_WINDOW_TOOLTIP or SDL_WINDOW_POPUP MENU, and zero or more
    ///              additional SDL_WindowFlags OR'd together.
    /// \returns the window that was created or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn createPopup(parent: *Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) Error!*Window {
        return SDL_CreatePopupWindow(parent, offset_x, offset_y, w, h, flags) orelse internal.emitError();
    }

    /// Create a window with the specified properties.
    ///
    /// These are the supported properties:
    ///
    /// - "always-on-top" (boolean) - true if the window should be always on top
    /// - "borderless" (boolean) - true if the window has no window decoration
    /// - "focusable" (boolean) - true if the window should accept keyboard input
    ///   (defaults true)
    /// - "fullscreen" (boolean) - true if the window should start in fullscreen
    ///   mode at desktop resolution
    /// - "height" (number) - the height of the window
    /// - "hidden" (boolean) - true if the window should start hidden
    /// - "high-pixel-density" (boolean) - true if the window uses a high pixel
    ///   density buffer if possible
    /// - "maximized" (boolean) - true if the window should start maximized
    /// - "menu" (boolean) - true if the window is a popup menu
    /// - "metal" (string) - true if the window will be used with Metal rendering
    /// - "minimized" (boolean) - true if the window should start minimized
    /// - "mouse-grabbed" (boolean) - true if the window starts with grabbed mouse
    ///   focus
    /// - "opengl" (boolean) - true if the window will be used with OpenGL
    ///   rendering
    /// - "parent" (pointer) - an SDL_Window that will be the parent of this
    ///   window, required for windows with the "toolip" and "menu" properties
    /// - "resizable" (boolean) - true if the window should be resizable
    /// - "title" (string) - the title of the window, in UTF-8 encoding
    /// - "transparent" (string) - true if the window show transparent in the areas
    ///   with alpha of 0
    /// - "tooltip" (boolean) - true if the window is a tooltip
    /// - "utility" (boolean) - true if the window is a utility window, not showing
    ///   in the task bar and window list
    /// - "vulkan" (string) - true if the window will be used with Vulkan rendering
    /// - "width" (number) - the width of the window
    /// - "x" (number) - the x position of the window, or `SDL_WINDOWPOS_CENTERED`,
    ///   defaults to `SDL_WINDOWPOS_UNDEFINED`. This is relative to the parent for
    ///   windows with the "parent" property set.
    /// - "y" (number) - the y position of the window, or `SDL_WINDOWPOS_CENTERED`,
    ///   defaults to `SDL_WINDOWPOS_UNDEFINED`. This is relative to the parent for
    ///   windows with the "parent" property set.
    ///
    /// On macOS:
    ///
    /// - "cocoa.window" (pointer) - the (__unsafe_unretained) NSWindow associated
    ///   with the window, if you want to wrap an existing window.
    /// - "cocoa.view" (pointer) - the (__unsafe_unretained) NSView associated with
    ///   the window, defaults to [window contentView]
    ///
    /// On Windows:
    ///
    /// - "win32.hwnd" (pointer) - the HWND associated with the window, if you want
    ///   to wrap an existing window.
    /// - "win32.pixel_format_hwnd" (pointer) - optional, another window to share
    ///   pixel format with, useful for OpenGL windows
    ///
    /// On X11:
    ///
    /// - "x11.window" (number) - the X11 Window associated with the window, if you
    ///   want to wrap an existing window.
    ///
    /// The SDL_Window is implicitly shown if the "hidden" property is not set.
    ///
    /// Windows with the "tooltip" and "menu" properties are popup windows and have
    /// the behaviors and guidelines outlined in `SDL_CreatePopupWindow()`.
    ///
    /// \param props the properties to use
    /// \returns the window that was created or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn createWithProperties(props: PropertiesID) Error!*Window {
        return SDL_CreateWindowWithProperties(props) orelse internal.emitError();
    }

    /// Get the display associated with a window.
    ///
    /// \param window the window to query
    /// \returns the instance ID of the display containing the center of the window
    ///          on success or 0 on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getDisplay(self: *Window) Error!DisplayID {
        const id = SDL_GetDisplayForWindow(self);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get the pixel density of a window.
    ///
    /// This is a ratio of pixel size to window size. For example, if the window is
    /// 1920x1080 and it has a high density back buffer of 3840x2160 pixels, it
    /// would have a pixel density of 2.0.
    ///
    /// \param window the window to query
    /// \returns the pixel density or 0.0f on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getPixelDensity(self: *Window) Error!f32 {
        const res = SDL_GetWindowPixelDensity(self);
        try internal.assertResult(res != 0);
        return res;
    }

    /// Get the content display scale relative to a window's pixel size.
    ///
    /// This is a combination of the window pixel density and the display content
    /// scale, and is the expected scale for displaying content in this window. For
    /// example, if a 3840x2160 window had a display scale of 2.0, the user expects
    /// the content to take twice as many pixels and be the same physical size as
    /// if it were being displayed in a 1920x1080 window with a display scale of
    /// 1.0.
    ///
    /// Conceptually this value corresponds to the scale display setting, and is
    /// updated when that setting is changed, or the window moves to a display with
    /// a different scale setting.
    ///
    /// \param window the window to query
    /// \returns the display scale, or 0.0f on failure; call SDL_GetError() for
    ///          more information.
    ///
    pub fn getDisplayScale(self: *Window) Error!f32 {
        const res = SDL_GetWindowDisplayScale(self);
        try internal.assertResult(res != 0);
        return res;
    }

    /// Set the display mode to use when a window is visible and fullscreen.
    ///
    /// This only affects the display mode used when the window is fullscreen. To
    /// change the window size when the window is not fullscreen, use
    /// SDL_SetWindowSize().
    ///
    /// If the window is currently in the fullscreen state, this request is
    /// asynchronous on some windowing systems and the new mode dimensions may not
    /// be applied immediately upon the return of this function. If an immediate
    /// change is required, call SDL_SyncWindow() to block until the changes have
    /// taken effect.
    ///
    /// When the new mode takes effect, an SDL_EVENT_WINDOW_RESIZED and/or an
    /// SDL_EVENT_WINDOOW_PIXEL_SIZE_CHANGED event will be emitted with the new
    /// mode dimensions.
    ///
    /// \param window the window to affect
    /// \param mode a pointer to the display mode to use, which can be NULL for
    ///             desktop mode, or one of the fullscreen modes returned by
    ///             SDL_GetFullscreenDisplayModes().
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setFullscreenMode(self: *Window, mode: *const DisplayMode) Error!void {
        try internal.checkResult(SDL_SetWindowFullscreenMode(self, mode));
    }

    /// Query the display mode to use when a window is visible at fullscreen.
    ///
    /// \param window the window to query
    /// \returns a pointer to the fullscreen mode to use or NULL for desktop mode
    ///
    pub fn getFullscreenMode(self: *Window) ?*const DisplayMode {
        return SDL_GetWindowFullscreenMode(self);
    }

    /// Get the raw ICC profile data for the screen the window is currently on.
    ///
    /// Data returned should be freed with SDL_free.
    ///
    /// \param window the window to query
    /// \param size the size of the ICC profile
    /// \returns the raw ICC profile data on success or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getICCProfile(self: *Window) Error![]u8 {
        var len: usize = 0;

        if (SDL_GetWindowICCProfile(self, &len)) |ptr|
            return @as([*]u8, @ptrCast(@alignCast(ptr)))[0..len]
        else
            return internal.emitError();
    }

    /// Get the pixel format associated with the window.
    ///
    /// \param window the window to query
    /// \returns the pixel format of the window on success or
    ///          SDL_PIXELFORMAT_UNKNOWN on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn getPixelFormat(self: *Window) Error!PixelFormat {
        const format = SDL_GetWindowPixelFormat(self);
        try internal.assertResult(format != .unknown);
        return format;
    }

    /// Get the numeric ID of a window.
    ///
    /// The numeric ID is what SDL_WindowEvent references, and is necessary to map
    /// these events to specific SDL_Window objects.
    ///
    /// \param window the window to query
    /// \returns the ID of the window on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getID(self: *Window) Error!WindowID {
        const id = SDL_GetDisplayForWindow(self);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Get parent of a window.
    ///
    /// \param window the window to query
    /// \returns the parent of the window on success or NULL if the window has no
    ///          parent.
    ///
    pub fn getParent(self: *Window) ?*Window {
        return SDL_GetWindowParent(self);
    }

    /// Get the properties associated with a window.
    ///
    /// The following read-only properties are provided by SDL:
    ///
    /// On Android:
    ///
    /// ```
    /// "SDL.window.android.window" (pointer) - the ANativeWindow associated with the window
    /// "SDL.window.android.surface" (pointer) - the EGLSurface associated with the window
    /// ```
    ///
    /// On iOS:
    ///
    /// ```
    /// "SDL.window.uikit.window" (pointer) - the (__unsafe_unretained) UIWindow associated with the window
    /// "SDL.window.uikit.metal_view_tag" (number) - the NSInteger tag assocated with metal views on the window
    /// ```
    ///
    /// On KMS/DRM:
    ///
    /// ```
    /// "SDL.window.kmsdrm.dev_index" (number) - the device index associated with the window (e.g. the X in /dev/dri/cardX)
    /// "SDL.window.kmsdrm.drm_fd" (number) - the DRM FD associated with the window
    /// "SDL.window.kmsdrm.gbm_dev" (pointer) - the GBM device associated with the window
    /// ```
    ///
    /// On macOS:
    ///
    /// ```
    /// "SDL.window.cocoa.window" (pointer) - the (__unsafe_unretained) NSWindow associated with the window
    /// "SDL.window.cocoa.metal_view_tag" (number) - the NSInteger tag assocated with metal views on the window
    /// ```
    ///
    /// On Vivante:
    ///
    /// ```
    /// "SDL.window.vivante.display" (pointer) - the EGLNativeDisplayType associated with the window
    /// "SDL.window.vivante.window" (pointer) - the EGLNativeWindowType associated with the window
    /// "SDL.window.vivante.surface" (pointer) - the EGLSurface associated with the window
    /// ```
    ///
    /// On UWP:
    ///
    /// ```
    /// "SDL.window.winrt.window" (pointer) - the IInspectable CoreWindow associated with the window
    /// ```
    ///
    /// On Windows:
    ///
    /// ```
    /// "SDL.window.win32.hwnd" (pointer) - the HWND associated with the window
    /// "SDL.window.win32.hdc" (pointer) - the HDC associated with the window
    /// "SDL.window.win32.instance" (pointer) - the HINSTANCE associated with the window
    /// ```
    ///
    /// On Wayland:
    ///
    /// ```
    /// "SDL.window.wayland.registry" (pointer) - the wl_registry associated with the window
    /// "SDL.window.wayland.display" (pointer) - the wl_display associated with the window
    /// "SDL.window.wayland.surface" (pointer) - the wl_surface associated with the window
    /// "SDL.window.wayland.egl_window" (pointer) - the wl_egl_window associated with the window
    /// "SDL.window.wayland.xdg_surface" (pointer) - the xdg_surface associated with the window
    /// "SDL.window.wayland.xdg_toplevel" (pointer) - the xdg_toplevel role associated with the window
    /// "SDL.window.wayland.xdg_popup" (pointer) - the xdg_popup role associated with the window
    /// "SDL.window.wayland.xdg_positioner" (pointer) - the xdg_positioner associated with the window, in popup mode
    /// ```
    ///
    /// Note: The xdg_* window objects do not internally persist across window
    /// show/hide calls. They will be null if the window is hidden and must be
    /// queried each time it is shown.
    ///
    /// On X11:
    ///
    /// ```
    /// "SDL.window.x11.display" (pointer) - the X11 Display associated with the window
    /// "SDL.window.x11.screen" (number) - the screen number associated with the window
    /// "SDL.window.x11.window" (number) - the X11 Window associated with the window
    /// ```
    ///
    /// \param window the window to query
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *Window) Error!PropertiesID {
        const props = SDL_GetWindowProperties(self);
        try internal.assertResult(props != .invalid);
        return SDL_GetWindowProperties(self);
    }

    /// Get the window flags.
    ///
    /// \param window the window to query
    /// \returns a mask of the SDL_WindowFlags associated with `window`
    ///
    pub fn getFlags(self: *Window) WindowFlags {
        return SDL_GetWindowFlags(self);
    }

    /// Set the title of a window.
    ///
    /// This string is expected to be in UTF-8 encoding.
    ///
    /// \param window the window to change
    /// \param title the desired window title in UTF-8 format
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setTitle(self: *Window, title: [*:0]const u8) Error!void {
        try internal.checkResult(SDL_SetWindowTitle(self, title));
    }

    /// Get the title of a window.
    ///
    /// \param window the window to query
    /// \returns the title of the window in UTF-8 format or "" if there is no
    ///          title.
    ///
    pub fn getTitle(self: *Window) ?[*:0]const u8 {
        return SDL_GetWindowTitle(self);
    }

    /// Set the icon for a window.
    ///
    /// \param window the window to change
    /// \param icon an SDL_Surface structure containing the icon for the window
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setIcon(self: *Window, icon: *Surface) Error!void {
        try internal.checkResult(SDL_SetWindowIcon(self, icon));
    }

    /// Request that the window's position be set.
    ///
    /// If, at the time of this request, the window is in a fixed-size state such
    /// as maximized, this request may be deferred until the window returns to a
    /// resizable state.
    ///
    /// This can be used to reposition fullscreen-desktop windows onto a different
    /// display, however, exclusive fullscreen windows are locked to a specific
    /// display and can only be repositioned programmatically via
    /// SDL_SetWindowFullscreenMode().
    ///
    /// On some windowing systems this request is asynchronous and the new
    /// coordinates may not have have been applied immediately upon the return of
    /// this function. If an immediate change is required, call SDL_SyncWindow() to
    /// block until the changes have taken effect.
    ///
    /// When the window position changes, an SDL_EVENT_WINDOW_MOVED event will be
    /// emitted with the window's new coordinates. Note that the new coordinates
    /// may not match the exact coordinates requested, as some windowing systems
    /// can restrict the position of the window in certain scenarios (e.g.
    /// constraining the position so the window is always within desktop bounds).
    /// Additionally, as this is just a request, it can be denied by the windowing
    /// system.
    ///
    /// \param window the window to reposition
    /// \param x the x coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
    ///          `SDL_WINDOWPOS_UNDEFINED`
    /// \param y the y coordinate of the window, or `SDL_WINDOWPOS_CENTERED` or
    ///          `SDL_WINDOWPOS_UNDEFINED`
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setPosition(self: *Window, x: c_int, y: c_int) Error!void {
        try internal.checkResult(SDL_SetWindowPosition(self, x, y));
    }

    /// Get the position of a window.
    ///
    /// This is the current position of the window as last reported by the
    /// windowing system.
    ///
    /// If you do not need the value for one of the positions a NULL may be passed
    /// in the `x` or `y` parameter.
    ///
    /// \param window the window to query
    /// \param x a pointer filled in with the x position of the window, may be NULL
    /// \param y a pointer filled in with the y position of the window, may be NULL
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getPosition(self: *Window, x: *c_int, y: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowPosition(self, x, y));
    }

    /// Request that the size of a window's client area be set.
    ///
    /// NULL can safely be passed as the `w` or `h` parameter if the width or
    /// height value is not desired.
    ///
    /// If, at the time of this request, the window in a fixed-size state, such as
    /// maximized or fullscreen, the request will be deferred until the window
    /// exits this state and becomes resizable again.
    ///
    /// To change the fullscreen mode of a window, use
    /// SDL_SetWindowFullscreenMode()
    ///
    /// On some windowing systems, this request is asynchronous and the new window
    /// size may not have have been applied immediately upon the return of this
    /// function. If an immediate change is required, call SDL_SyncWindow() to
    /// block until the changes have taken effect.
    ///
    /// When the window size changes, an SDL_EVENT_WINDOW_RESIZED event will be
    /// emitted with the new window dimensions. Note that the new dimensions may
    /// not match the exact size requested, as some windowing systems can restrict
    /// the window size in certain scenarios (e.g. constraining the size of the
    /// content area to remain within the usable desktop bounds). Additionally, as
    /// this is just a request, it can be denied by the windowing system.
    ///
    /// \param window the window to change
    /// \param w the width of the window, must be > 0
    /// \param h the height of the window, must be > 0
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setSize(self: *Window, w: c_int, h: c_int) Error!void {
        try internal.checkResult(SDL_SetWindowSize(self, w, h));
    }

    /// Get the size of a window's client area.
    ///
    /// NULL can safely be passed as the `w` or `h` parameter if the width or
    /// height value is not desired.
    ///
    /// The window pixel size may differ from its window coordinate size if the
    /// window is on a high pixel density display. Use SDL_GetWindowSizeInPixels()
    /// or SDL_GetRenderOutputSize() to get the real client area size in pixels.
    ///
    /// \param window the window to query the width and height from
    /// \param w a pointer filled in with the width of the window, may be NULL
    /// \param h a pointer filled in with the height of the window, may be NULL
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getSize(self: *Window, w: *c_int, h: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowSize(self, w, h));
    }

    /// Get the size of a window's borders (decorations) around the client area.
    ///
    /// Note: If this function fails (returns -1), the size values will be
    /// initialized to 0, 0, 0, 0 (if a non-NULL pointer is provided), as if the
    /// window in question was borderless.
    ///
    /// Note: This function may fail on systems where the window has not yet been
    /// decorated by the display server (for example, immediately after calling
    /// SDL_CreateWindow). It is recommended that you wait at least until the
    /// window has been presented and composited, so that the window system has a
    /// chance to decorate the window and provide the border dimensions to SDL.
    ///
    /// This function also returns -1 if getting the information is not supported.
    ///
    /// \param window the window to query the size values of the border
    ///               (decorations) from
    /// \param top pointer to variable for storing the size of the top border; NULL
    ///            is permitted
    /// \param left pointer to variable for storing the size of the left border;
    ///             NULL is permitted
    /// \param bottom pointer to variable for storing the size of the bottom
    ///               border; NULL is permitted
    /// \param right pointer to variable for storing the size of the right border;
    ///              NULL is permitted
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getSizeInPixels(self: *Window, w: *c_int, h: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowSizeInPixels(self, w, h));
    }

    /// Get the size of a window's borders (decorations) around the client area.
    ///
    /// Note: If this function fails (returns -1), the size values will be
    /// initialized to 0, 0, 0, 0 (if a non-NULL pointer is provided), as if the
    /// window in question was borderless.
    ///
    /// Note: This function may fail on systems where the window has not yet been
    /// decorated by the display server (for example, immediately after calling
    /// SDL_CreateWindow). It is recommended that you wait at least until the
    /// window has been presented and composited, so that the window system has a
    /// chance to decorate the window and provide the border dimensions to SDL.
    ///
    /// This function also returns -1 if getting the information is not supported.
    ///
    /// \param window the window to query the size values of the border
    ///               (decorations) from
    /// \param top pointer to variable for storing the size of the top border; NULL
    ///            is permitted
    /// \param left pointer to variable for storing the size of the left border;
    ///             NULL is permitted
    /// \param bottom pointer to variable for storing the size of the bottom
    ///               border; NULL is permitted
    /// \param right pointer to variable for storing the size of the right border;
    ///              NULL is permitted
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getBordersSize(self: *Window, top: *c_int, left: *c_int, bottom: *c_int, right: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowBordersSize(self, top, left, bottom, right));
    }

    /// Set the minimum size of a window's client area.
    ///
    /// \param window the window to change
    /// \param min_w the minimum width of the window, or 0 for no limit
    /// \param min_h the minimum height of the window, or 0 for no limit
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setMinimumSize(self: *Window, min_w: c_int, min_h: c_int) Error!void {
        try internal.checkResult(SDL_SetWindowMinimumSize(self, min_w, min_h));
    }

    /// Get the minimum size of a window's client area.
    ///
    /// \param window the window to query
    /// \param w a pointer filled in with the minimum width of the window, may be
    ///          NULL
    /// \param h a pointer filled in with the minimum height of the window, may be
    ///          NULL
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getMinimumSize(self: *Window, w: *c_int, h: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowMinimumSize(self, w, h));
    }

    /// Set the maximum size of a window's client area.
    ///
    /// \param window the window to change
    /// \param max_w the maximum width of the window, or 0 for no limit
    /// \param max_h the maximum height of the window, or 0 for no limit
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setMaximumSize(self: *Window, max_w: c_int, max_h: c_int) Error!void {
        try internal.checkResult(SDL_SetWindowMaximumSize(self, max_w, max_h));
    }

    /// Get the maximum size of a window's client area.
    ///
    /// \param window the window to query
    /// \param w a pointer filled in with the maximum width of the window, may be
    ///          NULL
    /// \param h a pointer filled in with the maximum height of the window, may be
    ///          NULL
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getMaximumSize(self: *Window, w: *c_int, h: *c_int) Error!void {
        try internal.checkResult(SDL_GetWindowMaximumSize(self, w, h));
    }

    /// Set the border state of a window.
    ///
    /// This will add or remove the window's `SDL_WINDOW_BORDERLESS` flag and add
    /// or remove the border from the actual window. This is a no-op if the
    /// window's border already matches the requested state.
    ///
    /// You can't change the border state of a fullscreen window.
    ///
    /// \param window the window of which to change the border state
    /// \param bordered SDL_FALSE to remove border, SDL_TRUE to add border
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setBordered(self: *Window, bordered: bool) Error!void {
        try internal.checkResult(SDL_SetWindowBordered(self, Bool.fromZig(bordered)));
    }

    /// Set the user-resizable state of a window.
    ///
    /// This will add or remove the window's `SDL_WINDOW_RESIZABLE` flag and
    /// allow/disallow user resizing of the window. This is a no-op if the window's
    /// resizable state already matches the requested state.
    ///
    /// You can't change the resizable state of a fullscreen window.
    ///
    /// \param window the window of which to change the resizable state
    /// \param resizable SDL_TRUE to allow resizing, SDL_FALSE to disallow
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setResizable(self: *Window, resizable: bool) Error!void {
        try internal.checkResult(SDL_SetWindowResizable(self, Bool.fromZig(resizable)));
    }
    /// Set the window to always be above the others.
    ///
    /// This will add or remove the window's `SDL_WINDOW_ALWAYS_ON_TOP` flag. This
    /// will bring the window to the front and keep the window above the rest.
    ///
    /// \param window The window of which to change the always on top state
    /// \param on_top SDL_TRUE to set the window always on top, SDL_FALSE to
    ///               disable
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setAlwaysOnTop(self: *Window, on_top: bool) Error!void {
        try internal.checkResult(SDL_SetWindowAlwaysOnTop(self, Bool.fromZig(on_top)));
    }

    /// Show a window.
    ///
    /// \param window the window to show
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn show(self: *Window) Error!void {
        try internal.checkResult(SDL_ShowWindow(self));
    }

    /// Hide a window.
    ///
    /// \param window the window to hide
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn hide(self: *Window) Error!void {
        try internal.checkResult(SDL_HideWindow(self));
    }

    /// Raise a window above other windows and set the input focus.
    ///
    /// \param window the window to raise
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn raise(self: *Window) Error!void {
        try internal.checkResult(SDL_RaiseWindow(self));
    }

    /// Request that the window be made as large as possible.
    ///
    /// Non-resizable windows can't be maximized. The window must have the
    /// SDL_WINDOW_RESIZABLE flag set, or this will have no effect.
    ///
    /// On some windowing systems this request is asynchronous and the new window
    /// state may not have have been applied immediately upon the return of this
    /// function. If an immediate change is required, call SDL_SyncWindow() to
    /// block until the changes have taken effect.
    ///
    /// When the window state changes, an SDL_EVENT_WINDOW_MAXIMIZED event will be
    /// emitted. Note that, as this is just a request, the windowing system can
    /// deny the state change.
    ///
    /// When maximizing a window, whether the constraints set via
    /// SDL_SetWindowMaximumSize() are honored depends on the policy of the window
    /// manager. Win32 and macOS enforce the constraints when maximizing, while X11
    /// and Wayland window managers may vary.
    ///
    /// \param window the window to maximize
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn maximize(self: *Window) Error!void {
        try internal.checkResult(SDL_MaximizeWindow(self));
    }

    /// Request that the window be minimized to an iconic representation.
    ///
    /// On some windowing systems this request is asynchronous and the new window
    /// state may not have have been applied immediately upon the return of this
    /// function. If an immediate change is required, call SDL_SyncWindow() to
    /// block until the changes have taken effect.
    ///
    /// When the window state changes, an SDL_EVENT_WINDOW_MINIMIZED event will be
    /// emitted. Note that, as this is just a request, the windowing system can
    /// deny the state change.
    ///
    /// \param window the window to minimize
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn minimize(self: *Window) Error!void {
        try internal.checkResult(SDL_MinimizeWindow(self));
    }

    /// Request that the size and position of a minimized or maximized window be
    /// restored.
    ///
    /// On some windowing systems this request is asynchronous and the new window
    /// state may not have have been applied immediately upon the return of this
    /// function. If an immediate change is required, call SDL_SyncWindow() to
    /// block until the changes have taken effect.
    ///
    /// When the window state changes, an SDL_EVENT_WINDOW_RESTORED event will be
    /// emitted. Note that, as this is just a request, the windowing system can
    /// deny the state change.
    ///
    /// \param window the window to restore
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn restore(self: *Window) Error!void {
        try internal.checkResult(SDL_RestoreWindow(self));
    }

    /// Request that the window's fullscreen state be changed.
    ///
    /// By default a window in fullscreen state uses fullscreen desktop mode, but a
    /// specific display mode can be set using SDL_SetWindowFullscreenMode().
    ///
    /// On some windowing systems this request is asynchronous and the new
    /// fullscreen state may not have have been applied immediately upon the return
    /// of this function. If an immediate change is required, call SDL_SyncWindow()
    /// to block until the changes have taken effect.
    ///
    /// When the window state changes, an SDL_EVENT_WINDOW_ENTER_FULLSCREEN or
    /// SDL_EVENT_WINDOW_LEAVE_FULLSCREEN event will be emitted. Note that, as this
    /// is just a request, it can be denied by the windowing system.
    ///
    /// \param window the window to change
    /// \param fullscreen SDL_TRUE for fullscreen mode, SDL_FALSE for windowed mode
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setFullscreen(self: *Window, fullscreen: bool) Error!void {
        try internal.checkResult(SDL_SetWindowFullscreen(self, Bool.fromZig(fullscreen)));
    }

    /// Block until any pending window state is finalized.
    ///
    /// On asynchronous windowing systems, this acts as a synchronization barrier
    /// for pending window state. It will attempt to wait until any pending window
    /// state has been applied and is guaranteed to return within finite time. Note
    /// that for how long it can potentially block depends on the underlying window
    /// system, as window state changes may involve somewhat lengthy animations
    /// that must complete before the window is in its final requested state.
    ///
    /// On windowing systems where changes are immediate, this does nothing.
    ///
    /// \param window the window for which to wait for the pending state to be
    ///               applied
    /// \returns 0 on success, a positive value if the operation timed out before
    ///          the window was in the requested state, or a negative error code on
    ///          failure; call SDL_GetError() for more information.
    ///
    pub fn sync(self: *Window) Error!void {
        try internal.checkResult(SDL_SyncWindow(self));
    }

    /// Return whether the window has a surface associated with it.
    ///
    /// \param window the window to query
    /// \returns SDL_TRUE if there is a surface associated with the window, or
    ///          SDL_FALSE otherwise.
    ///
    pub fn hasSurface(self: *Window) bool {
        return SDL_HasWindowSurface(self).toZig();
    }

    /// Get the SDL surface associated with the window.
    ///
    /// A new surface will be created with the optimal format for the window, if
    /// necessary. This surface will be freed when the window is destroyed. Do not
    /// free this surface.
    ///
    /// This surface will be invalidated if the window is resized. After resizing a
    /// window this function must be called again to return a valid surface.
    ///
    /// You may not combine this with 3D or the rendering API on this window.
    ///
    /// This function is affected by `SDL_HINT_FRAMEBUFFER_ACCELERATION`.
    ///
    /// \param window the window to query
    /// \returns the surface associated with the window, or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getSurface(self: *Window) Error!*Surface {
        return SDL_GetWindowSurface(self) orelse internal.emitError();
    }

    /// Copy the window surface to the screen.
    ///
    /// This is the function you use to reflect any changes to the surface on the
    /// screen.
    ///
    /// This function is equivalent to the SDL 1.2 API SDL_Flip().
    ///
    /// \param window the window to update
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn updateSurface(self: *Window) Error!void {
        try internal.checkResult(SDL_UpdateWindowSurface(self));
    }

    /// Copy areas of the window surface to the screen.
    ///
    /// This is the function you use to reflect changes to portions of the surface
    /// on the screen.
    ///
    /// This function is equivalent to the SDL 1.2 API SDL_UpdateRects().
    ///
    /// \param window the window to update
    /// \param rects an array of SDL_Rect structures representing areas of the
    ///              surface to copy, in pixels
    /// \param numrects the number of rectangles
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn updateSurfaceRects(self: *Window, rects: []const Rect) Error!void {
        try internal.checkResult(SDL_UpdateWindowSurfaceRects(self, rects.ptr, @intCast(rects.len)));
    }

    /// Destroy the surface associated with the window.
    ///
    /// \param window the window to update
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn destroySurface(self: *Window) Error!void {
        try internal.checkResult(SDL_DestroyWindowSurface(self));
    }

    /// Set a window's input grab mode.
    ///
    /// When input is grabbed, the mouse is confined to the window. This function
    /// will also grab the keyboard if `SDL_HINT_GRAB_KEYBOARD` is set. To grab the
    /// keyboard without also grabbing the mouse, use SDL_SetWindowKeyboardGrab().
    ///
    /// If the caller enables a grab while another window is currently grabbed, the
    /// other window loses its grab in favor of the caller's window.
    ///
    /// \param window the window for which the input grab mode should be set
    /// \param grabbed SDL_TRUE to grab input or SDL_FALSE to release input
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setGrab(self: *Window, grabbed: bool) Error!void {
        try internal.checkResult(SDL_SetWindowGrab(self, Bool.fromZig(grabbed)));
    }

    /// Set a window's keyboard grab mode.
    ///
    /// Keyboard grab enables capture of system keyboard shortcuts like Alt+Tab or
    /// the Meta/Super key. Note that not all system keyboard shortcuts can be
    /// captured by applications (one example is Ctrl+Alt+Del on Windows).
    ///
    /// This is primarily intended for specialized applications such as VNC clients
    /// or VM frontends. Normal games should not use keyboard grab.
    ///
    /// When keyboard grab is enabled, SDL will continue to handle Alt+Tab when the
    /// window is full-screen to ensure the user is not trapped in your
    /// application. If you have a custom keyboard shortcut to exit fullscreen
    /// mode, you may suppress this behavior with
    /// `SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED`.
    ///
    /// If the caller enables a grab while another window is currently grabbed, the
    /// other window loses its grab in favor of the caller's window.
    ///
    /// \param window The window for which the keyboard grab mode should be set.
    /// \param grabbed This is SDL_TRUE to grab keyboard, and SDL_FALSE to release.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setKeyboardGrab(self: *Window, grabbed: bool) Error!void {
        try internal.checkResult(SDL_SetWindowKeyboardGrab(self, Bool.fromZig(grabbed)));
    }

    /// Set a window's mouse grab mode.
    ///
    /// Mouse grab confines the mouse cursor to the window.
    ///
    /// \param window The window for which the mouse grab mode should be set.
    /// \param grabbed This is SDL_TRUE to grab mouse, and SDL_FALSE to release.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setMouseGrab(self: *Window, grabbed: bool) Error!void {
        try internal.checkResult(SDL_SetWindowMouseGrab(self, Bool.fromZig(grabbed)));
    }

    /// Get a window's input grab mode.
    ///
    /// \param window the window to query
    /// \returns SDL_TRUE if input is grabbed, SDL_FALSE otherwise.
    ///
    pub fn getGrab(self: *Window) bool {
        return SDL_GetWindowGrab(self).toZig();
    }

    /// Get a window's keyboard grab mode.
    ///
    /// \param window the window to query
    /// \returns SDL_TRUE if keyboard is grabbed, and SDL_FALSE otherwise.
    ///
    pub fn getKeyboardGrab(self: *Window) bool {
        return SDL_GetWindowKeyboardGrab(self).toZig();
    }

    /// Get a window's mouse grab mode.
    ///
    /// \param window the window to query
    /// \returns SDL_TRUE if mouse is grabbed, and SDL_FALSE otherwise.
    ///
    pub fn getMouseGrab(self: *Window) bool {
        return SDL_GetWindowMouseGrab(self).toZig();
    }

    /// Confines the cursor to the specified area of a window.
    ///
    /// Note that this does NOT grab the cursor, it only defines the area a cursor
    /// is restricted to when the window has mouse focus.
    ///
    /// \param window The window that will be associated with the barrier.
    /// \param rect A rectangle area in window-relative coordinates. If NULL the
    ///             barrier for the specified window will be destroyed.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setMouseRect(self: *Window, r: *const Rect) Error!void {
        try internal.checkResult(SDL_SetWindowMouseRect(self, r));
    }

    /// Get the mouse confinement rectangle of a window.
    ///
    /// \param window The window to query
    /// \returns A pointer to the mouse confinement rectangle of a window, or NULL
    ///          if there isn't one.
    ///
    pub fn getMouseRect(self: *Window) ?*const Rect {
        return SDL_GetWindowMouseRect(self);
    }

    /// Set the opacity for a window.
    ///
    /// The parameter `opacity` will be clamped internally between 0.0f
    /// (transparent) and 1.0f (opaque).
    ///
    /// This function also returns -1 if setting the opacity isn't supported.
    ///
    /// \param window the window which will be made transparent or opaque
    /// \param opacity the opacity value (0.0f - transparent, 1.0f - opaque)
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setOpacity(self: *Window, opacity: f32) Error!void {
        try internal.checkResult(SDL_SetWindowOpacity(self, opacity));
    }

    /// Get the opacity of a window.
    ///
    /// If transparency isn't supported on this platform, opacity will be reported
    /// as 1.0f without error.
    ///
    /// The parameter `opacity` is ignored if it is NULL.
    ///
    /// This function also returns -1 if an invalid window was provided.
    ///
    /// \param window the window to get the current opacity value from
    /// \param out_opacity the float filled in (0.0f - transparent, 1.0f - opaque)
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getOpacity(self: *Window, out_opacity: *f32) Error!void {
        try internal.checkResult(SDL_GetWindowOpacity(self, out_opacity));
    }

    /// Set the window as a modal for another window.
    ///
    /// \param modal_window the window that should be set modal
    /// \param parent_window the parent window for the modal window
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setModalFor(self: *Window, parent_window: *Window) Error!void {
        try internal.checkResult(SDL_SetWindowModalFor(self, parent_window));
    }

    /// Explicitly set input focus to the window.
    ///
    /// You almost certainly want SDL_RaiseWindow() instead of this function. Use
    /// this with caution, as you might give focus to a window that is completely
    /// obscured by other windows.
    ///
    /// \param window the window that should get the input focus
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setInputFocus(self: *Window) Error!void {
        try internal.checkResult(SDL_SetWindowInputFocus(self));
    }

    /// Set whether the window may have input focus.
    ///
    /// \param window the window to set focusable state
    /// \param focusable SDL_TRUE to allow input focus, SDL_FALSE to not allow
    ///                  input focus
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setFocusable(self: *Window, focusable: bool) Error!void {
        try internal.checkResult(SDL_SetWindowFocusable(self, Bool.fromZig(focusable)));
    }

    /// Display the system-level window menu.
    ///
    /// This default window menu is provided by the system and on some platforms
    /// provides functionality for setting or changing privileged state on the
    /// window, such as moving it between workspaces or displays, or toggling the
    /// always-on-top property.
    ///
    /// On platforms or desktops where this is unsupported, this function does
    /// nothing.
    ///
    /// \param window the window for which the menu will be displayed
    /// \param x the x coordinate of the menu, relative to the origin (top-left) of
    ///          the client area
    /// \param y the y coordinate of the menu, relative to the origin (top-left) of
    ///          the client area
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn showSystemMenu(self: *Window, x: c_int, y: c_int) Error!void {
        try internal.checkResult(SDL_ShowWindowSystemMenu(self, x, y));
    }

    /// Provide a callback that decides if a window region has special properties.
    ///
    /// Normally windows are dragged and resized by decorations provided by the
    /// system window manager (a title bar, borders, etc), but for some apps, it
    /// makes sense to drag them from somewhere else inside the window itself; for
    /// example, one might have a borderless window that wants to be draggable from
    /// any part, or simulate its own title bar, etc.
    ///
    /// This function lets the app provide a callback that designates pieces of a
    /// given window as special. This callback is run during event processing if we
    /// need to tell the OS to treat a region of the window specially; the use of
    /// this callback is known as "hit testing."
    ///
    /// Mouse input may not be delivered to your application if it is within a
    /// special area; the OS will often apply that input to moving the window or
    /// resizing the window and not deliver it to the application.
    ///
    /// Specifying NULL for a callback disables hit-testing. Hit-testing is
    /// disabled by default.
    ///
    /// Platforms that don't support this functionality will return -1
    /// unconditionally, even if you're attempting to disable hit-testing.
    ///
    /// Your callback may fire at any time, and its firing does not indicate any
    /// specific behavior (for example, on Windows, this certainly might fire when
    /// the OS is deciding whether to drag your window, but it fires for lots of
    /// other reasons, too, some unrelated to anything you probably care about _and
    /// when the mouse isn't actually at the location it is testing_). Since this
    /// can fire at any time, you should try to keep your callback efficient,
    /// devoid of allocations, etc.
    ///
    /// \param window the window to set hit-testing on
    /// \param callback the function to call when doing a hit-test
    /// \param callback_data an app-defined void pointer passed to **callback**
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setHitTest(self: *Window, callback: HitTest, callback_data: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetWindowHitTest(self, callback, callback_data));
    }

    /// Request a window to demand attention from the user.
    ///
    /// \param window the window to be flashed
    /// \param operation the flash operation
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn flash(self: *Window, operation: FlashOperation) Error!void {
        try internal.checkResult(SDL_FlashWindow(self, operation));
    }

    /// Destroy a window.
    ///
    /// If `window` is NULL, this function will return immediately after setting
    /// the SDL error message to "Invalid window". See SDL_GetError().
    ///
    /// \param window the window to destroy
    ///
    pub fn destroy(self: *Window) void {
        SDL_DestroyWindow(self);
    }

    extern fn SDL_CreateWindow(title: [*:0]const u8, w: c_int, h: c_int, flags: WindowFlags) ?*Window;
    extern fn SDL_CreatePopupWindow(parent: *Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) ?*Window;
    extern fn SDL_CreateWindowWithProperties(props: PropertiesID) ?*Window;
    extern fn SDL_GetDisplayForWindow(window: *Window) DisplayID;
    extern fn SDL_GetWindowPixelDensity(window: *Window) f32;
    extern fn SDL_GetWindowDisplayScale(window: *Window) f32;
    extern fn SDL_SetWindowFullscreenMode(window: *Window, mode: *const DisplayMode) c_int;
    extern fn SDL_GetWindowFullscreenMode(window: *Window) ?*const DisplayMode;
    extern fn SDL_GetWindowICCProfile(window: *Window, size: *usize) ?*anyopaque;
    extern fn SDL_GetWindowPixelFormat(window: *Window) PixelFormat;
    extern fn SDL_GetWindowID(window: *Window) WindowID;
    extern fn SDL_GetWindowParent(window: *Window) ?*Window;
    extern fn SDL_GetWindowProperties(window: *Window) PropertiesID;
    extern fn SDL_GetWindowFlags(window: *Window) WindowFlags;
    extern fn SDL_SetWindowTitle(window: *Window, title: [*:0]const u8) c_int;
    extern fn SDL_GetWindowTitle(window: *Window) ?[*:0]const u8;
    extern fn SDL_SetWindowIcon(window: *Window, icon: *Surface) c_int;
    extern fn SDL_SetWindowPosition(window: *Window, x: c_int, y: c_int) c_int;
    extern fn SDL_GetWindowPosition(window: *Window, x: *c_int, y: *c_int) c_int;
    extern fn SDL_SetWindowSize(window: *Window, w: c_int, h: c_int) c_int;
    extern fn SDL_GetWindowSize(window: *Window, w: *c_int, h: *c_int) c_int;
    extern fn SDL_GetWindowBordersSize(window: *Window, top: *c_int, left: *c_int, bottom: *c_int, right: *c_int) c_int;
    extern fn SDL_GetWindowSizeInPixels(window: *Window, w: *c_int, h: *c_int) c_int;
    extern fn SDL_SetWindowMinimumSize(window: *Window, min_w: c_int, min_h: c_int) c_int;
    extern fn SDL_GetWindowMinimumSize(window: *Window, w: *c_int, h: *c_int) c_int;
    extern fn SDL_SetWindowMaximumSize(window: *Window, max_w: c_int, max_h: c_int) c_int;
    extern fn SDL_GetWindowMaximumSize(window: *Window, w: *c_int, h: *c_int) c_int;
    extern fn SDL_SetWindowBordered(window: *Window, bordered: Bool) c_int;
    extern fn SDL_SetWindowResizable(window: *Window, resizable: Bool) c_int;
    extern fn SDL_SetWindowAlwaysOnTop(window: *Window, on_top: Bool) c_int;
    extern fn SDL_ShowWindow(window: *Window) c_int;
    extern fn SDL_HideWindow(window: *Window) c_int;
    extern fn SDL_RaiseWindow(window: *Window) c_int;
    extern fn SDL_MaximizeWindow(window: *Window) c_int;
    extern fn SDL_MinimizeWindow(window: *Window) c_int;
    extern fn SDL_RestoreWindow(window: *Window) c_int;
    extern fn SDL_SetWindowFullscreen(window: *Window, fullscreen: Bool) c_int;
    extern fn SDL_SyncWindow(window: *Window) c_int;
    extern fn SDL_HasWindowSurface(window: *Window) Bool;
    extern fn SDL_GetWindowSurface(window: *Window) ?*Surface;
    extern fn SDL_UpdateWindowSurface(window: *Window) c_int;
    extern fn SDL_UpdateWindowSurfaceRects(window: *Window, rects: [*]const Rect, numrects: c_int) c_int;
    extern fn SDL_DestroyWindowSurface(window: *Window) c_int;
    extern fn SDL_SetWindowGrab(window: *Window, grabbed: Bool) c_int;
    extern fn SDL_SetWindowKeyboardGrab(window: *Window, grabbed: Bool) c_int;
    extern fn SDL_SetWindowMouseGrab(window: *Window, grabbed: Bool) c_int;
    extern fn SDL_GetWindowGrab(window: *Window) Bool;
    extern fn SDL_GetWindowKeyboardGrab(window: *Window) Bool;
    extern fn SDL_GetWindowMouseGrab(window: *Window) Bool;
    extern fn SDL_SetWindowMouseRect(window: *Window, r: *const Rect) c_int;
    extern fn SDL_GetWindowMouseRect(window: *Window) ?*const Rect;
    extern fn SDL_SetWindowOpacity(window: *Window, opacity: f32) c_int;
    extern fn SDL_GetWindowOpacity(window: *Window, out_opacity: *f32) c_int;
    extern fn SDL_SetWindowModalFor(modal_window: *Window, parent_window: *Window) c_int;
    extern fn SDL_SetWindowInputFocus(window: *Window) c_int;
    extern fn SDL_SetWindowFocusable(window: *Window, focusable: Bool) c_int;
    extern fn SDL_ShowWindowSystemMenu(window: *Window, x: c_int, y: c_int) c_int;
    extern fn SDL_SetWindowHitTest(window: *Window, callback: HitTest, callback_data: ?*anyopaque) c_int;
    extern fn SDL_FlashWindow(window: *Window, operation: FlashOperation) c_int;
    extern fn SDL_DestroyWindow(window: *Window) void;
};

pub const WindowID = enum(u32) {
    invalid = 0,
    _,

    /// Get a window from a stored ID.
    ///
    /// The numeric ID is what SDL_WindowEvent references, and is necessary to map
    /// these events to specific SDL_Window objects.
    ///
    /// \param id the ID of the window
    /// \returns the window associated with `id` or NULL if it doesn't exist; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getWindow(self: WindowID) Error!*Window {
        return SDL_GetWindowFromID(self) orelse internal.emitError();
    }

    extern fn SDL_GetWindowFromID(id: WindowID) ?*Window;
};

/// Get the number of video drivers compiled into SDL.
///
/// \returns a number >= 1 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn getNumVideoDrivers() Error!c_int {
    const num = SDL_GetNumVideoDrivers();
    try internal.assertResult(num > 0);
    return num;
}

/// Get the name of a built in video driver.
///
/// The video drivers are presented in the order in which they are normally
/// checked during initialization.
///
/// \param index the index of a video driver
/// \returns the name of the video driver with the given **index**.
///
pub fn getVideoDriver(index: c_int) Error![*:0]const u8 {
    return getVideoDriver(index) orelse internal.emitError();
}

/// Get the name of the currently initialized video driver.
///
/// \returns the name of the current video driver or NULL if no driver has been
///          initialized.
///
/// \since This function is available since SDL 3.0.0.
///
pub fn getCurrentVideoDriver() ?[*:0]const u8 {
    return SDL_GetCurrentVideoDriver();
}

/// Get the current system theme
///
/// \returns the current system theme, light, dark, or unknown
///
pub fn getSystemTheme() SystemTheme {
    return SDL_GetSystemTheme();
}

/// Get a list of currently connected displays.
///
/// \param count a pointer filled in with the number of displays returned
/// \returns a 0 terminated array of display instance IDs which should be freed
///         with SDL_free(), or NULL on error; call SDL_GetError() for more
///         details.
///
pub fn getDisplays() Error![:.invalid]DisplayID {
    var len: c_int = 0;

    if (SDL_GetDisplays(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

/// Return the primary display.
///
/// \returns the instance ID of the primary display on success or 0 on failure;
///          call SDL_GetError() for more information.
///
pub fn getPrimaryDisplay() Error!DisplayID {
    const id = SDL_GetPrimaryDisplay();
    try internal.assertResult(id != .invalid);
    return id;
}

/// Check whether the screensaver is currently enabled.
///
/// The screensaver is disabled by default since SDL 2.0.2. Before SDL 2.0.2
/// the screensaver was enabled by default.
///
/// The default can also be changed using `SDL_HINT_VIDEO_ALLOW_SCREENSAVER`.
///
/// \returns SDL_TRUE if the screensaver is enabled, SDL_FALSE if it is
///          disabled.
///
pub fn isScreenSaverEnabled() bool {
    return SDL_ScreenSaverEnabled().toZig();
}

/// Allow the screen to be blanked by a screen saver.
///
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn enableScreenSaver() Error!void {
    try internal.checkResult(SDL_EnableScreenSaver());
}

/// Prevent the screen from being blanked by a screen saver.
///
/// If you disable the screensaver, it is automatically re-enabled when SDL
/// quits.
///
/// The screensaver is disabled by default since SDL 2.0.2. Before SDL 2.0.2
/// the screensaver was enabled by default.
///
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn disableScreenSaver() Error!void {
    try internal.checkResult(SDL_DisableScreenSaver());
}

/// Get the window that currently has an input grab enabled.
///
/// \returns the window if input is grabbed or NULL otherwise.
///
pub fn getGrabbedWindow() ?*Window {
    return SDL_GetGrabbedWindow();
}

extern fn SDL_GetNumVideoDrivers() c_int;
extern fn SDL_GetVideoDriver(index: c_int) ?[*:0]const u8;
extern fn SDL_GetCurrentVideoDriver() ?[*:0]const u8;
extern fn SDL_GetSystemTheme() SystemTheme;
extern fn SDL_GetDisplays(count: *c_int) ?[*]DisplayID;
extern fn SDL_GetPrimaryDisplay() DisplayID;
extern fn SDL_ScreenSaverEnabled() Bool;
extern fn SDL_EnableScreenSaver() c_int;
extern fn SDL_DisableScreenSaver() c_int;
extern fn SDL_GetGrabbedWindow() ?*Window;

const std = @import("std");

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const video = @import("video.zig");
const Window = video.Window;

const FunctionPointer = @import("stdinc.zig").FunctionPointer;

pub const AttributeTag = enum(c_uint) {
    red_size,
    green_size,
    blue_size,
    alpha_size,
    buffer_size,
    doublebuffer,
    depth_size,
    stencil_size,
    accum_red_size,
    accum_green_size,
    accum_blue_size,
    accum_alpha_size,
    stereo,
    multisamplebuffers,
    multisamplesamples,
    accelerated_visual,
    retained_backing,
    context_major_version,
    context_minor_version,
    context_flags,
    context_profile_mask,
    share_with_current_context,
    framebuffer_srgb_capable,
    context_release_behavior,
    context_reset_notification,
    context_no_error,
    floatbuffers,
    egl_platform,
};

pub const Profile = enum(u8) {
    core = 0x0001,
    compatibility = 0x0002,
    es = 0x0004,
};

pub const ContexFlags = packed struct(u8) {
    debug: bool = false,
    forward_compatible: bool = false,
    robust_access: bool = false,
    reset_isolation: bool = false,

    __padding: u4 = 0,

    pub fn toInt(self: ContexFlags) c_int {
        return @as(u8, @bitCast(self));
    }
};

pub const ContextReleaseFlags = packed struct(u8) {
    flush: bool = false,

    __padding: u7 = 0,

    pub fn toInt(self: ContextReleaseFlags) c_int {
        return @as(u8, @bitCast(self));
    }
};

pub const ContextResetNotificationFlags = packed struct(u8) {
    lose_context: bool = false,

    __padding: u7,

    pub fn toInt(self: ContextResetNotificationFlags) c_int {
        return @as(u8, @bitCast(self));
    }
};

pub const Attribute = union(AttributeTag) {
    red_size: u8,
    green_size: u8,
    blue_size: u8,
    alpha_size: u8,
    buffer_size: u8,
    doublebuffer: bool,
    depth_size: u8,
    stencil_size: u8,
    accum_red_size: u8,
    accum_green_size: u8,
    accum_blue_size: u8,
    accum_alpha_size: u8,
    stereo: bool,
    multisamplebuffers: u8,
    multisamplesamples: u8,
    accelerated_visual: bool,
    retained_backing: bool,
    context_major_version: u8,
    context_minor_version: u8,
    context_flags: ContexFlags,
    context_profile_mask: Profile,
    share_with_current_context: bool,
    framebuffer_srgb_capable: bool,
    context_release_behavior: ContextReleaseFlags,
    context_reset_notification: ContextResetNotificationFlags,
    context_no_error: bool,
    floatbuffers: bool,
    egl_platform: bool,

    pub fn toInt(self: Attribute) c_int {
        return switch (self) {
            //u8
            .red_size,
            .green_size,
            .blue_size,
            .alpha_size,
            .buffer_size,
            .depth_size,
            .stencil_size,
            .accum_red_size,
            .accum_green_size,
            .accum_blue_size,
            .accum_alpha_size,
            .multisamplebuffers,
            .multisamplesamples,
            .context_major_version,
            .context_minor_version,
            => |val| val,

            // bool
            .doublebuffer,
            .stereo,
            .accelerated_visual,
            .retained_backing,
            .share_with_current_context,
            .framebuffer_srgb_capable,
            .context_no_error,
            .floatbuffers,
            .egl_platform,
            => |val| @intFromBool(val),

            .context_profile_mask => |val| @intFromEnum(val),

            .context_flags => |val| val.toInt(),
            .context_release_behavior => |val| val.toInt(),
            .context_reset_notification => |val| val.toInt(),
        };
    }
};

pub const Context = opaque {
    /// Create an OpenGL context for an OpenGL window, and make it current.
    ///
    /// Windows users new to OpenGL should note that, for historical reasons, GL
    /// functions added after OpenGL version 1.1 are not available by default.
    /// Those functions must be loaded at run-time, either with an OpenGL
    /// extension-handling library or with SDL_GL_GetProcAddress() and its related
    /// functions.
    ///
    /// SDL_GLContext is an alias for `void *`. It's opaque to the application.
    ///
    /// \param window the window to associate with the context
    /// \returns the OpenGL context associated with `window` or NULL on error; call
    ///          SDL_GetError() for more details.
    ///
    pub fn create(window: *Window) Error!*Context {
        return SDL_GL_CreateContext(window) orelse internal.emitError();
    }

    /// Get the currently active OpenGL context.
    ///
    /// \returns the currently active OpenGL context or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getCurrent() Error!*Context {
        return SDL_GL_GetCurrentContext() orelse internal.emitError();
    }

    /// Set up an OpenGL context for rendering into an OpenGL window.
    ///
    /// The context must have been created with a compatible window.
    ///
    /// \param window the window to associate with the context
    /// \param context the OpenGL context to associate with the window
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn makeCurrent(self: *Context, window: *Window) Error!void {
        try internal.checkResult(SDL_GL_MakeCurrent(window, self));
    }

    /// Delete an OpenGL context.
    ///
    /// \param context the OpenGL context to be deleted
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn delete(self: *Context) Error!void {
        try internal.checkResult(SDL_GL_DeleteContext(self));
    }

    extern fn SDL_GL_CreateContext(window: *Window) ?*Context;
    extern fn SDL_GL_GetCurrentContext() ?*Context;
    extern fn SDL_GL_MakeCurrent(window: *Window, context: *Context) c_int;
    extern fn SDL_GL_DeleteContext(context: *Context) c_int;
};

/// Dynamically load an OpenGL library.
///
/// This should be done after initializing the video driver, but before
/// creating any OpenGL windows. If no OpenGL library is loaded, the default
/// library will be loaded upon creation of the first OpenGL window.
///
/// If you do this, you need to retrieve all of the GL functions used in your
/// program from the dynamic library using SDL_GL_GetProcAddress().
///
/// \param path the platform dependent OpenGL library name, or NULL to open the
///             default OpenGL library
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn loadLibrary(path: ?[*:0]const u8) Error!void {
    try internal.checkResult(SDL_GL_LoadLibrary(path));
}

/// Unload the OpenGL library previously loaded by SDL_GL_LoadLibrary().
///
pub fn unloadLibrary() void {
    SDL_GL_UnloadLibrary();
}

/// Get an OpenGL function by name.
///
/// If the GL library is loaded at runtime with SDL_GL_LoadLibrary(), then all
/// GL functions must be retrieved this way. Usually this is used to retrieve
/// function pointers to OpenGL extensions.
///
/// There are some quirks to looking up OpenGL functions that require some
/// extra care from the application. If you code carefully, you can handle
/// these quirks without any platform-specific code, though:
///
/// - On Windows, function pointers are specific to the current GL context;
///   this means you need to have created a GL context and made it current
///   before calling SDL_GL_GetProcAddress(). If you recreate your context or
///   create a second context, you should assume that any existing function
///   pointers aren't valid to use with it. This is (currently) a
///   Windows-specific limitation, and in practice lots of drivers don't suffer
///   this limitation, but it is still the way the wgl API is documented to
///   work and you should expect crashes if you don't respect it. Store a copy
///   of the function pointers that comes and goes with context lifespan.
/// - On X11, function pointers returned by this function are valid for any
///   context, and can even be looked up before a context is created at all.
///   This means that, for at least some common OpenGL implementations, if you
///   look up a function that doesn't exist, you'll get a non-NULL result that
///   is _NOT_ safe to call. You must always make sure the function is actually
///   available for a given GL context before calling it, by checking for the
///   existence of the appropriate extension with SDL_GL_ExtensionSupported(),
///   or verifying that the version of OpenGL you're using offers the function
///   as core functionality.
/// - Some OpenGL drivers, on all platforms, *will* return NULL if a function
///   isn't supported, but you can't count on this behavior. Check for
///   extensions you use, and if you get a NULL anyway, act as if that
///   extension wasn't available. This is probably a bug in the driver, but you
///   can code defensively for this scenario anyhow.
/// - Just because you're on Linux/Unix, don't assume you'll be using X11.
///   Next-gen display servers are waiting to replace it, and may or may not
///   make the same promises about function pointers.
/// - OpenGL function pointers must be declared `APIENTRY` as in the example
///   code. This will ensure the proper calling convention is followed on
///   platforms where this matters (Win32) thereby avoiding stack corruption.
///
/// \param proc the name of an OpenGL function
/// \returns a pointer to the named OpenGL function. The returned pointer
///          should be cast to the appropriate function signature.
///
pub fn getProcAddress(proc: [*:0]const u8) ?FunctionPointer {
    return SDL_GL_GetProcAddress(proc);
}

/// Check if an OpenGL extension is supported for the current context.
///
/// This function operates on the current GL context; you must have created a
/// context and it must be current before calling this function. Do not assume
/// that all contexts you create will have the same set of extensions
/// available, or that recreating an existing context will offer the same
/// extensions again.
///
/// While it's probably not a massive overhead, this function is not an O(1)
/// operation. Check the extensions you care about after creating the GL
/// context and save that information somewhere instead of calling the function
/// every time you need to know.
///
/// \param extension the name of the extension to check
/// \returns SDL_TRUE if the extension is supported, SDL_FALSE otherwise.
///
pub fn isExtensionSupported(extension: [*:0]const u8) bool {
    return SDL_GL_ExtensionSupported(extension).toZig();
}

/// Reset all previously set OpenGL context attributes to their default values.
///
pub fn resetAttributes() void {
    SDL_GL_ResetAttributes();
}

/// Set an OpenGL window attribute before window creation.
///
/// This function sets the OpenGL attribute `attr` to `value`. The requested
/// attributes should be set before creating an OpenGL window. You should use
/// SDL_GL_GetAttribute() to check the values after creating the OpenGL
/// context, since the values obtained can differ from the requested ones.
///
/// \param attr an SDL_GLattr enum value specifying the OpenGL attribute to set
/// \param value the desired value for the attribute
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setAttribute(attr: Attribute) Error!void {
    try internal.checkResult(SDL_GL_SetAttribute(
        std.meta.activeTag(attr),
        attr.toInt(),
    ));
}

/// Get the actual value for an attribute from the current context.
///
/// \param attr an SDL_GLattr enum value specifying the OpenGL attribute to get
/// \param value a pointer filled in with the current value of `attr`
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn getAttribute(attr: AttributeTag, value: *c_int) Error!void {
    try internal.checkResult(SDL_GL_GetAttribute(attr, value));
}

/// Get the currently active OpenGL window.
///
/// \returns the currently active OpenGL window on success or NULL on failure;
///          call SDL_GetError() for more information.
///
pub fn getCurrentWindow() Error!*Window {
    return SDL_GL_GetCurrentWindow() orelse internal.emitError();
}

/// Set the swap interval for the current OpenGL context.
///
/// Some systems allow specifying -1 for the interval, to enable adaptive
/// vsync. Adaptive vsync works the same as vsync, but if you've already missed
/// the vertical retrace for a given frame, it swaps buffers immediately, which
/// might be less jarring for the user during occasional framerate drops. If an
/// application requests adaptive vsync and the system does not support it,
/// this function will fail and return -1. In such a case, you should probably
/// retry the call with 1 for the interval.
///
/// Adaptive vsync is implemented for some glX drivers with
/// GLX_EXT_swap_control_tear, and for some Windows drivers with
/// WGL_EXT_swap_control_tear.
///
/// Read more on the Khronos wiki:
/// https://www.khronos.org/opengl/wiki/Swap_Interval#Adaptive_Vsync
///
/// \param interval 0 for immediate updates, 1 for updates synchronized with
///                 the vertical retrace, -1 for adaptive vsync
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setSwapInterval(interval: c_int) Error!void {
    try internal.checkResult(SDL_GL_SetSwapInterval(interval));
}

/// Get the swap interval for the current OpenGL context.
///
/// If the system can't determine the swap interval, or there isn't a valid
/// current context, this function will set *interval to 0 as a safe default.
///
/// \param interval Output interval value. 0 if there is no vertical retrace
///                 synchronization, 1 if the buffer swap is synchronized with
///                 the vertical retrace, and -1 if late swaps happen
///                 immediately instead of waiting for the next retrace
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn getSwapInterval(interval: *c_int) Error!void {
    try internal.checkResult(SDL_GL_GetSwapInterval(interval));
}

/// Update a window with OpenGL rendering.
///
/// This is used with double-buffered OpenGL contexts, which are the default.
///
/// On macOS, make sure you bind 0 to the draw framebuffer before swapping the
/// window, otherwise nothing will happen. If you aren't using
/// glBindFramebuffer(), this is the default and you won't have to do anything
/// extra.
///
/// \param window the window to change
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn swapWindow(window: *Window) Error!void {
    try internal.checkResult(SDL_GL_SwapWindow(window));
}

extern fn SDL_GL_LoadLibrary(path: ?[*:0]const u8) c_int;
extern fn SDL_GL_GetProcAddress(proc: [*:0]const u8) ?FunctionPointer;
extern fn SDL_GL_UnloadLibrary() void;
extern fn SDL_GL_ExtensionSupported(extension: [*:0]const u8) Bool;
extern fn SDL_GL_ResetAttributes() void;
extern fn SDL_GL_SetAttribute(attr: AttributeTag, value: c_int) c_int;
extern fn SDL_GL_GetAttribute(attr: AttributeTag, value: *c_int) c_int;
extern fn SDL_GL_GetCurrentWindow() ?*Window;
extern fn SDL_GL_SetSwapInterval(interval: c_int) c_int;
extern fn SDL_GL_GetSwapInterval(interval: *c_int) c_int;
extern fn SDL_GL_SwapWindow(window: *Window) c_int;

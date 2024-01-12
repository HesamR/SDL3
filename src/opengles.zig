const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const video = @import("video.zig");
const Window = video.Window;

const FunctionPointer = @import("stdinc.zig").FunctionPointer;

pub const Display = *opaque {};
pub const Config = *opaque {};
pub const Surface = *opaque {};
pub const Attribute = isize;
pub const Int = c_int;

pub const none = 0x3038;

pub const AttribArrayCallback = *const fn () callconv(.C) [*:none]Attribute;
pub const IntArrayCallback = *const fn () callconv(.C) [*:none]Int;

/// Get an EGL library function by name.
///
/// If an EGL library is loaded, this function allows applications to get entry
/// points for EGL functions. This is useful to provide to an EGL API and
/// extension loader.
///
/// \param proc the name of an EGL function
/// \returns a pointer to the named EGL function. The returned pointer should
///          be cast to the appropriate function signature.
///
pub fn getProcAddress(proc: [*:0]const u8) ?FunctionPointer {
    return SDL_EGL_GetProcAddress(proc);
}

/// Get the currently active EGL display.
///
/// \returns the currently active EGL display or NULL on failure; call
///          SDL_GetError() for more information.
///
pub fn getCurrentDisplay() Error!Display {
    return SDL_EGL_GetCurrentEGLDisplay() orelse internal.emitError();
}

/// Get the currently active EGL config.
///
/// \returns the currently active EGL config or NULL on failure; call
///          SDL_GetError() for more information.
///
pub fn getCurrentConfig() Error!Config {
    return SDL_EGL_GetCurrentEGLConfig() orelse internal.emitError();
}

/// Get the EGL surface associated with the window.
///
/// \param window the window to query
/// \returns the EGLSurface pointer associated with the window, or NULL on
///          failure.
///
pub fn getWindowSurface(window: *Window) Error!Surface {
    return SDL_EGL_GetWindowEGLSurface(window);
}

/// Sets the callbacks for defining custom EGLAttrib arrays for EGL
/// initialization.
///
/// Each callback should return a pointer to an EGL attribute array terminated
/// with EGL_NONE. Callbacks may return NULL pointers to signal an error, which
/// will cause the SDL_CreateWindow process to fail gracefully.
///
/// The arrays returned by each callback will be appended to the existing
/// attribute arrays defined by SDL.
///
/// NOTE: These callback pointers will be reset after SDL_GL_ResetAttributes.
///
/// \param platformAttribCallback Callback for attributes to pass to
///                               eglGetPlatformDisplay.
/// \param surfaceAttribCallback Callback for attributes to pass to
///                              eglCreateSurface.
/// \param contextAttribCallback Callback for attributes to pass to
///                              eglCreateContext.
///
pub fn setAttributeCallbacks(platformAttribCallback: AttribArrayCallback, surfaceAttribCallback: IntArrayCallback, contextAttribCallback: IntArrayCallback) void {
    SDL_EGL_SetEGLAttributeCallbacks(platformAttribCallback, surfaceAttribCallback, contextAttribCallback);
}

extern fn SDL_EGL_GetProcAddress(proc: [*:0]const u8) ?FunctionPointer;
extern fn SDL_EGL_GetCurrentEGLDisplay() ?Display;
extern fn SDL_EGL_GetCurrentEGLConfig() ?Config;
extern fn SDL_EGL_GetWindowEGLSurface(window: *Window) ?Surface;
extern fn SDL_EGL_SetEGLAttributeCallbacks(platformAttribCallback: AttribArrayCallback, surfaceAttribCallback: IntArrayCallback, contextAttribCallback: IntArrayCallback) void;

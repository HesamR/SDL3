const internal = @import("internal.zig");
const Error = internal.Error;

///   Initialization flags for SDL_Init and/or SDL_InitSubSystem
///
/// These are the flags which may be passed to SDL_Init().  You should
/// specify the subsystems which you will be using in your application.
///
pub const InitFlags = packed struct(u32) {
    timer: bool = false,
    __padding1: u3 = 0,
    audio: bool = false,
    video: bool = false,
    __padding2: u3 = 0,
    joystick: bool = false,
    __padding3: u2 = 0,
    haptic: bool = false,
    gamepad: bool = false,
    events: bool = false,
    sensor: bool = false,

    __padding4: u16 = 0,
};

/// Initialize the SDL library.
///
/// SDL_Init() simply forwards to calling SDL_InitSubSystem(). Therefore, the
/// two may be used interchangeably. Though for readability of your code
/// SDL_InitSubSystem() might be preferred.
///
/// The file I/O (for example: SDL_RWFromFile) and threading (SDL_CreateThread)
/// subsystems are initialized by default. Message boxes
/// (SDL_ShowSimpleMessageBox) also attempt to work without initializing the
/// video subsystem, in hopes of being useful in showing an error dialog when
/// SDL_Init fails. You must specifically initialize other subsystems if you
/// use them in your application.
///
/// Logging (such as SDL_Log) works without initialization, too.
///
/// `flags` may be any of the following OR'd together:
///
/// - `SDL_INIT_TIMER`: timer subsystem
/// - `SDL_INIT_AUDIO`: audio subsystem
/// - `SDL_INIT_VIDEO`: video subsystem; automatically initializes the events
///   subsystem
/// - `SDL_INIT_JOYSTICK`: joystick subsystem; automatically initializes the
///   events subsystem
/// - `SDL_INIT_HAPTIC`: haptic (force feedback) subsystem
/// - `SDL_INIT_GAMEPAD`: gamepad subsystem; automatically initializes the
///   joystick subsystem
/// - `SDL_INIT_EVENTS`: events subsystem
/// - `SDL_INIT_EVERYTHING`: all of the above subsystems
///
/// Subsystem initialization is ref-counted, you must call SDL_QuitSubSystem()
/// for each SDL_InitSubSystem() to correctly shutdown a subsystem manually (or
/// call SDL_Quit() to force shutdown). If a subsystem is already loaded then
/// this call will increase the ref-count and return.
///
/// \param flags subsystem initialization flags
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
/// \since This function is available since SDL 3.0.0.
///
pub fn init(flags: InitFlags) Error!void {
    try internal.checkResult(SDL_Init(flags));
}
extern fn SDL_Init(flags: InitFlags) c_int;

/// Get a mask of the specified subsystems which are currently initialized.
///
/// \param flags any of the flags used by SDL_Init(); see SDL_Init for details.
/// \returns a mask of all initialized subsystems if `flags` is 0, otherwise it
///          returns the initialization status of the specified subsystems.
///
/// \since This function is available since SDL 3.0.0.
///
pub fn wasInit(flags: InitFlags) InitFlags {
    return SDL_WasInit(flags);
}
extern fn SDL_WasInit(flags: InitFlags) InitFlags;

/// Clean up all initialized subsystems.
///
/// You should call this function even if you have already shutdown each
/// initialized subsystem with SDL_QuitSubSystem(). It is safe to call this
/// function even in the case of errors in initialization.
///
/// You can use this function with atexit() to ensure that it is run when your
/// application is shutdown, but it is not wise to do this from a library or
/// other dynamically loaded code.
///
/// \since This function is available since SDL 3.0.0.
///
pub fn quit() void {
    SDL_Quit();
}
extern fn SDL_Quit() void;

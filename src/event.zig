const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const video = @import("video.zig");
const DisplayID = video.DisplayID;
const WindowID = video.WindowID;

const keyboard = @import("keyboard.zig");
const Keysym = keyboard.Keysym;

const mouse = @import("mouse.zig");
const MouseID = mouse.MouseID;
const MouseButton = mouse.MouseButton;
const MouseButtonFlags = mouse.MouseButtonFlags;
const MouseWheelDirection = mouse.MouseWheelDirection;

const joystick = @import("joystick.zig");
const JoystickID = joystick.JoystickID;
const JoystickPowerLevel = joystick.JoystickPowerLevel;
const JoystickHat = joystick.JoystickHat;
const GamepadAxis8 = joystick.GamepadAxis8;
const GamepadButton8 = joystick.GamepadButton8;

const audio = @import("audio.zig");
const AudioDeviceID = audio.AudioDeviceID;

const touch = @import("touch.zig");
const TouchID = touch.TouchID;
const FingerID = touch.FingerID;

const pen = @import("pen.zig");
const PenID = pen.PenID;
const PenStatusFlags = pen.PenStatusFlags;
const PenTip = pen.PenTip;

const sensor = @import("sensor.zig");
const SensorID = sensor.SensorID;

pub const State = enum(u8) {
    released = 0,
    pressed = 1,
};

const EventType = enum(u32) {
    /// User-requested quit
    quit = 0x100,
    /// The application is being terminated by the OS
    /// Called on iOS in applicationWillTerminate()
    /// Called on Android in onDestroy()
    terminating,
    /// The application is low on memory, free memory if possible.
    /// Called on iOS in applicationDidReceiveMemoryWarning()
    /// Called on Android in onLowMemory()
    low_memory,
    /// The application is about to enter the background
    /// Called on iOS in applicationWillResignActive()
    /// Called on Android in onPause()
    will_enter_background,
    /// The application did enter the background and may not get CPU for some time
    /// Called on iOS in applicationDidEnterBackground()
    /// Called on Android in onPause()
    did_enter_background,
    /// The application is about to enter the foreground
    /// Called on iOS in applicationWillEnterForeground()
    /// Called on Android in onResume()
    will_enter_foreground,
    /// The application is now interactive
    /// Called on iOS in applicationDidBecomeActive()
    /// Called on Android in onResume()
    did_enter_foreground,
    /// The user's locale preferences have changed.
    locale_changed,
    /// The system theme changed
    system_theme_changed,
    /// Display orientation has changed to data1
    display_orientation = 0x151,
    /// Display has been added to the system
    display_added,
    /// Display has been removed from the system
    display_removed,
    /// Display has changed position
    display_moved,
    /// Display has changed content scale
    display_content_scale_changed,
    /// Window has been shown
    window_shown = 0x202,
    /// Window has been hidden
    window_hidden,
    /// Window has been exposed and should be redrawn
    window_exposed,
    /// Window has been moved to data1, data2
    window_moved,
    /// Window has been resized to data1xdata2
    window_resized,
    /// The pixel size of the window has changed to data1xdata2
    window_pixel_size_changed,
    /// Window has been minimized
    window_minimized,
    /// Window has been maximized
    window_maximized,
    /// Window has been restored to normal size and position
    window_restored,
    /// Window has gained mouse focus
    window_mouse_enter,
    /// Window has lost mouse focus
    window_mouse_leave,
    /// Window has gained keyboard focus
    window_focus_gained,
    /// Window has lost keyboard focus
    window_focus_lost,
    /// The window manager requests that the window be closed
    window_close_requested,
    /// Window is being offered a focus (should SetWindowInputFocus() on itself or a subwindow, or ignore)
    window_take_focus,
    /// Window had a hit test that wasn't SDL_HITTEST_NORMAL
    window_hit_test,
    /// The ICC profile of the window's display has changed
    window_iccprof_changed,
    /// Window has been moved to display data1
    window_display_changed,
    /// Window display scale has been changed
    window_display_scale_changed,
    /// The window has been occluded
    window_occluded,
    /// The window has entered fullscreen mode
    window_enter_fullscreen,
    /// The window has left fullscreen mode
    window_leave_fullscreen,
    /// The window with the associated ID is being or has been destroyed. If this message is being handled
    /// in an event watcher, the window handle is still valid and can still be used to retrieve any userdata
    /// associated with the window. Otherwise, the handle has already been destroyed and all resources
    /// associated with it are invalid
    window_destroyed,
    /// Window has gained focus of the pressure-sensitive pen with ID "data1"
    window_pen_enter,
    /// Window has lost focus of the pressure-sensitive pen with ID "data1"
    window_pen_leave,
    /// Key pressed
    key_down = 0x300,
    /// Key released
    key_up,
    /// Keyboard text editing (composition)
    text_editing,
    /// Keyboard text input
    text_input,
    /// Keymap changed due to a system event such as an
    /// input language or keyboard layout change.
    keymap_changed,
    /// Mouse moved
    mouse_motion = 0x400,
    /// Mouse button pressed
    mouse_button_down,
    /// Mouse button released
    mouse_button_up,
    /// Mouse wheel motion
    mouse_wheel,
    /// Joystick axis motion
    joystick_axis_motion = 0x600,
    /// Joystick hat position change
    joystick_hat_motion = 0x602,
    /// Joystick button pressed
    joystick_button_down,
    /// Joystick button released
    joystick_button_up,
    /// A new joystick has been inserted into the system
    joystick_added,
    /// An opened joystick has been removed
    joystick_removed,
    /// Joystick battery level change
    joystick_battery_updated,
    /// Joystick update is complete
    joystick_update_complete,
    /// Gamepad axis motion
    gamepad_axis_motion = 0x650,
    /// Gamepad button pressed
    gamepad_button_down,
    /// Gamepad button released
    gamepad_button_up,
    /// A new gamepad has been inserted into the system
    gamepad_added,
    /// An opened gamepad has been removed
    gamepad_removed,
    /// The gamepad mapping was updated
    gamepad_remapped,
    /// Gamepad touchpad was touched
    gamepad_touchpad_down,
    /// Gamepad touchpad finger was moved
    gamepad_touchpad_motion,
    /// Gamepad touchpad finger was lifted
    gamepad_touchpad_up,
    /// Gamepad sensor was updated
    gamepad_sensor_update,
    /// Gamepad update is complete
    gamepad_update_complete,
    /// Gamepad Steam handle has changed
    gamepad_steam_handle_updated,
    finger_down = 0x700,
    finger_up,
    finger_motion,
    /// The clipboard or primary selection changed
    clipboard_update = 0x900,
    /// The system requests a file open
    drop_file = 0x1000,
    /// text/plain drag-and-drop event
    drop_text,
    /// A new set of drops is beginning (NULL filename)
    drop_begin,
    /// Current set of drops is now complete (NULL filename)
    drop_complete,
    /// Position while moving over the window
    drop_position,
    /// A new audio device is available
    audio_device_added = 0x1100,
    /// An audio device has been removed.
    audio_device_removed,
    /// An audio device's format has been changed by the system.
    audio_device_format_changed,
    /// A sensor was updated
    sensor_update = 0x1200,
    /// Pressure-sensitive pen touched drawing surface
    pen_down = 0x1300,
    /// Pressure-sensitive pen stopped touching drawing surface
    pen_up,
    /// Pressure-sensitive pen moved, or angle/pressure changed
    pen_motion,
    /// Pressure-sensitive pen button pressed
    pen_button_down,
    /// Pressure-sensitive pen button released
    pen_button_up,
    /// The render targets have been reset and their contents need to be updated
    render_targets_reset = 0x2000,
    /// the device has been reset and all textures need to be recreated
    render_device_reset,
    /// Signals the end of an event poll cycle
    poll_sentinel = 0x7f00,
    /// Events ::USER through ::SDL_EVENT_LAST are for your use,
    /// and should be allocated with SDL_RegisterEvents()
    user = 0x8000,
};

pub const CommonEvent = extern struct {
    type: EventType,
    timestamp: u64,
};

pub const DisplayEvent = extern struct {
    type: EventType,
    timestamp: u64,
    display_id: DisplayID,
    data1: i32,
};

pub const WindowEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    data1: i32,
    data2: i32,
};

pub const KeyboardEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    state: State,
    repeat: u8,
    padding2: u8,
    padding3: u8,
    keysym: Keysym,
};

pub const TextEditingEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    text: [*:0]u8,
    start: i32,
    length: i32,
};

pub const TextInputEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    text: [*:0]u8,
};

pub const MouseMotionEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    which: MouseID,
    state: MouseButtonFlags,
    x: f32,
    y: f32,
    xrel: f32,
    yrel: f32,
};

pub const MouseButtonEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    which: MouseID,
    button: MouseButton,
    state: State,
    clicks: u8,
    padding: u8,
    x: f32,
    y: f32,
};

pub const MouseWheelEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    which: MouseID,
    x: f32,
    y: f32,
    direction: MouseWheelDirection,
    mouseX: f32,
    mouseY: f32,
};

pub const JoyAxisEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    axis: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    value: i16,
    padding4: u16,
};

pub const JoyHatEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    hat: u8,
    value: JoystickHat,
    padding1: u8,
    padding2: u8,
};

pub const JoyButtonEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    button: u8,
    state: State,
    padding1: u8,
    padding2: u8,
};

pub const JoyDeviceEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
};

pub const JoyBatteryEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    level: JoystickPowerLevel,
};

pub const GamepadAxisEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    axis: GamepadAxis8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    value: i16,
    padding4: u16,
};

pub const GamepadButtonEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    button: GamepadButton8,
    state: State,
    padding1: u8,
    padding2: u8,
};

pub const GamepadDeviceEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
};

pub const GamepadTouchpadEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    touchpad: i32,
    finger: i32,
    x: f32,
    y: f32,
    pressure: f32,
};

pub const GamepadSensorEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: JoystickID,
    sensor: i32,
    data: [3]f32,
    sensor_timestamp: u64,
};

pub const AudioDeviceEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: AudioDeviceID,
    is_capture: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const TouchFingerEvent = extern struct {
    type: EventType,
    timestamp: u64,
    touchId: TouchID,
    fingerId: FingerID,
    x: f32,
    y: f32,
    dx: f32,
    dy: f32,
    pressure: f32,
    windowID: WindowID,
};

pub const PenTipEvent = extern struct {
    type: EventType,
    timestamp: u64,
    windowID: u32,
    which: PenID,
    tip: PenTip,
    state: State,
    pen_state: PenStatusFlags,
    x: f32,
    y: f32,
    axes: [6]f32,
};

pub const PenMotionEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    which: PenID,
    padding1: u8,
    padding2: u8,
    pen_state: PenStatusFlags,
    x: f32,
    y: f32,
    axes: [6]f32,
};

pub const PenButtonEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    which: PenID,
    button: MouseButton,
    state: State,
    pen_state: PenStatusFlags,
    x: f32,
    y: f32,
    axes: [6]f32,
};

pub const DropEvent = extern struct {
    type: EventType,
    timestamp: u64,
    windowID: WindowID,
    x: f32,
    y: f32,
    source: ?[*:0]u8,
    data: ?[*:0]u8,
};

pub const ClipboardEvent = extern struct {
    type: EventType,
    timestamp: u64,
};

pub const SensorEvent = extern struct {
    type: EventType,
    timestamp: u64,
    which: SensorID,
    data: [6]f32,
    sensor_timestamp: u64,
};

pub const QuitEvent = extern struct {
    type: EventType,
    timestamp: u64,
};

pub const UserEvent = extern struct {
    type: EventType,
    timestamp: u64,
    window_id: WindowID,
    code: i32,
    data1: ?*anyopaque,
    data2: ?*anyopaque,
};

pub const Event = extern union {
    type: EventType,
    common: CommonEvent,
    display: DisplayEvent,
    window: WindowEvent,
    key: KeyboardEvent,
    edit: TextEditingEvent,
    text: TextInputEvent,
    motion: MouseMotionEvent,
    button: MouseButtonEvent,
    wheel: MouseWheelEvent,
    jaxis: JoyAxisEvent,
    jhat: JoyHatEvent,
    jbutton: JoyButtonEvent,
    jdevice: JoyDeviceEvent,
    jbattery: JoyBatteryEvent,
    gaxis: GamepadAxisEvent,
    gbutton: GamepadButtonEvent,
    gdevice: GamepadDeviceEvent,
    gtouchpad: GamepadTouchpadEvent,
    gsensor: GamepadSensorEvent,
    adevice: AudioDeviceEvent,
    sensor: SensorEvent,
    quit: QuitEvent,
    user: UserEvent,
    tfinger: TouchFingerEvent,
    ptip: PenTipEvent,
    pmotion: PenMotionEvent,
    pbutton: PenButtonEvent,
    drop: DropEvent,
    clipboard: ClipboardEvent,
    padding: [128]u8,
};

/// A function pointer used for callbacks that watch the event queue.
///
/// \param userdata what was passed as `userdata` to SDL_SetEventFilter()
///        or SDL_AddEventWatch, etc
/// \param event the event that triggered the callback
/// \returns 1 to permit event to be added to the queue, and 0 to disallow
///          it. When used with SDL_AddEventWatch, the return value is ignored.
///
pub const EventFilter = ?*const fn (userdata: ?*anyopaque, event: *Event) callconv(.C) c_int;

pub const EventAction = enum(c_uint) {
    add,
    peek,
    get,
};

/// Pump the event loop, gathering events from the input devices.
///
/// This function updates the event queue and internal input device state.
///
/// **WARNING**: This should only be run in the thread that initialized the
/// video subsystem, and for extra safety, you should consider only doing those
/// things on the main thread in any case.
///
/// SDL_PumpEvents() gathers all the pending input information from devices and
/// places it in the event queue. Without calls to SDL_PumpEvents() no events
/// would ever be placed on the queue. Often the need for calls to
/// SDL_PumpEvents() is hidden from the user since SDL_PollEvent() and
/// SDL_WaitEvent() implicitly call SDL_PumpEvents(). However, if you are not
/// polling or waiting for events (e.g. you are filtering them), then you must
/// call SDL_PumpEvents() to force an event queue update.
///
pub fn pumpEvents() void {
    SDL_PumpEvents();
}

/// Check the event queue for messages and optionally return them.
///
/// `action` may be any of the following:
///
/// - `SDL_ADDEVENT`: up to `numevents` events will be added to the back of the
///   event queue.
/// - `SDL_PEEKEVENT`: `numevents` events at the front of the event queue,
///   within the specified minimum and maximum type, will be returned to the
///   caller and will _not_ be removed from the queue.
/// - `SDL_GETEVENT`: up to `numevents` events at the front of the event queue,
///   within the specified minimum and maximum type, will be returned to the
///   caller and will be removed from the queue.
///
/// You may have to call SDL_PumpEvents() before calling this function.
/// Otherwise, the events may not be ready to be filtered when you call
/// SDL_PeepEvents().
///
/// This function is thread-safe.
///
/// \param events destination buffer for the retrieved events
/// \param numevents if action is SDL_ADDEVENT, the number of events to add
///                  back to the event queue; if action is SDL_PEEKEVENT or
///                  SDL_GETEVENT, the maximum number of events to retrieve
/// \param action action to take; see [[#action|Remarks]] for details
/// \param minType minimum value of the event type to be considered;
///                SDL_EVENT_FIRST is a safe choice
/// \param maxType maximum value of the event type to be considered;
///                SDL_EVENT_LAST is a safe choice
/// \returns the number of events actually stored or a negative error code on
///          failure; call SDL_GetError() for more information.
///
pub fn peepEvents(events: []Event, action: EventAction, min_type: EventType, max_type: EventType) Error!c_int {
    const res = SDL_PeepEvents(events.ptr, @intCast(events.len), action, min_type, max_type);
    try internal.assertResult(res >= 0);
    return res;
}

/// Check for the existence of a certain event type in the event queue.
///
/// If you need to check for a range of event types, use SDL_HasEvents()
/// instead.
///
/// \param type the type of event to be queried; see SDL_EventType for details
/// \returns SDL_TRUE if events matching `type` are present, or SDL_FALSE if
///          events matching `type` are not present.
///
pub fn hasEvent(typ: EventType) bool {
    return SDL_HasEvent(typ).toZig();
}

/// Check for the existence of certain event types in the event queue.
///
/// If you need to check for a single event type, use SDL_HasEvent() instead.
///
/// \param minType the low end of event type to be queried, inclusive; see
///                SDL_EventType for details
/// \param maxType the high end of event type to be queried, inclusive; see
///                SDL_EventType for details
/// \returns SDL_TRUE if events with type >= `minType` and <= `maxType` are
///          present, or SDL_FALSE if not.
///
pub fn hasEvents(min_type: EventType, max_type: EventType) bool {
    return SDL_HasEvents(min_type, max_type).toZig();
}

/// Clear events of a specific type from the event queue.
///
/// This will unconditionally remove any events from the queue that match
/// `type`. If you need to remove a range of event types, use SDL_FlushEvents()
/// instead.
///
/// It's also normal to just ignore events you don't care about in your event
/// loop without calling this function.
///
/// This function only affects currently queued events. If you want to make
/// sure that all pending OS events are flushed, you can call SDL_PumpEvents()
/// on the main thread immediately before the flush call.
///
/// \param type the type of event to be cleared; see SDL_EventType for details
///
pub fn flushEvent(typ: EventType) void {
    SDL_FlushEvent(typ);
}

/// Clear events of a range of types from the event queue.
///
/// This will unconditionally remove any events from the queue that are in the
/// range of `minType` to `maxType`, inclusive. If you need to remove a single
/// event type, use SDL_FlushEvent() instead.
///
/// It's also normal to just ignore events you don't care about in your event
/// loop without calling this function.
///
/// This function only affects currently queued events. If you want to make
/// sure that all pending OS events are flushed, you can call SDL_PumpEvents()
/// on the main thread immediately before the flush call.
///
/// \param minType the low end of event type to be cleared, inclusive; see
///                SDL_EventType for details
/// \param maxType the high end of event type to be cleared, inclusive; see
///                SDL_EventType for details
///
pub fn flushEvents(min_type: EventType, max_type: EventType) void {
    SDL_FlushEvents(min_type, max_type);
}

/// Poll for currently pending events.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`. The 1 returned refers to
/// this event, immediately stored in the SDL Event structure -- not an event
/// to follow.
///
/// If `event` is NULL, it simply returns 1 if there is an event in the queue,
/// but will not remove it from the queue.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that set the video mode.
///
/// SDL_PollEvent() is the favored way of receiving system events since it can
/// be done from the main loop and does not suspend the main loop while waiting
/// on an event to be posted.
///
/// The common practice is to fully process the event queue once every frame,
/// usually as a first step before updating the game's state:
///
/// ```c
/// while (game_is_still_running) {
///     SDL_Event event;
///     while (SDL_PollEvent(&event)) {  // poll until all events are handled!
///         // decide what to do with this event.
///     }
///
///     // update game state, draw the current frame
/// }
/// ```
///
/// \param event the SDL_Event structure to be filled with the next event from
///              the queue, or NULL
/// \returns SDL_TRUE if this got an event or SDL_FALSE if there are none
///          available.
///
pub fn pollEvent(event: ?*Event) bool {
    return SDL_PollEvent(event).toZig();
}

/// Wait indefinitely for the next available event.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that initialized the video subsystem.
///
/// \param event the SDL_Event structure to be filled in with the next event
///              from the queue, or NULL
/// \returns SDL_TRUE on success or SDL_FALSE if there was an error while
///          waiting for events; call SDL_GetError() for more information.
///
pub fn waitEvent(event: ?*Event) bool {
    return SDL_WaitEvent(event).toZig();
}

/// Wait until the specified timeout (in milliseconds) for the next available
/// event.
///
/// If `event` is not NULL, the next event is removed from the queue and stored
/// in the SDL_Event structure pointed to by `event`.
///
/// As this function may implicitly call SDL_PumpEvents(), you can only call
/// this function in the thread that initialized the video subsystem.
///
/// The timeout is not guaranteed, the actual wait time could be longer due to
/// system scheduling.
///
/// \param event the SDL_Event structure to be filled in with the next event
///              from the queue, or NULL
/// \param timeoutMS the maximum number of milliseconds to wait for the next
///                  available event
/// \returns SDL_TRUE if this got an event or SDL_FALSE if the timeout elapsed
///          without any events available.
///
pub fn waitEventTimeout(event: ?*Event, timeout_ms: i32) bool {
    return SDL_WaitEventTimeout(event, timeout_ms).toZig();
}

/// Add an event to the event queue.
///
/// The event queue can actually be used as a two way communication channel.
/// Not only can events be read from the queue, but the user can also push
/// their own events onto it. `event` is a pointer to the event structure you
/// wish to push onto the queue. The event is copied into the queue, and the
/// caller may dispose of the memory pointed to after SDL_PushEvent() returns.
///
/// Note: Pushing device input events onto the queue doesn't modify the state
/// of the device within SDL.
///
/// This function is thread-safe, and can be called from other threads safely.
///
/// Note: Events pushed onto the queue with SDL_PushEvent() get passed through
/// the event filter but events added with SDL_PeepEvents() do not.
///
/// For pushing application-specific events, please use SDL_RegisterEvents() to
/// get an event type that does not conflict with other code that also wants
/// its own custom event types.
///
/// \param event the SDL_Event to be added to the queue
/// \returns 1 on success, 0 if the event was filtered, or a negative error
///          code on failure; call SDL_GetError() for more information. A
///          common reason for error is the event queue being full.
///
pub fn pushEvent(event: *Event) Error!void {
    try internal.checkResult(SDL_PushEvent(event));
}

/// Set up a filter to process all events before they change internal state and
/// are posted to the internal event queue.
///
/// If the filter function returns 1 when called, then the event will be added
/// to the internal queue. If it returns 0, then the event will be dropped from
/// the queue, but the internal state will still be updated. This allows
/// selective filtering of dynamically arriving events.
///
/// **WARNING**: Be very careful of what you do in the event filter function,
/// as it may run in a different thread!
///
/// On platforms that support it, if the quit event is generated by an
/// interrupt signal (e.g. pressing Ctrl-C), it will be delivered to the
/// application at the next event poll.
///
/// There is one caveat when dealing with the ::SDL_QuitEvent event type. The
/// event filter is only called when the window manager desires to close the
/// application window. If the event filter returns 1, then the window will be
/// closed, otherwise the window will remain open if possible.
///
/// Note: Disabled events never make it to the event filter function; see
/// SDL_SetEventEnabled().
///
/// Note: If you just want to inspect events without filtering, you should use
/// SDL_AddEventWatch() instead.
///
/// Note: Events pushed onto the queue with SDL_PushEvent() get passed through
/// the event filter, but events pushed onto the queue with SDL_PeepEvents() do
/// not.
///
/// \param filter An SDL_EventFilter function to call when an event happens
/// \param userdata a pointer that is passed to `filter`
///
pub fn setEventFilter(filter: EventFilter, userdata: ?*anyopaque) void {
    SDL_SetEventFilter(filter, userdata);
}

/// Query the current event filter.
///
/// This function can be used to "chain" filters, by saving the existing filter
/// before replacing it with a function that will call that saved filter.
///
/// \param filter the current callback function will be stored here
/// \param userdata the pointer that is passed to the current event filter will
///                 be stored here
/// \returns SDL_TRUE on success or SDL_FALSE if there is no event filter set.
///
pub fn getEventFilter(filter: *EventFilter, userdata: *?*anyopaque) bool {
    return SDL_GetEventFilter(filter, userdata).toZig();
}

/// Add a callback to be triggered when an event is added to the event queue.
///
/// `filter` will be called when an event happens, and its return value is
/// ignored.
///
/// **WARNING**: Be very careful of what you do in the event filter function,
/// as it may run in a different thread!
///
/// If the quit event is generated by a signal (e.g. SIGINT), it will bypass
/// the internal queue and be delivered to the watch callback immediately, and
/// arrive at the next event poll.
///
/// Note: the callback is called for events posted by the user through
/// SDL_PushEvent(), but not for disabled events, nor for events by a filter
/// callback set with SDL_SetEventFilter(), nor for events posted by the user
/// through SDL_PeepEvents().
///
/// \param filter an SDL_EventFilter function to call when an event happens.
/// \param userdata a pointer that is passed to `filter`
/// \returns 0 on success, or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn addEventWatch(filter: EventFilter, userdata: ?*anyopaque) Error!void {
    try internal.checkResult(SDL_AddEventWatch(filter, userdata));
}

/// Remove an event watch callback added with SDL_AddEventWatch().
///
/// This function takes the same input as SDL_AddEventWatch() to identify and
/// delete the corresponding callback.
///
/// \param filter the function originally passed to SDL_AddEventWatch()
/// \param userdata the pointer originally passed to SDL_AddEventWatch()
///
pub fn delEventWatch(filter: EventFilter, userdata: ?*anyopaque) void {
    SDL_DelEventWatch(filter, userdata);
}

/// Run a specific filter function on the current event queue, removing any
/// events for which the filter returns 0.
///
/// See SDL_SetEventFilter() for more information. Unlike SDL_SetEventFilter(),
/// this function does not change the filter permanently, it only uses the
/// supplied filter until this function returns.
///
/// \param filter the SDL_EventFilter function to call when an event happens
/// \param userdata a pointer that is passed to `filter`
///
pub fn filterEvents(filter: EventFilter, userdata: ?*anyopaque) void {
    SDL_FilterEvents(filter, userdata);
}

/// Set the state of processing events by type.
///
/// \param type the type of event; see SDL_EventType for details
/// \param enabled whether to process the event or not
///
pub fn setEventEnabled(typ: EventType, enabled: bool) void {
    SDL_SetEventEnabled(typ, Bool.fromZig(enabled));
}

/// Query the state of processing events by type.
///
/// \param type the type of event; see SDL_EventType for details
/// \returns SDL_TRUE if the event is being processed, SDL_FALSE otherwise.
///
pub fn isEventEnabled(typ: EventType) bool {
    return SDL_EventEnabled(typ).toZig();
}

extern fn SDL_PumpEvents() void;
extern fn SDL_PeepEvents(events: [*]Event, numevents: c_int, action: EventAction, minType: EventType, maxType: EventType) c_int;
extern fn SDL_HasEvent(@"type": EventType) Bool;
extern fn SDL_HasEvents(minType: EventType, maxType: EventType) Bool;
extern fn SDL_FlushEvent(@"type": EventType) void;
extern fn SDL_FlushEvents(minType: EventType, maxType: EventType) void;
extern fn SDL_PollEvent(event: ?*Event) Bool;
extern fn SDL_WaitEvent(event: ?*Event) Bool;
extern fn SDL_WaitEventTimeout(event: ?*Event, timeoutMS: i32) Bool;
extern fn SDL_PushEvent(event: *Event) c_int;
extern fn SDL_SetEventFilter(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_GetEventFilter(filter: *EventFilter, userdata: *?*anyopaque) Bool;
extern fn SDL_AddEventWatch(filter: EventFilter, userdata: ?*anyopaque) c_int;
extern fn SDL_DelEventWatch(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_FilterEvents(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_SetEventEnabled(@"type": EventType, enabled: Bool) void;
extern fn SDL_EventEnabled(@"type": EventType) Bool;

// extern fn SDL_RegisterEvents(numevents: c_int) u32;
// extern fn SDL_AllocateEventMemory(size: usize) ?*anyopaque;

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

pub const ms_per_second = 1000;
pub const us_per_second = 1000000;
pub const ns_per_second = 1000000000;
pub const ns_per_ms = 1000000;
pub const ns_per_us = 1000;

pub fn msToNs(ms: u64) u64 {
    return ms * ns_per_ms;
}

pub fn nsToMs(ns: u64) u64 {
    return ns / ns_per_ms;
}

pub fn usToNs(us: u64) u64 {
    return us * ns_per_us;
}

pub fn nsToUs(ns: u64) u64 {
    return ns / ns_per_us;
}

/// Function prototype for the timer callback function.
///
/// The callback function is passed the current timer interval and returns
/// the next timer interval, in milliseconds. If the returned value is the same as the one
/// passed in, the periodic alarm continues, otherwise a new alarm is
/// scheduled. If the callback returns 0, the periodic alarm is cancelled.
pub const TimerCallback = *const fn (interval: u32, userdata: ?*anyopaque) callconv(.C) u32;

pub const TimerID = enum(c_int) {
    invalid = 0,
    _,

    /// Call a callback function at a future time.
    ///
    /// If you use this function, you must pass `SDL_INIT_TIMER` to SDL_Init().
    ///
    /// The callback function is passed the current timer interval and the user
    /// supplied parameter from the SDL_AddTimer() call and should return the next
    /// timer interval. If the value returned from the callback is 0, the timer is
    /// canceled.
    ///
    /// The callback is run on a separate thread.
    ///
    /// Timers take into account the amount of time it took to execute the
    /// callback. For example, if the callback took 250 ms to execute and returned
    /// 1000 (ms), the timer would only wait another 750 ms before its next
    /// iteration.
    ///
    /// Timing may be inexact due to OS scheduling. Be sure to note the current
    /// time with SDL_GetTicksNS() or SDL_GetPerformanceCounter() in case your
    /// callback needs to adjust for variances.
    ///
    /// \param interval the timer delay, in milliseconds, passed to `callback`
    /// \param callback the SDL_TimerCallback function to call when the specified
    ///                 `interval` elapses
    /// \param param a pointer that is passed to `callback`
    /// \returns a timer ID or 0 if an error occurs; call SDL_GetError() for more
    ///          information.
    ///
    pub fn add(interval: u32, callback: TimerCallback, param: ?*anyopaque) Error!TimerID {
        const id = SDL_AddTimer(interval, callback, param);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Remove a timer created with SDL_AddTimer().
    ///
    /// \param id the ID of the timer to remove
    /// \returns SDL_TRUE if the timer is removed or SDL_FALSE if the timer wasn't
    ///          found.
    ///
    pub fn remove(self: TimerID) bool {
        return SDL_RemoveTimer(self).toZig();
    }

    extern fn SDL_AddTimer(interval: u32, callback: TimerCallback, param: ?*anyopaque) TimerID;
    extern fn SDL_RemoveTimer(id: TimerID) Bool;
};

/// Get the number of milliseconds since SDL library initialization.
///
/// \returns an unsigned 64-bit value representing the number of milliseconds
///          since the SDL library initialized.
///
pub fn getTicks() u64 {
    return SDL_GetTicks();
}

/// Get the number of nanoseconds since SDL library initialization.
///
/// \returns an unsigned 64-bit value representing the number of nanoseconds
///          since the SDL library initialized.
///
pub fn getTicksNS() u64 {
    return SDL_GetTicksNS();
}

/// Get the current value of the high resolution counter.
///
/// This function is typically used for profiling.
///
/// The counter values are only meaningful relative to each other. Differences
/// between values can be converted to times by using
/// SDL_GetPerformanceFrequency().
///
/// \returns the current counter value.
///
pub fn getPerformanceCounter() u64 {
    return SDL_GetPerformanceCounter();
}

/// Get the count per second of the high resolution counter.
///
/// \returns a platform-specific count per second.
///
pub fn getPerformanceFrequency() u64 {
    return SDL_GetPerformanceFrequency();
}

/// Wait a specified number of milliseconds before returning.
///
/// This function waits a specified number of milliseconds before returning. It
/// waits at least the specified time, but possibly longer due to OS
/// scheduling.
///
/// \param ms the number of milliseconds to delay
///
pub fn delay(ms: u32) void {
    SDL_Delay(ms);
}

/// Wait a specified number of nanoseconds before returning.
///
/// This function waits a specified number of nanoseconds before returning. It
/// waits at least the specified time, but possibly longer due to OS
/// scheduling.
///
/// \param ns the number of nanoseconds to delay
///
pub fn delayNS(ns: u64) void {
    SDL_DelayNS(ns);
}

extern fn SDL_GetTicks() u64;
extern fn SDL_GetTicksNS() u64;
extern fn SDL_GetPerformanceCounter() u64;
extern fn SDL_GetPerformanceFrequency() u64;
extern fn SDL_Delay(ms: u32) void;
extern fn SDL_DelayNS(ns: u64) void;

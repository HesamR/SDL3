const builtin = @import("builtin");

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const PropertiesID = @import("properties.zig").PropertiesID;

const endian = builtin.cpu.arch.endian();

/// Audio format flags.
///
/// These are what the 16 bits in SDL_AudioFormat currently mean...
/// (Unspecified bits are always zero).
///
/// \verbatim
/// ++-----------------------sample is signed if set
/// ||
/// ||       ++-----------sample is bigendian if set
/// ||       ||
/// ||       ||          ++---sample is float if set
/// ||       ||          ||
/// ||       ||          || +---sample bit size---+
/// ||       ||          || |                     |
/// 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
/// \endverbatim
///
/// There are macros in SDL 2.0 and later to query these bits.
///
pub const AudioFormat = packed struct(u16) {
    sample_size: u8,
    float: bool = 0,

    __padding1: u3 = 0,

    big_endian: bool = false,

    __padding2: u2 = 0,

    signed: bool = false,

    pub const unsigned8: AudioFormat = .{
        .sample_size = 8,
    };

    pub const signed8: AudioFormat = .{
        .sample_size = 8,
        .signed = true,
    };

    pub const signed16le: AudioFormat = .{
        .sample_size = 16,
        .signed = true,
    };

    pub const signed16be: AudioFormat = .{
        .sample_size = 16,
        .signed = true,
        .big_endian = true,
    };

    pub const signed32le: AudioFormat = .{
        .sample_size = 32,
        .signed = true,
    };

    pub const signed32be: AudioFormat = .{
        .sample_size = 32,
        .signed = true,
        .big_endian = true,
    };

    pub const float32le: AudioFormat = .{
        .sample_size = 32,
        .float = true,
        .signed = true,
    };

    pub const float32be: AudioFormat = .{
        .sample_size = 32,
        .float = true,
        .big_endian = true,
        .signed = true,
    };

    pub const signed16 = switch (endian) {
        .big => signed16be,
        .little => signed16le,
    };

    pub const singed32 = switch (endian) {
        .big => signed32be,
        .little => signed32le,
    };

    pub const float32 = switch (endian) {
        .big => float32be,
        .little => float32le,
    };
};

pub const AudioSpec = extern struct {
    format: AudioFormat,

    /// For multi-channel audio, the default SDL channel mapping is:
    ///
    /// 2:  FL  FR                          (stereo)
    /// 3:  FL  FR LFE                      (2.1 surround)
    /// 4:  FL  FR  BL  BR                  (quad)
    /// 5:  FL  FR LFE  BL  BR              (4.1 surround)
    /// 6:  FL  FR  FC LFE  SL  SR          (5.1 surround - last two can also be BL BR)
    /// 7:  FL  FR  FC LFE  BC  SL  SR      (6.1 surround)
    /// 8:  FL  FR  FC LFE  BL  BR  SL  SR  (7.1 surround)
    channels: c_int,
    freq: c_int,
};

/// A callback that fires when data passes through an SDL_AudioStream.
///
/// Apps can (optionally) register a callback with an audio stream that
/// is called when data is added with SDL_PutAudioStreamData, or requested
/// with SDL_GetAudioStreamData. These callbacks may run from any
/// thread, so if you need to protect shared data, you should use
/// SDL_LockAudioStream to serialize access; this lock will be held by
/// before your callback is called, so your callback does not need to
/// manage the lock explicitly.
///
/// Two values are offered here: one is the amount of additional data needed
/// to satisfy the immediate request (which might be zero if the stream
/// already has enough data queued) and the other is the total amount
/// being requested. In a Get call triggering a Put callback, these
/// values can be different. In a Put call triggering a Get callback,
/// these values are always the same.
///
/// Byte counts might be slightly overestimated due to buffering or
/// resampling, and may change from call to call.
///
/// \param stream The SDL audio stream associated with this callback.
/// \param additional_amount The amount of data, in bytes, that is needed right now.
/// \param total_amount The total amount of data requested, in bytes, that is requested or available.
/// \param userdata An opaque pointer provided by the app for their personal use.
///
pub const AudioStreamFn = *const fn (userdata: ?*anyopaque, stream: *AudioStream, additional_amount: c_int, total_amount: c_int) callconv(.C) void;

/// A callback that fires when data is about to be fed to an audio device.
///
/// This is useful for accessing the final mix, perhaps for writing a
/// visualizer or applying a final effect to the audio data before playback.
///
/// \sa SDL_SetAudioDevicePostmixCallback
///
pub const AudioPostmixFn = *const fn (userdata: ?*anyopaque, *const AudioSpec, buffer: [*]f32, len: c_int) callconv(.C) void;

pub const default_output_audio_device_id: AudioDeviceID = .default_output;
pub const default_capture_audio_device_id: AudioDeviceID = .defautt_capture;

pub const AudioDeviceID = enum(u32) {
    invalid = 0,
    default_output = 0xffffffff,
    defautt_capture = 0xfffffffe,
    _,

    /// Open a specific audio device.
    ///
    /// You can open both output and capture devices through this function. Output
    /// devices will take data from bound audio streams, mix it, and send it to the
    /// hardware. Capture devices will feed any bound audio streams with a copy of
    /// any incoming data.
    ///
    /// An opened audio device starts out with no audio streams bound. To start
    /// audio playing, bind a stream and supply audio data to it. Unlike SDL2,
    /// there is no audio callback; you only bind audio streams and make sure they
    /// have data flowing into them (however, you can simulate SDL2's semantics
    /// fairly closely by using SDL_OpenAudioDeviceStream instead of this
    /// function).
    ///
    /// If you don't care about opening a specific device, pass a `devid` of either
    /// `SDL_AUDIO_DEVICE_DEFAULT_OUTPUT` or `SDL_AUDIO_DEVICE_DEFAULT_CAPTURE`. In
    /// this case, SDL will try to pick the most reasonable default, and may also
    /// switch between physical devices seamlessly later, if the most reasonable
    /// default changes during the lifetime of this opened device (user changed the
    /// default in the OS's system preferences, the default got unplugged so the
    /// system jumped to a new default, the user plugged in headphones on a mobile
    /// device, etc). Unless you have a good reason to choose a specific device,
    /// this is probably what you want.
    ///
    /// You may request a specific format for the audio device, but there is no
    /// promise the device will honor that request for several reasons. As such,
    /// it's only meant to be a hint as to what data your app will provide. Audio
    /// streams will accept data in whatever format you specify and manage
    /// conversion for you as appropriate. SDL_GetAudioDeviceFormat can tell you
    /// the preferred format for the device before opening and the actual format
    /// the device is using after opening.
    ///
    /// It's legal to open the same device ID more than once; each successful open
    /// will generate a new logical SDL_AudioDeviceID that is managed separately
    /// from others on the same physical device. This allows libraries to open a
    /// device separately from the main app and bind its own streams without
    /// conflicting.
    ///
    /// It is also legal to open a device ID returned by a previous call to this
    /// function; doing so just creates another logical device on the same physical
    /// device. This may be useful for making logical groupings of audio streams.
    ///
    /// This function returns the opened device ID on success. This is a new,
    /// unique SDL_AudioDeviceID that represents a logical device.
    ///
    /// Some backends might offer arbitrary devices (for example, a networked audio
    /// protocol that can connect to an arbitrary server). For these, as a change
    /// from SDL2, you should open a default device ID and use an SDL hint to
    /// specify the target if you care, or otherwise let the backend figure out a
    /// reasonable default. Most backends don't offer anything like this, and often
    /// this would be an end user setting an environment variable for their custom
    /// need, and not something an application should specifically manage.
    ///
    /// When done with an audio device, possibly at the end of the app's life, one
    /// should call SDL_CloseAudioDevice() on the returned device id.
    ///
    /// \param devid the device instance id to open, or
    ///              SDL_AUDIO_DEVICE_DEFAULT_OUTPUT or
    ///              SDL_AUDIO_DEVICE_DEFAULT_CAPTURE for the most reasonable
    ///              default device.
    /// \param spec the requested device configuration. Can be NULL to use
    ///             reasonable defaults.
    /// \returns The device ID on success, 0 on error; call SDL_GetError() for more
    ///          information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn open(self: AudioDeviceID, spec: ?*const AudioSpec) Error!AudioDeviceID {
        const id = SDL_OpenAudioDevice(self, spec);
        try internal.assertResult(id != .invalid);
        return id;
    }

    /// Convenience function for straightforward audio init for the common case.
    ///
    /// If all your app intends to do is provide a single source of PCM audio, this
    /// function allows you to do all your audio setup in a single call.
    ///
    /// This is intended to be a clean means to migrate apps from SDL2.
    ///
    /// This function will open an audio device, create a stream and bind it.
    /// Unlike other methods of setup, the audio device will be closed when this
    /// stream is destroyed, so the app can treat the returned SDL_AudioStream as
    /// the only object needed to manage audio playback.
    ///
    /// Also unlike other functions, the audio device begins paused. This is to map
    /// more closely to SDL2-style behavior, and since there is no extra step here
    /// to bind a stream to begin audio flowing. The audio device should be resumed
    /// with SDL_ResumeAudioDevice(SDL_GetAudioStreamDevice(stream));
    ///
    /// This function works with both playback and capture devices.
    ///
    /// The `spec` parameter represents the app's side of the audio stream. That
    /// is, for recording audio, this will be the output format, and for playing
    /// audio, this will be the input format.
    ///
    /// If you don't care about opening a specific audio device, you can (and
    /// probably _should_), use SDL_AUDIO_DEVICE_DEFAULT_OUTPUT for playback and
    /// SDL_AUDIO_DEVICE_DEFAULT_CAPTURE for recording.
    ///
    /// One can optionally provide a callback function; if NULL, the app is
    /// expected to queue audio data for playback (or unqueue audio data if
    /// capturing). Otherwise, the callback will begin to fire once the device is
    /// unpaused.
    ///
    /// \param devid an audio device to open, or SDL_AUDIO_DEVICE_DEFAULT_OUTPUT or
    ///              SDL_AUDIO_DEVICE_DEFAULT_CAPTURE.
    /// \param spec the audio stream's data format. Required.
    /// \param callback A callback where the app will provide new data for
    ///                 playback, or receive new data for capture. Can be NULL, in
    ///                 which case the app will need to call SDL_PutAudioStreamData
    ///                 or SDL_GetAudioStreamData as necessary.
    /// \param userdata App-controlled pointer passed to callback. Can be NULL.
    ///                 Ignored if callback is NULL.
    /// \returns an audio stream on success, ready to use. NULL on error; call
    ///          SDL_GetError() for more information. When done with this stream,
    ///          call SDL_DestroyAudioStream to free resources and close the
    ///          device.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn openStream(self: AudioDeviceID, spec: *const AudioSpec, callback: ?AudioStreamFn, userdata: ?*anyopaque) Error!*AudioStream {
        return SDL_OpenAudioDeviceStream(self, spec, callback, userdata) orelse internal.emitError();
    }

    /// Get the human-readable name of a specific audio device.
    ///
    /// The string returned by this function is UTF-8 encoded. The caller should
    /// call SDL_free on the return value when done with it.
    ///
    /// \param devid the instance ID of the device to query.
    /// \returns the name of the audio device, or NULL on error.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getName(self: AudioDeviceID) Error![*:0]u8 {
        return SDL_GetAudioDeviceName(self) orelse internal.emitError();
    }

    /// Get the current audio format of a specific audio device.
    ///
    /// For an opened device, this will report the format the device is currently
    /// using. If the device isn't yet opened, this will report the device's
    /// preferred format (or a reasonable default if this can't be determined).
    ///
    /// You may also specify SDL_AUDIO_DEVICE_DEFAULT_OUTPUT or
    /// SDL_AUDIO_DEVICE_DEFAULT_CAPTURE here, which is useful for getting a
    /// reasonable recommendation before opening the system-recommended default
    /// device.
    ///
    /// You can also use this to request the current device buffer size. This is
    /// specified in sample frames and represents the amount of data SDL will feed
    /// to the physical hardware in each chunk. This can be converted to
    /// milliseconds of audio with the following equation:
    ///
    /// `ms = (int) ((((Sint64) frames) * 1000) / spec.freq);`
    ///
    /// Buffer size is only important if you need low-level control over the audio
    /// playback timing. Most apps do not need this.
    ///
    /// \param devid the instance ID of the device to query.
    /// \param spec On return, will be filled with device details.
    /// \param sample_frames Pointer to store device buffer size, in sample frames.
    ///                      Can be NULL.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getFormat(self: AudioDeviceID, spec: *AudioSpec, sample_frames: *c_int) Error!void {
        try internal.checkResult(SDL_GetAudioDeviceFormat(self, spec, sample_frames));
    }

    /// Use this function to pause audio playback on a specified device.
    ///
    /// This function pauses audio processing for a given device. Any bound audio
    /// streams will not progress, and no audio will be generated. Pausing one
    /// device does not prevent other unpaused devices from running.
    ///
    /// Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    /// has to bind a stream before any audio will flow. Pausing a paused device is
    /// a legal no-op.
    ///
    /// Pausing a device can be useful to halt all audio without unbinding all the
    /// audio streams. This might be useful while a game is paused, or a level is
    /// loading, etc.
    ///
    /// Physical devices can not be paused or unpaused, only logical devices
    /// created through SDL_OpenAudioDevice() can be.
    ///
    /// \param dev a device opened by SDL_OpenAudioDevice()
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn pause(self: AudioDeviceID) Error!void {
        try internal.checkResult(SDL_PauseAudioDevice(self));
    }

    /// Use this function to unpause audio playback on a specified device.
    ///
    /// This function unpauses audio processing for a given device that has
    /// previously been paused with SDL_PauseAudioDevice(). Once unpaused, any
    /// bound audio streams will begin to progress again, and audio can be
    /// generated.
    ///
    /// Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    /// has to bind a stream before any audio will flow. Unpausing an unpaused
    /// device is a legal no-op.
    ///
    /// Physical devices can not be paused or unpaused, only logical devices
    /// created through SDL_OpenAudioDevice() can be.
    ///
    /// \param dev a device opened by SDL_OpenAudioDevice()
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn unpause(self: AudioDeviceID) Error!void {
        try internal.checkResult(SDL_ResumeAudioDevice(self));
    }

    /// Use this function to query if an audio device is paused.
    ///
    /// Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    /// has to bind a stream before any audio will flow.
    ///
    /// Physical devices can not be paused or unpaused, only logical devices
    /// created through SDL_OpenAudioDevice() can be. Physical and invalid device
    /// IDs will report themselves as unpaused here.
    ///
    /// \param dev a device opened by SDL_OpenAudioDevice()
    /// \returns SDL_TRUE if device is valid and paused, SDL_FALSE otherwise.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn isPaused(self: AudioDeviceID) bool {
        return SDL_AudioDevicePaused(self).toZig();
    }

    /// Close a previously-opened audio device.
    ///
    /// The application should close open audio devices once they are no longer
    /// needed.
    ///
    /// This function may block briefly while pending audio data is played by the
    /// hardware, so that applications don't drop the last buffer of data they
    /// supplied if terminating immediately afterwards.
    ///
    /// \param devid an audio device id previously returned by
    ///              SDL_OpenAudioDevice()
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn close(self: AudioDeviceID) void {
        SDL_CloseAudioDevice(self);
    }

    /// Bind a list of audio streams to an audio device.
    ///
    /// Audio data will flow through any bound streams. For an output device, data
    /// for all bound streams will be mixed together and fed to the device. For a
    /// capture device, a copy of recorded data will be provided to each bound
    /// stream.
    ///
    /// Audio streams can only be bound to an open device. This operation is
    /// atomic--all streams bound in the same call will start processing at the
    /// same time, so they can stay in sync. Also: either all streams will be bound
    /// or none of them will be.
    ///
    /// It is an error to bind an already-bound stream; it must be explicitly
    /// unbound first.
    ///
    /// Binding a stream to a device will set its output format for output devices,
    /// and its input format for capture devices, so they match the device's
    /// settings. The caller is welcome to change the other end of the stream's
    /// format at any time.
    ///
    /// \param devid an audio device to bind a stream to.
    /// \param streams an array of audio streams to unbind.
    /// \param num_streams Number streams listed in the `streams` array.
    /// \returns 0 on success, -1 on error; call SDL_GetError() for more
    ///          information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn bindStreams(self: AudioDeviceID, streams: []*AudioStream) Error!void {
        try internal.checkResult(SDL_BindAudioStreams(self, streams.ptr, @intCast(streams.len)));
    }

    /// Bind a single audio stream to an audio device.
    ///
    /// This is a convenience function, equivalent to calling
    /// `SDL_BindAudioStreams(devid, &stream, 1)`.
    ///
    /// \param devid an audio device to bind a stream to.
    /// \param stream an audio stream to bind to a device.
    /// \returns 0 on success, -1 on error; call SDL_GetError() for more
    ///          information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn bindStream(self: AudioDeviceID, stream: *AudioStream) Error!void {
        try internal.checkResult(SDL_BindAudioStream(self, stream));
    }

    /// Set a callback that fires when data is about to be fed to an audio device.
    ///
    /// This is useful for accessing the final mix, perhaps for writing a
    /// visualizer or applying a final effect to the audio data before playback.
    ///
    /// The buffer is the final mix of all bound audio streams on an opened device;
    /// this callback will fire regularly for any device that is both opened and
    /// unpaused. If there is no new data to mix, either because no streams are
    /// bound to the device or all the streams are empty, this callback will still
    /// fire with the entire buffer set to silence.
    ///
    /// This callback is allowed to make changes to the data; the contents of the
    /// buffer after this call is what is ultimately passed along to the hardware.
    ///
    /// The callback is always provided the data in float format (values from -1.0f
    /// to 1.0f), but the number of channels or sample rate may be different than
    /// the format the app requested when opening the device; SDL might have had to
    /// manage a conversion behind the scenes, or the playback might have jumped to
    /// new physical hardware when a system default changed, etc. These details may
    /// change between calls. Accordingly, the size of the buffer might change
    /// between calls as well.
    ///
    /// This callback can run at any time, and from any thread; if you need to
    /// serialize access to your app's data, you should provide and use a mutex or
    /// other synchronization device.
    ///
    /// All of this to say: there are specific needs this callback can fulfill, but
    /// it is not the simplest interface. Apps should generally provide audio in
    /// their preferred format through an SDL_AudioStream and let SDL handle the
    /// difference.
    ///
    /// This function is extremely time-sensitive; the callback should do the least
    /// amount of work possible and return as quickly as it can. The longer the
    /// callback runs, the higher the risk of audio dropouts or other problems.
    ///
    /// This function will block until the audio device is in between iterations,
    /// so any existing callback that might be running will finish before this
    /// function sets the new callback and returns.
    ///
    /// Setting a NULL callback function disables any previously-set callback.
    ///
    /// \param devid The ID of an opened audio device.
    /// \param callback A callback function to be called. Can be NULL.
    /// \param userdata App-controlled pointer passed to callback. Can be NULL.
    /// \returns zero on success, -1 on error; call SDL_GetError() for more
    ///          information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setPostmixCallback(self: AudioDeviceID, callback: ?AudioPostmixFn, userdata: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetAudioPostmixCallback(self, callback, userdata));
    }

    extern fn SDL_OpenAudioDevice(devid: AudioDeviceID, spec: ?*const AudioSpec) AudioDeviceID;
    extern fn SDL_OpenAudioDeviceStream(devid: AudioDeviceID, spec: *const AudioSpec, callback: ?AudioStreamFn, userdata: ?*anyopaque) ?*AudioStream;
    extern fn SDL_GetAudioDeviceName(devid: AudioDeviceID) ?[*:0]u8;
    extern fn SDL_GetAudioDeviceFormat(devid: AudioDeviceID, spec: *AudioSpec, sample_frames: *c_int) c_int;
    extern fn SDL_PauseAudioDevice(dev: AudioDeviceID) c_int;
    extern fn SDL_ResumeAudioDevice(dev: AudioDeviceID) c_int;
    extern fn SDL_AudioDevicePaused(dev: AudioDeviceID) Bool;
    extern fn SDL_CloseAudioDevice(devid: AudioDeviceID) void;
    extern fn SDL_BindAudioStreams(devid: AudioDeviceID, streams: [*]*AudioStream, num_streams: c_int) c_int;
    extern fn SDL_BindAudioStream(devid: AudioDeviceID, stream: *AudioStream) c_int;
    extern fn SDL_SetAudioPostmixCallback(devid: AudioDeviceID, callback: AudioPostmixFn, userdata: ?*anyopaque) c_int;
};

/// SDL_AudioStream is an audio conversion interface.
///  - It can handle resampling data in chunks without generating
///    artifacts, when it doesn't have the complete buffer available.
///  - It can handle incoming data in any variable size.
///  - It can handle input/output format changes on the fly.
///  - You push data as you have it, and pull it when you need it
///  - It can also function as a basic audio data queue even if you
///    just have sound that needs to pass from one place to another.
///  - You can hook callbacks up to them when more data is added or
///    requested, to manage data on-the-fly.
///
pub const AudioStream = opaque {
    /// Create a new audio stream.
    ///
    /// \param src_spec The format details of the input audio
    /// \param dst_spec The format details of the output audio
    /// \returns a new audio stream on success, or NULL on failure.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn create(src_spec: *const AudioSpec, dst_spec: *const AudioSpec) Error!*AudioStream {
        return SDL_CreateAudioStream(src_spec, dst_spec) orelse internal.emitError();
    }

    /// Unbind a single audio stream from its audio device.
    ///
    /// This is a convenience function, equivalent to calling
    /// `SDL_UnbindAudioStreams(&stream, 1)`.
    ///
    /// \param stream an audio stream to unbind from a device.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn unbind(self: *AudioStream) void {
        SDL_UnbindAudioStream(self);
    }

    /// Query an audio stream for its currently-bound device.
    ///
    /// This reports the audio device that an audio stream is currently bound to.
    ///
    /// If not bound, or invalid, this returns zero, which is not a valid device
    /// ID.
    ///
    /// \param stream the audio stream to query.
    /// \returns The bound audio device, or 0 if not bound or invalid.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getDevice(self: *AudioStream) AudioDeviceID {
        return SDL_GetAudioStreamDevice(self);
    }

    /// Get the properties associated with an audio stream.
    ///
    /// \param stream the SDL_AudioStream to query
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *AudioStream) Error!PropertiesID {
        const props = SDL_GetAudioStreamProperties(self);
        try internal.assertResult(props != .invalid);
        return props;
    }

    /// Query the current format of an audio stream.
    ///
    /// \param stream the SDL_AudioStream to query.
    /// \param src_spec Where to store the input audio format; ignored if NULL.
    /// \param dst_spec Where to store the output audio format; ignored if NULL.
    /// \returns 0 on success, or -1 on error.
    ///
    /// \threadsafety It is safe to call this function from any thread, as it holds
    ///               a stream-specific mutex while running.
    ///
    pub fn getFormat(self: *AudioStream, src_spec: *AudioSpec, dst_spec: *AudioSpec) Error!void {
        try internal.checkResult(SDL_GetAudioStreamFormat(self, src_spec, dst_spec));
    }

    /// Change the input and output formats of an audio stream.
    ///
    /// Future calls to and SDL_GetAudioStreamAvailable and SDL_GetAudioStreamData
    /// will reflect the new format, and future calls to SDL_PutAudioStreamData
    /// must provide data in the new input formats.
    ///
    /// \param stream The stream the format is being changed
    /// \param src_spec The new format of the audio input; if NULL, it is not
    ///                 changed.
    /// \param dst_spec The new format of the audio output; if NULL, it is not
    ///                 changed.
    /// \returns 0 on success, or -1 on error.
    ///
    /// \threadsafety It is safe to call this function from any thread, as it holds
    ///               a stream-specific mutex while running.
    ///
    pub fn setFormat(self: *AudioStream, src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) Error!void {
        try internal.checkResult(SDL_SetAudioStreamFormat(self, src_spec, dst_spec));
    }

    /// Get the frequency ratio of an audio stream.
    ///
    /// \param stream the SDL_AudioStream to query.
    /// \returns the frequency ratio of the stream, or 0.0 on error
    ///
    /// \threadsafety It is safe to call this function from any thread, as it holds
    ///               a stream-specific mutex while running.
    ///
    pub fn getFrequencyRatio(self: *AudioStream) Error!f32 {
        const freq = SDL_GetAudioStreamFrequencyRatio(self);
        try internal.assertResult(freq != 0);
        return freq;
    }

    /// Change the frequency ratio of an audio stream.
    ///
    /// The frequency ratio is used to adjust the rate at which input data is
    /// consumed. Changing this effectively modifies the speed and pitch of the
    /// audio. A value greater than 1.0 will play the audio faster, and at a higher
    /// pitch. A value less than 1.0 will play the audio slower, and at a lower
    /// pitch.
    ///
    /// This is applied during SDL_GetAudioStreamData, and can be continuously
    /// changed to create various effects.
    ///
    /// \param stream The stream the frequency ratio is being changed
    /// \param ratio The frequency ratio. 1.0 is normal speed. Must be between 0.01
    ///              and 100.
    /// \returns 0 on success, or -1 on error.
    ///
    /// \threadsafety It is safe to call this function from any thread, as it holds
    ///               a stream-specific mutex while running.
    ///
    pub fn setFrequencyRatio(self: *AudioStream, ratio: f32) Error!void {
        try internal.checkResult(SDL_SetAudioStreamFrequencyRatio(self, ratio));
    }

    /// Add data to be converted/resampled to the stream.
    ///
    /// This data must match the format/channels/samplerate specified in the latest
    /// call to SDL_SetAudioStreamFormat, or the format specified when creating the
    /// stream if it hasn't been changed.
    ///
    /// Note that this call simply queues unconverted data for later. This is
    /// different than SDL2, where data was converted during the Put call and the
    /// Get call would just dequeue the previously-converted data.
    ///
    /// \param stream The stream the audio data is being added to
    /// \param buf A pointer to the audio data to add
    /// \param len The number of bytes to write to the stream
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread, but if the
    ///               stream has a callback set, the caller might need to manage
    ///               extra locking.
    ///
    pub fn putData(self: *AudioStream, buf: *const anyopaque, len: c_int) Error!void {
        try internal.checkResult(SDL_PutAudioStreamData(self, buf, len));
    }

    /// Get converted/resampled data from the stream.
    ///
    /// The input/output data format/channels/samplerate is specified when creating
    /// the stream, and can be changed after creation by calling
    /// SDL_SetAudioStreamFormat.
    ///
    /// Note that any conversion and resampling necessary is done during this call,
    /// and SDL_PutAudioStreamData simply queues unconverted data for later. This
    /// is different than SDL2, where that work was done while inputting new data
    /// to the stream and requesting the output just copied the converted data.
    ///
    /// \param stream The stream the audio is being requested from
    /// \param buf A buffer to fill with audio data
    /// \param len The maximum number of bytes to fill
    /// \returns the number of bytes read from the stream, or -1 on error
    ///
    /// \threadsafety It is safe to call this function from any thread, but if the
    ///               stream has a callback set, the caller might need to manage
    ///               extra locking.
    ///
    pub fn getData(self: *AudioStream, buf: *anyopaque, len: c_int) Error!void {
        try internal.checkResult(SDL_GetAudioStreamData(self, buf, len));
    }

    /// Get the number of converted/resampled bytes available.
    ///
    /// The stream may be buffering data behind the scenes until it has enough to
    /// resample correctly, so this number might be lower than what you expect, or
    /// even be zero. Add more data or flush the stream if you need the data now.
    ///
    /// If the stream has so much data that it would overflow an int, the return
    /// value is clamped to a maximum value, but no queued data is lost; if there
    /// are gigabytes of data queued, the app might need to read some of it with
    /// SDL_GetAudioStreamData before this function's return value is no longer
    /// clamped.
    ///
    /// \param stream The audio stream to query
    /// \returns the number of converted/resampled bytes available.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getAvailable(self: *AudioStream) c_int {
        return SDL_GetAudioStreamAvailable(self);
    }

    /// Get the number of bytes currently queued.
    ///
    /// Note that audio streams can change their input format at any time, even if
    /// there is still data queued in a different format, so the returned byte
    /// count will not necessarily match the number of _sample frames_ available.
    /// Users of this API should be aware of format changes they make when feeding
    /// a stream and plan accordingly.
    ///
    /// Queued data is not converted until it is consumed by
    /// SDL_GetAudioStreamData, so this value should be representative of the exact
    /// data that was put into the stream.
    ///
    /// If the stream has so much data that it would overflow an int, the return
    /// value is clamped to a maximum value, but no queued data is lost; if there
    /// are gigabytes of data queued, the app might need to read some of it with
    /// SDL_GetAudioStreamData before this function's return value is no longer
    /// clamped.
    ///
    /// \param stream The audio stream to query
    /// \returns the number of bytes queued.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getQueued(self: *AudioStream) c_int {
        return SDL_GetAudioStreamQueued(self);
    }

    /// Tell the stream that you're done sending data, and anything being buffered
    /// should be converted/resampled and made available immediately.
    ///
    /// It is legal to add more data to a stream after flushing, but there will be
    /// audio gaps in the output. Generally this is intended to signal the end of
    /// input, so the complete output becomes available.
    ///
    /// \param stream The audio stream to flush
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn flush(self: *AudioStream) Error!void {
        try internal.checkResult(SDL_FlushAudioStream(self));
    }

    /// Clear any pending data in the stream without converting it
    ///
    /// \param stream The audio stream to clear
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn clear(self: *AudioStream) Error!void {
        try internal.checkResult(SDL_ClearAudioStream(self));
    }

    /// Lock an audio stream for serialized access.
    ///
    /// Each SDL_AudioStream has an internal mutex it uses to protect its data
    /// structures from threading conflicts. This function allows an app to lock
    /// that mutex, which could be useful if registering callbacks on this stream.
    ///
    /// One does not need to lock a stream to use in it most cases, as the stream
    /// manages this lock internally. However, this lock is held during callbacks,
    /// which may run from arbitrary threads at any time, so if an app needs to
    /// protect shared data during those callbacks, locking the stream guarantees
    /// that the callback is not running while the lock is held.
    ///
    /// As this is just a wrapper over SDL_LockMutex for an internal lock, it has
    /// all the same attributes (recursive locks are allowed, etc).
    ///
    /// \param stream The audio stream to lock.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn lock(self: *AudioStream) Error!void {
        try internal.checkResult(SDL_LockAudioStream(self));
    }

    /// Unlock an audio stream for serialized access.
    ///
    /// This unlocks an audio stream after a call to SDL_LockAudioStream.
    ///
    /// \param stream The audio stream to unlock.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety You should only call this from the same thread that
    ///               previously called SDL_LockAudioStream.
    ///
    pub fn unlock(self: *AudioStream) Error!void {
        try internal.checkResult(SDL_UnlockAudioStream(self));
    }

    /// Set a callback that runs when data is requested from an audio stream.
    ///
    /// This callback is called _before_ data is obtained from the stream, giving
    /// the callback the chance to add more on-demand.
    ///
    /// The callback can (optionally) call SDL_PutAudioStreamData() to add more
    /// audio to the stream during this call; if needed, the request that triggered
    /// this callback will obtain the new data immediately.
    ///
    /// The callback's `approx_request` argument is roughly how many bytes of
    /// _unconverted_ data (in the stream's input format) is needed by the caller,
    /// although this may overestimate a little for safety. This takes into account
    /// how much is already in the stream and only asks for any extra necessary to
    /// resolve the request, which means the callback may be asked for zero bytes,
    /// and a different amount on each call.
    ///
    /// The callback is not required to supply exact amounts; it is allowed to
    /// supply too much or too little or none at all. The caller will get what's
    /// available, up to the amount they requested, regardless of this callback's
    /// outcome.
    ///
    /// Clearing or flushing an audio stream does not call this callback.
    ///
    /// This function obtains the stream's lock, which means any existing callback
    /// (get or put) in progress will finish running before setting the new
    /// callback.
    ///
    /// Setting a NULL function turns off the callback.
    ///
    /// \param stream the audio stream to set the new callback on.
    /// \param callback the new callback function to call when data is added to the
    ///                 stream.
    /// \param userdata an opaque pointer provided to the callback for its own
    ///                 personal use.
    /// \returns 0 on success, -1 on error. This only fails if `stream` is NULL.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setGetCallback(self: *AudioStream, callback: ?AudioStreamFn, userdata: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetAudioStreamGetCallback(self, callback, userdata));
    }

    /// Set a callback that runs when data is added to an audio stream.
    ///
    /// This callback is called _after_ the data is added to the stream, giving the
    /// callback the chance to obtain it immediately.
    ///
    /// The callback can (optionally) call SDL_GetAudioStreamData() to obtain audio
    /// from the stream during this call.
    ///
    /// The callback's `approx_request` argument is how many bytes of _converted_
    /// data (in the stream's output format) was provided by the caller, although
    /// this may underestimate a little for safety. This value might be less than
    /// what is currently available in the stream, if data was already there, and
    /// might be less than the caller provided if the stream needs to keep a buffer
    /// to aid in resampling. Which means the callback may be provided with zero
    /// bytes, and a different amount on each call.
    ///
    /// The callback may call SDL_GetAudioStreamAvailable to see the total amount
    /// currently available to read from the stream, instead of the total provided
    /// by the current call.
    ///
    /// The callback is not required to obtain all data. It is allowed to read less
    /// or none at all. Anything not read now simply remains in the stream for
    /// later access.
    ///
    /// Clearing or flushing an audio stream does not call this callback.
    ///
    /// This function obtains the stream's lock, which means any existing callback
    /// (get or put) in progress will finish running before setting the new
    /// callback.
    ///
    /// Setting a NULL function turns off the callback.
    ///
    /// \param stream the audio stream to set the new callback on.
    /// \param callback the new callback function to call when data is added to the
    ///                 stream.
    /// \param userdata an opaque pointer provided to the callback for its own
    ///                 personal use.
    /// \returns 0 on success, -1 on error. This only fails if `stream` is NULL.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setPutCallback(self: *AudioStream, callback: ?AudioStreamFn, userdata: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetAudioStreamPutCallback(self, callback, userdata));
    }

    /// Free an audio stream
    ///
    /// \param stream The audio stream to free
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn destroy(self: *AudioStream) void {
        SDL_DestroyAudioStream(self);
    }

    extern fn SDL_CreateAudioStream(src_spec: *const AudioSpec, dst_spec: *const AudioSpec) ?*AudioStream;
    extern fn SDL_UnbindAudioStream(stream: *AudioStream) void;
    extern fn SDL_GetAudioStreamDevice(stream: *AudioStream) AudioDeviceID;
    extern fn SDL_GetAudioStreamProperties(stream: *AudioStream) PropertiesID;
    extern fn SDL_GetAudioStreamFormat(stream: *AudioStream, src_spec: *AudioSpec, dst_spec: *AudioSpec) c_int;
    extern fn SDL_SetAudioStreamFormat(stream: *AudioStream, src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) c_int;
    extern fn SDL_GetAudioStreamFrequencyRatio(stream: *AudioStream) f32;
    extern fn SDL_SetAudioStreamFrequencyRatio(stream: *AudioStream, ratio: f32) c_int;
    extern fn SDL_PutAudioStreamData(stream: *AudioStream, buf: *const anyopaque, len: c_int) c_int;
    extern fn SDL_GetAudioStreamData(stream: *AudioStream, buf: *anyopaque, len: c_int) c_int;
    extern fn SDL_GetAudioStreamAvailable(stream: *AudioStream) c_int;
    extern fn SDL_GetAudioStreamQueued(stream: *AudioStream) c_int;
    extern fn SDL_FlushAudioStream(stream: *AudioStream) c_int;
    extern fn SDL_ClearAudioStream(stream: *AudioStream) c_int;
    extern fn SDL_LockAudioStream(stream: *AudioStream) c_int;
    extern fn SDL_UnlockAudioStream(stream: *AudioStream) c_int;
    extern fn SDL_SetAudioStreamGetCallback(stream: *AudioStream, callback: ?AudioStreamFn, userdata: ?*anyopaque) c_int;
    extern fn SDL_SetAudioStreamPutCallback(stream: *AudioStream, callback: ?AudioStreamFn, userdata: ?*anyopaque) c_int;
    extern fn SDL_DestroyAudioStream(stream: *AudioStream) void;
};

/// Use this function to get the number of built-in audio drivers.
///
/// This function returns a hardcoded number. This never returns a negative
/// value; if there are no drivers compiled into this build of SDL, this
/// function returns zero. The presence of a driver in this list does not mean
/// it will function, it just means SDL is capable of interacting with that
/// interface. For example, a build of SDL might have esound support, but if
/// there's no esound server available, SDL's esound driver would fail if used.
///
/// By default, SDL tries all drivers, in its preferred order, until one is
/// found to be usable.
///
/// \returns the number of built-in audio drivers.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn getNumAudioDrivers() c_int {
    return SDL_GetNumAudioDrivers();
}

/// Use this function to get the name of a built in audio driver.
///
/// The list of audio drivers is given in the order that they are normally
/// initialized by default; the drivers that seem more reasonable to choose
/// first (as far as the SDL developers believe) are earlier in the list.
///
/// The names of drivers are all simple, low-ASCII identifiers, like "alsa",
/// "coreaudio" or "xaudio2". These never have Unicode characters, and are not
/// meant to be proper names.
///
/// \param index the index of the audio driver; the value ranges from 0 to
///              SDL_GetNumAudioDrivers() - 1
/// \returns the name of the audio driver at the requested index, or NULL if an
///          invalid index was specified.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn getAudioDriver(index: c_int) Error![*:0]const u8 {
    return SDL_GetAudioDriver(index) orelse internal.emitError();
}

/// Get the name of the current audio driver.
///
/// The returned string points to internal static memory and thus never becomes
/// invalid, even if you quit the audio subsystem and initialize a new driver
/// (although such a case would return a different static string from another
/// call to this function, of course). As such, you should not modify or free
/// the returned string.
///
/// \returns the name of the current audio driver or NULL if no driver has been
///          initialized.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn getCurrentAudioDriver() ?[*:0]const u8 {
    return SDL_GetCurrentAudioDriver();
}

/// Get a list of currently-connected audio output devices.
///
/// This returns of list of available devices that play sound, perhaps to
/// speakers or headphones ("output" devices). If you want devices that record
/// audio, like a microphone ("capture" devices), use
/// SDL_GetAudioCaptureDevices() instead.
///
/// This only returns a list of physical devices; it will not have any device
/// IDs returned by SDL_OpenAudioDevice().
///
/// \param count a pointer filled in with the number of devices returned
/// \returns a 0 terminated array of device instance IDs which should be freed
///          with SDL_free(), or NULL on error; call SDL_GetError() for more
///          details.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn getAudioOutputDevices() Error![:.invalid]AudioDeviceID {
    var len: c_int = 0;

    if (SDL_GetAudioOutputDevices(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

/// Get a list of currently-connected audio capture devices.
///
/// This returns of list of available devices that record audio, like a
/// microphone ("capture" devices). If you want devices that play sound,
/// perhaps to speakers or headphones ("output" devices), use
/// SDL_GetAudioOutputDevices() instead.
///
/// This only returns a list of physical devices; it will not have any device
/// IDs returned by SDL_OpenAudioDevice().
///
/// \param count a pointer filled in with the number of devices returned
/// \returns a 0 terminated array of device instance IDs which should be freed
///          with SDL_free(), or NULL on error; call SDL_GetError() for more
///          details.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn getAudioCaptureDevices() Error![:.invalid]AudioDeviceID {
    var len: c_int = 0;

    if (SDL_GetAudioCaptureDevices(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

/// Unbind a list of audio streams from their audio devices.
///
/// The streams being unbound do not all have to be on the same device. All
/// streams on the same device will be unbound atomically (data will stop
/// flowing through them all unbound streams on the same device at the same
/// time).
///
/// Unbinding a stream that isn't bound to a device is a legal no-op.
///
/// \param streams an array of audio streams to unbind.
/// \param num_streams Number streams listed in the `streams` array.
///
/// \threadsafety It is safe to call this function from any thread.
///
pub fn unbindAudioStreams(streams: []*AudioStream) void {
    SDL_UnbindAudioStreams(streams.ptr, @intCast(streams.len));
}

extern fn SDL_GetNumAudioDrivers() c_int;
extern fn SDL_GetAudioDriver(index: c_int) ?[*:0]const u8;
extern fn SDL_GetCurrentAudioDriver() ?[*:0]const u8;
extern fn SDL_GetAudioOutputDevices(count: *c_int) ?[*]AudioDeviceID;
extern fn SDL_GetAudioCaptureDevices(count: *c_int) ?[*]AudioDeviceID;
extern fn SDL_UnbindAudioStreams(streams: [*]*AudioStream, num_streams: c_int) void;

// extern fn SDL_MixAudioFormat(dst: [*]u8, src: [*]const u8, format: AudioFormat, len: u32, volume: c_int) c_int;
// extern fn SDL_ConvertAudioSamples(src_spec: ?*const AudioSpec, src_data: [*]const u8, src_len: c_int, dst_spec: ?*const AudioSpec, dst_data: *?[*]u8, dst_len: *c_int) c_int;
// extern fn SDL_GetSilenceValueForFormat(format: AudioFormat) c_int;

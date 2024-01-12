const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const PixelFormat = @import("pixels.zig").PixelFormat;

pub const VideoCaptureSpec = extern struct {
    format: PixelFormat,
    width: c_int,
    height: c_int,
};

///  SDL Video Capture Status
///
///  Change states but calling the function in this order:
///
///  SDL_OpenVideoCapture()
///  SDL_SetVideoCaptureSpec()  -> Init
///  SDL_StartVideoCapture()    -> Playing
///  SDL_StopVideoCapture()     -> Stopped
///  SDL_CloseVideoCapture()
///
pub const VideoCaptureStatus = enum(c_int) {
    fail = -1,
    init = 0,
    stopped,
    playing,
};

pub const VideoCaptureFrame = extern struct {
    timestamp_ns: u64,
    num_planes: c_int,
    data: [3][*]u8,
    pitch: [3]c_int,
    internal: ?*anyopaque,
};

/// This is a unique ID for a video capture device for the time it is connected to the system,
/// and is never reused for the lifetime of the application. If the device is
/// disconnected and reconnected, it will get a new ID.
///
/// The ID value starts at 1 and increments from there. The value 0 is an invalid ID.
///
pub const VideoCaptureDeviceID = enum(u32) {
    invalid = 0,
    _,

    /// Get device name
    ///
    /// \param instance_id the video capture device instance ID
    /// \returns device name, shouldn't be freed
    ///
    pub fn getName(self: VideoCaptureDeviceID) Error![*:0]const u8 {
        return SDL_GetVideoCaptureDeviceName(self) orelse internal.emitError();
    }

    extern fn SDL_GetVideoCaptureDeviceName(instance_id: VideoCaptureDeviceID) ?[*:0]const u8;
};

pub const VideoCaptureDevice = opaque {
    /// Open a Video Capture device
    ///
    /// \param instance_id the video capture device instance ID
    /// \returns device, or NULL on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn open(instance_id: VideoCaptureDeviceID) Error!*VideoCaptureDevice {
        return SDL_OpenVideoCapture(instance_id) orelse internal.emitError();
    }

    /// Open a Video Capture device and set specification
    ///
    /// \param instance_id the video capture device instance ID
    /// \param desired desired video capture spec
    /// \param obtained obtained video capture spec
    /// \param allowed_changes allow changes or not
    /// \returns device, or NULL on failure; call SDL_GetError() for more
    ///          information.
    ///
    pub fn openWithSpec(instance_id: VideoCaptureDeviceID, desired: *const VideoCaptureSpec, obtained: *VideoCaptureSpec, allowed_changes: bool) Error!*VideoCaptureDevice {
        return SDL_OpenVideoCaptureWithSpec(instance_id, desired, obtained, @intFromBool(allowed_changes)) orelse internal.emitError();
    }

    /// Set specification
    ///
    /// \param device opened video capture device
    /// \param desired desired video capture spec
    /// \param obtained obtained video capture spec
    /// \param allowed_changes allow changes or not
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setSpec(self: *VideoCaptureDevice, desired: *const VideoCaptureSpec, obtained: *VideoCaptureSpec, allowed_changes: bool) Error!void {
        try internal.checkResult(SDL_SetVideoCaptureSpec(self, desired, obtained, @intFromEnum(allowed_changes)));
    }

    /// Get the obtained video capture spec
    ///
    /// \param device opened video capture device
    /// \param spec The SDL_VideoCaptureSpec to be initialized by this function.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getSpec(self: *VideoCaptureDevice, spec: *VideoCaptureSpec) Error!void {
        try internal.checkResult(SDL_GetVideoCaptureSpec(self, spec));
    }

    /// Get frame format of video capture device.
    ///
    /// The value can be used to fill SDL_VideoCaptureSpec structure.
    ///
    /// \param device opened video capture device
    /// \param index format between 0 and num -1
    /// \param format pointer output format (SDL_PixelFormatEnum)
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getFormat(self: *VideoCaptureDevice, index: c_int, format: *PixelFormat) Error!void {
        try internal.checkResult(SDL_GetVideoCaptureFormat(self, index, format));
    }

    /// Number of available formats for the device
    ///
    /// \param device opened video capture device
    /// \returns number of formats or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getNumFormats(self: *VideoCaptureDevice) Error!c_int {
        const num = SDL_GetNumVideoCaptureFormats(self);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get frame sizes of the device and the specified input format.
    ///
    /// The value can be used to fill SDL_VideoCaptureSpec structure.
    ///
    /// \param device opened video capture device
    /// \param format a format that can be used by the device (SDL_PixelFormatEnum)
    /// \param index framesize between 0 and num -1
    /// \param width output width
    /// \param height output height
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getFrameSize(self: *VideoCaptureDevice, format: PixelFormat, index: c_int, width: *c_int, height: *c_int) Error!void {
        try internal.checkResult(SDL_GetVideoCaptureFrameSize(self, format, index, width, height));
    }

    /// Number of different framesizes available for the device and pixel format.
    ///
    /// \param device opened video capture device
    /// \param format frame pixel format (SDL_PixelFormatEnum)
    /// \returns number of framesizes or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getNumFrameSizes(self: *VideoCaptureDevice, format: PixelFormat) Error!c_int {
        const num = SDL_GetNumVideoCaptureFrameSizes(self, format);
        try internal.assertResult(num >= 0);
        return num;
    }

    /// Get video capture status
    ///
    /// \param device opened video capture device
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getStatus(self: *VideoCaptureDevice) VideoCaptureStatus {
        const status = SDL_GetVideoCaptureStatus(self);
        try internal.assertResult(status != .fail);
        return status;
    }

    /// Start video capture
    ///
    /// \param device opened video capture device
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn start(self: *VideoCaptureDevice) Error!void {
        try internal.checkResult(SDL_StartVideoCapture(self));
    }

    /// Acquire a frame.
    ///
    /// The frame is a memory pointer to the image data, whose size and format are
    /// given by the the obtained spec.
    ///
    /// Non blocking API. If there is a frame available, frame->num_planes is non
    /// 0. If frame->num_planes is 0 and returned code is 0, there is no frame at
    /// that time.
    ///
    /// After used, the frame should be released with SDL_ReleaseVideoCaptureFrame
    ///
    /// \param device opened video capture device
    /// \param frame pointer to get the frame
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn acquireFrame(self: *VideoCaptureDevice, frame: *VideoCaptureFrame) Error!void {
        try internal.checkResult(SDL_AcquireVideoCaptureFrame(self, frame));
    }

    /// Release a frame.
    ///
    /// Let the back-end re-use the internal buffer for video capture.
    ///
    /// All acquired frames should be released before closing the device.
    ///
    /// \param device opened video capture device
    /// \param frame frame pointer.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn releaseFrame(self: *VideoCaptureDevice, frame: *VideoCaptureFrame) Error!void {
        try internal.checkResult(SDL_ReleaseVideoCaptureFrame(self, frame));
    }

    /// Stop Video Capture
    ///
    /// \param device opened video capture device
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn stop(self: *VideoCaptureDevice) Error!void {
        try internal.checkResult(SDL_StopVideoCapture(self));
    }

    /// Use this function to shut down video_capture processing and close the
    /// video_capture device.
    ///
    /// \param device opened video capture device
    ///
    pub fn close(self: *VideoCaptureDevice) void {
        SDL_CloseVideoCapture(self);
    }

    extern fn SDL_OpenVideoCapture(instance_id: VideoCaptureDeviceID) ?*VideoCaptureDevice;
    extern fn SDL_OpenVideoCaptureWithSpec(instance_id: VideoCaptureDeviceID, desired: *const VideoCaptureSpec, obtained: *VideoCaptureSpec, allowed_changes: c_int) ?*VideoCaptureDevice;
    extern fn SDL_SetVideoCaptureSpec(device: *VideoCaptureDevice, desired: *const VideoCaptureSpec, obtained: *VideoCaptureSpec, allowed_changes: c_int) c_int;
    extern fn SDL_GetVideoCaptureSpec(device: *VideoCaptureDevice, spec: *VideoCaptureSpec) c_int;
    extern fn SDL_GetVideoCaptureFormat(device: *VideoCaptureDevice, index: c_int, format: *PixelFormat) c_int;
    extern fn SDL_GetNumVideoCaptureFormats(device: *VideoCaptureDevice) c_int;
    extern fn SDL_GetVideoCaptureFrameSize(device: *VideoCaptureDevice, format: PixelFormat, index: c_int, width: *c_int, height: *c_int) c_int;
    extern fn SDL_GetNumVideoCaptureFrameSizes(device: *VideoCaptureDevice, format: PixelFormat) c_int;
    extern fn SDL_GetVideoCaptureStatus(device: *VideoCaptureDevice) VideoCaptureStatus;
    extern fn SDL_StartVideoCapture(device: *VideoCaptureDevice) c_int;
    extern fn SDL_AcquireVideoCaptureFrame(device: *VideoCaptureDevice, frame: *VideoCaptureFrame) c_int;
    extern fn SDL_ReleaseVideoCaptureFrame(device: *VideoCaptureDevice, frame: *VideoCaptureFrame) c_int;
    extern fn SDL_StopVideoCapture(device: *VideoCaptureDevice) c_int;
    extern fn SDL_CloseVideoCapture(device: *VideoCaptureDevice) void;
};

/// Get a list of currently connected video capture devices.
///
/// \param count a pointer filled in with the number of video capture devices
/// \returns a 0 terminated array of video capture instance IDs which should be
///          freed with SDL_free(), or NULL on error; call SDL_GetError() for
///          more details.
///
pub fn getVideoCaptureDevices() Error![:.invalid]VideoCaptureDeviceID {
    var len: c_int = 0;

    if (SDL_GetVideoCaptureDevices(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

extern fn SDL_GetVideoCaptureDevices(count: *c_int) ?[*]VideoCaptureDeviceID;

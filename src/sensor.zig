const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const PropertiesID = @import("properties.zig").PropertiesID;

/// Accelerometer sensor
///
/// The accelerometer returns the current acceleration in SI meters per
/// second squared. This measurement includes the force of gravity, so
/// a device at rest will have an value of SDL_STANDARD_GRAVITY away
/// from the center of the earth, which is a positive Y value.
///
/// values[0]: Acceleration on the x axis
/// values[1]: Acceleration on the y axis
/// values[2]: Acceleration on the z axis
///
/// For phones and tablets held in natural orientation and game controllers held in front of you, the axes are defined as follows:
/// -X ... +X : left ... right
/// -Y ... +Y : bottom ... top
/// -Z ... +Z : farther ... closer
///
/// The axis data is not changed when the device is rotated.
///
/// Gyroscope sensor
///
/// The gyroscope returns the current rate of rotation in radians per second.
/// The rotation is positive in the counter-clockwise direction. That is,
/// an observer looking from a positive location on one of the axes would
/// see positive rotation on that axis when it appeared to be rotating
/// counter-clockwise.
///
/// values[0]: Angular speed around the x axis (pitch)
/// values[1]: Angular speed around the y axis (yaw)
/// values[2]: Angular speed around the z axis (roll)
///
/// For phones and tablets held in natural orientation and game controllers held in front of you, the axes are defined as follows:
/// -X ... +X : left ... right
/// -Y ... +Y : bottom ... top
/// -Z ... +Z : farther ... closer
///
/// The axis data is not changed when the device is rotated.
/// The different sensors defined by SDL
///
/// Additional sensors may be available, using platform dependent semantics.
///
/// Hare are the additional Android sensors:
/// https://developer.android.com/reference/android/hardware/SensorEvent.html#values
///
pub const SensorType = enum(c_int) {
    /// Returned for an invalid sensor
    invalid = -1,
    /// Unknown sensor type
    unknown,
    /// Accelerometer
    accel,
    /// Gyroscope
    gyro,
    /// Accelerometer for left Joy-Con controller and Wii nunchuk
    accel_l,
    /// Gyroscope for left Joy-Con controller
    gyro_l,
    /// Accelerometer for right Joy-Con controller
    accel_r,
    /// Gyroscope for right Joy-Con controller
    gyro_r,
};

pub const standard_gravity = 9.80665;

/// This is a unique ID for a sensor for the time it is connected to the system,
/// and is never reused for the lifetime of the application.
///
/// The ID value starts at 1 and increments from there. The value 0 is an invalid ID.
///
pub const SensorID = enum(u32) {
    invalid = 0,
    _,

    /// Return the SDL_Sensor associated with an instance ID.
    ///
    /// \param instance_id the sensor instance ID
    /// \returns an SDL_Sensor object.
    ///
    pub fn getSensor(self: SensorID) Error!*Sensor {
        return SDL_GetSensorFromInstanceID(self) orelse internal.emitError();
    }

    /// Get the implementation dependent name of a sensor.
    ///
    /// \param instance_id the sensor instance ID
    /// \returns the sensor name, or NULL if `instance_id` is not valid
    ///
    pub fn getName(self: SensorID) Error![*:0]const u8 {
        return SDL_GetSensorInstanceName(self) orelse internal.emitError();
    }

    /// Get the type of a sensor.
    ///
    /// \param instance_id the sensor instance ID
    /// \returns the SDL_SensorType, or `SDL_SENSOR_INVALID` if `instance_id` is
    ///          not valid
    ///
    pub fn getType(self: SensorID) Error!SensorType {
        const ty = SDL_GetSensorInstanceType(self);
        try internal.assertResult(ty != .invalid);
        return ty;
    }

    /// Get the platform dependent type of a sensor.
    ///
    /// \param instance_id the sensor instance ID
    /// \returns the sensor platform dependent type, or -1 if `instance_id` is not
    ///          valid
    ///
    pub fn getNonPortableType(self: SensorID) Error!c_int {
        const ty = SDL_GetSensorInstanceNonPortableType(self);
        try internal.assertResult(ty >= 0);
        return ty;
    }

    extern fn SDL_GetSensorFromInstanceID(instance_id: SensorID) ?*Sensor;
    extern fn SDL_GetSensorInstanceName(instance_id: SensorID) ?[*:0]const u8;
    extern fn SDL_GetSensorInstanceType(instance_id: SensorID) SensorType;
    extern fn SDL_GetSensorInstanceNonPortableType(instance_id: SensorID) c_int;
};

pub const Sensor = opaque {
    /// Open a sensor for use.
    ///
    /// \param instance_id the sensor instance ID
    /// \returns an SDL_Sensor sensor object, or NULL if an error occurred.
    ///
    pub fn open(id: SensorID) Error!*Sensor {
        return SDL_OpenSensor(id) orelse internal.emitError();
    }

    /// Get the properties associated with a sensor.
    ///
    /// \param sensor The SDL_Sensor object
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *Sensor) Error!PropertiesID {
        const props = SDL_GetSensorProperties(self);
        try internal.assertResult(props != .invalid);
        return props;
    }

    /// Get the implementation dependent name of a sensor
    ///
    /// \param sensor The SDL_Sensor object
    /// \returns the sensor name, or NULL if `sensor` is NULL.
    ///
    pub fn getName(self: *Sensor) [*:0]const u8 {
        return SDL_GetSensorName(self);
    }

    /// Get the type of a sensor.
    ///
    /// \param sensor The SDL_Sensor object to inspect
    /// \returns the SDL_SensorType type, or `SDL_SENSOR_INVALID` if `sensor` is
    ///          NULL.
    ///
    pub fn getType(self: *Sensor) SensorType {
        return SDL_GetSensorType(self);
    }

    /// Get the platform dependent type of a sensor.
    ///
    /// \param sensor The SDL_Sensor object to inspect
    /// \returns the sensor platform dependent type, or -1 if `sensor` is NULL.
    ///
    pub fn getNonPortableType(self: *Sensor) c_int {
        return SDL_GetSensorNonPortableType(self);
    }

    /// Get the instance ID of a sensor.
    ///
    /// \param sensor The SDL_Sensor object to inspect
    /// \returns the sensor instance ID, or 0 if `sensor` is NULL.
    ///
    pub fn getID(self: *Sensor) SensorID {
        return SDL_GetSensorInstanceID(self);
    }

    /// Get the current state of an opened sensor.
    ///
    /// The number of values and interpretation of the data is sensor dependent.
    ///
    /// \param sensor The SDL_Sensor object to query
    /// \param data A pointer filled with the current sensor state
    /// \param num_values The number of values to write to data
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getData(self: *Sensor, data: []f32) Error!void {
        try internal.checkResult(SDL_GetSensorData(self, data.ptr, @intCast(data.len)));
    }

    /// Close a sensor previously opened with SDL_OpenSensor().
    ///
    /// \param sensor The SDL_Sensor object to close
    ///
    pub fn close(self: *Sensor) void {
        SDL_CloseSensor(self);
    }

    extern fn SDL_OpenSensor(instance_id: SensorID) ?*Sensor;
    extern fn SDL_GetSensorProperties(sensor: *Sensor) PropertiesID;
    extern fn SDL_GetSensorName(sensor: *Sensor) [*:0]const u8;
    extern fn SDL_GetSensorType(sensor: *Sensor) SensorType;
    extern fn SDL_GetSensorNonPortableType(sensor: *Sensor) c_int;
    extern fn SDL_GetSensorInstanceID(sensor: *Sensor) SensorID;
    extern fn SDL_GetSensorData(sensor: *Sensor, data: [*]f32, num_values: c_int) c_int;
    extern fn SDL_CloseSensor(sensor: *Sensor) void;
};

/// Get a list of currently connected sensors.
///
/// \param count a pointer filled in with the number of sensors returned
/// \returns a 0 terminated array of sensor instance IDs which should be freed
///          with SDL_free(), or NULL on error; call SDL_GetError() for more
///          details.
///
pub fn getSensors() Error![:.invalid]SensorID {
    var len: c_int = 0;

    if (SDL_GetSensors(&len)) |arr|
        return arr[0..@intCast(len) :.invalid]
    else
        return internal.emitError();
}

extern fn SDL_GetSensors(count: *c_int) [*]SensorID;

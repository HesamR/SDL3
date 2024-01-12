const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

pub const PropertyType = enum(c_uint) {
    invalid,
    pointer,
    string,
    number,
    float,
    boolean,
};

pub const CleanupFn = *const fn (userdata: ?*anyopaque, value: ?*anyopaque) callconv(.C) void;
pub const EnumeratePropertiesFn = *const fn (userdata: ?*anyopaque, props: PropertiesID, name: [*:0]const u8) void;

pub const PropertiesID = enum(u32) {
    invalid = 0,
    _,

    /// Get the global SDL properties
    ///
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getGlobal() Error!PropertiesID {
        const ret = SDL_GetGlobalProperties();
        try internal.assertResult(ret != .invalid);
        return ret;
    }

    /// Create a set of properties
    ///
    /// All properties are automatically destroyed when SDL_Quit() is called.
    ///
    /// \returns an ID for a new set of properties, or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn create() Error!PropertiesID {
        const ret = SDL_CreateProperties();
        try internal.assertResult(ret != .invalid);
        return ret;
    }

    /// Lock a set of properties
    ///
    /// Obtain a multi-threaded lock for these properties. Other threads will wait
    /// while trying to lock these properties until they are unlocked. Properties
    /// must be unlocked before they are destroyed.
    ///
    /// The lock is automatically taken when setting individual properties, this
    /// function is only needed when you want to set several properties atomically
    /// or want to guarantee that properties being queried aren't freed in another
    /// thread.
    ///
    /// \param props the properties to lock
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn lock(self: PropertiesID) Error!void {
        try internal.checkResult(SDL_LockProperties(self));
    }

    /// Unlock a set of properties
    ///
    /// \param props the properties to unlock
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn unlock(self: PropertiesID) void {
        SDL_UnlockProperties(self);
    }

    /// Set a property on a set of properties with a cleanup function that is
    /// called when the property is deleted
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property, or NULL to delete the property
    /// \param cleanup the function to call when this property is deleted, or NULL
    ///                if no cleanup is necessary
    /// \param userdata a pointer that is passed to the cleanup function
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    ///
    pub fn setWithCleanup(self: PropertiesID, name: [*:0]const u8, value: ?*anyopaque, cleanup: ?CleanupFn, userdata: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetPropertyWithCleanup(self, name, value, cleanup, userdata));
    }

    /// Set a property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property, or NULL to delete the property
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn set(self: PropertiesID, name: [*:0]const u8, value: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_SetProperty(self, name, value));
    }

    /// Set a string property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property, or NULL to delete the property
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setString(self: PropertiesID, name: [*:0]const u8, value: ?[*:0]const u8) Error!void {
        try internal.checkResult(SDL_SetStringProperty(self, name, value));
    }

    /// Set an integer property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setNumber(self: PropertiesID, name: [*:0]const u8, value: i64) Error!void {
        try internal.checkResult(SDL_SetNumberProperty(self, name, value));
    }

    /// Set a floating point property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setFloat(self: PropertiesID, name: [*:0]const u8, value: f32) Error!void {
        try internal.checkResult(SDL_SetFloatProperty(self, name, value));
    }

    /// Set a boolean property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to modify
    /// \param value the new value of the property
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn setBoolean(self: PropertiesID, name: [*:0]const u8, value: bool) Error!void {
        try internal.checkResult(SDL_SetBooleanProperty(self, name, if (value) .true else .false));
    }

    /// Get the type of a property on a set of properties
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \returns the type of the property, or SDL_PROPERTY_TYPE_INVALID if it is
    ///          not set.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getType(self: PropertiesID, name: [*:0]const u8) PropertyType {
        return SDL_GetPropertyType(self, name);
    }

    /// Get a property on a set of properties
    ///
    /// By convention, the names of properties that SDL exposes on objects will
    /// start with "SDL.", and properties that SDL uses internally will start with
    /// "SDL.internal.". These should be considered read-only and should not be
    /// modified by applications.
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \param default_value the default value of the property
    /// \returns the value of the property, or `default_value` if it is not set or
    ///          not a pointer property.
    ///
    /// \threadsafety It is safe to call this function from any thread, although
    ///               the data returned is not protected and could potentially be
    ///               freed if you call SDL_SetProperty() or SDL_ClearProperty() on
    ///               these properties from another thread. If you need to avoid
    ///               this, use SDL_LockProperties() and SDL_UnlockProperties().
    ///
    pub fn get(self: PropertiesID, name: [*:0]const u8, default_value: ?*anyopaque) ?*anyopaque {
        return SDL_GetProperty(self, name, default_value);
    }

    /// Get a string property on a set of properties
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \param default_value the default value of the property
    /// \returns the value of the property, or `default_value` if it is not set or
    ///          not a string property.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getString(self: PropertiesID, name: [*:0]const u8, default_value: [*:0]const u8) [*:0]const u8 {
        return SDL_GetStringProperty(self, name, default_value);
    }

    /// Get a number property on a set of properties
    ///
    /// You can use SDL_GetPropertyType() to query whether the property exists and
    /// is a number property.
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \param default_value the default value of the property
    /// \returns the value of the property, or `default_value` if it is not set or
    ///          not a number property.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getNumber(self: PropertiesID, name: [*:0]const u8, default_value: i64) i64 {
        return SDL_GetNumberProperty(self, name, default_value);
    }

    /// Get a floating point property on a set of properties
    ///
    /// You can use SDL_GetPropertyType() to query whether the property exists and
    /// is a floating point property.
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \param default_value the default value of the property
    /// \returns the value of the property, or `default_value` if it is not set or
    ///          not a float property.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getFloat(self: PropertiesID, name: [*:0]const u8, default_value: f32) f32 {
        return SDL_GetFloatProperty(self, name, default_value);
    }

    /// Get a boolean property on a set of properties
    ///
    /// You can use SDL_GetPropertyType() to query whether the property exists and
    /// is a boolean property.
    ///
    /// \param props the properties to query
    /// \param name the name of the property to query
    /// \param default_value the default value of the property
    /// \returns the value of the property, or `default_value` if it is not set or
    ///          not a float property.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn getBoolean(self: PropertiesID, name: [*:0]const u8, default_value: bool) bool {
        return SDL_GetBooleanProperty(self, name, Bool.fromZig(default_value)).toZig();
    }

    /// Clear a property on a set of properties
    ///
    /// \param props the properties to modify
    /// \param name the name of the property to clear
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn clear(self: PropertiesID, name: [*:0]const u8) Error!void {
        try internal.checkResult(SDL_ClearProperty(self, name));
    }

    /// Enumerate the properties on a set of properties
    ///
    /// The callback function is called for each property on the set of properties.
    /// The properties are locked during enumeration.
    ///
    /// \param props the properties to query
    /// \param callback the function to call for each property
    /// \param userdata a pointer that is passed to `callback`
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    /// \threadsafety It is safe to call this function from any thread.
    ///
    pub fn enumerate(self: PropertiesID, callback: EnumeratePropertiesFn, userdata: ?*anyopaque) Error!void {
        try internal.checkResult(SDL_EnumerateProperties(self, callback, userdata));
    }

    /// Destroy a set of properties
    ///
    /// All properties are deleted and their cleanup functions will be called, if
    /// any.
    ///
    /// \param props the properties to destroy
    ///
    /// \threadsafety This function should not be called while these properties are
    ///               locked or other threads might be setting or getting values
    ///               from these properties.
    ///
    pub fn destroy(self: PropertiesID) void {
        SDL_DestroyProperties(self);
    }

    extern fn SDL_GetGlobalProperties() PropertiesID;
    extern fn SDL_CreateProperties() PropertiesID;
    extern fn SDL_LockProperties(props: PropertiesID) c_int;
    extern fn SDL_UnlockProperties(props: PropertiesID) void;
    extern fn SDL_SetPropertyWithCleanup(props: PropertiesID, name: [*:0]const u8, value: ?*anyopaque, cleanup: ?CleanupFn, userdata: ?*anyopaque) c_int;
    extern fn SDL_SetProperty(props: PropertiesID, name: [*:0]const u8, value: ?*anyopaque) c_int;
    extern fn SDL_SetStringProperty(props: PropertiesID, name: [*:0]const u8, value: ?[*:0]const u8) c_int;
    extern fn SDL_SetNumberProperty(props: PropertiesID, name: [*:0]const u8, value: i64) c_int;
    extern fn SDL_SetFloatProperty(props: PropertiesID, name: [*:0]const u8, value: f32) c_int;
    extern fn SDL_SetBooleanProperty(props: PropertiesID, name: [*:0]const u8, value: Bool) c_int;
    extern fn SDL_GetPropertyType(props: PropertiesID, name: [*:0]const u8) PropertyType;
    extern fn SDL_GetProperty(props: PropertiesID, name: [*:0]const u8, default_value: ?*anyopaque) ?*anyopaque;
    extern fn SDL_GetStringProperty(props: PropertiesID, name: [*:0]const u8, default_value: [*:0]const u8) [*:0]const u8;
    extern fn SDL_GetNumberProperty(props: PropertiesID, name: [*:0]const u8, default_value: i64) i64;
    extern fn SDL_GetFloatProperty(props: PropertiesID, name: [*:0]const u8, default_value: f32) f32;
    extern fn SDL_GetBooleanProperty(props: PropertiesID, name: [*:0]const u8, default_value: Bool) Bool;
    extern fn SDL_ClearProperty(props: PropertiesID, name: [*:0]const u8) c_int;
    extern fn SDL_EnumerateProperties(props: PropertiesID, callback: EnumeratePropertiesFn, userdata: ?*anyopaque) c_int;
    extern fn SDL_DestroyProperties(props: PropertiesID) void;
};

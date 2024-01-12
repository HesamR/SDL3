const std = @import("std");

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

/// An SDL_GUID is a 128-bit identifier for an input device that
///   identifies that device across runs of SDL programs on the same
///   platform.  If the device is detached and then re-attached to a
///   different port, or if the base system is rebooted, the device
///   should still report the same GUID.
///
/// GUIDs are as precise as possible but are not guaranteed to
///   distinguish physically distinct but equivalent devices.  For
///   example, two game controllers from the same vendor with the same
///   product ID and revision may have the same GUID.
///
/// GUIDs may be platform-dependent (i.e., the same device may report
///   different GUIDs on different operating systems).
pub const GUID = extern struct {
    data: [16]u8,

    pub fn toString(guid: GUID, out: []u8) Error!void {
        std.debug.assert(out.len >= 33);

        try internal.checkResult(SDL_GUIDToString(guid, out.ptr, @intCast(out.len)));
    }

    pub fn fromString(pch_guild: [*:0]const u8) GUID {
        return SDL_GUIDFromString(pch_guild);
    }

    pub fn isZero(self: GUID) bool {
        return std.meta.eql(self, GUID{ .data = [_]u8{0} ** 16 });
    }

    extern fn SDL_GUIDFromString(pch_guild: [*:0]const u8) GUID;
    extern fn SDL_GUIDToString(guid: GUID, psz_guid: [*]u8, cb_guid: c_int) c_int;
};

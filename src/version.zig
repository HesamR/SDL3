const internal = @import("internal.zig");
const Error = internal.Error;

/// Information about the version of SDL in use.
///
/// Represents the library's version as three levels: major revision
/// (increments with massive changes, additions, and enhancements),
/// minor revision (increments with backwards-compatible changes to the
/// major revision), and patchlevel (increments with fixes to the minor
/// revision).
///
pub const Version = extern struct {
    major: u8,
    minor: u8,
    patch: u8,
};

/// Get the version of SDL that is linked against your program.
///
/// If you are linking to SDL dynamically, then it is possible that the current
/// version will be different than the version you compiled against. This
/// function returns the current version, while SDL_VERSION() is a macro that
/// tells you what version you compiled with.
///
/// This function may be called safely at any time, even before SDL_Init().
///
/// \param ver the SDL_version structure that contains the version information
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn getVersion(ver: *Version) Error!void {
    try internal.checkResult(SDL_GetVersion(ver));
}

/// Get the code revision of SDL that is linked against your program.
///
/// This value is the revision of the code you are linked with and may be
/// different from the code you are compiling with, which is found in the
/// constant SDL_REVISION.
///
/// The revision is arbitrary string (a hash value) uniquely identifying the
/// exact revision of the SDL library in use, and is only useful in comparing
/// against other revisions. It is NOT an incrementing number.
///
/// If SDL wasn't built from a git repository with the appropriate tools, this
/// will return an empty string.
///
/// Prior to SDL 2.0.16, before development moved to GitHub, this returned a
/// hash for a Mercurial repository.
///
/// You shouldn't use this function for anything but logging it for debugging
/// purposes. The string is not intended to be reliable in any way.
///
/// \returns an arbitrary string, uniquely identifying the exact revision of
///          the SDL library in use.
///
pub fn getRevision() ?[*:0]const u8 {
    return SDL_GetRevision();
}

extern fn SDL_GetVersion(ver: *Version) c_int;
extern fn SDL_GetRevision() ?[*:0]const u8;

const std = @import("std");

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const stdinc = @import("stdinc.zig");

/// Callback function that will be called when data for the specified mime-type
/// is requested by the OS.
///
/// The callback function is called with NULL as the mime_type when the clipboard
/// is cleared or new data is set. The clipboard is automatically cleared in SDL_Quit().
///
/// \param userdata  A pointer to provided user data
/// \param mime_type The requested mime-type
/// \param size      A pointer filled in with the length of the returned data
/// \returns a pointer to the data for the provided mime-type. Returning NULL or
///          setting length to 0 will cause no data to be sent to the "receiver". It is
///          up to the receiver to handle this. Essentially returning no data is more or
///          less undefined behavior and may cause breakage in receiving applications.
///          The returned data will not be freed so it needs to be retained and dealt
///          with internally.
///
pub const ClipboardDataCallback = *const fn (userdata: ?*anyopaque, mime_type: [*:0]const u8, size: *usize) callconv(.C) ?*const anyopaque;

/// Callback function that will be called when the clipboard is cleared, or new data is set.
///
/// \param userdata A pointer to provided user data
///
pub const ClipboardCleanupCallback = *const fn (userdata: ?*anyopaque) callconv(.C) void;

/// Put UTF-8 text into the clipboard.
///
/// \param text the text to store in the clipboard
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setClipboardText(text: [*:0]const u8) Error!void {
    try internal.checkResult(SDL_SetClipboardText(text));
}

/// Get UTF-8 text from the clipboard, which must be freed with SDL_free().
///
/// This functions returns empty string if there was not enough memory left for
/// a copy of the clipboard's content.
///
/// \returns the clipboard text on success or an empty string on failure; call
///          SDL_GetError() for more information. Caller must call SDL_free()
///          on the returned pointer when done with it (even if there was an
///          error).
///
pub fn getClipboardText() Error![*:0]u8 {
    const text = SDL_GetClipboardText();
    if (std.mem.len(text) == 0) {
        stdinc.free(@ptrCast(text));
        return internal.emitError();
    } else {
        return text;
    }
}

/// Query whether the clipboard exists and contains a non-empty text string.
///
/// \returns SDL_TRUE if the clipboard has text, or SDL_FALSE if it does not.
///
pub fn hasClipboardText() bool {
    return SDL_HasClipboardText().toZig();
}

/// Put UTF-8 text into the primary selection.
///
/// \param text the text to store in the primary selection
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setPrimarySelectionText(text: [*:0]const u8) Error!void {
    try internal.checkResult(SDL_SetPrimarySelectionText(text));
}

/// Get UTF-8 text from the primary selection, which must be freed with
/// SDL_free().
///
/// This functions returns empty string if there was not enough memory left for
/// a copy of the primary selection's content.
///
/// \returns the primary selection text on success or an empty string on
///          failure; call SDL_GetError() for more information. Caller must
///          call SDL_free() on the returned pointer when done with it (even if
///          there was an error).
///
pub fn getPrimarySelectionText() [*:0]u8 {
    const text = SDL_GetPrimarySelectionText();
    if (std.mem.len(text) == 0) {
        stdinc.free(@ptrCast(text));
        return internal.emitError();
    } else {
        return text;
    }
}

/// Query whether the primary selection exists and contains a non-empty text
/// string.
///
/// \returns SDL_TRUE if the primary selection has text, or SDL_FALSE if it
///          does not.
///
pub fn hasPrimarySelectionText() bool {
    return SDL_HasPrimarySelectionText().toZig();
}

/// Offer clipboard data to the OS
///
/// Tell the operating system that the application is offering clipboard data
/// for each of the proivded mime-types. Once another application requests the
/// data the callback function will be called allowing it to generate and
/// respond with the data for the requested mime-type.
///
/// The size of text data does not include any terminator, and the text does
/// not need to be null terminated (e.g. you can directly copy a portion of a
/// document)
///
/// \param callback A function pointer to the function that provides the
///                 clipboard data
/// \param cleanup A function pointer to the function that cleans up the
///                clipboard data
/// \param userdata An opaque pointer that will be forwarded to the callbacks
/// \param mime_types A list of mime-types that are being offered
/// \param num_mime_types The number of mime-types in the mime_types list
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setClipboardData(callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: ?*anyopaque, mime_types: [][*:0]const u8) Error!void {
    try internal.checkResult(SDL_SetClipboardData(callback, cleanup, userdata, mime_types.ptr, mime_types.len));
}

/// Clear the clipboard data
///
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn clearClipboardData() Error!void {
    try internal.checkResult(SDL_ClearClipboardData());
}

/// Get the data from clipboard for a given mime type
///
/// The size of text data does not include the terminator, but the text is
/// guaranteed to be null terminated.
///
/// \param mime_type The mime type to read from the clipboard
/// \param size A pointer filled in with the length of the returned data
/// \returns the retrieved data buffer or NULL on failure; call SDL_GetError()
///          for more information. Caller must call SDL_free() on the returned
///          pointer when done with it.
///
pub fn getClipboardData(mime_type: [*:0]const u8) Error![]u8 {
    var len: usize = 0;
    const ptr = SDL_GetClipboardData(mime_type, &len);

    if (ptr) |p|
        return @as([*]u8, @ptrCast(@alignCast(p)))[0..len]
    else
        return internal.emitError();
}

/// Query whether there is data in the clipboard for the provided mime type
///
/// \param mime_type The mime type to check for data for
/// \returns SDL_TRUE if there exists data in clipboard for the provided mime
///          type, SDL_FALSE if it does not.
///
pub fn hasClipboardData(mime_type: [*:0]const u8) bool {
    return SDL_HasClipboardData(mime_type).toZig();
}

extern fn SDL_SetClipboardText(text: [*:0]const u8) c_int;
extern fn SDL_GetClipboardText() [*:0]u8;
extern fn SDL_HasClipboardText() Bool;
extern fn SDL_SetPrimarySelectionText(text: [*:0]const u8) c_int;
extern fn SDL_GetPrimarySelectionText() [*:0]u8;
extern fn SDL_HasPrimarySelectionText() Bool;
extern fn SDL_SetClipboardData(callback: ClipboardDataCallback, cleanup: ClipboardCleanupCallback, userdata: ?*anyopaque, mime_types: [*][*:0]const u8, num_mime_types: usize) c_int;
extern fn SDL_ClearClipboardData() c_int;
extern fn SDL_GetClipboardData(mime_type: [*:0]const u8, size: *usize) ?*anyopaque;
extern fn SDL_HasClipboardData(mime_type: [*:0]const u8) Bool;

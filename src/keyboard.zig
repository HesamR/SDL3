const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;
const Rect = @import("rect.zig").Rect;

const Window = opaque {};

const Scancode = enum(c_uint) {
    unknown = 0,
    a = 4,
    b = 5,
    c = 6,
    d = 7,
    e = 8,
    f = 9,
    g = 10,
    h = 11,
    i = 12,
    j = 13,
    k = 14,
    l = 15,
    m = 16,
    n = 17,
    o = 18,
    p = 19,
    q = 20,
    r = 21,
    s = 22,
    t = 23,
    u = 24,
    v = 25,
    w = 26,
    x = 27,
    y = 28,
    z = 29,
    num1 = 30,
    num2 = 31,
    num3 = 32,
    num4 = 33,
    num5 = 34,
    num6 = 35,
    num7 = 36,
    num8 = 37,
    num9 = 38,
    num0 = 39,
    enter = 40,
    escape = 41,
    backspace = 42,
    tab = 43,
    space = 44,
    minus = 45,
    equals = 46,
    left_bracket = 47,
    righ_tbracket = 48,
    backslash = 49,
    non_us_hash = 50,
    semicolon = 51,
    apostrophe = 52,
    grave = 53,
    comma = 54,
    period = 55,
    slash = 56,
    capslock = 57,
    f1 = 58,
    f2 = 59,
    f3 = 60,
    f4 = 61,
    f5 = 62,
    f6 = 63,
    f7 = 64,
    f8 = 65,
    f9 = 66,
    f10 = 67,
    f11 = 68,
    f12 = 69,
    printscreen = 70,
    scrolllock = 71,
    pause = 72,
    insert = 73,
    home = 74,
    pageup = 75,
    delete = 76,
    end = 77,
    pagedown = 78,
    right = 79,
    left = 80,
    down = 81,
    up = 82,
    numlock_clear = 83,
    kp_divide = 84,
    kp_multiply = 85,
    kp_minus = 86,
    kp_plus = 87,
    kp_enter = 88,
    kp_1 = 89,
    kp_2 = 90,
    kp_3 = 91,
    kp_4 = 92,
    kp_5 = 93,
    kp_6 = 94,
    kp_7 = 95,
    kp_8 = 96,
    kp_9 = 97,
    kp_0 = 98,
    kp_period = 99,
    non_us_backslash = 100,
    application = 101,
    power = 102,
    kp_equals = 103,
    f13 = 104,
    f14 = 105,
    f15 = 106,
    f16 = 107,
    f17 = 108,
    f18 = 109,
    f19 = 110,
    f20 = 111,
    f21 = 112,
    f22 = 113,
    f23 = 114,
    f24 = 115,
    execute = 116,
    help = 117,
    menu = 118,
    select = 119,
    stop = 120,
    again = 121,
    undo = 122,
    cut = 123,
    copy = 124,
    paste = 125,
    find = 126,
    mute = 127,
    volume_up = 128,
    volume_down = 129,
    kp_comma = 133,
    kp_equalsas400 = 134,
    international1 = 135,
    international2 = 136,
    international3 = 137,
    international4 = 138,
    international5 = 139,
    international6 = 140,
    international7 = 141,
    international8 = 142,
    international9 = 143,
    lang1 = 144,
    lang2 = 145,
    lang3 = 146,
    lang4 = 147,
    lang5 = 148,
    lang6 = 149,
    lang7 = 150,
    lang8 = 151,
    lang9 = 152,
    alterase = 153,
    sysreq = 154,
    cancel = 155,
    clear = 156,
    prior = 157,
    return2 = 158,
    separator = 159,
    out = 160,
    oper = 161,
    clear_again = 162,
    crsel = 163,
    exsel = 164,
    kp_00 = 176,
    kp_000 = 177,
    thousands_separator = 178,
    decimal_separator = 179,
    currency_unit = 180,
    currency_subunit = 181,
    kp_leftparen = 182,
    kp_rightparen = 183,
    kp_leftbrace = 184,
    kp_rightbrace = 185,
    kp_tab = 186,
    kp_backspace = 187,
    kp_a = 188,
    kp_b = 189,
    kp_c = 190,
    kp_d = 191,
    kp_e = 192,
    kp_f = 193,
    kp_xor = 194,
    kp_power = 195,
    kp_percent = 196,
    kp_less = 197,
    kp_greater = 198,
    kp_ampersand = 199,
    kp_dbl_ampersand = 200,
    kp_vertical_bar = 201,
    kp_dbl_vertical_bar = 202,
    kp_colon = 203,
    kp_hash = 204,
    kp_space = 205,
    kp_at = 206,
    kp_exclam = 207,
    kp_memstore = 208,
    kp_memrecall = 209,
    kp_memclear = 210,
    kp_memadd = 211,
    kp_memsubtract = 212,
    kp_memmultiply = 213,
    kp_memdivide = 214,
    kp_plusminus = 215,
    kp_clear = 216,
    kp_clearentry = 217,
    kp_binary = 218,
    kp_octal = 219,
    kp_decimal = 220,
    kp_hexadecimal = 221,
    lctrl = 224,
    lshift = 225,
    lalt = 226,
    lgui = 227,
    rctrl = 228,
    rshift = 229,
    ralt = 230,
    rgui = 231,
    mode = 257,
    audio_next = 258,
    audio_prev = 259,
    audio_stop = 260,
    audio_play = 261,
    audio_mute = 262,
    media_select = 263,
    www = 264,
    mail = 265,
    calculator = 266,
    computer = 267,
    ac_search = 268,
    ac_home = 269,
    ac_back = 270,
    ac_forward = 271,
    ac_stop = 272,
    ac_refresh = 273,
    ac_bookmarks = 274,
    brightness_down = 275,
    brightness_up = 276,
    display_switch = 277,
    kbd_illum_toggle = 278,
    kbd_illum_down = 279,
    kbd_illum_up = 280,
    eject = 281,
    sleep = 282,
    app1 = 283,
    app2 = 284,
    audio_rewind = 285,
    audio_fastforward = 286,
    soft_left = 287,
    soft_right = 288,
    call = 289,
    endcall = 290,
};

const mask = 1 << 30;

fn toKeycode(comptime scan: Scancode) comptime_int {
    return @intFromEnum(scan) | mask;
}

const Keycode = enum(c_int) {
    unknown = 0,
    enter = '\r',
    escape = '\x1b',
    backspace = '\x08',
    tab = '\t',
    space = ' ',
    exclaim = '!',
    quotedbl = '"',
    hash = '#',
    percent = '%',
    dollar = '$',
    ampersand = '&',
    quote = '\'',
    left_paren = '(',
    right_paren = ')',
    asterisk = '*',
    plus = '+',
    comma = ',',
    minus = '-',
    period = '.',
    slash = '/',
    num0 = '0',
    num1 = '1',
    num2 = '2',
    num3 = '3',
    num4 = '4',
    num5 = '5',
    num6 = '6',
    num7 = '7',
    num8 = '8',
    num9 = '9',
    colon = ':',
    semicolon = ';',
    less = '<',
    equals = '=',
    greater = '>',
    question = '?',
    at = '@',
    left_bracket = '[',
    backslash = '\\',
    right_bracket = ']',
    caret = '^',
    underscore = '_',
    backquote = '`',
    a = 'a',
    b = 'b',
    c = 'c',
    d = 'd',
    e = 'e',
    f = 'f',
    g = 'g',
    h = 'h',
    i = 'i',
    j = 'j',
    k = 'k',
    l = 'l',
    m = 'm',
    n = 'n',
    o = 'o',
    p = 'p',
    q = 'q',
    r = 'r',
    s = 's',
    t = 't',
    u = 'u',
    v = 'v',
    w = 'w',
    x = 'x',
    y = 'y',
    z = 'z',
    capslock = toKeycode(.capslock),
    f1 = toKeycode(.f1),
    f2 = toKeycode(.f2),
    f3 = toKeycode(.f3),
    f4 = toKeycode(.f4),
    f5 = toKeycode(.f5),
    f6 = toKeycode(.f6),
    f7 = toKeycode(.f7),
    f8 = toKeycode(.f8),
    f9 = toKeycode(.f9),
    f10 = toKeycode(.f10),
    f11 = toKeycode(.f11),
    f12 = toKeycode(.f12),
    printscreen = toKeycode(.printscreen),
    scrolllock = toKeycode(.scrolllock),
    pause = toKeycode(.pause),
    insert = toKeycode(.insert),
    home = toKeycode(.home),
    pageup = toKeycode(.pageup),
    delete = '\x7F',
    end = toKeycode(.end),
    pagedown = toKeycode(.pagedown),
    right = toKeycode(.right),
    left = toKeycode(.left),
    down = toKeycode(.down),
    up = toKeycode(.up),
    numlock_clear = toKeycode(.numlock_clear),
    kp_divide = toKeycode(.kp_divide),
    kp_multiply = toKeycode(.kp_multiply),
    kp_minus = toKeycode(.kp_minus),
    kp_plus = toKeycode(.kp_plus),
    kp_enter = toKeycode(.kp_enter),
    kp_1 = toKeycode(.kp_1),
    kp_2 = toKeycode(.kp_2),
    kp_3 = toKeycode(.kp_3),
    kp_4 = toKeycode(.kp_4),
    kp_5 = toKeycode(.kp_5),
    kp_6 = toKeycode(.kp_6),
    kp_7 = toKeycode(.kp_7),
    kp_8 = toKeycode(.kp_8),
    kp_9 = toKeycode(.kp_9),
    kp_0 = toKeycode(.kp_0),
    kp_period = toKeycode(.kp_period),
    application = toKeycode(.application),
    power = toKeycode(.power),
    kp_equals = toKeycode(.kp_equals),
    f13 = toKeycode(.f13),
    f14 = toKeycode(.f14),
    f15 = toKeycode(.f15),
    f16 = toKeycode(.f16),
    f17 = toKeycode(.f17),
    f18 = toKeycode(.f18),
    f19 = toKeycode(.f19),
    f20 = toKeycode(.f20),
    f21 = toKeycode(.f21),
    f22 = toKeycode(.f22),
    f23 = toKeycode(.f23),
    f24 = toKeycode(.f24),
    execute = toKeycode(.execute),
    help = toKeycode(.help),
    menu = toKeycode(.menu),
    select = toKeycode(.select),
    stop = toKeycode(.stop),
    again = toKeycode(.again),
    undo = toKeycode(.undo),
    cut = toKeycode(.cut),
    copy = toKeycode(.copy),
    paste = toKeycode(.paste),
    find = toKeycode(.find),
    mute = toKeycode(.mute),
    volume_up = toKeycode(.volume_up),
    volume_down = toKeycode(.volume_down),
    kp_comma = toKeycode(.kp_comma),
    kp_equalsas400 = toKeycode(.kp_equalsas400),
    alterase = toKeycode(.alterase),
    sysreq = toKeycode(.sysreq),
    cancel = toKeycode(.cancel),
    clear = toKeycode(.clear),
    prior = toKeycode(.prior),
    return2 = toKeycode(.return2),
    separator = toKeycode(.separator),
    out = toKeycode(.out),
    oper = toKeycode(.oper),
    clear_again = toKeycode(.clear_again),
    crsel = toKeycode(.crsel),
    exsel = toKeycode(.exsel),
    kp_00 = toKeycode(.kp_00),
    kp_000 = toKeycode(.kp_000),
    thousands_separator = toKeycode(.thousands_separator),
    decimal_separator = toKeycode(.decimal_separator),
    currency_unit = toKeycode(.currency_unit),
    currency_subunit = toKeycode(.currency_subunit),
    kp_leftparen = toKeycode(.kp_leftparen),
    kp_rightparen = toKeycode(.kp_rightparen),
    kp_leftbrace = toKeycode(.kp_leftbrace),
    kp_rightbrace = toKeycode(.kp_rightbrace),
    kp_tab = toKeycode(.kp_tab),
    kp_backspace = toKeycode(.kp_backspace),
    kp_a = toKeycode(.kp_a),
    kp_b = toKeycode(.kp_b),
    kp_c = toKeycode(.kp_c),
    kp_d = toKeycode(.kp_d),
    kp_e = toKeycode(.kp_e),
    kp_f = toKeycode(.kp_f),
    kp_xor = toKeycode(.kp_xor),
    kp_power = toKeycode(.kp_power),
    kp_percent = toKeycode(.kp_percent),
    kp_less = toKeycode(.kp_less),
    kp_greater = toKeycode(.kp_greater),
    kp_ampersand = toKeycode(.kp_ampersand),
    kp_dbl_ampersand = toKeycode(.kp_dbl_ampersand),
    kp_vertical_bar = toKeycode(.kp_vertical_bar),
    kp_dbl_vertical_bar = toKeycode(.kp_dbl_vertical_bar),
    kp_colon = toKeycode(.kp_colon),
    kp_hash = toKeycode(.kp_hash),
    kp_space = toKeycode(.kp_space),
    kp_at = toKeycode(.kp_at),
    kp_exclam = toKeycode(.kp_exclam),
    kp_memstore = toKeycode(.kp_memstore),
    kp_memrecall = toKeycode(.kp_memrecall),
    kp_memclear = toKeycode(.kp_memclear),
    kp_memadd = toKeycode(.kp_memadd),
    kp_memsubtract = toKeycode(.kp_memsubtract),
    kp_memmultiply = toKeycode(.kp_memmultiply),
    kp_memdivide = toKeycode(.kp_memdivide),
    kp_plusminus = toKeycode(.kp_plusminus),
    kp_clear = toKeycode(.kp_clear),
    kp_clearentry = toKeycode(.kp_clearentry),
    kp_binary = toKeycode(.kp_binary),
    kp_octal = toKeycode(.kp_octal),
    kp_decimal = toKeycode(.kp_decimal),
    kp_hexadecimal = toKeycode(.kp_hexadecimal),
    lctrl = toKeycode(.lctrl),
    lshift = toKeycode(.lshift),
    lalt = toKeycode(.lalt),
    lgui = toKeycode(.lgui),
    rctrl = toKeycode(.rctrl),
    rshift = toKeycode(.rshift),
    ralt = toKeycode(.ralt),
    rgui = toKeycode(.rgui),
    mode = toKeycode(.mode),
    audio_next = toKeycode(.audio_next),
    audio_prev = toKeycode(.audio_prev),
    audio_stop = toKeycode(.audio_stop),
    audio_play = toKeycode(.audio_play),
    audio_mute = toKeycode(.audio_mute),
    media_select = toKeycode(.media_select),
    www = toKeycode(.www),
    mail = toKeycode(.mail),
    calculator = toKeycode(.calculator),
    computer = toKeycode(.computer),
    ac_search = toKeycode(.ac_search),
    ac_home = toKeycode(.ac_home),
    ac_back = toKeycode(.ac_back),
    ac_forward = toKeycode(.ac_forward),
    ac_stop = toKeycode(.ac_stop),
    ac_refresh = toKeycode(.ac_refresh),
    ac_bookmarks = toKeycode(.ac_bookmarks),
    brightness_down = toKeycode(.brightness_down),
    brightness_up = toKeycode(.brightness_up),
    display_switch = toKeycode(.display_switch),
    kbd_illum_toggle = toKeycode(.kbd_illum_toggle),
    kbd_illum_down = toKeycode(.kbd_illum_down),
    kbd_illum_up = toKeycode(.kbd_illum_up),
    eject = toKeycode(.eject),
    sleep = toKeycode(.sleep),
    app1 = toKeycode(.app1),
    app2 = toKeycode(.app2),
    audio_rewind = toKeycode(.audio_rewind),
    audio_fastforward = toKeycode(.audio_fastforward),
    soft_left = toKeycode(.soft_left),
    soft_right = toKeycode(.soft_right),
    call = toKeycode(.call),
    endcall = toKeycode(.endcall),
};

pub const Keymod = packed struct(u16) {
    lshift: bool = false,
    rshift: bool = false,

    __padding1: u4 = 0,

    lctrl: bool = false,
    rctrl: bool = false,
    lalt: bool = false,
    ralt: bool = false,
    lgui: bool = false,
    rgui: bool = false,
    num: bool = false,
    caps: bool = false,
    mode: bool = false,
    scroll: bool = false,

    pub fn fromInt(val: c_uint) Keymod {
        return @bitCast(@as(u16, @intCast(val)));
    }

    pub fn toInt(self: Keymod) c_uint {
        return @as(u16, @bitCast(self));
    }
};

pub const Keysym = extern struct {
    scancode: Scancode,
    keycode: Keycode,
    mod: Keymod,
    unused: u32,
};

/// Query the window which currently has keyboard focus.
///
/// \returns the window with keyboard focus.
///
pub fn getKeyboardFocus() ?*Window {
    return SDL_GetKeyboardFocus();
}

/// Get a snapshot of the current state of the keyboard.
///
/// The pointer returned is a pointer to an internal SDL array. It will be
/// valid for the whole lifetime of the application and should not be freed by
/// the caller.
///
/// A array element with a value of 1 means that the key is pressed and a value
/// of 0 means that it is not. Indexes into this array are obtained by using
/// SDL_Scancode values.
///
/// Use SDL_PumpEvents() to update the state array.
///
/// This function gives you the current state after all events have been
/// processed, so if a key or button has been pressed and released before you
/// process events, then the pressed state will never show up in the
/// SDL_GetKeyboardState() calls.
///
/// Note: This function doesn't take into account whether shift has been
/// pressed or not.
///
/// \param numkeys if non-NULL, receives the length of the returned array
/// \returns a pointer to an array of key states.
///
pub fn getKeyboardState() []const u8 {
    var len: c_int = 0;
    const arr = SDL_GetKeyboardState(&len);
    return arr[0..@intCast(len)];
}

/// Clear the state of the keyboard
///
/// This function will generate key up events for all pressed keys.
///
pub fn resetKeyboard() void {
    SDL_ResetKeyboard();
}

/// Get the current key modifier state for the keyboard.
///
/// \returns an OR'd combination of the modifier keys for the keyboard. See
///          SDL_Keymod for details.
///
pub fn getModState() Keymod {
    return Keymod.fromInt(SDL_GetModState());
}

/// Set the current key modifier state for the keyboard.
///
/// The inverse of SDL_GetModState(), SDL_SetModState() allows you to impose
/// modifier key states on your application. Simply pass your desired modifier
/// states into `modstate`. This value may be a bitwise, OR'd combination of
/// SDL_Keymod values.
///
/// This does not change the keyboard state, only the key modifier flags that
/// SDL reports.
///
/// \param modstate the desired SDL_Keymod for the keyboard
///
pub fn setModState(modstate: Keymod) void {
    SDL_SetModState(modstate.toInt());
}

/// Start accepting Unicode text input events.
///
/// This function will start accepting Unicode text input events in the focused
/// SDL window, and start emitting SDL_TextInputEvent (SDL_EVENT_TEXT_INPUT)
/// and SDL_TextEditingEvent (SDL_EVENT_TEXT_EDITING) events. Please use this
/// function in pair with SDL_StopTextInput().
///
/// On some platforms using this function activates the screen keyboard.
///
pub fn startTextInput() void {
    SDL_StartTextInput();
}

/// Stop receiving any text input events.
///
pub fn stopTextInput() void {
    SDL_StopTextInput();
}

/// Check whether or not Unicode text input events are enabled.
///
/// \returns SDL_TRUE if text input events are enabled else SDL_FALSE.
///
pub fn isTextInputActive() bool {
    return SDL_TextInputActive().toZig();
}

/// Dismiss the composition window/IME without disabling the subsystem.
///
pub fn clearComposition() void {
    SDL_ClearComposition();
}

/// Returns if an IME Composite or Candidate window is currently shown.
///
/// \returns SDL_TRUE if shown, else SDL_FALSE
///
pub fn isTextInputShown() bool {
    return SDL_TextInputShown().toZig();
}

/// Set the rectangle used to type Unicode text inputs.
///
/// Native input methods will place a window with word suggestions near it,
/// without covering the text being inputted.
///
/// To start text input in a given location, this function is intended to be
/// called before SDL_StartTextInput, although some platforms support moving
/// the rectangle even while text input (and a composition) is active.
///
/// Note: If you want to use the system native IME window, try setting hint
/// **SDL_HINT_IME_SHOW_UI** to **1**, otherwise this function won't give you
/// any feedback.
///
/// \param rect the SDL_Rect structure representing the rectangle to receive
///             text (ignored if NULL)
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setTextInputRect(rect: *const Rect) Error!void {
    try internal.checkResult(SDL_SetTextInputRect(rect));
}

/// Check whether the platform has screen keyboard support.
///
/// \returns SDL_TRUE if the platform has some screen keyboard support or
///          SDL_FALSE if not.
///
pub fn hasScreenKeyboardSupport() bool {
    return SDL_HasScreenKeyboardSupport().toZig();
}

/// Check whether the screen keyboard is shown for given window.
///
/// \param window the window for which screen keyboard should be queried
/// \returns SDL_TRUE if screen keyboard is shown or SDL_FALSE if not.
///
pub fn isScreenKeyboardShown(window: *Window) bool {
    return SDL_ScreenKeyboardShown(window).toZig();
}

extern fn SDL_GetKeyboardFocus() ?*Window;
extern fn SDL_GetKeyboardState(numkeys: *c_int) [*]const u8;
extern fn SDL_ResetKeyboard() void;
extern fn SDL_GetModState() c_uint;
extern fn SDL_SetModState(modstate: c_uint) void;
extern fn SDL_StartTextInput() void;
extern fn SDL_StopTextInput() void;
extern fn SDL_TextInputActive() Bool;
extern fn SDL_ClearComposition() void;
extern fn SDL_TextInputShown() Bool;
extern fn SDL_SetTextInputRect(rect: *const Rect) c_int;
extern fn SDL_HasScreenKeyboardSupport() Bool;
extern fn SDL_ScreenKeyboardShown(window: *Window) Bool;

// extern fn SDL_GetKeyFromScancode(scancode: Scancode) Keycode;
// extern fn SDL_GetScancodeFromKey(key: Keycode) Scancode;
// extern fn SDL_GetScancodeName(scancode: Scancode) [*:0]const u8;
// extern fn SDL_GetScancodeFromName(name: [*:0]const u8) Scancode;
// extern fn SDL_GetKeyName(key: Keycode) [*:0]const u8;
// extern fn SDL_GetKeyFromName(name: [*:0]const u8) Keycode;

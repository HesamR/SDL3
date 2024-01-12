const std = @import("std");
const log = std.log.scoped(.SDL);

pub const Bool = enum(c_uint) {
    false = 0,
    true = 1,

    pub fn fromZig(val: bool) Bool {
        return if (val) .true else .false;
    }

    pub fn toZig(self: Bool) bool {
        return switch (self) {
            .false => false,
            .true => true,
        };
    }
};

pub const Error = error{
    SDLError,
};

pub inline fn checkResult(ret: c_int) Error!void {
    return assertResult(ret == 0);
}

pub inline fn assertResult(cond: bool) Error!void {
    if (!cond) return emitError();
}

pub inline fn emitError() Error {
    if (SDL_GetError()) |err|
        log.err("SDL failed : {s}", .{err});

    return error.SDLError;
}

pub inline fn hasError() Error!void {
    if (SDL_GetError()) |err| {
        log.err("SDL failed : {s}", .{err});
        return error.SDLError;
    }
}

extern fn SDL_GetError() ?[*:0]const u8;

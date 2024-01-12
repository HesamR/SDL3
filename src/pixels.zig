const builtin = @import("builtin");

const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const endian = builtin.cpu.arch.endian();

pub const PixelFormat = enum(u32) {
    unknown = 0,
    index1_lsb = 286261504,
    index1_msb = 287310080,
    index2_lsb = 470811136,
    index2_msb = 471859712,
    index4_lsb = 303039488,
    index4_msb = 304088064,
    index8 = 318769153,
    rgb332 = 336660481,
    xrgb4444 = 353504258,
    rgb444 = 353504258,
    xbgr4444 = 357698562,
    bgr444 = 357698562,
    xrgb1555 = 353570562,
    rgb555 = 353570562,
    xbgr1555 = 357764866,
    bgr555 = 357764866,
    argb4444 = 355602434,
    rgba4444 = 356651010,
    abgr4444 = 359796738,
    bgra4444 = 360845314,
    argb1555 = 355667970,
    rgba5551 = 356782082,
    abgr1555 = 359862274,
    bgra5551 = 360976386,
    rgb565 = 353701890,
    bgr565 = 357896194,
    rgb24 = 386930691,
    bgr24 = 390076419,
    xrgb8888 = 370546692,
    rgbx8888 = 371595268,
    xbgr8888 = 374740996,
    bgrx8888 = 375789572,
    argb8888 = 372645892,
    rgba8888 = 373694468,
    abgr8888 = 376840196,
    bgra8888 = 377888772,
    xrgb2101010 = 370614276,
    xbgr2101010 = 374808580,
    argb2101010 = 372711428,
    abgr2101010 = 376905732,
    yv12 = 842094169,
    iyuv = 1448433993,
    yuy2 = 844715353,
    uyvy = 1498831189,
    yvyu = 1431918169,
    nv12 = 842094158,
    nv21 = 825382478,
    external_oes = 542328143,
    _,

    pub const rgba32: PixelFormat = switch (endian) {
        .big => .rgba8888,
        .little => .abgr8888,
    };

    pub const argb32: PixelFormat = switch (endian) {
        .big => .argb8888,
        .little => .bgra8888,
    };

    pub const bgra32: PixelFormat = switch (endian) {
        .big => .bgra8888,
        .little => .argb8888,
    };

    pub const abgr32: PixelFormat = switch (endian) {
        .big => .abgr8888,
        .little => .rgba8888,
    };

    pub const rgbx32: PixelFormat = switch (endian) {
        .big => .rgbx8888,
        .little => .xbgr8888,
    };

    pub const xrgb32: PixelFormat = switch (endian) {
        .big => .xrgb8888,
        .little => .bgrx8888,
    };

    pub const bgrx32: PixelFormat = switch (endian) {
        .big => .bgrx8888,
        .little => .xrgb8888,
    };

    pub const xbgr32: PixelFormat = switch (endian) {
        .big => .xbgr8888,
        .little => .rgbx8888,
    };

    /// Convert a bpp value and RGBA masks to an enumerated pixel format.
    ///
    /// This will return `SDL_PIXELFORMAT_UNKNOWN` if the conversion wasn't
    /// possible.
    ///
    /// \param bpp a bits per pixel value; usually 15, 16, or 32
    /// \param Rmask the red mask for the format
    /// \param Gmask the green mask for the format
    /// \param Bmask the blue mask for the format
    /// \param Amask the alpha mask for the format
    /// \returns one of the SDL_PixelFormatEnum values
    ///
    pub fn fromMasks(bpp: c_int, rmask: u32, gmask: u32, bmask: u32, amask: u32) PixelFormat {
        return SDL_GetPixelFormatEnumForMasks(bpp, rmask, gmask, bmask, amask);
    }

    /// Get the human readable name of a pixel format.
    ///
    /// \param format the pixel format to query
    /// \returns the human readable name of the specified pixel format or
    ///          `SDL_PIXELFORMAT_UNKNOWN` if the format isn't recognized.
    ///
    pub fn getName(self: PixelFormat) [*:0]const u8 {
        return SDL_GetPixelFormatName(self);
    }

    /// Convert one of the enumerated pixel formats to a bpp value and RGBA masks.
    ///
    /// \param format one of the SDL_PixelFormatEnum values
    /// \param bpp a bits per pixel value; usually 15, 16, or 32
    /// \param Rmask a pointer filled in with the red mask for the format
    /// \param Gmask a pointer filled in with the green mask for the format
    /// \param Bmask a pointer filled in with the blue mask for the format
    /// \param Amask a pointer filled in with the alpha mask for the format
    /// \returns SDL_TRUE on success or SDL_FALSE if the conversion wasn't
    ///          possible; call SDL_GetError() for more information.
    ///
    pub fn getMasks(self: PixelFormat, bpp: *c_int, rmask: *u32, gmask: *u32, bmask: *u32, amask: *u32) Error!void {
        try internal.assertResult(SDL_GetMasksForPixelFormatEnum(self, bpp, rmask, gmask, bmask, amask).toZig());
    }

    extern fn SDL_GetPixelFormatName(format: PixelFormat) ?[*:0]const u8;
    extern fn SDL_GetMasksForPixelFormatEnum(format: PixelFormat, bpp: *c_int, rmask: *u32, gmask: *u32, bmask: *u32, amask: *u32) Bool;
    extern fn SDL_GetPixelFormatEnumForMasks(bpp: c_int, rmask: u32, gmask: u32, bmask: u32, amask: u32) PixelFormat;
};

pub const Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

pub const Palette = extern struct {
    ncolors: c_int,
    colors: ?[*]Color,
    version: u32,
    refcount: c_int,

    /// Create a palette structure with the specified number of color entries.
    ///
    /// The palette entries are initialized to white.
    ///
    /// \param ncolors represents the number of color entries in the color palette
    /// \returns a new SDL_Palette structure on success or NULL on failure (e.g. if
    ///          there wasn't enough memory); call SDL_GetError() for more
    ///          information.
    ///
    pub fn create(n_colors: c_int) Error!*Palette {
        return SDL_CreatePalette(n_colors) orelse internal.emitError();
    }

    /// Set a range of colors in a palette.
    ///
    /// \param palette the SDL_Palette structure to modify
    /// \param colors an array of SDL_Color structures to copy into the palette
    /// \param firstcolor the index of the first palette entry to modify
    /// \param ncolors the number of entries to modify
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setColors(self: *Palette, colors: []const Color, first: c_int) Error!void {
        try internal.checkResult(SDL_SetPaletteColors(self, colors.ptr, first, @intCast(colors.len)));
    }

    /// Free a palette created with SDL_CreatePalette().
    ///
    /// \param palette the SDL_Palette structure to be freed
    ///
    pub fn destroy(self: *Palette) void {
        SDL_DestroyPalette(self);
    }

    extern fn SDL_CreatePalette(ncolors: c_int) ?*Palette;
    extern fn SDL_SetPaletteColors(palette: *Palette, colors: [*]const Color, firstcolor: c_int, ncolors: c_int) c_int;
    extern fn SDL_DestroyPalette(palette: *Palette) void;
};

pub const PixelFormatStruct = extern struct {
    format: u32,
    palette: ?*Palette,
    BitsPerPixel: u8,
    BytesPerPixel: u8,
    padding: [2]u8,
    Rmask: u32,
    Gmask: u32,
    Bmask: u32,
    Amask: u32,
    Rloss: u8,
    Gloss: u8,
    Bloss: u8,
    Aloss: u8,
    Rshift: u8,
    Gshift: u8,
    Bshift: u8,
    Ashift: u8,
    refcount: c_int,
    next: ?*PixelFormatStruct,

    /// Create an SDL_PixelFormat structure corresponding to a pixel format.
    ///
    /// Returned structure may come from a shared global cache (i.e. not newly
    /// allocated), and hence should not be modified, especially the palette. Weird
    /// errors such as `Blit combination not supported` may occur.
    ///
    /// \param pixel_format one of the SDL_PixelFormatEnum values
    /// \returns the new SDL_PixelFormat structure or NULL on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn create(format: PixelFormat) Error!*PixelFormatStruct {
        return SDL_CreatePixelFormat(format) orelse internal.emitError();
    }

    /// Set the palette for a pixel format structure.
    ///
    /// \param format the SDL_PixelFormat structure that will use the palette
    /// \param palette the SDL_Palette structure that will be used
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setPalette(self: *PixelFormatStruct, palette: *Palette) Error!void {
        try internal.checkResult(SDL_SetPixelFormatPalette(self, palette));
    }

    /// Map an RGB triple to an opaque pixel value for a given pixel format.
    ///
    /// This function maps the RGB color value to the specified pixel format and
    /// returns the pixel value best approximating the given RGB color value for
    /// the given pixel format.
    ///
    /// If the format has a palette (8-bit) the index of the closest matching color
    /// in the palette will be returned.
    ///
    /// If the specified pixel format has an alpha component it will be returned as
    /// all 1 bits (fully opaque).
    ///
    /// If the pixel format bpp (color depth) is less than 32-bpp then the unused
    /// upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    /// format the return value can be assigned to a Uint16, and similarly a Uint8
    /// for an 8-bpp format).
    ///
    /// \param format an SDL_PixelFormat structure describing the pixel format
    /// \param r the red component of the pixel in the range 0-255
    /// \param g the green component of the pixel in the range 0-255
    /// \param b the blue component of the pixel in the range 0-255
    /// \returns a pixel value
    ///
    pub fn mapRGB(self: *PixelFormatStruct, r: u8, g: u8, b: u8) u32 {
        return SDL_MapRGB(self, r, g, b);
    }

    /// Map an RGBA quadruple to a pixel value for a given pixel format.
    ///
    /// This function maps the RGBA color value to the specified pixel format and
    /// returns the pixel value best approximating the given RGBA color value for
    /// the given pixel format.
    ///
    /// If the specified pixel format has no alpha component the alpha value will
    /// be ignored (as it will be in formats with a palette).
    ///
    /// If the format has a palette (8-bit) the index of the closest matching color
    /// in the palette will be returned.
    ///
    /// If the pixel format bpp (color depth) is less than 32-bpp then the unused
    /// upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    /// format the return value can be assigned to a Uint16, and similarly a Uint8
    /// for an 8-bpp format).
    ///
    /// \param format an SDL_PixelFormat structure describing the format of the
    ///               pixel
    /// \param r the red component of the pixel in the range 0-255
    /// \param g the green component of the pixel in the range 0-255
    /// \param b the blue component of the pixel in the range 0-255
    /// \param a the alpha component of the pixel in the range 0-255
    /// \returns a pixel value
    ///
    pub fn mapRGBA(self: *PixelFormatStruct, r: u8, g: u8, b: u8, a: u8) u32 {
        return mapRGBA(self, r, g, b, a);
    }

    /// Get RGB values from a pixel in the specified format.
    ///
    /// This function uses the entire 8-bit [0..255] range when converting color
    /// components from pixel formats with less than 8-bits per RGB component
    /// (e.g., a completely white pixel in 16-bit RGB565 format would return [0xff,
    /// 0xff, 0xff] not [0xf8, 0xfc, 0xf8]).
    ///
    /// \param pixel a pixel value
    /// \param format an SDL_PixelFormat structure describing the format of the
    ///               pixel
    /// \param r a pointer filled in with the red component
    /// \param g a pointer filled in with the green component
    /// \param b a pointer filled in with the blue component
    ///
    pub fn getRGB(self: *const PixelFormatStruct, pixel: u32, r: *u8, g: *u8, b: *u8) void {
        SDL_GetRGB(pixel, self, r, g, b);
    }

    /// Get RGBA values from a pixel in the specified format.
    ///
    /// This function uses the entire 8-bit [0..255] range when converting color
    /// components from pixel formats with less than 8-bits per RGB component
    /// (e.g., a completely white pixel in 16-bit RGB565 format would return [0xff,
    /// 0xff, 0xff] not [0xf8, 0xfc, 0xf8]).
    ///
    /// If the surface has no alpha component, the alpha will be returned as 0xff
    /// (100% opaque).
    ///
    /// \param pixel a pixel value
    /// \param format an SDL_PixelFormat structure describing the format of the
    ///               pixel
    /// \param r a pointer filled in with the red component
    /// \param g a pointer filled in with the green component
    /// \param b a pointer filled in with the blue component
    /// \param a a pointer filled in with the alpha component
    ///
    pub fn getRGBA(self: *const PixelFormatStruct, pixel: u32, r: *u8, g: *u8, b: *u8, a: *u8) void {
        SDL_GetRGBA(pixel, self, r, g, b, a);
    }

    extern fn SDL_CreatePixelFormat(pixel_format: PixelFormat) ?*PixelFormatStruct;
    extern fn SDL_DestroyPixelFormat(format: *PixelFormatStruct) void;
    extern fn SDL_SetPixelFormatPalette(format: *PixelFormatStruct, palette: *Palette) c_int;
    extern fn SDL_MapRGB(format: *const PixelFormatStruct, r: u8, g: u8, b: u8) u32;
    extern fn SDL_MapRGBA(format: *const PixelFormatStruct, r: u8, g: u8, b: u8, a: u8) u32;
    extern fn SDL_GetRGB(pixel: u32, format: *const PixelFormatStruct, r: *u8, g: *u8, b: *u8) void;
    extern fn SDL_GetRGBA(pixel: u32, format: *const PixelFormatStruct, r: *u8, g: *u8, b: *u8, a: *u8) void;
};

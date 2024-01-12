const internal = @import("internal.zig");
const Error = internal.Error;
const Bool = internal.Bool;

const PropertiesID = @import("properties.zig").PropertiesID;

const pixels = @import("pixels.zig");
const PixelFormatStruct = pixels.PixelFormatStruct;
const PixelFormat = pixels.PixelFormat;
const Palette = pixels.Palette;

const BlendMode = @import("blendmode.zig").BlendMode;

const Rect = @import("rect.zig").Rect;

pub const SurfaceFlags = packed struct(u32) {
    /// Surface uses preallocated memory */
    prealloc: bool = false,
    /// Surface is RLE encoded */
    rleaccel: bool = false,
    /// Surface is referenced internally */
    dontfree: bool = false,
    /// Surface uses aligned memory */
    simd_aligned: bool = false,
    /// Surface uses properties */
    uses_properties: bool = false,

    __padding: u27 = 0,
};

pub const BlitMap = opaque {};

/// The type of function used for surface blitting functions.
///
pub const Blip = *const fn (*Surface, *const Rect, *Surface, *const Rect) callconv(.C) c_int;

pub const ScaleMode = enum(c_uint) {
    /// nearest pixel sampling */
    nearest,
    /// linear filtering */
    linear,
    /// anisotropic filtering */
    best,
};

/// A collection of pixels used in software blitting.
///
/// Pixels are arranged in memory in rows, with the top row first.
/// Each row occupies an amount of memory given by the pitch (sometimes
/// known as the row stride in non-SDL APIs).
///
/// Within each row, pixels are arranged from left to right until the
/// width is reached.
/// Each pixel occupies a number of bits appropriate for its format, with
/// most formats representing each pixel as one or more whole bytes
/// (in some indexed formats, instead multiple pixels are packed into
/// each byte), and a byte order given by the format.
/// After encoding all pixels, any remaining bytes to reach the pitch are
/// used as padding to reach a desired alignment, and have undefined contents.
///
/// \note  This structure should be treated as read-only, except for \c pixels,
///        which, if not NULL, contains the raw pixel data for the surface.
pub const Surface = extern struct {
    flags: SurfaceFlags,
    format: ?*PixelFormatStruct,
    w: c_int,
    h: c_int,
    pitch: c_int,
    pixels: ?*anyopaque,
    reserved: ?*anyopaque,
    locked: c_int,
    list_blitmap: ?*anyopaque,
    clip_rect: Rect,
    map: ?*BlitMap,
    refcount: c_int,

    /// Allocate a new RGB surface with a specific pixel format.
    ///
    /// \param width the width of the surface
    /// \param height the height of the surface
    /// \param format the SDL_PixelFormatEnum for the new surface's pixel format.
    /// \returns the new SDL_Surface structure that is created or NULL if it fails;
    ///          call SDL_GetError() for more information.
    ///
    pub fn create(width: c_int, height: c_int, format: PixelFormat) Error!*Surface {
        return SDL_CreateSurface(width, height, format) orelse internal.emitError();
    }

    /// Allocate a new RGB surface with a specific pixel format and existing pixel
    /// data.
    ///
    /// No copy is made of the pixel data. Pixel data is not managed automatically;
    /// you must free the surface before you free the pixel data.
    ///
    /// Pitch is the offset in bytes from one row of pixels to the next, e.g.
    /// `width*4` for `SDL_PIXELFORMAT_RGBA8888`.
    ///
    /// You may pass NULL for pixels and 0 for pitch to create a surface that you
    /// will fill in with valid values later.
    ///
    /// \param pixels a pointer to existing pixel data
    /// \param width the width of the surface
    /// \param height the height of the surface
    /// \param pitch the pitch of the surface in bytes
    /// \param format the SDL_PixelFormatEnum for the new surface's pixel format.
    /// \returns the new SDL_Surface structure that is created or NULL if it fails;
    ///          call SDL_GetError() for more information.
    ///
    pub fn createFrom(data: *anyopaque, width: c_int, height: c_int, pitch: c_int, format: PixelFormat) Error!*Surface {
        return SDL_CreateSurfaceFrom(data, width, height, pitch, format) orelse internal.emitError();
    }

    /// Get the properties associated with a surface.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \returns a valid property ID on success or 0 on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getProperties(self: *Surface) Error!PropertiesID {
        const props = SDL_GetSurfaceProperties(self);
        try internal.assertResult(props != .invalid);
        return props;
    }

    /// Set the palette used by a surface.
    ///
    /// A single palette can be shared with many surfaces.
    ///
    /// \param surface the SDL_Surface structure to update
    /// \param palette the SDL_Palette structure to use
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setPalette(self: *Surface, palette: *Palette) Error!void {
        try internal.checkResult(SDL_SetSurfacePalette(self, palette));
    }

    /// Set up a surface for directly accessing the pixels.
    ///
    /// Between calls to SDL_LockSurface() / SDL_UnlockSurface(), you can write to
    /// and read from `surface->pixels`, using the pixel format stored in
    /// `surface->format`. Once you are done accessing the surface, you should use
    /// SDL_UnlockSurface() to release it.
    ///
    /// Not all surfaces require locking. If `SDL_MUSTLOCK(surface)` evaluates to
    /// 0, then you can read and write to the surface at any time, and the pixel
    /// format of the surface will not change.
    ///
    /// \param surface the SDL_Surface structure to be locked
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn lock(self: *Surface) Error!void {
        try internal.checkResult(SDL_LockSurface(self));
    }

    /// Release a surface after directly accessing the pixels.
    ///
    /// \param surface the SDL_Surface structure to be unlocked
    ///
    pub fn unlock(self: *Surface) void {
        SDL_UnlockSurface(self);
    }

    /// Set the RLE acceleration hint for a surface.
    ///
    /// If RLE is enabled, color key and alpha blending blits are much faster, but
    /// the surface must be locked before directly accessing the pixels.
    ///
    /// \param surface the SDL_Surface structure to optimize
    /// \param flag 0 to disable, non-zero to enable RLE acceleration
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setRLE(self: *Surface, enable: bool) Error!void {
        try internal.checkResult(SDL_SetSurfaceRLE(self, if (enable) 1 else 0));
    }

    /// Returns whether the surface is RLE enabled
    ///
    /// It is safe to pass a NULL `surface` here; it will return SDL_FALSE.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \returns SDL_TRUE if the surface is RLE enabled, SDL_FALSE otherwise.
    ///
    pub fn hasRLE(self: *Surface) bool {
        return SDL_SurfaceHasRLE(self).toZig();
    }

    /// Set the color key (transparent pixel) in a surface.
    ///
    /// The color key defines a pixel value that will be treated as transparent in
    /// a blit. For example, one can use this to specify that cyan pixels should be
    /// considered transparent, and therefore not rendered.
    ///
    /// It is a pixel of the format used by the surface, as generated by
    /// SDL_MapRGB().
    ///
    /// RLE acceleration can substantially speed up blitting of images with large
    /// horizontal runs of transparent pixels. See SDL_SetSurfaceRLE() for details.
    ///
    /// \param surface the SDL_Surface structure to update
    /// \param flag SDL_TRUE to enable color key, SDL_FALSE to disable color key
    /// \param key the transparent pixel
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setColorKey(self: *Surface, enabled: bool, key: u32) Error!void {
        try internal.checkResult(SDL_SetSurfaceColorKey(self, if (enabled) 1 else 0, key));
    }

    /// Returns whether the surface has a color key
    ///
    /// It is safe to pass a NULL `surface` here; it will return SDL_FALSE.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \returns SDL_TRUE if the surface has a color key, SDL_FALSE otherwise.
    ///
    pub fn hasColorKey(self: *Surface) bool {
        return SDL_SurfaceHasColorKey(self).toZig();
    }

    /// Get the color key (transparent pixel) for a surface.
    ///
    /// The color key is a pixel of the format used by the surface, as generated by
    /// SDL_MapRGB().
    ///
    /// If the surface doesn't have color key enabled this function returns -1.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \param key a pointer filled in with the transparent pixel
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getColorKey(self: *Surface, key: *u32) Error!void {
        try internal.checkResult(SDL_GetSurfaceColorKey(self, key));
    }

    /// Set an additional color value multiplied into blit operations.
    ///
    /// When this surface is blitted, during the blit operation each source color
    /// channel is modulated by the appropriate color value according to the
    /// following formula:
    ///
    /// `srcC = srcC * (color / 255)`
    ///
    /// \param surface the SDL_Surface structure to update
    /// \param r the red color value multiplied into blit operations
    /// \param g the green color value multiplied into blit operations
    /// \param b the blue color value multiplied into blit operations
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setColorMod(self: *Surface, r: u8, g: u8, b: u8) Error!void {
        try internal.checkResult(SDL_SetSurfaceColorMod(self, r, g, b));
    }

    /// Get the additional color value multiplied into blit operations.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \param r a pointer filled in with the current red color value
    /// \param g a pointer filled in with the current green color value
    /// \param b a pointer filled in with the current blue color value
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getColorMod(self: *Surface, r: *u8, g: *u8, b: *u8) Error!void {
        try internal.checkResult(SDL_GetSurfaceColorMod(self, r, g, b));
    }

    /// Set an additional alpha value used in blit operations.
    ///
    /// When this surface is blitted, during the blit operation the source alpha
    /// value is modulated by this alpha value according to the following formula:
    ///
    /// `srcA = srcA * (alpha / 255)`
    ///
    /// \param surface the SDL_Surface structure to update
    /// \param alpha the alpha value multiplied into blit operations
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setAlphaMod(self: *Surface, alpha: u8) Error!void {
        try internal.checkResult(SDL_SetSurfaceAlphaMod(self, alpha));
    }

    /// Get the additional alpha value used in blit operations.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \param alpha a pointer filled in with the current alpha value
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getAlphaMod(self: *Surface, alpha: *u8) Error!void {
        try internal.checkResult(SDL_GetSurfaceAlphaMod(self, alpha));
    }

    /// Set the blend mode used for blit operations.
    ///
    /// To copy a surface to another surface (or texture) without blending with the
    /// existing data, the blendmode of the SOURCE surface should be set to
    /// `SDL_BLENDMODE_NONE`.
    ///
    /// \param surface the SDL_Surface structure to update
    /// \param blendMode the SDL_BlendMode to use for blit blending
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn setBlendMode(self: *Surface, blend_mode: BlendMode) Error!void {
        try internal.checkResult(SDL_SetSurfaceBlendMode(self, blend_mode));
    }

    /// Get the blend mode used for blit operations.
    ///
    /// \param surface the SDL_Surface structure to query
    /// \param blendMode a pointer filled in with the current SDL_BlendMode
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getBlendMode(self: *Surface, blend_mode: *BlendMode) Error!void {
        try internal.checkResult(SDL_GetSurfaceBlendMode(self, blend_mode));
    }

    /// Set the clipping rectangle for a surface.
    ///
    /// When `surface` is the destination of a blit, only the area within the clip
    /// rectangle is drawn into.
    ///
    /// Note that blits are automatically clipped to the edges of the source and
    /// destination surfaces.
    ///
    /// \param surface the SDL_Surface structure to be clipped
    /// \param rect the SDL_Rect structure representing the clipping rectangle, or
    ///             NULL to disable clipping
    /// \returns SDL_TRUE if the rectangle intersects the surface, otherwise
    ///          SDL_FALSE and blits will be completely clipped.
    ///
    pub fn setClipRect(self: *Surface, rect: *const Rect) bool {
        return SDL_SetSurfaceClipRect(self, rect).toZig();
    }

    /// Get the clipping rectangle for a surface.
    ///
    /// When `surface` is the destination of a blit, only the area within the clip
    /// rectangle is drawn into.
    ///
    /// \param surface the SDL_Surface structure representing the surface to be
    ///                clipped
    /// \param rect an SDL_Rect structure filled in with the clipping rectangle for
    ///             the surface
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn getClipRect(self: *Surface, rect: *Rect) Error!void {
        try internal.checkResult(SDL_GetSurfaceClipRect(self, rect));
    }

    /// Creates a new surface identical to the existing surface.
    ///
    /// The returned surface should be freed with SDL_DestroySurface().
    ///
    /// \param surface the surface to duplicate.
    /// \returns a copy of the surface, or NULL on failure; call SDL_GetError() for
    ///          more information.
    ///
    pub fn duplicate(self: *Surface) Error!*Surface {
        return SDL_DuplicateSurface(self) orelse internal.emitError();
    }

    /// Copy an existing surface to a new surface of the specified format.
    ///
    /// This function is used to optimize images for faster *repeat* blitting. This
    /// is accomplished by converting the original and storing the result as a new
    /// surface. The new, optimized surface can then be used as the source for
    /// future blits, making them faster.
    ///
    /// \param surface the existing SDL_Surface structure to convert
    /// \param format the SDL_PixelFormat structure that the new surface is
    ///               optimized for
    /// \returns the new SDL_Surface structure that is created or NULL if it fails;
    ///          call SDL_GetError() for more information.
    ///
    pub fn convert(self: *Surface, format: *const PixelFormatStruct) Error!*Surface {
        return SDL_ConvertSurface(self, format) orelse internal.emitError();
    }

    /// Copy an existing surface to a new surface of the specified format enum.
    ///
    /// This function operates just like SDL_ConvertSurface(), but accepts an
    /// SDL_PixelFormatEnum value instead of an SDL_PixelFormat structure. As such,
    /// it might be easier to call but it doesn't have access to palette
    /// information for the destination surface, in case that would be important.
    ///
    /// \param surface the existing SDL_Surface structure to convert
    /// \param pixel_format the SDL_PixelFormatEnum that the new surface is
    ///                     optimized for
    /// \returns the new SDL_Surface structure that is created or NULL if it fails;
    ///          call SDL_GetError() for more information.
    ///
    pub fn convertFormat(self: *Surface, pixel_format: PixelFormat) Error!*Surface {
        return SDL_ConvertSurfaceFormat(self, pixel_format) orelse internal.emitError();
    }

    /// Perform a fast fill of a rectangle with a specific color.
    ///
    /// `color` should be a pixel of the format used by the surface, and can be
    /// generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
    /// alpha component then the destination is simply filled with that alpha
    /// information, no blending takes place.
    ///
    /// If there is a clip rectangle set on the destination (set via
    /// SDL_SetSurfaceClipRect()), then this function will fill based on the
    /// intersection of the clip rectangle and `rect`.
    ///
    /// \param dst the SDL_Surface structure that is the drawing target
    /// \param rect the SDL_Rect structure representing the rectangle to fill, or
    ///             NULL to fill the entire surface
    /// \param color the color to fill with
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn fillRect(self: *Surface, rect: *const Rect, color: u32) Error!void {
        try internal.checkResult(SDL_FillSurfaceRect(self, rect, color));
    }

    /// Perform a fast fill of a set of rectangles with a specific color.
    ///
    /// `color` should be a pixel of the format used by the surface, and can be
    /// generated by SDL_MapRGB() or SDL_MapRGBA(). If the color value contains an
    /// alpha component then the destination is simply filled with that alpha
    /// information, no blending takes place.
    ///
    /// If there is a clip rectangle set on the destination (set via
    /// SDL_SetSurfaceClipRect()), then this function will fill based on the
    /// intersection of the clip rectangle and `rect`.
    ///
    /// \param dst the SDL_Surface structure that is the drawing target
    /// \param rects an array of SDL_Rects representing the rectangles to fill.
    /// \param count the number of rectangles in the array
    /// \param color the color to fill with
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn fillRects(self: *Surface, rects: []const Rect, color: u32) Error!void {
        try internal.checkResult(SDL_FillSurfaceRects(self, rects.ptr, @intCast(rects.len), color));
    }

    /// Performs a fast blit from the source surface to the destination surface.
    ///
    /// This assumes that the source and destination rectangles are the same size.
    /// If either `srcrect` or `dstrect` are NULL, the entire surface (`src` or
    /// `dst`) is copied. The final blit rectangles are saved in `srcrect` and
    /// `dstrect` after all clipping is performed.
    ///
    /// The blit function should not be called on a locked surface.
    ///
    /// The blit semantics for surfaces with and without blending and colorkey are
    /// defined as follows:
    ///
    /// ```c
    ///    RGBA->RGB:
    ///      Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source alpha-channel and per-surface alpha)
    ///       SDL_SRCCOLORKEY ignored.
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB.
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       RGB values of the source color key, ignoring alpha in the
    ///       comparison.
    ///
    ///   RGB->RGBA:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source per-surface alpha)
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB, set destination alpha to source per-surface alpha value.
    ///     both:
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       source color key.
    ///
    ///   RGBA->RGBA:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source alpha-channel and per-surface alpha)
    ///       SDL_SRCCOLORKEY ignored.
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy all of RGBA to the destination.
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       RGB values of the source color key, ignoring alpha in the
    ///       comparison.
    ///
    ///   RGB->RGB:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source per-surface alpha)
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB.
    ///     both:
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       source color key.
    /// ```
    ///
    /// \param src the SDL_Surface structure to be copied from
    /// \param srcrect the SDL_Rect structure representing the rectangle to be
    ///                copied, or NULL to copy the entire surface
    /// \param dst the SDL_Surface structure that is the blit target
    /// \param dstrect the SDL_Rect structure representing the x and y position in
    ///                the destination surface. On input the width and height are
    ///                ignored (taken from srcrect), and on output this is filled
    ///                in with the actual rectangle used after clipping.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn blit(self: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *Rect) Error!void {
        try internal.checkResult(SDL_BlitSurface(self, srcrect, dst, dstrect));
    }

    /// Performs a fast blit from the source surface to the destination surface.
    ///
    /// This assumes that the source and destination rectangles are the same size.
    /// If either `srcrect` or `dstrect` are NULL, the entire surface (`src` or
    /// `dst`) is copied. The final blit rectangles are saved in `srcrect` and
    /// `dstrect` after all clipping is performed.
    ///
    /// The blit function should not be called on a locked surface.
    ///
    /// The blit semantics for surfaces with and without blending and colorkey are
    /// defined as follows:
    ///
    /// ```c
    ///    RGBA->RGB:
    ///      Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source alpha-channel and per-surface alpha)
    ///       SDL_SRCCOLORKEY ignored.
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB.
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       RGB values of the source color key, ignoring alpha in the
    ///       comparison.
    ///
    ///   RGB->RGBA:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source per-surface alpha)
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB, set destination alpha to source per-surface alpha value.
    ///     both:
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       source color key.
    ///
    ///   RGBA->RGBA:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source alpha-channel and per-surface alpha)
    ///       SDL_SRCCOLORKEY ignored.
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy all of RGBA to the destination.
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       RGB values of the source color key, ignoring alpha in the
    ///       comparison.
    ///
    ///   RGB->RGB:
    ///     Source surface blend mode set to SDL_BLENDMODE_BLEND:
    ///       alpha-blend (using the source per-surface alpha)
    ///     Source surface blend mode set to SDL_BLENDMODE_NONE:
    ///       copy RGB.
    ///     both:
    ///       if SDL_SRCCOLORKEY set, only copy the pixels matching the
    ///       source color key.
    /// ```
    ///
    /// \param src the SDL_Surface structure to be copied from
    /// \param srcrect the SDL_Rect structure representing the rectangle to be
    ///                copied, or NULL to copy the entire surface
    /// \param dst the SDL_Surface structure that is the blit target
    /// \param dstrect the SDL_Rect structure representing the x and y position in
    ///                the destination surface. On input the width and height are
    ///                ignored (taken from srcrect), and on output this is filled
    ///                in with the actual rectangle used after clipping.
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn blitUnchecked(self: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect) Error!void {
        try internal.checkResult(SDL_BlitSurfaceUnchecked(self, srcrect, dst, dstrect));
    }

    /// Perform stretch blit between two surfaces of the same format.
    ///
    /// Using SDL_SCALEMODE_NEAREST: fast, low quality. Using SDL_SCALEMODE_LINEAR:
    /// bilinear scaling, slower, better quality, only 32BPP.
    ///
    /// \param src the SDL_Surface structure to be copied from
    /// \param srcrect the SDL_Rect structure representing the rectangle to be
    ///                copied
    /// \param dst the SDL_Surface structure that is the blit target
    /// \param dstrect the SDL_Rect structure representing the target rectangle in
    ///                the destination surface
    /// \param scaleMode scale algorithm to be used
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn softStretch(self: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect, scaleMode: ScaleMode) Error!void {
        try internal.checkResult(SDL_SoftStretch(self, srcrect, dst, dstrect, scaleMode));
    }

    /// Perform a scaled surface copy to a destination surface.
    ///
    /// \param src the SDL_Surface structure to be copied from
    /// \param srcrect the SDL_Rect structure representing the rectangle to be
    ///                copied
    /// \param dst the SDL_Surface structure that is the blit target
    /// \param dstrect the SDL_Rect structure representing the target rectangle in
    ///                the destination surface, filled with the actual rectangle
    ///                used after clipping
    /// \param scaleMode scale algorithm to be used
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn blitScaled(self: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *Rect, scaleMode: ScaleMode) Error!void {
        try internal.checkResult(SDL_BlitSurfaceScaled(self, srcrect, dst, dstrect, scaleMode));
    }

    /// Perform low-level surface scaled blitting only.
    ///
    /// This is a semi-private function and it performs low-level surface blitting,
    /// assuming the input rectangles have already been clipped.
    ///
    /// \param src the SDL_Surface structure to be copied from
    /// \param srcrect the SDL_Rect structure representing the rectangle to be
    ///                copied
    /// \param dst the SDL_Surface structure that is the blit target
    /// \param dstrect the SDL_Rect structure representing the target rectangle in
    ///                the destination surface
    /// \param scaleMode scale algorithm to be used
    /// \returns 0 on success or a negative error code on failure; call
    ///          SDL_GetError() for more information.
    ///
    pub fn blitUncheckedScaled(self: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect, scaleMode: ScaleMode) Error!void {
        try internal.checkResult(SDL_BlitSurfaceUncheckedScaled(self, srcrect, dst, dstrect, scaleMode));
    }

    /// Free an RGB surface.
    ///
    /// It is safe to pass NULL to this function.
    ///
    /// /param surface the SDL_Surface to free.
    ///
    pub fn destroy(self: *Surface) void {
        SDL_DestroySurface(self);
    }

    extern fn SDL_CreateSurface(width: c_int, height: c_int, format: PixelFormat) ?*Surface;
    extern fn SDL_CreateSurfaceFrom(pixels: *anyopaque, width: c_int, height: c_int, pitch: c_int, format: PixelFormat) ?*Surface;
    extern fn SDL_GetSurfaceProperties(surface: *Surface) PropertiesID;
    extern fn SDL_SetSurfacePalette(surface: *Surface, palette: *Palette) c_int;
    extern fn SDL_LockSurface(surface: *Surface) c_int;
    extern fn SDL_UnlockSurface(surface: *Surface) void;
    extern fn SDL_SetSurfaceRLE(surface: *Surface, flag: c_int) c_int;
    extern fn SDL_SurfaceHasRLE(surface: *Surface) Bool;
    extern fn SDL_SetSurfaceColorKey(surface: *Surface, flag: c_int, key: u32) c_int;
    extern fn SDL_SurfaceHasColorKey(surface: *Surface) Bool;
    extern fn SDL_GetSurfaceColorKey(surface: *Surface, key: *u32) c_int;
    extern fn SDL_SetSurfaceColorMod(surface: *Surface, r: u8, g: u8, b: u8) c_int;
    extern fn SDL_GetSurfaceColorMod(surface: *Surface, r: *u8, g: *u8, b: *u8) c_int;
    extern fn SDL_SetSurfaceAlphaMod(surface: *Surface, alpha: u8) c_int;
    extern fn SDL_GetSurfaceAlphaMod(surface: *Surface, alpha: *u8) c_int;
    extern fn SDL_SetSurfaceBlendMode(surface: *Surface, blendMode: BlendMode) c_int;
    extern fn SDL_GetSurfaceBlendMode(surface: *Surface, blendMode: *BlendMode) c_int;
    extern fn SDL_SetSurfaceClipRect(surface: *Surface, rect: *const Rect) Bool;
    extern fn SDL_GetSurfaceClipRect(surface: *Surface, rect: *Rect) c_int;
    extern fn SDL_DuplicateSurface(surface: *Surface) ?*Surface;
    extern fn SDL_ConvertSurface(surface: *Surface, format: *const PixelFormatStruct) ?*Surface;
    extern fn SDL_ConvertSurfaceFormat(surface: *Surface, pixel_format: PixelFormat) ?*Surface;
    extern fn SDL_FillSurfaceRect(dst: *Surface, rect: *const Rect, color: u32) c_int;
    extern fn SDL_FillSurfaceRects(dst: *Surface, rects: [*]const Rect, count: c_int, color: u32) c_int;
    extern fn SDL_BlitSurface(src: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *Rect) c_int;
    extern fn SDL_BlitSurfaceUnchecked(src: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect) c_int;
    extern fn SDL_SoftStretch(src: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect, scaleMode: ScaleMode) c_int;
    extern fn SDL_BlitSurfaceScaled(src: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *Rect, scaleMode: ScaleMode) c_int;
    extern fn SDL_BlitSurfaceUncheckedScaled(src: *Surface, srcrect: *const Rect, dst: *Surface, dstrect: *const Rect, scaleMode: ScaleMode) c_int;
    extern fn SDL_DestroySurface(surface: *Surface) void;
};

// pub extern fn SDL_PremultiplyAlpha(width: c_int, height: c_int, src_format: PixelFormat, src: ?*const anyopaque, src_pitch: c_int, dst_format: PixelFormat, dst: ?*anyopaque, dst_pitch: c_int) c_int;
// pub extern fn SDL_ConvertPixels(width: c_int, height: c_int, src_format: PixelFormat, src: ?*const anyopaque, src_pitch: c_int, dst_format: PixelFormat, dst: ?*anyopaque, dst_pitch: c_int) c_int;
// pub extern fn SDL_SetYUVConversionMode(mode: SDL_YUV_CONVERSION_MODE) void;
// pub extern fn SDL_GetYUVConversionMode() SDL_YUV_CONVERSION_MODE;
// pub extern fn SDL_GetYUVConversionModeForResolution(width: c_int, height: c_int) SDL_YUV_CONVERSION_MODE;

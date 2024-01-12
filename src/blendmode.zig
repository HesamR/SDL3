/// The blend mode used in SDL_RenderTexture() and drawing operations.
pub const BlendMode = enum(c_uint) {
    /// no blending
    /// dstRGBA = srcRGBA
    none = 0x00000000,

    /// alpha blending
    /// dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
    /// dstA = srcA + (dstA * (1-srcA)) */
    blend = 0x00000001,

    /// additive blending
    /// dstRGB = (srcRGB * srcA) + dstRGB
    /// dstA = dstA */
    add = 0x00000002,

    /// color modulate
    /// dstRGB = srcRGB * dstRGB
    /// dstA = dstA */
    mod = 0x00000004,

    /// color multiply
    /// dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA))
    /// dstA = dstA */
    mul = 0x00000008,

    invalid = 0x7FFFFFFF,

    _,

    /// Compose a custom blend mode for renderers.
    ///
    /// The functions SDL_SetRenderDrawBlendMode and SDL_SetTextureBlendMode accept
    /// the SDL_BlendMode returned by this function if the renderer supports it.
    ///
    /// A blend mode controls how the pixels from a drawing operation (source) get
    /// combined with the pixels from the render target (destination). First, the
    /// components of the source and destination pixels get multiplied with their
    /// blend factors. Then, the blend operation takes the two products and
    /// calculates the result that will get stored in the render target.
    ///
    /// Expressed in pseudocode, it would look like this:
    ///
    /// ```c
    /// dstRGB = colorOperation(srcRGB * srcColorFactor, dstRGB * dstColorFactor);
    /// dstA = alphaOperation(srcA * srcAlphaFactor, dstA * dstAlphaFactor);
    /// ```
    ///
    /// Where the functions `colorOperation(src, dst)` and `alphaOperation(src,
    /// dst)` can return one of the following:
    ///
    /// - `src + dst`
    /// - `src - dst`
    /// - `dst - src`
    /// - `min(src, dst)`
    /// - `max(src, dst)`
    ///
    /// The red, green, and blue components are always multiplied with the first,
    /// second, and third components of the SDL_BlendFactor, respectively. The
    /// fourth component is not used.
    ///
    /// The alpha component is always multiplied with the fourth component of the
    /// SDL_BlendFactor. The other components are not used in the alpha
    /// calculation.
    ///
    /// Support for these blend modes varies for each renderer. To check if a
    /// specific SDL_BlendMode is supported, create a renderer and pass it to
    /// either SDL_SetRenderDrawBlendMode or SDL_SetTextureBlendMode. They will
    /// return with an error if the blend mode is not supported.
    ///
    /// This list describes the support of custom blend modes for each renderer in
    /// SDL 2.0.6. All renderers support the four blend modes listed in the
    /// SDL_BlendMode enumeration.
    ///
    /// - **direct3d**: Supports all operations with all factors. However, some
    ///   factors produce unexpected results with `SDL_BLENDOPERATION_MINIMUM` and
    ///   `SDL_BLENDOPERATION_MAXIMUM`.
    /// - **direct3d11**: Same as Direct3D 9.
    /// - **opengl**: Supports the `SDL_BLENDOPERATION_ADD` operation with all
    ///   factors. OpenGL versions 1.1, 1.2, and 1.3 do not work correctly with SDL
    ///   2.0.6.
    /// - **opengles**: Supports the `SDL_BLENDOPERATION_ADD` operation with all
    ///   factors. Color and alpha factors need to be the same. OpenGL ES 1
    ///   implementation specific: May also support `SDL_BLENDOPERATION_SUBTRACT`
    ///   and `SDL_BLENDOPERATION_REV_SUBTRACT`. May support color and alpha
    ///   operations being different from each other. May support color and alpha
    ///   factors being different from each other.
    /// - **opengles2**: Supports the `SDL_BLENDOPERATION_ADD`,
    ///   `SDL_BLENDOPERATION_SUBTRACT`, `SDL_BLENDOPERATION_REV_SUBTRACT`
    ///   operations with all factors.
    /// - **psp**: No custom blend mode support.
    /// - **software**: No custom blend mode support.
    ///
    /// Some renderers do not provide an alpha component for the default render
    /// target. The `SDL_BLENDFACTOR_DST_ALPHA` and
    /// `SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA` factors do not have an effect in this
    /// case.
    ///
    /// \param srcColorFactor the SDL_BlendFactor applied to the red, green, and
    ///                       blue components of the source pixels
    /// \param dstColorFactor the SDL_BlendFactor applied to the red, green, and
    ///                       blue components of the destination pixels
    /// \param colorOperation the SDL_BlendOperation used to combine the red,
    ///                       green, and blue components of the source and
    ///                       destination pixels
    /// \param srcAlphaFactor the SDL_BlendFactor applied to the alpha component of
    ///                       the source pixels
    /// \param dstAlphaFactor the SDL_BlendFactor applied to the alpha component of
    ///                       the destination pixels
    /// \param alphaOperation the SDL_BlendOperation used to combine the alpha
    ///                       component of the source and destination pixels
    /// \returns an SDL_BlendMode that represents the chosen factors and
    ///          operations.
    ///
    pub fn compose(src: BlendFactor, dst: BlendFactor, op: BlendOperation, src_alpha: BlendFactor, dst_alpha: BlendFactor, op_alpha: BlendOperation) BlendMode {
        return SDL_ComposeCustomBlendMode(src, dst, op, src_alpha, dst_alpha, op_alpha);
    }

    extern fn SDL_ComposeCustomBlendMode(src: BlendFactor, dst: BlendFactor, op: BlendOperation, src_alpha: BlendFactor, dst_alpha: BlendFactor, op_alpha: BlendOperation) BlendMode;
};

pub const BlendOperation = enum(c_uint) {
    /// dst + src: supported by all renderers */
    add = 0x1,
    /// dst - src : supported by D3D9, D3D11, OpenGL, OpenGLES */
    subtract = 0x2,
    /// src - dst : supported by D3D9, D3D11, OpenGL, OpenGLES */
    rev_subtract = 0x3,
    /// min(dst, src) : supported by D3D9, D3D11 */
    minimum = 0x4,
    /// max(dst, src) : supported by D3D9, D3D11 */
    maximum = 0x5,
};

pub const BlendFactor = enum(c_uint) {
    /// 0, 0, 0, 0 */
    zero = 0x1,
    /// 1, 1, 1, 1 */
    one = 0x2,
    /// srcR, srcG, srcB, srcA */
    src_color = 0x3,
    /// 1-srcR, 1-srcG, 1-srcB, 1-srcA */
    one_minus_src_color = 0x4,
    /// srcA, srcA, srcA, srcA */
    src_alpha = 0x5,
    /// 1-srcA, 1-srcA, 1-srcA, 1-srcA */
    one_minus_src_alpha = 0x6,
    /// dstR, dstG, dstB, dstA */
    dst_color = 0x7,
    /// 1-dstR, 1-dstG, 1-dstB, 1-dstA */
    one_minus_dst_color = 0x8,
    /// dstA, dstA, dstA, dstA */
    dst_alpha = 0x9,
    /// 1-dstA, 1-dstA, 1-dstA, 1-dstA */
    one_minus_dst_alpha = 0xA,
};

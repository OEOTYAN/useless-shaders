$input a_color0, a_position, a_texcoord0
$output v_texcoord0, v_color0, v_linearClampBounds

#include <bgfx_shader.sh>

uniform vec4 TintColor;
uniform vec4 HudOpacity;
uniform vec4 OutlineCutoff;
uniform vec4 GlyphCutoff;
uniform vec4 GlyphSmoothRadius;
uniform vec4 ShadowSmoothRadius;
uniform vec4 ShadowColor;
uniform vec4 OutlineColor;
uniform vec4 ShadowOffset;
uniform vec4 HalfTexelOffset;

#ifndef FONT_TYPE_TRUE_TYPE
bool NeedsLinearClamp() {
    #ifndef FONT_TYPE_MSDF
    return true;
    #else
    return GlyphSmoothRadius.x > 0.00095;
    #endif
}
#endif

void main() {
    const float GLYPH_SIZE = 1.0 / 16.0;

    vec2 texCoord = a_texcoord0;
#ifndef FONT_TYPE_TRUE_TYPE
    int corner = int(a_position.z);
    bool isRight = corner == 1 || corner == 2;
    bool isBottom = corner == 0 || corner == 1;
    texCoord.x += isRight ? GLYPH_SIZE : 0.0;
    texCoord.y += isBottom ? GLYPH_SIZE : 0.0;
#endif

    vec4 linearClampBounds = vec4(0.0, 0.0, 1.0, 1.0);
#ifndef FONT_TYPE_TRUE_TYPE
    if(NeedsLinearClamp()) {
        linearClampBounds.xy = a_texcoord0 + HalfTexelOffset.x;
        linearClampBounds.zw = a_texcoord0 + GLYPH_SIZE - HalfTexelOffset.x;
    }
#endif

    v_texcoord0 = texCoord;
    v_linearClampBounds = linearClampBounds;
    v_color0 = a_color0;
    gl_Position = mul(u_modelViewProj, vec4(a_position.xy, 0.0, 1.0));
}

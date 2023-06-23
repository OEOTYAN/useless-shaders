//for Actor ActorTint ActorMultiTexture ActorGlint
//Not yet completed, does not support ActorBanner at this time and may have other issues

$input v_color0, v_fog, v_light, v_texcoord0
#ifdef BANNER
    $input v_texcoords
#endif
#ifdef GLINT
    $input v_layerUv
#endif

#include <bgfx_shader.sh>

uniform vec4 ColorBased;
uniform vec4 ChangeColor;
uniform vec4 UseAlphaRewrite;
uniform vec4 TintedAlphaTestEnabled;
uniform vec4 MatColor;
uniform vec4 OverlayColor;
uniform vec4 TileLightColor;
uniform vec4 MultiplicativeTintColor;
uniform vec4 FogColor;
uniform vec4 FogControl;
uniform vec4 ActorFPEpsilon;
uniform vec4 LightDiffuseColorAndIntensity;
uniform vec4 LightWorldSpaceDirection;
uniform vec4 HudOpacity;
uniform vec4 UVAnimation;
uniform mat4 Bones[8];
//ActorBanner
uniform vec4 BannerColors[7];
uniform vec4 BannerUVOffsetsAndScales[7];
//ActorGlint
uniform vec4 UVScale;
uniform vec4 GlintColor;

SAMPLER2D(s_MatTexture, 0);
SAMPLER2D(s_MatTexture1, 1);
//ActorMultiTexture
SAMPLER2D(s_MatTexture2, 2);

vec4 glintBlend(vec4 dest, vec4 source) {
	// glBlendFuncSeparate(GL_SRC_COLOR, GL_ONE, GL_ONE, GL_ZERO)
    return vec4(source.rgb * source.rgb, abs(source.a)) + vec4(dest.rgb, 0.0);
}

#ifdef EMISSIVE
    #ifdef EMISSIVE_ONLY
        #define NEEDS_DISCARD(C) (C.a < 0.00390625 || C.a > 0.9960938 )
    #else
        #define NEEDS_DISCARD(C) (dot (C, vec4(1.0, 1.0, 1.0, 1.0)) < 0.00390625)
    #endif
#else
    #if defined(CHANGE_COLOR) || defined(CHANGE_COLOR_MULTI)
        #define NEEDS_DISCARD(C) (C.a < 0.5)
    #else
        #define NEEDS_DISCARD(C) (C.a < 0.00390625)
    #endif
#endif

void main() {
#ifdef DEPTH_ONLY
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    return;
#endif

    vec4 color;

    color = MatColor * texture2D(s_MatTexture, v_texcoord0);

#ifdef MASKED_MULTITEXTURE
    vec4 markings = texture2D(s_MatTexture1, v_texcoord0);

	// If markings has a non-black color and no alpha, use color; otherwise use markings 
    float maskedTexture = float(dot(markings.rgb, vec3(1.0, 1.0, 1.0)) * (1.0 - markings.a) > 0.0);
    color = mix(markings, color, maskedTexture);
#endif // MASKED_MULTITEXTURE

#if defined(ALPHA_TEST) && !defined(MULTI_TEXTURE) && !defined(TINT)
    vec4 color_cmp;
    color_cmp.rgb = color.rgb;
    color_cmp.a = mix(color.a, (color.a * OverlayColor.a), TintedAlphaTestEnabled.r);
    if(NEEDS_DISCARD(color_cmp))
        discard;
#endif // ALPHA_TEST

#ifdef CHANGE_COLOR_MULTI
	// Texture is a mask for tinting with two colors
    vec2 colorMask = color.rg;

	// Apply the base color tint
    color.rgb = colorMask.rrr * ChangeColor.rgb;

	// Apply the secondary color mask and tint so long as its grayscale value is not 0
    color.rgb = mix(color.rgb, colorMask.ggg * MultiplicativeTintColor.rgb, ceil(colorMask.g));
#else

#ifdef CHANGE_COLOR
    color.rgb = mix(color.rgb, color.rgb * ChangeColor.rgb, color.a);
    color.a *= ChangeColor.a;
#endif

#endif// CHANGE_COLOR_MULTI

#ifdef MULTITEXTURE
    vec4 tex1 = texture2D(s_MatTexture1, v_texcoord0);
    vec4 armor = texture2D(s_MatTexture2, v_texcoord0);
    color.rgb = mix(color.rgb, tex1.rgb, tex1.a);

#ifdef COLOR_SECOND_TEXTURE
    if(armor.a > 0.0) {
        color.rgb = mix(armor.rgb, armor.rgb * ChangeColor.rgb, armor.a)
    }
#else
    color.rgb = mix(color.rgb, armor.rgb, armor.a);
#endif
#ifdef ALPHA_TEST
    if(color.a < 0.5 && tex1.a < 0.00390625) {
        discard;
    }
#endif
#endif// MULTITEXTURE

#ifdef TINT
    vec4 tintTex = texture2D(s_MatTexture1, v_texcoord0);
    tintTex.rgb = tintTex.rgb * MultiplicativeTintColor.rgb;

#ifdef ALPHA_TEST
    color.rgb = mix(color.rgb, tintTex.rgb, tintTex.a);
    if(color.a + tintTex.a < 0.00390625) {
        discard;
    }
#endif
#endif// TINT

#ifdef ALPHA_TEST
    color.a = max(UseAlphaRewrite.r, color.a);
#endif
    color.rgb = color.rgb * mix(vec3(1.0, 1.0, 1.0), v_color0.rgb, ColorBased.r);
    color.rgb = mix(color.rgb, OverlayColor.rgb, OverlayColor.a);

#if defined(EMISSIVE) || defined(EMISSIVE_ONLY)
	//make glowy stuff
    color.rgb *= mix(vec3(1.0, 1.0, 1.0), v_light.rgb, color.a);
#else
    color.rgb *= v_light.rgb;
#endif

	//apply fog
    color.rgb = mix(color.rgb, v_fog.rgb, v_fog.a);

#ifdef GLINT
	// Applies color mask to glint texture instead and blends with original color
    vec4 layer1 = texture2D(s_MatTexture1, fract(v_layerUv.xy)).rgbr * GlintColor;
    vec4 layer2 = texture2D(s_MatTexture1, fract(v_layerUv.zw)).rgbr * GlintColor;
    vec4 glint = (layer1 + layer2) * TileLightColor;
    color = glintBlend(color, glint);
#endif
    gl_FragColor = color;
}
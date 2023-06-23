//for Actor ActorTint ActorMultiTexture ActorGlint
//Not yet completed, does not support ActorBanner at this time and may have other issues

$input a_position, a_color0, a_texcoord0, a_indices, a_normal
#ifdef INSTANCING
    $input i_data0, i_data1, i_data2, i_data3
#endif

$output v_color0, v_fog, v_light, v_texcoord0
#ifdef BANNER
    $output v_texcoords
#endif
#ifdef GLINT
    $output v_layerUv
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

#define AMBIENT (0.45)

#define XFAC (-0.1)
#define ZFAC (0.1)

float lightIntensity(vec4 normal) {
#ifdef FANCY
    vec3 N = normalize(mul(u_model[0], normal)).xyz;
    N.y *= TileLightColor.w;
    float yLight = (1.0 + N.y) * 0.5;
    return yLight * (1.0 - AMBIENT) + N.x * N.x * XFAC + N.z * N.z * ZFAC + AMBIENT;
#else
    return 1.0;
#endif
}

vec2 calculateLayerUV(vec2 uv, float offset, float rotation) {
    uv -= 0.5;
    float rsin = sin(rotation);
    float rcos = cos(rotation);
    uv = mul(mtxFromCols(vec2(rcos, -rsin), vec2(rsin, rcos)), uv);
    uv.x += offset;
    uv += 0.5;
    return uv * UVScale.xy;
}

void main() {
    vec4 entitySpacePosition;
    vec4 position;
    mat4 World;
    #ifdef INSTANCING
        World = mtxFromCols(i_data0, i_data1, i_data2, i_data3);
    #else
        World = mul(u_model[0], Bones[int(a_indices)]);
    #endif
    
    entitySpacePosition = mul(World, vec4(a_position, 1.0));
    position = mul(u_viewProj, entitySpacePosition);

    float L = lightIntensity(a_normal);

    L += OverlayColor.a * 0.35;

    vec4 light = vec4(TileLightColor.xyz * L, 1.0);

    vec4 fogColor;
    fogColor.rgb = FogColor.rgb;
    fogColor.a = clamp(((position.z / FogControl.z) - FogControl.x) / (FogControl.y - FogControl.x), 0.0, 1.0);

    #if defined(DEPTH_ONLY) && !defined(BANNER)
        v_texcoord0 = vec2(0.0, 0.0);
        v_color0 = vec4(0.0, 0.0, 0.0, 0.0);
    #else
        vec2 uv = a_texcoord0;
        #ifdef GLINT
            v_layerUv.xy = calculateLayerUV(a_texcoord0, UVAnimation.x, UVAnimation.z);
            v_layerUv.zw = calculateLayerUV(a_texcoord0, UVAnimation.y, UVAnimation.w);
        #endif
        v_texcoord0 = uv;
        v_color0 = a_color0;
    #endif
    #ifdef BANNER
        #ifdef ALPHA_TEST
            v_texcoords = vec4(0.0, 0.0, 0.0, 0.0);
        #endif
    #endif
    v_fog = fogColor;
    v_light = light;
    gl_Position = position;
}
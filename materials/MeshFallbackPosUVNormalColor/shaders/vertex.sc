$input a_position, a_color0, a_texcoord0, a_normal
$output v_color, v_fog, v_light, v_texCoords

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>
#include <MinecraftRenderer.Materials/DynamicUtil.dragonh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>

uniform vec4 ZShiftValue;
uniform vec4 UVAnimation;
uniform vec4 TileLightColor;
uniform vec4 OverlayColor;
uniform vec4 FogControl;
uniform vec4 FogColor;

void main() {
    vec4 position;
#if !defined(RASTERIZED_ALPHA_TEST_PASS) && !defined(RASTERIZED_OPAQUE_PASS) && !defined(RASTERIZED_TRANSPARENT_PASS)
    mat4 World = u_model[0];
    position = jitterVertexPosition(mul(World, vec4(a_position, 1.0)).xyz);
#endif
#if defined(RASTERIZED_ALPHA_TEST_PASS) || defined(RASTERIZED_OPAQUE_PASS) || defined(RASTERIZED_TRANSPARENT_PASS)
    position = mul(u_modelViewProj, vec4(a_position, 1.0));
#endif

    v_texCoords = UVAnimation.xy + (a_texcoord0.xy * UVAnimation.zw);
    v_color = a_color0;
    position.z += ZShiftValue.x;

#ifdef LIT
    vec4 light;
    float L = 1.0;
    vec3 N = normalize(mul(World, a_normal).xyz);
    N.y *= TileLightColor.w;
    float yLight = (1.0 + N.y) * 0.5;
    L = yLight * (1.0 - 0.45) + N.x * N.x * -0.1 + N.z * N.z * 0.1 + 0.45;
    light = vec4(vec3(L, L, L) * TileLightColor.xyz, 1.0);
    light += OverlayColor.a * 0.35;
    v_light = light;
#endif

    float cameraDepth = position.z;
    float fogIntensity = calculateFogIntensity(cameraDepth, FogControl.z, FogControl.x, FogControl.y);
    v_fog = vec4(FogColor.rgb, fogIntensity);
    gl_Position = position;
}

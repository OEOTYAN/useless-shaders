$input a_position, a_normal, a_texcoord0, a_color0
#if INSTANCING
    $input i_data0, i_data1, i_data2
#endif

$output v_texcoord0, v_color0, v_light, v_fog

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/DynamicUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>

uniform vec4 FogControl;
uniform vec4 OverlayColor;
uniform vec4 FogColor;
uniform vec4 TileLightColor;

void main() {
    mat4 World = u_model[0];

    float lightIntensity = calculateLightIntensity(World, vec4(a_normal.xyz, 0.0), TileLightColor);
    lightIntensity += OverlayColor.a * 0.35;
    vec4 light = vec4(lightIntensity * TileLightColor.rgb, 1.0);

    vec3 worldPosition;
    #if INSTANCING
        mat4 model = mtxFromCols(i_data0, i_data1, i_data2, vec4(0.0, 0.0, 0.0, 1.0));
        worldPosition = instMul(model, vec4(a_position, 1.0)).xyz;
    #else
        worldPosition = mul(World, vec4(a_position, 1.0)).xyz;
    #endif

    vec4 position = jitterVertexPosition(worldPosition);
    float cameraDepth = position.z;
    float fogIntensity = calculateFogIntensity(cameraDepth, FogControl.z, FogControl.x, FogControl.y);
    vec4 fog = vec4(FogColor.rgb, fogIntensity);

    #if DEPTH_ONLY
        v_color0 = vec4(0.0, 0.0, 0.0, 0.0);
    #else
        v_color0 = a_color0;
    #endif

    v_light = light;
    v_fog = fog;
    v_texcoord0 = a_texcoord0;
    gl_Position = position;
}

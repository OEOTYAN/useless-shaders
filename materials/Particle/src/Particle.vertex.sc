$input a_color0, a_position, a_texcoord0
$output v_color0, v_fog, v_texcoord0

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

uniform vec4 FogAndDistanceControl;
uniform vec4 FogColor;

void main() {
    vec4 pos = vec4(a_position, 1.0);
    vec4 worldPos = vec4(mul(u_model[0], pos).xyz, 1.0);
    vec4 position = mul(u_viewProj, worldPos);

    float fogIntensity = calculateFogIntensity(position.z, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y);
    vec4 fog = vec4(FogColor.rgb, fogIntensity);

    v_texcoord0 = a_texcoord0;
    v_color0 = a_color0;
    v_fog = fog;
    gl_Position = position;
}

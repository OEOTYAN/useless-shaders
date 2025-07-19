$input a_position, a_texcoord0, a_color0
$output v_texcoord0, v_color, v_layer1UV, v_layer2UV

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/GlintUtil.dragonh>

uniform vec4 GlintColor;
uniform vec4 HudOpacity;
uniform vec4 TintColor;
uniform vec4 UVRotation;
uniform vec4 UVScale;
uniform vec4 UVOffset;

void main() {
    v_texcoord0 = a_texcoord0;
    v_layer1UV = calculateLayerUV(a_texcoord0, UVOffset.x, UVRotation.x, UVScale.xy);
    v_layer2UV = calculateLayerUV(a_texcoord0, UVOffset.y, UVRotation.y, UVScale.xy);
    v_color = a_color0;
    gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));
}

$input a_position
$output v_texcoord0

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>

uniform mat4 CubemapRotation;

void main() {
vec3 worldPosition = mul(u_model[0], vec4(a_position, 1.0)).xyz;
gl_Position = jitterVertexPosition(worldPosition);
v_texcoord0 = mul(CubemapRotation, vec4(worldPosition, 0.0)).xyz;
}

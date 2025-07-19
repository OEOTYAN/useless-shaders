$input a_position, a_texcoord0, a_indices
$output v_texcoord0

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>

uniform mat4 Bones[8];
uniform vec4 UVScale;

void main() {
mat4 World = u_model[0];
World = mul(World, Bones[int(a_indices)]);
v_texcoord0 = a_texcoord0 * UVScale.xy;
vec3 worldPosition = mul(World, vec4(a_position, 1.0)).xyz;
gl_Position = jitterVertexPosition(worldPosition);
}

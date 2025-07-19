$input a_position, a_texcoord0
$output v_texcoord0

#include <bgfx_shader.sh>

uniform mat4 CubemapRotation;

void main() {
v_texcoord0 = a_texcoord0;
gl_Position = mul(u_modelViewProj, mul(CubemapRotation, vec4(a_position, 1.0)));
}

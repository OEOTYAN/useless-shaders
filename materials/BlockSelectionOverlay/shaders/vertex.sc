$input a_position, a_texcoord0
$output v_texcoord0

#include <bgfx_shader.sh>

void main() {
v_texcoord0 = a_texcoord0;
vec4 position = mul(u_modelViewProj, vec4(a_position, 1.0));
position.z -= 1.0 / 8192.0;
gl_Position = position;
}

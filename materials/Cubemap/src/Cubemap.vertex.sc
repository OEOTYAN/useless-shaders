$input a_position
$output v_texcoord0

#include <bgfx_shader.sh>

uniform mat4 CubemapRotation;

void main() {
    vec4 pos =  mul(u_model[0], vec4(a_position, 1.0));

    gl_Position = mul(u_viewProj, vec4(pos.xyz, 1.0));
    v_texcoord0 = mul(CubemapRotation, vec4(pos.xyz, 0.0)).xyz;
}

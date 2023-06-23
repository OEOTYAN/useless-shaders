$input a_position, a_texcoord0
$output v_texcoord0

#include <bgfx_shader.sh>

void main() {
    vec2 pos = (a_position.xy * 2.0) - 1.0;
    v_texcoord0 = a_texcoord0;
    gl_Position = vec4(pos, 0.0, 1.0);
}

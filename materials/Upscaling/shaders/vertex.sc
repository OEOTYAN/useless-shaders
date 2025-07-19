$input a_position, a_texcoord0
$output v_texcoord0

#include <bgfx_shader.sh>

void main() {
#if !defined(FALLBACK)
vec4 pos = vec4(a_position, 1.0);
pos.xy = pos.xy * 2.0 - 1.0;
v_texcoord0 = a_texcoord0;
gl_Position = pos;
#else
gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
#endif
}

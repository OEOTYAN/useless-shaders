$input a_position, a_texcoord0
$output v_projPosition, v_texcoord0

#include <bgfx_shader.sh>

void main() {
    vec4 position = vec4(a_position, 1.0);
    position.xy = position.xy * 2.0 - 1.0;

    vec3 projPosition = a_position.xyz;
    projPosition.xy = projPosition.xy * 2.0 - 1.0;

    vec2 texcoord0 = a_texcoord0;

    v_projPosition = projPosition;
    v_texcoord0 = texcoord0;
    gl_Position = position;
}

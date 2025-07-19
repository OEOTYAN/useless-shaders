$input a_position, a_texcoord0
$output v_ndcPosition, v_texcoord0

#include <bgfx_shader.sh>

void main() {
#if FALLBACK
    v_texcoord0 = vec2(0.0, 0.0);
    v_ndcPosition = vec3(0.0, 0.0, 0.0);
    gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
#else
    vec4 clipPosition = mul(u_modelViewProj, vec4(a_position, 1.0));
    vec3 ndcPosition = clipPosition.xyz / clipPosition.w;

    v_ndcPosition = ndcPosition;
    v_texcoord0 = a_texcoord0;
    gl_Position = clipPosition;
#endif
}

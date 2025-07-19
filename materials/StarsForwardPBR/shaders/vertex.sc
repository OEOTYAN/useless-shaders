$input a_position, a_color0
$output v_color0, v_ndcPosition

#include <bgfx_shader.sh>

void main() {
#if FALLBACK
    gl_Position = vec4(0.0, 0.0, 0.0, 0.0);
#else
    vec4 clipPosition = mul(u_modelViewProj, vec4(a_position, 1.0));
    vec3 ndcPosition = clipPosition.xyz / clipPosition.w;

    v_ndcPosition = ndcPosition;
    v_color0 = a_color0;
    gl_Position = clipPosition;
#endif
}

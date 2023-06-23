$input v_color0

#include <bgfx_shader.sh>

uniform vec4 StarsColor;

void main() {
    vec4 starColor;
    starColor.a = v_color0.a;
    starColor.rgb = v_color0.rgb * StarsColor.rgb * v_color0.a;
    gl_FragColor = starColor;
}
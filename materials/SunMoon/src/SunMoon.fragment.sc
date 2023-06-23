$input v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 SunMoonColor;

SAMPLER2D(s_SunMoonTexture, 0);

void main() {
    gl_FragColor = SunMoonColor * texture2D(s_SunMoonTexture, v_texcoord0);
}
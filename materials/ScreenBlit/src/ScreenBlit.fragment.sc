$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D(s_MatTexture, 0);

void main() {
    gl_FragColor = texture2D(s_MatTexture, v_texcoord0);
}

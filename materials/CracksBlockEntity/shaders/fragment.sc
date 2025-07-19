$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLER2D_AUTOREG(s_CracksTexture);

void main() {
gl_FragColor = texture2D(s_CracksTexture, v_texcoord0);
}

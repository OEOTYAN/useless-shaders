$input v_texcoord0

#include <bgfx_shader.sh>
uniform vec4 MatColor;

SAMPLER2D_AUTOREG(s_MatTexture);

void main() {
vec4 diffuse = texture2D(s_MatTexture, v_texcoord0);

const float ALPHA_THRESHOLD = 0.5;
if(diffuse.a < ALPHA_THRESHOLD) {
discard;
}

gl_FragColor = MatColor;
}

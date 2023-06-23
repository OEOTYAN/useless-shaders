$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLERCUBE(s_MatTexture, 0);

void main() {
    vec3 dir = normalize(v_texcoord0);
    dir.x = -dir.x;
    gl_FragColor = textureCube(s_MatTexture, dir);
}

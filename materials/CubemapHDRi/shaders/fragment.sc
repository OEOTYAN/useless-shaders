$input v_texcoord0

#include <bgfx_shader.sh>

SAMPLERCUBE_AUTOREG(s_MatTexture);

vec3 color_degamma(vec3 clr) {
float e = 2.2;
return pow(max(clr, vec3(0.0, 0.0, 0.0)), vec3(e, e, e));
}

vec4 color_degamma(vec4 clr) {
return vec4(color_degamma(clr.rgb), clr.a);
}

void main() {
vec3 dir = normalize(v_texcoord0);
dir.x = dir.x * - 1.0;

vec4 sampledColor = textureCube(s_MatTexture, dir);
gl_FragColor = color_degamma(sampledColor);
}

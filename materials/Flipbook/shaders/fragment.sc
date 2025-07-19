$input v_texcoord0, v_texcoord1

#include <bgfx_shader.sh>

uniform vec4 VBlendControl;

SAMPLER2D_AUTOREG(s_BlitTexture);

void main() {
vec4 colorFrom = texture2D(s_BlitTexture, v_texcoord0);
vec4 colorTo = texture2D(s_BlitTexture, v_texcoord1);
vec4 color = colorFrom;
if(colorFrom.a < 0.01) {
color = colorTo;
} else if(colorTo.a >= 0.01) {
color = mix(colorFrom, colorTo, VBlendControl.z);
}
gl_FragColor = color;
}
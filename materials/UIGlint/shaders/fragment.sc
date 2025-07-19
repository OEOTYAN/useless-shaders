$input v_texcoord0, v_color, v_layer1UV, v_layer2UV

#include <bgfx_shader.sh>

uniform vec4 GlintColor;
uniform vec4 HudOpacity;
uniform vec4 TintColor;
uniform vec4 UVOffset;
uniform vec4 UVRotation;
uniform vec4 UVScale;

SAMPLER2D_AUTOREG(s_MatTexture);
SAMPLER2D_AUTOREG(s_GlintTexture);

void main() {
vec4 diffuse = texture2D(s_MatTexture, v_texcoord0);
if(diffuse.a <= 0.00390625) {
discard;
}
vec4 layer1 = texture2D(s_GlintTexture, fract(v_layer1UV));
vec4 layer2 = texture2D(s_GlintTexture, fract(v_layer2UV));
vec4 glint = layer1 + layer2;
glint *= GlintColor;
diffuse.rgb = glint.rgb;
diffuse = diffuse * TintColor;
diffuse.rgb *= diffuse.rgb;
diffuse.rgb *= TintColor.a;
diffuse = diffuse * HudOpacity.x;
gl_FragColor = diffuse;
}

$input v_color0

#include <bgfx_shader.sh>

uniform vec4 TintColor;
uniform vec4 HudOpacity;

void main() {
vec4 diffuse = v_color0 * TintColor;
diffuse.a = diffuse.a * HudOpacity.x;
gl_FragColor = diffuse;
}

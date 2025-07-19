#include <bgfx_shader.sh>

uniform vec4 TintColor;
uniform vec4 HudOpacity;

void main() {
    vec4 diffuse = TintColor;
    diffuse.a = diffuse.a * HudOpacity.x;
    gl_FragColor = diffuse;
}

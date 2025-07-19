$input a_position, a_texcoord0
$output v_texcoord0

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>

void main() {
v_texcoord0 = a_texcoord0;
gl_Position = jitterVertexPosition(a_position);
}

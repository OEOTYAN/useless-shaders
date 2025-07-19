$input v_texcoord0, v_color0, v_light, v_fog

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/DynamicUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>
#include <MinecraftRenderer.Materials/ActorUtil.dragonh>

uniform vec4 ChangeColor;
uniform vec4 OverlayColor;
uniform vec4 ColorBased;
uniform vec4 MultiplicativeTintColor;
uniform vec4 MatColor;

SAMPLER2D_AUTOREG(s_MatTexture);

void main() {
#if DEPTH_ONLY_PASS
gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
return;
#else
vec4 albedo = getActorAlbedoNoColorChange(v_texcoord0, s_MatTexture, MatColor);
albedo.rgb *= mix(vec3(1.0, 1.0, 1.0), v_color0.rgb, ColorBased.x);

#if MULTI_COLOR_TINT
albedo = applyMultiColorChange(albedo, ChangeColor.rgb, MultiplicativeTintColor.rgb);
#else
albedo = applyColorChange(albedo, ChangeColor, v_color0.a);
#endif

albedo = applyOverlayColor(albedo, OverlayColor);
albedo = applyLighting(albedo, v_light);

#if ALPHA_TEST_PASS
if(albedo.a < 0.5) {
discard;
}
#endif

albedo.rgb = applyFog(albedo.rgb, v_fog.rgb, v_fog.a);
gl_FragColor = albedo;
#endif // DEPTH_ONLY_PASS
}

$input v_projPosition, v_texcoord0

#include <bgfx_shader.sh>
#include <bgfx_compute.sh>

#if !defined(FALLBACK) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)

#include "DoDeferredShading.sc"

SAMPLER2D_AUTOREG(s_ColorMetalness);
SAMPLER2D_AUTOREG(s_SceneDepth);
SAMPLER2D_AUTOREG(s_Normal);
SAMPLER2D_AUTOREG(s_EmissiveAmbientLinearRoughness);

PBRFragmentInfo getPBRFragmentInfo(vec3 projPosition, vec2 texcoord0) {
vec2 uv = texcoord0;
float z = texture2D(s_SceneDepth, uv).r;
#if BGFX_SHADER_LANGUAGE_GLSL
z = z * 2.0 - 1.0;
#endif
vec4 viewPosition = projToView(vec4(projPosition.xy, z, 1.0), u_invProj);
vec4 worldPosition = mul(u_invView, vec4(viewPosition.xyz, 1.0));
vec2 n = texture2D(s_Normal, uv).xy;
vec3 worldNorm = normalize(octToNdirSnorm(n.xy));
vec3 viewNorm = normalize(mul(u_view, vec4(worldNorm, 0.0)).xyz);
vec4 cm = texture2D(s_ColorMetalness, uv);
vec4 ear = texture2D(s_EmissiveAmbientLinearRoughness, uv);
float blockAmbientContribution = ear.g;
float skyAmbientContribution = ear.b;
float roughness = ear.a;

PBRFragmentInfo result;
result.lightClusterUV = uv;
result.worldPosition = worldPosition.xyz;
result.viewPosition = viewPosition.xyz;
result.ndcPosition = vec3(projPosition.xy, z);
result.worldNormal = worldNorm;
result.viewNormal = viewNorm;
result.albedo = color_degamma(cm.rgb);
result.metalness = cm.a;
result.roughness = roughness;
result.emissive = ear.r;
result.blockAmbientContribution = blockAmbientContribution;
result.skyAmbientContribution = skyAmbientContribution;
return result;
}

vec4 DeferredLighting(vec3 projPosition, vec2 texcoord0) {
PBRFragmentInfo fragmentInfo = getPBRFragmentInfo(projPosition, texcoord0);
return evaluateFragmentColor(fragmentInfo);
}

#endif

void main() {
#if !defined(FALLBACK) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)
gl_FragColor = DeferredLighting(v_projPosition, v_texcoord0);
#else
gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
#endif
}
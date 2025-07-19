input a_color0, a_position, a_texcoord0, a_texcoord1, a_normal, a_tangent
#if defined(FORWARD_PBR_TRANSPARENT)
input a_texcoord4
#endif
#ifdef INSTANCING__ON
input i_data0, i_data1, i_data2
#endif

output v_color0, v_fog, v_normal, v_tangent, v_bitangent, v_texcoord0, v_lightmapUV, v_worldPos, v_blockAmbientContribution, v_skyAmbientContribution
#if defined(FORWARD_PBR_TRANSPARENT)
output v_pbrTextureId
#endif

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

uniform mat4 PointLightProj;
uniform vec4 PointLightShadowParams1;
uniform vec4 ShadowBias;
uniform vec4 SunDir;
uniform vec4 ShadowSlopeBias;
uniform vec4 PrepassUVOffset;
uniform vec4 BlockBaseAmbientLightColorIntensity;
uniform vec4 CascadeShadowResolutions;
uniform vec4 LightWorldSpaceDirection;
uniform vec4 LightDiffuseColorAndIlluminance;
uniform vec4 AtmosphericScatteringEnabled;
uniform vec4 ViewPositionAndTime;
uniform mat4 CloudShadowProj;
uniform vec4 VolumeScatteringEnabled;
uniform vec4 FogSkyBlend;
uniform vec4 PointLightDiffuseFadeOutParameters;
uniform vec4 MoonDir;
uniform vec4 ClusterSize;
uniform vec4 AtmosphericScattering;
uniform vec4 FogAndDistanceControl;
uniform vec4 RenderChunkFogAlpha;
uniform vec4 DiffuseSpecularEmissiveAmbientTermToggles;
uniform vec4 DirectionalLightToggleAndCountAndMaxDistance;
uniform vec4 EmissiveMultiplierAndDesaturationAndCloudPCFAndContribution;
uniform vec4 DirectionalShadowModeAndCloudShadowToggleAndPointLightToggleAndShadowToggle;
uniform vec4 FogColor;
uniform vec4 VolumeDimensions;
uniform vec4 ShadowPCFWidth;
uniform vec4 MoonColor;
uniform vec4 ShadowParams;
uniform vec4 SkyAmbientLightColorIntensity;
uniform vec4 ClusterDimensions;
uniform vec4 ClusterNearFarWidthHeight;
uniform vec4 SunColor;
uniform vec4 PointLightSpecularFadeOutParameters;
uniform vec4 VolumeNearFar;
uniform vec4 IBLParameters;
uniform vec4 SkyZenithColor;
uniform vec4 SkyHorizonColor;

void main() {
    //StandardTemplate_VertSharedTransform
vec3 worldPosition;
#ifdef INSTANCING__ON
mat4 model;
model[0] = vec4(i_data0.x, i_data1.x, i_data2.x, 0);
model[1] = vec4(i_data0.y, i_data1.y, i_data2.y, 0);
model[2] = vec4(i_data0.z, i_data1.z, i_data2.z, 0);
model[3] = vec4(i_data0.w, i_data1.w, i_data2.w, 1);
worldPosition = instMul(model, vec4(a_position, 1.0)).xyz;
#else
worldPosition = mul(u_model[0], vec4(a_position, 1.0)).xyz;
#endif

vec4 position;// = mul(u_viewProj, vec4(worldPosition, 1.0));
vec2 texcoord0 = a_texcoord0;
vec4 color0 = a_color0;

    //StandardTemplate_InvokeVertexOverrideFunction
position = jitterVertexPosition(worldPosition);

vec4 fog;
vec3 normal = vec3(0.0, 0.0, 0.0);
vec3 tangent = vec3(0.0, 0.0, 0.0);
vec3 bitangent = vec3(0.0, 0.0, 0.0);
int pbrTextureId = 0;
#if FORWARD_PBR_TRANSPARENT
float cameraDepth = length(ViewPositionAndTime.xyz - worldPosition);
    // float fogIntensity = calculateFogIntensityFadedVanilla(cameraDepth, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y, RenderChunkFogAlpha.x);
float fogIntensity = calculateFogIntensityFaded(cameraDepth, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y, RenderChunkFogAlpha.x);
fog = vec4(FogColor.rgb, fogIntensity);

pbrTextureId = int(a_texcoord4) & 0xffff;

vec3 n = a_normal.xyz;
vec3 t = a_tangent.xyz;
vec3 b = cross(n, t) * a_tangent.w;

normal = mul(u_model[0], vec4(n, 0.0)).xyz;
tangent = mul(u_model[0], vec4(t, 0.0)).xyz;
bitangent = mul(u_model[0], vec4(b, 0.0)).xyz;

#else

#endif

    //StandardTemplate_InvokeLightingVertexFunction
vec2 lightmapUV = a_texcoord1;

v_texcoord0 = texcoord0;
v_color0 = color0;
v_fog = fog;
v_lightmapUV = lightmapUV;
v_tangent = tangent;
v_normal = normal;
v_bitangent = bitangent;
v_worldPos = worldPosition;
v_skyAmbientContribution = 0.0;
v_blockAmbientContribution = 0.0;

#if defined(FORWARD_PBR_TRANSPARENT)
v_pbrTextureId = pbrTextureId;
#endif

gl_Position = position;
}

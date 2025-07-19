$input v_ndcPosition, v_texcoord0

#include <bgfx_shader.sh>

uniform mat4 PointLightProj;
uniform vec4 ShadowBias;
uniform vec4 PointLightShadowParams1;
uniform vec4 ShadowSlopeBias;
uniform vec4 BlockBaseAmbientLightColorIntensity;
uniform vec4 PrepassUVOffset;
uniform vec4 CascadeShadowResolutions;
uniform vec4 DirectionalShadowModeAndCloudShadowToggleAndPointLightToggleAndShadowToggle;
uniform vec4 VolumeScatteringEnabled;
uniform vec4 DiffuseSpecularEmissiveAmbientTermToggles;
uniform vec4 EmissiveMultiplierAndDesaturationAndCloudPCFAndContribution;
uniform vec4 DirectionalLightToggleAndCountAndMaxDistance;
uniform vec4 ShadowPCFWidth;
uniform vec4 VolumeDimensions;
uniform vec4 ShadowParams;
uniform vec4 SkyAmbientLightColorIntensity;
uniform vec4 ClusterDimensions;
uniform vec4 ClusterNearFarWidthHeight;
uniform vec4 ClusterSize;
uniform vec4 PointLightDiffuseFadeOutParameters;
uniform vec4 PointLightSpecularFadeOutParameters;
uniform vec4 VolumeNearFar;
uniform vec4 SunMoonColor;
uniform mat4 CloudShadowProj;

SAMPLER2D_AUTOREG(s_SunMoonTexture);
SAMPLER2DARRAY_AUTOREG(s_ScatteringBuffer);

float linearToLogDepth(float linearDepth) {
return log((exp(4.0) - 1.0) * linearDepth + 1.0) / 4.0;
}

vec3 ndcToVolume(vec3 ndc, mat4 inverseProj, vec2 nearFar) {
vec2 uv = 0.5 * (ndc.xy + vec2(1.0, 1.0));
vec4 view = mul(inverseProj, vec4(ndc, 1.0));
float viewDepth = - view.z / view.w;
float wLinear = (viewDepth - nearFar.x) / (nearFar.y - nearFar.x);
return vec3(uv, linearToLogDepth(wLinear));
}

vec4 sampleVolume(highp sampler2DArray volume, ivec3 dimensions, vec3 uvw) {
float depth = uvw.z * float(dimensions.z) - 0.5;
int index = clamp(int(depth), 0, dimensions.z - 2);
float offset = clamp(depth - float(index), 0.0, 1.0);
vec4 a = texture2DArray(volume, vec3(uvw.xy, index)).rgba;
vec4 b = texture2DArray(volume, vec3(uvw.xy, index + 1)).rgba;
return mix(a, b, offset);
}

void main() {
#if FALLBACK
gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
#else
vec4 spriteColor = texture2D(s_SunMoonTexture, v_texcoord0);
vec3 sunMoonColor = SunMoonColor.rgb * spriteColor.rgb * SunMoonColor.a;
vec3 outColor;
if(VolumeScatteringEnabled.x != 0.0) {
vec3 uvw = ndcToVolume(v_ndcPosition, u_invProj, VolumeNearFar.xy);
vec4 sourceExtinction = sampleVolume(s_ScatteringBuffer, ivec3(VolumeDimensions.xyz), uvw);
outColor = sourceExtinction.a * sunMoonColor;
} else {
outColor = sunMoonColor;
}

gl_FragColor = vec4(outColor.r, outColor.g, outColor.b, 1.0);
#endif
}

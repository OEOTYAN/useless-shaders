$input v_texcoord0, v_fog, v_occlusionHeight, v_occlusionUV

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

uniform vec4 Dimensions;
uniform vec4 ViewPosition;
uniform vec4 UVOffsetAndScale;
uniform vec4 OcclusionHeightOffset;
uniform vec4 FogColor;
uniform vec4 FogAndDistanceControl;
uniform vec4 PositionForwardOffset;
uniform vec4 PositionBaseOffset;
uniform vec4 Velocity;

SAMPLER2D(s_WeatherTexture, s_WeatherTexture_REG);
SAMPLER2D(s_OcclusionTexture, s_OcclusionTexture_REG);
SAMPLER2D(s_LightingTexture, s_LightingTexture_REG);

float getOcclusionHeight(const vec4 occlusionTextureSample) {
float height = occlusionTextureSample.g + (occlusionTextureSample.b * 255.0) - (OcclusionHeightOffset.x / 255.0);
return height;
}

float getOcclusionLuminance(const vec4 occlusionTextureSample) {
return occlusionTextureSample.r;
}

bool isOccluded(const vec2 occlusionUV, const float occlusionHeight, const float occlusionHeightThreshold) {
#ifndef FLIP_OCCLUSION
#define OCCLUSION_OPERATOR <
#else
#define OCCLUSION_OPERATOR >
#endif

#ifndef NO_OCCLUSION
	// clamp the uvs
return (occlusionUV.x >= 0.0 && occlusionUV.x <= 1.0 &&
    occlusionUV.y >= 0.0 && occlusionUV.y <= 1.0 &&
    occlusionHeight OCCLUSION_OPERATOR occlusionHeightThreshold);
#else
return false;
#endif
}

void main() {
vec4 diffuse = texture2D(s_WeatherTexture, v_texcoord0);
vec4 occlusionLuminanceAndHeightThreshold = texture2D(s_OcclusionTexture, v_occlusionUV);

float occlusionLuminance = getOcclusionLuminance(occlusionLuminanceAndHeightThreshold);
float occlusionHeightThreshold = getOcclusionHeight(occlusionLuminanceAndHeightThreshold);

if(isOccluded(v_occlusionUV, v_occlusionHeight, occlusionHeightThreshold)) {
diffuse.a = 0.0;
} else {
float mixAmount = (v_occlusionHeight - occlusionHeightThreshold) * 25.0;
float uvX = occlusionLuminance - (mixAmount * occlusionLuminance);
vec2 lightingUV = vec2(uvX, 1.0);
vec3 light = texture2D(s_LightingTexture, lightingUV).rgb;
diffuse.rgb *= light;
diffuse.rgb = applyFog(diffuse.rgb, v_fog.rgb, v_fog.a);
}
gl_FragColor = diffuse;
}

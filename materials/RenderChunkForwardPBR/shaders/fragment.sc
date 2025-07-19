input v_color0, v_fog, v_normal, v_tangent, v_bitangent, v_texcoord0, v_lightmapUV, v_worldPos, v_blockAmbientContribution, v_skyAmbientContribution
#if defined(FORWARD_PBR_TRANSPARENT)
input v_pbrTextureId
#endif

#include <bgfx_shader.sh>
#include <bgfx_compute.sh>

#if defined(FORWARD_PBR_TRANSPARENT)

#include "../../DeferredShading/shaders/DoDeferredShading.sc"

SAMPLER2D_AUTOREG(s_MatTexture);
SAMPLER2D_AUTOREG(s_SeasonsTexture);
SAMPLER2D_AUTOREG(s_LightMapTexture);
BUFFER_RO_AUTOREG(s_PBRData, PBRTextureData);

float saturatedLinearRemapZeroToOne(float value, float zeroValue, float oneValue) {
return saturate((((value) * (1. / (oneValue - zeroValue))) + - zeroValue / (oneValue - zeroValue)));
}

vec3 calculateTangentNormalFromHeightmap(sampler2D heightmapTexture, vec2 heightmapUV, float mipLevel) {
vec3 tangentNormal = vec3(0., 0., 1.);
const float kHeightMapPixelEdgeWidth = 1.0 / 12.0;
const float kHeightMapDepth = 4.0;
const float kRecipHeightMapDepth = 1.0 / kHeightMapDepth;
float fadeForLowerMips = saturatedLinearRemapZeroToOne(mipLevel, 2., 1.);
if(fadeForLowerMips > 0.) {
vec2 widthHeight = vec2(textureSize(heightmapTexture, 0));
vec2 pixelCoord = heightmapUV * widthHeight;
{
const float kNudgePixelCentreDistEpsilon = 0.0625;
const float kNudgeUvEpsilon = 0.25 / 65536.;
vec2 nudgeSampleCoord = fract(pixelCoord);
if(abs(nudgeSampleCoord.x - 0.5) < kNudgePixelCentreDistEpsilon) {
heightmapUV.x += (nudgeSampleCoord.x > 0.5) ? kNudgeUvEpsilon : - kNudgeUvEpsilon;
}
if(abs(nudgeSampleCoord.y - 0.5) < kNudgePixelCentreDistEpsilon) {
heightmapUV.y += (nudgeSampleCoord.y > 0.5) ? kNudgeUvEpsilon : - kNudgeUvEpsilon;
}
}
vec4 heightSamples = textureGather(heightmapTexture, heightmapUV, 0);
vec2 subPixelCoord = fract(pixelCoord + 0.5);
const float kBevelMode = 0.0;
vec2 axisSamplePair = (subPixelCoord.y > 0.5) ? heightSamples.xy : heightSamples.wz;
float axisBevelCentreSampleCoord = subPixelCoord.x;
axisBevelCentreSampleCoord += ((axisSamplePair.x > axisSamplePair.y) ? kHeightMapPixelEdgeWidth : - kHeightMapPixelEdgeWidth) * kBevelMode;
ivec2 axisSampleIndices = ivec2(saturate(vec2(axisBevelCentreSampleCoord - kHeightMapPixelEdgeWidth, axisBevelCentreSampleCoord + kHeightMapPixelEdgeWidth) * 2.));
tangentNormal.x = (axisSamplePair[axisSampleIndices.x] - axisSamplePair[axisSampleIndices.y]);
axisSamplePair = (subPixelCoord.x > 0.5) ? heightSamples.zy : heightSamples.wx;
axisBevelCentreSampleCoord = subPixelCoord.y;
axisBevelCentreSampleCoord += ((axisSamplePair.x > axisSamplePair.y) ? kHeightMapPixelEdgeWidth : - kHeightMapPixelEdgeWidth) * kBevelMode;
axisSampleIndices = ivec2(saturate(vec2(axisBevelCentreSampleCoord - kHeightMapPixelEdgeWidth, axisBevelCentreSampleCoord + kHeightMapPixelEdgeWidth) * 2.));
tangentNormal.y = (axisSamplePair[axisSampleIndices.x] - axisSamplePair[axisSampleIndices.y]);
tangentNormal.z = kRecipHeightMapDepth;
tangentNormal = normalize(tangentNormal);
tangentNormal.xy *= fadeForLowerMips;
}
return tangentNormal;
}

vec2 getPBRDataUV(vec2 surfaceUV, vec2 uvScale, vec2 uvBias) {
return (((surfaceUV) * (uvScale)) + uvBias);
}

#endif // FORWARD_PBR_TRANSPARENT

void main() {
#if FORWARD_PBR_TRANSPARENT
vec4 diffuse = texture2D(s_MatTexture, v_texcoord0);

const float ALPHA_THRESHOLD = 0.5;
if(diffuse.a < ALPHA_THRESHOLD) {
discard;
}

diffuse.rgb *= v_color0.rgb;
diffuse.a *= v_color0.a;

    //RenderChunkSurfTransparent
    //applyPBRValuesToSurfaceOutput
PBRTextureData pbrTextureData = s_PBRData[v_pbrTextureId];
vec2 normalUVScale = vec2(pbrTextureData.colourToNormalUvScale0, pbrTextureData.colourToNormalUvScale1);
vec2 normalUVBias = vec2(pbrTextureData.colourToNormalUvBias0, pbrTextureData.colourToNormalUvBias1);
vec2 materialUVScale = vec2(pbrTextureData.colourToMaterialUvScale0, pbrTextureData.colourToMaterialUvScale1);
vec2 materialUVBias = vec2(pbrTextureData.colourToMaterialUvBias0, pbrTextureData.colourToMaterialUvBias1);

int kPBRTextureDataFlagHasMaterialTexture = (1 << 0);
    // These two are mutually exclusive
int kPBRTextureDataFlagHasNormalTexture = (1 << 1);
int kPBRTextureDataFlagHasHeightMapTexture = (1 << 2);

vec3 tangentNormal = vec3(0, 0, 1);
if((pbrTextureData.flags & kPBRTextureDataFlagHasNormalTexture) == kPBRTextureDataFlagHasNormalTexture) {
vec2 uv = getPBRDataUV(v_texcoord0, normalUVScale, normalUVBias);
tangentNormal = texture2D(s_MatTexture, uv).xyz * 2. - 1.;
} else if((pbrTextureData.flags & kPBRTextureDataFlagHasHeightMapTexture) == kPBRTextureDataFlagHasHeightMapTexture) {
vec2 normalUv = getPBRDataUV(v_texcoord0, normalUVScale, normalUVBias);
float normalMipLevel = min(pbrTextureData.maxMipNormal - pbrTextureData.maxMipColour, pbrTextureData.maxMipNormal);
tangentNormal = calculateTangentNormalFromHeightmap(s_MatTexture, normalUv, normalMipLevel);
}

float emissive = pbrTextureData.uniformEmissive;
float metalness = pbrTextureData.uniformMetalness;
float linearRoughness = pbrTextureData.uniformRoughness;
if((pbrTextureData.flags & kPBRTextureDataFlagHasMaterialTexture) == kPBRTextureDataFlagHasMaterialTexture) {
vec2 uv = getPBRDataUV(v_texcoord0, materialUVScale, materialUVBias);
vec3 texel = texture2D(s_MatTexture, uv).rgb;
metalness = texel.r;
emissive = texel.g;
linearRoughness = texel.b;
}

mat3 tbn = mtxFromRows(normalize(v_tangent), normalize(v_bitangent), normalize(v_normal));
tbn = transpose(tbn);
vec3 normal = mul(tbn, tangentNormal).xyz;

    //computeLighting_RenderChunk_SplitLightMapValues
vec2 newLightmapUV = min(v_lightmapUV.xy, vec2(1.0, 1.0));
vec3 blockLight = texture2D(s_LightMapTexture, min(vec2(newLightmapUV.x, 1.5 * 1.0 / 16.0), vec2(1.0, 1.0))).rgb;
vec3 skyLight = texture2D(s_LightMapTexture, min(vec2(newLightmapUV.y, 0.5 * 1.0 / 16.0), vec2(1.0, 1.0))).rgb;

PBRFragmentInfo fragmentData;
vec4 viewPosition = mul(u_view, vec4(v_worldPos, 1.0));
vec4 clipPosition = mul(u_proj, viewPosition);
vec3 ndcPosition = clipPosition.xyz / clipPosition.w;
vec2 uv = (ndcPosition.xy + vec2(1.0, 1.0)) / 2.0;
vec4 worldNormal = vec4(normal, 0.0);
vec4 viewNormal = mul(u_view, worldNormal);
fragmentData.lightClusterUV = uv;
fragmentData.worldPosition = v_worldPos;
fragmentData.viewPosition = viewPosition.xyz;
fragmentData.ndcPosition = ndcPosition;
fragmentData.worldNormal = worldNormal.xyz;
fragmentData.viewNormal = viewNormal.xyz;
fragmentData.albedo = diffuse.rgb;
fragmentData.roughness = linearRoughness;
fragmentData.metalness = metalness;
fragmentData.emissive = emissive;
fragmentData.blockAmbientContribution = blockLight.x;
fragmentData.skyAmbientContribution = skyLight.x;

gl_FragColor.rgb = evaluateFragmentColor(fragmentData).rgb;
gl_FragColor.a = diffuse.a;

#else

gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
#endif
}

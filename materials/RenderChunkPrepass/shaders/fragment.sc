$input v_color0, v_fog, v_texcoord0, v_lightmapUV, v_normal, v_tangent, v_bitangent, v_position, v_worldPos, v_blockAmbientContribution, v_skyAmbientContribution
#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)
$input v_pbrTextureId
#endif

#include <bgfx_compute.sh>
#include <bgfx_shader.sh>
#include <defines.sh>
#include <overlay.sh>

    struct PBRTextureData
{
    float colourToMaterialUvScale0;
    float colourToMaterialUvScale1;
    float colourToMaterialUvBias0;
    float colourToMaterialUvBias1;
    float colourToNormalUvScale0;
    float colourToNormalUvScale1;
    float colourToNormalUvBias0;
    float colourToNormalUvBias1;
    int flags;
    float uniformRoughness;
    float uniformEmissive;
    float uniformMetalness;
    float uniformSubsurface;
    float maxMipColour;
    float maxMipMer;
    float maxMipNormal;
};

uniform vec4 LightWorldSpaceDirection;
uniform vec4 GlobalRoughness;
uniform vec4 FogColor;
uniform vec4 FogAndDistanceControl;
uniform vec4 LightDiffuseColorAndIlluminance;
uniform vec4 ViewPositionAndTime;
uniform vec4 RenderChunkFogAlpha;

SAMPLER2D_AUTOREG(s_LightMapTexture);
SAMPLER2D_AUTOREG(s_MatTexture);
SAMPLER2D_AUTOREG(s_SeasonsTexture);

#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)

BUFFER_RO_AUTOREG(s_PBRData, PBRTextureData);

vec2 octWrap(vec2 v)
{
    return (1.0 - abs(v.yx)) * ((2.0 * step(0.0, v)) - 1.0);
}

vec2 ndirToOctSnorm(vec3 n)
{
    vec2 p = n.xy * (1.0 / (abs(n.x) + abs(n.y) + abs(n.z)));
    p = (n.z < 0.0) ? octWrap(p) : p;
    return p;
}

vec2 ndirToOctUnorm(vec3 n)
{
    vec2 p = ndirToOctSnorm(n);
    return p * 0.5 + 0.5;
}

vec3 octToNdirSnorm(vec2 p)
{
    vec3 n = vec3(p.xy, 1.0 - abs(p.x) - abs(p.y));
    n.xy = (n.z < 0.0) ? octWrap(n.xy) : n.xy;
    return normalize(n);
}

vec3 octToNdirUnorm(vec2 p)
{
    vec2 pSnorm = p * 2.0 - 1.0;
    return octToNdirSnorm(pSnorm);
}

float saturatedLinearRemapZeroToOne(float value, float zeroValue, float oneValue)
{
    return saturate((((value) * (1. / (oneValue - zeroValue))) + -zeroValue / (oneValue - zeroValue)));
}
float packMetalnessSubsurface(float metalness, float subsurface)
{
    if (metalness > subsurface)
    {
        return (128.0 / 255.0) + (127.0 / 255.0) * metalness;
    }
    else
    {
        return (127.0 / 255.0) - (127.0 / 255.0) * subsurface;
    }
}
vec2 calculateMotionVector(vec3 worldPosition, vec3 previousWorldPosition)
{
    vec4 screenSpacePos = mul(u_viewProj, vec4(worldPosition, 1.0));
    screenSpacePos /= screenSpacePos.w;
    screenSpacePos = screenSpacePos * 0.5 + 0.5;
    vec4 prevScreenSpacePos = mul(u_prevViewProj, vec4(previousWorldPosition, 1.0));
    prevScreenSpacePos /= prevScreenSpacePos.w;
    prevScreenSpacePos = prevScreenSpacePos * 0.5 + 0.5;
    return screenSpacePos.xy - prevScreenSpacePos.xy;
}
vec3 calculateTangentNormalFromHeightmap(sampler2D heightmapTexture, vec2 heightmapUV, float mipLevel)
{
    vec3 tangentNormal = vec3(0., 0., 1.);
    const float kHeightMapPixelEdgeWidth = 1.0 / 12.0;
    const float kHeightMapDepth = 4.0;
    const float kRecipHeightMapDepth = 1.0 / kHeightMapDepth;
    float fadeForLowerMips = saturatedLinearRemapZeroToOne(mipLevel, 2., 1.);
    if (fadeForLowerMips > 0.)
    {
        vec2 widthHeight = vec2(textureSize(heightmapTexture, 0));
        vec2 pixelCoord = heightmapUV * widthHeight;
        {
            const float kNudgePixelCentreDistEpsilon = 0.0625;
            const float kNudgeUvEpsilon = 0.25 / 65536.;
            vec2 nudgeSampleCoord = fract(pixelCoord);
            if (abs(nudgeSampleCoord.x - 0.5) < kNudgePixelCentreDistEpsilon)
            {
                heightmapUV.x += (nudgeSampleCoord.x > 0.5) ? kNudgeUvEpsilon : -kNudgeUvEpsilon;
            }
            if (abs(nudgeSampleCoord.y - 0.5) < kNudgePixelCentreDistEpsilon)
            {
                heightmapUV.y += (nudgeSampleCoord.y > 0.5) ? kNudgeUvEpsilon : -kNudgeUvEpsilon;
            }
        }
        vec4 heightSamples = textureGather(heightmapTexture, heightmapUV, 0);
        vec2 subPixelCoord = fract(pixelCoord + 0.5);
        const float kBevelMode = 0.0;
        vec2 axisSamplePair = (subPixelCoord.y > 0.5) ? heightSamples.xy : heightSamples.wz;
        float axisBevelCentreSampleCoord = subPixelCoord.x;
        axisBevelCentreSampleCoord += ((axisSamplePair.x > axisSamplePair.y) ? kHeightMapPixelEdgeWidth : -kHeightMapPixelEdgeWidth) * kBevelMode;
        ivec2 axisSampleIndices = ivec2(saturate(vec2(axisBevelCentreSampleCoord - kHeightMapPixelEdgeWidth, axisBevelCentreSampleCoord + kHeightMapPixelEdgeWidth) * 2.));
        tangentNormal.x = (axisSamplePair[axisSampleIndices.x] - axisSamplePair[axisSampleIndices.y]);
        axisSamplePair = (subPixelCoord.x > 0.5) ? heightSamples.zy : heightSamples.wx;
        axisBevelCentreSampleCoord = subPixelCoord.y;
        axisBevelCentreSampleCoord += ((axisSamplePair.x > axisSamplePair.y) ? kHeightMapPixelEdgeWidth : -kHeightMapPixelEdgeWidth) * kBevelMode;
        axisSampleIndices = ivec2(saturate(vec2(axisBevelCentreSampleCoord - kHeightMapPixelEdgeWidth, axisBevelCentreSampleCoord + kHeightMapPixelEdgeWidth) * 2.));
        tangentNormal.y = (axisSamplePair[axisSampleIndices.x] - axisSamplePair[axisSampleIndices.y]);
        tangentNormal.z = kRecipHeightMapDepth;
        tangentNormal = normalize(tangentNormal);
        tangentNormal.xy *= fadeForLowerMips;
    }
    return tangentNormal;
}

vec2 getPBRDataUV(vec2 surfaceUV, vec2 uvScale, vec2 uvBias)
{
    return (((surfaceUV) * (uvScale)) + uvBias);
}

#endif

vec4 applySeasons(vec3 vertexColor, float vertexAlpha, vec4 diffuse)
{
    vec2 uv = vertexColor.xy;
    diffuse.rgb *= mix(vec3(1.0, 1.0, 1.0), texture2D(s_SeasonsTexture, uv).rgb * 2.0, vertexColor.b);
    diffuse.rgb *= vec3_splat(vertexAlpha);
    diffuse.a = 1.0;
    return diffuse;
}

float sRGB(float x)
{
    if (x <= 0.00031308)
        return 12.92 * x;
    else
        return 1.055 * pow(x, (1.0 / 2.4)) - 0.055;
}

void main()
{
    vec4 diffuse = texture2D(s_MatTexture, v_texcoord0);
    bool needDiscard = false;

#if defined(ALPHA_TEST_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS) || defined(DEPTH_ONLY_PASS)
    const float ALPHA_THRESHOLD = 0.5;
    if (diffuse.a < ALPHA_THRESHOLD)
    {
        needDiscard = true;
    }
#endif

#if defined(SEASONS__ON) && !defined(TRANSPARENT_PASS) && !defined(TRANSPARENT_PBR_PASS)
    diffuse = applySeasons(v_color0.rgb, v_color0.a, diffuse);
#else
    diffuse.rgb *= v_color0.rgb;
    diffuse.a *= v_color0.a;
#endif

    int isLightOverlay = 0;

    if (v_normal.y > 0.99)
    {
        vec3 cp = fract(v_position);

        cp.x = cp.x * 3.0 - 1.1;
        cp.z = cp.z * 3.0 - 1.1;

        bool isRedstoneDust = false;

#if (defined(ALPHA_TEST_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)) && (!defined(TRANSPARENT_PASS)) && (!defined(SEASONS__ON)) && (!defined(INSTANCING__ON))
        red_stone_level(needDiscard, isRedstoneDust, diffuse, cp, v_color0.rgb);
#endif

#ifdef LIGHT_OVERLAY

        if (!(isRedstoneDust) && length(v_worldPos) < 64.0)
        {
            light_overlay(needDiscard, isLightOverlay, cp, v_lightmapUV);
        }

#endif
    }

#if defined(ALPHA_TEST_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS) || defined(DEPTH_ONLY_PASS)
    if (needDiscard)
    {
        discard;
    }
#endif

    float blockLight = v_lightmapUV.x;
    float skyLight = v_lightmapUV.y;

#if defined(NIGHT_VISION)
    blockLight = 1.0;
    skyLight = 1.0;
#endif

#ifdef LIGHT_OVERLAY
    if (isLightOverlay == 1)
    {
        diffuse = mix(diffuse, vec4(0.0, 1.0, 0.0, 1.5), 0.15);
        blockLight = 1.0;
        skyLight = 1.0;
    }
    else if (isLightOverlay == 2)
    {
        diffuse = mix(diffuse, vec4(1.0, 0.0, 0.0, 1.0), 0.3);
        blockLight = 1.0;
        skyLight = 1.0;
    }
#endif

#ifdef CHUNK_BORDERS
    chunk_border(diffuse, v_position);
#endif

    const int kInvalidPBRTextureHandle = 0xffff;
    const int kPBRTextureDataFlagHasMaterialTexture = (1 << 0);
    const int kPBRTextureDataFlagHasSubsurfaceChannel = (1 << 1);
    const int kPBRTextureDataFlagHasNormalTexture = (1 << 2);
    const int kPBRTextureDataFlagHasHeightMapTexture = (1 << 3);
#if (defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)
    // RenderChunkSurfGeometryPrepass
    // applyPBRValuesToSurfaceOutput
    PBRTextureData pbrTextureData = s_PBRData[v_pbrTextureId];
    vec2 normalUVScale = vec2(pbrTextureData.colourToNormalUvScale0, pbrTextureData.colourToNormalUvScale1);
    vec2 normalUVBias = vec2(pbrTextureData.colourToNormalUvBias0, pbrTextureData.colourToNormalUvBias1);
    vec2 materialUVScale = vec2(pbrTextureData.colourToMaterialUvScale0, pbrTextureData.colourToMaterialUvScale1);
    vec2 materialUVBias = vec2(pbrTextureData.colourToMaterialUvBias0, pbrTextureData.colourToMaterialUvBias1);

    vec3 tangentNormal = vec3(0, 0, 1);
    if ((pbrTextureData.flags & kPBRTextureDataFlagHasNormalTexture) == kPBRTextureDataFlagHasNormalTexture)
    {
        vec2 uv = getPBRDataUV(v_texcoord0, normalUVScale, normalUVBias);
        tangentNormal = texture2D(s_MatTexture, uv).xyz * 2. - 1.;
    }
    else if ((pbrTextureData.flags & kPBRTextureDataFlagHasHeightMapTexture) == kPBRTextureDataFlagHasHeightMapTexture)
    {
        vec2 normalUv = getPBRDataUV(v_texcoord0, normalUVScale, normalUVBias);
        float normalMipLevel = min(pbrTextureData.maxMipNormal - pbrTextureData.maxMipColour, pbrTextureData.maxMipNormal);
        tangentNormal = calculateTangentNormalFromHeightmap(s_MatTexture, normalUv, normalMipLevel);
    }

    float metalness = pbrTextureData.uniformMetalness;
    float emissive = pbrTextureData.uniformEmissive;
    float linearRoughness = pbrTextureData.uniformRoughness;
    float subsurface = pbrTextureData.uniformSubsurface;
    if ((pbrTextureData.flags & kPBRTextureDataFlagHasMaterialTexture) == kPBRTextureDataFlagHasMaterialTexture)
    {
        vec2 uv = getPBRDataUV(v_texcoord0, materialUVScale, materialUVBias);
        vec4 texel = texture2D(s_MatTexture, uv).rgba;
        metalness = texel.r;
        emissive = texel.g;
        linearRoughness = texel.b;
        if ((pbrTextureData.flags & kPBRTextureDataFlagHasSubsurfaceChannel) == kPBRTextureDataFlagHasSubsurfaceChannel)
        {
            subsurface = texel.a;
        };
    }

    mat3 tbn = mtxFromRows(normalize(v_tangent), normalize(v_bitangent), normalize(v_normal));
    tbn = transpose(tbn);
    vec3 viewSpaceNormal = mul(tbn, tangentNormal).xyz;

    // computeLighting_RenderChunk_SplitLightMapValues

    // RenderChunkGeometryPrepass
    // applyPrepassSurfaceToGBuffer
    gl_FragData[0].rgb = diffuse.rgb;
    gl_FragData[0].a = packMetalnessSubsurface(metalness, subsurface);

    vec3 worldPosition = v_worldPos.xyz;
    vec3 prevWorldPosition = v_worldPos.xyz - u_prevWorldPosOffset.xyz;

    vec3 viewNormal = normalize(viewSpaceNormal).xyz;
    gl_FragData[1].xy = ndirToOctSnorm(viewNormal);

    gl_FragData[1].zw = calculateMotionVector(worldPosition, prevWorldPosition);

    gl_FragData[2] = vec4(emissive, blockLight, skyLight, linearRoughness);

#else

#if defined(DEPTH_ONLY_PASS) || defined(DEPTH_ONLY_OPAQUE_PASS)
    diffuse = vec4(1.0, 1.0, 1.0, 1.0);
#endif

#if defined(TRANSPARENT_PBR_PASS)
    // computeLighting_RenderChunk_Split
    diffuse.rgb *= saturate(blockLight + skyLight);
#endif

    gl_FragData[0].rgb = mix(diffuse.rgb, FogColor.rgb, v_fog.a);
    gl_FragData[0].a = diffuse.a;
    gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
    gl_FragData[2] = vec4(0.0, 0.0, 0.0, 0.0);

#endif
}

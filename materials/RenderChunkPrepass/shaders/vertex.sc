$input a_color0, a_position, a_texcoord0, a_texcoord1, a_normal, a_tangent
#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)
$input a_texcoord4
#endif
#ifdef INSTANCING__ON
$input i_data0, i_data1, i_data2
#endif

$output v_color0, v_fog, v_normal, v_tangent, v_bitangent, v_texcoord0, v_lightmapUV, v_position, v_worldPos, v_blockAmbientContribution, v_skyAmbientContribution
#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)
$output v_pbrTextureId
#endif

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/TAAUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>
#include <MinecraftRenderer.Materials/LightUtil.dragonh>

uniform vec4 RenderChunkFogAlpha;
uniform vec4 FogAndDistanceControl;
uniform vec4 ViewPositionAndTime;
uniform vec4 FogColor;
uniform vec4 GlobalRoughness;
uniform vec4 LightWorldSpaceDirection;
uniform vec4 LightDiffuseColorAndIlluminance;

void transformAsBillboardVertex(inout vec3 worldPos, vec4 color0, out vec4 position) {
worldPos += vec3(0.5, 0.5, 0.5);
vec3 forward = normalize(worldPos - ViewPositionAndTime.xyz);
vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), forward));
vec3 up = cross(forward, right);
vec3 offsets = color0.xyz;
worldPos -= up * (offsets.z - 0.5) + right * (offsets.x - 0.5);
position = mul(u_viewProj, vec4(worldPos, 1.0));
}

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
#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)
    //RenderChunkPrepassVert
    //applyPBRValuesToVertexOutput
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
    //RenderChunkVert
    #ifdef RENDER_AS_BILLBOARDS__ON
color0 = vec4(1.0, 1.0, 1.0, 1.0);
transformAsBillboardVertex(worldPosition, a_color0, position);
    #endif

float cameraDepth = length(ViewPositionAndTime.xyz - worldPosition);
    // float fogIntensity = calculateFogIntensityFadedVanilla(cameraDepth, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y, RenderChunkFogAlpha.x);
float fogIntensity = calculateFogIntensityFaded(cameraDepth, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y, RenderChunkFogAlpha.x);
fog = vec4(FogColor.rgb, fogIntensity);

    #if defined(TRANSPARENT_PASS) || defined(TRANSPARENT_PBR_PASS)
        //RenderChunkVertTransparent
bool shouldBecomeOpaqueInTheDistance = a_color0.a < 0.95;
if(shouldBecomeOpaqueInTheDistance) {
float cameraDistance = cameraDepth / FogAndDistanceControl.w;
float alphaFadeOut = clamp(cameraDistance, 0.0, 1.0);
color0.a = mix(a_color0.a, 1.0, alphaFadeOut);
}
    #endif

#endif

v_position = a_position;
v_texcoord0 = texcoord0;
v_color0 = color0;
v_fog = fog;
v_lightmapUV = computeLighting_RenderChunk_Vertex(a_texcoord1);
v_tangent = tangent;
v_normal = normal;
v_bitangent = bitangent;
v_worldPos = worldPosition;
v_skyAmbientContribution = vec3(0, 0, 0);
v_blockAmbientContribution = vec3(0, 0, 0);

#if defined(GEOMETRY_PREPASS_PASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST_PASS)
v_pbrTextureId = pbrTextureId;
#endif

gl_Position = position;
}

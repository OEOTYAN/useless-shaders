#include "ShaderConstants.fxh"
#include "util.fxh"

struct VS_Input {
    float3 position : POSITION;
    float4 color : COLOR;
    float2 uv0 : TEXCOORD_0;
    float2 uv1 : TEXCOORD_1;
#ifdef INSTANCEDSTEREO
    uint instanceID : SV_InstanceID;
#endif
};

struct PS_Input {
    float4 position : SV_Position;
    float3 worldPos : worldPos;
    float3 chunkPos : chunkPos;
#ifndef BYPASS_PIXEL_SHADER
    lpfloat4 color : COLOR;
     float2 uv0 : TEXCOORD_0_FB_MSAA;
     float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

#ifdef FOG
    float4 fogColor : FOG_COLOR;
#endif
#ifdef GEOMETRY_INSTANCEDSTEREO
    uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
    uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

static const float rA = 1.0;
static const float rB = 1.0;
static const float3 UNIT_Y = float3(0, 1, 0);
static const float DIST_DESATURATION =
    56.0 / 255.0;  // WARNING this value is also hardcoded in the water color,
                   // don'tchange

float getleaao(float3 c)
{
const float3 O = float3(0.682352941176471,0.643137254901961, 0.164705882352941);

const float3 N = float3(0.195996912842436,0.978673548072766,-0.061508507207520);

return dot(c, float3(0.260278,1.29965,-0.0816814));
}

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput) {
#ifndef BYPASS_PIXEL_SHADER
    PSInput.uv0 = VSInput.uv0;
    PSInput.uv1 = VSInput.uv1;
    PSInput.color = VSInput.color;
#endif

float3 mPos=VSInput.position.xyz;

#if !defined(AS_ENTITY_RENDERER)&&defined(BLEND)&&!defined(BYPASS_PIXEL_SHADER)&&defined(WAVING_WATER)
bool iswater=false;
    if (PSInput.color.a>0.05&&PSInput.color.a<0.95&&abs(PSInput.color.b-PSInput.color.g)+abs(PSInput.color.r-PSInput.color.g)>0.0001&&abs(abs(frac(VSInput.position.y)-0.5)-0.5)>0.0001) {
        iswater = true;
    }
#endif

#if !defined(AS_ENTITY_RENDERER)&&defined(BLEND)&&!defined(BYPASS_PIXEL_SHADER)&&defined(WAVING_WATER)
if(iswater){
        float3 mPos2=fmod(VSInput.position.xyz,16);

// float lightWeight = clamp((input[j].uv1.y * 33.05f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);
    //   lightWeight *= 1.1f;
    //   lightWeight -= 0.1f;
    //   lightWeight = max(0.0f, lightWeight);
    //  lightWeight = Pow5(lightWeight);

float speed =  0.1;

		float magnitude = (sin(((mPos2.y + mPos2.x)/2.0 + TIME * 3.14159265358979323846264 / ((28.0)))) * 0.055 + 0.045) ;
		float d2 = sin(TIME * 3.14159265358979323846264 / (112.0 * speed)) * 3.0 - 1.5;
		float d3 = sin(TIME * 3.14159265358979323846264 / (142.0 * speed)) * 3.0 - 1.5;
        mPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.z + d2) + (mPos2.x + d3)) * magnitude*frac(VSInput.position.y+0.005);
} 
#endif
    PSInput.chunkPos = mPos;

#ifdef AS_ENTITY_RENDERER
#ifdef INSTANCEDSTEREO
    int i = VSInput.instanceID;
    PSInput.position =
        mul(WORLDVIEWPROJ_STEREO[i], float4(mPos, 1));
#else
    PSInput.position = mul(WORLDVIEWPROJ, float4(mPos, 1));
#endif
    float3 worldPos = PSInput.position;
#else
    float3 worldPos = (mPos * CHUNK_ORIGIN_AND_SCALE.w) +
                      CHUNK_ORIGIN_AND_SCALE.xyz;

    // Transform to view space before projection instead of all at once to avoid
    // floating point errors Not required for entities because they are already
    // offset by camera translation before rendering World position here is
    // calculated above and can get huge
#ifdef INSTANCEDSTEREO
    int i = VSInput.instanceID;

    PSInput.position = mul(WORLDVIEW_STEREO[i], float4(worldPos, 1));
    PSInput.position = mul(PROJ_STEREO[i], PSInput.position);

#else
    PSInput.position = mul(WORLDVIEW, float4(worldPos, 1));
    PSInput.position = mul(PROJ, PSInput.position);
#endif
#endif

    PSInput.worldPos = worldPos;
#ifdef GEOMETRY_INSTANCEDSTEREO
    PSInput.instanceID = VSInput.instanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
    PSInput.renTarget_id = VSInput.instanceID;
#endif
    ///// find distance from the camera

#if defined(FOG) || defined(BLEND)
#ifdef FANCY
    float3 relPos = -worldPos;
    float cameraDepth = length(relPos);
#else
    float cameraDepth = PSInput.position.z;
#endif
#endif

    ///// apply fog

#ifdef FOG
    float len = cameraDepth / RENDER_DISTANCE;
#ifdef ALLOW_FADE
    len += RENDER_CHUNK_FOG_ALPHA.r;
#endif

    PSInput.fogColor.rgb = FOG_COLOR.rgb;
    PSInput.fogColor.a = clamp(
        (len - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);

#endif

    ///// blended layer (mostly water) magic
    /*
    #ifdef BLEND
        //Mega hack: only things that become opaque are allowed to have
    vertex-driven transparency in the Blended layer...
        //to fix this we'd need to find more space for a flag in the vertex
    format. color.a is the only unused part bool shouldBecomeOpaqueInTheDistance
    = VSInput.color.a < 0.95; if(shouldBecomeOpaqueInTheDistance) { #ifdef FANCY
    /////enhance water float cameraDist = cameraDepth / FAR_CHUNKS_DISTANCE;
            #else
                float3 relPos = -worldPos.xyz;
                float camDist = length(relPos);
                float cameraDist = camDist / FAR_CHUNKS_DISTANCE;
            #endif //FANCY

            float alphaFadeOut = clamp(cameraDist, 0.0, 1.0);
            PSInput.color.a = lerp(VSInput.color.a, 1.0, alphaFadeOut);
        }
    #endif
    */
    // PSInput.position.xyz/=PSInput.position.w/abs(tan(TIME/10.0));
    // PSInput.position.w=abs(tan(TIME/10.0));
}

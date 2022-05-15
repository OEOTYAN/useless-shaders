#include "ShaderConstants.fxh"

struct VS_Input {
	float3 position : POSITION;
#ifdef USE_SKINNING
	uint boneId : BONEID_0;
#endif
	float4 normal : NORMAL;
	float2 texCoords : TEXCOORD_0;
	float4 color : COLOR;

#ifdef INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
};

struct PS_Input {
	float4 position : SV_Position;
    #ifndef UI_ENTITY
    float3 worldpos : worldpos;
#endif

#ifdef ENABLE_LIGHT
	float4 light : LIGHT;
#endif
#ifdef ENABLE_FOG
	float4 fogColor : FOG_COLOR;
#endif

#ifndef DISABLE_TINTING
	float4 color : COLOR;
#endif
	float4 texCoords : TEXCOORD_0_FB_MSAA;
	
#ifdef GEOMETRY_INSTANCEDSTEREO
	uint instanceID : SV_InstanceID;
#endif
#ifdef VERTEXSHADER_INSTANCEDSTEREO
	uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

static const float AMBIENT = 0.45;

static const float XFAC = -0.1;
static const float ZFAC = 0.1;

float4 TransformRGBA8_SNORM(const float4 RGBA8_SNORM) {
#ifdef R8G8B8A8_SNORM_UNSUPPORTED
	return RGBA8_SNORM * float(2.0).xxxx - float(1.0).xxxx;
#else
	return RGBA8_SNORM;
#endif
}


float lightIntensity(const float4x4 worldMat, const float4 position, const float4 normal) {
	float3 N = -normalize(mul(worldMat, normal)).xyz;

	N.y *= TILE_LIGHT_COLOR.a;

	//take care of double sided polygons on materials without culling
#ifdef FLIP_BACKFACES
	float3 viewDir = normalize((mul(worldMat, position)).xyz);
	if (dot(N, viewDir) > 0.0) {
		N *= -1.0;
	}
#endif

	float yLight = (1.0 + N.y) * 0.5;
	return yLight * (1.0 - AMBIENT) + N.x*N.x * XFAC + N.z*N.z * ZFAC + AMBIENT;

}

ROOT_SIGNATURE
void main(in VS_Input VSInput, out PS_Input PSInput)
{
#ifdef INSTANCEDSTEREO
	int i = VSInput.instanceID;
	#ifdef USE_SKINNING
		PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
	#else
		PSInput.position = mul(WORLDVIEWPROJ_STEREO[i], float4(VSInput.position, 1));
	#endif
	#ifdef GEOMETRY_INSTANCEDSTEREO
		PSInput.instanceID = i;
	#endif 
	#ifdef VERTEXSHADER_INSTANCEDSTEREO
		PSInput.renTarget_id = i;
	#endif
#else
	#ifdef USE_SKINNING
		PSInput.position = mul(WORLDVIEWPROJ, mul(BONES[VSInput.boneId], float4(VSInput.position, 1)));
	#else
		PSInput.position = mul(WORLDVIEWPROJ, float4(VSInput.position, 1));
	#endif
#endif
    #ifndef UI_ENTITY
	#ifdef USE_SKINNING
PSInput.worldpos=mul(BONES[VSInput.boneId], float4(VSInput.position, 1)).xyz;
    	#else
PSInput.worldpos=VSInput.position;
	#endif
#endif
#ifdef ENABLE_LIGHT
	float4 normal = TransformRGBA8_SNORM(VSInput.normal);

#ifdef USE_SKINNING
	float L = lightIntensity(BONES[VSInput.boneId], float4(VSInput.position, 1), normal);
#elif !defined(INSTANCEDSTEREO)
	float L = lightIntensity(WORLD, float4(VSInput.position, 1), normal);
#else
	float L = lightIntensity(WORLD_STEREO, float4(VSInput.position, 1), normal);
#endif

#ifndef ALWAYS_LIT
	PSInput.light = float4(L.xxx * TILE_LIGHT_COLOR.rgb, 1.0);
#else
	PSInput.light = float4(L.xxx, 1.0);
#endif
#endif

	int frameIndex = int(VSInput.color.a * 255.0f);
	PSInput.texCoords.xy = (VSInput.texCoords.xy * BANNER_UV_OFFSETS_AND_SCALES[frameIndex].zw) + BANNER_UV_OFFSETS_AND_SCALES[frameIndex].xy;
	PSInput.texCoords.zw = (VSInput.texCoords.xy * BANNER_UV_OFFSETS_AND_SCALES[0].zw) + BANNER_UV_OFFSETS_AND_SCALES[0].xy;

#ifndef DISABLE_TINTING
	PSInput.color = BANNER_COLORS[frameIndex];
	PSInput.color.a = 1.0f;
	if (frameIndex > 0) {
		PSInput.color.a = 0.0f;
	}
#endif

#ifdef ENABLE_FOG
	//fog
	PSInput.fogColor.rgb = FOG_COLOR.rgb;
	PSInput.fogColor.a = clamp(((PSInput.position.z / RENDER_DISTANCE) - FOG_CONTROL.x) / (FOG_CONTROL.y - FOG_CONTROL.x), 0.0, 1.0);
#endif
}


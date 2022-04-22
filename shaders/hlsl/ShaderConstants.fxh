#define ITEM_XRAY
#define ENABLE_OUTLINE
#define OUTLINE_WIDTH 0.02
#define ENABLE_BLOCK_MAP
#define ENABLE_ENTITY_MAP
#define ENABLE_PLAYER_MAP
#define ENABLE_CHUNK_LOADING_ANIMATION
#define INV_ASPECT_RATIO 17.0/32.0
#define CHUNK_BOARD_MSAA 5
#define TEXTURE_MSAA 3
#define TEXT_MSAA 6
#define TICKING_DIS 10
//#define SHOW_TICKING_DIS
#define SHOW_MAP_TICKING_DIS
#define WATER_MIX 0.06
#define BLOCK_PSIZE 0.019
#define PLAYER_MAP_SIZE 0.015
//#define ALWAYS_LIT
//#define LIGHT_OVERLAY
#define WAVING_WHEAT
#define WAVING_LEAVES
#define WAVING_WATERLILY
#define WAVING_WATER
//#define FOG
//#define ORE_XRAY //has some bugs



// These [aren't but] should be grouped in a way that they require the least amount of updating (world data in one, model data in another, part of model data in another one, etc)

// This define specifies our uber root signature so that it can be 
// included at shader compile time, which speeds up PSO creation time.
// https://msdn.microsoft.com/en-us/library/windows/desktop/dn913202(v=vs.85).aspx
#define MinecraftRootSignature "RootFlags(ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT | DENY_DOMAIN_SHADER_ROOT_ACCESS | DENY_GEOMETRY_SHADER_ROOT_ACCESS | DENY_HULL_SHADER_ROOT_ACCESS), " \
	"DescriptorTable(SRV(t0)), " \
	"DescriptorTable(SRV(t1)), " \
	"DescriptorTable(SRV(t2)), " \
	"DescriptorTable(SRV(t3)), " \
	"DescriptorTable(SRV(t4)), " \
	"DescriptorTable(SRV(t5)), " \
	"DescriptorTable(SRV(t6)), " \
	"DescriptorTable(SRV(t7)), " \
	"DescriptorTable(SRV(t8)), " \
	"DescriptorTable(SRV(t9)), " \
	"DescriptorTable(SRV(t10)), " \
	"DescriptorTable(SRV(t11)), " \
	"DescriptorTable(SRV(t12)), " \
	"DescriptorTable(SRV(t13)), " \
	"DescriptorTable(SRV(t14)), " \
	"DescriptorTable(SRV(t15)), " \
	"DescriptorTable(Sampler(s0)), " \
	"DescriptorTable(Sampler(s1)), " \
	"DescriptorTable(Sampler(s2)), " \
	"DescriptorTable(Sampler(s3)), " \
	"DescriptorTable(Sampler(s4)), " \
	"DescriptorTable(Sampler(s5)), " \
	"DescriptorTable(Sampler(s6)), " \
	"DescriptorTable(Sampler(s7)), " \
	"DescriptorTable(Sampler(s8)), " \
	"DescriptorTable(Sampler(s9)), " \
	"DescriptorTable(Sampler(s10)), " \
	"DescriptorTable(Sampler(s11)), " \
	"DescriptorTable(Sampler(s12)), " \
	"DescriptorTable(Sampler(s13)), " \
	"DescriptorTable(Sampler(s14)), " \
	"DescriptorTable(Sampler(s15)), " \
	"CBV(b0, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b1, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b2, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b3, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b4, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b5, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b6, visibility=SHADER_VISIBILITY_PIXEL), " \
	"CBV(b0, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b1, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b2, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b3, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b4, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b5, visibility=SHADER_VISIBILITY_VERTEX), " \
	"CBV(b6, visibility=SHADER_VISIBILITY_VERTEX)"

// HLSL root signatures require SM 5.0 or higher.  We only use SM 5.0
// or higher when the Feature Level is 11_0 or above.  Specifying a 
// root signature when compiling for DX11 silently ignores the root
// signature.
#if (VERSION >= 0xb000) 
#define ROOT_SIGNATURE [RootSignature(MinecraftRootSignature)]
#else
#define ROOT_SIGNATURE 
#endif

#if (defined(USE_STEREO_TEXTURE_ARRAY) || defined(ARRAY_TEXTURE_0)) && (VERSION >= 0xa000)
Texture2DArray TEXTURE_0 : register (t0);
#else
Texture2DMS<float4> TEXTURE_0_MS : register(t0);
Texture2D TEXTURE_0 : register(t0);
#endif

Texture2DMS<float4> TEXTURE_1_MS : register(t1);
Texture2D TEXTURE_1 : register(t1);
Texture2D TEXTURE_2 : register(t2);
#ifndef NO_TEX_3
Texture2D TEXTURE_3 : register(t3);
sampler TextureSampler3 : register(s3);
#endif

// Make sure this thing is actually getting bound
sampler TextureSampler0 : register(s0);
sampler TextureSampler1 : register(s1);
sampler TextureSampler2 : register(s2);

#ifdef LOW_PRECISION
#define lpfloat min16float
#define lpfloat2 min16float2
#define lpfloat4 min16float4
#else
#define lpfloat float
#define lpfloat2 float2
#define lpfloat4 float4
#endif

#if defined(MSAA_FRAMEBUFFER_ENABLED)
#define TEXCOORD_0_FB_MSAA TEXCOORD_0_centroid
#define TEXCOORD_1_FB_MSAA TEXCOORD_1_centroid
#define TEXCOORD_2_FB_MSAA TEXCOORD_2_centroid
#define TEXCOORD_3_FB_MSAA TEXCOORD_3_centroid
#else
#define TEXCOORD_0_FB_MSAA TEXCOORD_0
#define TEXCOORD_1_FB_MSAA TEXCOORD_1
#define TEXCOORD_2_FB_MSAA TEXCOORD_2
#define TEXCOORD_3_FB_MSAA TEXCOORD_3
#endif


cbuffer RenderChunkConstants : register(b0)
{
	float4 CHUNK_ORIGIN_AND_SCALE;
	float RENDER_CHUNK_FOG_ALPHA;
}


cbuffer ActorConstants
{
	float4 OVERLAY_COLOR;
	float4 TILE_LIGHT_COLOR;
	float4 CHANGE_COLOR;
	float4 GLINT_COLOR;
	float4 UV_ANIM;
	float2 UV_OFFSET;
	float2 UV_ROTATION;
	float2 GLINT_UV_SCALE;
	float4 MULTIPLICATIVE_TINT_CHANGE_COLOR;
}

cbuffer PerFrameConstants : register(b2)
{

	float3 VIEW_POS;
	float TIME;

	float4 FOG_COLOR;

	float2 FOG_CONTROL;

	float RENDER_DISTANCE;
	float FAR_CHUNKS_DISTANCE;
}


#if !defined(INSTANCEDSTEREO)

cbuffer WorldConstants : register(b1)
{
	float4x4 WORLDVIEWPROJ;
	float4x4 WORLD;
	float4x4 WORLDVIEW;
	float4x4 PROJ;
}

#else

cbuffer WorldConstantsStereographic {
	float4x4 WORLDVIEWPROJ_STEREO[2];
	float4x4 WORLD_STEREO;
	float4x4 WORLDVIEW_STEREO[2];
	float4x4 PROJ_STEREO[2];
}

#endif

cbuffer AnimationConstants {
	float4x4 BONES[8];
}

cbuffer ShaderConstants : register(b3)
{
	float4 CURRENT_COLOR;
	float4 DARKEN;
	float3 TEXTURE_DIMENSIONS;
	float1 HUD_OPACITY;
	float4x4 UV_TRANSFORM;
	int MSAA_SAMPLECOUNT;
}

cbuffer WeatherConstants
{
	float4 POSITION_OFFSET;
	float4 VELOCITY;
	float4 ALPHA;
	float4 VIEW_POSITION;
	float4 SIZE_SCALE;
	float4 FORWARD;
	float4 UV_INFO;
	float4 PARTICLE_BOX;
}

cbuffer FlipbookTextureConstants
{
	float1 V_OFFSET;
	float1 V_BLEND_OFFSET;
}

cbuffer EffectsConstants
{
	float2 EFFECT_UV_OFFSET;


}

cbuffer BannerConstants
{
	float4 BANNER_COLORS[7];
	float4 BANNER_UV_OFFSETS_AND_SCALES[7];
}

cbuffer TextConstants
{
	float1 GLYPH_SMOOTH_RADIUS;
	float1 OUTLINE_CUTOFF;
	float1 SHADOW_SMOOTH_RADIUS;
	float4 SHADOW_COLOR;
	float2 SHADOW_OFFSET;
}
cbuffer DebugConstants
{
	float TEXTURE_ARRAY_INDEX_0;
};

cbuffer InterFrameConstants
{
	// in secs. This is reset every 2 mins. so the range is [0, 120)
	// make sure your shader handles the case when it transitions from 120 to 0
	float TOTAL_REAL_WORLD_TIME;
	float4x4 CUBE_MAP_ROTATION;
};

cbuffer PostProcessConstants {
	int GaussianBlurSize;
	float DepthOfFieldNearEndDepth;
	float DepthOfFieldFarStartDepth;
	float DepthOfFieldFarEndDepth;
};

cbuffer UITransformsConstants
{
	float4x4 TRANSFORM;
};

cbuffer UIStandardPrimitivePixelConstants
{
	int SHADER_TYPE;
};

cbuffer UIStandardPrimitiveAdditionalPixelConstants
{
	float4 PRIM_PROPS_0;
	float4 PRIM_PROPS_1;
};

cbuffer UIEffectsPixelConstants
{
	float4 COEFFICIENTS[3];
	float4 PIXEL_OFFSETS[6];
};

cbuffer UIRenoirShaderVSConstants
{
	float4x4 COORD_TRANSFORM;
	float4 RENOIR_SHADER_VS_PROPS_0;
};

cbuffer UIRenoirShaderPSConstants
{
	float4 RENOIR_SHADER_PS_PROPS_0;
	float4 RENOIR_SHADER_PS_PROPS_1;
	float4 RENOIR_SHADER_PS_PROPS_2;
	float4 RENOIR_SHADER_PS_PROPS_3;
};
#ifdef FOG
#define ENABLE_FOG
#endif
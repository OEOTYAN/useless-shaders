#include "ShaderConstants.fxh"
#define TEXEL_AA
#include "util.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
    float2 uv : TEXCOORD_0_FB_MSAA;
};

struct PS_Output
{
    float4 color : SV_Target;
};

float median(float a, float b, float c) {
    return max(min(a, b), min(max(a, b), c));
}

float InterleavedGradientNoise( float2 uv, float FrameId )
{
	// magic values are found by experimentation
	uv += FrameId * (float2(47, 17) * 0.695f);

    const float3 magic = float3( 0.06711056f, 0.00583715f, 52.9829189f );
    return frac(magic.z * frac(dot(uv, magic.xy)));
}
static const float GLYPH_UV_SIZE = 1.0 / 16.0;

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
    float2 uv0dx = ddx(PSInput.uv);
    float2 uv0dy = ddy(PSInput.uv);
    float2 uvmin=floor(PSInput.uv/GLYPH_UV_SIZE)*GLYPH_UV_SIZE;
    float4 diffuse;
#if USE_TEXEL_AA
        float3 sum=float3(0,0,0);
    float weight=0;
     for (int uv0i = 0; uv0i < TEXT_MSAA; uv0i++)
         for (int uv0j = 0; uv0j < TEXT_MSAA; uv0j++){
             float2 iter;
             iter.x=(uv0i) / (float)(TEXT_MSAA);
             iter.y=(uv0j) / (float)(TEXT_MSAA);
            //  iter-=0.5;
            //  iter*=1;
            //  iter+=0.5;
             float2 luv0 =
                 GLYPH_UV_SIZE*ftri((PSInput.uv + uv0dx *iter.x  + uv0dy * iter.y-uvmin)/GLYPH_UV_SIZE);
                 luv0-=GLYPH_UV_SIZE*0.5;
                 luv0*=0.995;
                 luv0+=GLYPH_UV_SIZE*0.5;
        float4 tmpcolor=texture2Dlod_AA(TEXTURE_0, TextureSampler0,luv0+uvmin,0);

        weight+=tmpcolor.a;
        sum+=tmpcolor.a*pow(tmpcolor.rgb,2.2);
    }
    diffuse = float4(pow(sum/weight,1.0/2.2),weight/ (float)(TEXT_MSAA*TEXT_MSAA));
    //float4 diffuse = texture2Dlod_AA(TEXTURE_0, TextureSampler0,uvmin+0.0625*ftri((PSInput.uv-uvmin+uv0dx*rands.x+uv0dy*rands.y)*16.0),0);
    //TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
    #else
    
    diffuse = texture2Dlod_AA(TEXTURE_0, TextureSampler0,PSInput.uv,0);
#endif


#ifdef ALPHA_TEST
    if (diffuse.a < 0.001)
    {
        discard;
    }
#endif

#ifdef MSDF
    float4 resultColor = PSInput.color;

    const float sampleDistance = median(diffuse.r, diffuse.g, diffuse.b);

    const float outerEdgeAlpha = smoothstep(max(0.0, OUTLINE_CUTOFF - GLYPH_SMOOTH_RADIUS), min(1.0, OUTLINE_CUTOFF + GLYPH_SMOOTH_RADIUS), sampleDistance);
    // Apply stroke (outline) cutoff
    resultColor = float4(resultColor.rgb, resultColor.a * outerEdgeAlpha);

    const float2 topLeft = floor(PSInput.uv / GLYPH_UV_SIZE) * GLYPH_UV_SIZE;
    const float2 bottomRight = floor(PSInput.uv / GLYPH_UV_SIZE) * GLYPH_UV_SIZE + GLYPH_UV_SIZE;

    const float4 shadowSample = TEXTURE_0.Sample(TextureSampler0, clamp(PSInput.uv - SHADOW_OFFSET, topLeft, bottomRight));
    const float shadowDistance = shadowSample.a;
    const float shadowAlpha = smoothstep(max(0.0, OUTLINE_CUTOFF - SHADOW_SMOOTH_RADIUS), min(1.0, OUTLINE_CUTOFF + SHADOW_SMOOTH_RADIUS), shadowDistance);
    // Apply shadow past the stroke
    resultColor = lerp(float4(SHADOW_COLOR.rgb, SHADOW_COLOR.a * shadowAlpha), resultColor, outerEdgeAlpha);

    diffuse = resultColor;
#else
    diffuse *= PSInput.color;
#endif

    PSOutput.color = diffuse * DARKEN;
}
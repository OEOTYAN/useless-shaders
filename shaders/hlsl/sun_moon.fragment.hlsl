#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float2 uv : TEXCOORD_0_FB_MSAA;
    float3 sufacepos : sufacepos;
	float3 barys : barys;
};

struct PS_Output
{
    float4 color : SV_Target;
};

#define PI	3.141592653589793f

float4 ImportanceSampleGGXaniso( float2 E, float RoughnessX, float RoughnessY )
{
	float ax = RoughnessX * RoughnessX;
	float ay = RoughnessY * RoughnessY;

	float Phi = atan( ay / ax * tan( 2 * PI * E.x ) ) + ceil ( 2 * E.x - 0.5 ) * PI;
	float CosPhi = cos( Phi );
	float SinPhi = sin( Phi );
    float k = CosPhi*CosPhi / (ax*ax) + SinPhi*SinPhi / (ay*ay);
	float CosTheta = sqrt( (1 - E.y) / ( 1 + ( 1 / k - 1) * E.y ) );
	float CosTheta2 = CosTheta * CosTheta;
	float SinTheta = sqrt( 1 - CosTheta2 );

	float3 H;
	H.x = SinTheta * CosPhi;
	H.y = SinTheta * SinPhi;
	H.z = CosTheta;
	
	float d = SinTheta * SinTheta * k + CosTheta2;
	float D = 1 / ( PI * ax*ay * d*d );
	float PDF = D * CosTheta;

	return float4( H , PDF );
}

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv);
#else
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
#endif

#ifdef ALPHA_TEST
    if( diffuse.a < 0.5 )
    {
        discard;
    }
#endif

#ifdef IGNORE_CURRENTCOLOR
    diffuse = diffuse;
#else
    diffuse = CURRENT_COLOR * diffuse;
#endif/*
diffuse.rgb=PSInput.sufacepos;
	 float3 deltas = fwidth(PSInput.barys);
	 float3 smoothing = deltas ;
	 float3 thickness = deltas ;
	 float3 baryss = smoothstep(thickness,thickness+smoothing,PSInput.barys);
	 PSOutput.color.rgb = lerp(float3(0,0,0), diffuse.rgb,min(baryss.x,min(baryss.z,baryss.y)));
     PSOutput.color.a=1;*/
	 PSOutput.color =  diffuse;
}

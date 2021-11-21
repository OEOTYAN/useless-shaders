#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input//片元着色器输入结构体,应与几何着色器中的GeometryShaderOutput保持一致
{
	float4 position : SV_Position;//经过屏幕映射后的坐标

#ifndef BYPASS_PIXEL_SHADER
	lpfloat4 color : COLOR;//颜色
	snorm float2 uv0 : TEXCOORD_0_FB_MSAA;//材质uv
	snorm float2 uv1 : TEXCOORD_1_FB_MSAA;//光照uv
#endif

#ifdef FOG
	float4 fogColor : FOG_COLOR;//雾颜色
#endif
};

struct PS_Output//片元着色器输出结构体
{
	float4 color : SV_Target;//片元最终的颜色
};

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
#ifdef BYPASS_PIXEL_SHADER
    PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    return;
#else

#if USE_TEXEL_AA
	float4 diffuse = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0 );//使用纹理抗锯齿的函数, 在util.fxh中定义
#else
	float4 diffuse = TEXTURE_0.Sample(TextureSampler0, PSInput.uv0);//直接采样
#endif

#ifdef SEASONS_FAR
	diffuse.a = 1.0f;
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a < ALPHA_THRESHOLD)
		discard;//丢弃片元, 使其不渲染
#endif

#if defined(BLEND)
	diffuse.a *= PSInput.color.a;
#endif

#if !defined(ALWAYS_LIT)
	diffuse = diffuse * TEXTURE_1.Sample(TextureSampler1, PSInput.uv1);//原版光照渲染
#endif

#ifndef SEASONS
	#if !USE_ALPHA_TEST && !defined(BLEND)
		diffuse.a = PSInput.color.a;
	#endif	

	diffuse.rgb *= PSInput.color.rgb;//混合输入颜色
#else
	float2 uv = PSInput.color.xy;
	diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb*2.0f, PSInput.color.b);
	diffuse.rgb *= PSInput.color.aaa;
	diffuse.a = 1.0f;
#endif

#ifdef FOG
	diffuse.rgb = lerp( diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a );//雾
#endif

	PSOutput.color = diffuse;

#ifdef VR_MODE
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif // BYPASS_PIXEL_SHADER
}

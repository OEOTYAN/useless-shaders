cbuffer _15_17 : register(b1, space0)
{
    float4 _17_m0[1] : packoffset(c0);
};

Texture2D<float4> _8 : register(t0, space0);
Texture2D<float4> _9 : register(t1, space0);
Texture2D<float4> _10 : register(t2, space0);
SamplerState _20 : register(s0, space0);
SamplerState _21 : register(s1, space0);
SamplerState _22 : register(s2, space0);

static float4 COLOR;
static float4 COLOR_2;
static float2 TEXCOORD_1;
static float2 TEXCOORD;
static float4 SV_Target;

struct SPIRV_Cross_Input
{
    float4 COLOR : TEXCOORD1;
    float4 COLOR_2 : TEXCOORD2;
    float2 TEXCOORD_1 : TEXCOORD3;
    centroid float2 TEXCOORD : TEXCOORD4;
};

struct SPIRV_Cross_Output
{
    float4 SV_Target : SV_Target0;
};

void frag_main()
{
    float4 _64 = _8.Sample(_20, float2(TEXCOORD.x, TEXCOORD.y));
    float4 _70 = _10.Sample(_22, float2(COLOR.x, COLOR.y));
    float4 _91 = _9.Sample(_21, float2(TEXCOORD_1.x, TEXCOORD_1.y));
    float _98 = ((_64.x * COLOR.w) * ((((_70.x * 2.0f) + (-1.0f)) * COLOR.z) + 1.0f)) * _91.x;
    float _101 = ((_64.y * COLOR.w) * ((((_70.y * 2.0f) + (-1.0f)) * COLOR.z) + 1.0f)) * _91.y;
    float _104 = ((_64.z * COLOR.w) * ((((_70.z * 2.0f) + (-1.0f)) * COLOR.z) + 1.0f)) * _91.z;
    SV_Target.x = ((_17_m0[0u].x - _98) * COLOR_2.w) + _98;
    SV_Target.y = ((_17_m0[0u].y - _101) * COLOR_2.w) + _101;
    SV_Target.z = ((_17_m0[0u].z - _104) * COLOR_2.w) + _104;
    SV_Target.w = 1.0f;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    COLOR = stage_input.COLOR;
    COLOR_2 = stage_input.COLOR_2;
    TEXCOORD_1 = stage_input.TEXCOORD_1;
    TEXCOORD = stage_input.TEXCOORD;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.SV_Target = SV_Target;
    return stage_output;
}

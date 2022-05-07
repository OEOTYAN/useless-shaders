cbuffer _13_15 : register(b1, space0)
{
    float4 _15_m0[1] : packoffset(c0);
};

Texture2D<float4> _8 : register(t1, space0);
SamplerState _18 : register(s1, space0);

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
    float4 _43 = _8.Sample(_18, float2(TEXCOORD_1.x, TEXCOORD_1.y));
    float _45 = _43.x;
    float _46 = _43.y;
    float _47 = _43.z;
    SV_Target.x = ((_15_m0[0u].x - _45) * COLOR_2.w) + _45;
    SV_Target.y = ((_15_m0[0u].y - _46) * COLOR_2.w) + _46;
    SV_Target.z = ((_15_m0[0u].z - _47) * COLOR_2.w) + _47;
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

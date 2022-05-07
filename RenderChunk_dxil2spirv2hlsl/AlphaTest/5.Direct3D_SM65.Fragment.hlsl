cbuffer _14_16 : register(b1, space0)
{
    float4 _16_m0[1] : packoffset(c0);
};

Texture2D<float4> s_MatTexture : register(t0, space0);
Texture2D<float4> s_LightMapTexture : register(t1, space0);
SamplerState MatTextureSampler : register(s0, space0);
SamplerState LightMapTextureSampler : register(s1, space0);

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

static bool discard_state;

void discard_exit()
{
    if (discard_state)
    {
        discard;
    }
}

void frag_main()
{
    discard_state = false;
    float4 _58 = s_MatTexture.Sample(MatTextureSampler, TEXCOORD);
    float _63 = _58.w;
    if (_63 < 0.5f)
    {
        discard_state = true;
    }
    float4 _74 = s_LightMapTexture.Sample(LightMapTextureSampler, TEXCOORD_1);
    float _79 = (_58.x * COLOR.x) * _74.x;
    float _80 = (_58.y * COLOR.y) * _74.y;
    float _81 = (_58.z * COLOR.z) * _74.z;
    SV_Target.x = ((_16_m0[0u].x - _79) * COLOR_2.w) + _79;
    SV_Target.y = ((_16_m0[0u].y - _80) * COLOR_2.w) + _80;
    SV_Target.z = ((_16_m0[0u].z - _81) * COLOR_2.w) + _81;
    SV_Target.w = _63;
    discard_exit();
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

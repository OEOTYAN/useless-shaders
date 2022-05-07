cbuffer _14_16 : register(b1, space0)
{
    float4 _16_m0[1] : packoffset(c0);
};

Texture2D<float4> _8 : register(t0, space0);
Texture2D<float4> _9 : register(t1, space0);
SamplerState _19 : register(s0, space0);
SamplerState _20 : register(s1, space0);

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
    if (_8.Sample(_19, float2(TEXCOORD.x, TEXCOORD.y)).w < 0.5f)
    {
        discard_state = true;
    }
    float4 _61 = _9.Sample(_20, float2(TEXCOORD_1.x, TEXCOORD_1.y));
    float _63 = _61.x;
    float _64 = _61.y;
    float _65 = _61.z;
    SV_Target.x = ((_16_m0[0u].x - _63) * COLOR_2.w) + _63;
    SV_Target.y = ((_16_m0[0u].y - _64) * COLOR_2.w) + _64;
    SV_Target.z = ((_16_m0[0u].z - _65) * COLOR_2.w) + _65;
    SV_Target.w = 1.0f;
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

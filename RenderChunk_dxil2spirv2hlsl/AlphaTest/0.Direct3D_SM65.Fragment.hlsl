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

static float4 v_color0;
static float4 v_fog;
static float2 v_lightmapUV;
static float2 v_texcoord0;
static float4 SV_Target;

struct SPIRV_Cross_Input
{
    float4 v_color0 : TEXCOORD1;
    float4 v_fog : TEXCOORD2;
    float2 v_lightmapUV : TEXCOORD3;
    centroid float2 v_texcoord0 : TEXCOORD4;
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
    float4 _64 = _8.Sample(_20, float2(v_texcoord0.x, v_texcoord0.y));
    if (_64.w < 0.5f)
    {
        discard_state = true;
    }
    float4 _77 = _10.Sample(_22, float2(v_color0.x, v_color0.y));
    float4 _98 = _9.Sample(_21, float2(v_lightmapUV.x, v_lightmapUV.y));
    float _105 = ((_64.x * v_color0.w) * ((((_77.x * 2.0f)-1.0) * v_color0.z) + 1.0f)) * _98.x;
    float _108 = ((_64.y * v_color0.w) * ((((_77.y * 2.0f)-1.0) * v_color0.z) + 1.0f)) * _98.y;
    float _111 = ((_64.z * v_color0.w) * ((((_77.z * 2.0f)-1.0) * v_color0.z) + 1.0f)) * _98.z;
    SV_Target.x = ((_17_m0[0u].x - _105) * v_fog.w) + _105;
    SV_Target.y = ((_17_m0[0u].y - _108) * v_fog.w) + _108;
    SV_Target.z = ((_17_m0[0u].z - _111) * v_fog.w) + _111;
    SV_Target.w = 1.0f;
    discard_exit();
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    v_color0 = stage_input.v_color0;
    v_fog = stage_input.v_fog;
    v_lightmapUV = stage_input.v_lightmapUV;
    v_texcoord0 = stage_input.v_texcoord0;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.SV_Target = SV_Target;
    return stage_output;
}

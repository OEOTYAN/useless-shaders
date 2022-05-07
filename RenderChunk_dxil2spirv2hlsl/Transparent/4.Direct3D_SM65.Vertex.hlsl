cbuffer _10_12 : register(b0, space0)
{
    float4 _12_m0[8] : packoffset(c0);
};


static float4 gl_Position;
static float4 COLOR;
static float3 POSITION;
static float2 TEXCOORD;
static float2 TEXCOORD_1;
static float4 TEXCOORD_8;
static float4 TEXCOORD_7;
static float4 TEXCOORD_6;
static float4 TEXCOORD_5;
static float4 COLOR_1;
static float4 COLOR_2;
static float2 TEXCOORD_1_1;
static float2 TEXCOORD_2;

struct SPIRV_Cross_Input
{
    float4 COLOR : TEXCOORD0;
    float3 POSITION : TEXCOORD1;
    float2 TEXCOORD : TEXCOORD2;
    float2 TEXCOORD_1 : TEXCOORD3;
    float4 TEXCOORD_8 : TEXCOORD4;
    float4 TEXCOORD_7 : TEXCOORD5;
    float4 TEXCOORD_6 : TEXCOORD6;
    float4 TEXCOORD_5 : TEXCOORD7;
};

struct SPIRV_Cross_Output
{
    float4 COLOR_1 : TEXCOORD1;
    float4 COLOR_2 : TEXCOORD2;
    float2 TEXCOORD_1_1 : TEXCOORD3;
    centroid float2 TEXCOORD_2 : TEXCOORD4;
    float4 gl_Position : SV_Position;
};

void vert_main()
{
    float _119 = (TEXCOORD_5.x + 0.5f) + mad(POSITION.z, TEXCOORD_6.x, mad(POSITION.y, TEXCOORD_7.x, POSITION.x * TEXCOORD_8.x));
    float _121 = (TEXCOORD_5.y + 0.5f) + mad(POSITION.z, TEXCOORD_6.y, mad(POSITION.y, TEXCOORD_7.y, POSITION.x * TEXCOORD_8.y));
    float _123 = (TEXCOORD_5.z + 0.5f) + mad(POSITION.z, TEXCOORD_6.z, mad(POSITION.y, TEXCOORD_7.z, POSITION.x * TEXCOORD_8.z));
    float _130 = _119 - _12_m0[6u].x;
    float _131 = _121 - _12_m0[6u].y;
    float _132 = _123 - _12_m0[6u].z;
    float _136 = rsqrt(dot(float3(_130, _131, _132), float3(_130, _131, _132)));
    float _137 = _130 * _136;
    float _139 = _132 * _136;
    float _140 = (-0.0f) - _137;
    float _146 = rsqrt(dot(float3(_139, 0.0f, _140), float3(_139, 0.0f, _140)));
    float _147 = _146 * _139;
    float _148 = _146 * _140;
    float _152 = COLOR.z + (-0.5f);
    float _154 = (_131 * _136) * _152;
    float _158 = COLOR.x + (-0.5f);
    float _163 = (_119 - (_147 * _158)) - (_154 * _148);
    float _164 = _121 - (((_147 * _139) - (_148 * _137)) * _152);
    float _165 = _123 - ((_148 * _158) - (_154 * _147));
    float _182 = _12_m0[6u].x - _163;
    float _183 = _12_m0[6u].y - _164;
    float _184 = _12_m0[6u].z - _165;
    float _190 = sqrt(((_182 * _182) + (_183 * _183)) + (_184 * _184));
    float _205 = ((_12_m0[4u].x - _12_m0[5u].x) + (_190 / _12_m0[5u].z)) / (_12_m0[5u].y - _12_m0[5u].x);
    float _245 = isnan(0.0f) ? _205 : (isnan(_205) ? 0.0f : max(_205, 0.0f));
    float _223;
    if (COLOR.w < 0.949999988079071044921875f)
    {
        float _218 = _190 / _12_m0[5u].w;
        float _256 = isnan(0.0f) ? _218 : (isnan(_218) ? 0.0f : max(_218, 0.0f));
        _223 = ((isnan(1.0f) ? _256 : (isnan(_256) ? 1.0f : min(_256, 1.0f))) * (1.0f - COLOR.w)) + COLOR.w;
    }
    else
    {
        _223 = 1.0f;
    }
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_1.x = 1.0f;
    COLOR_1.y = 1.0f;
    COLOR_1.z = 1.0f;
    COLOR_1.w = _223;
    COLOR_2.x = _12_m0[7u].x;
    COLOR_2.y = _12_m0[7u].y;
    COLOR_2.z = _12_m0[7u].z;
    COLOR_2.w = isnan(1.0f) ? _245 : (isnan(_245) ? 1.0f : min(_245, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _165, mad(_12_m0[1u].x, _164, _163 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _165, mad(_12_m0[1u].y, _164, _163 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _165, mad(_12_m0[1u].z, _164, _163 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _165, mad(_12_m0[1u].w, _164, _163 * _12_m0[0u].w)) + _12_m0[3u].w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    COLOR = stage_input.COLOR;
    POSITION = stage_input.POSITION;
    TEXCOORD = stage_input.TEXCOORD;
    TEXCOORD_1 = stage_input.TEXCOORD_1;
    TEXCOORD_8 = stage_input.TEXCOORD_8;
    TEXCOORD_7 = stage_input.TEXCOORD_7;
    TEXCOORD_6 = stage_input.TEXCOORD_6;
    TEXCOORD_5 = stage_input.TEXCOORD_5;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.COLOR_1 = COLOR_1;
    stage_output.COLOR_2 = COLOR_2;
    stage_output.TEXCOORD_1_1 = TEXCOORD_1_1;
    stage_output.TEXCOORD_2 = TEXCOORD_2;
    return stage_output;
}

cbuffer _10_12 : register(b0, space0)
{
    float4 _12_m0[24] : packoffset(c0);
};


static float4 gl_Position;
static float4 COLOR;
static float3 POSITION;
static float2 TEXCOORD;
static float2 TEXCOORD_1;
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
    float _113 = (_12_m0[7u].x + 0.5f) + mad(_12_m0[6u].x, POSITION.z, mad(_12_m0[5u].x, POSITION.y, _12_m0[4u].x * POSITION.x));
    float _115 = (_12_m0[7u].y + 0.5f) + mad(_12_m0[6u].y, POSITION.z, mad(_12_m0[5u].y, POSITION.y, _12_m0[4u].y * POSITION.x));
    float _117 = (_12_m0[7u].z + 0.5f) + mad(_12_m0[6u].z, POSITION.z, mad(_12_m0[5u].z, POSITION.y, _12_m0[4u].z * POSITION.x));
    float _124 = _113 - _12_m0[22u].x;
    float _125 = _115 - _12_m0[22u].y;
    float _126 = _117 - _12_m0[22u].z;
    float _130 = rsqrt(dot(float3(_124, _125, _126), float3(_124, _125, _126)));
    float _131 = _124 * _130;
    float _133 = _126 * _130;
    float _134 = (-0.0f) - _131;
    float _140 = rsqrt(dot(float3(_133, 0.0f, _134), float3(_133, 0.0f, _134)));
    float _141 = _140 * _133;
    float _142 = _140 * _134;
    float _146 = COLOR.z + (-0.5f);
    float _148 = (_125 * _130) * _146;
    float _152 = COLOR.x + (-0.5f);
    float _157 = (_113 - (_141 * _152)) - (_148 * _142);
    float _158 = _115 - (((_141 * _133) - (_142 * _131)) * _146);
    float _159 = _117 - ((_142 * _152) - (_148 * _141));
    float _176 = _12_m0[22u].x - _157;
    float _177 = _12_m0[22u].y - _158;
    float _178 = _12_m0[22u].z - _159;
    float _199 = ((_12_m0[20u].x - _12_m0[21u].x) + (sqrt(((_176 * _176) + (_177 * _177)) + (_178 * _178)) / _12_m0[21u].z)) / (_12_m0[21u].y - _12_m0[21u].x);
    float _227 = isnan(0.0f) ? _199 : (isnan(_199) ? 0.0f : max(_199, 0.0f));
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    COLOR_1.x = 1.0f;
    COLOR_1.y = 1.0f;
    COLOR_1.z = 1.0f;
    COLOR_1.w = 1.0f;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_2.x = _12_m0[23u].x;
    COLOR_2.y = _12_m0[23u].y;
    COLOR_2.z = _12_m0[23u].z;
    COLOR_2.w = isnan(1.0f) ? _227 : (isnan(_227) ? 1.0f : min(_227, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _159, mad(_12_m0[1u].x, _158, _157 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _159, mad(_12_m0[1u].y, _158, _157 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _159, mad(_12_m0[1u].z, _158, _157 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _159, mad(_12_m0[1u].w, _158, _157 * _12_m0[0u].w)) + _12_m0[3u].w;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    COLOR = stage_input.COLOR;
    POSITION = stage_input.POSITION;
    TEXCOORD = stage_input.TEXCOORD;
    TEXCOORD_1 = stage_input.TEXCOORD_1;
    vert_main();
    SPIRV_Cross_Output stage_output;
    stage_output.gl_Position = gl_Position;
    stage_output.COLOR_1 = COLOR_1;
    stage_output.COLOR_2 = COLOR_2;
    stage_output.TEXCOORD_1_1 = TEXCOORD_1_1;
    stage_output.TEXCOORD_2 = TEXCOORD_2;
    return stage_output;
}

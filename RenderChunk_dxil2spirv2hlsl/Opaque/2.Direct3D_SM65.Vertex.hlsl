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
    float _113 = mad(POSITION.z, TEXCOORD_6.x, mad(POSITION.y, TEXCOORD_7.x, POSITION.x * TEXCOORD_8.x)) + TEXCOORD_5.x;
    float _117 = mad(POSITION.z, TEXCOORD_6.y, mad(POSITION.y, TEXCOORD_7.y, POSITION.x * TEXCOORD_8.y)) + TEXCOORD_5.y;
    float _121 = mad(POSITION.z, TEXCOORD_6.z, mad(POSITION.y, TEXCOORD_7.z, POSITION.x * TEXCOORD_8.z)) + TEXCOORD_5.z;
    float _144 = _12_m0[6u].x - _113;
    float _145 = _12_m0[6u].y - _117;
    float _146 = _12_m0[6u].z - _121;
    float _167 = ((_12_m0[4u].x - _12_m0[5u].x) + (sqrt(((_144 * _144) + (_145 * _145)) + (_146 * _146)) / _12_m0[5u].z)) / (_12_m0[5u].y - _12_m0[5u].x);
    float _196 = isnan(0.0f) ? _167 : (isnan(_167) ? 0.0f : max(_167, 0.0f));
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    COLOR_1.x = COLOR.x;
    COLOR_1.y = COLOR.y;
    COLOR_1.z = COLOR.z;
    COLOR_1.w = COLOR.w;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_2.x = _12_m0[7u].x;
    COLOR_2.y = _12_m0[7u].y;
    COLOR_2.z = _12_m0[7u].z;
    COLOR_2.w = isnan(1.0f) ? _196 : (isnan(_196) ? 1.0f : min(_196, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _121, mad(_12_m0[1u].x, _117, _113 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _121, mad(_12_m0[1u].y, _117, _113 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _121, mad(_12_m0[1u].z, _117, _113 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _121, mad(_12_m0[1u].w, _117, _113 * _12_m0[0u].w)) + _12_m0[3u].w;
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

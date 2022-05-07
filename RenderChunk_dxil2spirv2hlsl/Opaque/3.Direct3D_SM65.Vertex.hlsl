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
    float _109 = mad(_12_m0[6u].x, POSITION.z, mad(_12_m0[5u].x, POSITION.y, _12_m0[4u].x * POSITION.x)) + _12_m0[7u].x;
    float _113 = mad(_12_m0[6u].y, POSITION.z, mad(_12_m0[5u].y, POSITION.y, _12_m0[4u].y * POSITION.x)) + _12_m0[7u].y;
    float _117 = mad(_12_m0[6u].z, POSITION.z, mad(_12_m0[5u].z, POSITION.y, _12_m0[4u].z * POSITION.x)) + _12_m0[7u].z;
    float _140 = _12_m0[22u].x - _109;
    float _141 = _12_m0[22u].y - _113;
    float _142 = _12_m0[22u].z - _117;
    float _163 = ((_12_m0[20u].x - _12_m0[21u].x) + (sqrt(((_140 * _140) + (_141 * _141)) + (_142 * _142)) / _12_m0[21u].z)) / (_12_m0[21u].y - _12_m0[21u].x);
    float _192 = isnan(0.0f) ? _163 : (isnan(_163) ? 0.0f : max(_163, 0.0f));
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    COLOR_1.x = COLOR.x;
    COLOR_1.y = COLOR.y;
    COLOR_1.z = COLOR.z;
    COLOR_1.w = COLOR.w;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_2.x = _12_m0[23u].x;
    COLOR_2.y = _12_m0[23u].y;
    COLOR_2.z = _12_m0[23u].z;
    COLOR_2.w = isnan(1.0f) ? _192 : (isnan(_192) ? 1.0f : min(_192, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _117, mad(_12_m0[1u].x, _113, _109 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _117, mad(_12_m0[1u].y, _113, _109 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _117, mad(_12_m0[1u].z, _113, _109 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _117, mad(_12_m0[1u].w, _113, _109 * _12_m0[0u].w)) + _12_m0[3u].w;
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

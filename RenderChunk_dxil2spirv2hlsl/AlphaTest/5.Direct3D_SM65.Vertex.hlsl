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
    float _117 = (TEXCOORD_5.x + 0.5f) + mad(POSITION.z, TEXCOORD_6.x, mad(POSITION.y, TEXCOORD_7.x, POSITION.x * TEXCOORD_8.x));
    float _119 = (TEXCOORD_5.y + 0.5f) + mad(POSITION.z, TEXCOORD_6.y, mad(POSITION.y, TEXCOORD_7.y, POSITION.x * TEXCOORD_8.y));
    float _121 = (TEXCOORD_5.z + 0.5f) + mad(POSITION.z, TEXCOORD_6.z, mad(POSITION.y, TEXCOORD_7.z, POSITION.x * TEXCOORD_8.z));
    float _128 = _117 - _12_m0[6u].x;
    float _129 = _119 - _12_m0[6u].y;
    float _130 = _121 - _12_m0[6u].z;
    float _134 = rsqrt(dot(float3(_128, _129, _130), float3(_128, _129, _130)));
    float _135 = _128 * _134;
    float _137 = _130 * _134;
    float _138 = (-0.0f) - _135;
    float _144 = rsqrt(dot(float3(_137, 0.0f, _138), float3(_137, 0.0f, _138)));
    float _145 = _144 * _137;
    float _146 = _144 * _138;
    float _150 = COLOR.z + (-0.5f);
    float _152 = (_129 * _134) * _150;
    float _156 = COLOR.x + (-0.5f);
    float _161 = (_117 - (_145 * _156)) - (_152 * _146);
    float _162 = _119 - (((_145 * _137) - (_146 * _135)) * _150);
    float _163 = _121 - ((_146 * _156) - (_152 * _145));
    float _180 = _12_m0[6u].x - _161;
    float _181 = _12_m0[6u].y - _162;
    float _182 = _12_m0[6u].z - _163;
    float _203 = ((_12_m0[4u].x - _12_m0[5u].x) + (sqrt(((_180 * _180) + (_181 * _181)) + (_182 * _182)) / _12_m0[5u].z)) / (_12_m0[5u].y - _12_m0[5u].x);
    float _231 = isnan(0.0f) ? _203 : (isnan(_203) ? 0.0f : max(_203, 0.0f));
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_1.x = 1.0f;
    COLOR_1.y = 1.0f;
    COLOR_1.z = 1.0f;
    COLOR_1.w = 1.0f;
    COLOR_2.x = _12_m0[7u].x;
    COLOR_2.y = _12_m0[7u].y;
    COLOR_2.z = _12_m0[7u].z;
    COLOR_2.w = isnan(1.0f) ? _231 : (isnan(_231) ? 1.0f : min(_231, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _163, mad(_12_m0[1u].x, _162, _161 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _163, mad(_12_m0[1u].y, _162, _161 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _163, mad(_12_m0[1u].z, _162, _161 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _163, mad(_12_m0[1u].w, _162, _161 * _12_m0[0u].w)) + _12_m0[3u].w;
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

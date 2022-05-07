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
    float _115 = (_12_m0[7u].x + 0.5f) + mad(_12_m0[6u].x, POSITION.z, mad(_12_m0[5u].x, POSITION.y, _12_m0[4u].x * POSITION.x));
    float _117 = (_12_m0[7u].y + 0.5f) + mad(_12_m0[6u].y, POSITION.z, mad(_12_m0[5u].y, POSITION.y, _12_m0[4u].y * POSITION.x));
    float _119 = (_12_m0[7u].z + 0.5f) + mad(_12_m0[6u].z, POSITION.z, mad(_12_m0[5u].z, POSITION.y, _12_m0[4u].z * POSITION.x));
    float _126 = _115 - _12_m0[22u].x;
    float _127 = _117 - _12_m0[22u].y;
    float _128 = _119 - _12_m0[22u].z;
    float _132 = rsqrt(dot(float3(_126, _127, _128), float3(_126, _127, _128)));
    float _133 = _126 * _132;
    float _135 = _128 * _132;
    float _136 = (-0.0f) - _133;
    float _142 = rsqrt(dot(float3(_135, 0.0f, _136), float3(_135, 0.0f, _136)));
    float _143 = _142 * _135;
    float _144 = _142 * _136;
    float _148 = COLOR.z + (-0.5f);
    float _150 = (_127 * _132) * _148;
    float _154 = COLOR.x + (-0.5f);
    float _159 = (_115 - (_143 * _154)) - (_150 * _144);
    float _160 = _117 - (((_143 * _135) - (_144 * _133)) * _148);
    float _161 = _119 - ((_144 * _154) - (_150 * _143));
    float _178 = _12_m0[22u].x - _159;
    float _179 = _12_m0[22u].y - _160;
    float _180 = _12_m0[22u].z - _161;
    float _186 = sqrt(((_178 * _178) + (_179 * _179)) + (_180 * _180));
    float _201 = ((_12_m0[20u].x - _12_m0[21u].x) + (_186 / _12_m0[21u].z)) / (_12_m0[21u].y - _12_m0[21u].x);
    float _241 = isnan(0.0f) ? _201 : (isnan(_201) ? 0.0f : max(_201, 0.0f));
    float _219;
    if (COLOR.w < 0.949999988079071044921875f)
    {
        float _214 = _186 / _12_m0[21u].w;
        float _252 = isnan(0.0f) ? _214 : (isnan(_214) ? 0.0f : max(_214, 0.0f));
        _219 = ((isnan(1.0f) ? _252 : (isnan(_252) ? 1.0f : min(_252, 1.0f))) * (1.0f - COLOR.w)) + COLOR.w;
    }
    else
    {
        _219 = 1.0f;
    }
    TEXCOORD_2.x = TEXCOORD.x;
    TEXCOORD_2.y = TEXCOORD.y;
    TEXCOORD_1_1.x = TEXCOORD_1.x;
    TEXCOORD_1_1.y = TEXCOORD_1.y;
    COLOR_1.x = 1.0f;
    COLOR_1.y = 1.0f;
    COLOR_1.z = 1.0f;
    COLOR_1.w = _219;
    COLOR_2.x = _12_m0[23u].x;
    COLOR_2.y = _12_m0[23u].y;
    COLOR_2.z = _12_m0[23u].z;
    COLOR_2.w = isnan(1.0f) ? _241 : (isnan(_241) ? 1.0f : min(_241, 1.0f));
    gl_Position.x = mad(_12_m0[2u].x, _161, mad(_12_m0[1u].x, _160, _159 * _12_m0[0u].x)) + _12_m0[3u].x;
    gl_Position.y = mad(_12_m0[2u].y, _161, mad(_12_m0[1u].y, _160, _159 * _12_m0[0u].y)) + _12_m0[3u].y;
    gl_Position.z = mad(_12_m0[2u].z, _161, mad(_12_m0[1u].z, _160, _159 * _12_m0[0u].z)) + _12_m0[3u].z;
    gl_Position.w = mad(_12_m0[2u].w, _161, mad(_12_m0[1u].w, _160, _159 * _12_m0[0u].w)) + _12_m0[3u].w;
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

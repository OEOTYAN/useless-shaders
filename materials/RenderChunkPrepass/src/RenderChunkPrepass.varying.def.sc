vec4 a_color0                   : COLOR0;
vec4 a_normal                   : NORMAL;
vec4 a_tangent                  : TANGENT;
vec3 a_position                 : POSITION;
vec2 a_texcoord0                : TEXCOORD0;
vec2 a_texcoord1                : TEXCOORD1;
int  a_texcoord4                : TEXCOORD4;

vec4 i_data0                    : TEXCOORD8;
vec4 i_data1                    : TEXCOORD7;
vec4 i_data2                    : TEXCOORD6;
vec4 i_data3                    : TEXCOORD5;

vec4 v_color0                   : COLOR0;
vec4 v_fog                      : COLOR2;
vec3 v_normal                   : NORMAL;
vec3 v_tangent                  : TANGENT;
vec3 v_bitangent                : BITANGENT;
vec2 v_texcoord0                : TEXCOORD0;
vec2 v_lightmapUV               : TEXCOORD1;
vec3 v_worldPos                 : TEXCOORD3;
int  v_pbrTextureId             : TEXCOORD4;
vec3 v_blockAmbientContribution : TEXCOORD5;
vec3 v_skyAmbientContribution   : TEXCOORD6;

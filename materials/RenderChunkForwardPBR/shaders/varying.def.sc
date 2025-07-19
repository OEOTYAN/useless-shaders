vec4 a_color0    : COLOR0;
vec4 a_normal    : NORMAL;
vec4 a_tangent   : TANGENT;
vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;
vec2 a_texcoord1 : TEXCOORD1;
#if BGFX_SHADER_LANGUAGE_HLSL
int  a_texcoord4 : TEXCOORD4;
#else
float a_texcoord4 : TEXCOORD4;
#endif

vec4 i_data0 : TEXCOORD7;
vec4 i_data1 : TEXCOORD6;
vec4 i_data2 : TEXCOORD5;

vec4 v_color0                   : COLOR0;
vec4 v_fog                      : COLOR2;
vec3 v_normal                   : NORMAL;
vec3 v_tangent                  : TANGENT;
vec3 v_bitangent                : BITANGENT;
centroid vec2 v_texcoord0       : TEXCOORD0;
vec2 v_lightmapUV               : TEXCOORD1;
vec3 v_worldPos                 : TEXCOORD3;
flat int v_pbrTextureId         : TEXCOORD4;
float v_blockAmbientContribution : TEXCOORD5;
float v_skyAmbientContribution   : TEXCOORD6;
vec3 a_position  : POSITION;
vec2 a_texcoord0 : TEXCOORD0;

#if BGFX_SHADER_LANGUAGE_HLSL
int a_indices : BLENDINDICES;
#else
float a_indices : BLENDINDICES;
#endif

vec2 v_texcoord0 : TEXCOORD0;

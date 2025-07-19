$input a_color0, a_position
#ifdef GEOMETRY_PREPASS_PASS
$input a_texcoord0
    #ifdef INSTANCING__ON
$input i_data0, i_data1, i_data2
    #endif
#endif

$output v_color0
#ifdef GEOMETRY_PREPASS_PASS
$output v_texcoord0, v_normal, v_worldPos, v_prevWorldPos
#endif

#include <bgfx_shader.sh>

uniform vec4 SkyColor;
uniform vec4 FogColor;

void main() {
#if defined(OPAQUE_PASS)
    //Opaque
v_color0 = mix(SkyColor, FogColor, a_color0.x);
gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));

#elif defined(GEOMETRY_PREPASS_PASS) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)
    //GeometryPrepass
mat4 model;
    #ifdef INSTANCING__ON
model = mtxFromCols(i_data0, i_data1, i_data2, vec4(0, 0, 0, 1));
    #else
model = u_model[0];
    #endif

v_normal = vec3(0.0, 0.0, 0.0);
v_texcoord0 = a_texcoord0;
v_worldPos = mul(model, vec4(a_position, 1.0)).xyz;
v_prevWorldPos = mul(u_model[0], vec4(a_position, 1.0)).xyz;
v_color0 = mix(SkyColor, FogColor, a_color0.x);
gl_Position = mul(u_modelViewProj, vec4(a_position, 1.0));

#else
    //Fallback
v_color0 = vec4(0.0, 0.0, 0.0, 0.0);
gl_Position = vec4(0.0, 0.0, 0.0, 0.0);

#endif
}
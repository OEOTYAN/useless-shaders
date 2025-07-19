$input v_color0
#if defined(GEOMETRY_PREPASS_PASS)
$input v_texcoord0, v_normal, v_worldPos, v_prevWorldPos
#endif

#include <bgfx_shader.sh>

vec2 octWrap(vec2 v) {
return (1.0 - abs(v.yx)) * ((2.0 * step(0.0, v)) - 1.0);
}

vec2 ndirToOctSnorm(vec3 n) {
vec2 p = n.xy * (1.0 / (abs(n.x) + abs(n.y) + abs(n.z)));
p = (n.z < 0.0) ? octWrap(p) : p;
return p;
}

void main() {
#if defined(OPAQUE_PASS)
    //Opaque
gl_FragColor = v_color0;

#elif defined(GEOMETRY_PREPASS_PASS) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)
    //GeometryPrepass
vec3 viewSpaceNormal = vec3(0, 1, 0);
vec3 viewNormal = normalize(viewSpaceNormal).xyz;

vec4 screenSpacePos = mul(u_viewProj, vec4(v_worldPos, 1.0));
screenSpacePos /= screenSpacePos.w;
screenSpacePos = screenSpacePos * 0.5 + 0.5;

vec4 prevScreenSpacePos = mul(u_prevViewProj, vec4(v_worldPos.xyz - u_prevWorldPosOffset.xyz, 1.0));
prevScreenSpacePos /= prevScreenSpacePos.w;
prevScreenSpacePos = prevScreenSpacePos * 0.5 + 0.5;

gl_FragData[0].rgb = v_color0.rgb;
gl_FragData[0].a = 0.0;

gl_FragData[1].xy = ndirToOctSnorm(viewNormal);
gl_FragData[1].zw = screenSpacePos.xy - prevScreenSpacePos.xy;

gl_FragData[2] = vec4(1.0, 0.0, 0.0, 0.5);

#else
    //Fallback
gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);

#endif
}
$input v_color0, v_texcoord0, v_lightmapUV, v_position, v_worldpos

#include <bgfx_shader.sh>
#include <defines.sh>
#include <overlay.sh>

SAMPLER2D_AUTOREG(s_MatTexture);
SAMPLER2D_AUTOREG(s_SeasonsTexture);
SAMPLER2D_AUTOREG(s_LightMapTexture);

void main() {
vec4 diffuse;
bool needDiscard = false;

#if defined(DEPTH_ONLY_OPAQUE_PASS) || defined(DEPTH_ONLY_PASS)
diffuse.rgb = vec3(1.0, 1.0, 1.0);
#else
diffuse = texture2D(s_MatTexture, v_texcoord0);
#if defined(ALPHA_TEST_PASS)
if(diffuse.a < 0.5) {
needDiscard = true;
}
#endif

#if defined(SEASONS__ON) && (defined(OPAQUE_PASS) || defined(ALPHA_TEST_PASS))
diffuse.rgb *= mix(vec3(1.0, 1.0, 1.0), texture2D(s_SeasonsTexture, v_color0.xy).rgb * 2.0, v_color0.b);
diffuse.rgb *= v_color0.aaa;
#else
diffuse *= v_color0;
#endif
#endif

#ifndef TRANSPARENT_PASS
diffuse.a = 1.0;
#endif

    // https://github.com/OEOTYAN/useless-shaders/blob/master/shaders/glsl/renderchunk.fragment
int isLightOverlay = 0;

vec3 normal = normalize(cross(dFdx(v_position), dFdy(v_position)));

if(normal.y > 0.99) {
vec3 cp = fract(v_position);

cp.x = cp.x * 3.0 - 1.1;
cp.z = cp.z * 3.0 - 1.1;

bool isRedstoneDust = false;

#if defined(ALPHA_TEST_PASS) && (!defined(TRANSPARENT_PASS)) && (!defined(SEASONS__ON)) && (!defined(INSTANCING__ON))
red_stone_level(needDiscard, isRedstoneDust, diffuse, cp, v_color0.rgb);
#endif

#ifdef LIGHT_OVERLAY

 if (!(isRedstoneDust) && length(v_worldpos) < 64.0){
    light_overlay(needDiscard, isLightOverlay, cp, v_lightmapUV);
 }

#endif
}

#if defined(ALPHA_TEST_PASS) && !(defined(DEPTH_ONLY_OPAQUE_PASS) || defined(DEPTH_ONLY_PASS))
if(needDiscard) {
discard;
}
#endif

#if !defined(NIGHT_VISION)
diffuse.rgb *= texture2D(s_LightMapTexture, v_lightmapUV).rgb;
#endif

#ifdef LIGHT_OVERLAY
if(isLightOverlay == 1) {
diffuse = mix(diffuse, vec4(0.0, 1.0, 0.0, 1.5), 0.15);
} else if(isLightOverlay == 2) {
diffuse = mix(diffuse, vec4(1.0, 0.0, 0.0, 1.0), 0.3);
}
#endif

#ifdef CHUNK_BORDERS

chunk_border(diffuse, v_position);

#endif

    // diffuse.rgb = mix(diffuse.rgb,v_fog.rgb,v_fog.a);
gl_FragColor = diffuse;
}
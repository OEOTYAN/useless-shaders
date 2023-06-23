$input a_color0, a_position, a_texcoord0, a_texcoord1, a_normal, a_tangent
#if defined(GEOMETRY_PREPASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST)
    $input a_texcoord4
#endif
#ifdef INSTANCING
    $input i_data0, i_data1, i_data2, i_data3
#endif

$output v_color0, v_fog, v_normal, v_tangent, v_bitangent, v_texcoord0, v_lightmapUV, v_worldPos, v_blockAmbientContribution, v_skyAmbientContribution
#if defined(GEOMETRY_PREPASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST)
    $output v_pbrTextureId
#endif

#include <bgfx_shader.sh>

uniform vec4 RenderChunkFogAlpha;
uniform vec4 FogAndDistanceControl;
uniform vec4 ViewPositionAndTime;
uniform vec4 FogColor;
uniform vec4 SubPixelOffset;

void main() {
    mat4 model;
#ifdef INSTANCING
    model = mtxFromCols(i_data0, i_data1, i_data2, i_data3);
#else
    model = u_model[0];
#endif

    mat4 offsetProj = u_proj;
    offsetProj[0].z += SubPixelOffset.x;
    offsetProj[1].z -= SubPixelOffset.y;

    vec3 worldPos = mul(model, vec4(a_position, 1.0)).xyz;
    vec3 modelCamPos = (ViewPositionAndTime.xyz - worldPos);
    float camDis = length(modelCamPos);
    vec4 color;
#if defined(GEOMETRY_PREPASS) || defined(GEOMETRY_PREPASS_ALPHA_TEST)
    color = a_color0;
    v_normal = a_normal;
    v_tangent = a_tangent;
    v_bitangent = cross(a_normal.xyz, a_tangent.xyz);
    v_worldPos = worldPos;
    v_pbrTextureId = a_texcoord4 & 65535;
#else
    #ifdef RENDER_AS_BILLBOARDS
        worldPos += vec3(0.5, 0.5, 0.5);
        vec3 viewDir = normalize(worldPos - ViewPositionAndTime.xyz);
        vec3 boardPlane = normalize(vec3(viewDir.z, 0.0, -viewDir.x));
        worldPos = (worldPos -
            ((((viewDir.yzx * boardPlane.zxy) - (viewDir.zxy * boardPlane.yzx)) *
            (a_color0.z - 0.5)) +
            (boardPlane * (a_color0.x - 0.5))));
        color = vec4(1.0, 1.0, 1.0, 1.0);
    #else
        color = a_color0;
    #endif

    #if defined(TRANSPARENT) || defined(TRANSPARENT_PBR)
        if (a_color0.a < 0.949999988079071044921875) {
            color.w = mix(a_color0.a, 1.0, clamp(camDis / FogAndDistanceControl.w, 0.0, 1.0));
        }
    #endif

    v_normal = vec3(0.0, 0.0, 0.0);
    v_tangent = vec3(0.0, 0.0, 0.0);
    v_bitangent = vec3(0.0, 0.0, 0.0);
    v_worldPos = vec3(0.0, 0.0, 0.0);
#endif

    v_texcoord0 = a_texcoord0;
    v_lightmapUV = a_texcoord1;
    v_color0 = color;
    v_fog.xyz = FogColor.xyz;
    v_fog.w = clamp(((RenderChunkFogAlpha.x - FogAndDistanceControl.x) + (camDis / FogAndDistanceControl.z)) /
                        (FogAndDistanceControl.y - FogAndDistanceControl.x), 0.0, 1.0);
    gl_Position = mul(offsetProj, mul(u_view, vec4(worldPos, 1.0)));
}

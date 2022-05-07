$input a_color0, a_position, a_texcoord0, a_texcoord1
#ifdef INSTANCING
    $input i_data0, i_data1, i_data2, i_data3
#endif
$output v_color0, v_texcoord0, v_lightmapUV, v_position

#include <bgfx_shader.sh>

uniform vec4 RenderChunkFogAlpha;
uniform vec4 FogAndDistanceControl;
uniform vec4 ViewPositionAndTime;
uniform vec4 FogColor;

float Pow2(float x){
    return x * x;
}

void main() {
    mat4 model;
#ifdef INSTANCING
    model = mtxFromCols(i_data0, i_data1, i_data2, i_data3);
#else
    model = u_model[0];
#endif

    vec3 worldPos = mul(model, vec4(a_position, 1.0)).xyz;

            worldPos.y += (12.0 * Pow2(cos(3.141592653589793f *
                                         (0.5 - RenderChunkFogAlpha.x))) +
                         128.0 * (RenderChunkFogAlpha.x +
                                  log(1.0 - RenderChunkFogAlpha.x)));

    vec4 color;
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

    // vec3 modelCamPos = (ViewPositionAndTime.xyz - worldPos);
    // float camDis = length(modelCamPos);
    // vec4 fogColor;
    // fogColor.rgb = FogColor.rgb;
    // fogColor.a = clamp(((((camDis / FogAndDistanceControl.z) + RenderChunkFogAlpha.x) -
        // FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);

// #ifdef TRANSPARENT
    // if(a_color0.a < 0.95) {
        // color.a = mix(a_color0.a, 1.0, clamp((camDis / FogAndDistanceControl.w), 0.0, 1.0));
    // };
// #endif

    v_texcoord0 = a_texcoord0;
    v_lightmapUV = a_texcoord1;
    v_color0 = color;
    //v_fog = fogColor;
    v_position = a_position;
    gl_Position = mul(u_viewProj, vec4(worldPos, 1.0));
}

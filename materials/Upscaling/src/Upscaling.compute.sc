#include <bgfx_compute.sh>

uniform vec4 DisplayResolution;
uniform vec4 RenderResolution;
uniform vec4 RecipDisplayResolution;
uniform vec4 RenderResolutionDivDisplayResolution;
uniform vec4 DisplayResolutionDivRenderResolution;
uniform vec4 SubPixelJitter;

SAMPLER2D(s_InputTAAHistory, 1);

IMAGE2D_RO(s_InputFinalColor,           rgba16f, 0); //Actually R11G11B10_FLOAT
IMAGE2D_RO(s_InputBufferMotionVectors,  rgba16f, 2);
IMAGE2D_WR(s_OutputBuffer,              rgba16f, 3);

NUM_THREADS(16, 16, 1)
void main() {
    uvec3 GlobalInvocationID = gl_GlobalInvocationID;

    vec2 _911 = ((vec2(GlobalInvocationID.x + 0.5, GlobalInvocationID.y + 0.5) * RenderResolutionDivDisplayResolution.x) - SubPixelJitter.xy) - 0.5;
    ivec2 _920 = ivec2(round(_911.x), round(_911.y));
    vec4 _1093 = imageLoad(s_InputFinalColor, _920);
    vec2 _852 = imageLoad(s_InputBufferMotionVectors, _920).zw;
    _852.y *= (-1.0);
    vec3 _1535 = _1093.xyz;
    vec3 _1536 = _1093.xyz * _1093.xyz;
    
    vec3 _1539;
    vec3 _1540;
    for (int x = -1; x <= 1; _1536 = _1540, _1535 = _1539, x++) {
        _1540 = _1536;
        _1539 = _1535;
        vec3 _1543;
        vec3 _1544;
        for (int y = -1; y <= 1; _1540 = _1544, _1539 = _1543, y++) {
            if (x == 0 && y == 0) {
                _1544 = _1540;
                _1543 = _1539;
                continue;
            }
            vec3 _968 = imageLoad(s_InputFinalColor, ivec2(_920.x + x, _920.y + y)).xyz;
            _1544 = _1540 + (_968 * _968);
            _1543 = _1539 + _968;
        }
    }
    vec2 _988 = _852;
    vec2 _989 = _988 * RenderResolution.xy;
    _852 = _989;
    vec3 _992 = _1535 * 0.111111111938953399658203125;
    vec3 _1002 = sqrt(max(0.0, (_1536 * 0.111111111938953399658203125) - (_992 * _992)));
    float _1007 = smoothstep(0.0, 1.0, sqrt(dot(_989, _989)));
    float _1146 = mix(4.0, 1.0, _1007);
    vec2 _1038 = clamp(vec2(GlobalInvocationID.x + 0.5, GlobalInvocationID.y + 0.5) - (_989 * DisplayResolutionDivRenderResolution.x), 0.0, DisplayResolution.xy - 1.0);
    vec2 _1191 = floor(_1038 - 0.5);
    vec2 _1193 = _1191 + 0.5;
    vec2 _1197 = clamp(_1038 - _1193, 0.0, 1.0);
    vec2 _1200 = _1197 * _1197;
    vec2 _1203 = _1200 * _1197;
    vec2 _1209 = _1200 - ((_1203 + _1197) * 0.5);
    vec2 _1151 = _1209;
    vec2 _1216 = ((_1203 * 1.5) - (_1200 * 2.5)) + 1.0;
    vec2 _1220 = (_1203 - _1200) * 0.5;
    vec2 _1153 = _1220;
    vec2 _1227 = ((1.0 - _1209) - _1216) - _1220;
    vec2 _1230 = _1216 + _1227;
    vec2 _1155 = _1230;
    vec2 _1156 = (_1191 + (-0.5)) * RecipDisplayResolution.xy;
    vec2 _1157 = (_1193 + (_1227 / _1230)) * RecipDisplayResolution.xy;
    vec2 _1158 = (_1191 + 2.5) * RecipDisplayResolution.xy;
    vec2 _1054 = _911 - _920;
    imageStore(s_OutputBuffer,
        ivec2(GlobalInvocationID.x, GlobalInvocationID.y),
        vec4(
            mix(
                min(
                    _992 + (_1002 * _1146), 
                    max(
                        _992 - (_1002 * _1146), 
                        max(
                            0.0, 
                            (
                                (
                                    (
                                        (
                                            (
                                                (
                                                    (
                                                        (
                                                            texture2DLod(s_InputTAAHistory, vec2(_1156.x, _1156.y), 0).xyz * (_1151.x * _1151.y)
                                                        ) 
                                                        + 
                                                        (
                                                            texture2DLod(s_InputTAAHistory, vec2(_1156.x, _1157.y), 0).xyz * (_1151.x * _1155.y)
                                                        )
                                                    ) 
                                                    + 
                                                    (
                                                        texture2DLod(s_InputTAAHistory, vec2(_1156.x, _1158.y), 0).xyz * (_1151.x * _1153.y)
                                                    )
                                                ) 
                                                + 
                                                (
                                                    texture2DLod(s_InputTAAHistory, vec2(_1157.x, _1156.y), 0).xyz * (_1155.x * _1151.y)
                                                )
                                            ) 
                                            + 
                                            texture2DLod(s_InputTAAHistory, vec2(_1157.x, _1157.y), 0).xyz * (_1155.x * _1155.y)
                                        )
                                    ) 
                                    + 
                                    (
                                        texture2DLod(s_InputTAAHistory, vec2(_1157.x, _1158.y), 0).xyz * (_1155.x * _1153.y)
                                    ) 
                                    + 
                                    (
                                        texture2DLod(s_InputTAAHistory, vec2(_1158.x, _1156.y), 0).xyz * (_1153.x * _1151.y)
                                    )
                                ) 
                                + 
                                (
                                    texture2DLod(s_InputTAAHistory, vec2(_1158.x, _1157.y), 0).xyz * (_1153.x * _1155.y)
                                )
                            ) 
                            + 
                            (
                                texture2DLod(s_InputTAAHistory, vec2(_1158.x, _1158.y), 0).xyz * (_1153.x * _1153.y)
                            )
                        )
                    )
                ), 
                _1093.xyz, 
                max(_1007, clamp(1.0 - (DisplayResolutionDivRenderResolution.x * dot(_1054, _1054)), 0.0500000007450580596923828125, 1.0)) * 0.100000001490116119384765625
            ), 
            0.0
        )
    );
}

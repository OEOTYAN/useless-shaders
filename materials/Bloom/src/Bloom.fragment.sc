$input v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 BloomParams1;
uniform vec4 BloomParams2;

SAMPLER2D(s_HDRi, 0);
SAMPLER2D(s_DepthTexture, 1);
SAMPLER2D(s_BlurPyramidTexture, 2);
SAMPLER2D(s_RasterColor, 3);

vec4 BloomHighPass(vec2 texcoord) {
    vec2 _499 = vec2(1.5 * abs(dFdx(texcoord.x)), 1.5 * abs(dFdy(-texcoord.y)));

    vec4 _660 = texture2D(s_HDRi, texcoord);
    float _684 = dot(_660.xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));

    vec4 _692 = texture2D(s_HDRi, (texcoord + vec2(_499.x, _499.y)));
    float _716 = dot(_692.xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));

    vec4 _724 = texture2D(s_HDRi, (texcoord + vec2(-_499.x, _499.y)));
    float _748 = dot(_724.xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));

    vec4 _756 = texture2D(s_HDRi, (texcoord + vec2(_499.x, -_499.y)));
    float _780 = dot(_756.xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));

    vec4 _788 = texture2D(s_HDRi, (texcoord + vec2(-_499.x, -_499.y)));
    float _812 = dot(_788.xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));

    vec4 _619 = ((((vec4(_660.xyz * step(BloomParams1.y, _684), _684) * 0.5) + (vec4(_692.xyz * step(BloomParams1.y, _716), _716) * 0.125)) + (vec4(_724.xyz * step(BloomParams1.y, _748), _748) * 0.125)) + (vec4(_756.xyz * step(BloomParams1.y, _780), _780) * 0.125)) + (vec4(_788.xyz * step(BloomParams1.y, _812), _812) * 0.125);
    
    vec4 _862;
    if (BloomParams2.z != 0.0) {
        _862 = _619 * pow(clamp(((texture2D(s_DepthTexture, texcoord).x * BloomParams2.y) - BloomParams2.x) / (BloomParams2.y - BloomParams2.x), BloomParams1.w, 1.0), BloomParams1.z);
    } else {
        _862 = _619;
    }
    
    return _862;
}

vec4 DFDownSample(vec2 texcoord) {
    vec2 _386 = vec2(1.5 * abs(dFdx(texcoord.x)), 1.5 * abs(dFdy(-texcoord.y)));
    return (
            (
                (
                    (texture2D(s_BlurPyramidTexture, texcoord) * 0.5) 
                    + 
                    (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_386.x, _386.y))) * 0.125)
                ) 
                + 
                (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_386.x, _386.y))) * 0.125)
            ) 
            + 
            (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_386.x, -_386.y))) * 0.125)
        ) 
        + 
        (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_386.x, -_386.y))) * 0.125);
}

vec4 DFDownSampleWithDepthErosion(vec2 texcoord) {
    vec2 _433 = vec2(1.5 * abs(dFdx(texcoord.x)), 1.5 * abs(dFdy(-texcoord.y)));

    vec4 _577 = texture2D(s_BlurPyramidTexture, texcoord);
    vec4 _455 = _577;

    vec4 _585 = texture2D(s_BlurPyramidTexture, (texcoord + vec2(_433.x, _433.y)));
    vec4 _458 = _585;

    vec4 _593 = texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_433.x, _433.y)));
    vec4 _461 = _593;

    vec4 _601 = texture2D(s_BlurPyramidTexture, (texcoord + vec2(_433.x, -_433.y)));
    vec4 _464 = _601;

    vec4 _609 = texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_433.x, -_433.y)));
    vec4 _467 = _609;

    vec3 _551 = ((((_577.xyz * 0.5).xyz + (_585.xyz * 0.125)).xyz + (_593.xyz * 0.125)).xyz + (_601.xyz * 0.125)).xyz + (_609.xyz * 0.125);
    vec4 _454 = vec4(_551.x, _551.y, _551.z, 0.0);
    _454.w = max(_455.w, max(_458.w, max(_461.w, max(_464.w, _467.w))));
    return _454;
}

vec4 DFUpSample(vec2 texcoord) {
    vec2 _444 = vec2(4.0 * abs(dFdx(texcoord.x)), 4.0 * abs(dFdy(-texcoord.y)));
    return (
            (
                (
                    (
                        (
                            (
                                (texture2D(s_BlurPyramidTexture, (texcoord + vec2(0.5 * _444.x, 0.5 * _444.y))) * 0.16599999368190765380859375) 
                                + 
                                (texture2D(s_BlurPyramidTexture, (texcoord + vec2((-0.5) * _444.x, 0.5 * _444.y))) * 0.16599999368190765380859375)
                            ) 
                            + 
                            (texture2D(s_BlurPyramidTexture, (texcoord + vec2(0.5 * _444.x, (-0.5) * _444.y))) * 0.16599999368190765380859375)
                        ) 
                        + 
                        (texture2D(s_BlurPyramidTexture, (texcoord + vec2((-0.5) * _444.x, (-0.5) * _444.y))) * 0.16599999368190765380859375)
                    ) 
                    + 
                    (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_444.x, _444.y))) * 0.082999996840953826904296875)
                ) 
                + 
                (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_444.x, _444.y))) * 0.082999996840953826904296875)
            ) 
            + 
            (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_444.x, -_444.y))) * 0.082999996840953826904296875)
        ) 
        + 
        (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_444.x, -_444.y))) * 0.082999996840953826904296875);
}

vec4 BloomBlend(vec2 texcoord) {
    vec2 _471 = vec2(4.0 * abs(dFdx(texcoord.x)), 4.0 * abs(dFdy(-texcoord.y)));

    return vec4(
            texture2D(s_HDRi, texcoord).xyz 
            + 
            (
                (
                    (
                        (
                            (
                                (
                                    (
                                        (
                                            (texture2D(s_BlurPyramidTexture, (texcoord + vec2(0.5 * _471.x, 0.5 * _471.y))) * 0.16599999368190765380859375) 
                                            + 
                                            (texture2D(s_BlurPyramidTexture, (texcoord + vec2((-0.5) * _471.x, 0.5 * _471.y))) * 0.16599999368190765380859375)
                                        ) 
                                        + 
                                        (texture2D(s_BlurPyramidTexture, (texcoord + vec2(0.5 * _471.x, (-0.5) * _471.y))) * 0.16599999368190765380859375)
                                    ) 
                                    + 
                                    (texture2D(s_BlurPyramidTexture, (texcoord + vec2((-0.5) * _471.x, (-0.5) * _471.y))) * 0.16599999368190765380859375)
                                ) 
                                + 
                                (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_471.x, _471.y))) * 0.082999996840953826904296875)
                            ) 
                            + 
                            (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_471.x, _471.y))) * 0.082999996840953826904296875)
                        ) 
                        + 
                        (texture2D(s_BlurPyramidTexture, (texcoord + vec2(_471.x, -_471.y))) * 0.082999996840953826904296875)
                    ) 
                    + 
                    (texture2D(s_BlurPyramidTexture, (texcoord + vec2(-_471.x, -_471.y))) * 0.082999996840953826904296875)
                ).xyz 
                * 
                BloomParams1.x
            )
        , 1.0);
}

void main() {
#if BLOOM_HIGH_PASS
    gl_FragColor = BloomHighPass(v_texcoord0);
#elif DFDOWN_SAMPLE
    gl_FragColor = DFDownSample(v_texcoord0);
#elif DFDOWN_SAMPLE_WITH_DEPTH_EROSION
    gl_FragColor = DFDownSampleWithDepthErosion(v_texcoord0);
#elif DFUP_SAMPLE
    gl_FragColor = DFUpSample(v_texcoord0);
#elif BLOOM_BLEND
    gl_FragColor = BloomBlend(v_texcoord0);
#endif
}

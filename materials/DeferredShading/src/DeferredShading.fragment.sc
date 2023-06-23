$input v_projPosition, v_texcoord0

#include <bgfx_shader.sh>
#include <bgfx_compute.sh>

struct LightCluster {
    int start;
    int count;
};

struct Light {
    vec4 position;
    vec4 color;
};

struct LightData {
    float lookup;
};

struct LightSourceWorldInfo {
    vec4 worldSpaceDirection;
    vec4 diffuseColorAndIlluminance;
    vec4 shadowDirection;
    mat4 shadowProj0;
    mat4 shadowProj1;
    mat4 shadowProj2;
    mat4 shadowProj3;
    int isSun;
    int shadowCascadeNumber;
    int pad0;
    int pad1;
};

struct PBRLightingInfo {
    int diffuseLightEnabled;
    int specularLightEnabled;
    int emissiveLightEnabled;
    int ambientLightEnabled;
    int pointLightContributionEnabled;
    int directionalShadowsMode;
    int pointLightShadowsEnabled;
    int cloudShadowsEnabled;
    int directionalLightCount;
    float maxShadowDistance;
    float ambientLightContributionMultiplier;
    float padding0;
    float emissiveMultiplier;
    float emissiveDesaturation;
    float cloudShadowPCFWidth;
    float cloudShadowContribution;
    mat4 cloudShadowProj;
    vec4 cascadeShadowResolutions;
    vec4 shadowBias;
    vec4 shadowSlopeBias;
    vec4 shadowPCFWidth;
    vec4 shadowParams;
    vec4 blockBaseAmbientLightColorIntensity;
    vec4 skyAmbientLightColorIntensity;
    vec4 clusterDimensions;
    vec4 clusterNearFar;
};


uniform vec4 SunDir;
uniform vec4 SunColor;
uniform vec4 MoonDir;
uniform vec4 MoonColor;
uniform vec4 SkyHorizonColor;
uniform vec4 SkyZenithColor;
uniform vec4 AtmosphericScattering;
uniform vec4 AtmosphericScatteringEnabled;
uniform vec4 FogSkyBlend;
uniform vec4 FogColor;
uniform vec4 FogAndDistanceControl;
uniform vec4 RenderChunkFogAlpha;

// ACCELERATION_STRUCTURE(s_SceneBVH, 7);

SAMPLER2DARRAYSHADOW(s_ShadowCascades0, 3);
SAMPLER2DARRAYSHADOW(s_ShadowCascades1, 5);
SAMPLER2DSHADOW(s_CloudShadow, 6);

SAMPLER2D(s_ColorMetalness, 0);
SAMPLER2D(s_SceneDepth, 1);
SAMPLER2D(s_Normal, 2);
SAMPLER2D(s_EmissiveAmbientLinearRoughness, 4);

BUFFER_RO(s_LightClusters, LightCluster, 8);
BUFFER_RO(s_DirectionalLightSources, LightSourceWorldInfo, 9);
BUFFER_RO(s_LightLookupArray, LightData, 10);
BUFFER_RO(s_Lights, Light, 11);
BUFFER_RO(s_LightingInfo, PBRLightingInfo, 12);

void main() {
#if !defined(FALLBACK) && (BGFX_SHADER_LANGUAGE_GLSL >= 310 || BGFX_SHADER_LANGUAGE_HLSL >= 500 || BGFX_SHADER_LANGUAGE_PSSL || BGFX_SHADER_LANGUAGE_SPIRV || BGFX_SHADER_LANGUAGE_METAL)
    vec4 _2896 = vec4(v_projPosition.xy, texture2D(s_SceneDepth, v_texcoord0).r, 1.0);

    float tmp1 = mul(u_invProj, vec4(_2896.x, 0.0, 0.0, 0.0)).x;
    float tmp2 = mul(u_invProj, vec4(0.0, _2896.y, 0.0, 0.0)).y;
    float tmp3 = mul(u_invProj, vec4(0.0, 0.0, 0.0, _2896.w)).z;
    float tmp4 = mul(u_invProj, vec4(0.0, 0.0, _2896.z, 1.0)).w;
    vec4 _3038 = vec4(tmp1, tmp2, tmp3, tmp4) / tmp4;
    vec4 _2939 = mul(u_invView, vec4(_3038.xyz, 1.0));

    vec4 _3047 = texture2D(s_Normal, v_texcoord0);
    vec2 normal = (_3047.xy * 2.0) - 1.0;
    vec2 _3049 = normal;
    vec3 _3071 = vec3(normal, (1.0 - abs(_3049.x)) - abs(_3049.y));
    bool isNegative = _3071.z < 0.0;
    vec2 tmp1_1 = (vec2(1.0, 1.0) - abs(_3071.yx)) * ((step(vec2(0.0, 0.0), _3071.xy) * 2.0) - 1.0);
    vec2 _3081 = vec2(isNegative ? tmp1_1.x : _3071.x, isNegative ? tmp1_1.y : _3071.y);
    vec3 _3083 = vec3(_3081.x, _3081.y, _3071.z);

    vec3 _2956 = normalize(mul(u_view, vec4(normalize(normalize(_3083)), 0.0)).xyz);

    vec4 colorMetalness = texture2D(s_ColorMetalness, v_texcoord0);
    vec4 _2905 = colorMetalness;

    vec4 emissiveAmbientLinearRoughness = texture2D(s_EmissiveAmbientLinearRoughness, v_texcoord0);

    vec3 _2975 = _3038.xyz;
    vec3 _3122 = pow(max(colorMetalness.xyz, 0.0), 2.2000000476837158203125);
    vec3 _5904 = _2975;
    vec4 _5792 = s_LightingInfo[0].blockBaseAmbientLightColorIntensity;
    vec4 _5793 = s_LightingInfo[0].skyAmbientLightColorIntensity;
    vec3 _3464 = _3122 * ((clamp(((s_LightingInfo[0].blockBaseAmbientLightColorIntensity.xyz * emissiveAmbientLinearRoughness.y) * _5792.w) + ((s_LightingInfo[0].skyAmbientLightColorIntensity.xyz * emissiveAmbientLinearRoughness.z) * _5793.w), vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0)) * s_LightingInfo[0].ambientLightContributionMultiplier) * float(s_LightingInfo[0].ambientLightEnabled));
    vec3 _5954;
    
    if (emissiveAmbientLinearRoughness.x < 0.25) {
        vec3 _3251 = normalize(-_2975);
        vec3 _5947 = 0.0;
        vec3 _3671;
        int _6054;
        float _6070;
        int _5963;
        float _5985;
        for (int lightIndex = 0; lightIndex < s_LightingInfo[0].directionalLightCount; _5985 = _6070, _5963 = _6054, _5947 = _3671, lightIndex++) {
            vec3 _3580 = normalize(mul(u_view, s_DirectionalLightSources[lightIndex].worldSpaceDirection).xyz);
            float shadow;
            if (s_LightingInfo[0].directionalShadowsMode == 2) {
                float _3602 = max(dot(_2956, normalize(mul(u_view, s_DirectionalLightSources[lightIndex].shadowDirection).xyz)), 0.0);
                mat4 shadowProj[4] = { 
                    s_DirectionalLightSources[lightIndex].shadowProj0, 
                    s_DirectionalLightSources[lightIndex].shadowProj1, 
                    s_DirectionalLightSources[lightIndex].shadowProj2, 
                    s_DirectionalLightSources[lightIndex].shadowProj3
                };

                vec4 shadowBias = s_LightingInfo[0].shadowBias;
                vec4 shadowSlopeBias = s_LightingInfo[0].shadowSlopeBias;
                vec4 _5756 = s_LightingInfo[0].shadowParams;

                int shadowMapIndex = -1;
                vec4 shadowCoord;
                for (int shadowProjIndex = 0; shadowProjIndex < 4; shadowProjIndex++) {
                    vec4 _3868 = mul(shadowProj[shadowProjIndex], vec4(_2939.xyz, 1.0));
                    shadowCoord = _3868 / _3868.w;
                    if (length(clamp(shadowCoord.xyz, -1.0, 1.0) - shadowCoord.xyz) == 0.0) {
                        shadowMapIndex = shadowProjIndex;
                        break;
                    }
                }
                
                float _5995;
                float _6071;
                if (shadowMapIndex != -1) {
                    shadowCoord.y *= (-1.0);
                    shadowCoord.z -= ((shadowBias[s_DirectionalLightSources[lightIndex].shadowCascadeNumber] + (shadowSlopeBias[s_DirectionalLightSources[lightIndex].shadowCascadeNumber] * clamp(tan(acos(_3602)), 0.0, 1.0))) / shadowCoord.w);
                    vec2 _3795 = shadowCoord.xy * 0.5 + 0.5;
                    vec4 shadowResolutions = s_LightingInfo[0].cascadeShadowResolutions;
                    vec4 shadowPCFWidth = s_LightingInfo[0].shadowPCFWidth;
                    vec4 shadowParams = s_LightingInfo[0].shadowParams;
                    
                    int pcfWidth = clamp(int(shadowPCFWidth[shadowMapIndex] + 0.5), 1, 9);
                    int halfPCFWidth = pcfWidth / 2;
                    float _5968;
                    bool cascadeNumberOutOfBound = false;
                    float sum = 0.0;
                    for (int pcf_y = 0; (pcf_y < pcfWidth) && (pcf_y < 9) && !cascadeNumberOutOfBound; pcf_y++) {
                        for (int pcf_x = 0; (pcf_x < pcfWidth) && (pcf_x < 9) && !cascadeNumberOutOfBound; pcf_x++) {
                            vec2 _3953 = vec2(float(pcf_x - halfPCFWidth) + 0.5, float(pcf_y - halfPCFWidth) + 0.5) * shadowParams.x;
                            switch (s_DirectionalLightSources[lightIndex].shadowCascadeNumber) {
                                case 0: {
                                    vec2 _3965 = (_3795 + _3953) * shadowResolutions[shadowMapIndex];
                                    vec4 _3902 = vec4(_3965.x, _3965.y, shadowMapIndex, shadowCoord.z);
                                    sum += shadow2DArray(s_ShadowCascades0, _3902).x;
                                    break;
                                }
                                case 1: {
                                    vec2 _3983 = (_3795 + _3953) * shadowResolutions[shadowMapIndex];
                                    vec4 _3904 = vec4(_3983.x, _3983.y, shadowMapIndex, shadowCoord.z);
                                    sum += shadow2DArray(s_ShadowCascades1, _3904).x;
                                    break;
                                }
                                default: {
                                    cascadeNumberOutOfBound = true;
                                    break;
                                }
                            }
                        }
                    }
                    float directionalLightsShadow = 1.0;
                    if (!cascadeNumberOutOfBound) {
                        directionalLightsShadow = sum / float(pcfWidth * pcfWidth);
                    }

                    float cloudShadow;
                    if ((s_DirectionalLightSources[lightIndex].isSun > 0) && (s_LightingInfo[0].cloudShadowsEnabled > 0)) {
                        vec4 _5622 = s_LightingInfo[0].cascadeShadowResolutions;
                        vec4 _5623 = s_LightingInfo[0].shadowBias;
                        vec4 _5624 = s_LightingInfo[0].shadowSlopeBias;
                        vec4 _5626 = s_LightingInfo[0].shadowParams;
                        vec4 _4066 = mul(s_LightingInfo[0].cloudShadowProj, vec4(_2939.xyz, 1.0));
                        vec4 _4045 = _4066;
                        _4045 = _4066 / vec4_splat(_4045.w);
                        _4045.y *= (-1.0);
                        _4045.z -= ((_5623.x + (_5624.x * clamp(tan(acos(_3602)), 0.0, 1.0))) / _4045.w);
                        vec2 _4103 = (vec2(_4045.x, _4045.y) * 0.5) + vec2(0.5, 0.5);
                        int _4108 = clamp(int(s_LightingInfo[0].cloudShadowPCFWidth + 0.5), 1, 9);
                        int _4110 = _4108 / 2;
                        float _5991;
                        _5991 = 0.0;
                        float _6036;
                        for (int _5990 = 0; _5990 < _4108; _5991 = _6036, _5990++) {
                            _6036 = _5991;
                            float _4157;
                            for (int _6034 = 0; _6034 < _4108; _6036 = _4157, _6034++) {
                                vec2 _4148 = (_4103 + (vec2(float(_6034 - _4110) + 0.5, float(_5990 - _4110) + 0.5) * _5626.x)) * _5622.x;
                                float _4151 = _4148.x;
                                vec3 _4057 = vec3(_4151, _4148.y, _4045.z);
                                _4157 = _6036 + shadow2D(s_CloudShadow, vec3(_4151, _4148.y, _4057.z));
                            }
                        }
                        float _4167 = _5991 / float(_4108 * _4108);
                        float _5994;
                        if (_4167 < 1.0) {
                            _5994 = min(directionalLightsShadow, max(_4167, 1.0 - s_LightingInfo[0].cloudShadowContribution));
                        }  else {
                            _5994 = directionalLightsShadow;
                        }
                        cloudShadow = _5994;
                    } else {
                        cloudShadow = directionalLightsShadow;
                    }

                    _6071 = directionalLightsShadow;
                    _5995 = mix(cloudShadow, 1.0, smoothstep(max(0.0, _5756.y - 8.0), _5756.y, -_5904.z));
                } else {
                    _6071 = _5985;
                    _5995 = 1.0;
                }
                _6070 = _6071;
                _6054 = shadowMapIndex;
                shadow = _5995;
            } else {
                _6070 = _5985;
                _6054 = _5963;
                shadow = 1.0;
            }
            vec4 _3490 = s_DirectionalLightSources[lightIndex].diffuseColorAndIlluminance;
            vec3 _4280 = normalize(_3580 + _3251);
            float _4283 = emissiveAmbientLinearRoughness.w * emissiveAmbientLinearRoughness.w;
            float _4336 = _4283 * _4283;
            float _4340 = max(dot(_2956, _4280), 0.0);
            float _4348 = max((((_4336 - 1.0) * _4340) * _4340) + 1.0, 0.0001);
            float _4364 = max(dot(_2956, _3251), 0.0);
            float _4368 = max(dot(_2956, _3580), 0.0);
            float _4370 = _4283 * 0.5;
            vec3 _4396 = mix(vec3_splat(0.039999999105930328369140625), _3122, vec3_splat(_2905.w));
            vec3 _4412 = _4396 + ((vec3(1.0, 1.0, 1.0) - _4396) * pow(clamp(1.0 - max(dot(_3251, _4280), 0.0), 0.0, 1.0), 5.0));

            // _3671 = _5947 + ((((((((vec3(1.0, 1.0, 1.0) - _4412) * (1.0 - _2905.w)) * _3122) * vec3_splat(0.3183098733425140380859375)) * float(s_LightingInfo[0].diffuseLightEnabled)) + ((((_4412 * (_4336 / ((_4348 * _4348) * 3.1415927410125732421875))) * ((_4364 / (((_4364 * (1.0 - _4370)) + _4370) + 9.9999997473787516355514526367188e-05)) * (_4368 / (((_4368 * (1.0 - _4370)) + _4370) + 9.9999997473787516355514526367188e-05)))) / vec3_splat(((4.0 * max(dot(_2956, _3580), 0.0)) * max(dot(_2956, _3251), 0.0)) + 9.9999997473787516355514526367188e-05)) * float(s_LightingInfo[0].specularLightEnabled))) * ((s_DirectionalLightSources[lightIndex].diffuseColorAndIlluminance.xyz * _3490.w) * max(dot(_2956, _3580), 0.0))) * shadow);
            _3671 = _5947 + 
            (
                (
                    (
                        (
                            (
                                (
                                    ((vec3(1.0, 1.0, 1.0) - _4412) * (1.0 - _2905.w)) * _3122
                                ) 
                                * 
                                0.3183098733425140380859375
                            ) 
                            * 
                            s_LightingInfo[0].diffuseLightEnabled
                        ) 
                        + 
                        (
                            (
                                (
                                    (_4412 * (_4336 / ((_4348 * _4348) * 3.1415927410125732421875))) 
                                    * 
                                    (
                                        (_4364 / (((_4364 * (1.0 - _4370)) + _4370) + 0.0001)) 
                                        * 
                                        (_4368 / (((_4368 * (1.0 - _4370)) + _4370) + 0.0001))
                                    )
                                ) 
                                / 
                                (
                                    ((4.0 * max(dot(_2956, _3580), 0.0)) * max(dot(_2956, _3251), 0.0)) 
                                    + 
                                    0.0001
                                )
                            ) 
                            * 
                            s_LightingInfo[0].specularLightEnabled
                        )
                    ) 
                    * 
                    (
                        s_DirectionalLightSources[lightIndex].diffuseColorAndIlluminance.xyz * _3490.w * max(dot(_2956, _3580), 0.0)
                    )
                ) * shadow
            );
        }

        vec3 pointLight;
        vec4 _5554 = s_LightingInfo[0].clusterDimensions;
        vec3 _4446 = s_LightingInfo[0].clusterDimensions.xyz;
        vec2 _4661 = s_LightingInfo[0].clusterNearFar.xy;
        float _4708 = log2(_4661.y / _4661.x);
        int clusterIndex = int(floor((floor(v_texcoord0.x * _4446.x) + (floor((1.0 - v_texcoord0.y) * _4446.y) * _4446.x)) + ((floor((log2(-_2975.z) * (_4446.z / _4708)) - ((_4446.z * log2(_4661.x)) / _4708)) * _4446.x) * _4446.y)));
        if (clusterIndex >= floor((_5554.x * _5554.y) * _5554.z) || s_LightClusters[clusterIndex].count == 0) {
            pointLight = vec3(0.0, 0.0, 0.0);
        } else {
            int _4578 = s_LightClusters[clusterIndex].start + s_LightClusters[clusterIndex].count;
            vec3 _5950;
            _5950 = vec3(0.0, 0.0, 0.0);
            vec3 _4651;
            for (int i = s_LightClusters[clusterIndex].start; i < _4578; _5950 = _4651, i++) {
                int _4591 = int(s_LightLookupArray[i].lookup);
                vec4 _5562 = s_Lights[_4591].color;
                vec3 _4611 = mul(u_view, vec4(s_Lights[_4591].position.xyz, 1.0)).xyz - _2975;
                vec3 _4613 = normalize(_4611);
                float _4619 = length(_4611);
                vec3 _4810 = normalize(_4613 + _3251);
                float _4813 = emissiveAmbientLinearRoughness.w * emissiveAmbientLinearRoughness.w;
                float _4866 = _4813 * _4813;
                float _4870 = max(dot(_2956, _4810), 0.0);
                float _4878 = max((((_4866 - 1.0) * _4870) * _4870) + 1.0, 0.0001);
                float _4894 = max(dot(_2956, _3251), 0.0);
                float _4898 = max(dot(_2956, _4613), 0.0);
                float _4900 = _4813 * 0.5;
                vec3 _4926 = mix(vec3_splat(0.039999999105930328369140625), _3122, vec3_splat(_2905.w));
                vec3 _4942 = _4926 + ((vec3(1.0, 1.0, 1.0) - _4926) * pow(clamp(1.0 - max(dot(_3251, _4810), 0.0), 0.0, 1.0), 5.0));
                _4651 = _5950 + ((((((((vec3(1.0, 1.0, 1.0) - _4942) * (1.0 - _2905.w)) * _3122) * vec3_splat(0.3183098733425140380859375)) * float(s_LightingInfo[0].diffuseLightEnabled)) + ((((_4942 * (_4866 / ((_4878 * _4878) * 3.1415927410125732421875))) * ((_4894 / (((_4894 * (1.0 - _4900)) + _4900) + 0.0001)) * (_4898 / (((_4898 * (1.0 - _4900)) + _4900) + 0.0001)))) / vec3_splat(((4.0 * max(dot(_2956, _4613), 0.0)) * max(dot(_2956, _3251), 0.0)) + 0.0001)) * float(s_LightingInfo[0].specularLightEnabled))) * ((s_Lights[_4591].color.xyz * (_5562.w / (_4619 * _4619))) * max(dot(_2956, _4613), 0.0))) * 1.0);
            }
            pointLight = _5950;
        }
        _5954 = (_3464 + _5947) + (pointLight * s_LightingInfo[0].pointLightContributionEnabled);
    } else {
        _5954 = _3464 + (((mix(_3122, vec3_splat(dot(_3122, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875))), vec3_splat(s_LightingInfo[0].emissiveDesaturation)) * float(s_LightingInfo[0].emissiveLightEnabled)) * vec3_splat(emissiveAmbientLinearRoughness.x)) * s_LightingInfo[0].emissiveMultiplier);
    }

    float _3322 = length(_2975);
    vec3 finalColor;
    if (AtmosphericScatteringEnabled.x != 0.0) {
        float _5009 = clamp((((_3322 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x) - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x), 0.0, 1.0);
        vec3 _5956;
        if (_5009 > 0.0) {
            vec3 _5070 = normalize(_2939.xyz - mul(u_invView, vec4(0.0, 0.0, 0.0, 1.0)).xyz);
            vec4 _5826 = SunColor;
            vec4 _5827 = MoonColor;
            vec4 _5830 = FogColor;
            vec3 _5071 = _5070;
            float _5139 = FogSkyBlend.x - FogSkyBlend.w;
            float _5325 = smoothstep(FogSkyBlend.y, _5139, _5071.y);
            float _5339 = smoothstep(FogSkyBlend.z - FogSkyBlend.w, _5139, _5071.y);
            vec3 _5356 = pow(max(SkyZenithColor.xyz, 0.0), 2.2000000476837158203125);
            vec3 _5365 = pow(max(SkyHorizonColor.xyz, 0.0), 2.2000000476837158203125);
            float _5186 = dot(_5070, SunDir.xyz);
            float _5190 = dot(_5070, MoonDir.xyz);
            float _5375 = 0.5 * (_5186 + 1.0);
            float _5387 = 0.5 * (_5190 + 1.0);
            float _5211 = clamp(pow(max(_5186, 0.0), AtmosphericScattering.w), 0.0, 1.0);
            float _5216 = clamp(pow(max(_5190, 0.0), AtmosphericScattering.w), 0.0, 1.0);
            float _5409 = smoothstep(_5830.w, -FogSkyBlend.w, _5071.y);
            _5956 = mix(_5954, mix(mix(_5356, pow(max(FogColor.xyz, 0.0), 2.2000000476837158203125), vec3_splat(clamp((_5409 * _5409) * _5409, 0.0, 1.0))), (((mix(_5356, _5365, vec3_splat(clamp((_5325 * _5325) * _5325, 0.0, 1.0))) * AtmosphericScattering.x) * 0.0596831031143665313720703125) * (((_5375 * _5375) * _5826.w) + ((_5387 * _5387) * _5827.w))) + (((_5365 * clamp((_5339 * _5339) * _5339, 0.0, 1.0)) * 0.079577468335628509521484375) * (((((pow(max(SunColor.xyz, vec3(0.0, 0.0, 0.0)), vec3_splat(2.2000000476837158203125)) * _5826.w) * AtmosphericScattering.y) * _5211) * (3.6099998950958251953125 / pow(1.809999942779541015625 - (_5211 * 1.7999999523162841796875), 1.5))) + ((((pow(max(MoonColor.xyz, vec3(0.0, 0.0, 0.0)), vec3_splat(2.2000000476837158203125)) * _5827.w) * AtmosphericScattering.z) * _5216) * (3.6099998950958251953125 / pow(1.809999942779541015625 - (_5216 * 1.7999999523162841796875), 1.5))))), vec3_splat(clamp(smoothstep(0.5, 0.75, _5009), 0.0, 1.0))), vec3_splat(_5009));
        } else {
            _5956 = _5954;
        }
        finalColor = _5956;
    } else {
        finalColor = mix(_5954, FogColor.xyz, vec3_splat(clamp((((_3322 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x) - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x), 0.0, 1.0)));
    }
    gl_FragColor = vec4(finalColor, 1.0);
#else
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
#endif
}
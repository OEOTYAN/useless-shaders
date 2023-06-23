#include <bgfx_compute.sh>

struct Histogram {
    uint count;
};

uniform vec4 MinLogLuminance;
uniform vec4 AdaptiveParameters;
uniform vec4 DeltaTime;
uniform vec4 ScreenSize;
uniform vec4 LogLuminanceRange;

SAMPLER2D(s_GameColor, 0);
BUFFER_WR(s_CurFrameLuminanceHistogram, Histogram, 1);
IMAGE2D_WR(s_AdaptedFrameAverageLuminance, r32f, 2);

SHARED uint curFrameLuminanceHistogramShared[256];

void BuildHistogram(uint localInvocationIndex, uvec3 globalInvocationID) {
    curFrameLuminanceHistogramShared[localInvocationIndex] = 0;
    barrier();

    if (globalInvocationID.x < ScreenSize.x && globalInvocationID.y < ScreenSize.y) {
        float _292 = dot(texture2DLod(s_GameColor, (globalInvocationID.xy / ScreenSize.xy), 0.0).xyz, vec3(0.2125999927520751953125, 0.715200006961822509765625, 0.072200000286102294921875));
        uint _345;
        if (_292 < 0.004999999888241291046142578125) {
            _345 = 0;
        } else {
            _345 = uint((clamp((log2(_292) - MinLogLuminance.x) / LogLuminanceRange.x, 0.0, 1.0) * 254.0) + 1.0);
        }
        uint _297;
        atomicFetchAndAdd(curFrameLuminanceHistogramShared[_345], 1, _297);
    }
    barrier();

    uint _303;
    atomicFetchAndAdd(s_CurFrameLuminanceHistogram[localInvocationIndex].count, curFrameLuminanceHistogramShared[localInvocationIndex], _303);
}

void CalculateAverage(uint localInvocationIndex) {
    uint count = s_CurFrameLuminanceHistogram[localInvocationIndex].count;
    curFrameLuminanceHistogramShared[localInvocationIndex] = count * localInvocationIndex;
    barrier();

    for (uint _383 = 128; _383 > 0; _383 >>= 1) {
        if (localInvocationIndex < _383) {
            curFrameLuminanceHistogramShared[localInvocationIndex] += curFrameLuminanceHistogramShared[localInvocationIndex + _383];
        }
        barrier();
    }

    if (localInvocationIndex == 0) {
        float _328 = exp2(((((float(curFrameLuminanceHistogramShared[0]) / max((ScreenSize.x * ScreenSize.y) - float(count), 1.0)) - 1.0) * 0.00393700785934925079345703125) * LogLuminanceRange.x) + MinLogLuminance.x);
        float _368 = imageLoad(s_AdaptedFrameAverageLuminance, ivec2(0, 0));
        float _269 = (_368 + ((_328 - _368) * (1.0 - exp(((-DeltaTime.x) * AdaptiveParameters.x) * ((_368 < _328) ? AdaptiveParameters.y : (1.0 / AdaptiveParameters.z))))));
        imageStore(s_AdaptedFrameAverageLuminance, ivec2(0, 0), _269);
    }
}

void CleanUp(uint localInvocationIndex) {
    s_CurFrameLuminanceHistogram[localInvocationIndex].count = 0;
}


NUM_THREADS(1, 1, 1)
void main() {
#if BUILD_HISTOGRAM
    BuildHistogram(gl_LocalInvocationIndex, gl_GlobalInvocationID);
#elif CALCULATE_AVERAGE
    CalculateAverage(gl_LocalInvocationIndex);
#elif CLEAN_UP
    CleanUp(gl_LocalInvocationIndex);
#endif
}

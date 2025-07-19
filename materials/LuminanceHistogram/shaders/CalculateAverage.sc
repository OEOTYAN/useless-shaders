SHARED float curFrameLuminanceHistogramShared[256];

void Average(uint LocalInvocationIndex) {
    uint histogramCount = s_CurFrameLuminanceHistogram[LocalInvocationIndex].count;
    if (EnableCustomWeight.x != 0.0) {
        vec2 uv = vec2((float(LocalInvocationIndex) + 0.5f) / float(256), 0.5f);
        curFrameLuminanceHistogramShared[LocalInvocationIndex] = float(histogramCount) * texture2DLod(s_CustomWeight, uv, 0.0f).r;
    } else {
        curFrameLuminanceHistogramShared[LocalInvocationIndex] = float(histogramCount) * float(LocalInvocationIndex);
    }
    barrier();
    for (uint cutoff = uint(256 >> 1); cutoff > 0u;) {
        if (uint(LocalInvocationIndex) < cutoff) {
            curFrameLuminanceHistogramShared[LocalInvocationIndex] = curFrameLuminanceHistogramShared[LocalInvocationIndex] + curFrameLuminanceHistogramShared[LocalInvocationIndex + cutoff];
        }
        barrier();
        cutoff = (cutoff >> 1u);
    }
    if (LocalInvocationIndex == 0u) {
        float weightedLogAverage = (curFrameLuminanceHistogramShared[0] / max(ScreenSize.x * ScreenSize.y - float(histogramCount), 1.0f)) - 1.0f;
        if (weightedLogAverage < 1.f) {
            weightedLogAverage = 0.0f;
        }
        float weightedAverageLuminance = exp2(((weightedLogAverage * LogLuminanceRange.x) / 254.0f) + MinLogLuminance.x);
        float prevLuminance = imageLoad(s_AdaptedFrameAverageLuminance, ivec2(0, 0)).r;
        bool isBrighter = (prevLuminance < weightedAverageLuminance);
        float speedParam = isBrighter ? AdaptiveParameters.y : AdaptiveParameters.z;
        float adaptedLuminance = prevLuminance + (weightedAverageLuminance - prevLuminance) * (1.0f - exp(-DeltaTime.x * AdaptiveParameters.x * speedParam));
        if (isBrighter) {
            adaptedLuminance = adaptedLuminance > weightedAverageLuminance ? weightedAverageLuminance : adaptedLuminance;
        } else {
            adaptedLuminance = adaptedLuminance > weightedAverageLuminance ? adaptedLuminance : weightedAverageLuminance;
        }
        imageStore(s_AdaptedFrameAverageLuminance, ivec2(0, 0), vec4(adaptedLuminance, adaptedLuminance, adaptedLuminance, adaptedLuminance));
        int maxLuminanceBin = 0;
        for (int i = 256 - 1; i > 0; i--) {
            if (float(s_CurFrameLuminanceHistogram[i].count) >= AdaptiveParameters.w) {
                maxLuminanceBin = i;
                break;
            }
        }
        vec2 uv = vec2((float(maxLuminanceBin) + 0.5f) / float(256), 0.5f);
        float maxLuminance = 0.0f;
        if (EnableCustomWeight.x != 0.0) {
            maxLuminance = exp2(((texture2DLod(s_CustomWeight, uv, 0.0f).r - 1.0f) * LogLuminanceRange.x) / 254.0f + MinLogLuminance.x);
        } else {
            maxLuminance = exp2(((float(maxLuminanceBin) - 1.0f) * LogLuminanceRange.x) / 254.0f + MinLogLuminance.x);
        }
        imageStore(s_MaxFrameLuminance, ivec2(0, 0), vec4(maxLuminance, maxLuminance, maxLuminance, maxLuminance));
    }
}

NUM_THREADS(16, 16, 1)
void main() {
    Average(gl_LocalInvocationIndex);
}

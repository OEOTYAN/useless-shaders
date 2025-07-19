#include <bgfx_compute.sh>

struct Histogram {
    uint count;
};

uniform vec4 MinLogLuminance;
uniform vec4 AdaptiveParameters;
uniform vec4 DeltaTime;
uniform vec4 ScreenSize;
uniform vec4 LogLuminanceRange;
uniform vec4 EnableCustomWeight;

SAMPLER2D_AUTOREG(s_GameColor);
SAMPLER2D_AUTOREG(s_CustomWeight);
BUFFER_RW_AUTOREG(s_CurFrameLuminanceHistogram, Histogram);
IMAGE2D_RW_AUTOREG(s_AdaptedFrameAverageLuminance, r32f);
IMAGE2D_RW_AUTOREG(s_MaxFrameLuminance, r32f);


#if BUILD_HISTOGRAM
    #include "BuildHistogram.sc"
#elif CALCULATE_AVERAGE
    #include "CalculateAverage.sc"
#elif CLEAN_UP
    #include "CleanUp.sc"
#endif

SHARED uint curFrameLuminanceHistogramShared[256];

uint luminanceToHistogramBin(float luminance) {
    if (luminance < 0.00095f) {
        return 0u;
    }
    float logLuminance = clamp((log2(luminance) - MinLogLuminance.x) * 1.0f / LogLuminanceRange.x, 0.0f, 1.0f);
    return uint(logLuminance * 254.0 + 1.0);
}

void Build(uint LocalInvocationIndex, uvec3 GlobalInvocationID) {
    uint x = GlobalInvocationID.x;
    uint y = GlobalInvocationID.y;
    curFrameLuminanceHistogramShared[LocalInvocationIndex] = 0u;
    barrier();
    if (x < uint(ScreenSize.x) && y < uint(ScreenSize.y)) {
        ivec2 pixel = ivec2(x, y);
        vec2 uv = vec2(pixel) / ScreenSize.xy;
        vec3 color = texture2DLod(s_GameColor, uv, 0.0f).rgb;
        float luminance = dot(color.rgb, vec3(0.2126f, 0.7152f, 0.0722f));
        uint index = luminanceToHistogramBin(luminance);
        atomicAdd(curFrameLuminanceHistogramShared[index], 1u);
    }
    barrier();
    atomicAdd(s_CurFrameLuminanceHistogram[LocalInvocationIndex].count, curFrameLuminanceHistogramShared[LocalInvocationIndex]);
}

NUM_THREADS(16, 16, 1)
void main() {
    Build(gl_LocalInvocationIndex, gl_GlobalInvocationID);
}

void Clean(uint LocalInvocationIndex) {
    s_CurFrameLuminanceHistogram[LocalInvocationIndex].count = 0u;
}

NUM_THREADS(16, 16, 1)
void main() {
    Clean(gl_LocalInvocationIndex);
}

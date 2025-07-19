#include <bgfx_compute.sh>

uniform vec4 ClearValue;
uniform vec4 VolumeDimensions;

IMAGE2D_ARRAY_WR_AUTOREG(s_Volume, rgba16f);

void Clear(uvec3 GlobalInvocationID) {
    int volumeWidth = int(VolumeDimensions.x);
    int volumeHeight = int(VolumeDimensions.y);
    int volumeDepth = int(VolumeDimensions.z);
    int x = int(GlobalInvocationID.x);
    int y = int(GlobalInvocationID.y);
    int z = int(GlobalInvocationID.z);
    if (x >= volumeWidth || y >= volumeHeight || z >= volumeDepth) {
        return;
    }
    imageStore(s_Volume, ivec3(x, y, z), ClearValue);
}

NUM_THREADS(8, 8, 8)
void main() {
    Clear(gl_GlobalInvocationID);
}
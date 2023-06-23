#include <bgfx_compute.sh>

struct LightExtends {
    vec4 min;
    vec4 max;
    int index;
    int pad0;
    int pad1;
    int pad2;
};

struct LightCluster {
    int start;
    int count;
};

struct LightData {
    float lookup;
};

uniform vec4 LightsPerCluster;
uniform vec4 ClusterDimensions;

BUFFER_RW(s_LightClusters,    LightCluster, 0);
BUFFER_WR(s_LightLookupArray, LightData,    1);
BUFFER_RO(s_Extends,          LightExtends, 2);

NUM_THREADS(4, 4, 4)
void main() {
    vec3 id = vec3(gl_GlobalInvocationID);

    int lightsPerCluster = int(LightsPerCluster.x);
    int clusterIndex = int(floor(id.x + (ClusterDimensions.x * id.y) + (ClusterDimensions.x * ClusterDimensions.y * id.z)));

    int start = clusterIndex * lightsPerCluster;
    s_LightClusters[clusterIndex].start = start;
    s_LightClusters[clusterIndex].count = 0;

    for (int i = 0; i < int(ClusterDimensions.w); i++) {
        LightExtends lightExtends = s_Extends[i];
        if (id.z >= lightExtends.min.z && id.z <= lightExtends.max.z &&
            id.y >= lightExtends.min.y && id.y <= lightExtends.max.y &&
            id.x >= lightExtends.min.x && id.x <= lightExtends.max.x) {
            if (int(s_LightClusters[clusterIndex].count) < lightsPerCluster) {
                int originalCount;
                atomicFetchAndAdd(s_LightClusters[clusterIndex].count, 1, originalCount);
                s_LightLookupArray[originalCount + start].lookup = lightExtends.index;
            }
        }
    }
}

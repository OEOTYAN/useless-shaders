#include <bgfx_compute.sh>

struct LightCluster {
    int count;
};

struct LightData {
    float lookup;
};

struct LightExtends {
    vec4 min;
    vec4 max;
    vec4 pos;
    int index;
    float radius;
    int pad1;
    int pad2;
};

struct LightContribution {
    float contribution;
    int indexInLookUp;
};

uniform vec4 LightsPerCluster;
uniform vec4 ClusterNearFarWidthHeight;
uniform vec4 CameraFarPlane;
uniform vec4 ClusterDimensions;
uniform vec4 ClusterSize;
uniform vec4 CameraClusterWeight;
uniform mat4 InvViewMat;
uniform mat4 ProjMat;
uniform mat4 ViewMat;
uniform vec4 WorldOrigin;

BUFFER_WR_AUTOREG(s_LightLookupArray, LightData);
BUFFER_RO_AUTOREG(s_Extends, LightExtends);

#if defined(CLUSTER_LIGHTS)
    #include "ClusterLights.sc"
#elif defined(CLUSTER_LIGHTS_MANHATTAN)
    #include "ClusterLightsManhattan.sc"
#endif

NUM_THREADS(4, 4, 4)
void main() {
    ClusterLights(gl_GlobalInvocationID);
}

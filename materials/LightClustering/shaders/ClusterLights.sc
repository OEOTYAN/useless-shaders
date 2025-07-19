float getViewSpaceCoordByRatio(float clusterIndex, float clusterSize, float screenDim, float farPlaneDim, float planeRatio) {
    return ((clusterIndex * clusterSize - screenDim / 2.0f) / screenDim) * (farPlaneDim * planeRatio);
}

float getClusterDepthByIndex(float index, float maxSlices, vec2 clusterNearFar) {
    float zNear = clusterNearFar.x;
    float zFar = clusterNearFar.y;
    if (index == 0.0f) {
        return zNear;
    }
    if (index == 1.0f) {
        return 1.0f;
    }
    float nearFarLog = log2(zFar / 1.5f);
    float logDepth = nearFarLog * (index - 2.0f) / (maxSlices - 2.0f);
    return pow(2.0f, logDepth);
}

void ClusterLights(uvec3 GlobalInvocationID) {
    float x = float(GlobalInvocationID.x);
    float y = float(GlobalInvocationID.y);
    float z = float(GlobalInvocationID.z);
    int lightCount = int(ClusterDimensions.w);
    int maxLights = int(LightsPerCluster.x);
    if (x >= ClusterDimensions.x || y >= ClusterDimensions.y || z >= ClusterDimensions.z) {
        return;
    }
    highp int idx = int(x + y * ClusterDimensions.x + z * ClusterDimensions.x * ClusterDimensions.y);
    highp int rangeStart = int(idx * maxLights);
    highp int rangeEnd = int(rangeStart + maxLights);
    float viewDepth = getClusterDepthByIndex(z + 0.5f, ClusterDimensions.z, ClusterNearFarWidthHeight.xy);
    float planeRatio = viewDepth / CameraFarPlane.z;
    float centerX = getViewSpaceCoordByRatio(x + 0.5f, ClusterSize.x, ClusterNearFarWidthHeight.z, CameraFarPlane.x, planeRatio);
    float centerY = getViewSpaceCoordByRatio(y + 0.5f, ClusterSize.y, ClusterNearFarWidthHeight.w, CameraFarPlane.y, planeRatio);
    vec3 center = vec3(centerX, centerY, -viewDepth);
    LightContribution distanceToCenter[64];
    int countResult = 0;
    for (int l = 0; l < lightCount; l++) {
        LightExtends bound = s_Extends[l];
        if (z < bound.min.z || z > bound.max.z)
        continue;
        if (y < bound.min.y || y > bound.max.y)
        continue;
        if (x < bound.min.x || x > bound.max.x)
        continue;
        float curDistance = length(bound.pos.xyz - center);
        if (countResult >= maxLights && curDistance >= distanceToCenter[countResult - 1].contribution) {
            continue;
        }
        int low = 0;
        int high = countResult;
        while (low < high) {
            int mid = (low + high) / 2;
            if (distanceToCenter[mid].contribution < curDistance) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        if (countResult < maxLights) {
            for (int j = countResult - 1; j >= low; j--) {
                distanceToCenter[j + 1] = distanceToCenter[j];
            }
            distanceToCenter[low].contribution = curDistance;
            distanceToCenter[low].indexInLookUp = countResult;
            s_LightLookupArray[idx * maxLights + countResult].lookup = float(bound.index);
            countResult++;
        } else {
            int insertPos = distanceToCenter[maxLights - 1].indexInLookUp;
            for (int j = maxLights - 2; j >= low; j--) {
                distanceToCenter[j + 1] = distanceToCenter[j];
            }
            distanceToCenter[low].contribution = curDistance;
            distanceToCenter[low].indexInLookUp = insertPos;
            s_LightLookupArray[idx * maxLights + insertPos].lookup = float(bound.index);
        }
    }
    if (countResult < maxLights) {
        s_LightLookupArray[rangeStart + countResult].lookup = -1.0;
    }
}

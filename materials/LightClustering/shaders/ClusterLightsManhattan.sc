float clusterIndexToScreenCoord(float index, float clusterSize, float dimension) {
    return (min(index * clusterSize, dimension) - dimension / 2.0f) / dimension;
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
    LightContribution contribution[64];
    vec2 corners[7];
    corners[0] = vec2(1.0f, 0.0f);
    corners[1] = vec2(0.0f, 1.0f);
    corners[2] = vec2(1.0f, 1.0f);
    corners[3] = vec2(1.0f, 1.0f);
    corners[4] = vec2(0.0f, 1.0f);
    corners[5] = vec2(1.0f, 0.0f);
    corners[6] = vec2(0.0f, 0.0f);
    int closestCornerToCameraIndex = 3;
    float left = x;
    float right = x + 1.0f;
    float bottom = y;
    float top = y + 1.0f;
    if (right < ClusterDimensions.x / 2.0f && top < ClusterDimensions.y / 2.0f) {
        closestCornerToCameraIndex = 2;
    } else if (left > ClusterDimensions.x / 2.0f && top < ClusterDimensions.y / 2.0f) {
        closestCornerToCameraIndex = 1;
    } else if (right < ClusterDimensions.x / 2.0f && bottom > ClusterDimensions.y / 2.0f) {
        closestCornerToCameraIndex = 0;
    } else if (left > ClusterDimensions.x / 2.0f && bottom > ClusterDimensions.y / 2.0f) {
        closestCornerToCameraIndex = -1;
    }
    int oppositeCornerIndex = 4 + closestCornerToCameraIndex;
    int countResult = 0;
    for (int l = 0; l < lightCount; l++) {
        LightExtends bound = s_Extends[l];
        if (z < bound.min.z || z > bound.max.z)
            continue;
        if (y < bound.min.y || y > bound.max.y)
            continue;
        if (x < bound.min.x || x > bound.max.x)
            continue;
        vec3 closestCornerToCameraView = vec3(0.0f, 0.0f, 0.0f);
        vec3 oppositeCornerView = vec3(0.0f, 0.0f, 0.0f);
        vec3 lightWorldGrid = floor(bound.pos.xyz - WorldOrigin.xyz);
        float cornerViewZ = getClusterDepthByIndex(z, ClusterDimensions.z, ClusterNearFarWidthHeight.xy);
        float cornerScreenX = clusterIndexToScreenCoord(x, ClusterSize.x, ClusterNearFarWidthHeight.z);
        float cornerScreenY = clusterIndexToScreenCoord(y, ClusterSize.y, ClusterNearFarWidthHeight.w);
        float cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
        float cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
        vec3 clusterWorld = mul(InvViewMat, vec4(cornerViewX, cornerViewY, -cornerViewZ, 1.0f)).xyz;
        vec3 clusterWorldGrid = floor(clusterWorld - WorldOrigin.xyz);
        vec3 clusterWorldGridMin = clusterWorldGrid;
        vec3 clusterWorldGridMax = clusterWorldGrid;
        if (closestCornerToCameraIndex == -1) {
            closestCornerToCameraView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
        }
        if (closestCornerToCameraIndex == 3) {
            cornerScreenX = clusterIndexToScreenCoord(x + 0.5f, ClusterSize.x, ClusterNearFarWidthHeight.z);
            cornerScreenY = clusterIndexToScreenCoord(y + 0.5f, ClusterSize.y, ClusterNearFarWidthHeight.w);
            cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
            cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
            closestCornerToCameraView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
        }
        for (int cf = 0; cf < 3; cf++) {
            cornerScreenX = clusterIndexToScreenCoord(x + corners[cf].x, ClusterSize.x, ClusterNearFarWidthHeight.z);
            cornerScreenY = clusterIndexToScreenCoord(y + corners[cf].y, ClusterSize.y, ClusterNearFarWidthHeight.w);
            cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
            cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
            clusterWorld = mul(InvViewMat, vec4(cornerViewX, cornerViewY, -cornerViewZ, 1.0f)).xyz;
            clusterWorldGrid = floor(clusterWorld - WorldOrigin.xyz);
            clusterWorldGridMin = min(clusterWorldGrid, clusterWorldGridMin);
            clusterWorldGridMax = max(clusterWorldGrid, clusterWorldGridMax);
            if (closestCornerToCameraIndex == cf) {
                closestCornerToCameraView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
            }
        }
        cornerViewZ = getClusterDepthByIndex(z + 1.0f, ClusterDimensions.z, ClusterNearFarWidthHeight.xy);
        for (int cb = 3; cb < 7; cb++) {
            cornerScreenX = clusterIndexToScreenCoord(x + corners[cb].x, ClusterSize.x, ClusterNearFarWidthHeight.z);
            cornerScreenY = clusterIndexToScreenCoord(y + corners[cb].y, ClusterSize.y, ClusterNearFarWidthHeight.w);
            cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
            cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
            clusterWorld = mul(InvViewMat, vec4(cornerViewX, cornerViewY, -cornerViewZ, 1.0f)).xyz;
            clusterWorldGrid = floor(clusterWorld - WorldOrigin.xyz);
            clusterWorldGridMin = min(clusterWorldGrid, clusterWorldGridMin);
            clusterWorldGridMax = max(clusterWorldGrid, clusterWorldGridMax);
            if (oppositeCornerIndex == cb) {
                oppositeCornerView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
            }
        }
        if (oppositeCornerIndex == 7) {
            cornerScreenX = clusterIndexToScreenCoord(x + 0.5f, ClusterSize.x, ClusterNearFarWidthHeight.z);
            cornerScreenY = clusterIndexToScreenCoord(y + 0.5f, ClusterSize.y, ClusterNearFarWidthHeight.w);
            cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
            cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
            oppositeCornerView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
        }
        cornerViewZ = getClusterDepthByIndex(z + 0.5f, ClusterDimensions.z, ClusterNearFarWidthHeight.xy);
        cornerScreenX = clusterIndexToScreenCoord(x + 0.5f, ClusterSize.x, ClusterNearFarWidthHeight.z);
        cornerScreenY = clusterIndexToScreenCoord(y + 0.5f, ClusterSize.y, ClusterNearFarWidthHeight.w);
        cornerViewX = cornerViewZ * cornerScreenX / ProjMat[0][0];
        cornerViewY = cornerViewZ * cornerScreenY / ProjMat[1][1];
        vec3 centerView = vec3(cornerViewX, cornerViewY, -cornerViewZ);
        vec3 lightView = mul(ViewMat, vec4(bound.pos.xyz, 1.0f)).xyz;
        float lightDistance = length(lightView);
        float cameraDistanceContribution = max(1.0f - lightDistance / length(oppositeCornerView), 0.0f);
        float clusterContribution = max(1.0f - length(lightView - centerView) / (length(oppositeCornerView - closestCornerToCameraView) / 2.0f), 0.0f);
        float curContribution = CameraClusterWeight.x * cameraDistanceContribution + CameraClusterWeight.y * clusterContribution;
        if (countResult >= maxLights && curContribution <= contribution[countResult - 1].contribution) {
            continue;
        }
        bool lightInCluster = true;
        for (int gridX = int(clusterWorldGridMin.x); gridX <= int(clusterWorldGridMax.x); gridX++) {
            for (int gridY = int(clusterWorldGridMin.y); gridY <= int(clusterWorldGridMax.y); gridY++) {
                for (int gridZ = int(clusterWorldGridMin.z); gridZ <= int(clusterWorldGridMax.z); gridZ++) {
                    vec3 curWorldGrid = vec3(float(gridX), float(gridY), float(gridZ));
                    vec3 dir = curWorldGrid - lightWorldGrid;
                    float manhattan = abs(dir.x) + abs(dir.y) + abs(dir.z);
                    if (manhattan <= bound.radius) {
                        lightInCluster = true;
                        break;
                    }
                }
            }
        }
        if (lightInCluster) {
            int low = 0;
            int high = countResult;
            while (low < high) {
                int mid = (low + high) / 2;
                if (contribution[mid].contribution >= curContribution) {
                    low = mid + 1;
                } else {
                    high = mid;
                }
            }
            if (countResult < maxLights) {
                for (int j = countResult - 1; j >= low; j--) {
                    contribution[j + 1] = contribution[j];
                }
                contribution[low].contribution = curContribution;
                contribution[low].indexInLookUp = countResult;
                s_LightLookupArray[idx * maxLights + countResult].lookup = float(bound.index);
                countResult++;
            } else {
                int insertPos = contribution[maxLights - 1].indexInLookUp;
                for (int j = maxLights - 2; j >= low; j--) {
                    contribution[j + 1] = contribution[j];
                }
                contribution[low].contribution = curContribution;
                contribution[low].indexInLookUp = insertPos;
                s_LightLookupArray[idx * maxLights + insertPos].lookup = float(bound.index);
            }
        }
    }
    if (countResult < maxLights) {
        s_LightLookupArray[rangeStart + countResult].lookup = -1.0;
    }
}

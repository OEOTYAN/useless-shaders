
float RandFast(uint2 PixelPos, float M) {
    float Magic = 3571.0 + M;
    float2 Random2 = (1.0 / 4320.0) * PixelPos + float2(0.25, 0.0);
    float Random = frac(dot(Random2 * Random2, Magic));
    Random = frac(Random * Random * (2 * Magic));
    return Random;
}
half3 sRGBToLinear(half3 Color) {
    Color = max(6.10352e-5, Color);
    return Color > 0.04045 ? pow(Color * (1.0 / 1.055) + 0.0521327, 2.4)
                           : Color * (1.0 / 12.92);
}

bool RayHitSphere(float3 RayOrigin,
                  float3 UnitRayDirection,
                  float3 SphereCenter,
                  float SphereRadius) {
    float3 ClosestPointOnRay =
        max(0, dot(SphereCenter - RayOrigin, UnitRayDirection)) *
        UnitRayDirection;
    float3 CenterToRay = RayOrigin + ClosestPointOnRay - SphereCenter;
    return dot(CenterToRay, CenterToRay) <= Square(SphereRadius);
}
float2 RayIntersectSphere(float3 RayOrigin,
                          float3 RayDirection,
                          float4 Sphere) {
    float3 LocalPosition = RayOrigin - Sphere.xyz;
    float LocalPositionSqr = dot(LocalPosition, LocalPosition);

    float3 QuadraticCoef;
    QuadraticCoef.x = dot(RayDirection, RayDirection);
    QuadraticCoef.y = 2 * dot(RayDirection, LocalPosition);
    QuadraticCoef.z = LocalPositionSqr - Sphere.w * Sphere.w;

    float Discriminant = QuadraticCoef.y * QuadraticCoef.y -
                         4 * QuadraticCoef.x * QuadraticCoef.z;

    float2 Intersections = -1;

    // Only continue if the ray intersects the sphere

    if (Discriminant >= 0) {
        float SqrtDiscriminant = sqrt(Discriminant);
        Intersections = (-QuadraticCoef.y + float2(-1, 1) * SqrtDiscriminant) /
                        (2 * QuadraticCoef.x);
    }

    return Intersections;
}

#define WAVE_HEIGHT 1.0f

float ValueNoise(float2 uv) {
    float2 uvp = frac(uv) * 64.0 + 0.5f;
    float2 i = floor(uvp);
    float2 f = frac(uvp);
    float a = RandFast(fmod(i, 64), 0);
    float b = RandFast(fmod(i + float2(1, 0), 64), 0);
    float c = RandFast(fmod(i + float2(0, 1), 64), 0);
    float d = RandFast(fmod(i + float2(1, 1), 64), 0);
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float AlmostIdentity(in float x, in float m, in float n) {
    if (x > m)
        return x;

    float a = 2.0f * n - m;
    float b = 2.0f * m - 3.0f * n;
    float t = x / m;

    return (a * t + b) * t * t + n;
}

float GetWaves(float3 position, in float scale) {
    float speed = 0.9f;

    float2 p = position.xz / 20.0f;

    p.xy -= position.y / 20.0f;

    p.x = -p.x;

    p.x += (TIME / 40.0f) * speed;
    p.y -= (TIME / 40.0f) * speed;

    float weight = 1.0f;
    float weights = weight;

    float allwaves = 0.0f;

    float wave =
        ValueNoise((p * float2(2.0f, 1.2f)) + float2(0.0f, p.x * 2.1f)).x;
    p /= 2.1f;
    p.y -= (TIME / 20.0f) * speed;
    p.x -= (TIME / 30.0f) * speed;
    allwaves += wave;

    weight = 4.1f;
    weights += weight;
    wave = ValueNoise((p * float2(2.0f, 1.4f)) + float2(0.0f, -p.x * 2.1f)).x;
    p /= 1.5f;
    p.x += (TIME / 20.0f) * speed;
    wave *= weight;
    allwaves += wave;

    weight = 17.25f;
    weights += weight;
    wave = (ValueNoise((p * float2(1.0f, 0.75f)) + float2(0.0f, p.x * 1.1f)).x);
    p /= 1.5f;
    p.x -= (TIME / 55.0f) * speed;
    wave *= weight;
    allwaves += wave;

    weight = 15.25f;
    weights += weight;
    wave =
        (ValueNoise((p * float2(1.0f, 0.75f)) + float2(0.0f, -p.x * 1.7f)).x);
    p /= 1.9f;
    p.x += (TIME / 155.0f) * speed;
    wave *= weight;
    allwaves += wave;

    weight = 29.25f;
    weights += weight;
    wave =
        abs(ValueNoise((p * float2(1.0f, 0.8f)) + float2(0.0f, -p.x * 1.7f)).x *
                2.0f -
            1.0f);
    p /= 2.0f;
    p.x += (TIME / 155.0f) * speed;
    wave = 1.0f - AlmostIdentity(wave, 0.2f, 0.1f);
    wave *= weight;
    allwaves += wave;

    weight = 15.25f;
    weights += weight;
    wave =
        abs(ValueNoise((p * float2(1.0f, 0.8f)) + float2(0.0f, p.x * 1.7f)).x *
                2.0f -
            1.0f);
    wave = 1.0f - AlmostIdentity(wave, 0.2f, 0.1f);
    wave *= weight;
    allwaves += wave;

    allwaves /= weights;

    return allwaves;
}

float3 GetWaterParallaxCoord(in float3 position,
                             in float3 viewVector,
                             in float distance) {
    float3 parallaxCoord = position.xyz;

    float3 stepSize = float3(0.6f * WAVE_HEIGHT, 0.6f * WAVE_HEIGHT, 0.6f);

    float waveHeight = GetWaves(position, 1.0f);

    float3 pCoord = float3(0.0f, 0.0f, 1.0f);

    float3 step = viewVector * stepSize;
    float distAngleWeight = ((distance * 0.2f) * (2.1f - viewVector.z)) / 2.0f;
    distAngleWeight = 1.0f;
    step *= distAngleWeight;

    float sampleHeight = waveHeight;

    for (int i = 0; sampleHeight < pCoord.z && i < 10; ++i) {
        pCoord.xy = lerp(pCoord.xy, pCoord.xy + step.xy,
                         clamp((pCoord.z - sampleHeight) /
                                   (stepSize.z * 0.2f * distAngleWeight /
                                    (-viewVector.z + 0.05f)),
                               0.0f, 1.0f));
        pCoord.z += step.z;
        // pCoord += step;
        sampleHeight =
            GetWaves(position + float3(pCoord.x, 0.0f, pCoord.y), 1.0f);
    }

    parallaxCoord = position.xyz + float3(pCoord.x, 0.0f, pCoord.y);

    return parallaxCoord;
}

float3 GetWavesNormal(float3 position,
                      float3 worldPos,
                      in float scale,
                      in float3x3 tbnMatrix,
                      in float distance) {
    float3 wavesNormal;
    float3 modelView = normalize(-worldPos);

    float3 viewVector = normalize(mul(tbnMatrix, modelView.xyz));

    // viewVector = normalize(viewVector);

    // position = GetWaterParallaxCoord(position, viewVector,distance);

    const float sampleDistance = 13.0f;

    position -= float3(0.005f, 0.0f, 0.005f) * sampleDistance;

    float wavesCenter = GetWaves(position, scale);
    float wavesLeft =
        GetWaves(position + float3(0.01f * sampleDistance, 0.0f, 0.0f), scale);
    float wavesUp =
        GetWaves(position + float3(0.0f, 0.0f, 0.01f * sampleDistance), scale);

    wavesNormal.r = wavesCenter - wavesLeft;
    wavesNormal.g = wavesCenter - wavesUp;

    wavesNormal.r *= 20.0f * WAVE_HEIGHT / sampleDistance;
    wavesNormal.g *= 20.0f * WAVE_HEIGHT / sampleDistance;

    //  wavesNormal.b = sqrt(1.0f - wavesNormal.r * wavesNormal.r -
    //  wavesNormal.g * wavesNormal.g);
    wavesNormal.b = 1.0;
    wavesNormal.rgb = normalize(wavesNormal.rgb);

    return wavesNormal.rgb;
}
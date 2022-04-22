
#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/) 
#define USE_TEXEL_AA 0
#else
#define USE_TEXEL_AA 1
#endif

#ifdef ALPHA_TEST
#define USE_ALPHA_TEST 1
#else
#define USE_ALPHA_TEST 0
#endif

#if USE_TEXEL_AA

static const float TEXEL_AA_LOD_CONSERVATIVE_ALPHA = -1.0f;
static const float TEXEL_AA_LOD_RELAXED_ALPHA = 2.0f;
float4 texture2D_AA(in Texture2D source, in sampler bilinearSampler, in float2 originalUV) {

	const float2 dUV_dX = ddx(originalUV) * TEXTURE_DIMENSIONS.xy;
	const float2 dUV_dY = ddy(originalUV) * TEXTURE_DIMENSIONS.xy;

	const float2 delU = float2(dUV_dX.x, dUV_dY.x);
	const float2 delV = float2(dUV_dX.y, dUV_dY.y);
	const float2 adjustmentScalar = max(1.0f / float2(length(delU), length(delV)), 1.0f);

	const float2 fractionalTexel = frac(originalUV * TEXTURE_DIMENSIONS.xy);
	const float2 adjustedFractionalTexel = clamp(fractionalTexel * adjustmentScalar, 0.0f, 0.5f) + clamp(fractionalTexel * adjustmentScalar - (adjustmentScalar - 0.5f), 0.0f, 0.5f);

	const float lod = log2(sqrt(max(dot(dUV_dX, dUV_dX), dot(dUV_dY, dUV_dY))) * 2.0f);
	const float samplingMode = smoothstep(TEXEL_AA_LOD_RELAXED_ALPHA, TEXEL_AA_LOD_CONSERVATIVE_ALPHA, lod);

	const float2 adjustedUV = (adjustedFractionalTexel + floor(originalUV * TEXTURE_DIMENSIONS.xy)) / TEXTURE_DIMENSIONS.xy;
	const float4 blendedSample = source.Sample(bilinearSampler, lerp(originalUV, adjustedUV, samplingMode));

	#if USE_ALPHA_TEST
		return float4(blendedSample.rgb, lerp(blendedSample.a, smoothstep(1.0f/2.0f, 1.0f, blendedSample.a), samplingMode));
	#else
		return blendedSample;
	#endif
}

float4 texture2Dat_AA(in Texture2D source, in sampler bilinearSampler, in float2 originalUV) {

	const float2 dUV_dX = ddx(originalUV) * TEXTURE_DIMENSIONS.xy;
	const float2 dUV_dY = ddy(originalUV) * TEXTURE_DIMENSIONS.xy;

	const float2 delU = float2(dUV_dX.x, dUV_dY.x);
	const float2 delV = float2(dUV_dX.y, dUV_dY.y);
	const float2 adjustmentScalar = max(1.0f / float2(length(delU), length(delV)), 1.0f);

	const float2 fractionalTexel = frac(originalUV * TEXTURE_DIMENSIONS.xy);
	const float2 adjustedFractionalTexel = clamp(fractionalTexel * adjustmentScalar, 0.0f, 0.5f) + clamp(fractionalTexel * adjustmentScalar - (adjustmentScalar - 0.5f), 0.0f, 0.5f);

	const float lod = log2(sqrt(max(dot(dUV_dX, dUV_dX), dot(dUV_dY, dUV_dY))) * 2.0f);
	const float samplingMode = smoothstep(TEXEL_AA_LOD_RELAXED_ALPHA, TEXEL_AA_LOD_CONSERVATIVE_ALPHA, lod);

	const float2 adjustedUV = (adjustedFractionalTexel + floor(originalUV * TEXTURE_DIMENSIONS.xy)) / TEXTURE_DIMENSIONS.xy;
	const float4 blendedSample = source.Sample(bilinearSampler, lerp(originalUV, adjustedUV, samplingMode));

if(max(blendedSample.r/blendedSample.a,max(blendedSample.g/blendedSample.a,blendedSample.b/blendedSample.a))<1.0)
		return float4(blendedSample.rgb/blendedSample.a,blendedSample.a);
		return float4(blendedSample.rgb,blendedSample.a);

}

#endif // USE_TEXEL_AA

float4 texture2Dlod_AA(in Texture2D source, in sampler bilinearSampler, in float2 originalUV,in float lod) {
    const float el=exp2(lod);

	const float2 dUV_dX = ddx(originalUV) * (TEXTURE_DIMENSIONS.xy/el);
	const float2 dUV_dY = ddy(originalUV) * (TEXTURE_DIMENSIONS.xy/el);

	const float2 delU = float2(dUV_dX.x, dUV_dY.x);
	const float2 delV = float2(dUV_dX.y, dUV_dY.y);
	const float2 adjustmentScalar = max(1.0f / float2(length(delU), length(delV)), 1.0f);

	const float2 fractionalTexel = frac(originalUV * (TEXTURE_DIMENSIONS.xy/el));
	const float2 adjustedFractionalTexel = clamp(fractionalTexel * adjustmentScalar, 0.0f, 0.5f) + clamp(fractionalTexel * adjustmentScalar - (adjustmentScalar - 0.5f), 0.0f, 0.5f);

	const float2 adjustedUV = (adjustedFractionalTexel + floor(originalUV * (TEXTURE_DIMENSIONS.xy/el))) / (TEXTURE_DIMENSIONS.xy/el);
	const float4 blendedSample = source.SampleLevel(bilinearSampler, adjustedUV,lod);

		return blendedSample;
}

float MakeDepthLinear(float z, float n, float f, bool scaleZ)
{
	//Remaps z from [0, 1] to [-1, 1].
	if (scaleZ) {
		z = 2.f * z - 1.f;
	}
	return (2.f * n) / (f + n - z * (f - n));
}

#define M_E 2.718281828459045f
#define M_PI 3.141592653589793f
#define M_TAU 6.283185307179586f

#define TangentBias(X) (X * 2.0f - 1.0f)

float ftri( float x)
{
    return abs(frac(0.5*(x-1.0))*2.0-1.0);
}
float2 ftri( float2 x)
{
    return abs(frac(0.5*(x-1.0))*2.0-1.0);
}
float3 ftri( float3 x)
{
    return abs(frac(0.5*(x-1.0))*2.0-1.0);
}
float4 ftri( float4 x)
{
    return abs(frac(0.5*(x-1.0))*2.0-1.0);
}
float Square( float x )
{
	return x*x;
}

float2 Square( float2 x )
{
	return x*x;
}

float3 Square( float3 x )
{
	return x*x;
}

float4 Square( float4 x )
{
	return x*x;
}

float Pow2( float x )
{
	return x*x;
}

float2 Pow2( float2 x )
{
	return x*x;
}

float3 Pow2( float3 x )
{
	return x*x;
}

float4 Pow2( float4 x )
{
	return x*x;
}

float Pow3( float x )
{
	return x*x*x;
}

float2 Pow3( float2 x )
{
	return x*x*x;
}

float3 Pow3( float3 x )
{
	return x*x*x;
}

float4 Pow3( float4 x )
{
	return x*x*x;
}

float Pow4( float x )
{
	float xx = x*x;
	return xx * xx;
}

float2 Pow4( float2 x )
{
	float2 xx = x*x;
	return xx * xx;
}

float3 Pow4( float3 x )
{
	float3 xx = x*x;
	return xx * xx;
}

float4 Pow4( float4 x )
{
	float4 xx = x*x;
	return xx * xx;
}

float Pow5( float x )
{
	float xx = x*x;
	return xx * xx * x;
}

float2 Pow5( float2 x )
{
	float2 xx = x*x;
	return xx * xx * x;
}

float3 Pow5( float3 x )
{
	float3 xx = x*x;
	return xx * xx * x;
}

float4 Pow5( float4 x )
{
	float4 xx = x*x;
	return xx * xx * x;
}

float Pow6( float x )
{
	float xx = x*x;
	return xx * xx * xx;
}

float2 Pow6( float2 x )
{
	float2 xx = x*x;
	return xx * xx * xx;
}

float3 Pow6( float3 x )
{
	float3 xx = x*x;
	return xx * xx * xx;
}

float4 Pow6( float4 x )
{
	float4 xx = x*x;
	return xx * xx * xx;
}

float inverse(float m) {
  return 1.0 / m;
}

float2x2 inverse(float2x2 m) {
  return float2x2(m[1][1],-m[0][1],
             -m[1][0], m[0][0]) / (m[0][0]*m[1][1] - m[0][1]*m[1][0]);
}

float3x3 inverse(float3x3 m) {
  float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
  float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
  float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

  float b01 = a22 * a11 - a12 * a21;
  float b11 = -a22 * a10 + a12 * a20;
  float b21 = a21 * a10 - a11 * a20;

  float det = a00 * b01 + a01 * b11 + a02 * b21;

  return float3x3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
              b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
              b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
}

float4x4 inverse(float4x4 m) {
  float
      a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3],
      a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3],
      a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3],
      a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3],

      b00 = a00 * a11 - a01 * a10,
      b01 = a00 * a12 - a02 * a10,
      b02 = a00 * a13 - a03 * a10,
      b03 = a01 * a12 - a02 * a11,
      b04 = a01 * a13 - a03 * a11,
      b05 = a02 * a13 - a03 * a12,
      b06 = a20 * a31 - a21 * a30,
      b07 = a20 * a32 - a22 * a30,
      b08 = a20 * a33 - a23 * a30,
      b09 = a21 * a32 - a22 * a31,
      b10 = a21 * a33 - a23 * a31,
      b11 = a22 * a33 - a23 * a32,

      det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

  return float4x4(
      a11 * b11 - a12 * b10 + a13 * b09,
      a02 * b10 - a01 * b11 - a03 * b09,
      a31 * b05 - a32 * b04 + a33 * b03,
      a22 * b04 - a21 * b05 - a23 * b03,
      a12 * b08 - a10 * b11 - a13 * b07,
      a00 * b11 - a02 * b08 + a03 * b07,
      a32 * b02 - a30 * b05 - a33 * b01,
      a20 * b05 - a22 * b02 + a23 * b01,
      a10 * b10 - a11 * b08 + a13 * b06,
      a01 * b08 - a00 * b10 - a03 * b06,
      a30 * b04 - a31 * b02 + a33 * b00,
      a21 * b02 - a20 * b04 - a23 * b00,
      a11 * b07 - a10 * b09 - a12 * b06,
      a00 * b09 - a01 * b07 + a02 * b06,
      a31 * b01 - a30 * b03 - a32 * b00,
      a20 * b03 - a21 * b01 + a22 * b00) / det;
}
$input v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 BloomParams1;
uniform vec4 BloomParams2;
uniform vec4 RenderMode;
uniform vec4 ScreenSize;

SAMPLER2D_AUTOREG(s_HDRi);
SAMPLER2D_AUTOREG(s_BlurPyramidTexture);
SAMPLER2D_AUTOREG(s_RasterColor);
SAMPLER2D_AUTOREG(s_DepthTexture);

float luminance(vec3 clr) {
return dot(clr, vec3(0.2126, 0.7152, 0.0722));
}

vec4 HighPass(vec4 col) {
float lum = luminance(col.rgb);
return vec4(col.rgb, lum);
}

vec4 HighPassDFDownsample(sampler2D srcImg, sampler2D depthImg, vec2 uv, vec2 pixelOffsets) {
vec4 col = vec4(0, 0, 0, 0);
col += 0.5 * HighPass(texture2D(srcImg, uv));
col += 0.125 * HighPass(texture2D(srcImg, uv + vec2(pixelOffsets.x, pixelOffsets.y)));
col += 0.125 * HighPass(texture2D(srcImg, uv + vec2(- pixelOffsets.x, pixelOffsets.y)));
col += 0.125 * HighPass(texture2D(srcImg, uv + vec2(pixelOffsets.x, - pixelOffsets.y)));
col += 0.125 * HighPass(texture2D(srcImg, uv + vec2(- pixelOffsets.x, - pixelOffsets.y)));
if(bool(BloomParams2.z)) {
float minRange = BloomParams2.x;
float maxRange = BloomParams2.y;
float depth = texture2D(depthImg, uv).r;
depth = ((depth * maxRange) - minRange) / (maxRange - minRange);
depth = clamp(depth, BloomParams1.z, 1.0);
col *= pow(depth, BloomParams1.y);
}
return col;
}

vec4 DualFilterDownsample(sampler2D srcImg, vec2 uv, vec2 pixelOffsets) {
vec4 col = vec4(0, 0, 0, 0);
col += 0.5 * texture2D(srcImg, uv);
col += 0.125 * texture2D(srcImg, uv + vec2(pixelOffsets.x, pixelOffsets.y));
col += 0.125 * texture2D(srcImg, uv + vec2(- pixelOffsets.x, pixelOffsets.y));
col += 0.125 * texture2D(srcImg, uv + vec2(pixelOffsets.x, - pixelOffsets.y));
col += 0.125 * texture2D(srcImg, uv + vec2(- pixelOffsets.x, - pixelOffsets.y));
return col;
}

vec4 DualFilterDownsampleWithDepthErosion(sampler2D srcImg, vec2 uv, vec2 pixelOffsets) {
vec4 col = vec4(0, 0, 0, 0);
vec4 a = texture2D(srcImg, uv);
vec4 b = texture2D(srcImg, uv + vec2(pixelOffsets.x, pixelOffsets.y));
vec4 c = texture2D(srcImg, uv + vec2(- pixelOffsets.x, pixelOffsets.y));
vec4 d = texture2D(srcImg, uv + vec2(pixelOffsets.x, - pixelOffsets.y));
vec4 e = texture2D(srcImg, uv + vec2(- pixelOffsets.x, - pixelOffsets.y));
col.rgb += 0.5 * a.rgb;
col.rgb += 0.125 * b.rgb;
col.rgb += 0.125 * c.rgb;
col.rgb += 0.125 * d.rgb;
col.rgb += 0.125 * e.rgb;
col.a = max(a.a, max(b.a, max(c.a, max(d.a, e.a))));
return col;
}

vec4 DualFilterUpsample(sampler2D srcImg, vec2 uv, vec2 pixelOffsets) {
vec4 col = vec4(0, 0, 0, 0);
col += 0.166 * texture2D(srcImg, uv + vec2(0.5 * pixelOffsets.x, 0.5 * pixelOffsets.y));
col += 0.166 * texture2D(srcImg, uv + vec2(- 0.5 * pixelOffsets.x, 0.5 * pixelOffsets.y));
col += 0.166 * texture2D(srcImg, uv + vec2(0.5 * pixelOffsets.x, - 0.5 * pixelOffsets.y));
col += 0.166 * texture2D(srcImg, uv + vec2(- 0.5 * pixelOffsets.x, - 0.5 * pixelOffsets.y));
col += 0.083 * texture2D(srcImg, uv + vec2(pixelOffsets.x, pixelOffsets.y));
col += 0.083 * texture2D(srcImg, uv + vec2(- pixelOffsets.x, pixelOffsets.y));
col += 0.083 * texture2D(srcImg, uv + vec2(pixelOffsets.x, - pixelOffsets.y));
col += 0.083 * texture2D(srcImg, uv + vec2(- pixelOffsets.x, - pixelOffsets.y));
return col;
}

vec4 BloomHighPass(vec2 texcoord0) {
float xOffset = 1.5 * abs(dFdx(texcoord0.x));
float yOffset = 1.5 * abs(dFdy(texcoord0.y));
vec2 uv = texcoord0;
return HighPassDFDownsample(s_HDRi, s_DepthTexture, uv, vec2(xOffset, yOffset));
}

vec4 DFDownSample(vec2 texcoord0) {
float xOffset = 1.5 * abs(dFdx(texcoord0.x));
float yOffset = 1.5 * abs(dFdy(texcoord0.y));
vec2 uv = texcoord0;
return DualFilterDownsample(s_BlurPyramidTexture, uv, vec2(xOffset, yOffset));
}

vec4 DFDownSampleWithDepthErosion(vec2 texcoord0) {
float xOffset = 1.5 * abs(dFdx(texcoord0.x));
float yOffset = 1.5 * abs(dFdy(texcoord0.y));
vec2 uv = texcoord0;
return DualFilterDownsampleWithDepthErosion(s_BlurPyramidTexture, uv, vec2(xOffset, yOffset));
}

vec4 DFUpSample(vec2 texcoord0) {
float xOffset = 4.0 * abs(dFdx(texcoord0.x));
float yOffset = 4.0 * abs(dFdy(texcoord0.y));
vec2 uv = texcoord0;
return DualFilterUpsample(s_BlurPyramidTexture, uv, vec2(xOffset, yOffset));
}

vec4 BloomBlend(vec2 texcoord0) {
float xOffset = 4.0 * abs(dFdx(texcoord0.x));
float yOffset = 4.0 * abs(dFdy(texcoord0.y));
vec2 uv = texcoord0;
vec4 bloom = DualFilterUpsample(s_BlurPyramidTexture, uv, vec2(xOffset, yOffset));
vec3 baseColor = texture2D(s_HDRi, uv).rgb;
float intensity = BloomParams1.x;
vec3 bloomedColor = baseColor + (intensity * bloom.rgb);
return vec4(bloomedColor, 1.0);
}

void main() {
#if BLOOM_HIGH_PASS
gl_FragColor = BloomHighPass(v_texcoord0);
#elif DFDOWN_SAMPLE
gl_FragColor = DFDownSample(v_texcoord0);
#elif DFDOWN_SAMPLE_WITH_DEPTH_EROSION
gl_FragColor = DFDownSampleWithDepthErosion(v_texcoord0);
#elif DFUP_SAMPLE
gl_FragColor = DFUpSample(v_texcoord0);
#elif BLOOM_BLEND
gl_FragColor = BloomBlend(v_texcoord0);
#endif
}

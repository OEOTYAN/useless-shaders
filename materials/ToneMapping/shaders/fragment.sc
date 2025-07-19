$input v_texcoord0

#include <bgfx_shader.sh>

uniform vec4 ExposureCompensation;
uniform vec4 LuminanceMinMax;
uniform vec4 RenderMode;
uniform vec4 ScreenSize;
uniform vec4 TonemapCorrection;
uniform vec4 TonemapParams0;

SAMPLER2D_AUTOREG(s_RasterColor);
SAMPLER2D_AUTOREG(s_ColorTexture);
SAMPLER2D_AUTOREG(s_AverageLuminance);
SAMPLER2D_AUTOREG(s_MaxLuminance);
SAMPLER2D_AUTOREG(s_RasterizedColor);
SAMPLER2D_AUTOREG(s_CustomExposureCompensation);

vec3 color_gamma(vec3 clr) {
float e = 1.0 / 2.2;
return pow(max(clr, vec3(0.0, 0.0, 0.0)), vec3(e, e, e));
}

vec4 color_gamma(vec4 clr) {
return vec4(color_gamma(clr.rgb), clr.a);
}

float luminance(vec3 clr) {
return dot(clr, vec3(0.2126, 0.7152, 0.0722));
}

float luminanceToEV100(float luminance) {
return log2(luminance) + 3.0;
}

vec3 TonemapReinhard(vec3 rgb, float W) {
vec3 color = rgb / (1.0 + rgb);
return color;
}

vec3 TonemapReinhardLuminance(vec3 rgb, float W) {
float l_old = luminance(rgb);
float l_new = (l_old * (1.0 + (l_old / W))) / (1.0 + l_old);
return rgb * (l_new / l_old);
}

vec3 TonemapReinhardJodie(vec3 rgb) {
float l = luminance(rgb);
vec3 tc = rgb / (1.0 + rgb);
return mix(rgb / (1.0 + l), tc, tc);
}

vec3 Uncharted2Tonemap(vec3 x) {
float A = 0.15;
float B = 0.50;
float C = 0.10;
float D = 0.20;
float E = 0.02;
float F = 0.30;
return ((x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F)) - E / F;
}

vec3 TonemapUncharted2(vec3 rgb, float W) {
const float ExposureBias = 2.0;
vec3 curr = Uncharted2Tonemap(ExposureBias * rgb);
vec3 whiteScale = 1.0 / Uncharted2Tonemap(vec3_splat(W));
return curr * whiteScale;
}

vec3 RRTAndODTFit(vec3 v) {
vec3 a = v * (v + 0.0245786) - 0.000090537;
vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
return a / b;
}

vec3 ACESFitted(vec3 rgb) {
const mat3 ACESInputMat = mat3(0.59719, 0.35458, 0.04823, 0.07600, 0.90834, 0.01566, 0.02840, 0.13383, 0.83777);
const mat3 ACESOutputMat = mat3(1.60475, - 0.53108, - 0.07367, - 0.10208, 1.10813, - 0.00605, - 0.00327, - 0.07276, 1.07602);
rgb = mul(ACESInputMat, rgb);
rgb = RRTAndODTFit(rgb);
rgb = mul(ACESOutputMat, rgb);
rgb = clamp(rgb, 0.0, 1.0);
return rgb;
}

vec3 TonemapACES(vec3 rgb) {
return ACESFitted(rgb);
}

vec3 TonemapColorCorrection(vec3 rgb, float luminance, float brightness, float contrast, float saturation) {
rgb = (rgb - 0.5) * contrast + 0.5 + brightness;
return mix(vec3_splat(luminance), rgb, max(0.0, saturation));
}

vec3 ApplyTonemap(vec3 sceneColor, float averageLuminance, float brightness, float contrast, float saturation, float compensation, float whitePoint, int tonemapper) {
float exposure = (0.18 / averageLuminance) * compensation;
sceneColor *= exposure;
float scaledWhitePoint = exposure * whitePoint;
float whitePointSquared = scaledWhitePoint * scaledWhitePoint;
if(tonemapper == 1) {
sceneColor = TonemapReinhardLuminance(sceneColor, whitePointSquared);
} else if(tonemapper == 2) {
sceneColor = TonemapReinhardJodie(sceneColor);
} else if(tonemapper == 3) {
sceneColor = TonemapUncharted2(sceneColor, whitePointSquared);
} else if(tonemapper == 4) {
sceneColor = TonemapACES(sceneColor);
} else {
sceneColor = TonemapReinhard(sceneColor, whitePointSquared);
}
float finalLuminance = luminance(sceneColor);
sceneColor = color_gamma(sceneColor);
return TonemapColorCorrection(sceneColor, finalLuminance, brightness, contrast, saturation);
}

void main() {
vec3 sceneColor = texture2D(s_ColorTexture, v_texcoord0.xy).rgb;
vec3 finalColor = sceneColor;
if(TonemapParams0.y <= 0.5) {
finalColor.rgb = color_gamma(sceneColor.rgb);
} else {
float averageLuminance = clamp(texture2D(s_AverageLuminance, vec2(0.5, 0.5)).r, LuminanceMinMax.x, LuminanceMinMax.y);
float compensation = ExposureCompensation.y;
int exposureCurveType = int(ExposureCompensation.x);
if(exposureCurveType > 0 && exposureCurveType < 2) {
compensation = 1.03 - 2.0 / ((1.0 / log(10.0)) * log(averageLuminance + 1.0) + 2.0);
} else if(exposureCurveType > 1) {
vec2 uv = vec2(LuminanceMinMax.x == LuminanceMinMax.y ? 0.5 : (luminanceToEV100(averageLuminance) - luminanceToEV100(LuminanceMinMax.x)) / (luminanceToEV100(LuminanceMinMax.y) - luminanceToEV100(LuminanceMinMax.x)), 0.5);
compensation = texture2D(s_CustomExposureCompensation, uv).r;
}
float whitePoint = texture2D(s_MaxLuminance, vec2(0.5, 0.5)).r;
whitePoint = whitePoint < TonemapCorrection.w ? TonemapCorrection.w : whitePoint;
finalColor.rgb = ApplyTonemap(sceneColor, averageLuminance, TonemapCorrection.x, TonemapCorrection.y, TonemapCorrection.z, compensation, whitePoint, int(TonemapParams0.x));
}
finalColor.rgb = clamp(finalColor.rgb, vec3(0.0, 0.0, 0.0), vec3(1.0, 1.0, 1.0));
vec4 rasterized = texture2D(s_RasterizedColor, v_texcoord0);
finalColor.rgb *= 1.0 - rasterized.a;
finalColor.rgb += rasterized.rgb;

gl_FragColor = vec4(finalColor.rgb, 1.0);
}

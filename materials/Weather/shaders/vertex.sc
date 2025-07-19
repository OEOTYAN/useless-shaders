$input a_position, a_color0, a_texcoord0
$output v_texcoord0, v_fog, v_occlusionHeight, v_occlusionUV

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

uniform vec4 FogColor;
uniform vec4 FogAndDistanceControl;
uniform vec4 Velocity;
uniform vec4 Dimensions;
uniform vec4 ViewPosition;
uniform vec4 UVOffsetAndScale;
uniform vec4 PositionForwardOffset;
uniform vec4 PositionBaseOffset;

#if BGFX_SHADER_LANGUAGE_GLSL
    #if BGFX_SHADER_LANGUAGE_GLSL < 130
float trunc(float _x) {
    return float(int(_x));
}
    #endif // BGFX_SHADER_LANGUAGE_GLSL < 130
float fmod(float _a, float _b) {
    return _a - _b * trunc(_a / _b);
}
vec2 fmod(vec2 _a, vec2 _b) {
    return vec2(fmod(_a.x, _b.x), fmod(_a.y, _b.y));
}
vec3 fmod(vec3 _a, vec3 _b) {
    return vec3(fmod(_a.x, _b.x), fmod(_a.y, _b.y), fmod(_a.z, _b.z));
}
vec4 fmod(vec4 _a, vec4 _b) {
    return vec4(fmod(_a.x, _b.x), fmod(_a.y, _b.y), fmod(_a.z, _b.z), fmod(_a.w, _b.w));
}
#endif // BGFX_SHADER_LANGUAGE_GLSL

void main() {
    float spriteSelector = a_color0.x * 255.0;

    vec2 texcoord0 = UVOffsetAndScale.xy + (a_texcoord0 * UVOffsetAndScale.zw);
#if !NO_VARIETY
    texcoord0.x += spriteSelector * UVOffsetAndScale.z;
#endif

    const float PARTICLE_BOX_DIMENSIONS = 30.0;
    const vec3 PARTICLE_BOX = vec3(PARTICLE_BOX_DIMENSIONS, PARTICLE_BOX_DIMENSIONS, PARTICLE_BOX_DIMENSIONS);

    // subtract the offset then fmod into (0.0f, PARTICLE_BOX)
    vec3 worldSpacePosition = fmod(a_position + PositionBaseOffset.xyz, PARTICLE_BOX);

    // centre box on origin
    worldSpacePosition -= PARTICLE_BOX * 0.5;

    // push along view vector so box is positioned more infront of camera
    worldSpacePosition += PositionForwardOffset.xyz;

    // get world position
    vec3 worldSpacePositionBottom = worldSpacePosition;
    vec3 worldSpacePositionTop = worldSpacePositionBottom + (Velocity.xyz * Dimensions.y);

    // get projected positions of top and bottom of particle, and top of particle in previous frame
    vec4 screenSpacePositionBottom = mul(u_modelViewProj, vec4(worldSpacePositionBottom, 1.0));
    vec4 screenSpacePositionTop = mul(u_modelViewProj, vec4(worldSpacePositionTop, 1.0));

    // get 2d vector in screenspace between top and bottom of particle
    vec2 screenSpaceUpDirection = (screenSpacePositionTop.xy / screenSpacePositionTop.w) - (screenSpacePositionBottom.xy / screenSpacePositionBottom.w);

    // get 2d vector perpendicular to velocity
    vec2 screenSpaceRightDirection = normalize(vec2(-screenSpaceUpDirection.y, screenSpaceUpDirection.x));

    // choose either the top or bottom projected position using uv.y
    vec4 position = mix(screenSpacePositionTop, screenSpacePositionBottom, a_texcoord0.y);

    // offset the position of each side of the particle using uv.x
    position.xy += (0.5 - a_texcoord0.x) * screenSpaceRightDirection * Dimensions.x;

    vec2 occlusionUV = worldSpacePosition.xz;
    occlusionUV += ViewPosition.xz;
    occlusionUV *= 1.0 / 64.0; // Scale by 1/TextureDimensions to get values between
    occlusionUV += 0.5;        // Offset so that center of view is in the center of occlusion texture

    float occlusionHeight = worldSpacePosition.y;
    occlusionHeight += ViewPosition.y - 0.5;
    occlusionHeight *= 1.0 / 255.0;

    //fog
    float fogIntensity = calculateFogIntensity(position.z, FogAndDistanceControl.z, FogAndDistanceControl.x, FogAndDistanceControl.y);
    vec4 fog = vec4(FogColor.rgb, fogIntensity);

    v_texcoord0 = texcoord0;
    v_fog = fog;
    v_occlusionHeight = occlusionHeight;
    v_occlusionUV = occlusionUV;
    gl_Position = position;
}

$input v_color0, v_fog, v_light, v_texcoord0, v_layerUv

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/ActorUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>
#include <MinecraftRenderer.Materials/GlintUtil.dragonh>

uniform vec4 ColorBased;
uniform vec4 ChangeColor;
uniform vec4 UseAlphaRewrite;
uniform vec4 TintedAlphaTestEnabled;
uniform vec4 MatColor;
uniform vec4 OverlayColor;
uniform vec4 TileLightColor;
uniform vec4 MultiplicativeTintColor;
uniform vec4 FogColor;
uniform vec4 FogControl;
uniform vec4 ActorFPEpsilon;
uniform vec4 LightDiffuseColorAndIlluminance;
uniform vec4 LightWorldSpaceDirection;
uniform vec4 HudOpacity;
uniform vec4 UVAnimation;
uniform mat4 Bones[8];
uniform vec4 UVScale;
uniform vec4 GlintColor;

SAMPLER2D(s_MatTexture, 0);
SAMPLER2D(s_MatTexture1, 1);

void main() {
    #if DEPTH_ONLY
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    #elif DEPTH_ONLY_OPAQUE
        gl_FragColor = vec4(applyFog(vec3(1.0, 1.0, 1.0), v_fog.rgb, v_fog.a), 1.0);
        return;
    #endif

    vec4 albedo = getActorAlbedoNoColorChange(v_texcoord0, s_MatTexture, s_MatTexture1, MatColor);

    #if ALPHA_TEST
        float alpha = mix(albedo.a, (albedo.a * OverlayColor.a), TintedAlphaTestEnabled.x);
        if(shouldDiscard(albedo.rgb, alpha, ActorFPEpsilon.x))
            discard;
    #endif // ALPHA_TEST

    #if CHANGE_COLOR_MULTI
        albedo = applyMultiColorChange(albedo, ChangeColor.rgb, MultiplicativeTintColor.rgb);
    #elif CHANGE_COLOR
        albedo = applyColorChange(albedo, ChangeColor, albedo.a);
        albedo.a *= ChangeColor.a;
    #endif // CHANGE_COLOR_MULTI

    #if ALPHA_TEST
        albedo.a = max(UseAlphaRewrite.r, albedo.a);
    #endif

    albedo = applyActorDiffuse(albedo, v_color0.rgb, v_light, ColorBased.x, OverlayColor);
    albedo = applyGlint(albedo, v_layerUv, s_MatTexture1, GlintColor, TileLightColor);

    #if TRANSPARENT
        albedo = applyHudOpacity(albedo, HudOpacity.x);
    #endif

    albedo.rgb = applyFog(albedo.rgb, v_fog.rgb, v_fog.a);
    
    gl_FragColor = albedo;
}

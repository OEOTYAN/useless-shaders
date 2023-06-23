//Not yet completed, may have some issues

$input v_color0, v_fog, v_light, v_texcoord0, v_texcoords

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/ActorUtil.dragonh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

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
uniform vec4 BannerColors[7];
uniform vec4 BannerUVOffsetsAndScales[7];

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

    #if !ALPHA_TEST
    	vec4 diffuse = texture2D(s_MatTexture, v_texcoords.xy);
	    vec4 base = texture2D(s_MatTexture, v_texcoords.zw);

        #if TINTING
	        base.a = mix(diffuse.r * diffuse.a, diffuse.a, v_color0.a);
	        base.rgb *= v_color0.rgb;
        #endif

        base = applyLighting(base, v_light);
        base = applyHudOpacity(base, HudOpacity.x);
        base.rgb = applyFog(base.rgb, v_fog.rgb, v_fog.a);

	    gl_FragColor = base;
    #else
        vec4 albedo = getActorAlbedoNoColorChange(v_texcoord0, s_MatTexture, s_MatTexture1, MatColor);

        float alpha = mix(albedo.a, (albedo.a * OverlayColor.a), TintedAlphaTestEnabled.x);
        if(shouldDiscard(albedo.rgb, alpha, ActorFPEpsilon.x))
            discard;

        #if CHANGE_COLOR_MULTI
            albedo = applyMultiColorChange(albedo, ChangeColor.rgb, MultiplicativeTintColor.rgb);
        #elif CHANGE_COLOR
            albedo = applyColorChange(albedo, ChangeColor, albedo.a);
            albedo.a *= ChangeColor.a;
        #endif // CHANGE_COLOR_MULTI

        albedo.a = max(UseAlphaRewrite.r, albedo.a);
        albedo = applyActorDiffuse(albedo, v_color0.rgb, v_light, ColorBased.x, OverlayColor);
        albedo = applyHudOpacity(albedo, HudOpacity.x);
        albedo.rgb = applyFog(albedo.rgb, v_fog.rgb, v_fog.a);
        gl_FragColor = albedo;
    #endif // !ALPHA_TEST
}

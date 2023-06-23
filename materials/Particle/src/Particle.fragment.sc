$input v_color0, v_fog, v_texcoord0

#include <bgfx_shader.sh>
#include <MinecraftRenderer.Materials/FogUtil.dragonh>

SAMPLER2D(s_ParticleTexture, 0);

void main() {
    vec4 diffuse = texture2D(s_ParticleTexture, v_texcoord0);
    #if ALPHA_TEST
        if (diffuse.w < 0.5) {
            discard;
        }
    #endif
    
    diffuse *= v_color0;
    diffuse.rgb = applyFog(diffuse.rgb, v_fog.rgb, v_fog.a);

    #if ALPHA_TEST
        diffuse.a = 1.0;
    #endif

    gl_FragColor = diffuse;
}


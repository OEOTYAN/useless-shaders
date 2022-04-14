#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input {
    float4 position : SV_Position;
    float3 worldPos : worldPos;
    float3 chunkPos : chunkPos;
    float3 tangent : tan;
    float3 bitangent : bitan;
    float3 normal : nor;
    float ismap : ismap;
#ifndef BYPASS_PIXEL_SHADER
    lpfloat4 color : COLOR;
     float4 uvm : uvm;
     float2 uv0 : TEXCOORD_0_FB_MSAA;
     float2 uv1 : TEXCOORD_1_FB_MSAA;
#endif

#ifdef FOG
    float4 fogColor : FOG_COLOR;
#endif
};

struct PS_Output {
    float4 color : SV_Target;
};

static const float AMBIENT = 0.5 - 1 / 512.0;

static const float XFAC = -0.15 + 1.0 / 1024;
static const float ZFAC = 0.05 + 1.0 / 1024;

float lightIntensity(const float3 normal) {
    float3 N = normal.xyz;

    float yLight = (1.0 + N.y) * 0.5;
    return yLight * (1.0 - AMBIENT) + N.x * N.x * XFAC + N.z * N.z * ZFAC +
           AMBIENT;
}

float InterleavedGradientNoise( float2 uv, float FrameId )
{
	// magic values are found by experimentation
	uv += FrameId * (float2(47, 17) * 0.695f);

    const float3 magic = float3( 0.06711056f, 0.00583715f, 52.9829189f );
    return frac(magic.z * frac(dot(uv, magic.xy)));
}

ROOT_SIGNATURE

void main(in PS_Input PSInput, out PS_Output PSOutput) {
    const float DP[64] = {1,  49, 13, 61, 4,  52, 16, 64, 33, 17, 45, 29, 36,
                          20, 48, 32, 9,  57, 5,  53, 12, 60, 8,  56, 41, 25,
                          37, 21, 44, 28, 40, 24, 3,  51, 15, 63, 2,  50, 14,
                          62, 35, 19, 47, 31, 34, 18, 46, 30, 11, 59, 7,  55,
                          10, 58, 6,  54, 43, 27, 39, 23, 42, 26, 38, 22};

#ifdef BYPASS_PIXEL_SHADER
    PSOutput.color = float4(0.0f, 0.0f, 0.0f, 0.0f);
    return;
#else

    // float3x3 TBN = float3x3(PSInput.tangent, PSInput.bitangent, PSInput.normal);
    // float3x3 inverseTBN = transpose(TBN);

    float2 uv0dx = ddx(PSInput.uv0);
    float2 uv0dy = ddy(PSInput.uv0);
    float2 rands;
    rands.x=InterleavedGradientNoise(PSInput.position.xy,TIME);
    rands.y=InterleavedGradientNoise(PSInput.position.xy,TIME+5371.5371);
    rands*=1.01;
#if USE_TEXEL_AA
    float3 sum=float3(0,0,0);
    float weight=0;
     for (int uv0i = 0; uv0i < TEXTURE_MSAA; uv0i++)
         for (int uv0j = 0; uv0j < TEXTURE_MSAA; uv0j++){
             float2 iter;
             iter.x=(uv0i) / (float)(TEXTURE_MSAA);
             iter.y=(uv0j) / (float)(TEXTURE_MSAA);
             float2 luv0 =
                 PSInput.uvm.zw*ftri((PSInput.uv0 + uv0dx *iter.x  + uv0dy * iter.y-PSInput.uvm.xy)/PSInput.uvm.zw);
        float4 tmpcolor=texture2Dlod_AA(TEXTURE_0, TextureSampler0,luv0+PSInput.uvm.xy,0);

        weight+=tmpcolor.a;
// #if USE_ALPHA_TEST
        // sum+=pow(tmpcolor.rgb,2.2);
	// #else
        sum+=tmpcolor.a*pow(tmpcolor.rgb,2.2);
	// #endif
    }
    float4 diffuse = float4(pow(sum/weight,1.0/2.2),weight/ (float)(TEXTURE_MSAA*TEXTURE_MSAA));
#else
    float4 diffuse = TEXTURE_0.SampleLevel(TextureSampler0,PSInput.uvm.xy+PSInput.uvm.zw*ftri((PSInput.uv0-PSInput.uvm.xy+uv0dx*rands.x+uv0dy*rands.y)/PSInput.uvm.zw),0);
#endif

#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
	if(diffuse.a< ALPHA_THRESHOLD)
		discard;
    //if((diffuse.a-abs(ddx(diffuse.a))< ALPHA_THRESHOLD)||(diffuse.a-abs(ddy(diffuse.a))< ALPHA_THRESHOLD)){
     //alpha test edge
     
        //if(texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv0).a< ALPHA_THRESHOLD)
		//discard;
        //diffuse.rgb=1;
   // }
#endif

/* if (PSInput.ismap < 0.5) {
// alpha test bug fixed
#if USE_ALPHA_TEST
	#ifdef ALPHA_TO_COVERAGE
		#define ALPHA_THRESHOLD 0.05
	#else
		#define ALPHA_THRESHOLD 0.5
	#endif
#if USE_TEXEL_AA

        float2 originalUV = PSInput.uv0;

        float2 dUV_dX = ddx(originalUV) * TEXTURE_DIMENSIONS.xy;
        float2 dUV_dY = ddy(originalUV) * TEXTURE_DIMENSIONS.xy;

        float2 delU = float2(dUV_dX.x, dUV_dY.x);
        float2 delV = float2(dUV_dX.y, dUV_dY.y);
        float2 adjustmentScalar =
            max(1.0f / float2(length(delU), length(delV)), 1.0f);
        float2 fractionalTexel = frac(originalUV * TEXTURE_DIMENSIONS.xy);
        float2 adjustedFractionalTexel =
            clamp(fractionalTexel * adjustmentScalar, 0.0f, 0.5f) +
            clamp(
                fractionalTexel * adjustmentScalar - (adjustmentScalar - 0.5f),
                0.0f, 0.5f);

        float2 adjustedUV = (adjustedFractionalTexel +
                             floor(originalUV * TEXTURE_DIMENSIONS.xy)) /
                            TEXTURE_DIMENSIONS.xy;

        float alphacurrect =
            TEXTURE_0.SampleLevel(TextureSampler0, adjustedUV, 0).a;
        alphacurrect = lerp(diffuse.a, alphacurrect,
                            saturate(length(PSInput.worldPos) / 8.0 - 1));
#else
        float alphacurrect =
            TEXTURE_0.SampleLevel(TextureSampler0, PSInput.uv0, 0).a;
#endif
#ifndef SEASONS
        if (!(PSInput.color.r + PSInput.color.g + PSInput.color.b < 2.9 &&
              PSInput.color.r * 1.5 < PSInput.color.b)) {
            float2 count0;
            float2 scrpos0 = PSInput.position.xy;
            count0.x = floor(fmod(scrpos0.x, 8.0f));
            count0.y = floor(fmod(scrpos0.y, 8.0f));

            int dither0 = (int)count0.x + (int)count0.y * 8;

            float pattern0 = DP[dither0];
            if ((pattern0 / 64.0f) > alphacurrect) {
                discard;
            } else {
                diffuse =
                    texture2Dat_AA(TEXTURE_0, TextureSampler0, PSInput.uv0);
            }
        }
#endif
#endif
    }*/

#if defined(BLEND)
    diffuse.a *= PSInput.color.a;
#endif


#if !defined(ALWAYS_LIT)
float3 mlight=TEXTURE_1.Sample(TextureSampler1, PSInput.uv1).rgb;
    diffuse = diffuse * TEXTURE_1.Sample(TextureSampler1, PSInput.uv1);
    #else 
    float3 mlight=1.0;
#endif

    float iswater = 0.0;
#ifndef SEASONS
#if !USE_ALPHA_TEST && !defined(BLEND)
    diffuse.a = PSInput.color.a;
#endif
    if ((PSInput.color.r + PSInput.color.g + PSInput.color.b < 2.9 &&
         PSInput.color.r * 1.5 < PSInput.color.b)) {
        iswater = 1.0;
    }
    diffuse.rgb *= PSInput.color.rgb;
#else
    float2 uv = PSInput.color.xy;
    diffuse.rgb *= lerp(1.0f, TEXTURE_2.Sample(TextureSampler2, uv).rgb * 2.0f,
                        PSInput.color.b);
    diffuse.rgb *= PSInput.color.aaa;
    diffuse.a = 1.0f;
#endif
#ifndef AS_ENTITY_RENDERER /*                             \
     float2 px = TEXTURE_DIMENSIONS.x * ddx(PSInput.uv0); \
     float2 py = TEXTURE_DIMENSIONS.y * ddx(PSInput.uv0); \
     float lod = max(0.5 * log2(max(dot(px, px), dot(py, py))),0);*/
    float3 cp = frac(PSInput.chunkPos);
    float3 ch = PSInput.worldPos;
    float3 chw = fwidth(ch);
    float3 chdx = ddx_fine(ch);
    float3 chdy = ddy_fine(ch);
    // float3 linea = max(chw/2,0.0625);//0.0625
    // float3 lineb = max(chw/2,0.0625 / 2.0);//0.0625 / 2.0
    float3 linea = 0.0626;        // 0.0625
    float3 lineb = 0.0627 / 2.0;  // 0.0625 / 2.0
    int ckk = 1;
    if (((PSInput.chunkPos.x < linea.x + chw.x ||
          PSInput.chunkPos.x > 16.0 - linea.x - chw.x) ||
         (PSInput.chunkPos.z < linea.z + chw.z ||
          PSInput.chunkPos.z > 16.0 - linea.z - chw.z)) &&
        (((cp.x < lineb.x + chw.x || cp.x > 1.0 - lineb.x - chw.x) &&
          (cp.y < lineb.y + chw.y || cp.y > 1.0 - lineb.y - chw.y)) ||
         ((cp.x < lineb.x + chw.x || cp.x > 1.0 - lineb.x - chw.x) &&
          (cp.z < lineb.z + chw.z || cp.z > 1.0 - lineb.z - chw.z)) ||
         ((cp.y < lineb.y + chw.y || cp.y > 1.0 - lineb.y - chw.y) &&
          (cp.z < lineb.z + chw.z || cp.z > 1.0 - lineb.z - chw.z))))
        ckk = CHUNK_BOARD_MSAA;
    int l1 = 0;
    int l2 = 0;
    int lrrr = 0;
    for (int ci = 0; ci < ckk; ci++)
        for (int cj = 0; cj < ckk; cj++) {
            float3 lchunkPos = frac((PSInput.chunkPos + chdx * ci / (float)ckk +
                                     chdy * cj / (float)ckk) /
                                    16.0) *
                               16.0;
            float3 lcp =
                frac(cp + chdx * ci / (float)ckk + chdy * cj / (float)ckk);

            if (((lchunkPos.x < linea.x || lchunkPos.x > 16.0 - linea.x) &&
                 (lchunkPos.y < linea.y || lchunkPos.y > 16.0 - linea.y)) ||
                ((lchunkPos.x < linea.x || lchunkPos.x > 16.0 - linea.x) &&
                 (lchunkPos.z < linea.z || lchunkPos.z > 16.0 - linea.z)) ||
                ((lchunkPos.y < linea.y || lchunkPos.y > 16.0 - linea.y) &&
                 (lchunkPos.z < linea.z || lchunkPos.z > 16.0 - linea.z)))
                l1 += 1;
            else if (((lchunkPos.x < lineb.x || lchunkPos.x > 16.0 - lineb.x) ||
                      (lchunkPos.z < lineb.z ||
                       lchunkPos.z > 16.0 - lineb.z)) &&
                     (((lcp.x < lineb.x || lcp.x > 1.0 - lineb.x) &&
                       (lcp.y < lineb.y || lcp.y > 1.0 - lineb.y)) ||
                      ((lcp.x < lineb.x || lcp.x > 1.0 - lineb.x) &&
                       (lcp.z < lineb.z || lcp.z > 1.0 - lineb.z)) ||
                      ((lcp.y < lineb.y || lcp.y > 1.0 - lineb.y) &&
                       (lcp.z < lineb.z || lcp.z > 1.0 - lineb.z))))
                l2 += 1;
            else
                lrrr += 1;
        }
    float weightq = ckk;
    weightq = 1.0 / weightq / weightq;
    diffuse.rgb =
        diffuse.rgb * lrrr * weightq +
        (lerp(diffuse.rgb, float3(0.0f, 0.0f, 1.0f), 0.2f) * weightq * l1 +
         (diffuse.rgb / 0.4f) * (float3(1.0f, 1.0f, 1.0f) - diffuse.rgb) *
             weightq * l2);
    // diffuse.rgb=diffuse.rgb*lrrr*weightq+(lerp(diffuse.rgb,lerp(diffuse.rgb,
    // float3(0.0f, 0.0f, 1.0f),
    // 0.2f),saturate(0.0625/length(linea)))*weightq*l1+(diffuse.rgb / 0.4f) *
    // lerp(diffuse.rgb,(float3(1.0f, 1.0f, 1.0f) -
    // diffuse.rgb),saturate(0.0625/2/length(lineb)))*weightq*l2);

    cp.x = cp.x * 3.0 - 1.1;
    cp.z = cp.z * 3.0 - 1.1;

    float3 normal =
        normalize(-cross(ddx(PSInput.worldPos), ddy(PSInput.worldPos)));
    bool isRedstoneDust = false;
#ifndef S_FAR
    if (normal.y > 0.99 && abs(normal.x) + abs(normal.z) < 0.01 &&
        PSInput.ismap < 0.5) {
        /*
                float X=frac((PSInput.chunkPos.z+30*TIME)/60)*60;
                    float linew=0.02*(pow(X,0.2)*exp2(-0.1*X)+0.15*X/(1+X));
                if (abs(PSInput.chunkPos.x- 8) <linew){
                    diffuse.rgb=float3(252,123,83)/255;
                }

                    diffuse.rgb=lerp(diffuse.rgb,float3(235,90,85)/255,((40-X)/40)*0.3*(1-smoothstep(0,2*(pow(linew/0.02,7)*0.02+0.06),abs(PSInput.chunkPos.x-
           8))));

                diffuse.rgb=lerp(diffuse.rgb,float3(235,90,85)/255,0.5*(1-smoothstep(0.01,2*(linew)+0.03,abs(PSInput.chunkPos.x-
           8))));
        */

        // redstone dust
        if (PSInput.color.r > 0.999 && PSInput.color.g > 50.0 / 255.0 - 0.001 &&
            PSInput.color.g < 50.0 / 255.0 + 0.001 && PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(15.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 244.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 244.0 / 255.0 + 0.001 &&
                   PSInput.color.g > 27.0 / 255.0 - 0.001 &&
                   PSInput.color.g < 27.0 / 255.0 + 0.001 &&
                   PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(14.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 234.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 234.0 / 255.0 + 0.001 &&
                   PSInput.color.g > 6.0 / 255.0 - 0.001 &&
                   PSInput.color.g < 6.0 / 255.0 + 0.001 &&
                   PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(13.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 224.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 224.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(12.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 && cp.z >= 0.45) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.45) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 214.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 214.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(11.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 204.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 204.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(10.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 && cp.z >= 0.25) ||
                (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 && cp.z >= 0.35) ||
                (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 && cp.z >= 0.25) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 && cp.z >= 0.65) ||
                (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 && cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 193.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 193.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(9.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.35) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 183.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 183.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(8.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 173.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 173.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(7.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 &&
                 cp.z >= 0.55)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 163.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 163.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(6.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.35) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 153.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 153.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(5.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 142.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 142.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(4.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 132.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 132.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(3.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 122.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 122.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(2.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.45) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 112.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 112.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (floor(1.0 / exp2(floor((4 / 0.6) * (cp.x - 0.1)))) % 2 >=
                     0.5 &&
                 cp.z <= 0.15 && cp.z >= 0.1) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.35) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        } else if (PSInput.color.r > 76.0 / 255.0 - 0.001 &&
                   PSInput.color.r < 76.0 / 255.0 + 0.001 &&
                   PSInput.color.g + PSInput.color.b < 0.001) {
            if ((cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.08 && cp.z >= 0.05) ||
                (cp.x <= 0.7 && cp.x >= 0.1 && cp.z <= 0.2 && cp.z >= 0.17) ||
                (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.25) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                 cp.z >= 0.65) ||
                (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                 cp.z >= 0.25)) {
                diffuse.rgb =
                    float3(1.0f, 1.0f, 1.0f) *
                mlight;
            }
            isRedstoneDust = true;
        }

#ifdef LIGHT_OVERLAY
        if (isRedstoneDust == false) {
            cp.x = cp.x - 0.13;
            // x
            if (PSInput.uv1.x == 0) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0 && PSInput.uv1.x <= 0.125) {
                if ((cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.125 && PSInput.uv1.x <= 0.1875) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.1875 && PSInput.uv1.x <= 0.25) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.25 && PSInput.uv1.x <= 0.3125) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.3125 && PSInput.uv1.x <= 0.375) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.375 && PSInput.uv1.x <= 0.4375) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.4375 && PSInput.uv1.x <= 0.5) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 &&
                     cp.z >= 0.55)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.x > 0.5 && PSInput.uv1.x <= 0.5625) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.5625 && PSInput.uv1.x <= 0.625) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.625 && PSInput.uv1.x <= 0.6875) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.6875 && PSInput.uv1.x <= 0.75) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.75 && PSInput.uv1.x <= 0.8125) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.8125 && PSInput.uv1.x <= 0.875) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.875 && PSInput.uv1.x <= 0.9375) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.x > 0.9375) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            }

            cp.x = cp.x * 2 + 0.55;
            cp.z = cp.z * 2 - 0.25;
            // y
            if (PSInput.uv1.y == 0) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0 && PSInput.uv1.y <= 0.125) {
                if ((cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.125 && PSInput.uv1.y <= 0.1875) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.1875 && PSInput.uv1.y <= 0.25) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.25 && PSInput.uv1.y <= 0.3125) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.3125 && PSInput.uv1.y <= 0.375) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.375 && PSInput.uv1.y <= 0.4375) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.4375 && PSInput.uv1.y <= 0.5) {
                if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 &&
                     cp.z >= 0.55)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(1.0, 0.0, 0.0, 1.0), 0.3);
                }
            } else if (PSInput.uv1.y > 0.5 && PSInput.uv1.y <= 0.5625) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.5625 && PSInput.uv1.y <= 0.625) {
                if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.625 && PSInput.uv1.y <= 0.6875) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.6875 && PSInput.uv1.y <= 0.75) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 && cp.x >= 0.1 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.75 && PSInput.uv1.y <= 0.8125) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.8125 && PSInput.uv1.y <= 0.875) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.75 &&
                     cp.z >= 0.65)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.875 && PSInput.uv1.y <= 0.9375) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            } else if (PSInput.uv1.y > 0.9375) {
                if ((cp.x <= 0.7 && cp.x >= 0.4 && cp.z <= 0.35 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.6 && cp.x >= 0.5 && cp.z <= 0.75 &&
                     cp.z >= 0.35) ||
                    (cp.x <= 0.7 && cp.x >= 0.6 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.3 && cp.x >= 0.2 && cp.z <= 0.55 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.2 && cp.x >= 0.1 && cp.z <= 0.55 &&
                     cp.z >= 0.25) ||
                    (cp.x <= 0.4 && cp.x >= 0.3 && cp.z <= 0.75 &&
                     cp.z >= 0.45) ||
                    (cp.x <= 0.3 && cp.x >= 0.1 && cp.z <= 0.75 &&
                     cp.z >= 0.65) ||
                    (cp.x <= 0.4 && cp.x >= 0.2 && cp.z <= 0.35 &&
                     cp.z >= 0.25)) {
                    diffuse.rgba =
                        lerp(diffuse.rgba, float4(0.0, 1.0, 0.0, 1.5), 0.15);
                }
            }
        }
#endif
    }
#endif
#endif

#ifdef FOG
    diffuse.rgb = lerp(diffuse.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a);
#endif
#ifdef FUCK
    diffuse.rgba = diffuse.a;
#endif
    /*

        const float DP[64] = {1,  49, 13, 61, 4,  52, 16, 64, 33, 17, 45, 29,
    36, 20, 48, 32, 9,  57, 5,  53, 12, 60, 8,  56, 41, 25, 37, 21, 44, 28, 40,
    24, 3,  51, 15, 63, 2,  50, 14, 62, 35, 19, 47, 31, 34, 18, 46, 30, 11, 59,
    7,  55, 10, 58, 6,  54, 43, 27, 39, 23, 42, 26, 38, 22}; float2 count;
        float2 scrpos = PSInput.position.xy;
        count.x = floor(fmod(scrpos.x, 8.0f));
        count.y = floor(fmod(scrpos.y, 8.0f));

        int dither = (int)count.x + (int)count.y * 8;

        float pattern = DP[dither];
        if (diffuse.a < 0.95 && iswater > 0.5)
        if((length(PSInput.worldPos)+8)/FAR_CHUNKS_DISTANCE>1)
        {
                #ifndef S_FAR
            if (((pattern) / 64.0f) < pow(TEXTURE_0.Sample(TextureSampler0,
    PSInput.uv0).a-0.03, 2.2)) #else if (((pattern) / 64.0f) <
    pow(diffuse.a-0.03, 2.2)) #endif discard; #ifndef S_FAR else diffuse.a = 1;
    #endif
    }else
    if((abs((length(PSInput.worldPos)+8)/FAR_CHUNKS_DISTANCE-1+WATER_MIX/2.0)<WATER_MIX/2.0)){
        float kl=4.5;
            if (((pattern) / 64.0) <
    pow(lerp(0.02,pow(TEXTURE_0.Sample(TextureSampler0,
    PSInput.uv0).a-0.03,2.2*kl),((length(PSInput.worldPos)+8)/FAR_CHUNKS_DISTANCE-1+WATER_MIX)/WATER_MIX),
    1/kl)) discard; else diffuse.a =
    pow(lerp(diffuse.a,1,((length(PSInput.worldPos)+8)/FAR_CHUNKS_DISTANCE-1+WATER_MIX)/WATER_MIX),0.7);

    }
    */

#ifdef S_FAR

    float2 count;
    float2 scrpos = PSInput.position.xy;
    count.x = floor(fmod(scrpos.x, 8.0f));
    count.y = floor(fmod(scrpos.y, 8.0f));

    int dither = (int)count.x + (int)count.y * 8;

    float pattern = DP[dither];
    if (diffuse.a < 0.95 && iswater > 0.5)
        if (((pattern) / 64.0f) < pow(diffuse.a - 0.03, 2.2))
            discard;
#endif

#ifdef SEASONS_FAR
    diffuse.a = 1.0f;
#endif
    // PSOutput.color.rgb =PSInput.color.rgb/lightIntensity(normal);

    if (PSInput.ismap > 0.5 && iswater < 0.5 && PSInput.normal.y < 0.0 &&
        min(min(PSInput.color.r, PSInput.color.g), PSInput.color.b) < 0.8)
        diffuse.rgb = diffuse.rgb / lightIntensity(PSInput.normal) *
                      lightIntensity(-PSInput.normal);
    // PSOutput.color.a = diffuse.a;
    PSOutput.color = diffuse;

#ifdef VR_MODE
    // On Rift, the transition from 0 brightness to the lowest 8 bit value is
    // abrupt, so clamp to the lowest 8 bit value.
    PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif

#endif  // BYPASS_PIXEL_SHADER
}
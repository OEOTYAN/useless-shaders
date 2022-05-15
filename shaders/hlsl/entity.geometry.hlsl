#include "ShaderConstants.fxh"
#include "util.fxh"

#ifdef ENABLE_PLAYER_MAP
#ifdef PLAYER
#define PLAYER__
#endif
#endif

struct GeometryShaderInput {
    float4 pos : SV_POSITION;
    float4 light : LIGHT;
    float4 fogColor : FOG_COLOR;
    float3 worldpos : worldpos;
    float3 normal : NORMAL;
#ifdef GLINT
    float4 layerUV : GLINT_UVS;
#endif

#ifdef COLOR_BASED
    float4 color : COLOR;
#endif

#ifdef USE_OVERLAY
    float4 overlayColor : OVERLAY_COLOR;
#endif

#ifdef TINTED_ALPHA_TEST
    float4 alphaTestMultiplier : ALPHA_MULTIPLIER;
#endif

    float2 uv : TEXCOORD_0_FB_MSAA;
#ifdef INSTANCEDSTEREO
    uint instanceID : SV_InstanceID;
#endif
};

// Per-pixel color data passed through the pixel shader.
struct GeometryShaderOutput {
    float4 pos : SV_POSITION;
    float4 light : LIGHT;
    float4 fogColor : FOG_COLOR;
    float edge : edge;
    float map : map;
#ifndef UI_ENTITY
#ifndef ARMOR_STAND
#ifndef BEACON
    float3 worldpos : worldpos;
    float3 normal : NORMAL;
#ifndef NO_TEXTURE

    float mt : mt;
    float3 tangent : tan;
    float3 bitangent : bitan;
#endif

#endif
#endif
#endif

#ifdef GLINT
    float4 layerUV : GLINT_UVS;
#endif

#ifdef COLOR_BASED
    float4 color : COLOR;
#endif

#ifdef USE_OVERLAY
    float4 overlayColor : OVERLAY_COLOR;
#endif

#ifdef TINTED_ALPHA_TEST
    float4 alphaTestMultiplier : ALPHA_MULTIPLIER;
#endif

#ifndef UI_ENTITY
     float4 uvm : uvm;
     #endif
    float2 uv : TEXCOORD_0_FB_MSAA;
#ifdef INSTANCEDSTEREO
    uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

// passes through the triangles, except changint the viewport id to match the
// instance
#ifndef UI_ENTITY
[maxvertexcount(9)]
#else
[maxvertexcount(3)]
#endif

    void
    main(triangle GeometryShaderInput input[3],
         inout TriangleStream<GeometryShaderOutput> outStream) {
        float headbias = 0.0;
#ifdef IS_HEAD
        headbias = 0.02;
#endif

#ifndef UI_ENTITY
float4x4 VIEW = mul(WORLDVIEW, inverse(WORLD));
#ifndef NO_TEXTURE

        bool notFrame = true;

#ifndef IS_SHULKER_BOX
#ifndef IS_HEAD
        float bisss = 0.25;
        if (abs(length(WORLD[1].y) - bisss) > 0.0001 ||
            (abs(length(WORLD[1].y) - bisss) +
                 abs(max(max(max(abs(WORLD[0].x), abs(WORLD[0].y)),
                             abs(WORLD[0].z)),
                         max(max(abs(WORLD[2].x), abs(WORLD[2].y)),
                             abs(WORLD[2].z))) -
                     bisss) <
             0.0000000000001)) {
            notFrame = false;
        }
#endif
#endif

        float2 uvzmin = min(min(input[0].uv, input[1].uv), input[2].uv);
        float2 uvzmax = max(max(input[0].uv, input[1].uv), input[2].uv);
        float uvl = length((uvzmax - uvzmin) * TEXTURE_DIMENSIONS.xy);
#endif
#endif

#ifdef IS_SHULKER_BOX
        float bisss = 0.25 / 16.0;
        if (abs(length(WORLD[1].y) - bisss) > 0.0001 ||
            (abs(length(WORLD[1].y) - bisss) +
                 abs(max(max(max(abs(WORLD[0].x), abs(WORLD[0].y)),
                             abs(WORLD[0].z)),
                         max(max(abs(WORLD[2].x), abs(WORLD[2].y)),
                             abs(WORLD[2].z))) -
                     bisss) <
             0.000050001)) {
            notFrame = false;
        }
#endif

#ifdef IS_HEAD
        float bisss = 0.5;
        if (abs(length(WORLD[1].y) - bisss) > 0.0001 ||
            (abs(length(WORLD[1].y) - bisss) +
                 abs(max(max(max(abs(WORLD[0].x), abs(WORLD[0].y)),
                             abs(WORLD[0].z)),
                         max(max(abs(WORLD[2].x), abs(WORLD[2].y)),
                             abs(WORLD[2].z))) -
                     bisss) <
             0.0000000000001)) {
            notFrame = false;
        }
#endif

#ifndef INSTANCEDSTEREO
#ifndef NO_TEXTURE
        float poslen =
            max(length(mul(WORLD, float4(input[0].worldpos, 1)).rgb -
                       mul(WORLD, float4(input[1].worldpos, 1)).rgb),
                max(length(mul(WORLD, float4(input[2].worldpos, 1)).rgb -
                           mul(WORLD, float4(input[1].worldpos, 1)).rgb),
                    length(mul(WORLD, float4(input[0].worldpos, 1)).rgb -
                           mul(WORLD, float4(input[2].worldpos, 1)).rgb)));
#else
        float poslen =
            min(length(mul(WORLD, float4(input[0].worldpos, 1)).rgb -
                       mul(WORLD, float4(input[1].worldpos, 1)).rgb),
                min(length(mul(WORLD, float4(input[2].worldpos, 1)).rgb -
                           mul(WORLD, float4(input[1].worldpos, 1)).rgb),
                    length(mul(WORLD, float4(input[0].worldpos, 1)).rgb -
                           mul(WORLD, float4(input[2].worldpos, 1)).rgb)));
        poslen=poslen/3.0*160.0;
        poslen=abs(poslen/exp2(floor(log2(poslen)))-1.5);
        bool isItem=poslen<0.001;
#endif
#endif

        GeometryShaderOutput output = (GeometryShaderOutput)0;

        output.map = 0;

#ifdef INSTANCEDSTEREO
        int i = input[0].instanceID;
#endif

        for (int p = 0; p < 3; p++) {
            int j = p;

            output.pos = input[j].pos;
            output.edge = 0;

#ifndef IS_EXP_ORB
#ifndef BEACON
#ifndef ARMOR_STAND
#ifndef INSTANCEDSTEREO
#ifndef UI_ENTITY
#ifndef NO_TEXTURE
            if (poslen / uvl < ((BLOCK_PSIZE) + headbias) && notFrame)
#else
            if (isItem)
#endif
{
    //         float angle = atan2(WORLD[0][0],WORLD[0][2]);
    // float4x4 mWorld={{length(WORLD[0].xyz),0,0,WORLD[0][3]},
    //                  {0,length(WORLD[1].xyz),0,WORLD[1][3]-sin(angle*2-M_PI/4)*0.1},
    //                  {0,0,length(WORLD[2].xyz),WORLD[2][3]},
    //                  {WORLD[3][0],WORLD[3][1],WORLD[3][2],WORLD[3][3]}};
    // output.pos=mul(PROJ,mul(VIEW,mul(mWorld, float4(input[j].worldpos, 1))));
    
#ifdef ITEM_XRAY
                if (poslen < 0.6)
                    output.pos.z = output.pos.z * 0.8;
#endif
}
#endif
#endif
#endif
#endif
#endif

#ifndef UI_ENTITY
#ifndef BEACON
#ifndef ARMOR_STAND
            output.worldpos = input[j].worldpos;
            output.normal = normalize(input[j].normal);
#endif
#endif
#endif

#ifndef NO_TEXTURE
#ifndef UI_ENTITY
            output.uvm = float4(uvzmin, uvzmax - uvzmin);
            #endif
            output.uv = input[j].uv;
#endif
#ifdef INSTANCEDSTEREO
            output.renTarget_id = i;
#endif
            output.light = input[j].light;
            output.fogColor = input[j].fogColor;
#ifdef COLOR_BASED
            output.color = input[j].color;
#endif
#ifdef USE_OVERLAY
            output.overlayColor = input[j].overlayColor;
#endif
#ifdef TINTED_ALPHA_TEST
            output.alphaTestMultiplier = input[j].alphaTestMultiplier;
#endif
#ifdef GLINT
            output.layerUV = input[j].layerUV;
#endif
            outStream.Append(output);
        }

#ifndef UI_ENTITY
#ifndef IS_EXP_ORB
#ifndef BEACON
#ifndef ARMOR_STAND
#ifdef ENABLE_ENTITY_MAP
#ifndef ITEM_IN_HAND
#ifndef NO_TEXTURE

        if (poslen / uvl > BLOCK_PSIZE) {
            output.map = 1;
            outStream.RestartStrip();
            for (int pm = 0; pm < 3; pm++) {
                int j = pm;
                output.pos.w = input[j].pos.w;

#ifndef PLAYER__
                float3 worldPos = mul(WORLD, float4(input[j].worldpos, 1)).xyz;
                float2 viewPos =
                    mul(worldPos.xz,
                        float2x2(VIEW[0].x, -VIEW[0].z, VIEW[0].z, VIEW[0].x));
#else
                float2 mpos =
                    mul(float2(WORLD[0][3], WORLD[2][3]),
                        float2x2(VIEW[0].x, -VIEW[0].z, VIEW[0].z, VIEW[0].x));
                float2 viewPos =
                    float2(input[j].worldpos.x, input[j].worldpos.y + 3.5) *
                        PLAYER_MAP_SIZE * (RENDER_DISTANCE) +
                    mpos;
#endif

                float2 map =
                    float2(viewPos.x / (RENDER_DISTANCE)*INV_ASPECT_RATIO,
                           -viewPos.y / (RENDER_DISTANCE));
                map /= 2;
                map.x += 0.7;
                map.y += 0.45;

#ifndef PLAYER__
                if (VIEW[2].y < 0)
                    output.pos.z = 1 / (worldPos.y / 256 + 2) - 0.1;
                else
                    output.pos.z = input[j].pos.z * 0.8 - 1;
#else
                output.pos.z = 0.1 / (-input[j].worldpos.z + 2);
#endif

                map *= input[j].pos.w;
                output.pos.xy = map;

                output.edge = 0;

#ifdef ENABLE_OUTLINE
                output.worldpos = input[j].worldpos;
                output.normal = 0;
#endif

#ifndef NO_TEXTURE
                output.uv = input[j].uv;
#endif
#ifdef INSTANCEDSTEREO
                output.renTarget_id = i;
#endif
                output.light = input[j].light;
                output.fogColor = input[j].fogColor;
#ifdef COLOR_BASED
                output.color = input[j].color;
#endif
#ifdef USE_OVERLAY
                output.overlayColor = input[j].overlayColor;
#endif
#ifdef TINTED_ALPHA_TEST
                output.alphaTestMultiplier = input[j].alphaTestMultiplier;
#endif
#ifdef GLINT
                output.layerUV = input[j].layerUV;
#endif
                outStream.Append(output);
            }
        }
        outStream.RestartStrip();
#endif
#endif
#endif
#endif
#endif
#endif
#endif

#ifndef IS_EXP_ORB

#ifdef ENABLE_OUTLINE
#ifndef NO_TEXTURE
#ifndef UI_ENTITY
        if (poslen / uvl < ((BLOCK_PSIZE) + headbias) && notFrame)
#endif
#else
        if (isItem)
#endif
            if (poslen < 1) {
#ifndef UI_ENTITY
#ifndef ARMOR_STAND
#ifndef BEACON
#ifndef INSTANCEDSTEREO
                outStream.RestartStrip();
                for (int p0 = 0; p0 < 3; p0++) {
                    int j = p0;

                    output.edge = 1;

#ifndef NO_TEXTURE
                    float3 normal =
                        normalize(cross(input[2].worldpos - input[1].worldpos,
                                        input[0].worldpos - input[1].worldpos));
                    int corner1Ind = (j + 1) % 3;
                    int corner2Ind = (j + 2) % 3;
                    float3 e1 =
                        mul(WORLD, float4(input[corner1Ind].worldpos, 1)).rgb -
                        mul(WORLD, float4(input[j].worldpos, 1)).rgb;
                    float3 e2 =
                        mul(WORLD, float4(input[corner2Ind].worldpos, 1)).rgb -
                        mul(WORLD, float4(input[j].worldpos, 1)).rgb;
                    float3 e01 = input[corner1Ind].worldpos - input[j].worldpos;
                    float3 e02 = input[corner2Ind].worldpos - input[j].worldpos;
                    float delta_u1 = input[corner1Ind].uv[0] - input[j].uv[0];
                    float delta_u2 = input[corner2Ind].uv[0] - input[j].uv[0];
                    float delta_v1 = input[corner1Ind].uv[1] - input[j].uv[1];
                    float delta_v2 = input[corner2Ind].uv[1] - input[j].uv[1];
                    float3 tangent =
                        (delta_v1 * e2 - delta_v2 * e1) /
                        (delta_v1 * delta_u2 - delta_v2 * delta_u1);
                    float3 ltangent =
                        (delta_v1 * e02 - delta_v2 * e01) /
                        (delta_v1 * delta_u2 - delta_v2 * delta_u1);
                    float3 bitangent =
                        (-delta_u1 * e2 + delta_u2 * e1) /
                        (delta_v1 * delta_u2 - delta_v2 * delta_u1);
                    if (ltangent.x < -0.999 && abs(normal.y) > 0.999) {
                        tangent = -tangent;
                        bitangent = -bitangent;
                    }
                    tangent = normalize(tangent);
                    bitangent = normalize(bitangent);
                    output.tangent = tangent;
                    output.bitangent = bitangent;

#endif

                    if (p0 == 1) {
                        j = 0;
                    } else if (p0 == 2) {
                        j = 2;
                    } else {
                        j = 1;
                    }

                    float thickness = (float)OUTLINE_WIDTH;

                    float3 biasItem = float3(8, 0.5, 8);
                    float3 biasChest = float3(0.5, 0.5, 0.5);
                    float3 biasShulker = float3(0, 16, 0);
#ifdef IS_DDDHEAD
                    float3 biasHead = -float3(0, 0.35, 0.5);
                    thickness *= 0.5;
#else
                    float3 biasHead = -float3(0, 0.25, 0);
#endif

                    float bz = pow(input[j].pos.z, 0.7);

#ifndef NO_TEXTURE
                    output.mt = 1 + bz * thickness;
#endif

#ifndef IS_HEAD
#ifdef NO_TEXTURE
                    output.pos =
                        mul(WORLDVIEWPROJ,
                            float4(biasItem +
                                       (input[j].worldpos - biasItem) *
                                           (1 + bz * thickness * 6 / biasItem),
                                   1));
#else
#ifndef IS_CHEST
                    output.pos = mul(
                        WORLDVIEWPROJ,
                        float4((input[j].worldpos) * (1 + bz * thickness), 1));
#else
#ifndef IS_SHULKER_BOX
                    output.pos =
                        mul(WORLDVIEWPROJ,
                            float4(biasChest + (input[j].worldpos - biasChest) *
                                                   (1 + bz * thickness),
                                   1));
#else
                    output.pos = mul(
                        WORLDVIEWPROJ,
                        float4(biasShulker + (input[j].worldpos - biasShulker) *
                                                 (1 + bz * thickness),
                               1));
#endif
#endif
#endif

#else
                    output.pos =
                        mul(WORLDVIEWPROJ,
                            float4(biasHead + (input[j].worldpos - biasHead) *
                                                  (1 + bz * thickness),
                                   1));
#endif

                    output.worldpos = input[j].worldpos * (1 + bz * thickness);
                    output.normal = normalize(-input[j].normal);

#ifdef ITEM_XRAY
                    output.pos.z = output.pos.z * 0.85;
#endif

#ifndef NO_TEXTURE
                    output.uv = input[j].uv;
#endif
#ifdef INSTANCEDSTEREO
                    output.renTarget_id = i;
#endif
                    output.light = input[j].light;
                    output.fogColor = input[j].fogColor;
#ifdef COLOR_BASED
                    output.color = input[j].color;
#endif
#ifdef USE_OVERLAY
                    output.overlayColor = input[j].overlayColor;
#endif
#ifdef TINTED_ALPHA_TEST
                    output.alphaTestMultiplier = input[j].alphaTestMultiplier;
#endif
#ifdef GLINT
                    output.layerUV = input[j].layerUV;
#endif
                    outStream.Append(output);
                }
#endif
#endif
#endif
#endif
            }
#endif
#endif
    }
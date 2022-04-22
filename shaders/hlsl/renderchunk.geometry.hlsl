#include "ShaderConstants.fxh"
#include "util.fxh"

struct GeometryShaderInput {
    float4 pos : SV_POSITION;
    float3 worldPos : worldPos;
    float3 chunkPos : chunkPos;
#ifndef BYPASS_PIXEL_SHADER
    lpfloat4 color : COLOR;
     float2 uv0 : TEXCOORD_0;
     float2 uv1 : TEXCOORD_1;
#endif
#ifdef NEAR_WATER
    float cameraDist : TEXCOORD_2;
#endif
#ifdef FOG
    float4 fogColor : FOG_COLOR;
#endif
#ifdef INSTANCEDSTEREO
    uint instanceID : SV_InstanceID;
#endif
};

// Per-pixel color data passed through the pixel shader.
struct GeometryShaderOutput {
    float4 pos : SV_POSITION;
    float3 worldPos : worldPos;
    float3 chunkPos : chunkPos;
    float3 tangent : tan;
    float3 bitangent : bitan;
    float3 normal : nor;
    float ismap : ismap;
#ifndef BYPASS_PIXEL_SHADER
    lpfloat4 color : COLOR;
     float4 uvm : uvm;
     float2 uv0 : TEXCOORD_0;
     float2 uv1 : TEXCOORD_1;
#endif
#ifdef NEAR_WATER
    float cameraDist : TEXCOORD_2;
#endif
#ifdef FOG
    float4 fogColor : FOG_COLOR;
#endif
#ifdef INSTANCEDSTEREO
    uint renTarget_id : SV_RenderTargetArrayIndex;
#endif
};

// passes through the triangles, except changint the viewport id to match the
// instance
[maxvertexcount(6)] void main(
    triangle GeometryShaderInput input[3],
    inout TriangleStream<GeometryShaderOutput> outStream) {
    GeometryShaderOutput output = (GeometryShaderOutput)0;

    float3 normal =
        normalize(cross(input[2].worldPos.xyz - input[1].worldPos.xyz,
                        input[0].worldPos.xyz - input[1].worldPos.xyz));


    float3 maxpos= max(input[0].chunkPos.xyz,max(input[1].chunkPos.xyz, input[2].chunkPos.xyz));
    float3 minpos=min(input[0].chunkPos.xyz,min(input[1].chunkPos.xyz, input[2].chunkPos.xyz));
    float3 aabb=maxpos-minpos;
    float3 center=minpos+aabb*0.5;
    #ifdef ORE_XRAY
    bool3 isc=abs(frac(center)-0.5)<0.01;
    bool is_ore=false;


 if((abs(frac(center.y)-0.5)<0.38)&&(isc.x+isc.y+isc.z>1.5)&&
 abs(dot(abs(aabb-float3(1,0.75,1)),float3(1.0,1.0,1.0))-1)<0.01&&
 ((input[1].uv1.x+input[1].uv1.y<0.01)/*||(input[1].uv1.x>0.9375)*/)){
 is_ore=true;
 }
#endif

#ifndef BYPASS_PIXEL_SHADER
    float2 minuv = min(input[0].uv0, min(input[1].uv0, input[2].uv0));
    float2 maxuv = max(input[0].uv0, max(input[1].uv0, input[2].uv0));
#endif

#if !defined(AS_ENTITY_RENDERER)&&defined(ALPHA_TEST)&&!defined(BYPASS_PIXEL_SHADER)&&!defined(S_FAR)&&(defined(WAVING_LEAVES)||defined(WAVING_WHEAT)||defined(WAVING_WATERLILY))
bool mayleave=false;
bool maywheat=false;
bool maywaterlily=false;
bool maywaterlilyb=false;
if(dot(abs(normal)-float3(1,1,1),float3(1,1,1))+2<0.001&&length(frac(center)-0.5)>0.25){
if(abs(input[0].color.b-input[0].color.g)+abs(input[0].color.r-input[0].color.g)>0.00001
    &&(input[0].color.g+input[0].color.b>0.01&&input[0].color.r<0.9)){
mayleave=true;
}else{
    if(abs(frac(center.y)-0.4375)<0.0001&&abs(dot(abs(aabb-float3(1,1,1)),float3(1,1,1))-1)<0.0001&&input[0].color.g>0.5)
    maywheat=true;
}
if(abs(input[0].color.r-input[0].color.g)<0.000001
    &&abs(frac(center.y)-0.015625)<0.0000001)
maywaterlily=true;
if(input[0].color.a<0.001&&input[0].color.g<0.06&&input[0].color.b<0.06&&input[0].color.r<0.06){
maywaterlily=true;
maywaterlilyb=true;
}
}
#endif

#ifdef INSTANCEDSTEREO
    int i = input[0].instanceID;
#endif
    {
        for (int j = 0; j < 3; j++) {

            output.worldPos = input[j].worldPos;
            output.chunkPos = input[j].chunkPos;
            #if defined(ALPHA_TEST)&&!defined(BYPASS_PIXEL_SHADER)&&!defined(S_FAR)&&(defined(WAVING_LEAVES)||defined(WAVING_WHEAT)||defined(WAVING_WATERLILY))

#ifdef WAVING_LEAVES
if(mayleave){
        float speed = 0.05;
        float3 mPos2=fmod(input[j].chunkPos.xyz,16);

float lightWeight = clamp((input[j].uv1.y * 33.05f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);
      lightWeight *= 1.1f;
      lightWeight -= 0.1f;
      lightWeight = max(0.0f, lightWeight);
     lightWeight = Pow4(lightWeight);

        float magnitude = (sin((mPos2.y + mPos2.x + TIME * 3.1415926 / ((28.0) * speed))) * 0.15 + 0.15) * 0.40 *lightWeight;
              magnitude *=lightWeight;        
        float d0 = sin(TIME * 3.1415926 / (112.0 * speed)) * 3.0 - 1.5;
        float d1 = sin(TIME * 3.1415926 / (142.0 * speed)) * 3.0 - 1.5;
        float d2 = sin(TIME * 3.1415926 / (132.0 * speed)) * 3.0 - 1.5;
        float d3 = sin(TIME * 3.1415926 / (122.0 * speed)) * 3.0 - 1.5;
        output.chunkPos.x += sin((TIME * 3.1415926 / (18.0 * speed)) + (-mPos2.x + d0)*1.6 + (mPos2.z + d1)*1.6) * magnitude ;
        output.chunkPos.z += sin((TIME * 3.1415926 / (17.0 * speed)) + (mPos2.z + d2)*1.6 + (-mPos2.x + d3)*1.6) * magnitude ;
        output.chunkPos.y += sin((TIME * 3.1415926 / (11.0 * speed)) + (mPos2.z + d2) + (mPos2.x + d3)) * (magnitude/2.0);
        output.worldPos = (output.chunkPos * CHUNK_ORIGIN_AND_SCALE.w) +
                      CHUNK_ORIGIN_AND_SCALE.xyz;
} 
#endif

#ifdef WAVING_WHEAT
if(maywheat&&input[j].chunkPos.y>center.y){
        float3 mPos2=fmod(input[j].chunkPos.xyz,16);

float lightWeight = clamp((input[j].uv1.y * 33.05f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);
      lightWeight *= 1.1f;
      lightWeight -= 0.1f;
      lightWeight = max(0.0f, lightWeight);
     lightWeight = Pow5(lightWeight);

float speed = 0.5;
        
        float magnitude = (sin((TIME * 3.14159265358979323846264 / (28.0)) + mPos2.x + mPos2.z) * 0.07 + 0.1)*lightWeight;
        float d0 = sin(TIME * 3.14159265358979323846264 / (122.0 * speed)) * 3.0 - 1.5 + mPos2.z;
        float d1 = sin(TIME * 3.14159265358979323846264 / (152.0 * speed)) * 3.0 - 1.5 + mPos2.x;
        float d2 = sin(TIME * 3.14159265358979323846264 / (122.0 * speed)) * 3.0 - 1.5 + mPos2.x;
        float d3 = sin(TIME * 3.14159265358979323846264 / (152.0 * speed)) * 3.0 - 1.5 + mPos2.z;
        output.chunkPos.x += sin((TIME * 3.14159265358979323846264 / (28.0 * speed)) + (mPos2.x + d0) * 0.1 + (mPos2.z + d1) * 0.1) * magnitude;
        output.chunkPos.z -= sin((TIME * 3.14159265358979323846264 / (28.0 * speed)) + (mPos2.z + d2) * 0.1 + (mPos2.x + d3) * 0.1) * magnitude;
        // output.chunkPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.x + d0) * 0.1 + (mPos2.z + d3) * 0.1) * (magnitude/2.0);
        // output.chunkPos.y += (sin(1.0 * 3.14159265358979323846264 / 16.0) * sin(1.0 * 3.14159265358979323846264 / 11.0) + sin(1.0 * 3.14159265358979323846264 / 46.0))*2.0;
        // output.chunkPos.y -= 0.2;
        speed = 0.1;
		 magnitude = (sin(((mPos2.y + mPos2.x)/2.0 + TIME * 3.14159265358979323846264 / ((28.0)))) * 0.025 + 0.075) * 0.8*lightWeight;
		 d0 = sin(TIME * 3.14159265358979323846264 / (112.0 * speed)) * 3.0 - 1.5;
		 d1 = sin(TIME * 3.14159265358979323846264 / (142.0 * speed)) * 3.0 - 1.5;
		 d2 = sin(TIME * 3.14159265358979323846264 / (112.0 * speed)) * 3.0 - 1.5;
		 d3 = sin(TIME * 3.14159265358979323846264 / (142.0 * speed)) * 3.0 - 1.5;
		output.chunkPos.x += sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (-mPos2.x + d0)*1.6 + (mPos2.z + d1)*1.6) * magnitude;
		output.chunkPos.z += sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (mPos2.z + d2)*1.6 + (-mPos2.x + d3)*1.6) * magnitude;
		output.chunkPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.z + d2) + (mPos2.x + d3)) * (magnitude/3.0) ;

        output.worldPos = (output.chunkPos * CHUNK_ORIGIN_AND_SCALE.w) +
                      CHUNK_ORIGIN_AND_SCALE.xyz;
} 
#endif

#ifdef WAVING_WATERLILY
if(maywaterlily){

        float3 mPos2=input[j].chunkPos.xyz;
        if(maywaterlilyb)
        mPos2.y+=1.0/64.0;
        mPos2=fmod(mPos2,16);

// float lightWeight = clamp((input[j].uv1.y * 33.05f / 32.0f) - 1.05f / 32.0f, 0.0f, 1.0f);
    //   lightWeight *= 1.1f;
    //   lightWeight -= 0.1f;
    //   lightWeight = max(0.0f, lightWeight);
    //  lightWeight = Pow5(lightWeight);

float speed = 0.5;
        
        float magnitude = (sin((TIME * 3.14159265358979323846264 / (28.0)) + mPos2.x + mPos2.z) * 0.02 + 0.02);
        float d0 = sin(TIME * 3.14159265358979323846264 / (122.0 * speed)) * 3.0 - 1.5 + mPos2.z;
        float d1 = sin(TIME * 3.14159265358979323846264 / (152.0 * speed)) * 3.0 - 1.5 + mPos2.x;
        float d2 = sin(TIME * 3.14159265358979323846264 / (122.0 * speed)) * 3.0 - 1.5 + mPos2.x;
        float d3 = sin(TIME * 3.14159265358979323846264 / (152.0 * speed)) * 3.0 - 1.5 + mPos2.z;
        output.chunkPos.x += sin((TIME * 3.14159265358979323846264 / (28.0 * speed)) + (mPos2.x + d0) * 0.1 + (mPos2.z + d1) * 0.1) * magnitude;
        output.chunkPos.z -= sin((TIME * 3.14159265358979323846264 / (28.0 * speed)) + (mPos2.z + d2) * 0.1 + (mPos2.x + d3) * 0.1) * magnitude;
        // output.chunkPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.x + d0) * 0.1 + (mPos2.z + d3) * 0.1) * (magnitude/2.0);
        // output.chunkPos.y += (sin(1.0 * 3.14159265358979323846264 / 16.0) * sin(1.0 * 3.14159265358979323846264 / 11.0) + sin(1.0 * 3.14159265358979323846264 / 46.0))*2.0;
       if(maywaterlilyb)
        output.chunkPos.y -= 1/96.0;
        speed = 0.1;
		 magnitude = (sin(((mPos2.y + mPos2.x)/2.0 + TIME * 3.14159265358979323846264 / ((28.0)))) * 0.055 + 0.045) * 0.4;
		 d0 = sin(TIME * 3.14159265358979323846264 / (112.0 * speed)) * 3.0 - 1.5;
		 d1 = sin(TIME * 3.14159265358979323846264 / (142.0 * speed)) * 3.0 - 1.5;
		 d2 = sin(TIME * 3.14159265358979323846264 / (112.0 * speed)) * 3.0 - 1.5;
		 d3 = sin(TIME * 3.14159265358979323846264 / (142.0 * speed)) * 3.0 - 1.5;
		output.chunkPos.x += 0.5*sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (-mPos2.x + d0)*1.6 + (mPos2.z + d1)*1.6) * magnitude;
		output.chunkPos.z += 0.5*sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (mPos2.z + d2)*1.6 + (-mPos2.x + d3)*1.6) * magnitude;
		output.chunkPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.z + d2) + (mPos2.x + d3)) * (magnitude/2.5) ;

        mPos2=center.xyz;
        mPos2=fmod(mPos2,16);

		output.chunkPos.x += sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (-mPos2.x + d0)*1.6 + (mPos2.z + d1)*1.6) * magnitude;
		output.chunkPos.z += sin((TIME * 3.14159265358979323846264 / (18.0 * speed)) + (mPos2.z + d2)*1.6 + (-mPos2.x + d3)*1.6) * magnitude;
		output.chunkPos.y += sin((TIME * 3.14159265358979323846264 / (11.0 * speed)) + (mPos2.z + d2) + (mPos2.x + d3)) *magnitude ;

        output.worldPos = (output.chunkPos * CHUNK_ORIGIN_AND_SCALE.w) +
                      CHUNK_ORIGIN_AND_SCALE.xyz;
} 
#endif
#endif


            output.ismap = 0.0;
            int corner1Ind = (j + 1) % 3;
            int corner2Ind = (j + 2) % 3;
            float3 e1 = input[corner1Ind].worldPos - input[j].worldPos;
            float3 e2 = input[corner2Ind].worldPos - input[j].worldPos;
            float delta_u1 = input[corner1Ind].uv0[0] - input[j].uv0[0];
            float delta_u2 = input[corner2Ind].uv0[0] - input[j].uv0[0];
            float delta_v1 = input[corner1Ind].uv0[1] - input[j].uv0[1];
            float delta_v2 = input[corner2Ind].uv0[1] - input[j].uv0[1];
            float3 tangent = (delta_v1 * e2 - delta_v2 * e1) /
                             (delta_v1 * delta_u2 - delta_v2 * delta_u1);
            float3 bitangent = (-delta_u1 * e2 + delta_u2 * e1) /
                               (delta_v1 * delta_u2 - delta_v2 * delta_u1);
            tangent = normalize(tangent);
            bitangent = normalize(bitangent);
            output.tangent = tangent;
            output.normal = normal;
            output.bitangent = bitangent;


#if !defined(AS_ENTITY_RENDERER)&&!defined(BYPASS_PIXEL_SHADER)&&((defined(ALPHA_TEST)&&!defined(S_FAR)&&(defined(WAVING_LEAVES)||defined(WAVING_WHEAT)||defined(WAVING_WATERLILY))))

            output.pos = mul(WORLDVIEWPROJ, float4(output.worldPos, 1));

#else
            output.pos = input[j].pos;
            #endif
#ifndef BYPASS_PIXEL_SHADER
            output.color = input[j].color;
            output.uvm = float4(minuv, maxuv - minuv);
            output.uv0 = input[j].uv0;
            output.uv1 = input[j].uv1;
#endif
#ifdef NEAR_WATER
            output.cameraDist = input[j].cameraDist;
#endif

#ifdef INSTANCEDSTEREO
            output.renTarget_id = i;
#endif

#ifdef FOG
            output.fogColor = input[j].fogColor;
#endif

#ifdef ORE_XRAY
           if(is_ore){
                    float3 bias=output.chunkPos-center;
                    bias=(abs(bias)-0.5)*sign(-bias);
                    float tm=0.125;

#ifndef FANCY
if(false)
#endif 
    tm=0.123;
                    output.pos=mul(WORLDVIEWPROJ, float4(output.worldPos+bias+normal*tm, 1));
    float3x3 TBN = float3x3(output.tangent, output.bitangent,output.normal);
    float3x3 inverseTBN = transpose(TBN);
                    output.uv0+=mul(TBN,bias).xy*(maxuv-minuv)*4/3.0;
#ifndef FANCY
//if(length(input[1].worldPos.xyz)<64)
                    output.pos.z = output.pos.z * 0.8;
#endif 
#ifndef BYPASS_PIXEL_SHADER
            output.uv1 = float2(1.0,1.0);
#endif
            }

#endif


            // else{
            //    if(abs(dot(abs(aabb-float3(0.75,0.75,0.75)),float3(1.0,1.0,1.0))-0.75)<0.01){
                //    output.pos.z=-1;
            //    }
            // }

#ifdef ALLOW_FADE
            float3 ppppos = input[j].chunkPos;
#ifdef ENABLE_CHUNK_LOADING_ANIMATION
            ppppos.y += (12.0 * Pow2(cos(3.141592653589793f *
                                         (0.5 - RENDER_CHUNK_FOG_ALPHA))) +
                         128.0 * (RENDER_CHUNK_FOG_ALPHA +
                                  log(1.0 - RENDER_CHUNK_FOG_ALPHA)));
#endif
            output.pos =
                mul(WORLDVIEW, float4((ppppos.xyz * CHUNK_ORIGIN_AND_SCALE.w) +
                                          CHUNK_ORIGIN_AND_SCALE.xyz,
                                      1));
            output.pos = mul(PROJ, output.pos);
#endif

            outStream.Append(output);
        }
    }

#ifdef ENABLE_BLOCK_MAP
    outStream.RestartStrip();
    {
        for (int p = 0; p < 3; p++) {
            output.ismap = 1.0;

            int j = p;
#ifndef BLEND
            if (normal.y < 0) {
                if (p == 1) {
                    j = 2;
                } else if (p == 2) {
                    j = 1;
                } else {
                    j = 0;
                }
            }
#endif
            output.worldPos = input[j].worldPos;
            output.pos.w = input[j].pos.w;

            if (WORLDVIEW[2].y < 0)
                output.pos.z = 1 / (input[j].worldPos.y / 256 + 2) - 0.1;
            else
                output.pos.z = input[j].pos.z * 0.8 - 1;
            //对三角形的深度进行特殊处理，使其不会乱序且永远处于上层。

            float2 viewPos = mul(input[j].worldPos.xz,
                                 float2x2(WORLDVIEW[0].x, -WORLDVIEW[0].z,
                                          WORLDVIEW[0].z, WORLDVIEW[0].x));
            //对三角形的朝向进行旋转，使得小地图永远朝着我们面向的方向。

            float2 map = float2(viewPos.x / (RENDER_DISTANCE)*INV_ASPECT_RATIO,
                                -viewPos.y / (RENDER_DISTANCE));
            //对三角形进行缩放，使其长宽比按照屏幕缩放，且大小随视距缩放。

            map /= 2;
            map.x += 0.7;
            map.y += 0.45;
            //使地图处于左上角，且大小合适。

            map *= input[j].pos.w;
            output.pos.xy = map;
            output.chunkPos = input[j].chunkPos;
            output.tangent = float3(0, 0, 1);
            output.normal = normal;
            output.bitangent = float3(1, 0, 0);
#ifndef BYPASS_PIXEL_SHADER
            output.color = input[j].color;
            output.uvm = float4(minuv, maxuv - minuv);
            output.uv0 = input[j].uv0;
            output.uv1 = input[j].uv1;
#endif
#ifdef NEAR_WATER
            output.cameraDist = input[j].cameraDist;
#endif

#ifdef INSTANCEDSTEREO
            output.renTarget_id = i;
#endif

#ifdef FOG
            output.fogColor = 0;
#endif
            outStream.Append(output);
        }
    }
#endif
}
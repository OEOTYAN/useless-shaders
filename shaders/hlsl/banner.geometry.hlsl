#include "ShaderConstants.fxh"
struct GeometryShaderInput {
	float4		pos				: SV_POSITION;
    #ifndef UI_ENTITY
    float3 worldpos : worldpos;
    #endif
#ifdef ENABLE_LIGHT
	float4		light			: LIGHT;
#endif
#ifdef ENABLE_FOG
	float4		fogColor		: FOG_COLOR;
#endif
#ifndef DISABLE_TINTING
	float4		color			: COLOR;
#endif
	float4		uv				: TEXCOORD_0_FB_MSAA;

#ifdef INSTANCEDSTEREO
	uint		instanceID		: SV_InstanceID;
#endif
};

// Per-pixel color data passed through the pixel shader.
struct GeometryShaderOutput {
	float4		pos				: SV_POSITION;
    #ifndef UI_ENTITY
    float edge : edge;
    float3 worldpos : worldpos;
    #endif
#ifdef ENABLE_LIGHT
	float4		light			: LIGHT;
#endif
#ifdef ENABLE_FOG
	float4		fogColor		: FOG_COLOR;
#endif
#ifndef DISABLE_TINTING
	float4		color			: COLOR;
#endif
	float4		uv				: TEXCOORD_0_FB_MSAA;

#ifdef INSTANCEDSTEREO
	uint        renTarget_id	: SV_RenderTargetArrayIndex;
#endif
};

// passes through the triangles, except changint the viewport id to match the instance
[maxvertexcount(6)]
void main(triangle GeometryShaderInput input[3], inout TriangleStream<GeometryShaderOutput> outStream)
{
	GeometryShaderOutput output = (GeometryShaderOutput)0;

#ifdef INSTANCEDSTEREO
	int i = input[0].instanceID;
#endif
	for (int j = 0; j < 3; j++)
	{
		output.pos = input[j].pos;
    #ifndef UI_ENTITY
            output.edge = 0;
            output.worldpos=input[j].worldpos;
    #ifdef ITEM_XRAY
        if(length(WORLD[0].xyz)<0.18)
        output.pos.z = input[j].pos.z * 0.8;
        #endif
        #endif
		output.uv				= input[j].uv;
#ifdef INSTANCEDSTEREO
		output.renTarget_id = i;
#endif
#ifdef ENABLE_LIGHT
		output.light			= input[j].light;
#endif
#ifdef ENABLE_FOG
		output.fogColor			= input[j].fogColor;
#endif
#ifndef DISABLE_TINTING
		output.color		    = input[j].color;
#endif
		outStream.Append(output);
	}
    #ifdef ENABLE_OUTLINE
    #ifndef UI_ENTITY
        outStream.RestartStrip();
        if(length(WORLD[0].xyz)<0.18){
            
                    float thickness = (float)OUTLINE_WIDTH;
                    float4 biasbanner=float4(0,-0.5,0,0);
	for (int j1 = 0; j1 < 3; j1++)
	{
        int j2;
            if (j1== 1) {
                        j2 = 0;
                    } else if (j1== 2) {
                        j2 = 2;
                    } else {
                        j2 = 1;
                    }
            output.edge = 1;
            output.worldpos=input[j2].worldpos;
                    float bz = pow(input[j2].pos.z, 0.7);
		float4 mPos = float4((input[j2].worldpos), 1);
        float3 mthick=bz * thickness*float3(2,1,4);
        float4 mthick4=float4(1+mthick,1.0);
		output.pos = mul(WORLDVIEWPROJ, (mPos-biasbanner)*mthick4+biasbanner);
    #ifdef ITEM_XRAY
        output.pos.z = output.pos.z*0.85;
#endif
		output.uv				= input[j2].uv;
#ifdef INSTANCEDSTEREO
		output.renTarget_id = i;
#endif
#ifdef ENABLE_LIGHT
		output.light			= 1.0;
#endif
#ifdef ENABLE_FOG
		output.fogColor			= input[j2].fogColor;
#endif
#ifndef DISABLE_TINTING
		output.color		    = 1.0;
#endif
		outStream.Append(output);
	}
}
#endif
#endif
}
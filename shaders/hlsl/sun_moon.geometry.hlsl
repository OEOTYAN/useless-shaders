#include "ShaderConstants.fxh"

struct GeometryShaderInput
{
	float4		pos				: SV_POSITION;
	float2		uv0				: TEXCOORD_0;
    float3 sufacepos : sufacepos;
};

// Per-pixel color data passed through the pixel shader.
struct GeometryShaderOutput
{
	float4		pos				: SV_POSITION;
	float2		uv0				: TEXCOORD_0;
    float3 sufacepos : sufacepos;
	float3 barys : barys;
};

// passes through the triangles, except changint the viewport id to match the instance
[maxvertexcount(3)]
void main(triangle GeometryShaderInput input[3], inout TriangleStream<GeometryShaderOutput> outStream)
{
	GeometryShaderOutput output = (GeometryShaderOutput)0;

#ifdef INSTANCEDSTEREO
	int i = input[0].instanceID;
#endif	
	{
		for (int j = 0; j < 3; j++)
		{
			output.pos = input[j].pos;
			output.sufacepos = input[j].sufacepos;
			output.uv0 = input[j].uv0;
			if(j==0)
			output.barys.rgb=float3(1,0,0);
			else if(j==1)
			output.barys.rgb=float3(0,1,0);
			else
			output.barys.rgb=float3(0,0,1);

			outStream.Append(output);
		}
		//outStream.RestartStrip();
	}
}
#include "ShaderConstants.fxh"

struct PS_Input
{
    float4 position : SV_Position;
    float4 color : COLOR;
    float3 worldpos : worldpos;
	float3 barys : barys;
};

struct PS_Output
{
    float4 color : SV_Target;
};
/*
#define PI	3.141592653589793f

//sky部分

float3 RS(float c,float q)
{
	float3 beta = q * float3(5.81,13.5,33.1) * pow(10.0,-6.0);//固定beta
	return (3.0 / (16.0 * PI)) * (1.0 + c * c) * beta;//相位*beta
}//瑞利散射

float3 MS(float c,float g,float q)
{
	float3 beta = q * 2.0 * pow(10.0,-5.0);//固定beta
	return (1.0 / (4.0 * PI)) * ((3.0 * (1.0 - g * g)) / (2.0 * (2.0 + g * g))) * ((1.0 + c * c) / pow(1.0 + g * g - 2.0 * g * c,1.5)) * beta;
}//米氏散射

float3 OD(float3 a,float3 b,float rq,float mq)
{
	float Hr = 7994.0;//瑞利大气高度
	float Hm = 1200.0;//米大气高度
	int samp = 5;
	float fs = samp;
	float sc = 1.0 / fs;
	float dr = 0.0;
	float dm = 0.0;
	float3 pr = b;
	float3 pm = b;
	float3 betar = rq * float3(5.81,13.5,33.1) * pow(10.0,-6.0);//固定beta
	float3 betam = mq * 2.0 * pow(10.0,-5.0);//固定beta
	float3 posd = (b - a) * sc;
	for(int i = 1;i <= samp;i++)
	{
		dr += exp(-pr.y / Hr);
		pr -= posd;
		dm += exp(-pm.y / Hm);
		pm -= posd;
	}
	return dr * betar + dm * betam;
}
float3 insc(float a,float b,float sun,float3 pos)
{
	float rq = 50.0;
	float mq = 1.0;
	float3 tsunf =float3(sin(a),cos(a),0);
	float3 co = 0;
	int samp = 50;//采样数
	float fs = float(samp);//浮点的采样数
	float sc = 1.0 / fs; //缩放
	float Hr = 7994.0;//瑞利大气高度
	float Hm = 1200.0;//米大气高度
	float3 pr = pos * Hr;//瑞利当前坐标
	float3 posdr = pr * sc;//瑞利步进量
	float3 pm = pos * Hm;//米当前坐标
	float3 posdm = pm * sc;//米步进量
	float g = 0.99;//各向异性系数
	float3 betar = rq * float3(5.81,13.5,33.1) * pow(10.0,-6.0);//固定beta
	float3 betam = mq * 2.0 * pow(10.0,-5.0);//固定beta
	float3 beta = betam + betar;
	for(int i = 1;i <= samp;i++)
	{
		float lapr = length(tsunf*Hr - pr);
		float lapm = length(tsunf*Hm - pm);
		float lpcr = length(pr);
		float lpcm = length(pm);
		//float3 tap = betar * lapr + betam * lapm;
		//float3 tpc = betar * lpcr + betam * lpcm;
		float3 tap = OD(tsunf * Hr,pr,rq,mq);
		float3 tpc = OD(tsunf * Hm,pm,rq,mq);
		co += sun * exp(-tap-tpc) * (RS(dot(pos,float3(sin(a)*sin(b),sin(a)*cos(b),cos(a))),rq) + MS(dot(pos,float3(sin(a)*sin(b),sin(a)*cos(b),cos(a))),g,mq));
		pr -= posdr;
		pm -= posdm;
	}
	return co;
}
float3 finalsky(float a ,float b,float sun,float3 pos)
{
	float3 skyco = 0;
	float gamma = 2.2;
	skyco =pow(skyco,gamma);
	
	
	float3 scpos = pos;
	float3 scatter = insc(a,b,sun,scpos);
	skyco = scatter;
	
	
	skyco = pow(skyco,1.0 /gamma);
	return skyco*5.0;
}
*//*
float skylen(float r, float h, float c)
{
	float t1 = 2.0 * r * c;
	float t2 = -2.0 * (r * h + h * h);
	return (-t1 + sqrt(t1 * t1 - 4.0 * t2)) / 2.0;
}
#define R 1000000.0
#define H 2048.0
// sky

    float3 getSkyColor(float3 e) {
        e.y = max(e.y, 0.0);
        return float3(pow(1.0 - e.y, 2.0), 1.0 - e.y, 0.6 + (1.0 - e.y)*0.4);
    }*/
ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
/*
	float3 worpos = PSInput.worldpos; 
	worpos.y += 0.128;
	float orilen = length(worpos);
	float skycos = worpos.y / orilen;
	float worlen = skylen(R, H, skycos);
	worpos *=worlen / orilen;*/
    /*
	float3 diffuse=PSInput.color.rgb;

	 float3 deltas = fwidth(PSInput.barys);
	 float3 smoothing = deltas ;
	 float3 thickness = deltas *0.5;
	 float3 baryss = smoothstep(thickness,thickness+smoothing,PSInput.barys);
	 PSOutput.color.rgb = lerp(float3(0,0,0),diffuse,min(baryss.x,min(baryss.z,baryss.y)));*/
    PSOutput.color = PSInput.color;
}
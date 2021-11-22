#include "ShaderConstants.fxh"
#include "util.fxh"

struct PS_Input {
	float4 position : SV_Position;

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
    float mt:mt;
	float3 tangent : tan;
	float3 bitangent : bitan;
#endif

        #endif
        #endif
        #endif

#ifdef GLINT
	// there is some alignment issue on the Windows Phone 1320 that causes the position
	// to get corrupted if this is two floats and last in the struct memory wise
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

};

struct PS_Output
{
	float4 color : SV_Target;
};

#ifdef USE_EMISSIVE
#ifdef USE_ONLY_EMISSIVE
#define NEEDS_DISCARD(C) (C.a == 0.0f ||C.a == 1.0f )
#else
#define NEEDS_DISCARD(C)	(C.a + C.r + C.g + C.b == 0.0)
#endif
#else
#ifndef USE_COLOR_MASK
#define NEEDS_DISCARD(C)	(C.a < 0.5)
#else
#define NEEDS_DISCARD(C)	(C.a == 0.0)
#endif
#endif

float4 glintBlend(float4 dest, float4 source) {
	// glBlendFuncSeparate(GL_SRC_COLOR, GL_ONE, GL_ONE, GL_ZERO)
	return float4(source.rgb * source.rgb, source.a) + float4(dest.rgb, 0.0);
}

float3x3 GetTangentBasis( float3 TangentZ )
{
	const float Sign = TangentZ.z >= 0 ? 1 : -1;
	const float a = -1/( Sign + TangentZ.z );
	const float b = TangentZ.x * TangentZ.y * a;
	
	float3 TangentX = { 1 + Sign * a * Pow2( TangentZ.x ), Sign * b, -Sign * TangentZ.x };
	float3 TangentY = { b,  Sign + a * Pow2( TangentZ.y ), -TangentZ.y };

	return float3x3( TangentX, TangentY, TangentZ );
}

float3 TangentToWorld( float3 Vec, float3 TangentZ )
{
	return mul( Vec, GetTangentBasis( TangentZ ) );
}

float3 WorldToTangent(float3 Vec, float3 TangentZ)
{
	return mul(GetTangentBasis(TangentZ), Vec);
}

float2 LineBoxIntersect(float3 RayOrigin, float3 RayEnd, float3 BoxMin, float3 BoxMax)
{
	float3 InvRayDir = 1.0f / (RayEnd - RayOrigin);
	
	//find the ray intersection with each of the 3 planes defined by the minimum extrema.
	float3 FirstPlaneIntersections = (BoxMin - RayOrigin) * InvRayDir;
	//find the ray intersection with each of the 3 planes defined by the maximum extrema.
	float3 SecondPlaneIntersections = (BoxMax - RayOrigin) * InvRayDir;
	//get the closest of these intersections along the ray
	float3 ClosestPlaneIntersections = min(FirstPlaneIntersections, SecondPlaneIntersections);
	//get the furthest of these intersections along the ray
	float3 FurthestPlaneIntersections = max(FirstPlaneIntersections, SecondPlaneIntersections);

	float2 BoxIntersections;
	//find the furthest near intersection
	BoxIntersections.x = max(ClosestPlaneIntersections.x, max(ClosestPlaneIntersections.y, ClosestPlaneIntersections.z));
	//find the closest far intersection
	BoxIntersections.y = min(FurthestPlaneIntersections.x, min(FurthestPlaneIntersections.y, FurthestPlaneIntersections.z));
	//clamp the intersections to be between RayOrigin and RayEnd on the ray
	return saturate(BoxIntersections);
}

ROOT_SIGNATURE
void main(in PS_Input PSInput, out PS_Output PSOutput)
{
   #ifdef ENABLE_OUTLINE
    #ifndef UI_ENTITY
    #ifndef ARMOR_STAND
       #ifndef BEACON
        if(PSInput.edge>0.5){
 if(PSInput.position.z<0.1){
    discard;
    }
    }
    if(PSInput.map>0.5){
 if(mul(WORLDVIEWPROJ, float4(PSInput.worldpos,1)).z<0.1){
    discard;
    }
    }
#endif
#endif
#endif
#endif


	float4 color = float4( 1.0f, 1.0f, 1.0f, 1.0f );

#if( !defined(NO_TEXTURE) || !defined(COLOR_BASED) || defined(USE_COLOR_BLEND) )

#if !defined(TEXEL_AA) || !defined(TEXEL_AA_FEATURE) || (VERSION < 0xa000 /*D3D_FEATURE_LEVEL_10_0*/)
	color = TEXTURE_0.Sample( TextureSampler0, PSInput.uv );
#else
	color = texture2D_AA(TEXTURE_0, TextureSampler0, PSInput.uv);
#endif

#ifdef MASKED_MULTITEXTURE
	float4 tex1 = TEXTURE_1.Sample(TextureSampler1, PSInput.uv);

	// If tex1 has a non-black color and no alpha, use color; otherwise use tex1 
	float maskedTexture = ceil( dot( tex1.rgb, float3(1.0f, 1.0f, 1.0f) ) * ( 1.0f - tex1.a ) );
	color = lerp(tex1, color, saturate(maskedTexture));
#endif // MASKED_MULTITEXTURE

#if defined(ALPHA_TEST) && !defined(USE_MULTITEXTURE) && !defined(MULTIPLICATIVE_TINT)
	if( NEEDS_DISCARD( color ) )
	{
		discard;
	}
#endif

#ifdef TINTED_ALPHA_TEST
	float4 testColor = color;
	testColor.a = testColor.a * PSInput.alphaTestMultiplier.r;
	if( NEEDS_DISCARD( testColor ) )
	{
		discard;
	}
#endif

#endif

#ifdef COLOR_BASED
	color *= PSInput.color;
#endif

#ifdef MULTI_COLOR_TINT
	// Texture is a mask for tinting with two colors
	float2 colorMask = color.rg;

	// Apply the base color tint
	color.rgb = colorMask.rrr * CHANGE_COLOR.rgb;

	// Apply the secondary color mask and tint so long as its grayscale value is not 0
	color.rgb = lerp(color.rgb, colorMask.ggg * MULTIPLICATIVE_TINT_CHANGE_COLOR.rgb, ceil(colorMask.g));
#else

#ifdef USE_COLOR_MASK
	color.rgb = lerp( color, color * CHANGE_COLOR, color.a ).rgb;
	color.a *= CHANGE_COLOR.a;
#endif

#ifdef ITEM_IN_HAND
	color.rgb = lerp(color, color * CHANGE_COLOR, color.a).rgb;
#endif

#endif

#ifdef USE_MULTITEXTURE
	float4 tex1 = TEXTURE_1.Sample(TextureSampler1, PSInput.uv);
	float4 tex2 = TEXTURE_2.Sample(TextureSampler2, PSInput.uv);
	color.rgb = lerp(color.rgb, tex1, tex1.a);
#ifdef ALPHA_TEST
	if (color.a < 0.5f && tex1.a == 0.0f) {
		discard;
	}
#endif

#ifdef COLOR_SECOND_TEXTURE
	if (tex2.a > 0.0f) {
		color.rgb = lerp(tex2.rgb, tex2 * CHANGE_COLOR, tex2.a);
	}
#else
	color.rgb = lerp(color.rgb, tex2, tex2.a);
#endif
#endif

#ifdef MULTIPLICATIVE_TINT
	float4 tintTex = TEXTURE_1.Sample(TextureSampler1, PSInput.uv);

#ifdef MULTIPLICATIVE_TINT_COLOR 
	tintTex.rgb = tintTex.rgb * MULTIPLICATIVE_TINT_CHANGE_COLOR.rgb;
#endif

#ifdef ALPHA_TEST
	color.rgb = lerp(color.rgb, tintTex.rgb, tintTex.a);
	if (color.a + tintTex.a <= 0.0f) {
		discard;
	}
#endif
#endif

#ifdef USE_OVERLAY
	//use either the diffuse or the OVERLAY_COLOR
	color.rgb = lerp( color, PSInput.overlayColor, PSInput.overlayColor.a ).rgb;

#endif


#ifdef USE_EMISSIVE
	//make glowy stuff
	color *= lerp( float( 1.0 ).xxxx, PSInput.light, color.a );
#else
	color *= PSInput.light;
#endif

	//apply fog
    #ifdef FOG
	color.rgb = lerp( color.rgb, PSInput.fogColor.rgb, PSInput.fogColor.a );
#endif

#ifdef GLINT
	// Applies color mask to glint texture instead and blends with original color
	float4 layer1 = TEXTURE_1.Sample(TextureSampler1, frac(PSInput.layerUV.xy)).rgbr * GLINT_COLOR;
	float4 layer2 = TEXTURE_1.Sample(TextureSampler1, frac(PSInput.layerUV.zw)).rgbr * GLINT_COLOR;
	float4 glint = (layer1 + layer2) * TILE_LIGHT_COLOR;
	color = glintBlend(color, glint);
#endif

    #ifdef ENABLE_OUTLINE
    #ifndef UI_ENTITY
    #ifndef ARMOR_STAND
       #ifndef BEACON
        if(PSInput.edge>0.5){
            float3 viewRay=-mul(WORLD,float4(PSInput.worldpos,1)).rgb;
            float3 viewDir=normalize(viewRay);
            float3 normal=normalize(cross(-ddy(viewRay),-ddx(viewRay)));
 if(dot(viewDir,mul(WORLD,float4(PSInput.normal,0)).rgb)<0){
    discard;
    }
#ifndef NO_TEXTURE

    if(abs(PSInput.normal.y)>0.99&&(PSInput.worldpos.y/PSInput.mt)>0.496&&(PSInput.worldpos.y/PSInput.mt)<0.497)
    discard;

        #endif


#ifdef IS_CHEST
#ifndef IS_SHULKER_BOX

    if(abs(PSInput.normal.y)>0.99&&(PSInput.worldpos.y/PSInput.mt)>0.36&&(PSInput.worldpos.y/PSInput.mt)<0.45)
    discard;
        #endif
        #endif

#ifdef IS_SHULKER_BOX

    if(abs(PSInput.normal.y)>0.99&&abs((PSInput.worldpos.y/PSInput.mt)-16)<0.1)
    discard;
        #endif

       #ifdef USE_BLEND
       
    float3x3 TBN;
    if(min(PSInput.normal.z,-PSInput.normal.x)<-0.999||(abs(PSInput.worldpos.y/PSInput.mt)<0.501&&abs(PSInput.normal.y)>0.99)||
    (abs(PSInput.worldpos.y/PSInput.mt)>0.55&&abs(PSInput.normal.y)>0.99))
    TBN = float3x3(PSInput.tangent, PSInput.bitangent, -normal);
    else
    TBN = float3x3(PSInput.tangent, PSInput.bitangent, normal);

float3 box_min;
float3 box_max;
if(abs(PSInput.worldpos.x/PSInput.mt)<0.1&&abs(PSInput.normal.x)>0.99){
box_min=float3(-0.5,-0.5,-7.5/16.0)*1.2;
box_max=float3( 0.5, 0.5, -7/16.0)*1.2;
}else if(abs(PSInput.worldpos.z/PSInput.mt)>0.55&&abs(PSInput.normal.z)>0.99){
box_min=float3(-1/16.0,-0.5,-1)*1.2;
box_max=float3( 1/16.0, 0.5, 0)*1.2;
}else if(abs(PSInput.worldpos.y/PSInput.mt)>0.55&&abs(PSInput.normal.y)>0.99){
box_min=float3(-1/16.0,-0.5,-1)*1.2;
box_max=float3( 1/16.0, 0.5,0)*1.2;
}else{
box_min=float3(-0.5,-0.5,-1);
box_max=float3( 0.5, 0.5, 0);
}

float3 ppos=0;

if(abs(PSInput.normal.y)>0.999)
ppos=float3(PSInput.worldpos.x,-sign(PSInput.normal.y)*PSInput.worldpos.z,abs(PSInput.worldpos.y)-0.5);
else if(abs(PSInput.normal.z)>0.999)
ppos=float3(PSInput.worldpos.x,sign(PSInput.normal.z)*PSInput.worldpos.y,abs(PSInput.worldpos.z)-0.5);
else
ppos=float3(PSInput.worldpos.z,-sign(PSInput.normal.x)*PSInput.worldpos.y,abs(PSInput.worldpos.x)-0.5);

    float2 intersections = LineBoxIntersect(ppos-mul(TBN,-viewDir)*10,ppos+mul(TBN,-viewDir)*10,box_min,box_max);

    if(intersections.y>intersections.x)
    discard;
        #endif

    color.rgba=1;
    }
        #endif
        #endif
        #endif
        #endif


    // #ifndef UI_ENTITY

// for(int i1=0;i1<4;i1++)
// for(int i2=0;i2<4;i2++)
// {
// float k=abs(WORLD[i2][i1]);
// int i=-1;

// float3 cp=(PSInput.worldpos-0.5);
    //   cp.x =cp.x*15+0.5+3.75*i1;
    //   cp.z =cp.z*10+1+2.5*i2;
// while(i<=4){
// int cc=((int)(k*pow(10,i)+0.01))%10;
// if(i==1){
    //   cp.x +=0.1;
                    //   if ((cp.x <=0.25 && cp.x >=0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25))
    // color.rgba=1;
// }
// i++;
    //   cp.x +=0.5;
            // if (cc == 0) {
                // if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25)) {
    // color.rgba=1;
                // }
            // } else if (cc == 1) {
                // if ((cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.35) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65)) {
    // color.rgba=1;
                // }
            // } else if (cc == 2) {
                // if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65)) {
    // color.rgba=1;
                // }
            // } else if (cc == 3) {
                // if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65)) {
    // color.rgba=1;
                // }
            // } else if (cc == 4) {
                // if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45)) {
    // color.rgba=1;
                // }
            // } else if (cc == 5) {
                // if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25)) {
    // color.rgba=1;
                // }
            // } else if (cc == 6) {
                // if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.35) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25)) {
    // color.rgba=1;
                // }
            // } else if (cc == 7) {
                // if ((cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.65 &&
                    //  cp.z >= 0.55)) {
    // color.rgba=1;
                // }
            // } else if (cc == 8) {
                // if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65) ||
                    // (cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25)) {
    // color.rgba=1;
                // }
            // } else if (cc == 9) {
                // if ((cp.x <= 0.3 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.55 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.2 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.35) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.3 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.45) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.1 + 0.15 && cp.z <= 0.35 &&
                    //  cp.z >= 0.25) ||
                    // (cp.x <= 0.4 + 0.15 && cp.x >= 0.2 + 0.15 && cp.z <= 0.75 &&
                    //  cp.z >= 0.65)) {
    // color.rgba=1;
                // }
            // }
// }
// }
        // #endif


	//WARNING do not refactor this 
	PSOutput.color = color;
#ifdef UI_ENTITY
	PSOutput.color.a *= HUD_OPACITY;
#endif

#ifdef VR_MODE
	// On Rift, the transition from 0 brightness to the lowest 8 bit value is abrupt, so clamp to 
	// the lowest 8 bit value.
	PSOutput.color = max(PSOutput.color, 1 / 255.0f);
#endif
}
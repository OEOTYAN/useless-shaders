//Instancing=On
//RenderAsBillboards=Off
//Seasons=Off

varying highp vec4 v_color0;
varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
varying highp vec2 v_texcoord0;
uniform highp vec4 FogColor;
uniform sampler2D s_MatTexture;
uniform sampler2D s_LightMapTexture;
void main ()
{
  lowp vec4 diffuse_1;
  diffuse_1.xyz = (texture2D (s_MatTexture, v_texcoord0).xyz * v_color0.xyz);
  diffuse_1.w = v_color0.w;
  mediump vec4 tmpvar_2;
  lowp vec4 tmpvar_3;
  tmpvar_3.xyz = (texture2D (s_LightMapTexture, v_lightmapUV).xyz * diffuse_1.xyz);
  tmpvar_3.w = diffuse_1.w;
  tmpvar_2 = tmpvar_3;
  mediump vec4 tmpvar_4;
  tmpvar_4.w = tmpvar_2.w;
  tmpvar_4.xyz = mix (tmpvar_2.xyz, FogColor.xyz, v_fog.w);
  gl_FragColor = tmpvar_4;
}


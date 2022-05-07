//Instancing=On
//RenderAsBillboards=Off
//Seasons=On

varying highp vec4 v_color0;
varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
varying highp vec2 v_texcoord0;
uniform highp vec4 FogColor;
uniform sampler2D s_MatTexture;
uniform sampler2D s_LightMapTexture;
uniform sampler2D s_SeasonsTexture;
void main ()
{
  lowp vec4 tmpvar_1;
  tmpvar_1 = texture2D (s_MatTexture, v_texcoord0);
  lowp vec4 diffuse_2;
  diffuse_2.w = tmpvar_1.w;
  diffuse_2.xyz = (tmpvar_1.xyz * mix (vec3(1.0, 1.0, 1.0), (texture2D (s_SeasonsTexture, v_color0.xy).xyz * 2.0), v_color0.z));
  diffuse_2.xyz = (diffuse_2.xyz * v_color0.www);
  diffuse_2.w = 1.0;
  mediump vec4 tmpvar_3;
  lowp vec4 tmpvar_4;
  tmpvar_4.xyz = (texture2D (s_LightMapTexture, v_lightmapUV).xyz * diffuse_2.xyz);
  tmpvar_4.w = diffuse_2.w;
  tmpvar_3 = tmpvar_4;
  mediump vec4 tmpvar_5;
  tmpvar_5.w = tmpvar_3.w;
  tmpvar_5.xyz = mix (tmpvar_3.xyz, FogColor.xyz, v_fog.w);
  gl_FragColor = tmpvar_5;
}


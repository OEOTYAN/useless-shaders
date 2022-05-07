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
  lowp vec4 tmpvar_2;
  tmpvar_2 = texture2D (s_MatTexture, v_texcoord0);
  diffuse_1.w = tmpvar_2.w;
  if ((tmpvar_2.w < 0.5)) {
    discard;
  };
  diffuse_1.xyz = (tmpvar_2.xyz * v_color0.xyz);
  mediump vec4 tmpvar_3;
  lowp vec4 tmpvar_4;
  tmpvar_4.xyz = (texture2D (s_LightMapTexture, v_lightmapUV).xyz * diffuse_1.xyz);
  tmpvar_4.w = diffuse_1.w;
  tmpvar_3 = tmpvar_4;
  mediump vec4 tmpvar_5;
  tmpvar_5.w = tmpvar_3.w;
  tmpvar_5.xyz = mix (tmpvar_3.xyz, FogColor.xyz, v_fog.w);
  gl_FragColor = tmpvar_5;
}


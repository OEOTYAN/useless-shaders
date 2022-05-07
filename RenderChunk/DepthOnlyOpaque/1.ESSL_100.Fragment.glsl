//Instancing=On
//RenderAsBillboards=On
//Seasons=Off

varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
uniform highp vec4 FogColor;
uniform sampler2D s_LightMapTexture;
void main ()
{
  mediump vec4 tmpvar_1;
  lowp vec4 tmpvar_2;
  tmpvar_2.xyz = texture2D (s_LightMapTexture, v_lightmapUV).xyz;
  tmpvar_2.w = 1.0;
  tmpvar_1 = tmpvar_2;
  mediump vec4 tmpvar_3;
  tmpvar_3.w = tmpvar_1.w;
  tmpvar_3.xyz = mix (tmpvar_1.xyz, FogColor.xyz, v_fog.w);
  gl_FragColor = tmpvar_3;
}


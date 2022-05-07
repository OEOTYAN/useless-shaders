//Instancing=On
//RenderAsBillboards=Off
//Seasons=On

varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
varying highp vec2 v_texcoord0;
uniform highp vec4 FogColor;
uniform sampler2D s_MatTexture;
uniform sampler2D s_LightMapTexture;
void main ()
{
  lowp vec4 tmpvar_1;
  tmpvar_1 = texture2D (s_MatTexture, v_texcoord0);
  if ((tmpvar_1.w < 0.5)) {
    discard;
  };
  mediump vec4 tmpvar_2;
  lowp vec4 tmpvar_3;
  tmpvar_3.xyz = texture2D (s_LightMapTexture, v_lightmapUV).xyz;
  tmpvar_3.w = 1.0;
  tmpvar_2 = tmpvar_3;
  mediump vec4 tmpvar_4;
  tmpvar_4.w = tmpvar_2.w;
  tmpvar_4.xyz = mix (tmpvar_2.xyz, FogColor.xyz, v_fog.w);
  gl_FragColor = tmpvar_4;
}


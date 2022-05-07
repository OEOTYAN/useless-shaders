//Instancing=On
//RenderAsBillboards=On
//Seasons=Off

attribute highp vec4 a_color0;
attribute highp vec3 a_position;
attribute highp vec2 a_texcoord0;
attribute highp vec2 a_texcoord1;
attribute highp vec4 i_data0;
attribute highp vec4 i_data1;
attribute highp vec4 i_data2;
attribute highp vec4 i_data3;
varying highp vec4 v_color0;
varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
varying highp vec2 v_texcoord0;
uniform highp mat4 u_viewProj;
uniform highp vec4 RenderChunkFogAlpha;
uniform highp vec4 FogAndDistanceControl;
uniform highp vec4 ViewPositionAndTime;
uniform highp vec4 FogColor;
void main ()
{
  highp mat4 model_1;
  model_1[0] = i_data0;
  model_1[1] = i_data1;
  model_1[2] = i_data2;
  model_1[3] = i_data3;
  highp vec4 tmpvar_2;
  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = a_position;
  highp vec4 tmpvar_3;
  highp vec4 tmpvar_4;
  highp vec3 tmpvar_5;
  tmpvar_5 = ((model_1 * tmpvar_2).xyz + vec3(0.5, 0.5, 0.5));
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize((tmpvar_5 - ViewPositionAndTime.xyz));
  highp vec3 tmpvar_7;
  tmpvar_7 = normalize(((vec3(1.0, 0.0, 0.0) * tmpvar_6.zxy) - (vec3(0.0, 0.0, 1.0) * tmpvar_6.yzx)));
  tmpvar_5 = (tmpvar_5 - ((
    ((tmpvar_6.yzx * tmpvar_7.zxy) - (tmpvar_6.zxy * tmpvar_7.yzx))
   * 
    (a_color0.z - 0.5)
  ) + (tmpvar_7 * 
    (a_color0.x - 0.5)
  )));
  highp vec4 tmpvar_8;
  tmpvar_8.w = 1.0;
  tmpvar_8.xyz = tmpvar_5;
  tmpvar_4 = (u_viewProj * tmpvar_8);
  highp float tmpvar_9;
  highp vec3 x_10;
  x_10 = (ViewPositionAndTime.xyz - tmpvar_5);
  tmpvar_9 = sqrt(dot (x_10, x_10));
  highp vec4 tmpvar_11;
  tmpvar_11.xyz = FogColor.xyz;
  tmpvar_11.w = clamp (((
    ((tmpvar_9 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  tmpvar_3 = vec4(1.0, 1.0, 1.0, 1.0);
  if ((a_color0.w < 0.95)) {
    tmpvar_3.w = mix (a_color0.w, 1.0, clamp ((tmpvar_9 / FogAndDistanceControl.w), 0.0, 1.0));
  };
  v_texcoord0 = a_texcoord0;
  v_lightmapUV = a_texcoord1;
  v_color0 = tmpvar_3;
  v_fog = tmpvar_11;
  gl_Position = tmpvar_4;
}


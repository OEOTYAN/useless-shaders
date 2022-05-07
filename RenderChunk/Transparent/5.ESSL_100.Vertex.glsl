//Instancing=On
//RenderAsBillboards=Off
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
  highp vec4 tmpvar_1;
  highp mat4 model_2;
  model_2[0] = i_data0;
  model_2[1] = i_data1;
  model_2[2] = i_data2;
  model_2[3] = i_data3;
  highp vec4 tmpvar_3;
  tmpvar_3.w = 1.0;
  tmpvar_3.xyz = a_position;
  highp vec3 tmpvar_4;
  tmpvar_4 = (model_2 * tmpvar_3).xyz;
  highp vec4 tmpvar_5;
  tmpvar_5.w = 1.0;
  tmpvar_5.xyz = tmpvar_4;
  tmpvar_1 = (u_viewProj * tmpvar_5);
  highp vec4 tmpvar_6;
  highp float tmpvar_7;
  highp vec3 x_8;
  x_8 = (ViewPositionAndTime.xyz - tmpvar_4);
  tmpvar_7 = sqrt(dot (x_8, x_8));
  highp vec4 tmpvar_9;
  tmpvar_9.xyz = FogColor.xyz;
  tmpvar_9.w = clamp (((
    ((tmpvar_7 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  tmpvar_6 = a_color0;
  if ((a_color0.w < 0.95)) {
    tmpvar_6.w = mix (a_color0.w, 1.0, clamp ((tmpvar_7 / FogAndDistanceControl.w), 0.0, 1.0));
  };
  v_texcoord0 = a_texcoord0;
  v_lightmapUV = a_texcoord1;
  v_color0 = tmpvar_6;
  v_fog = tmpvar_9;
  gl_Position = tmpvar_1;
}


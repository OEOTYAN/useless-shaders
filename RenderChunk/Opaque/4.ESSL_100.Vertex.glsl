//Instancing=On
//RenderAsBillboards=Off
//Seasons=On

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
  tmpvar_3 = (model_1 * tmpvar_2);
  highp vec4 tmpvar_4;
  tmpvar_4.w = 1.0;
  tmpvar_4.xyz = tmpvar_3.xyz;
  highp vec3 x_5;
  x_5 = (ViewPositionAndTime.xyz - tmpvar_3.xyz);
  highp vec4 tmpvar_6;
  tmpvar_6.xyz = FogColor.xyz;
  tmpvar_6.w = clamp (((
    ((sqrt(dot (x_5, x_5)) / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  v_texcoord0 = a_texcoord0;
  v_color0 = a_color0;
  v_lightmapUV = a_texcoord1;
  v_fog = tmpvar_6;
  gl_Position = (u_viewProj * tmpvar_4);
}


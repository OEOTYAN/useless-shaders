//Instancing=Off
//RenderAsBillboards=Off
//Seasons=Off

attribute highp vec4 a_color0;
attribute highp vec3 a_position;
attribute highp vec2 a_texcoord0;
attribute highp vec2 a_texcoord1;
varying highp vec4 v_color0;
varying highp vec4 v_fog;
varying highp vec2 v_lightmapUV;
varying highp vec2 v_texcoord0;
uniform highp mat4 u_viewProj;
uniform mat4 u_model[4];
uniform highp vec4 RenderChunkFogAlpha;
uniform highp vec4 FogAndDistanceControl;
uniform highp vec4 ViewPositionAndTime;
uniform highp vec4 FogColor;
void main ()
{
  highp vec4 tmpvar_1;
  tmpvar_1.w = 1.0;
  tmpvar_1.xyz = a_position;
  highp vec3 tmpvar_2;
  tmpvar_2 = (u_model[0] * tmpvar_1).xyz;
  highp vec4 tmpvar_3;
  tmpvar_3.w = 1.0;
  tmpvar_3.xyz = tmpvar_2;
  highp vec3 x_4;
  x_4 = (ViewPositionAndTime.xyz - tmpvar_2);
  highp vec4 tmpvar_5;
  tmpvar_5.xyz = FogColor.xyz;
  tmpvar_5.w = clamp (((
    ((sqrt(dot (x_4, x_4)) / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  v_texcoord0 = a_texcoord0;
  v_color0 = a_color0;
  v_lightmapUV = a_texcoord1;
  v_fog = tmpvar_5;
  gl_Position = (u_viewProj * tmpvar_3);
}


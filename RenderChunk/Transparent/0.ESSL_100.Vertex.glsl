//Instancing=Off
//RenderAsBillboards=Off
//Seasons=On

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
  highp vec4 tmpvar_2;
  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = a_position;
  highp vec3 tmpvar_3;
  tmpvar_3 = (u_model[0] * tmpvar_2).xyz;
  highp vec4 tmpvar_4;
  tmpvar_4.w = 1.0;
  tmpvar_4.xyz = tmpvar_3;
  tmpvar_1 = (u_viewProj * tmpvar_4);
  highp vec4 tmpvar_5;
  highp float tmpvar_6;
  highp vec3 x_7;
  x_7 = (ViewPositionAndTime.xyz - tmpvar_3);
  tmpvar_6 = sqrt(dot (x_7, x_7));
  highp vec4 tmpvar_8;
  tmpvar_8.xyz = FogColor.xyz;
  tmpvar_8.w = clamp (((
    ((tmpvar_6 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  tmpvar_5 = a_color0;
  if ((a_color0.w < 0.95)) {
    tmpvar_5.w = mix (a_color0.w, 1.0, clamp ((tmpvar_6 / FogAndDistanceControl.w), 0.0, 1.0));
  };
  v_texcoord0 = a_texcoord0;
  v_lightmapUV = a_texcoord1;
  v_color0 = tmpvar_5;
  v_fog = tmpvar_8;
  gl_Position = tmpvar_1;
}


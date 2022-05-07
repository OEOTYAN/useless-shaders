//Instancing=Off
//RenderAsBillboards=On
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
  highp vec4 tmpvar_2;
  highp vec4 tmpvar_3;
  highp vec3 tmpvar_4;
  tmpvar_4 = ((u_model[0] * tmpvar_1).xyz + vec3(0.5, 0.5, 0.5));
  highp vec3 tmpvar_5;
  tmpvar_5 = normalize((tmpvar_4 - ViewPositionAndTime.xyz));
  highp vec3 tmpvar_6;
  tmpvar_6 = normalize(((vec3(1.0, 0.0, 0.0) * tmpvar_5.zxy) - (vec3(0.0, 0.0, 1.0) * tmpvar_5.yzx)));
  tmpvar_4 = (tmpvar_4 - ((
    ((tmpvar_5.yzx * tmpvar_6.zxy) - (tmpvar_5.zxy * tmpvar_6.yzx))
   * 
    (a_color0.z - 0.5)
  ) + (tmpvar_6 * 
    (a_color0.x - 0.5)
  )));
  highp vec4 tmpvar_7;
  tmpvar_7.w = 1.0;
  tmpvar_7.xyz = tmpvar_4;
  tmpvar_3 = (u_viewProj * tmpvar_7);
  highp float tmpvar_8;
  highp vec3 x_9;
  x_9 = (ViewPositionAndTime.xyz - tmpvar_4);
  tmpvar_8 = sqrt(dot (x_9, x_9));
  highp vec4 tmpvar_10;
  tmpvar_10.xyz = FogColor.xyz;
  tmpvar_10.w = clamp (((
    ((tmpvar_8 / FogAndDistanceControl.z) + RenderChunkFogAlpha.x)
   - FogAndDistanceControl.x) / (FogAndDistanceControl.y - FogAndDistanceControl.x)), 0.0, 1.0);
  tmpvar_2 = vec4(1.0, 1.0, 1.0, 1.0);
  if ((a_color0.w < 0.95)) {
    tmpvar_2.w = mix (a_color0.w, 1.0, clamp ((tmpvar_8 / FogAndDistanceControl.w), 0.0, 1.0));
  };
  v_texcoord0 = a_texcoord0;
  v_lightmapUV = a_texcoord1;
  v_color0 = tmpvar_2;
  v_fog = tmpvar_10;
  gl_Position = tmpvar_3;
}


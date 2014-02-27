//************************************************************************************
//
// Filename    :   OVRLensCorrection.shader
// Content     :   Full screen shader
//				   This shader warps the final camera image to match the lens curvature on the Rift.
// Created     :   January 17, 2013
// Authors     :   Peter Giokaris
//
// Copyright   :   Copyright 2013 Oculus VR, Inc. All Rights reserved.
//
// Use of this software is subject to the terms of the Oculus LLC license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
//
//************************************************************************************/

Shader "OVRLensCorrection" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}
	
	// Shader code pasted into all further CGPROGRAM blocks
	#LINE 81
 
	
Subshader {
 Pass {
	  ZTest Always Cull Off ZWrite Off
	  Fog { Mode off }      

      Program "vp" {
// Vertex combos: 1
//   opengl - ALU: 5 to 5
//   d3d9 - ALU: 5 to 5
//   d3d11 - ALU: 4 to 4, TEX: 0 to 0, FLOW: 1 to 1
//   d3d11_9x - ALU: 4 to 4, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
"!!ARBvp1.0
# 5 ALU
PARAM c[5] = { program.local[0],
		state.matrix.mvp };
MOV result.texcoord[0].xy, vertex.texcoord[0];
DP4 result.position.w, vertex.position, c[4];
DP4 result.position.z, vertex.position, c[3];
DP4 result.position.y, vertex.position, c[2];
DP4 result.position.x, vertex.position, c[1];
END
# 5 instructions, 0 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
"vs_2_0
; 5 ALU
dcl_position0 v0
dcl_texcoord0 v1
mov oT0.xy, v1
dp4 oPos.w, v0, c3
dp4 oPos.z, v0, c2
dp4 oPos.y, v0, c1
dp4 oPos.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "UnityPerDraw" 0
// 6 instructions, 1 temp regs, 0 temp arrays:
// ALU 4 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedgcclnnbgpijgpddakojponflfpghdgniabaaaaaaoeabaaaaadaaaaaa
cmaaaaaaiaaaaaaaniaaaaaaejfdeheoemaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfceeaaklkl
epfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaadamaaaa
fdfgfpfagphdgjhegjgpgoaafeeffiedepepfceeaaklklklfdeieefcaeabaaaa
eaaaabaaebaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaafpaaaaadpcbabaaa
aaaaaaaafpaaaaaddcbabaaaabaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaa
gfaaaaaddccabaaaabaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaa
fgbfbaaaaaaaaaaaegiocaaaaaaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaaaaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaaaaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaaaaaaaaaadaaaaaapgbpbaaa
aaaaaaaaegaobaaaaaaaaaaadgaaaaafdccabaaaabaaaaaaegbabaaaabaaaaaa
doaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec2 xlv_TEXCOORD0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  highp vec2 tmpvar_1;
  mediump vec2 tmpvar_2;
  tmpvar_2 = _glesMultiTexCoord0.xy;
  tmpvar_1 = tmpvar_2;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _HmdWarpParam;
uniform highp vec2 _Scale;
uniform highp vec2 _ScaleIn;
uniform highp vec2 _Center;
uniform sampler2D _MainTex;
void main ()
{
  mediump vec4 tmpvar_1;
  highp vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  tmpvar_3 = ((xlv_TEXCOORD0 - _Center) * _ScaleIn);
  highp float tmpvar_4;
  tmpvar_4 = ((tmpvar_3.x * tmpvar_3.x) + (tmpvar_3.y * tmpvar_3.y));
  tmpvar_2 = (_Center + (_Scale * (tmpvar_3 * ((_HmdWarpParam.x + (_HmdWarpParam.y * tmpvar_4)) + ((_HmdWarpParam.z * tmpvar_4) * tmpvar_4)))));
  bvec2 tmpvar_5;
  tmpvar_5 = bvec2((clamp (tmpvar_2, vec2(0.0, 0.0), vec2(1.0, 1.0)) - tmpvar_2));
  bool tmpvar_6;
  tmpvar_6 = any(tmpvar_5);
  if (tmpvar_6) {
    tmpvar_1 = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    lowp vec4 tmpvar_7;
    tmpvar_7 = texture2D (_MainTex, tmpvar_2);
    tmpvar_1 = tmpvar_7;
  };
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES


#ifdef VERTEX

varying highp vec2 xlv_TEXCOORD0;
uniform highp mat4 glstate_matrix_mvp;
attribute vec4 _glesMultiTexCoord0;
attribute vec4 _glesVertex;
void main ()
{
  highp vec2 tmpvar_1;
  mediump vec2 tmpvar_2;
  tmpvar_2 = _glesMultiTexCoord0.xy;
  tmpvar_1 = tmpvar_2;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = tmpvar_1;
}



#endif
#ifdef FRAGMENT

varying highp vec2 xlv_TEXCOORD0;
uniform highp vec4 _HmdWarpParam;
uniform highp vec2 _Scale;
uniform highp vec2 _ScaleIn;
uniform highp vec2 _Center;
uniform sampler2D _MainTex;
void main ()
{
  mediump vec4 tmpvar_1;
  highp vec2 tmpvar_2;
  highp vec2 tmpvar_3;
  tmpvar_3 = ((xlv_TEXCOORD0 - _Center) * _ScaleIn);
  highp float tmpvar_4;
  tmpvar_4 = ((tmpvar_3.x * tmpvar_3.x) + (tmpvar_3.y * tmpvar_3.y));
  tmpvar_2 = (_Center + (_Scale * (tmpvar_3 * ((_HmdWarpParam.x + (_HmdWarpParam.y * tmpvar_4)) + ((_HmdWarpParam.z * tmpvar_4) * tmpvar_4)))));
  bvec2 tmpvar_5;
  tmpvar_5 = bvec2((clamp (tmpvar_2, vec2(0.0, 0.0), vec2(1.0, 1.0)) - tmpvar_2));
  bool tmpvar_6;
  tmpvar_6 = any(tmpvar_5);
  if (tmpvar_6) {
    tmpvar_1 = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    lowp vec4 tmpvar_7;
    tmpvar_7 = texture2D (_MainTex, tmpvar_2);
    tmpvar_1 = tmpvar_7;
  };
  gl_FragData[0] = tmpvar_1;
}



#endif"
}

SubProgram "flash " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
"agal_vs
[bc]
aaaaaaaaaaaaadaeadaaaaoeaaaaaaaaaaaaaaaaaaaaaaaa mov v0.xy, a3
bdaaaaaaaaaaaiadaaaaaaoeaaaaaaaaadaaaaoeabaaaaaa dp4 o0.w, a0, c3
bdaaaaaaaaaaaeadaaaaaaoeaaaaaaaaacaaaaoeabaaaaaa dp4 o0.z, a0, c2
bdaaaaaaaaaaacadaaaaaaoeaaaaaaaaabaaaaoeabaaaaaa dp4 o0.y, a0, c1
bdaaaaaaaaaaabadaaaaaaoeaaaaaaaaaaaaaaoeabaaaaaa dp4 o0.x, a0, c0
aaaaaaaaaaaaamaeaaaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov v0.zw, c0
"
}

SubProgram "d3d11_9x " {
Keywords { }
Bind "vertex" Vertex
Bind "texcoord" TexCoord0
ConstBuffer "UnityPerDraw" 336 // 64 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
BindCB "UnityPerDraw" 0
// 6 instructions, 1 temp regs, 0 temp arrays:
// ALU 4 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0_level_9_1
eefiecedmldjmmohbhmjmnnblgkeoagbliecmmbkabaaaaaalmacaaaaaeaaaaaa
daaaaaaaaeabaaaabaacaaaageacaaaaebgpgodjmmaaaaaammaaaaaaaaacpopp
jiaaaaaadeaaaaaaabaaceaaaaaadaaaaaaadaaaaaaaceaaabaadaaaaaaaaaaa
aeaaabaaaaaaaaaaaaaaaaaaaaacpoppbpaaaaacafaaaaiaaaaaapjabpaaaaac
afaaabiaabaaapjaafaaaaadaaaaapiaaaaaffjaacaaoekaaeaaaaaeaaaaapia
abaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaadaaoekaaaaakkjaaaaaoeia
aeaaaaaeaaaaapiaaeaaoekaaaaappjaaaaaoeiaaeaaaaaeaaaaadmaaaaappia
aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaacaaaaadoaabaaoeja
ppppaaaafdeieefcaeabaaaaeaaaabaaebaaaaaafjaaaaaeegiocaaaaaaaaaaa
aeaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaaddcbabaaaabaaaaaaghaaaaae
pccabaaaaaaaaaaaabaaaaaagfaaaaaddccabaaaabaaaaaagiaaaaacabaaaaaa
diaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaaaaaaaaaabaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaaaaaaaaaaagbabaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaaaaaaaaaacaaaaaa
kgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaa
aaaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafdccabaaa
abaaaaaaegbabaaaabaaaaaadoaaaaabejfdeheoemaaaaaaacaaaaaaaiaaaaaa
diaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaaebaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaadadaaaafaepfdejfeejepeoaafeeffiedepepfc
eeaaklklepfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaaaaaaaaaaabaaaaaa
adaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaa
adamaaaafdfgfpfagphdgjhegjgpgoaafeeffiedepepfceeaaklklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct v2f {
    highp vec4 pos;
    highp vec2 uv;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 321
uniform sampler2D _MainTex;
#line 329
uniform highp vec2 _Center = vec2( 0.0, 0.0);
uniform highp vec2 _ScaleIn = vec2( 0.0, 0.0);
uniform highp vec2 _Scale = vec2( 0.0, 0.0);
uniform highp vec4 _HmdWarpParam = vec4( 0.0, 0.0, 0.0, 0.0);
#line 333
#line 346
#line 322
v2f vert( in appdata_img v ) {
    v2f o;
    #line 325
    o.pos = (glstate_matrix_mvp * v.vertex);
    o.uv = v.texcoord.xy;
    return o;
}
out highp vec2 xlv_TEXCOORD0;
void main() {
    v2f xl_retval;
    appdata_img xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.texcoord = vec2(gl_MultiTexCoord0);
    xl_retval = vert( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec2(xl_retval.uv);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];

#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct v2f {
    highp vec4 pos;
    highp vec2 uv;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform highp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 321
uniform sampler2D _MainTex;
#line 329
uniform highp vec2 _Center = vec2( 0.0, 0.0);
uniform highp vec2 _ScaleIn = vec2( 0.0, 0.0);
uniform highp vec2 _Scale = vec2( 0.0, 0.0);
uniform highp vec4 _HmdWarpParam = vec4( 0.0, 0.0, 0.0, 0.0);
#line 333
#line 346
#line 333
highp vec2 HmdWarp( in highp vec2 in01 ) {
    highp vec2 vecFromCenter = ((in01 - _Center) * _ScaleIn);
    highp float rSq = ((vecFromCenter.x * vecFromCenter.x) + (vecFromCenter.y * vecFromCenter.y));
    #line 337
    highp vec2 vecResult = (vecFromCenter * ((_HmdWarpParam.x + (_HmdWarpParam.y * rSq)) + ((_HmdWarpParam.z * rSq) * rSq)));
    return (_Center + (_Scale * vecResult));
}
#line 340
mediump vec4 GetColor( in highp vec2 uv ) {
    #line 342
    highp vec2 tc = HmdWarp( uv);
    if (any(bvec2((clamp( tc, vec2( 0.0, 0.0), vec2( 1.0, 1.0)) - tc)))){
        return vec4( 0.0);
    }
    else{
        return texture( _MainTex, tc);
    }
}
#line 346
mediump vec4 frag( in v2f i ) {
    highp vec2 tc = i.uv;
    mediump vec4 c = vec4( 0.0);
    #line 350
    c += GetColor( tc);
    return c;
}
in highp vec2 xlv_TEXCOORD0;
void main() {
    mediump vec4 xl_retval;
    v2f xlt_i;
    xlt_i.pos = vec4(0.0);
    xlt_i.uv = vec2(xlv_TEXCOORD0);
    xl_retval = frag( xlt_i);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 1
//   opengl - ALU: 19 to 19, TEX: 1 to 1
//   d3d9 - ALU: 18 to 18, TEX: 1 to 1
//   d3d11 - ALU: 11 to 11, TEX: 1 to 1, FLOW: 3 to 3
//   d3d11_9x - ALU: 11 to 11, TEX: 1 to 1, FLOW: 3 to 3
SubProgram "opengl " {
Keywords { }
Vector 0 [_Center]
Vector 1 [_ScaleIn]
Vector 2 [_Scale]
Vector 3 [_HmdWarpParam]
SetTexture 0 [_MainTex] 2D
"!!ARBfp1.0
OPTION ARB_precision_hint_fastest;
# 19 ALU, 1 TEX
PARAM c[5] = { program.local[0..3],
		{ 1, 0 } };
TEMP R0;
TEMP R1;
ADD R0.xy, fragment.texcoord[0], -c[0];
MUL R0.xy, R0, c[1];
MUL R0.z, R0.y, R0.y;
MAD R0.z, R0.x, R0.x, R0;
MAD R1.x, R0.z, c[3].y, c[3];
MUL R0.w, R0.z, c[3].z;
MAD R0.z, R0.w, R0, R1.x;
MUL R0.xy, R0, R0.z;
MUL R0.xy, R0, c[2];
ADD R1.xy, R0, c[0];
MOV_SAT R1.zw, R1.xyxy;
TEX R0, R1, texture[0], 2D;
ADD R1.xy, R1.zwzw, -R1;
ABS R1.xy, R1;
CMP R1.xy, -R1, c[4].x, c[4].y;
ADD_SAT R1.x, R1, R1.y;
ABS R1.x, R1;
CMP R1.x, -R1, c[4].y, c[4];
CMP result.color, -R1.x, R0, c[4].y;
END
# 19 instructions, 2 R-regs
"
}

SubProgram "d3d9 " {
Keywords { }
Vector 0 [_Center]
Vector 1 [_ScaleIn]
Vector 2 [_Scale]
Vector 3 [_HmdWarpParam]
SetTexture 0 [_MainTex] 2D
"ps_2_0
; 18 ALU, 1 TEX
dcl_2d s0
def c4, 0.00000000, 1.00000000, 0, 0
dcl t0.xy
add r0.xy, t0, -c0
mul r3.xy, r0, c1
mul r0.x, r3.y, r3.y
mad r0.x, r3, r3, r0
mad r2.x, r0, c3.y, c3
mul r1.x, r0, c3.z
mad r0.x, r1, r0, r2
mul r0.xy, r3, r0.x
mul r0.xy, r0, c2
add r0.xy, r0, c0
mov_sat r2.xy, r0
texld r1, r0, s0
add r0.xy, r2, -r0
abs r0.xy, r0
cmp r0.xy, -r0, c4.x, c4.y
add_pp_sat r0.x, r0, r0.y
abs_pp r0.x, r0
cmp_pp r0, -r0.x, r1, c4.x
mov_pp oC0, r0
"
}

SubProgram "d3d11 " {
Keywords { }
ConstBuffer "$Globals" 64 // 64 used size, 5 vars
Vector 16 [_Center] 2
Vector 24 [_ScaleIn] 2
Vector 32 [_Scale] 2
Vector 48 [_HmdWarpParam] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 19 instructions, 2 temp regs, 0 temp arrays:
// ALU 11 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 2 static, 1 dynamic
"ps_4_0
eefiecedikpojkgojifbdkopecfhljimocepknecabaaaaaaaiadaaaaadaaaaaa
cmaaaaaaieaaaaaaliaaaaaaejfdeheofaaaaaaaacaaaaaaaiaaaaaadiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaadadaaaafdfgfpfagphdgjhegjgpgoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefceiacaaaa
eaaaaaaajcaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaafkaaaaadaagabaaa
aaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaaddcbabaaaabaaaaaa
gfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaaaaaaaajdcaabaaaaaaaaaaa
egbabaaaabaaaaaaegiacaiaebaaaaaaaaaaaaaaabaaaaaadiaaaaaidcaabaaa
aaaaaaaaegaabaaaaaaaaaaaogikcaaaaaaaaaaaabaaaaaaapaaaaahecaabaaa
aaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaadcaaaaalicaabaaaaaaaaaaa
bkiacaaaaaaaaaaaadaaaaaackaabaaaaaaaaaaaakiacaaaaaaaaaaaadaaaaaa
diaaaaahecaabaaaaaaaaaaackaabaaaaaaaaaaackaabaaaaaaaaaaadcaaaaak
ecaabaaaaaaaaaaackaabaaaaaaaaaaackiacaaaaaaaaaaaadaaaaaadkaabaaa
aaaaaaaadiaaaaahdcaabaaaaaaaaaaakgakbaaaaaaaaaaaegaabaaaaaaaaaaa
dcaaaaaldcaabaaaaaaaaaaaegiacaaaaaaaaaaaacaaaaaaegaabaaaaaaaaaaa
egiacaaaaaaaaaaaabaaaaaadgcaaaafmcaabaaaaaaaaaaaagaebaaaaaaaaaaa
aaaaaaaimcaabaaaaaaaaaaaagaebaiaebaaaaaaaaaaaaaakgaobaaaaaaaaaaa
apaaaaahecaabaaaaaaaaaaaogakbaaaaaaaaaaaogakbaaaaaaaaaaadjaaaaah
ecaabaaaaaaaaaaackaabaaaaaaaaaaaabeaaaaaaaaaaaaaefaaaaajpcaabaaa
abaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaabpaaaead
ckaabaaaaaaaaaaadgaaaaaipccabaaaaaaaaaaaaceaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaabcaaaaabdgaaaaafpccabaaaaaaaaaaaegaobaaaabaaaaaa
bfaaaaabdoaaaaab"
}

SubProgram "gles " {
Keywords { }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { }
"!!GLES"
}

SubProgram "flash " {
Keywords { }
Vector 0 [_Center]
Vector 1 [_ScaleIn]
Vector 2 [_Scale]
Vector 3 [_HmdWarpParam]
SetTexture 0 [_MainTex] 2D
"agal_ps
c4 0.0 1.0 0.0 0.0
[bc]
acaaaaaaaaaaadacaaaaaaoeaeaaaaaaaaaaaaoeabaaaaaa sub r0.xy, v0, c0
adaaaaaaadaaadacaaaaaafeacaaaaaaabaaaaoeabaaaaaa mul r3.xy, r0.xyyy, c1
adaaaaaaaaaaabacadaaaaffacaaaaaaadaaaaffacaaaaaa mul r0.x, r3.y, r3.y
adaaaaaaabaaabacadaaaaaaacaaaaaaadaaaaaaacaaaaaa mul r1.x, r3.x, r3.x
abaaaaaaaaaaabacabaaaaaaacaaaaaaaaaaaaaaacaaaaaa add r0.x, r1.x, r0.x
adaaaaaaacaaabacaaaaaaaaacaaaaaaadaaaaffabaaaaaa mul r2.x, r0.x, c3.y
abaaaaaaacaaabacacaaaaaaacaaaaaaadaaaaoeabaaaaaa add r2.x, r2.x, c3
adaaaaaaabaaabacaaaaaaaaacaaaaaaadaaaakkabaaaaaa mul r1.x, r0.x, c3.z
adaaaaaaaaaaabacabaaaaaaacaaaaaaaaaaaaaaacaaaaaa mul r0.x, r1.x, r0.x
abaaaaaaaaaaabacaaaaaaaaacaaaaaaacaaaaaaacaaaaaa add r0.x, r0.x, r2.x
adaaaaaaaaaaadacadaaaafeacaaaaaaaaaaaaaaacaaaaaa mul r0.xy, r3.xyyy, r0.x
adaaaaaaaaaaadacaaaaaafeacaaaaaaacaaaaoeabaaaaaa mul r0.xy, r0.xyyy, c2
abaaaaaaaaaaadacaaaaaafeacaaaaaaaaaaaaoeabaaaaaa add r0.xy, r0.xyyy, c0
aaaaaaaaacaaadacaaaaaafeacaaaaaaaaaaaaaaaaaaaaaa mov r2.xy, r0.xyyy
bgaaaaaaacaaadacacaaaafeacaaaaaaaaaaaaaaaaaaaaaa sat r2.xy, r2.xyyy
ciaaaaaaabaaapacaaaaaafeacaaaaaaaaaaaaaaafaababb tex r1, r0.xyyy, s0 <2d wrap linear point>
acaaaaaaaaaaadacacaaaafeacaaaaaaaaaaaafeacaaaaaa sub r0.xy, r2.xyyy, r0.xyyy
beaaaaaaaaaaadacaaaaaafeacaaaaaaaaaaaaaaaaaaaaaa abs r0.xy, r0.xyyy
bfaaaaaaacaaadacaaaaaafeacaaaaaaaaaaaaaaaaaaaaaa neg r2.xy, r0.xyyy
ckaaaaaaacaaadacacaaaafeacaaaaaaaeaaaaaaabaaaaaa slt r2.xy, r2.xyyy, c4.x
aaaaaaaaaeaaacacaeaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r4.y, c4
aaaaaaaaaeaaapacaeaaaaoeabaaaaaaaaaaaaaaaaaaaaaa mov r4, c4
acaaaaaaacaaamacaeaaaaffacaaaaaaaeaaaaaaacaaaaaa sub r2.zw, r4.y, r4.x
adaaaaaaaaaaadacacaaaapoacaaaaaaacaaaafeacaaaaaa mul r0.xy, r2.zwww, r2.xyyy
abaaaaaaaaaaadacaaaaaafeacaaaaaaaeaaaaaaabaaaaaa add r0.xy, r0.xyyy, c4.x
abaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaffacaaaaaa add r0.x, r0.x, r0.y
bgaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa sat r0.x, r0.x
beaaaaaaaaaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa abs r0.x, r0.x
bfaaaaaaacaaabacaaaaaaaaacaaaaaaaaaaaaaaaaaaaaaa neg r2.x, r0.x
ckaaaaaaacaaapacacaaaaaaacaaaaaaaeaaaaaaabaaaaaa slt r2, r2.x, c4.x
acaaaaaaadaaapacaeaaaaaaabaaaaaaabaaaaoeacaaaaaa sub r3, c4.x, r1
adaaaaaaaaaaapacadaaaaoeacaaaaaaacaaaaoeacaaaaaa mul r0, r3, r2
abaaaaaaaaaaapacaaaaaaoeacaaaaaaabaaaaoeacaaaaaa add r0, r0, r1
aaaaaaaaaaaaapadaaaaaaoeacaaaaaaaaaaaaaaaaaaaaaa mov o0, r0
"
}

SubProgram "d3d11_9x " {
Keywords { }
ConstBuffer "$Globals" 64 // 64 used size, 5 vars
Vector 16 [_Center] 2
Vector 24 [_ScaleIn] 2
Vector 32 [_Scale] 2
Vector 48 [_HmdWarpParam] 4
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
// 19 instructions, 2 temp regs, 0 temp arrays:
// ALU 11 float, 0 int, 0 uint
// TEX 1 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 2 static, 1 dynamic
"ps_4_0_level_9_1
eefiecedgfkpkckobapkchekkfacoadppkjbhlcgabaaaaaajmaeaaaaaeaaaaaa
daaaaaaamaabaaaabaaeaaaagiaeaaaaebgpgodjiiabaaaaiiabaaaaaaacpppp
feabaaaadeaaaaaaabaaciaaaaaadeaaaaaadeaaabaaceaaaaaadeaaaaaaaaaa
aaaaabaaadaaaaaaaaaaaaaaaaacppppfbaaaaafadaaapkaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaabpaaaaacaaaaaaiaaaaaadlabpaaaaacaaaaaajaaaaiapka
acaaaaadaaaaadiaaaaaoelaaaaaoekbafaaaaadabaaabiaaaaaaaiaaaaakkka
afaaaaadabaaaciaaaaaffiaaaaappkaafaaaaadaaaaabiaabaaffiaabaaffia
aeaaaaaeaaaaabiaabaaaaiaabaaaaiaaaaaaaiaaeaaaaaeaaaaaciaacaaffka
aaaaaaiaacaaaakaafaaaaadaaaaabiaaaaaaaiaaaaaaaiaaeaaaaaeaaaaabia
aaaaaaiaacaakkkaaaaaffiaafaaaaadaaaaadiaaaaaaaiaabaaoeiaabaaaaac
abaaadiaaaaaoekaaeaaaaaeaaaaadiaabaaoekaaaaaoeiaabaaoeiaabaaaaac
aaaabmiaaaaabliaacaaaaadabaaadiaaaaaoeibaaaabliaecaaaaadaaaacpia
aaaaoeiaaaaioekafkaaaaaeabaaabiaabaaoeiaabaaoeiaadaaaakafiaaaaae
aaaacpiaabaaaaibaaaaoeiaadaaaakaabaaaaacaaaicpiaaaaaoeiappppaaaa
fdeieefceiacaaaaeaaaaaaajcaaaaaafjaaaaaeegiocaaaaaaaaaaaaeaaaaaa
fkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaad
dcbabaaaabaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaaaaaaaaj
dcaabaaaaaaaaaaaegbabaaaabaaaaaaegiacaiaebaaaaaaaaaaaaaaabaaaaaa
diaaaaaidcaabaaaaaaaaaaaegaabaaaaaaaaaaaogikcaaaaaaaaaaaabaaaaaa
apaaaaahecaabaaaaaaaaaaaegaabaaaaaaaaaaaegaabaaaaaaaaaaadcaaaaal
icaabaaaaaaaaaaabkiacaaaaaaaaaaaadaaaaaackaabaaaaaaaaaaaakiacaaa
aaaaaaaaadaaaaaadiaaaaahecaabaaaaaaaaaaackaabaaaaaaaaaaackaabaaa
aaaaaaaadcaaaaakecaabaaaaaaaaaaackaabaaaaaaaaaaackiacaaaaaaaaaaa
adaaaaaadkaabaaaaaaaaaaadiaaaaahdcaabaaaaaaaaaaakgakbaaaaaaaaaaa
egaabaaaaaaaaaaadcaaaaaldcaabaaaaaaaaaaaegiacaaaaaaaaaaaacaaaaaa
egaabaaaaaaaaaaaegiacaaaaaaaaaaaabaaaaaadgcaaaafmcaabaaaaaaaaaaa
agaebaaaaaaaaaaaaaaaaaaimcaabaaaaaaaaaaaagaebaiaebaaaaaaaaaaaaaa
kgaobaaaaaaaaaaaapaaaaahecaabaaaaaaaaaaaogakbaaaaaaaaaaaogakbaaa
aaaaaaaadjaaaaahecaabaaaaaaaaaaackaabaaaaaaaaaaaabeaaaaaaaaaaaaa
efaaaaajpcaabaaaabaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaa
aaaaaaaabpaaaeadckaabaaaaaaaaaaadgaaaaaipccabaaaaaaaaaaaaceaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabcaaaaabdgaaaaafpccabaaaaaaaaaaa
egaobaaaabaaaaaabfaaaaabdoaaaaabejfdeheofaaaaaaaacaaaaaaaiaaaaaa
diaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaeeaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaadadaaaafdfgfpfagphdgjhegjgpgoaafeeffied
epepfceeaaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}

SubProgram "gles3 " {
Keywords { }
"!!GLES3"
}

}

#LINE 92

  }
  
}

Fallback off
	
} // shader
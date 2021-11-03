attribute vec3 aVertexPosition;
attribute vec3 aNormalPosition;
attribute vec2 aTextureCoord;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;

uniform vec3 ul[4];
uniform vec3 ur[4];
uniform vec3 ut[4];
uniform vec3 ub[4];
uniform vec3 un[4];
uniform vec3 uf[4];

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;
varying highp vec3 vTangent;

varying vec3 vl[4];
varying vec3 vr[4];
varying vec3 vt[4];
varying vec3 vb[4];
varying vec3 vn[4];
varying vec3 vf[4];

varying mat4 vp;
void main(void) {

  vFragPos = (uModelMatrix * vec4(aVertexPosition, 1.0)).xyz;
  vNormal = (uModelMatrix * vec4(aNormalPosition, 0.0)).xyz;

  gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
  vp = uProjectionMatrix * uViewMatrix;
  for(int i = 0;i < 4;i++) 
  vl[i] = (uModelMatrix * vec4(ul[i],1.0)).xyz,
  vr[i] = (uModelMatrix * vec4(ur[i],1.0)).xyz,
  vt[i] = (uModelMatrix * vec4(ut[i],1.0)).xyz,
  vb[i] = (uModelMatrix * vec4(ub[i],1.0)).xyz,
  vn[i] = (uModelMatrix * vec4(un[i],1.0)).xyz,
  vf[i] = (uModelMatrix * vec4(uf[i],1.0)).xyz;

  vTextureCoord = aTextureCoord;
  vTangent = normalize((uModelMatrix * vec4(0,1,0,1)).xyz);
}
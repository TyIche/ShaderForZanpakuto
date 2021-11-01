#ifdef GL_ES
precision mediump float;
#endif

uniform samplerCube skybox;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;

void main() {
     gl_FragColor = vec4(textureCube(skybox, vFragPos).xyz,1);
     //gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
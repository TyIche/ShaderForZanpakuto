#ifdef GL_ES
precision mediump float;
#endif

varying highp vec4 vFragColor;
void main()
{
    gl_FragColor = vFragColor;
}
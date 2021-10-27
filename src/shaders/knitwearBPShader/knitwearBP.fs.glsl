#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 uLightPos[100];
uniform vec3 uLightRadiance[100];

uniform vec3 uka;
uniform vec3 uks;
uniform vec3 ukd;

uniform vec3 uCameraPos;
uniform sampler2D uAlbedoMap;
uniform float uMetallic;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;
varying highp vec3 vTangent;

vec3 BlinnPhong(vec3 I,vec3 lp)
{
    vec3 ret = vec3(0.0);
    vec3 l = lp - vFragPos;
    float r = length(l);
    l = normalize(l);
    vec3 n = vNormal;
    n = normalize(n);
    ret += ukd * I/r*10.0 * max(0.0,dot(l,n));

    vec3 v = uCameraPos - vFragPos;
    v = normalize(v);
    vec3 h = v + l;
    h = normalize(h);

    // gl_FragColor = vec4(normalize(h),1);
    // if(dot(n,h) == 1.0) 
    // gl_FragColor = vec4(vec3(pow(max(0.0,dot(n,h)) ,200.0)),1);
    // else gl_FragColor = vec4(0,1 ,0 ,1 );
    // gl_FragColor = vec4(vec3(clamp(0.0,1.0,dot(n,h))),1);
    
    ret += uks * I/r*10.0 * pow(max(0.0,dot(n,h)) ,20.0);
    // if(ret == vec3(0.0))
    // gl_FragColor = vec4(I*10.0 * vec3(pow(max(0.0,dot(n,h)) ,5.0)),1);
    // else gl_FragColor = vec4(0,1 ,0 , 1);
    return ret;
}
void main()
{
    
    // gl_FragColor = vec4(vec3(0.577),1.0);
    // gl_FragColor = vec4(uka*100.0,1.0);
    // return ;

    vec3 ans = vec3(0.0);
    for(int i = 0;i < 100;i++)
    {
        if(uLightRadiance[i].z < 0.0) break;
        vec3 color =  BlinnPhong(uLightRadiance[i],uLightPos[i]);
        color += uka;
        // return ;
        // color = color / (color + vec3(1.0));
        // color = pow(color, vec3(1.0/2.2)); 
        ans += color;
    }
    
    // normalize(ans);
    // ans*=255.0;
    gl_FragColor = vec4(ans, 1);
}
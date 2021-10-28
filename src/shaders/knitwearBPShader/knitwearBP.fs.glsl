#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 uLightPos[100];
uniform vec3 uLightRadiance[100];
uniform vec3 ul[4];
uniform vec3 ur[4];
uniform vec3 ut[4];
uniform vec3 ub[4];
uniform vec3 un[4];
uniform vec3 uf[4];
uniform float uxlen;
uniform float uylen;
uniform float utwistRate;

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

highp vec3 nowFragPos;

float PI = acos(-1.0);
vec3 viewIn,viewStep;
float dis(vec3 mesh[4],vec3 p)
{
    vec3 N = cross(mesh[0] - mesh[1],mesh[2] - mesh[1]);
    N = normalize(N);

    return abs(dot(N,p - mesh[0]));
}
float getIntersection(vec3 vp,vec3 vdir,vec3 mesh[4])
{
    // t * vdir \dot N = dis(mesh,vp)
    vec3 N = cross(mesh[0] - mesh[1],mesh[2] - mesh[1]);
    N = normalize(N);
    float Dis = dis(mesh,vp);

    return Dis / abs(dot(N,vdir));
}
float T_in,T_out;
bool getView()
{
    vec3 vp = uCameraPos,vdir = uCameraPos - vFragPos;
    vdir = normalize(vdir);

    // float T_in,T_out;
    float a = getIntersection(vp,vdir,ul),b = getIntersection(vp,vdir,ur);
    float c = getIntersection(vp,vdir,ut),d = getIntersection(vp,vdir,ub);
    float e = getIntersection(vp,vdir,un),f = getIntersection(vp,vdir,uf);

    T_in = max(max(min(a,b),min(c,d)),min(e,f));
    T_out = min(min(max(a,b),max(c,d)),max(e,f));

    if( T_in <= T_out && T_in > 0.0)
    {
        viewIn = vp + T_in * vdir;
        viewStep = (T_out - T_in) * vdir / 20.0;
        return true;
    }
    return false;
}
vec3 BlinnPhong(vec3 I,vec3 lp)
{
    vec3 ret = vec3(0.0);
    vec3 l = lp - nowFragPos;
    float r = length(l);
    l = normalize(l);
    vec3 n = vNormal;
    n = normalize(n);
    r/=40.0;
    ret += ukd * I/r/r * max(0.0,dot(l,n));

    vec3 v = uCameraPos - nowFragPos;
    v = normalize(v);
    vec3 h = v + l;
    h = normalize(h);
    
    ret += uks * I/r/r * pow(max(0.0,dot(n,h)) ,20.0);

    return ret;
}
bool check(float x,float y,float x0,float y0,float r)
{
    return (x - x0) * (x - x0) + (y - y0) * (y - y0) <= r * r;
}
void main()
{
    // gl_FragColor = vec4(vec3(cos(6.28)),1.0);
    // return ;

    if(!getView()) return;

    for(float t = 0.0;t < 20.0;t += 1.0)
    {
        vec3 now = viewIn + viewStep * t;
        float xx = dis(ul,now)/uxlen,yy = dis(ub,now)/uylen;
        // if(!check(xx,yy,0.5,0.75,0.25)&&
        // !check(xx,yy,0.5 + 0.25 * cos(PI/3.0), 0.5 + 0.25 * sin(PI/3.0),0.25) 
        // &&!check(xx,yy,0.5 + 0.25 * cos(-PI/3.0), 0.5 + 0.25 * sin(-PI/3.0),0.25))
        // continue;
        nowFragPos = now;
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
        gl_FragColor = vec4(ans, 1);
        return ;
    // normalize(ans);
    // ans*=255.0;
    }
    
}
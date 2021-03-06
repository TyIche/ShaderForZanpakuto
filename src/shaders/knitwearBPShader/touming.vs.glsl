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

uniform vec3 uLightPos[100];
uniform vec3 uLightRadiance[100];


uniform float uxlen;
uniform float uylen;
uniform float utwistRate;


uniform vec3 uka;
uniform vec3 uks;
uniform vec3 ukd;


uniform vec3 uCameraPos;
uniform sampler2D uAlbedoMap;
uniform float uMetallic;

varying highp vec4 vFragColor;

highp vec2 vTextureCoord;
highp vec3 vFragPos;
highp vec3 vNormal;
highp vec3 vTangent;

highp vec3 nowFragPos;
highp vec3 tmp,nowNormal;

const int STEP = 10;
float PI = acos(-1.0);
vec3 viewIn,viewStep;
float dis(vec3 mesh[4],vec3 p)
{
    vec3 N = cross(mesh[0] - mesh[1],mesh[2] - mesh[1]);
    N = normalize(N);

    return dot(N,mesh[0] - p);
}
float getIntersection(vec3 vp,vec3 vdir,vec3 mesh[4])
{
    // t * vdir \dot N = dis(mesh,vp)
    vec3 N = cross(mesh[0] - mesh[1],mesh[2] - mesh[1]);
    N = normalize(N);
    float Dis = dis(mesh,vp);

    return Dis / dot(N,vdir);
}
float T_in = 0.0,T_out = 10000000.0;
bool getView()
{
    vec3 vp = uCameraPos,vdir = vFragPos - uCameraPos;
    vdir = normalize(vdir);

    // gl_FragColor = vec4(vdir,1);
    // float T_in,T_out;

    float a = getIntersection(vp,vdir,ul),b = getIntersection(vp,vdir,ur);
    float c = getIntersection(vp,vdir,ut),d = getIntersection(vp,vdir,ub);
    float e = getIntersection(vp,vdir,un),f = getIntersection(vp,vdir,uf);
    
    // float a = getIntersection(vp,vdir,vl),b = getIntersection(vp,vdir,vr);
    // float c = getIntersection(vp,vdir,vt),d = getIntersection(vp,vdir,vb);
    // float e = getIntersection(vp,vdir,vn),f = getIntersection(vp,vdir,vf);

    T_in = max(max(min(a,b),min(c,d)),min(e,f));
    T_out = min(min(max(a,b),max(c,d)),max(e,f));
    // gl_FragColor = vec4(normalize(vec3(T_in,T_out,0)),1);
    
    // if(T_in <= T_out && T_in > 0.0) gl_FragColor = vec4(vec3(1.0,0.0,0.0),1);
    // else if(T_in - T_out <= 1.0) gl_FragColor = vec4(vec3(0,1,0) ,1);
    // else gl_FragColor = vec4(vec3(0,(T_in-T_out)/100.0,0) ,1);

    if( T_in <= T_out && T_in > 0.0)
    {
        viewIn = vp + T_in * vdir;
        viewStep = (T_out - T_in) * vdir / float(STEP);
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
    vec3 n = nowNormal;
    n = normalize(n);
    r/=20.0;
    ret += ukd * I/r/r * max(0.0,dot(l,n));

    vec3 v = uCameraPos - nowFragPos;
    v = normalize(v);
    vec3 h = v + l;
    h = normalize(h);
    
    ret += uks * I/r/r * pow(max(0.0,dot(n,h)) ,150.0);

    return ret;
}
bool check(float x,float y,float x0,float y0,float r)
{
    if( (x - x0) * (x - x0) + (y - y0) * (y - y0) <= r * r)
    {
        tmp = vec3( x0,y0 ,0);
        // tmp = normalize(tmp);
        return true;
    }
    return false;
}
void main()
{

    vFragPos = (uModelMatrix * vec4(aVertexPosition, 1.0)).xyz;
    vNormal = (uModelMatrix * vec4(aNormalPosition, 0.0)).xyz;

    gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);

    vTextureCoord = aTextureCoord;
    vTangent = normalize((uModelMatrix * vec4(0,1,0,1)).xyz);

    vFragColor = vec4(uCameraPos- vFragPos,1);
    // gl_FragColor = vec4(normalize(vFragPos),1);
    // return ;


    // gl_FragColor = vec4(vec3(dot(normalize(cross(uf[0] - uf[1],uf[2] - uf[1])),vec3(1,0,0))),1);
    // return ;
    
    if(!getView()) return;
    // gl_FragColor = vec4(vec3(1, 1,1 )/1.55,1);
    // return ;
    // gl_FragColor = vec4(0,0 ,1 ,1 );
    bool flag = false;
    for(int t = 0;t <= STEP;t++)
    {
        highp float tt = float(t);
        vec3 now = viewIn + viewStep * tt;

        float xx = abs(dis(ul,now))/uxlen,yy = abs(dis(ub,now))/uylen;
        float zz = abs(dis(uf,now));

        // float xx = abs(dis(vl,now))/uxlen,yy = abs(dis(vb,now))/uylen;
        // float zz = abs(dis(vf,now));

        float theta = (zz - float(int(zz/utwistRate))*utwistRate)*(2.0*PI)/utwistRate;
        // float theta = zz * utwistRate;
        if(check(xx,yy,0.5+ 0.25*cos(theta),0.5+0.25*sin(theta),0.25)||

        check(xx,yy,0.5 + 0.25 * cos(PI*2.0/3.0+theta), 0.5 + 0.25 * sin(PI*2.0/3.0+theta),0.25)||
        check(xx,yy,0.5 + 0.25 * cos(-PI*2.0/3.0 + theta), 0.5 + 0.25 * sin(-PI*2.0/3.0+theta),0.25))
        {
            flag = true;
            nowFragPos = now;
            nowNormal =  now - vec3(now.x,tmp.x,tmp.y);
            if(t < 1) nowNormal = vNormal;
            // if(t > 0.5) nowNormal = tmp;
            // gl_FragColor = vec4(1,1,1,1);
            // return;
            // gl_FragColor = vec4(normalize(viewIn),1);
            // gl_FragColor = vec4(vec3(1.0),1);
            // return;
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
            // vFragColor = vec4(ans, 1);
            return ;
        }
    // normalize(ans);
    // ans*=255.0;
    }
    if(!flag)
    {
        gl_Position.z = 2147483647.0;
    }
}
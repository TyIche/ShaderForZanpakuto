#ifdef GL_ES
precision mediump float;
#endif
#extension GL_EXT_frag_depth : enable
uniform vec3 uLightPos[100];
uniform vec3 uLightRadiance[100];


uniform float uxlen;
uniform float uylen;
uniform float utwistRate;

// uniform vec3 ul[4];
// uniform vec3 ur[4];
// uniform vec3 ut[4];
// uniform vec3 ub[4];
// uniform vec3 un[4];
// uniform vec3 uf[4];

uniform vec3 uka;
uniform vec3 uks;
uniform vec3 ukd;

uniform vec3 uCameraPos;
uniform sampler2D uAlbedoMap;
uniform float uMetallic;
uniform float uTheta;

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

highp vec3 vA;
highp vec3 vB;
highp vec3 vC;
highp vec3 vD;
highp vec3 vO;
highp vec3 nowFragPos;
highp vec3 tmp,nowNormal;

const int STEP = 300;
const float EPSILON = 0.001;
float PI = acos(-1.0);
vec3 viewIn,viewDir;
float viewStep;
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
    vA = vb[0]+vb[1]+vb[2]+vb[3];vA /= 4.0;
    vD = vn[0]+vn[1]+vn[2]+vn[3];vD /= 4.0;
    vO = vb[2]+vb[1];vO /= 2.0;

    vec3 tmp = 2.0*((vA + vD)/2.0 - vO)+vO;
    vB = (0.552*tmp + 0.448*vA);
    vC = (0.552*tmp + 0.448*vD);


    vec3 vp = uCameraPos,vdir = vFragPos - uCameraPos;
    vdir = normalize(vdir);
    
    float a = getIntersection(vp,vdir,vl),b = getIntersection(vp,vdir,vr);
    float c = getIntersection(vp,vdir,vt),d = getIntersection(vp,vdir,vb);
    float e = getIntersection(vp,vdir,vn),f = getIntersection(vp,vdir,vf);

    T_in = max(max(min(a,b),min(c,d)),min(e,f));
    T_out = min(min(max(a,b),max(c,d)),max(e,f));

    if( T_in <= T_out && T_in > 0.0)
    {
        viewIn = vp + T_in * vdir;
        viewStep = (T_out - T_in) / float(STEP);
        viewDir = vdir;
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
    // r/=20.0;
    ret += ukd * I/r/r * max(0.0,dot(l,n));

    vec3 v = uCameraPos - nowFragPos;
    v = normalize(v);
    vec3 h = v + l;
    h = normalize(h);
    
    ret += uks * I/r/r * pow(max(0.0,dot(n,h)) ,50.0);

    return ret;
}
bool check(float x,float y,float x0,float y0,float r)
{
    if( (x - x0) * (x - x0) + (y - y0) * (y - y0) <= r * r)
    {
        tmp = vec3( x0-0.5,y0-0.5 ,0);
        // tmp = normalize(tmp);
        return true;
    }
    return false;
}
bool check2(vec3 mid,vec3 proj,float diss,float theta)
{   
    float yy = length(mid - proj);
    yy = length(proj - vO) <= length(vA - vO)?-yy:yy;
    yy /= uxlen;
    yy = 0.5 + yy;
    float xx = 0.5 + diss/uylen;
    float tmpp = xx;
    xx = yy;
    yy = tmpp;
    return (check(xx,yy,0.5+ 0.25*cos(theta),0.5+0.25*sin(theta),0.25)
    // );
    ||
        check(xx,yy,0.5 + 0.25 * cos(PI*2.0/3.0+theta), 0.5 + 0.25 * sin(PI*2.0/3.0+theta),0.25)||
        check(xx,yy,0.5 + 0.25 * cos(-PI*2.0/3.0 + theta), 0.5 + 0.25 * sin(-PI*2.0/3.0+theta),0.25));
}
void main()
{
    
    // if(vFragPos.z > 1.0) 
    // gl_FragColor = vec4(normalize(vFragPos),1);
    // return ;

    if(!getView()) 
    {gl_FragDepthEXT = 100.0;return;}
    bool flag = false;
    vec3 now = viewIn;
    float last = 0.0;
    for(int t = 0;t <= STEP;t++)
    {
        if(last > float(STEP) * viewStep) break;
        //highp float tt = float(t);
        //vec3 now = viewIn + viewStep * tt;
        
        float diss = dot(vA - now,normalize(cross(vA-vO,vD-vO)));
        vec3 proj = now + diss * normalize(cross(vA-vO,vD-vO));

        // if(abs(diss) <= 10.0)
        // gl_FragColor = vec4(normalize(proj) ,1 );return;
        // if(length(now - vA) <= 0.1) 
        // {
        //     gl_FragColor = vec4(1,0 ,0 ,1 );
        //     return;
        // }

        float T = acos(dot(normalize(proj - vO),normalize(vA - vO))) / (PI/2.0);

        float zz = T * (PI*length(vA - vO)/2.0);

        float theta = (zz - float(int(zz/utwistRate))*utwistRate)*(2.0*PI)/utwistRate + uTheta;


        vec3 trace = vA*(1.0-T)*(1.0-T)*(1.0-T)+3.0*vB*T*(1.0-T)*(1.0-T)+3.0*vC*T*T*(1.0-T)+vD*T*T*T;

        // if(length(trace - now) <= 1.0) {gl_FragColor = vec4(0,1 ,0 ,1 );return;}
        if(check2(trace,proj,diss,theta)&&T>=0.0&&T<=1.0)
        {
            flag = true;
            nowFragPos = now;
            
            // nowNormal =  normalize (now - (trace - normalize(cross(vA-vO,vD-vO)*uylen*tmp.x)
            // + normalize(trace - vO)*uylen*tmp.y));

            nowNormal =  normalize (now - (trace - uylen*normalize(cross(vA-vO,vD-vO))*tmp.y
            + uxlen*normalize(trace - vO)*tmp.x));
            // gl_FragColor = vec4(nowNormal,1 );
            // return;

            if(t < 1) nowNormal = vNormal;
            vec3 ans = vec3(0.0);
            for(int i = 0;i < 10;i++)
            {
                if(uLightRadiance[i].z < 0.0) break;
                vec3 color =  BlinnPhong(uLightRadiance[i],uLightPos[i]);
                color += uka;
                ans += color;
            }
            gl_FragColor = vec4(ans, 1);
            // if(T <= 1.0)
            // gl_FragColor = vec4(1,1,1,1);

            // gl_FragDepthEXT = (vp*vec4(vFragPos,1.0)).z/(vp*vec4(vFragPos,1.0)).w;
            highp float Z = length(vFragPos-uCameraPos),Ninv = 100.0,Finv = 0.001;
            gl_FragDepthEXT = (Ninv - 1.0/Z)/(Ninv - Finv);
            return ;
        }
        float sdf = diss*diss + (length(vA - vO) - length(vO - proj)) * (length(vA - vO) - length(vO - proj));
        sdf = sqrt(sdf);
        // last += viewStep;
        last += max (viewStep,sdf - uylen/2.0);
        now = viewIn + last * viewDir;
    }
    if(!flag)
    {   
        // gl_FragColor = vec4(1,1 ,0 ,1);
        // gl_FragDepthEXT = (vp*vec4(vFragPos,1.0)).z/(vp*vec4(vFragPos,1.0)).w;
        gl_FragDepthEXT = 128.0;
    }
}
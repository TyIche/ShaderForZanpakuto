#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 uLightPos[100];
uniform vec3 uLightRadiance[100];
uniform vec3 uLightDir;

uniform vec3 uCameraPos;
uniform sampler2D uAlbedoMap;
uniform float uMetallic;
uniform float uRoughness;
uniform float uRoughness2;
uniform sampler2D uBRDFLut;
uniform samplerCube uCubeTexture;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;
varying highp vec3 vTangent;

const float PI = 3.14159265359;
float DistributionGGX(vec3 N,vec3 H,float a1,float a2)
{
    a1 = a1 * a1;
    a2 = a2 * a2;

    float tmp = PI*a1*a2;
    float pram1 = dot(vTangent,H);
    pram1 /= a1;
    float pram2 = dot(cross(N,vTangent),H);
    pram2 /= a2;
    pram1 = pram1 * pram1;
    pram2 = pram2 * pram2;
    tmp *= pow(pram1+pram2+pow(dot(N,H),2.0),2.0);
    return 1.0/tmp;
    // return 1.0;
}

// float DistributionGGX(vec3 N, vec3 H, float roughness,float aem)
// {
//    // TODO: To calculate GGX NDF here
//    //float NdotH = clamp(dot(N,H),0.0,1.0);
//    float NdotH = dot(N,H);
//     float a = pow(roughness,4.0);
//     float ans = NdotH*NdotH*(a-1.0)+1.0;
//     ans = ans * ans ;
//     return a/ans/PI;
// }
float alpha(vec3 V,vec3 N)
{
    float coss = clamp(dot(N,V),0.0 ,1.0 );
    return sqrt(uRoughness*uRoughness*coss*coss+uRoughness2*uRoughness2*(1.0-coss*coss));
}
float lambda(vec3 V,vec3 N)
{
    float NdotV = clamp(dot(N,V),0.0 ,1.0 );
    float a = 1.0/alpha(V,N)/(sqrt(1.0-NdotV*NdotV)/NdotV);
    return (sqrt(1.0+1.0/a/a)-1.0)/2.0;
}
float GeometryHeightSmith(vec3 N,vec3 V,vec3 L,float uRoughness)
{
    float NdotL = max(0.0,dot(N,L));
    float NdotV = max(0.0,dot(N,V));
    return NdotL*NdotV/(1.0+lambda(V,N)+lambda(L,N));
    // return 1.0;
}
float GeometrySchlickGGX(float NdotV, float roughness)
{
    // TODO: To calculate Smith G1 here
    NdotV = clamp(NdotV,0.0,1.0);
    float k = (roughness+1.0)*(roughness+1.0)/8.0;
    return NdotV/(NdotV*(1.0-k) + k);
    // return 1.0;
}
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness,float NAME)
{
    // TODO: To calculate Smith G here
    return GeometrySchlickGGX(dot(L,N),roughness) * GeometrySchlickGGX(dot(V,N),roughness);
    // return 1.0;
}
vec3 fresnelSchlick(vec3 R0,vec3 V,vec3 H)
{
    return R0 + (1.0 - R0)*pow((1.0-clamp(dot(V,H),0.0,1.0)),5.0);
    // return vec3(0,0 ,0);
}
void main(void) {
    vec3 albedo = pow(texture2D(uAlbedoMap, vTextureCoord).rgb, vec3(2.2));

    vec3 N = normalize(vNormal);
    vec3 V = normalize(uCameraPos - vFragPos);
    float NdotV = max(dot(N, V), 0.0);

    vec3 F0 = vec3(0.04); 
    F0 = mix(F0, albedo, uMetallic);

    vec3 Lo = vec3(0.0);
    
    vec3 tmpColor = vec3(0.0);
    for(int i = 0;i<100;i++)
    {
        if(uLightRadiance[i].z < 0.0) break;
        vec3 L = normalize(uLightPos[i] - vFragPos);
        vec3 H = normalize(V + L);
        float NdotL = max(dot(N, L), 0.0); 

        vec3 radiance = uLightRadiance[i];

        float NDF = DistributionGGX(N, H, uRoughness,uRoughness2);   
        float G   = GeometrySmith(N, V, L, uRoughness,uRoughness2); 
        vec3 F = fresnelSchlick(F0, V, H);
        // if(NDF >= 0.5) {gl_FragColor = vec4(1,1,0,1);
        // return;}
        vec3 numerator    = NDF * G * F;
        float denominator = max((4.0 * NdotL * NdotV), 0.001);
        vec3 BRDF = numerator / denominator;

        Lo += BRDF * radiance * NdotL;
        vec3 color = Lo;

        color = color / (color + vec3(1.0));
        color = pow(color, vec3(1.0/2.2)); 
        tmpColor += color;
    }
    gl_FragColor = vec4(tmpColor, 1.0);
    // gl_FragColor = vec4(1,1,0,1);
}
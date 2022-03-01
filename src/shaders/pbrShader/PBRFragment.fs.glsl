
#ifdef GL_ES
precision mediump float;
#endif


#extension GL_EXT_frag_depth : enable

uniform vec3 uLightPos;
uniform vec3 uCameraPos;
uniform vec3 uLightRadiance;
uniform vec3 uLightDir;

uniform sampler2D uAlbedoMap;
uniform float uMetallic;
uniform float uRoughness;
uniform sampler2D uBRDFLut;
uniform samplerCube uCubeTexture;

varying highp vec2 vTextureCoord;
varying highp vec3 vFragPos;
varying highp vec3 vNormal;
varying mat4 vp;

const float PI = 3.14159265359;

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
   // TODO: To calculate GGX NDF here
   //float NdotH = clamp(dot(N,H),0.0,1.0);
   float NdotH = dot(N,H);
    float a = pow(roughness,4.0);
    float ans = NdotH*NdotH*(a-1.0)+1.0;
    ans = ans * ans ;
    return a/ans/PI;
}

// float GeometrySchlickGGX(float NdotV, float roughness)
// {
//     // TODO: To calculate Smith G1 here
//     float a = roughness*roughness;
//     return 2.0*NdotV/(sqrt(a*a*(1.0-NdotV*NdotV))+1.0);
//     NdotV = clamp(NdotV,0.0,1.0);
//     float k = (roughness+1.0)*(roughness+1.0)/8.0;
//     return NdotV/(NdotV*(1.0-k) + k);
// }

// float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
// {
//     // TODO: To calculate Smith G here
//     return GeometrySchlickGGX(dot(L,N),roughness) * GeometrySchlickGGX(dot(V,N),roughness);
// }
float alpha(vec3 V,vec3 N)
{
    float coss = clamp(dot(N,V),0.0 ,1.0 );
    return sqrt(uRoughness*uRoughness*coss*coss+uRoughness*uRoughness*(1.0-coss*coss));
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
// float GeometryHeightSmith(vec3 N, vec3 V, vec3 L, float roughness)
// {
//     float a = roughness * roughness;
//     float NdotV = clamp(dot(N,V),0.0,1.0 );
//     float NdotL = clamp(dot(N,L),0.0,1.0 );
//     return 2.0/(sqrt(a*a*(1.0-NdotL*NdotL)+NdotL)+sqrt(a*a*(1.0-NdotV*NdotV)+NdotV));
//     // return 1.0;
// }
vec3 fresnelSchlick(vec3 F0, vec3 V, vec3 H)
{
    // TODO: To calculate Schlick F here
    float VdotH = clamp(dot(H,V),0.0,1.0);
    vec3 R0 = F0;
    // R0 *= R0;
    return R0 + (1.0-R0)*pow(1.0-VdotH,5.0);
}
void main(void) {
    //
    // gl_FragColor = vec4(vFragPos,1);
    // return;
    //
  vec3 albedo = pow(texture2D(uAlbedoMap, vTextureCoord).rgb, vec3(2.2));

  vec3 N = normalize(vNormal);
//   gl_FragColor = vec4(N,1.0);
//   return;
  vec3 V = normalize(uCameraPos - vFragPos);
  float NdotV = max(dot(N, V), 0.0);
 
  vec3 F0 = vec3(0.04); 
  F0 = mix(F0, albedo, uMetallic);

  vec3 Lo = vec3(0.0);

  vec3 L = normalize(uLightPos - vFragPos);

  vec3 H = normalize(V + L);
  float NdotL = max(dot(N, L), 0.0); 

  vec3 radiance = uLightRadiance;

  float NDF = DistributionGGX(N, H, uRoughness);   
  float G   = GeometryHeightSmith(N, V, L, uRoughness); 
  vec3 F = fresnelSchlick(F0, V, H);
      
  vec3 numerator    = NDF * G * F; 
//   numerator /= G;
  float denominator = max((4.0 * NdotL * NdotV), 0.001);
  vec3 BRDF = numerator / denominator;

  Lo += BRDF * radiance * NdotL;
  vec3 color = Lo;

  color = color / (color + vec3(1.0));
  color = pow(color, vec3(1.0/2.2)); 
  gl_FragColor = vec4(color, 1.0);

  // gl_FragDepthEXT = (vp*vec4(vFragPos,1.0)).z/(vp*vec4(vFragPos,1.0)).w;
  // gl_FragDepthEXT = 
  // gl_FragDepthEXT = (vp*vec4(vFragPos,1.0)).z/(vp*vec4(vFragPos,1.0)).w*0.5 + 0.5;
  highp float Z = length(vFragPos-uCameraPos),Ninv = 100.0,Finv = 0.001;
  gl_FragDepthEXT = (Ninv - 1.0/Z)/(Ninv - Finv);
}
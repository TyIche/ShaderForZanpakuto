class KnitwearMaterial extends Material {

    constructor(albedo, metallic, ka,ks,kd,lights, vertexShader, fragmentShader) {
        super({
            'uAlbedoMap': { type: 'texture', value: albedo },
            'uMetallic': { type: '1f', value: metallic },
            'uka':{type:'3fv',value:ka},
            'uks':{type:'3fv',value:ks},
            'ukd':{type:'3fv',value:kd},
            'uLightRadiance': { type: '3fv', value: lights.lightRadiances },
            'uLightPos': { type: '3fv', value: lights.lightPoss },
        }, [], vertexShader, fragmentShader);
        
        // console.log(lights.lightRadiances,lights.lightPoss);
    }
}

async function buildKnitwearMaterial(albedo, metallic,ka,ks,kd,light, vertexPath, fragmentPath)
{   
    console.log("#######################");
    console.log(vertexPath,fragmentPath);
    let vertexShader = await getShaderString(vertexPath);
    let fragmentShader = await getShaderString(fragmentPath);
    
    return new KnitwearMaterial(albedo, metallic, ka,ks,kd, light, vertexShader, fragmentShader);
}
class anistropicMaterial extends Material {

    constructor(albedo, metallic, roughness, roughness2,BRDFLut, EavgLut, lights, vertexShader, fragmentShader) {
        super({
            
            'uAlbedoMap': { type: 'texture', value: albedo },
            'uMetallic': { type: '1f', value: metallic },
            'uRoughness': { type: '1f', value: roughness },
            'uRoughness2':{type:'1f',value:roughness2},
            'uBRDFLut': { type: 'texture', value: BRDFLut },
            'uEavgFLut': { type: 'texture', value: EavgLut },
            // 'uLightLen' : {type: '1i',value: lights.size},
            'uCubeTexture': { type: 'CubeTexture', value: null },
            'uLightRadiance': { type: '3fv', value: lights.lightRadiances },
            'uLightDir': { type: '3fv', value: [0,0,0] },
            'uLightPos': { type: '3fv', value: lights.lightPoss },
        }, [], vertexShader, fragmentShader);
        
        console.log(lights.lightRadiances,lights.lightPoss);
    }
}

async function buildAnistropicMaterial(albedo, metallic, roughness,roughness2,BRDFLut, EavgLut, light, vertexPath, fragmentPath)
{
    let vertexShader = await getShaderString(vertexPath);
    let fragmentShader = await getShaderString(fragmentPath);
    
    return new anistropicMaterial(albedo, metallic, roughness, roughness2,BRDFLut, EavgLut, light, vertexShader, fragmentShader);
}
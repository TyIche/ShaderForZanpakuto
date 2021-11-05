class KnitwearCircle extends Material {

    constructor(albedo, metallic, ka,ks,kd,lights,ul,ur,ut,ub,un,uf,
        xlen,ylen,tr,uA,uB,uC,uD,uO,
        vertexShader, fragmentShader) {
        super({
            'uAlbedoMap': { type: 'texture', value: albedo },
            'uMetallic': { type: '1f', value: metallic },
            'uka':{type:'3fv',value:ka},
            'uks':{type:'3fv',value:ks},
            'ukd':{type:'3fv',value:kd},
            'ul':{type:'3fv',value:ul},
            'ur':{type:'3fv',value:ur},
            'ut':{type:'3fv',value:ut},
            'ub':{type:'3fv',value:ub},
            'un':{type:'3fv',value:un},
            'uf':{type:'3fv',value:uf},
            'uxlen':{type:'1f',value:xlen},
            'uylen' : {type:'1f',value:ylen},
            'utwistRate' : {type:'1f',value:tr},
            'uA':{type:'3fv',value:uA},
            'uB':{type:'3fv',value:uB},
            'uC':{type:'3fv',value:uC},
            'uD':{type:'3fv',value:uD},
            'uO':{type:'3fv',value:uO},
            'uLightRadiance': { type: '3fv', value: lights.lightRadiances },
            'uLightPos': { type: '3fv', value: lights.lightPoss },
        }, [], vertexShader, fragmentShader);
        
        // console.log(lights.lightRadiances,lights.lightPoss);
    }
}

async function buildKnitwearCircle(albedo, metallic,ka,ks,kd,light,ul,ur,ut,
    ub,un,uf,xlen,ylen,tr,uA,uB,uC,uD,uO, vertexPath, fragmentPath)
{   
    console.log("#######################");
    console.log(vertexPath,fragmentPath);
    let vertexShader = await getShaderString(vertexPath);
    let fragmentShader = await getShaderString(fragmentPath);
    
    return new KnitwearCircle(albedo, metallic, ka,ks,kd, light,
        ul,ur,ut,ub,un,uf, xlen,ylen,tr,uA,uB,uC,uD,uO,vertexShader, fragmentShader);
}
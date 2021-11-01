class WebGLRenderer {
    meshes = [];
    shadowMeshes = [];
    lights = [];

    constructor(gl, camera) {
        this.gl = gl;
        this.camera = camera;
    }

    addLight(light) {
        this.lights.push({
            entity: light,
            meshRender: new MeshRender(this.gl, light.mesh, light.mat)
        });
    }
    addMeshRender(mesh) { this.meshes.push(mesh); }
    addShadowMeshRender(mesh) { this.shadowMeshes.push(mesh); }

    render() {
        const gl = this.gl;

        gl.clearColor(0.0, 0.0, 0.0, 1.0); // Clear to black, fully opaque
        gl.clearDepth(1.0); // Clear everything
        gl.enable(gl.DEPTH_TEST); // Enable depth testing
        gl.depthFunc(gl.LEQUAL); // Near things obscure far things

        // gl.enable(gl.BLEND);
        // gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

        // console.assert(this.lights.length != 0, "No light");
        // console.assert(this.lights.length == 1, "Multiple lights");

        // for (let l = 0; l < this.lights.length; l++) {
        //     // Draw light
        //     // TODO: Support all kinds of transform
        //     this.lights[l].meshRender.mesh.transform.translate = this.lights[l].entity.lightPos;
        //     this.lights[l].meshRender.draw(this.camera);

        //     // Camera pass
        //     for (let i = 0; i < this.meshes.length; i++) {
        //         this.gl.useProgram(this.meshes[i].shader.program.glShaderProgram);
        //         // this.gl.uniform3fv(this.meshes[i].shader.program.uniforms.uLightPos, this.lights[l].entity.lightPos);
        //         this.meshes[i].draw(this.camera);
        //     }
        // }
        for(let i in Lights.lightPoss)
        {
            
            if(i%3) continue;
            // console.log(typeof(i));
            i = parseInt(i);
            let meshh = Mesh.cube(setTransform(0, 0, 0, 2, 2, 2, 0));
            meshh.transform.translate = [Lights.lightPoss[i],Lights.lightPoss[i+1],Lights.lightPoss[i+2]];
            // console.log(i,Lights.lightPoss[i],Lights.lightPoss[i+1],Lights.lightPoss[i+2]);
            // meshh.transform.translate = [100,100,10];
            let MeshR = new MeshRender(this.gl,meshh,new EmissiveMaterial([Lights.lightRadiances[i],Lights.lightRadiances[i+1],Lights.lightRadiances[i+2]]));
            MeshR.draw(this.camera);
            break;
        }
        
        for (let i = 0; i < this.meshes.length; i++) {
            this.gl.useProgram(this.meshes[i].shader.program.glShaderProgram);
            // this.gl.uniform3fv(this.meshes[i].shader.program.uniforms.uLightPos, this.lights[l].entity.lightPos);
            this.meshes[i].draw(this.camera);
        }

    }
}
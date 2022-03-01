class lights{
    lightPoss;
    lightRadiances;
    constructor()
    {
        this.size  = 0;
        this.lightPoss = new Array();
        this.lightRadiances = new Array();
    }
    addLight(pos,radiance)
    {
        this.size++;
        this.lightPoss.push.apply(this.lightPoss,pos);
        this.lightRadiances.push.apply(this.lightRadiances,radiance);
    }
}
function genTwist(renderer)
{
    metallic = 1;
    let minx = -50,maxx = 50,miny = -5,maxy = 5,minz = -5,maxz = 5;

    let Sphere53Transform = setTransform(0, 0, 0, 100/7.188224, 10/7.188224,10/7.188224, 0, Math.PI, 0);


    loadOBJ(renderer, 'assets/testObj/', 'testObj', 'KnitwearMaterial', Sphere53Transform, metallic,
	1,1,
	// [minx,maxy,maxz,maxx,maxy,maxz,maxx,miny,maxz,minx,miny,maxz]
	[minx,maxy,maxz,minx,miny,maxz,maxx,miny,maxz,maxx,maxy,maxz]
	,[minx,maxy,minz,maxx,maxy,minz,maxx,miny,minz,minx,miny,minz],

	[minx,maxy,minz, minx,maxy,maxz, maxx,maxy,maxz, maxx,maxy,minz],
	[minx,miny,minz,maxx,miny,minz,maxx,miny,maxz,minx,miny,maxz],

	[maxx,miny,minz,maxx,maxy,minz,maxx,maxy,maxz,maxx,miny,maxz],
	[minx,miny,minz,minx,miny,maxz,minx,maxy,maxz,minx,maxy,minz]);

}
/*
14 6
23 1 3 5 2 23 3 45 4 23 5 32 6 32
1 2 3 4 5 6
*/
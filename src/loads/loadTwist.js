
function genTwist(renderer,Start = [0,0,0],End = [20,20,20],R = 10,twistRate = 30)
{
    metallic = 1;
	let len = (Start[0] - End[0]) * (Start[0] - End[0]) + (Start[1] - End[1])*(Start[1] - End[1]) + (Start[2] - End[2])*(Start[2] - End[2]);
	len = Math.sqrt(len);

	
	let dir = [Start[0] - End[0],Start[1] - End[1],Start[2] - End[2]];
	dir[0]/=-len,dir[1]/=-len;dir[2]/=-len;

	let xscale = len/2/3.594112,yscale = R/3.594112,zscale = R/3.594112;
    // let minx = -50,maxx = 50,miny = -5,maxy = 5,minz = -5,maxz = 5;
	let minx = -3.594112,maxx = 3.594112,miny = -3.594112,maxy = 3.594112,minz = -3.594112,maxz = 3.594112;
	// minx *= xscale;maxx *= xscale;miny *= yscale;maxy *= yscale;minz *= zscale;maxz *= zscale;
	let theta = dir[2]*dir[2]+dir[0]*dir[0] + 1
	 - dir[2]*dir[2] - (dir[0]-1)*(dir[0]-1);
	 console.log(dir[0]*dir[0] + 1,(dir[0]-1)*(dir[0]-1),dir[0])
	theta /= 2 * Math.sqrt(dir[2]*dir[2]+dir[0]*dir[0]);

	console.log(theta)

	theta = Math.acos(theta);
	
	if(dir[2] < 0)
	{
		theta *= -1;
	}
	console.log(theta);
    let Sphere53Transform = setTransform((Start[0]+End[0])/2,(Start[1]+End[1])/2,(Start[2]+End[2])/2,
	 xscale,yscale ,zscale, 0,-theta,Math.atan2(dir[1],Math.sqrt(dir[2]*dir[2]+dir[0]*dir[0])));
	// let Sphere53Transform = setTransform((Start[0]+End[0])/2,(Start[1]+End[1])/2,(Start[2]+End[2])/2,
	//  xscale,yscale ,zscale, 0,-Math.PI/4,Math.PI/4);



    loadOBJ(renderer, 'assets/testObj/', 'testObj', 'KnitwearMaterial', Sphere53Transform, metallic,
	1,1,
	// [minx,maxy,maxz,maxx,maxy,maxz,maxx,miny,maxz,minx,miny,maxz]
	[minx,maxy,maxz,minx,miny,maxz,maxx,miny,maxz,maxx,maxy,maxz]
	,[minx,maxy,minz,maxx,maxy,minz,maxx,miny,minz,minx,miny,minz],

	[minx,maxy,minz, minx,maxy,maxz, maxx,maxy,maxz, maxx,maxy,minz],
	[minx,miny,minz,maxx,miny,minz,maxx,miny,maxz,minx,miny,maxz],

	[maxx,miny,minz,maxx,maxy,minz,maxx,maxy,maxz,maxx,miny,maxz],
	[minx,miny,minz,minx,miny,maxz,minx,maxy,maxz,minx,maxy,minz],(maxz - minz)*zscale,(maxy - miny)*yscale,twistRate);

}
/*
14 6
23 1 3 5 2 23 3 45 4 23 5 32 6 32
1 2 3 4 5 6
*/
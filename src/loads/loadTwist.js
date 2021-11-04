function genTwistByR(renderer,r = 10,twistRate = 100)
{
	// genTwist(renderer,[-100,0,0],[100,0,0]);
	let H = 20;
	let d =  2*r;
	let k3 = Math.sqrt(3);

	let pointSet = [[-8*d,-r,H],[-8*d,-d-r,H],[-8*d,-2*d - r,H],[-8*d,-3 * d - r,H],
	[8*d,-r,H],[8*d,-d-r,H],[8*d,-2*d - r,H],[8*d,-3 * d - r,H]];
	let lastSet = [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
	let SP = [-4/k3*d,0,H];
	let delta = [[0,0,0],[0,0,d],[4*d/k3,-4*d,0],[0,0,-d],[0,0,0]];
	// let delta = [[0,0,0]];
	for(let i in delta)
	{
		for(let j = 0 ;j< 4;j++)
		{
			lastSet[j][0] = pointSet[j][0];
			lastSet[j][1] = pointSet[j][1];
			lastSet[j][2] = pointSet[j][2];
			//console.log("LOG ",i);
			if(i == 0) pointSet[j][0] = (3/k3*d*(2*j+1))/2-8/k3*d;
			else if( i == 4) pointSet[j][0] = 8*d;
			else pointSet[j][0] += delta[i][0],pointSet[j][1] += delta[i][1],pointSet[j][2]+=delta[i][2];
			// console.log("log ",lastSet[j])
			// if(lastSet[j][0]) 
			genTwist(renderer,[lastSet[j][0],lastSet[j][1],lastSet[j][2]]
				,[pointSet[j][0],pointSet[j][1],pointSet[j][2]],r*5/4,twistRate);
		}
		// for(let j = 0;j < 4;j++)
		// {
		// 	lastSet[j+4][0] = pointSet[j+4][0];
		// 	lastSet[j+4][1] = pointSet[j+4][1];
		// 	lastSet[j+4][2] = pointSet[j+4][2];

		// 	pointSet[j+4][0] = -pointSet[j][0];
		// 	pointSet[j+4][1] = pointSet[j][1];
		// 	pointSet[j+4][2] = pointSet[j][2];

		// 	genTwist(renderer,[lastSet[j+4][0],lastSet[j+4][1],lastSet[j+4][2]]
		// 		,[pointSet[j+4][0],pointSet[j+4][1],pointSet[j+4][2]],r,twistRate);
		// }
	}
	console.log(")))))))))))))))))))))))))))))))))))))");
	console.log(pointSet);
}
function genTwist(renderer,Start = [0,0,0],End = [0,0,200],R = 10,twistRate = 50)
{
    metallic = 1;
	console.log(Start,End);
	console.log(typeof(Start[0]))
	let len = (Start[0] - End[0]) * (Start[0] - End[0]) + (Start[1] - End[1])*(Start[1] - End[1]) + (Start[2] - End[2])*(Start[2] - End[2]);
	len = Math.sqrt(len);
	console.log(len);

	
	let dir = [Start[0] - End[0],Start[1] - End[1],Start[2] - End[2]];
	dir[0]/=-len,dir[1]/=-len;dir[2]/=-len;

	let xscale = len/2/3.594112,yscale = R/3.594112,zscale = R/3.594112;
    // let minx = -50,maxx = 50,miny = -5,maxy = 5,minz = -5,maxz = 5;
	let minx = -3.594112,maxx = 3.594112,miny = -3.594112,maxy = 3.594112,minz = -3.594112,maxz = 3.594112;
	// minx *= xscale;maxx *= xscale;miny *= yscale;maxy *= yscale;minz *= zscale;maxz *= zscale;
	let theta = dir[2]*dir[2]+dir[0]*dir[0] + 1
	 - dir[2]*dir[2] - (dir[0]-1)*(dir[0]-1);
	//  console.log(dir[0]*dir[0] + 1,(dir[0]-1)*(dir[0]-1),dir[0])
	theta /= 2 * Math.sqrt(dir[2]*dir[2]+dir[0]*dir[0]);

	theta = Math.acos(theta);
	
	if(dir[2] < 0)
	{
		theta *= -1;
	}
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
	[minx,miny,minz,minx,miny,maxz,minx,maxy,maxz,minx,maxy,minz],
	(maxz - minz)*zscale,(maxy - miny)*yscale,twistRate);

}
/*
14 6
23 1 3 5 2 23 3 45 4 23 5 32 6 32
1 2 3 4 5 6
*/
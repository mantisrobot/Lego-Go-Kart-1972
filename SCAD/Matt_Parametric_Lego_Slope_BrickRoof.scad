$fn=40;

eps = 0.05;
dummySize = 20;

// dimensions of brick in units
nrOfLengthUnits = 1;
nrOfWidthUnits = 2;


pitch = 8.0;
space = 0.04;
thickness = (1.6-space);
thicknessHeight = 2.3;
height = 9.6;
heightInner = 2.2;

cylinderTopRadius = 4.8 / 2;
cylinderTopHeight = 1.7;

cylinderBottomOuterRadius = 6.66 / 2;
cylinderBottomInnerRadius = 4.95 / 2;

length = nrOfLengthUnits * pitch - 2 * space;
width = nrOfWidthUnits * pitch - 2 * space;



module drawOuterCut()
{
	rotate([0,0,-90]) rotate([90,0,0]) linear_extrude(height=length+2*eps, center=true) polygon([[pitch,height],[pitch,height+dummySize],[width+eps,height+dummySize],[width+eps,heightInner],[pitch,height]]);
}


module drawInnerCut()
{
	rotate([0,0,-90]) rotate([90,0,0]) linear_extrude(height=length-2*thickness, center=true) polygon([[0,0],[width-2*thickness,0],[width-2*thickness,heightInner+eps],[pitch-thickness,height-heightInner+eps],[0, height-heightInner+eps]]);
}


// 2d primitive for outside fillets.
module fil_2d_o(r, angle=90) {
  intersection() {
    circle(r=r);
    polygon([
      [0, 0],
      [0, r],
      [r * tan(angle/2), r],
      [r * sin(angle), r * cos(angle)]
    ]);
  }
}

// 3d polar outside fillet.
module fil_polar_o(R, r, h, angle=90) {
  union(){
	  translate([0,0,h]) {
		rotate_extrude(convexity=10) {
		    translate([R-r, 0, 0]) {
		      fil_2d_o(r, angle);
		    }
		  }
	      cylinder(r=R-r+0.1, h=r);
      }
      cylinder(r=R, h=h);
  }
}

module drawExternalPin()
{
	translate([0,0,h1-eps]) 
    {
        difference()
        {
            fil_polar_o(r_pin,r_fillet,h_pin-r_fillet,angle=90);
        }
    }
    
	//translate([0,0,h1-eps]) cylinder(h_pin+eps, r_pin, r_pin);
}

module drawRoof()
{
	difference()
	{
		union()
		{	
			translate([-length/2,-width/2,0]) cube([length, width, height]);
			for (i = [1:nrOfLengthUnits])
			{
				translate([i*pitch-nrOfLengthUnits*pitch/2-pitch/2,nrOfWidthUnits*pitch/2-pitch/2,height-eps]) cylinder(r=cylinderTopRadius, h=cylinderTopHeight+eps);
			}
		}
		union()
		{	
			translate([0, width/2,0]) drawOuterCut();
			translate([0, width/2-thickness,-eps]) drawInnerCut();
		}		
	}

	difference()
	{
		union()
		{
			if (nrOfLengthUnits > 1)
			{
				for (x = [1:nrOfLengthUnits-1])
				{
					for (y = [1:nrOfWidthUnits-1])
					{
						difference() {
							translate([x*pitch-nrOfLengthUnits*pitch/2,nrOfWidthUnits*pitch/2-y*pitch,0]) cylinder(r=cylinderBottomOuterRadius, h=height-thicknessHeight+eps);
							translate([x*pitch-nrOfLengthUnits*pitch/2,nrOfWidthUnits*pitch/2-y*pitch,-eps]) cylinder(r=cylinderBottomInnerRadius, h=height-thicknessHeight+eps);
						}
					}
				}
			} 
		}
		union() 
		{
			if (nrOfLengthUnits > 1)
			{
				translate([0, width/2,0]) drawOuterCut();
			}
		}
	}
}



drawRoof();


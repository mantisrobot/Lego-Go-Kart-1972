$fn=100;

eps = 0.01;
dummySize = 20;


nr_length_units = 2;
nr_width_units = 2;
nr_width_units_brick = 1;


unit_size = 8.0;

pitch = 8.0;

h1 = 9.6; // height
h2 = 8.4; // inner height
h3 = 2.2;

// pin1
r1 = 6.66/2;
r2 = 4.95/2;

// pin2
r3 = 3.2/2;

space = 0.04; // space between bricks
t1 = (1.6-space); // thickness
t2 = 0.7; // inner wall thickness


nr_length_units_brick = nr_length_units;
lengthBrick = nr_length_units_brick*unit_size + (nr_length_units_brick - 1) * (pitch - unit_size) - 2 * space;
widthBrick = nr_width_units_brick*unit_size + (nr_width_units_brick - 1) * (pitch - unit_size) - space;

nr_length_units_sloped_brick = nr_length_units;
nr_width_units_sloped_brick = nr_width_units - nr_width_units_brick;
lengthSlopedBrick = lengthBrick;
widthSlopedBrick = nr_width_units_sloped_brick * pitch - space;


h_pin = 1.7;
r_pin = 4.8/2;
r_pin2 = 3.0/2;
pitch = 8.0;
r_fillet = 0.25;

function odd(i) = i%2;

function even(i) = !odd(i);


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


module drawExternalHollowPin()
{
	difference()
	{
        translate([0,0,0]) 
        {
            difference()
            {
                fil_polar_o(r_pin,r_fillet,h1+h_pin-r_fillet,angle=90);
            }
        }
	//	translate([0,0,0]) cylinder(h1+h_pin, r_pin, r_pin);
		translate([0,0,-eps]) cylinder(h1+h_pin+2*eps, r_pin2, r_pin2);
	}
}


module drawInternalPin1()
{
	difference()
	{
		translate([0,0,0]) cylinder(h2+eps, r1, r1);
		translate([0,0,-eps]) cylinder(h2+2*eps, r2, r2);
	}
}


module drawInternalPin2()
{
	cylinder(h2+eps, r3, r3);
}


module drawInnerWallsX()
{
	for (x = [1:nr_length_units_brick-1])
	{
		if ((nr_length_units_brick > 1) && (even(x) || odd(nr_length_units_brick)))
		{
			difference()
			{
				union()
				{
					translate([space,space,0]) translate([x*pitch-(pitch-unit_size)/2-t2/2,t1,0]) cube([t2,widthBrick-2*t1,h2+eps]);
				}
				union()
				{
					if (nr_width_units_brick > 1)
					{
						for (y = [1:nr_width_units_brick-1]) 
						{
							translate([x*pitch-(pitch-unit_size)/2,y*pitch-(pitch-unit_size)/2,-eps]) cylinder(h1+2*eps, r2, r2);
						}
					}
				}
			}
		}
	}
}


module drawInnerWallsY()
{
	for (y = [1:nr_width_units_brick-1])
	{
		if ((nr_width_units_brick > 1) && (even(y) || odd(nr_width_units_brick)))
		{
			difference()
			{
				union()
				{
					translate([space,space,0]) translate([t1,y*pitch-(pitch-unit_size)/2-t2/2,0]) cube([lengthBrick-2*t1,t2,h2+eps]);
				}
				union()
				{
					if (nr_length_units_brick > 1)
					{
						for (x = [1:nr_length_units_brick-1]) 
						{
							translate([x*pitch-(pitch-unit_size)/2,y*pitch-(pitch-unit_size)/2,-eps]) cylinder(h1+2*eps, r2, r2);
						}
					}
				}
			}
		}
	}
}


module drawInternalPins()
{
	if ((nr_length_units_brick > 1) && (nr_width_units_brick > 1)) 
	{
		for (x = [1:nr_length_units_brick-1])
		{
			for (y = [1:nr_width_units_brick-1]) 
			{	
				translate([x*pitch-(pitch-unit_size)/2,y*pitch-(pitch-unit_size)/2,0]) drawInternalPin1();
			}
		}
	}

	if ((nr_width_units_brick == 1) && (nr_length_units_brick > 1))
	{
		for (x = [1:nr_length_units_brick-1])
		{
			translate([x*pitch-(pitch-unit_size)/2,widthBrick/2,0]) drawInternalPin2();
		}
	}

	if ((nr_length_units_brick == 1) && (nr_width_units_brick > 1))
	{
		for (y = [1:nr_width_units_brick-1])
		{
			translate([lengthBrick/2,y*pitch-(pitch-unit_size)/2,0]) drawInternalPin2();
		}
	}
}


module drawExternalPins()
{
	for (x = [1:nr_length_units_brick])
	{
		for (y = [1:nr_width_units_brick])
		{	
			translate([x*pitch-pitch+unit_size/2,y*pitch-pitch+unit_size/2,0]) drawExternalPin();
		}
	}
}


module drawBrick() 
{
	translate([space,0,0]) 
	{	
		difference()
		{
			union()
			{	
				translate([0,-eps,0]) cube([lengthBrick,widthBrick+eps,h1]);
			}
			union()
			{	
				translate([t1,t1,-eps]) cube([lengthBrick-2*t1,widthBrick-2*t1,h2+eps]);
			}
		}		
	}

	drawInnerWallsX();
	drawInnerWallsY();
	drawInternalPins();
	drawExternalPins();
}


module drawOuterCut()
{
	rotate([0,0,90]) rotate([90,0,0]) linear_extrude(height=lengthSlopedBrick+2*eps, center=true) polygon([[0,0],[-widthSlopedBrick-eps,h1-h3],[-widthSlopedBrick-eps,-dummySize],[0,-dummySize],[0,0]]);
}


module drawInnerCut()
{
	alfa = atan((h1-h3)/widthSlopedBrick);
	rotate([0,0,90]) rotate([90,0,0]) linear_extrude(height=lengthSlopedBrick-2*t1, center=true) polygon([[eps,h3],[eps,dummySize],[-widthSlopedBrick+t1,dummySize],[-widthSlopedBrick+t1,h1-t1*tan(alfa)],[eps, h3]]);
}


module drawExternalPinsSlopedBrick()
{
	for (x = [1:nr_length_units_sloped_brick])
	{
		for (y = [1:nr_width_units_sloped_brick])
		{	
			translate([x*pitch-pitch+unit_size/2,(1-y)*pitch-pitch+unit_size/2,0]) drawExternalHollowPin();
		}
	}
}


module drawSlopedBrick()
{
	difference()
	{
		union()
		{	
			translate([-lengthSlopedBrick/2,-widthSlopedBrick,0]) cube([lengthSlopedBrick, widthSlopedBrick, h1]);
		}
		union()
		{	
			drawOuterCut();
			drawInnerCut();
		}		
	}

	difference()
	{
		translate([-lengthSlopedBrick/2-space,0,0]) drawExternalPinsSlopedBrick();
		drawOuterCut();
	}
}


module drawInverseRoof()
{
	translate([-lengthBrick/2-space,0,0]) drawBrick();
	drawSlopedBrick();
}



drawInverseRoof();

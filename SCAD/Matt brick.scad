$fn=100;

eps = 0.1;

nr_length_units = 4;
nr_width_units = 2;

unit_size = 8.0;

pitch = 8.0;

h1 = 9.6; // height
h2 = 8.4; // inner height

// pin1
r1 = 6.66/2;
r2 = 4.95/2;

// pin2
r3 = 3.2/2;


space = 0.04; // space between bricks
t1 = (1.6-space); // thickness
t2 = 0.7; // inner wall thickness


length = nr_length_units*unit_size + (nr_length_units - 1) * (pitch - unit_size) - 2 * space;
width = nr_width_units*unit_size + (nr_width_units - 1) * (pitch - unit_size) - 2 * space;


h_pin = 1.7;
r_pin = 4.8/2;
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
	for (x = [1:nr_length_units-1])
	{
		if ((nr_length_units > 1) && (even(x) || odd(nr_length_units)))
		{
			difference()
			{
				union()
				{
					translate([space,space,0]) translate([x*pitch-(pitch-unit_size)/2-t2/2,t1,0]) cube([t2,width-2*t1,h2+eps]);
				}
				union()
				{
					if (nr_width_units > 1)
					{
						for (y = [1:nr_width_units-1]) 
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
	for (y = [1:nr_width_units-1])
	{
		if ((nr_width_units > 1) && (even(y) || odd(nr_width_units)))
		{
			difference()
			{
				union()
				{
					translate([space,space,0]) translate([t1,y*pitch-(pitch-unit_size)/2-t2/2,0]) cube([length-2*t1,t2,h2+eps]);
				}
				union()
				{
					if (nr_length_units > 1)
					{
						for (x = [1:nr_length_units-1]) 
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
	if ((nr_length_units > 1) && (nr_width_units > 1)) 
	{
		for (x = [1:nr_length_units-1])
		{
			for (y = [1:nr_width_units-1]) 
			{	
				translate([x*pitch-(pitch-unit_size)/2,y*pitch-(pitch-unit_size)/2,0]) drawInternalPin1();
			}
		}
	}

	if ((nr_width_units == 1) && (nr_length_units > 1))
	{
		for (x = [1:nr_length_units-1])
		{
			translate([x*pitch-(pitch-unit_size)/2,width/2,0]) drawInternalPin2();
		}
	}

	if ((nr_length_units == 1) && (nr_width_units > 1))
	{
		for (y = [1:nr_width_units-1])
		{
			translate([length/2,y*pitch-(pitch-unit_size)/2,0]) drawInternalPin2();
		}
	}
}


module drawExternalPins()
{
	for (x = [1:nr_length_units])
	{
		for (y = [1:nr_width_units])
		{	
			translate([x*pitch-pitch+unit_size/2,y*pitch-pitch+unit_size/2,0]) drawExternalPin();
		}
	}
}


module drawBrick() 
{
	translate([space,space,0]) 
	{	
		difference()
		{
			union()
			{	
				cube([length,width,h1]);
			}
			union()
			{	
				translate([t1,t1,-eps]) cube([length-2*t1,width-2*t1,h2+eps]);
			}
		}		
	}

	drawInnerWallsX();
	drawInnerWallsY();
	drawInternalPins();
	drawExternalPins();
}


drawBrick();




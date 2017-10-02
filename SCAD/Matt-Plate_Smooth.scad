$fn=100;

eps = 0.1;

nr_length_units = 2;
nr_width_units = 1;

unit_size = 8.0;

pitch = 8.0;
space = 0.04; // space between bricks

h1 = 3.2; // height
h2 = 2.0; // 1.9 inner height

// pin1
r1 = 6.512/2; // 6.4
r2 = 4.8/2; // inner inside pin hole

// pin2
r3 = 3.2/2; // small inner pin diameter
r4 = 1.5/2;


t1 = (1.6-space); // thickness

length = nr_length_units*unit_size + (nr_length_units - 1) * (pitch - unit_size) - 2 * space;
width = nr_width_units*unit_size + (nr_width_units - 1) * (pitch - unit_size) - 2 * space;


h_pin = 1.6; // 1.9
r_pin = 4.8/2; // top pin
r_fillet = 0.25; // top pin fillet


module drawExternalPin()
{
	translate([0,0,h1-eps]) 
    {
        //cylinder(h_pin+eps, r_pin, r_pin);
        fil_polar_o(r_pin,r_fillet,h_pin+eps-r_fillet,angle=90);
    }
}


module drawInternalPin1()
{
	difference()
	{
		translate([0,0,0]) cylinder(h1, r1, r1);
		translate([0,0,-2*eps]) cylinder(h1+2*eps, r2, r2);
	}
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


module drawInternalPin2()
{
	difference()
	{
		translate([0,0,0]) cylinder(h1, r3, r3);
		translate([0,0,-2*eps]) cylinder(h1+2*eps, r4, r4);
	}
}


module drawPlate() 
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
/*
	for (x = [1:nr_length_units])
	{
		for (y = [1:nr_width_units])
		{	
			translate([x*pitch-pitch+unit_size/2,y*pitch-pitch+unit_size/2,0])
                    drawExternalPin();
		}
	}
*/
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



drawPlate();



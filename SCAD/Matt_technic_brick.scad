$fn=100;

eps = 0.1;

nr_length_units = 4;
nr_width_units = 1;

unit_size = 8.0;

pitch = 8.0;

h1 = 9.6; // height
h2 = 8.4; // inner height

// pin1
r1 = 6.66/2; //6.4
r2 = 4.95/2; // 4.8 

// pin2
r3 = 3.2/2; // smaller pin single row

// pinhole
ph1 = unit_size;
ph2 = 0.8; // bearing inset
ph3 = 5.6; // center hole offset
pr1 = 25.0/2;
pr2 = 4.95/2; // bearing hole
pr3 = 6.2/2; // bearing inset hole
pr4 = 7.4/2; // bearing outer


space = 0.04; // space between bricks
t1 = (1.6-space); // thickness
t2 = 1.5; // inner wall thickness


length = nr_length_units*unit_size + (nr_length_units - 1) * (pitch - unit_size) - 2 * space;
width = nr_width_units*unit_size + (nr_width_units - 1) * (pitch - unit_size) - 2 * space;


h_pin = 1.6;
r_pin1 = 4.8/2;
r_pin2 = 3.2/2;
r_fillet = 0.25;


module drawPinHole()
{
	translate([0,space,ph3]) rotate([-90,0,0])
	{
		ph = ph1 - 2*space;
		translate([0,0,-eps]) cylinder(ph2+eps, pr3, pr3);
		translate([0,0,ph2-eps]) cylinder(ph-2*ph2+2*eps, pr2, pr2);
		translate([0,0,ph-ph2]) cylinder(ph2+eps, pr3, pr3);
	}
}


module drawDoublePinHole()
{
    drawPinHole();
    ph = ph1 - 2*space;
    translate([0,ph,0]) drawPinHole();
}


module drawFullPinHole()
{
    drawDoublePinHole();
    ph = ph1 - 2*space;    
    translate([0,width-2*ph,0]) drawDoublePinHole();
    translate([0,space-eps,ph3]) rotate([-90,0,0]) cylinder(width+2*eps, pr2, pr2);
}


module drawPinHoles()
{
    if (nr_length_units > 1)
    {
        for (x = [1:nr_length_units-1])
        {
            translate([x*pitch,0,0]) drawFullPinHole();
        }
    }
}


module drawPinHoleBearing()
{
    translate([0,space+ph2,ph3]) rotate([-90,0,0])
    {
        ph = width - 2*ph2;
        difference()
        {
            translate([0,0,-eps]) cylinder(ph+2*eps, pr4, pr4);
            translate([0,0,-2*eps]) cylinder(ph+4*eps, pr2, pr2);
        }
    }
}


module drawPinHoleBearings()
{
    if (nr_length_units > 1)
    {
        for (x = [1:nr_length_units-1])
        {
            translate([x*pitch,0,0]) drawPinHoleBearing();
        }
    }
}


module drawExternalPin()
{
	translate([0,0,h1-eps]) 
    {
        difference()
        {
            fil_polar_o(r_pin1,r_fillet,h_pin-r_fillet,angle=90);
            //cylinder(h_pin+eps, r_pin1, r_pin1);
            cylinder(h_pin+2*eps, r_pin2, r_pin2);
        }
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
		if (nr_length_units > 1)
		{
			difference()
			{
				union()
				{
					translate([x*pitch-(pitch-unit_size)/2-t2/2,space+t1-eps,0]) cube([t2,width-2*t1+2*eps,h2+eps]);
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
	drawInternalPins();
	drawExternalPins();
}


module drawHoledBrick()
{
    difference()
    {
        union()
        {
            drawBrick();
            drawPinHoleBearings();
        }
        union()
        {
            drawPinHoles();
        }
    }    
}


drawHoledBrick();

